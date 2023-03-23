public class MonthalyCloudUsageTriggerHandler {

    public void MainEntry(System.TriggerOperation triggerEvent, Boolean IsExecuting, List<SObject> newlist, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap){
        
        List<BWC_Data__c> lstNew = (List<BWC_Data__c>)newlist;
        List<BWC_Data__c> lstOld = (List<BWC_Data__c>)oldList;
        Map<ID, BWC_Data__c> mapNew = (Map<ID,BWC_Data__c>)newMap;
        Map<ID, BWC_Data__c> mapOld = (Map<ID,BWC_Data__c>)oldMap;
        
        // Add entries to the dispatcher static variable if they need to be updated or do direct DML
        
        System.debug('MonthalyCloudUsageTriggerHandler MainEntry. triggerEvent: ' + triggerEvent);
        
        switch on triggerEvent {
			 when BEFORE_INSERT {
                //Added by Varun for CR754
                System.debug('MonthalyCloudUsageTriggerHandler ---- > BEFORE_INSERT');
                updateRecordType(lstNew);
            }           
            when BEFORE_UPDATE {
                //Added by Varun for CR754
                System.debug('MonthalyCloudUsageTriggerHandler ---- > BEFOR_UPDATE');
                updateRecordType(lstNew);
            }
            when AFTER_INSERT {
                System.debug('MonthalyCloudUsageTriggerHandler ---- > AFTER_INSERT');
                callZPAActiveUserRollUP(lstNew);
            }
            when AFTER_UPDATE {
                System.debug('MonthalyCloudUsageTriggerHandler ---- > AFTER_UPDATE');
                callZPAActiveUserRollUP(lstNew);
            }
            when AFTER_DELETE {
                System.debug('MonthalyCloudUsageTriggerHandler ---- > AFTER_DELETE');
                callZPAActiveUserRollUP(lstOld);
            }
            when else {
                System.debug('Not expecting Trigger Event: ' + triggerEvent);
            }
        }
    }
	
    //Added by Varun for CR754 - Start
	 private void updateRecordType(List<BWC_Data__c> monUsageList){
        ID ziaRecordType = Schema.SObjectType.BWC_Data__c.getRecordTypeInfosByName().get('ZIA') != null ?  Schema.SObjectType.BWC_Data__c.getRecordTypeInfosByName().get('ZIA').getRecordTypeId() : null;
        ID zpaRecordType = Schema.SObjectType.BWC_Data__c.getRecordTypeInfosByName().get('ZPA') != null ?  Schema.SObjectType.BWC_Data__c.getRecordTypeInfosByName().get('ZPA').getRecordTypeId() : null;
        
        for(BWC_Data__c usageRecord :  monUsageList){
            if (usageRecord.Type__c=='ZIA'){
                if(ziaRecordType != null){
                    usageRecord.RecordTypeId = ziaRecordType;
                }
            }else if(usageRecord.Type__c=='ZPA'){
                if(zpaRecordType != null){
                	usageRecord.RecordTypeId = zpaRecordType;    
                }
            }else{
                if(ziaRecordType != null){
                    usageRecord.RecordTypeId = ziaRecordType;
                }
            }
        }
        
    }
    //Added by Varun for CR754 - End
	
    private void callZPAActiveUserRollUP( List<BWC_Data__c> monUsageList){
        List<ID> cloudIDSet = new List<ID>();
        for(BWC_Data__c msg :  monUsageList){
            if(msg.Type__c == 'ZPA' && msg.Cloud_ID__c != null && msg.is_Current_Month__c == true){
                cloudIDSet.add(msg.Cloud_ID__c);
            }
        }
        if(cloudIDSet.size()>0){
            rollUPZPACloudMonthlyUsageRecords(cloudIDSet);
        }
    }
    
    
    private void rollUPZPACloudMonthlyUsageRecords(List<ID> cloudIDSet){
        System.debug('---rollUPCloudMonthlyUsageRecords---');
        System.debug('-cloudIDSet-'+cloudIDSet);
        if(cloudIDSet != null && cloudIDSet.size()>0){
            List<Zscaler_Cloud_ID__c> cloudIdToUpdate = new List<Zscaler_Cloud_ID__c>();
            for(Zscaler_Cloud_ID__c zc : [Select ID,Name,Cloud_Type__c,
                                          (Select ID,ZPA_L31d__c,ZPA_L90d__c from BWC_Data__r where Type__c = 'ZPA' and is_Current_Month__c = true)
                                          from Zscaler_Cloud_ID__c where id in :cloudIDSet and Cloud_Type__c = 'ZPA'])
            {
                Zscaler_Cloud_ID__c zci = new Zscaler_Cloud_ID__c();
                zci.id= zc.id;
                if(zc.BWC_Data__r != null){
                    Double sum31D = 0;
                    Double sum90D = 0;
                    for(BWC_Data__c bd : zc.BWC_Data__r){
                        sum31D+= (bd.ZPA_L31d__c != null ? bd.ZPA_L31d__c : 0);
                        sum90D+= (bd.ZPA_L90d__c != null ? bd.ZPA_L90d__c : 0);
                    }
                    zci.ZPA_Active_Users_L31D_RollUp__c = sum31D;
                    zci.ZPA_Active_Users_L90D_RollUp__c = sum90D;
                }else{
                 	zci.ZPA_Active_Users_L31D_RollUp__c = 0;
                    zci.ZPA_Active_Users_L90D_RollUp__c = 0;
                }
                cloudIdToUpdate.add(zci);
            }
            if(cloudIdToUpdate.size()>0){
                database.SaveResult[] srList =  Database.update(cloudIdToUpdate, false);
                for(database.SaveResult sr: srList){
                    if(!sr.isSuccess()){
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }
    }
    
}