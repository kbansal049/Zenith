({
    hideModalHelper: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        component.set("v.showModal", false);
    },
})