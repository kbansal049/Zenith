({  
    onInit : function( component, event, helper ) {    
        let action = component.get( "c.convertToContract" );  
        action.setParams({  
            recId: component.get( "v.recordId" )
        });  
        action.setCallback(this, function(response) {  
            let state = response.getState(); 
            if(state === "SUCCESS"){  
                let msg = response.getReturnValue();
                if(msg == 'Contract Detail records have been migrated successfully.'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: "success",
                        message: msg
                    });
                    toastEvent.fire(); 
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();   
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: "error",
                        message: msg
                    });
                    toastEvent.fire(); 
                    $A.get("e.force:closeQuickAction").fire();   
                }
            } 
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: "error",
                    message: "There were issues in migrating the Contract Detail records."
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });  
        $A.enqueueAction( action );         
    }   
})