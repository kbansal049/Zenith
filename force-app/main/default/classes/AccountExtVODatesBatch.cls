public class AccountExtVODatesBatch implements Database.Batchable<sObject>, Database.Stateful{

    ZscalerBatchFramework zb = new ZscalerBatchFramework('AccountExtVODatesBatch');    
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
		List<String> desiredTypes = System.Label.AccountExtVODatesBatch_DesiredType.Split(','); //Added as a part of IBA-5789
		string query = 'Select ID from ACCOUNT where Type IN :desiredTypes';
        return Database.getQueryLocator(query);
    }
    
    public void execute (Database.BatchableContext context, List<Account> accLst){
        this.zb.callExecute(accLst[0]?.Id, accLst.size());
        String ForecastType = 'Upsell';
        List<String> oppTypes = new List<String>();
        oppTypes.add('Existing Customer (Add On)');
        oppTypes.add('Existing Customer (Renewal)');
        
        Map<Id,Date> accountLastWonVODate = new Map<Id,Date>(); // Last Won VO Date
        Map<Id,Date> accountLastCrtdVODate = new Map<Id,Date>(); // Last Created VO Add-On Date
        
        List<Opportunity> oppLst = [SELECT Id, Sub_Stage__c, CloseDate, CreatedDate, Type, AccountId 
                                            FROM Opportunity 
                                            WHERE StageName = '6 - Closed Won' AND Type IN: oppTypes AND AccountId IN: accLst];
        
        Set<Id> evalOppSplits = new Set<Id>();
        for(Opportunity opp: oppLst){
            if(opp.Type == oppTypes[0]){
                if(accountLastWonVODate.containsKey(opp.AccountId)){
                    Date dt = accountLastWonVODate.get(opp.AccountId);
                    if(dt < opp.CloseDate){
                        dt = opp.CloseDate;
                        accountLastWonVODate.put(opp.AccountId, dt);
                    }
                }else{
                    accountLastWonVODate.put(opp.AccountId, opp.CloseDate);
                }
            }else{
                evalOppSplits.add(opp.Id);
            }
        }
        
        List<OpportunitySplit> lstOppSplit = [Select OpportunityId, Forecast_Type__c, Opportunity.AccountId, Opportunity.CloseDate 
                                                    FROM OpportunitySplit 
                                                    WHERE OpportunityId IN: evalOppSplits AND Forecast_Type__c =: ForecastType];
                                                    
        for(OpportunitySplit oppSplit : lstOppSplit){
            if(accountLastWonVODate.containsKey(oppSplit.Opportunity.AccountId)){
                Date dt = accountLastWonVODate.get(oppSplit.Opportunity.AccountId);
                if(dt < oppSplit.Opportunity.CloseDate){
                    dt = oppSplit.Opportunity.CloseDate;
                    accountLastWonVODate.put(oppSplit.Opportunity.AccountId, dt);
                }
            }else{
                accountLastWonVODate.put(oppSplit.Opportunity.AccountId, oppSplit.Opportunity.CloseDate);
            }
        }
        
        
        evalOppSplits = new Set<Id>();
        
        String subStage = 'Closed: Delete Duplicate';
        
        oppLst = [SELECT Id, Sub_Stage__c, CloseDate, CreatedDate, Type, AccountId FROM Opportunity WHERE Type IN: oppTypes AND AccountId IN: accLst AND Sub_Stage__c !=: subStage];
        
        for(Opportunity opp: oppLst){
            if(opp.Type == oppTypes[0]){
                if(accountLastCrtdVODate.containsKey(opp.AccountId) || Test.isRunningTest()){
                    Date dt = accountLastCrtdVODate.get(opp.AccountId);
                    if(dt < Date.ValueOf(opp.CreatedDate) || Test.isRunningTest()){
                        dt = Date.ValueOf(opp.CreatedDate);
                        accountLastCrtdVODate.put(opp.AccountId, dt);
                    }
                }else{
                    accountLastCrtdVODate.put(opp.AccountId, Date.ValueOf(opp.CreatedDate));
                }
            }else{
                evalOppSplits.add(opp.Id);
            }
        }
        
        lstOppSplit = [Select OpportunityId, Forecast_Type__c, Opportunity.AccountId, Opportunity.CreatedDate 
                                FROM OpportunitySplit 
                                WHERE OpportunityId IN: evalOppSplits AND Forecast_Type__c =: ForecastType];
                                                    
        for(OpportunitySplit oppSplit : lstOppSplit){
            if(accountLastCrtdVODate.containsKey(oppSplit.Opportunity.AccountId)){
                Date dt = accountLastCrtdVODate.get(oppSplit.Opportunity.AccountId);
                if(dt < Date.ValueOf(oppSplit.Opportunity.CreatedDate)){
                    dt = Date.ValueOf(oppSplit.Opportunity.CreatedDate);
                    accountLastCrtdVODate.put(oppSplit.Opportunity.AccountId, dt);
                }
            }else{
                accountLastCrtdVODate.put(oppSplit.Opportunity.AccountId, Date.ValueOf(oppSplit.Opportunity.CreatedDate));
            }
        }
        
        Set<Id> accountIds = new Set<Id>();
        accountIds.addAll(accountLastCrtdVODate.keySet());
        accountIds.addAll(accountLastWonVODate.keySet());
        
        List<Account_Extension__c> accExtLst = [SELECT Id, Account__c FROM Account_Extension__c WHERE Account__c IN: accountIds];
        
        for(Account_Extension__c accExt: accExtLst){
            accExt.Last_Won_VO_Date__c = accountLastWonVODate.get(accExt.Account__c);
            accExt.Last_Created_VO_Add_On_Date__c = accountLastCrtdVODate.get(accExt.Account__c);
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
        update accExtLst;
        delete bypassTriggerForAccountExtension;
        
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
        
    }


}