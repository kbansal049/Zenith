({
    doInit : function(component, event, helper) {
        //var ProvReqId = component.get("v.recordId");
        component.set("v.showSpinner",true);
        var action = component.get("c.getProvisioningReqDetails");
        action.setParams({
            'ProvReqId': component.get("v.recordId")
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner",false);
            if (state === "SUCCESS") {
                $A.get('e.force:closeQuickAction').fire();
                var Data = response.getReturnValue();
                if(typeof Data.Provisioning_Status__c === 'undefined'){
                    if(typeof Data.Send_Initial_l__c === 'undefined' || Data.Send_Initial_l__c == ""){
                        alert("Please specify who is going to receive the login credential.");
                    }
                    else if(Data.Send_Initial_l__c == "SE" && (typeof Data.SE__c === 'undefined' || Data.SE__c == "")){
                        alert("Please specify the SE user");
                    }
                    else if(Data.Send_Initial_l__c == "Partner" && (typeof Data.Partner_Contact__c === 'undefined' || Data.Partner_Contact__c == "")){
                        alert("The request must have a partner contact");
                    }
					else if(Data.Send_Initial_l__c == "Customer" && (typeof Data.Primary_Eval_Contact__c === 'undefined' || Data.Primary_Eval_Contact__c == "")){
                    	alert("The request must have a Customer Contact");
                    }
                    else if(Data.RecordType.Name != "FeVa Cloud") {
                    	alert("This functionality is available only for the FeVa Cloud.");
                    }
                    else{
                        window.open('/apex/ProvisioningFevaRequest?id='+Data.Id,'_Parent');
                    }
                }else if(Data.Provisioning_Status__c != "" && Data.Provisioning_Status__c != "Not Requested") {
                    alert("Users Creation is not allowed at this status.");
                }
            }
            else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
                $A.get('e.force:closeQuickAction').fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                    $A.get('e.force:closeQuickAction').fire();
                } 
                else {
                    alert("Unknown error");
                    $A.get('e.force:closeQuickAction').fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})