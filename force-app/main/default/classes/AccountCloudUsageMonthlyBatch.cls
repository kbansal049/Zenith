global class AccountCloudUsageMonthlyBatch implements Database.Batchable<sObject>, Database.Stateful {
        ZscalerBatchFramework zb = new ZscalerBatchFramework('AccountCloudUsageMonthlyBatch');

    @TestVisible
    private Set<Id> recIds;
    
    global AccountCloudUsageMonthlyBatch(Set<Id> ids){
         recIds = ids ;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
		List<String> desiredTypes = System.Label.AccountCloudUsageMonthlyBatch_DesiredType.Split(','); //Added as a part of IBA-5789
        return Database.getQueryLocator(
            //Modified Query CR# 3848
            'SELECT Id, Authenticated_Users_Deployed__c,Authenticated_Users_L31D__c,(SELECT Id, SIPA_Traffic_Volume_GB__c FROM Account_Extensions__r) FROM Account ' + (recIds.isEmpty() ? ' WHERE Type IN :desiredTypes' : ' WHERE ID IN:recIds and Type IN :desiredTypes')
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        Map<Id,List< Zscaler_Cloud_ID__c >> accZsciListMap = getLatestAuthUserCount(scope); 
       
        //Modified Query CR# 3325 Start
        List<Account_Extension__c> accExtList = new List<Account_Extension__c> ();
        Account_Extension__c accExt;
        
        for(Account acc : scope){
            accExt = new Account_Extension__c();
            
            Decimal cnt = 0.00;
            Decimal count = 0.00;
            Decimal cnt31DUsers = 0.00;
            Boolean valueChangedfor31D = false;
            for(Zscaler_Cloud_ID__c zci : (!accZsciListMap.isEMpty() && accZsciListMap.containsKey(acc.Id)) ? accZsciListMap.get(acc.Id) : new List<Zscaler_Cloud_ID__c>()){  
                If(zci.Cloud_Type__c =='ZIA'){
                  for(BWC_Data__c bwc : zci.BWC_Data__r.isEMpty() ? new List<BWC_Data__c>() : zci.BWC_Data__r){
						if(bwc.is_Current_Month__c){
							cnt = cnt + (bwc.X90_Day_Trailing_Unique_Auth_Users__c!=NULL ? bwc.X90_Day_Trailing_Unique_Auth_Users__c : 0.00);
						}
                        if(bwc.is_Previous_Month__c && bwc.X31_Day_Trailing_Unique_Auth_Users__c!=null ){
							cnt31DUsers = cnt31DUsers + bwc.X31_Day_Trailing_Unique_Auth_Users__c;   //CR# 3848
 							valueChangedfor31D=true;
						}
                        }
                }
                for(BWC_Data__c bwc : zci.BWC_Data__r.isEMpty() ? new List<BWC_Data__c>() : zci.BWC_Data__r){
                    count = count + (bwc.SIPA_Traffic_Volume_GB__c != NULL ? bwc.SIPA_Traffic_Volume_GB__c : 0.00);
                }
            }
            acc.Authenticated_Users_Deployed__c = cnt ;
            if(valueChangedfor31D){
                acc.Authenticated_Users_L31D__c = cnt31DUsers;
            }
            
            if (!acc.Account_Extensions__r.isEmpty()) {
                accExt = acc.Account_Extensions__r.get(0);
                accExt.SIPA_Traffic_Volume_GB__c = count;
                accExtList.add(accExt);
            }
        }
        
        try{ 
            TriggerHandler.bypass('AccountTriggerHandler');
            Database.update(scope,false);
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }
        catch(Exception e){
            ZscalerErrorLogsUtility.insertlogsForAsync('AccountCloudUsageMonthlyBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
        
        if (!accExtList.isEmpty()) {
            TriggerUtility.setAccountExtension();
            TriggerUtility2.updateAccExtRelatedAccExecuted();
            TriggerUtility.AccountOwnerChangeAlertExecuted();
            //updated by Akash 1: CR# 5023 start
            try{
                //adding custom setting to bypass account extension trigger
                Skip_Triggers_User_Based__c bypassTriggerForAccountExtension = new Skip_Triggers_User_Based__c(
 				SetupOwnerId = UserInfo.getUserId(),
   				Object_s_to_skip__c = 'Account_Extension__c',
    			Skip_all_triggers__c = true
				);
				insert bypassTriggerForAccountExtension;      
                Database.update(accExtList, false);  
                delete  bypassTriggerForAccountExtension;
                   
            }
            catch(Exception e){
                ZscalerErrorLogsUtility.insertlogsForAsync('AccountCloudUsageMonthlyBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
            }
            //updated by Akash 1: CR# 5023 end    
        }
        //Modified Query CR# 3325 End
    }    

    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        
    } 
    
    @TestVisible
    private static Map<Id,List< Zscaler_Cloud_ID__c >> getLatestAuthUserCount(List<Account> accs){
        Map<Id,List< Zscaler_Cloud_ID__c >> accLatestAuthUserCntMap = new Map<Id,List< Zscaler_Cloud_ID__c >>();
        
        for(Zscaler_Cloud_ID__c zsci : [SELECT id,Account__c,Cloud_Type__c,(SELECT id, X90_Day_Trailing_Unique_Auth_Users__c,Cloud_ID__c,
                                        SIPA_Traffic_Volume_GB__c,X31_Day_Trailing_Unique_Auth_Users__c,is_Current_Month__c,is_Previous_Month__c FROM BWC_Data__r order by Monthly_Usage__c desc LIMIT 2)
                                        FROM Zscaler_Cloud_ID__c 
                                        WHERE Account__c IN : accs                                        
                                        ]){
            if(!accLatestAuthUserCntMap.containsKey(zsci.Account__c))
                accLatestAuthUserCntMap.put(zsci.Account__c,new List<Zscaler_Cloud_ID__c>());
                
            List<Zscaler_Cloud_ID__c> cloudIds = accLatestAuthUserCntMap.get(zsci.Account__c);
            cloudIds.add(zsci);
			
				accLatestAuthUserCntMap.put(zsci.Account__c,cloudIds);
			                              
        }
        
        return accLatestAuthUserCntMap;
        
            
    }
    
    
}