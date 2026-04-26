// Define a global storage and retrieval solution ----

// Store commands executed in R
globalThis.qwebrRCommandHistory = [];

// Function to retrieve the command history
globalThis.qwebrFormatRHistory = function() {
   return qwebrRCommandHistory.join("\n\n");
}

// Retrieve HTML Elements ----

// Get the command modal
const command_history_modal = document.getElementById("qwebr-history-modal");

// Get the button that opens the command modal
const command_history_btn = document.getElementById("qwebrRHistoryButton");

// Get the <span> element that closes the command modal
const command_history_close_span = document.getElementById("qwebr-command-history-close-btn");

// Get the download button for r history information
const command_history_download_btn = document.getElementById("qwebr-download-history-btn");

// Plug in command history into modal/download button ----

// Function to populate the modal with command history
function populateCommandHistoryModal() {
    document.getElementById("qwebr-command-history-contents").innerHTML = qwebrFormatRHistory() || "No commands have been executed yet.";
}

// Function to format the current date and time to
// a string with the format YYYY-MM-DD-HH-MM-SS
function formatDateTime() {
    const now = new Date();

    const year = now.getFullYear();
    const day = String(now.getDate()).padStart(2, '0');
    const month = String(now.getMonth() + 1).padStart(2, '0'); // Months are zero-based
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');

    return `${year}-${month}-${day}-${hours}-${minutes}-${seconds}`;
}


// Function to convert document title with datetime to a safe filename
function safeFileName() {
    // Get the current page title
    let pageTitle = document.title;

    // Combine the current page title with the current date and time
    let pageNameWithDateTime = `Rhistory-${pageTitle}-${formatDateTime()}`;

    // Replace unsafe characters with safe alternatives
    let safeFilename = pageNameWithDateTime.replace(/[\\/:\*\?! "<>\|]/g, '-');

    return safeFilename;
}


// Function to download list contents as text file
function downloadRHistory() {
    // Get the current page title + datetime and use it as the filename
    const filename = `${safeFileName()}.R`;

    // Get the text contents of the R History list
    const text = qwebrFormatRHistory();

    // Create a new Blob object with the text contents
    const blob = new Blob([text], { type: 'text/plain' });
  
    // Create a new anchor element for the download
    const a = document.createElement('a');
    a.style.display = 'none';
    a.href = URL.createObjectURL(blob);
    a.download = filename;

    // Append the anchor to the body, click it, and remove it
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
}

// Register event handlers ----

// When the user clicks the View R History button, open the command modal
command_history_btn.onclick = function() {
    populateCommandHistoryModal();
    command_history_modal.style.display = "block";
}

// When the user clicks on <span> (x), close the command modal
command_history_close_span.onclick = function() {
    command_history_modal.style.display = "none";
}

// When the user clicks anywhere outside of the command modal, close it
window.onclick = function(event) {
    if (event.target == command_history_modal) {
        command_history_modal.style.display = "none";
    }
}

// Add an onclick event listener to the download button so that
// the user can download the R history as a text file
command_history_download_btn.onclick = function() {
    downloadRHistory();
};