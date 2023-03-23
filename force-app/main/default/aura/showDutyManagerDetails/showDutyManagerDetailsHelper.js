({
    pollDetails : function(component, event, helper){
    helper.getDetails(component,event,helper);
    helper.checkEscalation(component,event,helper);
    var pollingTime = $A.get("$Label.c.DutyManagerPollingTime");
    //window.setInterval(helper.callApexPriorityCheck(component,helper),1000); 
    window.setInterval(
        $A.getCallback(function() { 
            helper.getDetails(component,helper);
            //helper.checkEscalation(component,helper);
        }), pollingTime
    );
},

getDetails : function(component, event, helper){
    try {
        let action = component.get("c.getDetails");
        action.setParams
        ({
            recordId:component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var returnData = response.getReturnValue();
            console.log('First Data-->'+ JSON.stringify(returnData));
            component.set("v.dutyManagerDetails", response.getReturnValue());
        });
        $A.enqueueAction(action);
    } catch (error) {
        console.log('Error Get Details '+error.message);
    }
},
checkEscalation : function(component, event, helper){
    try {
        let action = component.get("c.checkEscalation");
        action.setParams
        ({
            recordId:component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var returnData = response.getReturnValue();
            console.log('First Data Escalated-->'+ JSON.stringify(returnData));
            component.set("v.checkEscalation", response.getReturnValue());
        });
        $A.enqueueAction(action);
        
    } catch (error) {
        console.log('Error Check Escalation '+error.message);
        
    }
}
})