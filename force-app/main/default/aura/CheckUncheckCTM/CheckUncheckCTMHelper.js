({

    handleSaveRecord: function (component, event, helper) {
        component.find("forceRecordCmp").saveRecord($A.getCallback(function (saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success',
                    type: 'success',
                    message: "Contact Updated."
                });

                toastEvent.fire();
            } else if (saveResult.state === "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    type: 'error',
                    message: "User is offline, device doesn't support drafts."
                });

                toastEvent.fire();
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' +JSON.stringify(saveResult.error));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    type: 'error',
					message: 'Problem saving record, error: ' + (saveResult.error && saveResult.error[0] && saveResult.error[0].message)? (saveResult.error[0].message) : JSON.stringify(saveResult.error)  //Change for CR-748. Replaced JSON.stringify(saveResult.error)                  
                });

                toastEvent.fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    type: 'error',
                    message: 'Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error)
                });

                toastEvent.fire();
            }
            $A.get('e.force:closeQuickAction').fire();
        }));
    },
    showtoast: function (title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            type: type,
            message: message
        });

        toastEvent.fire();
    },
})