({
	onInit : function(component, event, helper) {
		let action = component.get( "c.acceptOpp" );  
        action.setParams({  
            recId: component.get( "v.recordId" )
        });  
        action.setCallback(this, function(response) {  
            let state = response.getState(); 
            if(state === "SUCCESS"){  
            	var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: "success",
                        message: "Opportunity has been accepted."
                    });
                    toastEvent.fire(); 
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();    
            }
            else{
            	var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: "error",
                    message: "There were issues in accepting the opportunity. Please reach out to salesforce suppport."
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();    
            }
        });
        $A.enqueueAction( action );
	}
})