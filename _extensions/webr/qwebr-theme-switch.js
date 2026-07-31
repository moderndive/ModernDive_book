// Function to update Monaco Editors when body class changes
function updateMonacoEditorsOnBodyClassChange() {
    // Select the body element
    const body = document.querySelector('body');

    // Options for the observer (which mutations to observe)
    const observerOptions = {
        attributes: true,  // Observe changes to attributes
        attributeFilter: ['class'] // Only observe changes to the 'class' attribute
    };

    // Callback function to execute when mutations are observed
    const bodyClassChangeCallback = function(mutationsList, observer) {
        for(let mutation of mutationsList) {
            if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
                // Class attribute has changed
                // Update all Monaco Editors on the page
                updateMonacoEditorTheme();
            }
        }
    };

    // Create an observer instance linked to the callback function
    const observer = new MutationObserver(bodyClassChangeCallback);

    // Start observing the target node for configured mutations
    observer.observe(body, observerOptions);
}

// Function to update all instances of Monaco Editors on the page
function updateMonacoEditorTheme() {
    // Determine what VS Theme to use
    const vsThemeToUse = document.body.classList.contains("quarto-dark") ? 'vs-dark' : 'vs' ;

    // Iterate through all initialized Monaco Editors
    qwebrEditorInstances.forEach( function(editorInstance) { 
        editorInstance.updateOptions({ theme: vsThemeToUse }); 
    });
}

// Call the function to start observing changes to body class
updateMonacoEditorsOnBodyClassChange();