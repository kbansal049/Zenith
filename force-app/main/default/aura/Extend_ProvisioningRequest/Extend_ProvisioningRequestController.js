({
    doInit : function(component, event, helper) {
        var ProvReqId = component.get("v.recordId");
        component.set("v.showSpinner",true);
        var action = component.get("c.allowPRExtensionOrNot");
        action.setParams({
            'ProvReqId': component.get("v.recordId")
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner",false);
            if (state === "SUCCESS") {
                //$A.get('e.force:closeQuickAction').fire();
                var Data = response.getReturnValue();
                console.log('Data : ' + JSON.stringify(Data));
                if(Data.allowPRExt){
                    if((Data.prRecord.Provisioning_Status__c == 'Provisioned' && 
                        Data.prRecord.Provisioning_Extension_Status__c != 'PR Extension Requested')|| 
                       (Data.prRecord.Provisioning_Status__c=='Request Decommission' && 
                        (Data.prRecord.Decomm_Req_date__c=='' || Data.prRecord.Decomm_Req_date__c==null) ) ){
                        window.open('/apex/ProvisionExtensionPage?id=' + Data.prRecord.Id,'_Parent');
                    }
                    else{
                        alert('You Can Extend the PR only if the PR Status is Provisioned and Provisioning Extension Status is PR Extension Rejected or Extended');
                        $A.get('e.force:closeQuickAction').fire();
                    } 
                }else {
                    component.set("v.isModalOpen", true);
                    var errorString = 'This action cannot be completed as ' + 
                        Data.nonCompliantAccountType +
                        ' \"' + 
                          Data.nonCompliantAccountName + 
                          '\" failed for compliance screening. Contact dplscreening@zscaler.com for more information.';
                    component.set("v.errorMessage", errorString);
                    //alert(errorString);
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
    },
    
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        //component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        $A.get('e.force:closeQuickAction').fire();
    },
})