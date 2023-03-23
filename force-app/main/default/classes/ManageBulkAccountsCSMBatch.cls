/*****************************************************************************************
Name: ManageBulkAccountsCSMBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch Class for handling bulk Accounts CSM field Updates 
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR                   DATE            DETAIL              
1.0                Adarsh Pidaparthy        17/05/2022      CR#4826    CSM Name and CSM Name 2 - Account Team Updates
2.0                Harish Gowda N           23/12/2022      Added Changes for Batch Monitoring Frame Work.
******************************************************************************************/ 

public class ManageBulkAccountsCSMBatch implements Database.Batchable<SObject>,Database.Stateful {
    
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('ManageBulkAccountsCSMBatch');
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        this.zscalerBatchFrameWorkObj.callStart();
        String query = 'select id,name,CSM_Name_New__c,CSM_Name_New__r.profile.Name,CSM_Name_2__c,CSM_Name_2__r.Profile.Name,CS_Business_Alignment__c,CS_Business_Alignment__r.profile.Name,Load_CSM_Or_TAM_To_Account_Team__c, lastModifiedDate  from Account where Load_CSM_Or_TAM_To_Account_Team__c = true';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Account> bulkUpdateAccountsList) {
        this.zscalerBatchFrameWorkObj.callExecute(bulkUpdateAccountsList[0]?.Id, bulkUpdateAccountsList.size());
        Set<Id>accountIds = new Set<Id>();
        List<AccountTeamMember>atmToInsertList = new List<AccountTeamMember>();
        List<Account>accListToUpdate = new List<Account>();
        Manage_Account_CSM_TAM__mdt mapping = Manage_Account_CSM_TAM__mdt.getInstance('Customer_Success_Manager');
        for(Account eachAcc: bulkUpdateAccountsList){
            accountIds.add(eachAcc.Id);
        }
        List<AccountTeamMember> atmList = [select id,accountId,TeamMemberRole,UserId from AccountTeamMember Where accountId in:accountIds and TeamMemberRole = 'Customer Success Manager'];
        if(atmList!=null && !atmList.isEmpty() && atmList.size()>0){
            try{
                delete atmList; 
                if(test.isRunningTest()){
                    throw new ManageAccountException('Exception from test');
                }
            }           
            
            Catch(Exception ex){
                ZscalerErrorLogsUtility.insertLogsForAsync('ManageBulkAccountsCSMBatch', 'execute',
                                                           'Apex', UserInfo.getUserId(),
                                                           'Sales Cloud', ex.getStackTraceString(), 
                                                           'Manage Bulk Accounts CSM Batch process - Delete Account Team Members failed' + ex.getMessage(), ex.getTypeName());
            }
        }
        for(Account eachAccount:bulkUpdateAccountsList){
            
            if(eachAccount.CSM_Name_New__c!=null && eachAccount.CSM_Name_New__r.Profile.Name == 'Core Sales - CSM'){
                
                AccountTeamMember atm1 = new AccountTeamMember();
                atm1.AccountId = eachAccount.Id;
                atm1.userId = eachAccount.CSM_Name_New__c;
                atm1.TeamMemberRole = mapping.Field__c;
                atm1.AccountAccessLevel = mapping.Account_Access__c;
                atm1.OpportunityAccessLevel = mapping.Opportunity_Access__c;
                atm1.CaseAccessLevel = mapping.Case_Access__c;
                atm1.ContactAccessLevel = mapping.Contact_Access__c;
                atmToInsertList.add(atm1);
            }
            if(eachAccount.CSM_Name_2__c!=null && eachAccount.CSM_Name_2__r.Profile.Name == 'Core Sales - CSM'){
                
                AccountTeamMember atm2 = new AccountTeamMember();
                atm2.AccountId = eachAccount.Id;
                atm2.userId = eachAccount.CSM_Name_2__c;
                atm2.TeamMemberRole = mapping.Field__c;
                atm2.AccountAccessLevel = mapping.Account_Access__c;
                atm2.OpportunityAccessLevel = mapping.Opportunity_Access__c;
                atm2.CaseAccessLevel = mapping.Case_Access__c;
                atm2.ContactAccessLevel = mapping.Contact_Access__c;
                atmToInsertList.add(atm2);
            }
            if(eachAccount.CS_Business_Alignment__c!=null && eachAccount.CS_Business_Alignment__r.Profile.Name == 'Core Sales - CSM'){
                
                AccountTeamMember atm3 = new AccountTeamMember();
                atm3.AccountId = eachAccount.Id;
                atm3.userId = eachAccount.CS_Business_Alignment__c;
                atm3.TeamMemberRole = mapping.Field__c;
                atm3.AccountAccessLevel = mapping.Account_Access__c;
                atm3.OpportunityAccessLevel = mapping.Opportunity_Access__c;
                atm3.CaseAccessLevel = 'Edit';
                atm3.ContactAccessLevel = mapping.Contact_Access__c;
                atmToInsertList.add(atm3);
            }
            eachAccount.Load_CSM_Or_TAM_To_Account_Team__c = false;
            accListToUpdate.add(eachAccount);
        }
        if(atmToInsertList!=null && !atmToInsertList.isEmpty() && atmToInsertList.size()>0){
            try {
                insert atmToInsertList;
                if(test.isRunningTest()){
                    throw new ManageAccountException('Exception from test');
                } 
            }catch(Exception ex) {
                
                ZscalerErrorLogsUtility.insertLogsForAsync('ManageBulkAccountsCSMBatch', 'execute',
                                                           'Apex', UserInfo.getUserId(),
                                                           'Sales Cloud', ex.getStackTraceString(), 
                                                           'Manage Bulk Accounts CSM Batch process - Insert Account Team Members Process failed' + ex.getMessage(), ex.getTypeName());
            }    
        }
        if(accListToUpdate!=null && !accListToUpdate.isEmpty() && accListToUpdate.size()>0){
            try {
                TriggerHandler.bypass('AccountTriggerHandler'); 
                update accListToUpdate;
                if(test.isRunningTest()){
                    throw new ManageAccountException('Exception from test');
                }
            }catch(Exception ex) {
                
                ZscalerErrorLogsUtility.insertLogsForAsync('ManageBulkAccountsCSMBatch', 'execute',
                                                           'Apex', UserInfo.getUserId(),
                                                           'Sales Cloud', ex.getStackTraceString(), 
                                                           'Manage Bulk Accounts CSM Batch process - Update Account Records failed' + ex.getMessage(), ex.getTypeName());
            }
            
        }
    }
    
    public void finish(Database.BatchableContext context) {
        this.zscalerBatchFrameWorkObj.callFinish(context);
    }
}