trigger RHX_Zscaler_Cloud_ID on Zscaler_Cloud_ID__c
(after delete, after insert, after undelete, after update, before delete, before insert) {
    if(!TriggerUtility2.iszscalerCloudIdTriggerExecuted()){
        //Added by Ayush Kangar as Part of CR# 3284 - Start
        if((trigger.isBefore && trigger.isInsert)){
            ZscalerCloudIdHelper.beforeInsert(trigger.new);
        }
        //Added by Ayush Kangar as Part of CR# 3284 - End
        
        //Changes done for Autocreation of Zscaler Cloud ID Contact:Gurjinder:Start
        if((trigger.isAfter && trigger.isInsert)){  
            AutocreateZscalerCloudIDContact.CreateZscalerCloudIDContacts(trigger.new);  
        }
        if(trigger.isbefore && trigger.isdelete){
            AutocreateZscalerCloudIDContact.DeleteZscalerCloudIDContacts(trigger.oldMap);
        }
        //Added by Swathi as part of CR#4587 Start
        if(trigger.isAfter && trigger.isUpdate){
            ZscalerCloudIdHelper.AfterUpdate(trigger.newMap,trigger.oldMap);
        }
        //Added by Swathi as part of CR#4587 End
    }
    //Changes done for Autocreation of Zscaler Cloud ID Contact:Gurjinder:End
}