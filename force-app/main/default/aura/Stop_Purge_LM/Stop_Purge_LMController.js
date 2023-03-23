({
    doInit : function(component, event, helper) {
        var ProvReqId = component.get("v.recordId");
        component.set("v.showSpinner",true);
        var action = component.get("c.GetProvReqDetail");
        action.setParams({
            'ProvReqId': component.get("v.recordId")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner",false);
            if (state === "SUCCESS") {
                $A.get('e.force:closeQuickAction').fire();
                var Data = response.getReturnValue();
                console.log('Data.Provisioning_Status__c '+Data.Provisioning_Status__c);
				if(Data.Provisioning_Status__c != 'To Be Purged' && Data.Provisioning_Status__c != 'Decommissioned' && Data.Provisioning_Status__c != 'Awaiting Rep Confirmation'){
                	alert('Provisioning Request Status has to be "To Be Purged" or "Decommissioned" or "Awaiting Rep Confirmation"');
                }
                else if (Data.Provisioning_Status__c == 'To Be Purged' || Data.Provisioning_Status__c == 'Decommissioned' || Data.Provisioning_Status__c == 'Awaiting Rep Confirmation'){
                	window.open('/apex/PRStopPurgePage?id=' + Data.Id,'_Parent');
                }
            }
            else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
                $A.get('e.force:closeQuickAction').fire();
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + 
                                  errors[0].message);
                        }
                        $A.get('e.force:closeQuickAction').fire();
                    } 
                    else {
                        alert("Unknown error");
                        $A.get('e.force:closeQuickAction').fire();
                    }
                }
        });
        $A.enqueueAction(action);
    }
})