public class UpdateLastMeetingDateBatch implements  Database.Batchable<SObject>,Schedulable, Database.Stateful{
    
    ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateLastMeetingDateBatch');
    public Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        list<String> typeDetail =new list<String>();
        typeDetail.add(System.Label.Post_Sale_CISO_Security_Policy_Review);
        typeDetail.add(System.Label.VO_CISO_Security_Risk_Assessment);
        typeDetail.add(System.Label.VO_Product_Directions_Meeting);
        return Database.getQueryLocator([select id,accountId,type,EndDateTime,CreatedBy.TimeZoneSidKey from event where EndDateTime <= today and type!=null and accountId!=null and type in : typeDetail  and peopleai__MeetingStatus__c = 'Completed' order by EndDateTime asc]);
    }
    public void execute(Database.BatchableContext BC,List<Event> eventList){
        this.zb.callExecute(eventList[0]?.Id, eventList.size());
        list<id> CISOList = new list<id>();
        list<id> zscalerPMList = new list<id>();
        Map<Id,DateTime> mapDateValues = new Map<Id,DateTime>();
        Map<Id,DateTime> mapDateValues1 = new Map<Id,DateTime>();
        Map<Id,String> mapUserTimeZone = new Map<Id,String>();
        Map<Id,String> mapUserTimeZone1 = new Map<Id,String>();
        for(event singleEvent : eventList){
            if(singleEvent.type == System.Label.Post_Sale_CISO_Security_Policy_Review || singleEvent.type == System.Label.VO_CISO_Security_Risk_Assessment){
                CISOList.add(singleEvent.accountId);
                if(!mapDateValues.containsKey(singleEvent.accountId))  {
                    mapDateValues.put(singleEvent.accountId, singleEvent.EndDateTime);
                    mapUserTimeZone.put(singleEvent.accountId, singleEvent.CreatedBy.TimeZoneSidKey);
                }
            }
            else{
                zscalerPMList.add(singleEvent.AccountId);
                if(!mapDateValues1.containsKey(singleEvent.accountId))  {
                    mapDateValues1.put(singleEvent.accountId, singleEvent.EndDateTime);
                    mapUserTimeZone1.put(singleEvent.accountId, singleEvent.CreatedBy.TimeZoneSidKey);
                }
            }
            
        }
        list<id> accountIdList = new list<id>();
        accountIdList.addAll(CISOList);
        accountIdList.addAll(zscalerPMList);
        list<Account_Extension__c> accountExtensionList1 =  [select id,account__c,Last_Meeting_with_CISO__c,Last_Meeting_with_Zscaler_PM__c from Account_Extension__c where account__c in : accountIdList];
        for(Account_Extension__c actExt : accountExtensionList1) {
            if(CISOList.contains(actExt.account__c)){
                DateTime dT = mapDateValues.get(actExt.account__c);
                String dtPST = dt.format('yyyy-MM-dd HH:mm:ss', mapUserTimeZone.get(actExt.account__c));
                actExt.Last_Meeting_with_CISO__c = Date.valueOf(dtPST);
            }
            
            if(zscalerPMList.contains(actExt.account__c)){
                DateTime dT = mapDateValues1.get(actExt.account__c);
                String dtPST = dt.format('yyyy-MM-dd HH:mm:ss', mapUserTimeZone1.get(actExt.account__c));
                actExt.Last_Meeting_with_Zscaler_PM__c = Date.valueOf(dtPST);
            }
        }
        //bypassing AccountExtension trigger 
        TriggerUtility.setAccountExtension();
        TriggerUtility2.updateAccExtRelatedAccExecuted();
        TriggerUtility.AccountOwnerChangeAlertExecuted();
        //adding custom setting to bypass account extension trigger
        Skip_Triggers_User_Based__c bypassTriggerForAccountExtension = new Skip_Triggers_User_Based__c(
 		SetupOwnerId = UserInfo.getUserId(),
   		Object_s_to_skip__c = 'Account_Extension__c',
    	Skip_all_triggers__c = true
		);
		insert bypassTriggerForAccountExtension;
        update accountExtensionList1;   
        delete bypassTriggerForAccountExtension;
    }
    public void finish(Database.BatchableContext BC){
        this.zb.callFinish(BC);
    }
    public void execute(SchedulableContext sc)
    {
        UpdateLastMeetingDateBatch updateLastMetting= new UpdateLastMeetingDateBatch();
        Database.executeBatch(updateLastMetting);
        
    }
    
}