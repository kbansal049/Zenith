({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("Salesforce_Support_Ticket_Creation");
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Salesforce_Support_Ticket_Creation");
    },
    //Flow Status Change
    statusChange : function (component, event, helper) {
        //Check Flow Status
        if (event.getParam('status') === "FINISHED") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: "Ticket has been logged successfully. IT engineer will get in touch with you shortly.",
                type: "success"
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        } else if (event.getParam('status') === "ERROR") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Failure!",
                message: "Something went wrong.Please try again !!",
                type: "error"
            });
            toastEvent.fire();
        }
    }
})