#!/usr/bin/env perl
# Convert bookdown .Rmd -> Quarto .qmd in place (HTML-only).
use strict;
use warnings;

for my $file (@ARGV) {
    open(my $fh, '<', $file) or die "open $file: $!";
    local $/;
    my $text = <$fh>;
    close $fh;

    # --- 1. Collect (ref:LABEL) Caption definitions ---
    my %refs;
    while ($text =~ /^\(ref:([^)]+)\)\s*(.+?)\s*$/mg) {
        $refs{$1} = $2;
    }

    # --- 2. Inline (ref:LABEL) into fig.cap="(ref:LABEL)" ---
    $text =~ s!fig\.cap="\(ref:([^)]+)\)"!
        do {
            if (exists $refs{$1}) {
                my $cap = $refs{$1};
                $cap =~ s{\\}{\\\\}g;
                $cap =~ s{"}{\\"}g;
                qq(fig.cap="$cap");
            } else {
                qq(fig.cap="(ref:$1)");
            }
        }
    !ge;

    # --- 3. Drop (ref:LABEL) definition lines ---
    $text =~ s/^\(ref:[^)]+\)\s*.+?\n//mg;

    # --- 4. Discover labels referenced as figs / tables ---
    my (%fig_refs, %tbl_refs);
    $fig_refs{$1} = 1 while $text =~ /\\\@ref\(fig:([A-Za-z0-9_.\-]+)\)/g;
    $tbl_refs{$1} = 1 while $text =~ /\\\@ref\(tab:([A-Za-z0-9_.\-]+)\)/g;

    # --- 5. Rename chunk labels for referenced figs / tables ---
    for my $lbl (keys %fig_refs) {
        next if $lbl =~ /^(fig|tbl|sec)-/;
        my $q = quotemeta($lbl);
        $text =~ s/(^```\{r\s+)$q(?=[,\s\}])/${1}fig-$lbl/mg;
    }
    for my $lbl (keys %tbl_refs) {
        next if $lbl =~ /^(fig|tbl|sec)-/;
        my $q = quotemeta($lbl);
        $text =~ s/(^```\{r\s+)$q(?=[,\s\}])/${1}tbl-$lbl/mg;
    }

    # --- 6. Any remaining fig.cap= chunk without fig-/tbl-/sec- prefix ---
    $text =~ s!^```\{r\s+([A-Za-z0-9_.\-]+)(,[^\}]*)\}!
        do {
            my $lbl  = $1;
            my $opts = $2;
            if ($lbl =~ /^(fig|tbl|sec)-/) {
                "```{r $lbl$opts}";
            } elsif ($opts =~ /fig\.cap/) {
                "```{r fig-$lbl$opts}";
            } else {
                "```{r $lbl$opts}";
            }
        }
    !mge;

    # --- 7. Rewrite cross-refs (specific prefixes first, generic last) ---
    # Match \@ref(...) AND \\@ref(...) (the latter appears inside R strings
    # where bookdown required an escaped backslash).
    $text =~ s/\\?\\\@ref\(fig:([A-Za-z0-9_.\-]+)\)/\@fig-$1/g;
    $text =~ s/\\?\\\@ref\(tab:([A-Za-z0-9_.\-]+)\)/\@tbl-$1/g;
    $text =~ s/\\?\\\@ref\(eq:([A-Za-z0-9_.\-]+)\)/\@eq-$1/g;
    $text =~ s/\\?\\\@ref\(([A-Za-z0-9_.\-]+)\)/\@sec-$1/g;

    # Also strip stray leading backslashes left from earlier conversion runs
    # (e.g., \@fig-foo in already-converted files): these are illegal R escapes.
    $text =~ s/\\\@(fig|tbl|eq|sec)-/\@$1-/g;

    # --- 8. Heading anchors ---
    # {- #anchor} or {-#anchor} -> {.unnumbered #sec-anchor}
    $text =~ s!^(\#{1,6}[^\n]*?)\{-\s*\#([A-Za-z][A-Za-z0-9_.\-]*)\}!
        do {
            my $h = $1;
            my $a = $2;
            my $na = ($a =~ /^(sec|fig|tbl|eq)-/) ? $a : "sec-$a";
            "$h\{.unnumbered #$na\}";
        }
    !mge;
    # {#anchor[ classes]} -> {#sec-anchor[ classes]}
    $text =~ s!^(\#{1,6}[^\n]*?)\{\#([A-Za-z][A-Za-z0-9_.\-]*)(\s[^\}]*)?\}!
        do {
            my $h    = $1;
            my $a    = $2;
            my $rest = defined $3 ? $3 : '';
            if ($a =~ /^(sec|fig|tbl|eq)-/) {
                "$h\{#$a$rest\}";
            } else {
                "$h\{#sec-$a$rest\}";
            }
        }
    !mge;
    # {-} -> {.unnumbered}
    $text =~ s!^(\#{1,6}[^\n]*?)\{-\}!$1\{.unnumbered\}!mg;

    # --- 9. {block, type="..."} to :::{.type} fenced divs ---
    my @lines = split /\n/, $text, -1;
    my @out;
    my $in_block;
    for my $line (@lines) {
        if ($line =~ /^```\{block(?:\s+[A-Za-z0-9_.\-]+)?\s*,?\s*type=['"]([^'"]+)['"]/) {
            $in_block = $1;
            push @out, ":::{.$in_block}";
            next;
        }
        if (defined $in_block && $line =~ /^```\s*$/) {
            push @out, ":::";
            $in_block = undef;
            next;
        }
        if (defined $in_block && $line =~ /^\s*\\vspace\{/) {
            next;
        }
        push @out, $line;
    }
    $text = join("\n", @out);

    # --- 9b. Merge paired learncheck divs into one wrapping callout ---
    # bookdown emitted two separate divs (header + spacer); collapse them so
    # the questions live INSIDE the styled callout.
    $text =~ s{
        :::\{\.learncheck\}\s*\n
        \*\*_Learning\ check_\*\*\s*\n
        :::\s*\n
        (.*?)
        :::\{\.learncheck\}\s*\n
        :::\s*\n
    }{:::\{.learncheck\}\n**Learning Check**\n\n$1:::\n\n}gsx;

    # --- 9c. Prepend an init chunk that loads knitr + image_functions ---
    # Quarto runs each chapter in its own R session, and inline R such as
    # `r include_image(...)` can fire before the chapter's first R chunk,
    # so we add a hidden chunk at the very top (after YAML if present).
    if ($text !~ /\Q```{r setup-init,\E/) {
        my $init = "```{r setup-init, include=FALSE}\n"
                 . "library(knitr)\n"
                 . "source(\"scripts/image_functions.R\")\n"
                 . "```\n\n";
        if ($text =~ /\A(---\s*\n(?:.*?\n)?---\s*\n)/s) {
            my $front = $1;
            $text =~ s/\A\Q$front\E/$front\n$init/;
        } else {
            $text = $init . $text;
        }
    }

    # --- 10. Drop the (PART) emitter chunk (shows up in 02-visualization) ---
    $text =~ s!```\{r [^\}]*,\s*results="asis"[^\}]*\}\s*\nif \(is_latex_output\(\)\) \{\s*\n\s*cat\("# \(PART\)[^"]*"\)\s*\n\} else \{\s*\n\s*cat\("# \(PART\)[^"]*"\)\s*\n\}\s*\n```\s*\n!!g;

    open($fh, '>', $file) or die "write $file: $!";
    print $fh $text;
    close $fh;
    print STDERR "converted: $file\n";
}
