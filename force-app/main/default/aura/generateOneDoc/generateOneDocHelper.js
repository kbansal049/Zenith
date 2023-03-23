({
    openSingleFile: function(cmp, event, helper) {
        var fileID = cmp.get("v.fileID");
        if(fileID){
            var navService = cmp.find("navService");
            var pageReference = {
                type: 'standard__namedPage',
                attributes: {
                    objectApiName: 'filePreview',
                },
                state : {
                    selectedRecordId: fileID
                }
            };
            
            cmp.set("v.pageReference", pageReference);
            
            var defaultUrl = "#";
            navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
               helper.handlePreviewFile(cmp, event, helper);
            }), $A.getCallback(function(error) {
                
            }));
        }
    },
    
    handlePreviewFile: function(cmp, event, helper) {
        var navService = cmp.find("navService");
        // Uses the pageReference definition in the init handler
        var pageReference = cmp.get("v.pageReference");
        navService.navigate(pageReference);
    }
    
})