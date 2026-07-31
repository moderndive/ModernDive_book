// Declare startupMessageQWebR globally
globalThis.qwebrStartupMessage = document.createElement("p");

// Verify if OffScreenCanvas is supported
globalThis.qwebrOffScreenCanvasSupport = function() {
  return typeof OffscreenCanvas !== 'undefined'
}

// Function to set the button text
globalThis.qwebrSetInteractiveButtonState = function(buttonText, enableCodeButton = true) {
  document.querySelectorAll(".qwebr-button-run").forEach((btn) => {
    btn.innerHTML = buttonText;
    btn.disabled = !enableCodeButton;
  });
}

// Function to update the status message in non-interactive cells
globalThis.qwebrUpdateStatusMessage = function(message) {
  document.querySelectorAll(".qwebr-status-text.qwebr-cell-needs-evaluation").forEach((elem) => {
    elem.innerText = message;
  });
}

// Function to update the status message
globalThis.qwebrUpdateStatusHeader = function(message) {
  qwebrStartupMessage.innerHTML = `
    <i class="fa-solid fa-spinner fa-spin qwebr-icon-status-spinner"></i>
    <span>${message}</span>`;
}

// Function to return true if element is found, false if not
globalThis.qwebrCheckHTMLElementExists = function(selector) {
  const element = document.querySelector(selector);
  return !!element;
}

// Function that detects whether reveal.js slides are present
globalThis.qwebrIsRevealJS = function() {
  // If the '.reveal .slides' selector exists, RevealJS is likely present
  return qwebrCheckHTMLElementExists('.reveal .slides');
}

// Initialize the Quarto sidebar element
function qwebrSetupQuartoSidebar() {
  var newSideBarDiv = document.createElement('div');
  newSideBarDiv.id = 'quarto-margin-sidebar';
  newSideBarDiv.className = 'sidebar margin-sidebar';
  newSideBarDiv.style.top = '0px';
  newSideBarDiv.style.maxHeight = 'calc(0px + 100vh)';

  return newSideBarDiv;
}

// Position the sidebar in the document
function qwebrPlaceQuartoSidebar() {
  // Get the reference to the element with id 'quarto-document-content'
  var referenceNode = document.getElementById('quarto-document-content');

  // Create the new div element
  var newSideBarDiv = qwebrSetupQuartoSidebar();

  // Insert the new div before the 'quarto-document-content' element
  referenceNode.parentNode.insertBefore(newSideBarDiv, referenceNode);
}

function qwebrPlaceMessageContents(content, html_location = "title-block-header", revealjs_location = "title-slide") {

  // Get references to header elements
  const headerHTML = document.getElementById(html_location);
  const headerRevealJS = document.getElementById(revealjs_location);

  // Determine where to insert the quartoTitleMeta element
  if (headerHTML || headerRevealJS) {
    // Append to the existing "title-block-header" element or "title-slide" div
    (headerHTML || headerRevealJS).appendChild(content);
  } else {
    // If neither headerHTML nor headerRevealJS is found, insert after "webr-monaco-editor-init" script
    const monacoScript = document.getElementById("qwebr-monaco-editor-init");
    const header = document.createElement("header");
    header.setAttribute("id", "title-block-header");
    header.appendChild(content);
    monacoScript.after(header);
  }
}



function qwebrOffScreenCanvasSupportWarningMessage() {
  
  // Verify canvas is supported.
  if(qwebrOffScreenCanvasSupport()) return;

  // Create the main container div
  var calloutContainer = document.createElement('div');
  calloutContainer.classList.add('callout', 'callout-style-default', 'callout-warning', 'callout-titled');

  // Create the header div
  var headerDiv = document.createElement('div');
  headerDiv.classList.add('callout-header', 'd-flex', 'align-content-center');

  // Create the icon container div
  var iconContainer = document.createElement('div');
  iconContainer.classList.add('callout-icon-container');

  // Create the icon element
  var iconElement = document.createElement('i');
  iconElement.classList.add('callout-icon');

  // Append the icon element to the icon container
  iconContainer.appendChild(iconElement);

  // Create the title container div
  var titleContainer = document.createElement('div');
  titleContainer.classList.add('callout-title-container', 'flex-fill');
  titleContainer.innerText = 'Warning: Web Browser Does Not Support Graphing!';

  // Append the icon container and title container to the header div
  headerDiv.appendChild(iconContainer);
  headerDiv.appendChild(titleContainer);

  // Create the body container div
  var bodyContainer = document.createElement('div');
  bodyContainer.classList.add('callout-body-container', 'callout-body');

  // Create the paragraph element for the body content
  var paragraphElement = document.createElement('p');
  paragraphElement.innerHTML = 'This web browser does not have support for displaying graphs through the <code>quarto-webr</code> extension since it lacks an <code>OffScreenCanvas</code>. Please upgrade your web browser to one that supports <code>OffScreenCanvas</code>.';

  // Append the paragraph element to the body container
  bodyContainer.appendChild(paragraphElement);

  // Append the header div and body container to the main container div
  calloutContainer.appendChild(headerDiv);
  calloutContainer.appendChild(bodyContainer);

  // Append the main container div to the document depending on format
  qwebrPlaceMessageContents(calloutContainer, "title-block-header"); 

}


