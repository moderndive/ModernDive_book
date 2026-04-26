// Supported Evaluation Types for Context
globalThis.EvalTypes = Object.freeze({
  Interactive: 'interactive',
  Setup: 'setup',
  Output: 'output',
});

// Function that obtains the font size for a given element 
globalThis.qwebrCurrentFontSizeOnElement = function(element, cssProperty = 'font-size') {

  const currentFontSize = parseFloat(
    window
    .getComputedStyle(element)
    .getPropertyValue(cssProperty)
  );
  
  return currentFontSize;
}

// Function to determine font scaling
globalThis.qwebrScaledFontSize = function(div, qwebrOptions) {
  // Determine if we should compute font-size using RevealJS's `--r-main-font-size` 
  // or if we can directly use the document's `font-size`.
  const cssProperty = document.body.classList.contains('reveal') ? 
    "--r-main-font-size" : "font-size";
  
  // Get the current font size on the div element
  const elementFontSize = qwebrCurrentFontSizeOnElement(div, cssProperty);

  // Determine the scaled font size value
  const scaledFontSize = ((qwebrOptions['editor-font-scale'] ?? 1) * elementFontSize) ?? 17.5;

  return scaledFontSize;
}


// Function that dispatches the creation request
globalThis.qwebrCreateHTMLElement = function (
  cellData
) {

  // Extract key components
  const evalType = cellData.options.context;
  const qwebrCounter = cellData.id;

  // We make an assumption that insertion points are defined by the Lua filter as:
  // qwebr-insertion-location-{qwebrCounter} 
  const elementLocator = document.getElementById(`qwebr-insertion-location-${qwebrCounter}`);

  // Figure out the routine to use to insert the element.
  let qwebrElement;
  switch ( evalType ) {
    case EvalTypes.Interactive:
      qwebrElement = qwebrCreateInteractiveElement(qwebrCounter, cellData.options);
      break;
    case EvalTypes.Output: 
      qwebrElement = qwebrCreateNonInteractiveOutputElement(qwebrCounter, cellData.options);
      break;
    case EvalTypes.Setup: 
      qwebrElement = qwebrCreateNonInteractiveSetupElement(qwebrCounter, cellData.options);
      break;
    default: 
      qwebrElement = document.createElement('div');
      qwebrElement.textContent = 'Error creating `quarto-webr` element';
  }

  // Insert the dynamically generated object at the document location.
  elementLocator.appendChild(qwebrElement);
};

// Function that setups the interactive element creation
globalThis.qwebrCreateInteractiveElement = function (qwebrCounter, qwebrOptions) {

  // Create main div element
  var mainDiv = document.createElement('div');
  mainDiv.id = 'qwebr-interactive-area-' + qwebrCounter;
  mainDiv.className = `qwebr-interactive-area`;
  if (qwebrOptions.classes) {
    mainDiv.className += " " + qwebrOptions.classes
  }

  // Add a unique cell identifier that users can customize
  if (qwebrOptions.label) {
    mainDiv.setAttribute('data-id', qwebrOptions.label);
  }

  // Create toolbar div
  var toolbarDiv = document.createElement('div');
  toolbarDiv.className = 'qwebr-editor-toolbar';
  toolbarDiv.id = 'qwebr-editor-toolbar-' + qwebrCounter;

  // Create a div to hold the left buttons
  var leftButtonsDiv = document.createElement('div');
  leftButtonsDiv.className = 'qwebr-editor-toolbar-left-buttons';

  // Create a div to hold the right buttons
  var rightButtonsDiv = document.createElement('div');
  rightButtonsDiv.className = 'qwebr-editor-toolbar-right-buttons';

  // Create Run Code button
  var runCodeButton = document.createElement('button');
  runCodeButton.className = 'btn btn-default qwebr-button qwebr-button-run';
  runCodeButton.disabled = true;
  runCodeButton.type = 'button';
  runCodeButton.id = 'qwebr-button-run-' + qwebrCounter;
  runCodeButton.textContent = '🟡 Loading webR...';
  runCodeButton.title = `Run code (Shift + Enter)`;

  // Append buttons to the leftButtonsDiv
  leftButtonsDiv.appendChild(runCodeButton);

  // Create Reset button
  var resetButton = document.createElement('button');
  resetButton.className = 'btn btn-light btn-xs qwebr-button qwebr-button-reset';
  resetButton.type = 'button';
  resetButton.id = 'qwebr-button-reset-' + qwebrCounter;
  resetButton.title = 'Start over';
  resetButton.innerHTML = '<i class="fa-solid fa-arrows-rotate"></i>';

  // Create Copy button
  var copyButton = document.createElement('button');
  copyButton.className = 'btn btn-light btn-xs qwebr-button qwebr-button-copy';
  copyButton.type = 'button';
  copyButton.id = 'qwebr-button-copy-' + qwebrCounter;
  copyButton.title = 'Copy code';
  copyButton.innerHTML = '<i class="fa-regular fa-copy"></i>';

  // Append buttons to the rightButtonsDiv
  rightButtonsDiv.appendChild(resetButton);
  rightButtonsDiv.appendChild(copyButton);

  // Create console area div
  var consoleAreaDiv = document.createElement('div');
  consoleAreaDiv.id = 'qwebr-console-area-' + qwebrCounter;
  consoleAreaDiv.className = 'qwebr-console-area';

  // Create editor div
  var editorDiv = document.createElement('div');
  editorDiv.id = 'qwebr-editor-' + qwebrCounter;
  editorDiv.className = 'qwebr-editor';

  // Create output code area div
  var outputCodeAreaDiv = document.createElement('div');
  outputCodeAreaDiv.id = 'qwebr-output-code-area-' + qwebrCounter;
  outputCodeAreaDiv.className = 'qwebr-output-code-area';
  outputCodeAreaDiv.setAttribute('aria-live', 'assertive');

  // Create pre element inside output code area
  var preElement = document.createElement('pre');
  preElement.style.visibility = 'hidden';
  outputCodeAreaDiv.appendChild(preElement);

  // Create output graph area div
  var outputGraphAreaDiv = document.createElement('div');
  outputGraphAreaDiv.id = 'qwebr-output-graph-area-' + qwebrCounter;
  outputGraphAreaDiv.className = 'qwebr-output-graph-area';

  // Append buttons to the toolbar
  toolbarDiv.appendChild(leftButtonsDiv);
  toolbarDiv.appendChild(rightButtonsDiv);

  // Append all elements to the main div
  mainDiv.appendChild(toolbarDiv);
  consoleAreaDiv.appendChild(editorDiv);
  consoleAreaDiv.appendChild(outputCodeAreaDiv);
  mainDiv.appendChild(consoleAreaDiv);
  mainDiv.appendChild(outputGraphAreaDiv);

  return mainDiv;
}

