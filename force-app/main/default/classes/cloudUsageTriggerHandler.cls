public class cloudUsageTriggerHandler {
	public void MainEntry(System.TriggerOperation triggerEvent, Boolean IsExecuting, List<SObject> newlist, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap){
        
        List<Cloud_Usage__c> lstNew = (List<Cloud_Usage__c>)newlist;
        List<Cloud_Usage__c> lstOld = (List<Cloud_Usage__c>)oldList;
                
        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('CloudUsageTriggerHandler ---- > AFTER_INSERT');
                callZPAActiveUserRollUP(lstNew);
            }
            when AFTER_UPDATE {
                System.debug('CloudUsageTriggerHandler ---- > AFTER_UPDATE');
                callZPAActiveUserRollUP(lstNew);
            }
            when AFTER_DELETE {
                System.debug('CloudUsageTriggerHandler ---- > AFTER_DELETE');
                callZPAActiveUserRollUP(lstOld);
            }
            when else {
                System.debug('Not expecting Trigger Event: ' + triggerEvent);
            }
        }
    }
	
    private void callZPAActiveUserRollUP( List<Cloud_Usage__c> UsageList){
        List<ID> cloudIDSet = new List<ID>();
        for(Cloud_Usage__c msg :  UsageList){
            if(msg.Cloud_Usage_Type__c == 'ZPA' && msg.Zscaler_Cloud_ID__c != null ){
                cloudIDSet.add(msg.Zscaler_Cloud_ID__c);
            }
        }
        if(cloudIDSet.size()>0){
            rollUPZPACloudUsageRecords(cloudIDSet);
        }
    }
    
    
    private void rollUPZPACloudUsageRecords(List<ID> cloudIDSet){
        if(cloudIDSet != null && cloudIDSet.size()>0){
            List<Zscaler_Cloud_ID__c> cloudIdToUpdate = new List<Zscaler_Cloud_ID__c>();
            for(Zscaler_Cloud_ID__c zc : [Select ID,Name,Cloud_Type__c,
                                          (Select ID,ZPA_last_14_days__c from Cloud_Usage_Object__r where Cloud_Usage_Type__c = 'ZPA' and Usage_Pull_Date__c = LAST_N_DAYS:14)
                                          from Zscaler_Cloud_ID__c where id in :cloudIDSet and Cloud_Type__c = 'ZPA'])   
            {
                Zscaler_Cloud_ID__c zci = new Zscaler_Cloud_ID__c();
                zci.id= zc.id;
                if(zc.Cloud_Usage_Object__r != null){
                    Double sum14D = 0;
                    for(Cloud_Usage__c bd : zc.Cloud_Usage_Object__r){
                        sum14D+= (bd.ZPA_last_14_days__c != null ? bd.ZPA_last_14_days__c : 0);
                    }
                    zci.ZPA_Active_Users_L14D__c = sum14D;              
                }else{
                 	zci.ZPA_Active_Users_L14D__c = 0;
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
                        }
                    }
                }
            }
        }
    }
}