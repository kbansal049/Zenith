({
    doInit : function(component, event, helper) {
        var action = component.get( "c.validateRecordLock" ); 
        var recId = component.get("v.recordId");
        action.setParams({recordId:recId});
        action.setCallback(this, function(response){  
            var state = response.getState();  
            if (state === "SUCCESS") {  
                component.set("v.showModal", true);
            }  
            else if (state === "ERROR") {
                var errors = response.getError();
                helper.hideModalHelper(component, event, helper);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'ERROR',
                    message:errors[0].message,
                    duration:'5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });  
        $A.enqueueAction(action);  
        
    },
    hideModal: function(component, event, helper) {
        helper.hideModalHelper(component, event, helper);
    },
    
    submitForApproval: function(component, event, helper) {
        var action = component.get( "c.evaluateRecordLEX" ); 
        var recId = component.get("v.recordId");
        action.setParams({recordId:recId});
        action.setCallback(this, function(response){  
            var state = response.getState();  
            if (state === "SUCCESS") { 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'SUCCESS',
                    "message": 'Submitted Successfully',
                    duration:'5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                helper.hideModalHelper(component, event, helper);
            }  
            else if (state === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'ERROR',
                    message:errors[0].message,
                    duration:'5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });  
        $A.enqueueAction(action);  
    }  
})