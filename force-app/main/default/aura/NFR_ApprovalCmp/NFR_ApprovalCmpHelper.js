({
	recordUpdateHelper : function(component, event, helper) {
		if(component.get("v.record").Approval_Status__c != "Approved" && 
          component.get("v.record").Approval_Status__c != "Submitted" && 
          component.get("v.record").NFR_Sales_Engineer__c != null){
            component.set("v.spinner", true);   
            var action = component.get("c.submitForApproval");
            var id = component.get("v.recordId");
            action.setParams({
                "recId": id
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS" && response.getReturnValue()==true) {
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    $A.get('e.force:refreshView').fire();
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Successfully submitted for approval."
                    });
                    toastEvent.fire();
                    component.set("v.spinner", false);   
                    var isVFPage = component.get("v.fromVF");
                    if(isVFPage){
                        component.set("v.showSuccessVF", true);
                        component.set("v.successMsg", "Successfully submitted for approval");
                    }                    
                }
                else{
                    component.set("v.spinner", false);   
                    component.set("v.failed",true);
                }                
            });
            $A.enqueueAction(action);
        }
	}
})