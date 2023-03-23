({
    doInit : function(component, event, helper) {
        var ProvReqId = component.get("v.recordId");
        component.set("v.showSpinner",true);
        var action = component.get("c.GetProvisioningReqDetails");
        action.setParams({
            'ProvReqId': component.get("v.recordId")
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner",false);
            if (state === "SUCCESS") {
                $A.get('e.force:closeQuickAction').fire();
                var Data = response.getReturnValue();
                if(Data.Organization_Domain__c == "") {
                    alert("Please specify Domain Name");
                }
                else if(Data.Org_ID_with_cloud__c != "" && Data.Provisioning_Status__c == "Provisioned Eval") {
                    alert("This Organization has been setup in the SHIFT Cloud.");
                }
                    else if(Data.Send_Initial_l__c == "") {
                        alert("Please specify who is going to receive the login credential.");
                    }
                        else if(Data.Send_Initial_l__c == "SE" && Data.SE__c == "") {
                            alert("Please specify the SE user");
                        }
                            else if(Data.Send_Initial_l__c == "Partner" && Data.Partner_Contact__c == "") {
                                alert("The request must have a partner contact");
                            }
                                else if(Data.Send_Initial_l__c == "Customer" && Data.Primary_Eval_Contact__c == "") {
                                    alert("The request must have a Customer Contact");
                                }
                                    else if(Data.RecordType.Name != "Zscaler Shift") {
                                        alert("This functionality is available only for the SHIFT Cloud.");
                                    }
                                        else {
                                            window.open('/apex/ProvisioningSHIFTPOCRequest?id='+Data.Id,'_Parent');
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