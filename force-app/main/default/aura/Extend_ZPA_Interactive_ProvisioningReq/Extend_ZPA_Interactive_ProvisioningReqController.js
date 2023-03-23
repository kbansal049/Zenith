({
    doInit : function(component, event, helper) {
        var ProvReqId = component.get("v.recordId");
        component.set("v.showSpinner",true);
        var action = component.get("c.ExtendZPAInteractive");
        action.setParams({
            'ProvReqId': component.get("v.recordId")
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner",false);
            if (state === "SUCCESS") {
                $A.get('e.force:closeQuickAction').fire();
                var DataMap = response.getReturnValue(); 
                if(DataMap.Status == 'Success'){
                    location.reload(); 
                }
                else if(DataMap.Status == 'Error'){
                    alert(DataMap.Message);
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