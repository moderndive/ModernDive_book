// Layer C of the webR test pyramid: evaluate every {webr-r} cell in a real
// headless webR (browser-side R compiled to wasm, here running in Node via
// @r-wasm/webr). Catches the bugs Layer B can't — anything specific to
// webR's runtime: shadow `library()` actually working (not no-op'd by an
// installed package), `readr::read_csv` decoding gzipped CSVs from
// raw.githubusercontent.com over HTTP, namespace shadowing edge cases.
//
// One webR session for the whole run; globalenv is cleared between chapters
// (attached packages remain). Setup cells run before other cells per chapter
// to match Quarto's `#| context: setup` behavior.

import { WebR } from '@r-wasm/webr';
import fs from 'node:fs';
import path from 'node:path';

const ROOT = process.env.GITHUB_WORKSPACE
  ?? path.resolve(path.dirname(new URL(import.meta.url).pathname), '../..');

const PRELOAD = [
  'ggplot2', 'dplyr', 'tidyr', 'readr',
  'moderndive', 'nycflights23', 'fivethirtyeight',
  'patchwork', 'infer',
];

function extractWebrCells(qmdPath) {
  const content = fs.readFileSync(qmdPath, 'utf8');
  const re = /```\{webr-r[^}]*\}([\s\S]*?)```/g;
  const cells = [];
  let m, idx = 0;
  while ((m = re.exec(content)) !== null) {
    idx += 1;
    const body = m[1];
    cells.push({
      body,
      idx,
      isSetup: /context:\s*setup/.test(body.slice(0, 120)),
    });
  }
  // Setup cells run first regardless of file position (Quarto behavior).
  return [...cells.filter(c => c.isSetup), ...cells.filter(c => !c.isSetup)];
}

async function evalCell(webR, code) {
  const shelter = await new webR.Shelter();
  try {
    const result = await shelter.captureR(code, {
      withAutoprint: false,
      captureStreams: true,
      captureConditions: true,
    });
    // captureConditions surfaces errors that didn't throw natively
    const errCondition = result.output.find(
      o => o.type === 'message' && /Error/i.test(o.data?.message ?? ''),
    );
    if (errCondition) {
      throw new Error(errCondition.data.message);
    }
    return result;
  } finally {
    await shelter.purge();
  }
}

async function main() {
  console.log('=== Layer C: headless webR cell evaluation ===');
  const webR = new WebR({ interactive: false });
  await webR.init();
  console.log('webR initialised\n');

  console.log(`Installing preload packages: ${PRELOAD.join(', ')}`);
  await webR.installPackages(PRELOAD, true);
  console.log('packages installed\n');

  const qmdFiles = fs.readdirSync(ROOT)
    .filter(f => /^[0-9]+.*\.qmd$/.test(f))
    .sort();

  let totalCells = 0;
  const failures = [];

  for (const qmd of qmdFiles) {
    const cells = extractWebrCells(path.join(ROOT, qmd));
    if (cells.length === 0) continue;
    console.log(`== ${qmd} (${cells.length} webR cells) ==`);

    // Clear globalenv between chapters but keep attached packages.
    await webR.evalR('rm(list = ls(envir = globalenv()), envir = globalenv())');

    for (const cell of cells) {
      totalCells += 1;
      const label = cell.isSetup ? 'setup' : `cell #${cell.idx}`;
      try {
        await evalCell(webR, cell.body);
        console.log(`  ✓ ${label}`);
      } catch (e) {
        console.log(`  ✗ ${label}: ${e.message.split('\n')[0]}`);
        failures.push({ qmd, label, msg: e.message });
      }
    }
  }

  await webR.close();

  console.log(`\n========================`);
  console.log(`Total webR cells evaluated: ${totalCells}`);
  console.log(`Failed: ${failures.length}`);
  if (failures.length > 0) {
    console.log('\nFailures:');
    for (const f of failures) {
      console.log(`  ${f.qmd}  ${f.label}\n    ${f.msg.split('\n')[0]}`);
    }
    process.exit(1);
  }
  console.log(`\n✓ all ${totalCells} webR cells passed in headless webR`);
}

main().catch(e => {
  console.error('FATAL:', e);
  process.exit(2);
});
