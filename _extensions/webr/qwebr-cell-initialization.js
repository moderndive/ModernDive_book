// Handle cell initialization initialization
qwebrCellDetails.map(
  (entry) => {
    // Handle the creation of the element
    qwebrCreateHTMLElement(entry);
    // In the event of interactive, initialize the monaco editor
    if (entry.options.context == EvalTypes.Interactive) {
      qwebrCreateMonacoEditorInstance(entry);
    }
  }
);

// Identify non-interactive cells (in order)
const filteredEntries = qwebrCellDetails.filter(entry => {
  const contextOption = entry.options && entry.options.context;
  return ['output', 'setup'].includes(contextOption) || (contextOption == "interactive" && entry.options && entry.options.autorun === 'true');
});

// Condition non-interactive cells to only be run after webR finishes its initialization.
qwebrInstance.then(
  async () => {
    const nHiddenCells = filteredEntries.length;
    var currentHiddenCell = 0;


    // Modify button state
    qwebrSetInteractiveButtonState(`🟡 Running hidden code cells ...`, false);

    // Begin processing non-interactive sections
    // Due to the iteration policy, we must use a for() loop.
    // Otherwise, we would need to switch to using reduce with an empty
    // starting promise
    for (const entry of filteredEntries) {

      // Determine cell being examined
      currentHiddenCell = currentHiddenCell + 1;
      const formattedMessage = `Evaluating hidden cell ${currentHiddenCell} out of ${nHiddenCells}`;

      // Update the document status header
      if (qwebrShowStartupMessage) {
        qwebrUpdateStatusHeader(formattedMessage);
      }

      // Display the update in non-active areas
      qwebrUpdateStatusMessage(formattedMessage);

      // Extract details on the active cell
      const evalType = entry.options.context;
      const cellCode = entry.code;
      const qwebrCounter = entry.id;

      if (['output', 'setup'].includes(evalType)) {
        // Disable further global status updates
        const activeContainer = document.getElementById(`qwebr-non-interactive-loading-container-${qwebrCounter}`);
        activeContainer.classList.remove('qwebr-cell-needs-evaluation');
        activeContainer.classList.add('qwebr-cell-evaluated');

        // Update status on the code cell
        const activeStatus = document.getElementById(`qwebr-status-text-${qwebrCounter}`);
        activeStatus.innerText = " Evaluating hidden code cell...";
        activeStatus.classList.remove('qwebr-cell-needs-evaluation');
        activeStatus.classList.add('qwebr-cell-evaluated');
      }

      switch (evalType) {
        case 'interactive':
          // TODO: Make this more standardized.
          // At the moment, we're overriding the interactive status update by pretending its
          // output-like. 
          const tempOptions = entry.options;
          tempOptions["context"] = "output"
          // Run the code in a non-interactive state that is geared to displaying output
          await qwebrExecuteCode(`${cellCode}`, qwebrCounter, tempOptions);
          break;
        case 'output':
          // Run the code in a non-interactive state that is geared to displaying output
          await qwebrExecuteCode(`${cellCode}`, qwebrCounter, entry.options);
          break;
        case 'setup':
          const activeDiv = document.getElementById(`qwebr-noninteractive-setup-area-${qwebrCounter}`);

          // Store code in history
          qwebrLogCodeToHistory(cellCode, entry.options);

          // Run the code in a non-interactive state with all output thrown away
          await mainWebR.evalRVoid(`${cellCode}`);
          break;
        default: 
          break; 
      }

      if (['output', 'setup'].includes(evalType)) {
        // Disable further global status updates
        const activeContainer = document.getElementById(`qwebr-non-interactive-loading-container-${qwebrCounter}`);
        // Disable visibility
        activeContainer.style.visibility = 'hidden';
        activeContainer.style.display = 'none';
      }
    }
  }
).then(
  () => {
    // Release document status as ready

    if (qwebrShowStartupMessage) {
      qwebrStartupMessage.innerText = "🟢 Ready!"
    }
  
    qwebrSetInteractiveButtonState(
      `<i class="fa-solid fa-play qwebr-icon-run-code"></i> <span>Run Code</span>`, 
      true
    );  
  }
);