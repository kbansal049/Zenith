({
    recordUpdate : function(component, event, helper) {
        var accRec = component.get("v.record");
        //alert(component.get("v.trafficAlert"));
        //var crntUsrAcc = component.get("v.currentUser").Traffic_Alert_on_Account__c;
        var crntUsrAcc = component.get("v.trafficAlert");
        var dateVal = new Date('2018-01-01');
        var firstConDate = new Date(accRec.First_Contract_Date__c);
        if(accRec.Type == 'Customer' && accRec.First_Contract_Date__c != null 
           && firstConDate < dateVal 
           && accRec.Bandwidth_LM_Vs_PM__c != null &&
           accRec.Bandwidth_LM_Vs_PM__c <= -15 && accRec.Bandwidth_LM_Vs_6M_Ago__c!= null && 
           accRec.Bandwidth_LM_Vs_6M_Ago__c <= -15 && accRec.Bandwidth_LM_Vs_12M_Ago__c != null && 
           accRec.Bandwidth_LM_Vs_12M_Ago__c <= -15
           && crntUsrAcc
          ){ 
            component.set("v.showMsg", true); 	
            var action = component.get("c.getAsyncApexJobDates");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.wrpr", response.getReturnValue());
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);  
        }        
    }
})