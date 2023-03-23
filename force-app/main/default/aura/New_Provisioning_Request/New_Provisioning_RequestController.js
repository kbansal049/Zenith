({
    doInit : function(component, event, helper) {
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        console.log(context.attributes.recordId);
        component.set("v.parentId", context.attributes.recordId);
        component.set("v.loadOppData", true);
    },
    createPR: function(component, event, helper) {
        console.log('inside PR creation');
        let rec = component.get("v.record");
        let stage1 = $A.get("$Label.c.Stage_1_Alignment")
        if(rec.fields.StageName.value == stage1){
            if (confirm("Only FeVa Provisioning Request can be submitted now. Inline POC and Zscaler Shift Provisioning Requests can be submitted only from Stage 2 onwards.\nDo you want to continue?")) {
                var createAcountContactEvent = $A.get("e.force:createRecord");
                createAcountContactEvent.setParams({
                    "entityApiName": "Provisioning_Request__c",
                    "recordTypeId": "012700000001j7J",
                    "defaultFieldValues": {
                        'Opportunity__c' : rec.fields.Id.value,
                        'Account__c' : rec.fields.AccountId.value,
                        'SE__c' : rec.fields.SE_Name__c.value,
                        'Organization_Domain__c' : rec.fields.Account_Org_Domain__c.value,
                    }
                });
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.parentId"),
                "slideDevName": "detail"
                });
                createAcountContactEvent.fire();
               // navEvt.fire();
                
            }
            
        }else{
            var createAcountContactEvent = $A.get("e.force:createRecord");
            createAcountContactEvent.setParams({
                "entityApiName": "Provisioning_Request__c",
                "defaultFieldValues": {
                    'Opportunity__c' : rec.fields.Id.value,
                    'Account__c' : rec.fields.AccountId.value,
                    'SE__c' : rec.fields.SE_Name__c.value,
                    'Organization_Domain__c' : rec.fields.Account_Org_Domain__c.value,
                }
            });
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.parentId"),
                "slideDevName": "detail"
            });
            createAcountContactEvent.fire();
            //navEvt.fire();
        }
    },
})