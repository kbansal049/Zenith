({
    ConfirmPR : function(component, event, helper) {
        var rec = component.get("v.record");       
        console.log('inside ConfirmPR method '+rec);
        
        if(rec.fields.Provisioning_Status__c.value == 'Request Decommission' || rec.fields.Provisioning_Status__c.value == 'Decommissioned'){
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Error!",
					"message": "Decommission was previously requested. This action cannot be performed."
			});
				toastEvent.fire();
		}else{
            if (confirm("Only FeVa Provisioning Request can be submitted now. Inline POC and Zscaler Shift Provisioning Requests can be submitted only from Stage 2 onwards.\nDo you want to continue?")) {
				if (confirm("Are you sure you want to Purge the PR as well! ")){
					rec.fields.SE_Confirms_for_Purge_Process__c.value=true;
				}else{
					rec.fields.SE_Confirms_for_Purge_Process__c.value=false;
				}			
				rec.fields.Provisioning_Status__c.value='Request Decommission';
				component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
					console.log('inside save record part ');
					// use the recordUpdated event handler to handle generic logic when record is changed
					 if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "SUCCESS!",
							"message": "PR has been requested for Decommission successfully"
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