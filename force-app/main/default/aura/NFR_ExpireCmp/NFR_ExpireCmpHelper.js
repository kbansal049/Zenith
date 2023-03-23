({
    recordUpdateHelper : function(component, event, helper) {
        var expStatus = component.get("v.record").NFR_Licence_Status__c;
        if(expStatus === "Expired"){
            component.set("v.isExpired", true);
        }else{
           component.set("v.isExpired", false); 
        }
    },
    updateRecordLDSHelper : function(component, event, helper) {
        var NFRStatus = component.get("v.record").RecordType.Name;
        if(NFRStatus === 'Partners'){
            component.set("v.record.NFR_Licence_Status__c","Expiration Requested");
        }else{
        	component.set("v.record.NFR_Licence_Status__c","Expired");
            component.set("v.record.Approval_Status__c","Expired");
        }
        component.set("v.spinner", true); 
        component.find("recordLoader").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") { 
                var isVFPage = component.get("v.fromVF");
                if(isVFPage){
                    component.set("v.fromVF1", true);  
                }                
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();                
                component.set("v.spinner", false);  
                var toastEvent = $A.get("e.force:showToast");
                $A.get('e.force:refreshView').fire();
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Successfully expired the NFR."
                });
                toastEvent.fire();
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + 
                            JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
    }
})