({
    ForcePurge : function(component, event, helper) {
        var rec = component.get("v.record");       
        console.log('inside ForcePurge method '+rec);
        
		if(rec.fields.Provisioning_Status__c.value == 'To Be Purged' || rec.fields.Provisioning_Status__c.value == 'Awaiting Rep Confirmation'){
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Error!",
					"message": "Provisioning Request is already in process for Purge Approval"
			});
				toastEvent.fire();
		}else if(rec.fields.Provisioning_Status__c.value == 'Purged'){
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Error!",
					"message": "Provisioning Request has already Purged successfully"
			});
				toastEvent.fire();
		}else if(rec.fields.Provisioning_Status__c.value == 'Requested' ||
					rec.fields.Provisioning_Status__c.value == 'In Progress' ||
					rec.fields.Provisioning_Status__c.value == 'Provisioned' ||
					rec.fields.Provisioning_Status__c.value == 'Request Decommission' ||
					rec.fields.Provisioning_Status__c.value == 'Failed' ||
					rec.fields.Provisioning_Status__c.value == 'Disabled' ||
					rec.fields.Provisioning_Status__c.value == 'Provisioning Failed' ||
					rec.fields.Provisioning_Status__c.value == 'Production'){
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Error!",
					"message": "Provisioning Request cannot enter Purge Process with current Provisioning Status.Status has to be 'To Be Purged' or 'Decommissioned' or 'Awaiting Rep Confirmation'"
			});
				toastEvent.fire();
		}else if(rec.fields.Provisioning_Status__c.value == 'Decommisioned' ||
					rec.fields.Provisioning_Status__c.value == 'Purge Stopped' ||
					rec.fields.Provisioning_Status__c.value == 'Purge Approval Rejected' ){
				
				rec.fields.Provisioning_Status__c.value='Awaiting Rep Confirmation';
				rec.fields.Approval_for_Purge_Status__c.value='Not Yet Submitted for Purge Approval';
				rec.fields.RunGDPRvalidations__c.value='True';
				component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
					console.log('inside save record part ');
					// use the recordUpdated event handler to handle generic logic when record is changed
					 if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "SUCCESS!",
							"message": "PR has been requested for Force Purge successfully"
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