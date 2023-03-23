/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* CustomerRenewalReminderBatch
* @description    This class is used to check for all the Opportunity Extension Records that have
* 				  Today as their Renewal_Notice_to_CTMs_10d__c, Renewal_Notice_to_CTMs_100d__c
				  Renewal_Notice_to_CTMs_270d__c. This data will be used by the CustomerRenewalReminderScheduler
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-07-14
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Harish Gowda N          11-Apr-2022       CR# 4058 - Bulk exclude from renewal notification on account.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class CustomerRenewalReminderBatch implements Database.Batchable<SObject>, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CustomerRenewalReminderBatch');
    public Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        String queryString = 'SELECT Id, Name, Opportunity__c,Opportunity__r.Number_of_Approved_Extension_Requests__c, Opportunity__r.Account.CSM_Name_New__c, Opportunity__r.Account.OwnerId, Opportunity__r.AccountId, Opportunity__r.Account.Channel_Manager__c, Opportunity__r.Account.CSM_Name_New__r.ManagerId, Opportunity__r.Account.Area_Director__c, Renewal_Notice_to_CTMs_10d__c, Renewal_Notice_to_CTMs_100d__c, Renewal_Notice_to_CTMs_270d__c, Opportunity__r.Account.Exclude_Account_from_RenewalNotification__c FROM Opportunity_Extension__c WHERE (Renewal_Notice_to_CTMs_10d__c != NULL OR Renewal_Notice_to_CTMs_100d__c != NULL OR Renewal_Notice_to_CTMs_270d__c != NULL ) AND Opportunity__r.StageName = \'4 - Impact Validation\'AND Opportunity__r.Account.Exclude_Account_from_RenewalNotification__c != true AND Opportunity__r.Type = \'Existing Customer (Renewal)\' AND Opportunity__r.Renewal_Rep_Forecast_Category__c != \'Omitted\'';
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity_Extension__c> oppExtList) {
		this.zb.callExecute(oppExtList[0]?.Id, oppExtList.size());
        CustomerRenewalReminderController instance = CustomerRenewalReminderController.getInstance();
        instance.setOppExtList(oppExtList);
        instance.handle();
    }
    
    public void finish(Database.BatchableContext BC){
        this.zb.callFinish(BC);
    }
}