// Function that attaches the document status message and diagnostics
function displayStartupMessage(showStartupMessage, showHeaderMessage) {
  if (!showStartupMessage) {
    return;
  }

  // Create the outermost div element for metadata
  const quartoTitleMeta = document.createElement("div");
  quartoTitleMeta.classList.add("quarto-title-meta");

  // Create the first inner div element
  const firstInnerDiv = document.createElement("div");
  firstInnerDiv.setAttribute("id", "qwebr-status-message-area");

  // Create the second inner div element for "WebR Status" heading and contents
  const secondInnerDiv = document.createElement("div");
  secondInnerDiv.setAttribute("id", "qwebr-status-message-title");
  secondInnerDiv.classList.add("quarto-title-meta-heading");
  secondInnerDiv.innerText = "WebR Status";

  // Create another inner div for contents
  const secondInnerDivContents = document.createElement("div");
  secondInnerDivContents.setAttribute("id", "qwebr-status-message-body");
  secondInnerDivContents.classList.add("quarto-title-meta-contents");

  // Describe the WebR state
  qwebrStartupMessage.innerText = "🟡 Loading...";
  qwebrStartupMessage.setAttribute("id", "qwebr-status-message-text");
  // Add `aria-live` to auto-announce the startup status to screen readers
  qwebrStartupMessage.setAttribute("aria-live", "assertive");

  // Append the startup message to the contents
  secondInnerDivContents.appendChild(qwebrStartupMessage);

  // Add a status indicator for COOP and COEP Headers if needed
  if (showHeaderMessage) {
    const crossOriginMessage = document.createElement("p");
    crossOriginMessage.innerText = `${crossOriginIsolated ? '🟢' : '🟡'} COOP & COEP Headers`;
    crossOriginMessage.setAttribute("id", "qwebr-coop-coep-header");
    secondInnerDivContents.appendChild(crossOriginMessage);
  }

  // Combine the inner divs and contents
  firstInnerDiv.appendChild(secondInnerDiv);
  firstInnerDiv.appendChild(secondInnerDivContents);
  quartoTitleMeta.appendChild(firstInnerDiv);

  // Place message on webpage
  qwebrPlaceMessageContents(quartoTitleMeta); 
}

function qwebrAddCommandHistoryModal() {
  // Create the modal div
  var modalDiv = document.createElement('div');
  modalDiv.id = 'qwebr-history-modal';
  modalDiv.className = 'qwebr-modal';

  // Create the modal content div
  var modalContentDiv = document.createElement('div');
  modalContentDiv.className = 'qwebr-modal-content';

  // Create the span for closing the modal
  var closeSpan = document.createElement('span');
  closeSpan.id = 'qwebr-command-history-close-btn';
  closeSpan.className = 'qwebr-modal-close';
  closeSpan.innerHTML = '&times;';

  // Create the h1 element for the modal
  var modalH1 = document.createElement('h1');
  modalH1.textContent = 'R History Command Contents';

  // Create an anchor element for downloading the Rhistory file 
  var downloadLink = document.createElement('a');
  downloadLink.href = '#';
  downloadLink.id = 'qwebr-download-history-btn';
  downloadLink.className = 'qwebr-download-btn';

  // Create an 'i' element for the icon
  var icon = document.createElement('i');
  icon.className = 'bi bi-file-code';

  // Append the icon to the anchor element
  downloadLink.appendChild(icon);

  // Add the text 'Download R History' to the anchor element
  downloadLink.appendChild(document.createTextNode(' Download R History File'));

  // Create the pre for command history contents
  var commandContentsPre = document.createElement('pre');
  commandContentsPre.id = 'qwebr-command-history-contents';
  commandContentsPre.className = 'qwebr-modal-content-code';

  // Append the close span, h1, and history contents pre to the modal content div
  modalContentDiv.appendChild(closeSpan);
  modalContentDiv.appendChild(modalH1);
  modalContentDiv.appendChild(downloadLink);
  modalContentDiv.appendChild(commandContentsPre);

  // Append the modal content div to the modal div
  modalDiv.appendChild(modalContentDiv);

  // Append the modal div to the body
  document.body.appendChild(modalDiv);
}

