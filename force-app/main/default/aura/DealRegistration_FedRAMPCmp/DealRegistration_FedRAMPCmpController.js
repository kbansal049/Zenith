({
    recordUpdate : function(component, event, helper) {
        var dealStatus = component.get("v.record").Status__c;
        if(dealStatus !== "Approved" && dealStatus !== "Pending Conversion" && dealStatus !== "Pending Expiration" &&
           dealStatus !== null){
            component.set("v.isStatus", true);
        }else{
            component.set("v.isStatus", false); 
        }
        if(component.get("v.record").Deal_Reg_Type__c == null){
            component.set("v.isType", true);
        }
        else{
            component.set("v.isType", false); 
        }
        if(component.get("v.record").Discovery_Meeting_Date__c == null && component.get("v.record").Deal_Reg_Type__c == "Sourced"){
            component.set("v.isDate", true);
        }
        else{
            component.set("v.isDate", false);
        }
        if(component.get("v.record").Federal_Deal_Approved_OP__c){
            component.set("v.isFDA", true);
        }else{
            component.set("v.isFDA", false);  
        }
    },
    invokeApex : function(component, event, helper) {
        var action = component.get("c.saveDealReg");
        component.set("v.spinner", true);
        action.setParams({
            "dealRegId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if(state == "SUCCESS" && component.isValid()){
                console.log("success") ;
                var result = response.getReturnValue();
                console.log(result);
                //alert(result);
                if(result){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/"+component.get("v.recordId")
                    });
                    urlEvent.fire();
                   // component.set("v.spinner", false);
                    //location.reload();
                   // $A.get('e.force:refreshView').fire();
                }else{                    
                    alert("Failed to update Deal Reg");  
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    component.set("v.spinner", false);
                }
            }else{
                console.error("fail:" + response.getError()[0].message); 
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    closeQA : function(component,event, helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})