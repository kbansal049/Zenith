({
    invokeVFPage : function(component, event, helper) {
        helper.invokeVFPageHelper(component, event, helper);
    },
    recordUpdate : function(component, event, helper) {
        //const userPrfName = component.get('v.CurrentUser')['Profile'].Name;
        //alert('userPrfName'+component.get("v.record").Federal_Deal_Approved_OP__c);
        var dealStatus = component.get("v.record").Status__c;
        //alert('dealStatus--'+dealStatus);
        if(dealStatus !== "Approved" && dealStatus !== "Pending Conversion" && dealStatus !== "Pending Expiration"){
            component.set("v.isStatus", true);
        }else{
            component.set("v.isStatus", false); 
        }
        if(component.get("v.record").Deal_Reg_Type__c == null){
            component.set("v.isType", true);
        }else{
           component.set("v.isType", false); 
        }
        if(component.get("v.record").Discovery_Meeting_Date__c == null && component.get("v.record").Deal_Reg_Type__c == "Sourced"){
            component.set("v.isDate", true);
        }else{
          component.set("v.isDate", false);  
        }
        if(component.get("v.record").Federal_Deal_Approved_OP__c){          
            component.set("v.isFDA", true);
        }else{
           component.set("v.isFDA", false); 
        }
    },
    closeQA : function(component,event, helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})