// Function that adds output structure for non-interactive output
globalThis.qwebrCreateNonInteractiveOutputElement = function(qwebrCounter, qwebrOptions) {
  // Create main div element
  var mainDiv = document.createElement('div');
  mainDiv.id = 'qwebr-noninteractive-area-' + qwebrCounter;
  mainDiv.className = `qwebr-noninteractive-area`;
  if (qwebrOptions.classes) {
    mainDiv.className += " " + qwebrOptions.classes
  }
  
  // Add a unique cell identifier that users can customize
  if (qwebrOptions.label) {
    mainDiv.setAttribute('data-id', qwebrOptions.label);
  }
  
  // Create a status container div
  var statusContainer = createLoadingContainer(qwebrCounter);

  // Create output code area div
  var outputCodeAreaDiv = document.createElement('div');
  outputCodeAreaDiv.id = 'qwebr-output-code-area-' + qwebrCounter;
  outputCodeAreaDiv.className = 'qwebr-output-code-area';
  outputCodeAreaDiv.setAttribute('aria-live', 'assertive');

  // Create pre element inside output code area
  var preElement = document.createElement('pre');
  preElement.style.visibility = 'hidden';
  outputCodeAreaDiv.appendChild(preElement);

  // Create output graph area div
  var outputGraphAreaDiv = document.createElement('div');
  outputGraphAreaDiv.id = 'qwebr-output-graph-area-' + qwebrCounter;
  outputGraphAreaDiv.className = 'qwebr-output-graph-area';

  // Append all elements to the main div
  mainDiv.appendChild(statusContainer);
  mainDiv.appendChild(outputCodeAreaDiv);
  mainDiv.appendChild(outputGraphAreaDiv);

  return mainDiv;
};

// Function that adds a stub in the page to indicate a setup cell was used.
globalThis.qwebrCreateNonInteractiveSetupElement = function(qwebrCounter, qwebrOptions) {
  // Create main div element
  var mainDiv = document.createElement('div');
  mainDiv.id = `qwebr-noninteractive-setup-area-${qwebrCounter}`;
  mainDiv.className = `qwebr-noninteractive-setup-area`;
  if (qwebrOptions.classes) {
    mainDiv.className += " " + qwebrOptions.classes
  }


  // Add a unique cell identifier that users can customize
  if (qwebrOptions.label) {
    mainDiv.setAttribute('data-id', qwebrOptions.label);
  }

  // Create a status container div
  var statusContainer = createLoadingContainer(qwebrCounter);

  // Append status onto the main div
  mainDiv.appendChild(statusContainer);

  return mainDiv;
}


// Function to create loading container with specified ID
globalThis.createLoadingContainer = function(qwebrCounter) {

  // Create a status container
  const container = document.createElement('div');
  container.id = `qwebr-non-interactive-loading-container-${qwebrCounter}`;
  container.className = 'qwebr-non-interactive-loading-container qwebr-cell-needs-evaluation';

  // Create an R project logo to indicate its a code space
  const rProjectIcon = document.createElement('i');
  rProjectIcon.className = 'fa-brands fa-r-project fa-3x qwebr-r-project-logo';

  // Setup a loading icon from font awesome
  const spinnerIcon = document.createElement('i');
  spinnerIcon.className = 'fa-solid fa-spinner fa-spin fa-1x qwebr-icon-status-spinner';

  // Add a section for status text
  const statusText = document.createElement('p');
  statusText.id = `qwebr-status-text-${qwebrCounter}`;
  statusText.className = `qwebr-status-text qwebr-cell-needs-evaluation`;
  statusText.innerText = 'Loading webR...';

  // Incorporate an inner container
  const innerContainer = document.createElement('div');

  // Append elements to the inner container
  innerContainer.appendChild(spinnerIcon);
  innerContainer.appendChild(statusText);

  // Append elements to the main container
  container.appendChild(rProjectIcon);
  container.appendChild(innerContainer);

  return container;
}