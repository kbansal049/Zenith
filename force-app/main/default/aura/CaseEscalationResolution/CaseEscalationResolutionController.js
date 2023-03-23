({
	myAction : function(component, event, helper) {
        
        var action_getCaseNotesHistory = component.get("c.getCaseNotesHistory");
        action_getCaseNotesHistory.setParams({
            caseId: component.get("v.recordId")
        });

        action_getCaseNotesHistory.setCallback(this, function(data) {
            component.set("v.caseNoteHistory", data.getReturnValue());
        });
        $A.enqueueAction(action_getCaseNotesHistory); 
    }
})