function qwebrRegisterRevealJSCommandHistoryModal() {
  // Select the <ul> element inside the <div> with data-panel="Custom0"
  let ulElement = document.querySelector('div[data-panel="Custom0"] > ul.slide-menu-items');

  // Find the last <li> element with class slide-tool-item
  let lastItem = ulElement.querySelector('li.slide-tool-item:last-child');

  // Calculate the next data-item value
  let nextItemValue = 0;
  if (lastItem) {
      nextItemValue = parseInt(lastItem.dataset.item) + 1;
  }

  // Create a new <li> element
  let newListItem = document.createElement('li');
  newListItem.className = 'slide-tool-item';
  newListItem.dataset.item = nextItemValue.toString(); // Set the next available data-item value

  // Create the <a> element inside the <li>
  let newLink = document.createElement('a');
  newLink.href = '#';
  newLink.id = 'qwebrRHistoryButton'; // Set the ID for the new link
  
  // Create the <kbd> element inside the <a>
  let newKbd = document.createElement('kbd');
  newKbd.textContent = ' '; // Set to empty as we are not registering a keyboard shortcut

  // Create text node for the link text
  let newText = document.createTextNode(' View R History');

  // Append <kbd> and text node to <a>
  newLink.appendChild(newKbd);
  newLink.appendChild(newText);

  // Append <a> to <li>
  newListItem.appendChild(newLink);

  // Append <li> to <ul>
  ulElement.appendChild(newListItem);
}

// Handle setting up the R history modal
function qwebrCodeLinks() {

  if (qwebrIsRevealJS()) {
    qwebrRegisterRevealJSCommandHistoryModal();
    return;
  }

  // Create the container div
  var containerDiv = document.createElement('div');
  containerDiv.className = 'quarto-code-links';

  // Create the h2 element
  var h2 = document.createElement('h2');
  h2.textContent = 'webR Code Links';

  // Create the ul element
  var ul = document.createElement('ul');

  // Create the li element
  var li = document.createElement('li');

  // Create the a_history_btn element
  var a_history_btn = document.createElement('a');
  a_history_btn.href = 'javascript:void(0)';
  a_history_btn.setAttribute('id', 'qwebrRHistoryButton');

  // Create the i_history_btn element
  var i_history_btn = document.createElement('i');
  i_history_btn.className = 'bi bi-file-code';

  // Create the text node for the link text
  var text_history_btn = document.createTextNode('View R History');

  // Append the icon element and link text to the a element
  a_history_btn.appendChild(i_history_btn);
  a_history_btn.appendChild(text_history_btn);

  // Append the a element to the li element
  li.appendChild(a_history_btn);

  // Append the li element to the ul element
  ul.appendChild(li);

  // Append the h2 and ul elements to the container div
  containerDiv.appendChild(h2);
  containerDiv.appendChild(ul);

  // Append the container div to the element with the ID 'quarto-margin-sidebar'
  var sidebar = document.getElementById('quarto-margin-sidebar');
    
  // If the sidebar element is not found, create it
  if(!sidebar) {
    qwebrPlaceQuartoSidebar();
  }
  
  // Re-select the sidebar element (if it was just created)
  sidebar = document.getElementById('quarto-margin-sidebar');   


  // If the sidebar element exists, append the container div to it
  if(sidebar) {
    // Append the container div to the sidebar
    sidebar.appendChild(containerDiv);
    // Force the sidebar to be clickable by removing the 'zindex-bottom' class
    // added in pre-release: https://github.com/quarto-dev/quarto-cli/commit/f0c53a1ffcaa1de4eccbf07803b096898248adcc
    sidebar.className = 'sidebar margin-sidebar';
  } else {
    // Get a debugger ...
    console.warn('Element with ID "quarto-margin-sidebar" not found.');
  }
}

// Call the function to append the code links for qwebR into the right sidebar
qwebrCodeLinks();

// Add the command history modal
qwebrAddCommandHistoryModal();

displayStartupMessage(qwebrShowStartupMessage, qwebrShowHeaderMessage);
qwebrOffScreenCanvasSupportWarningMessage();