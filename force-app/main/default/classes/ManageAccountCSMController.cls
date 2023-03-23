/*****************************************************************************************
Name: ManageAccountCSMController
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex Controller for Manage CSM and Account Team Members Process.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR                   DATE            DETAIL              
1.0                Adarsh Pidaparthy        17/05/2022      CR#4826    CSM Name and CSM Name 2 - Account Team Updates
******************************************************************************************/ 

public without sharing class ManageAccountCSMController {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# 4826 : to manage Account Team Members when CSM fields are updated on Account
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : manageAccountTeamMembers .
* @param    NAME : string accountId .
* @return   TYPE : 
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    @AuraEnabled
    public static String manageAccountTeamMembers(List<Account>accList) {   
        
        Set<Id>accountIds = new Set<Id>();
        Map<Id, Map<Id,AccountTeamMember>> accountIdTeamMemberMap = new Map<Id,Map<Id,AccountTeamMember>>();
        List<AccountTeamMember>atmToInsertList = new List<AccountTeamMember>();
        List<AccountTeamMember>atmToDeleteList = new List<AccountTeamMember>();
        Manage_Account_CSM_TAM__mdt mapping = Manage_Account_CSM_TAM__mdt.getInstance('Customer_Success_Manager');
        Set<Id>csmNameIds = new Set<Id>();
        Set<Id>csmName2Ids = new Set<Id>();
        Set<Id>csBusinessAlignmentIds = new Set<Id>();
        for(Account eachAccount:accList){
            accountIds.add(eachAccount.Id);
            csmNameIds.add(eachAccount.CSM_Name_New__c);
            csmName2Ids.add(eachAccount.CSM_Name_2__c);
            csBusinessAlignmentIds.add(eachAccount.CS_Business_Alignment__c);
        }
        
        Map<Id,User> userIdMap = new Map<Id,User>([select id,name,Profile.name from User where id in :csmNameIds or id in :csmName2Ids or id in:csBusinessAlignmentIds]);
        List<Account>existingAccounts = [select id,name,CSM_Name_New__c,CSM_Name_New__r.profile.Name,CSM_Name_2__c,CSM_Name_2__r.Profile.Name,CS_Business_Alignment__c,CS_Business_Alignment__r.profile.Name from Account where Id in :accountIds];
        List<AccountTeamMember> atmList = [select id,accountId,TeamMemberRole,UserId from AccountTeamMember Where accountId in:accountIds];
        for(AccountTeamMember atm : atmList)
        {
            if(accountIdTeamMemberMap.containsKey(atm.accountId))
            {
                accountIdTeamMemberMap.get(atm.accountId).put(atm.UserId,atm);
            }
            else
            {
                accountIdTeamMemberMap.put(atm.accountId, new Map<Id,AccountTeamMember>{atm.UserId=>atm});
            }
        }
        for(Account eachAcc:existingAccounts){
            if(csmNameIds!=null && !csmNameIds.contains(eachAcc.CSM_Name_New__c) && eachAcc.CSM_Name_New__c!=null && eachAcc.CSM_Name_New__r.Profile.Name == 'Core Sales - CSM' && accountIdTeamMemberMap.containsKey(eachAcc.id) && accountIdTeamMemberMap.get(eachAcc.id).containskey(eachAcc.CSM_Name_New__c)){
                atmToDeleteList.add(accountIdTeamMemberMap.get(eachAcc.id).get(eachAcc.CSM_Name_New__c));
            }
            if(csmName2Ids!=null && !csmName2Ids.contains(eachAcc.CSM_Name_2__c) && eachAcc.CSM_Name_2__c!=null && eachAcc.CSM_Name_2__r.Profile.Name == 'Core Sales - CSM' && accountIdTeamMemberMap.containsKey(eachAcc.id) && accountIdTeamMemberMap.get(eachAcc.id).containskey(eachAcc.CSM_Name_2__c)){
                atmToDeleteList.add(accountIdTeamMemberMap.get(eachAcc.id).get(eachAcc.CSM_Name_2__c));
            }
            if(csBusinessAlignmentIds!=null && !csBusinessAlignmentIds.contains(eachAcc.CS_Business_Alignment__c) && eachAcc.CS_Business_Alignment__c!=null && eachAcc.CS_Business_Alignment__r.Profile.Name == 'Core Sales - CSM' && accountIdTeamMemberMap.containsKey(eachAcc.id) && accountIdTeamMemberMap.get(eachAcc.id).containskey(eachAcc.CS_Business_Alignment__c)){
                atmToDeleteList.add(accountIdTeamMemberMap.get(eachAcc.id).get(eachAcc.CS_Business_Alignment__c));
            }
        }
        for(Account eachAcc : accList){
            if(eachAcc.CSM_Name_New__c!=null && UserIdMap.containskey(eachAcc.CSM_Name_New__c) && UserIdMap.get(eachAcc.CSM_Name_New__c).Profile.Name == 'Core Sales - CSM'  && (!accountIdTeamMemberMap.containsKey(eachAcc.id) || (accountIdTeamMemberMap.containsKey(eachAcc.id) && !accountIdTeamMemberMap.get(eachAcc.id).containskey(eachAcc.CSM_Name_New__c)))){
                AccountTeamMember atm1 = new AccountTeamMember();
                atm1.AccountId = eachAcc.Id;
                atm1.userId = eachAcc.CSM_Name_New__c;
                atm1.TeamMemberRole = mapping.Field__c;
                atm1.AccountAccessLevel = mapping.Account_Access__c;
                atm1.OpportunityAccessLevel = mapping.Opportunity_Access__c;
                atm1.CaseAccessLevel = mapping.Case_Access__c;
                atm1.ContactAccessLevel = mapping.Contact_Access__c;
                atmToInsertList.add(atm1);
            }
            if(eachAcc.CSM_Name_2__c!=null && UserIdMap.containskey(eachAcc.CSM_Name_2__c) && UserIdMap.get(eachAcc.CSM_Name_2__c).Profile.Name == 'Core Sales - CSM' && (!accountIdTeamMemberMap.containsKey(eachAcc.id) || (accountIdTeamMemberMap.containsKey(eachAcc.id) && !accountIdTeamMemberMap.get(eachAcc.id).containskey(eachAcc.CSM_Name_2__c)))){  
                AccountTeamMember atm2 = new AccountTeamMember();
                atm2.AccountId = eachAcc.Id;
                atm2.userId = eachAcc.CSM_Name_2__c;
                atm2.TeamMemberRole = mapping.Field__c;
                atm2.AccountAccessLevel = mapping.Account_Access__c;
                atm2.OpportunityAccessLevel = mapping.Opportunity_Access__c;
                atm2.CaseAccessLevel = mapping.Case_Access__c;
                atm2.ContactAccessLevel = mapping.Contact_Access__c;
                atmToInsertList.add(atm2);
            }
            if(eachAcc.CS_Business_Alignment__c!=null && UserIdMap.containskey(eachAcc.CS_Business_Alignment__c) && UserIdMap.get(eachAcc.CS_Business_Alignment__c).Profile.Name == 'Core Sales - CSM' && (!accountIdTeamMemberMap.containsKey(eachAcc.id) || (accountIdTeamMemberMap.containsKey(eachAcc.id) && !accountIdTeamMemberMap.get(eachAcc.id).containskey(eachAcc.CS_Business_Alignment__c)))){  
                AccountTeamMember atm3 = new AccountTeamMember();
                atm3.AccountId = eachAcc.Id;
                atm3.userId = eachAcc.CS_Business_Alignment__c;
                atm3.TeamMemberRole = mapping.Field__c;
                atm3.AccountAccessLevel = mapping.Account_Access__c;
                atm3.OpportunityAccessLevel = mapping.Opportunity_Access__c;
                atm3.CaseAccessLevel = 'Edit';
                atm3.ContactAccessLevel = mapping.Contact_Access__c;
                atmToInsertList.add(atm3);
            }
        }
        
        if(accList!=null && !accList.isEmpty() && accList.size()>0){
            
            try{
                TriggerHandler.bypass('AccountTriggerHandler'); 
                update accList;
            }
            catch(Exception ex) {
                ZscalerErrorLogsUtility.insertLogsForAsync('ManageAccountCSMController', 'manageAccountTeamMembers',
                                                           'Apex', UserInfo.getUserId(),
                                                           'Sales Cloud', ex.getStackTraceString(), 
                                                           'Manage Account CSM process failed' + ex.getMessage(), ex.getTypeName());
                return 'Failure';
            }
        } 
        
        if(atmToDeleteList!=null && !atmToDeleteList.isEmpty() && atmToDeleteList.size()>0){
            
            try{
                delete atmToDeleteList;
                if(test.isRunningTest()){
                    throw new ManageAccountException('Exception from test');
                }
            }
            catch(Exception ex) {
                ZscalerErrorLogsUtility.insertLogsForAsync('ManageAccountCSMController', 'manageAccountTeamMembers',
                                                           'Apex', UserInfo.getUserId(),
                                                           'Sales Cloud', ex.getStackTraceString(), 
                                                           'Manage Account CSM process failed' + ex.getMessage(), ex.getTypeName());
                return 'Failure';                                           
            }
        }
        
        if(atmToInsertList!=null && !atmToInsertList.isEmpty() && atmToInsertList.size()>0){
            try {
                insert atmToInsertList;
                if(test.isRunningTest()){
                    throw new ManageAccountException('Exception from test');
                }
            }catch(Exception ex) {
                ZscalerErrorLogsUtility.insertLogsForAsync('ManageAccountCSMController', 'manageAccountTeamMembers',
                                                           'Apex', UserInfo.getUserId(),
                                                           'Sales Cloud', ex.getStackTraceString(), 
                                                           'Manage Account Team Members process failed' + ex.getMessage(), ex.getTypeName());
                return 'Failure';
            }
            
        }
        return 'Success';  
    }
    
}