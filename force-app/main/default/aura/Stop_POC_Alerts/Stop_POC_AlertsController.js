({
    StopPOCAlerts : function(component, event, helper) {
        var rec = component.get("v.record");       
        console.log('inside StopPOCAlerts method '+rec);
		if(rec.fields.Send_Reminder_Emails__c.value == false){
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Error!",
					"message": "There are no POC decommission alerts being sent at this time. Click on the Start POC alert button to start sending alerts"
			});
				toastEvent.fire();
		}else if(rec.fields.Send_Reminder_Emails__c.value == true){
			if(confirm("Do you want to stop sending email reminder?")){			
				rec.fields.Email_Sent__c.value=null;
				rec.fields.Send_Reminder_Emails__c.value=false;
				component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
					console.log('inside save record part ');
					// use the recordUpdated event handler to handle generic logic when record is changed
					 if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "SUCCESS!",
							"message": "POC alerts has been stopped for PR successfully"
						});
						toastEvent.fire();
					} else if (saveResult.state === "INCOMPLETE") {
						console.log("User is offline, device doesn't support drafts.");
					} else if (saveResult.state === "ERROR") {
						console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": JSON.stringify(saveResult.error)
                        });
						toastEvent.fire();
					} else {
						console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
					} 
                    $A.get('e.force:closeQuickAction').fire();
				}));
			}else{
				$A.get('e.force:closeQuickAction').fire();	
			}
		}
		$A.get('e.force:closeQuickAction').fire();	
        
    },
	 /**
     * Control the component behavior here when record is changed (via any component)
     */
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
            // get the fields that changed for this record
            var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            // record is changed, so refresh the component (or other component logic)
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Saved",
                "message": "The record was updated."
            });
            resultsToast.fire();

        } else if(eventParams.changeType === "LOADED") {
            // record is loaded in the cache
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving or deleting the record
        }
    }
})