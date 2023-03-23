({
    recordUpdateHelper : function(component, event, helper) {
        var expStatus = component.get("v.record").NFR_Licence_Status__c;
        const expdate = new Date(component.get("v.record").Expiry_Date_FromStartDate__c);
        const date = new Date();
    	const oneDay = 1000 * 60 * 60 * 24;
    	const diffInTime = expdate.getTime() - date.getTime();
    	const diffInDays = Math.round(diffInTime / oneDay);
        console.log(diffInDays);
        console.log(expdate);
        console.log(date);
        if((diffInDays >=30 || expdate < date) &&  expStatus!="Expired"){
           component.set("v.isExpired30days", true);
        } else if (expStatus === "Not Active"){
            component.set("v.isExpired", true);
        }   else{
           component.set("v.isExpired", false); 
           component.set("v.isExpired30days", false)
        }
    },
    extendExpiryHelper : function(component, event, helper) {
        //NFRLicenceTriggerHandler: Line 220 - In-Progress is updated to Active
        var NFRStatus = component.get("v.record").RecordType.Name;
        component.set("v.record.NFR_Licence_Status__c","Extension Requested");
        component.set("v.record.Approval_Status__c","Extension Requested");
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
                    "message": "Successfully extended the NFR."
                });
                toastEvent.fire(); 
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + 
                            JSON.stringify(saveResult.error));
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                component.set("v.spinner", false); 
                var toastEvent = $A.get("e.force:showToast");
                $A.get('e.force:refreshView').fire();
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": 'Problem saving record, error: '+JSON.stringify(saveResult.error[0].message)
                });
                toastEvent.fire();
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
    }
})