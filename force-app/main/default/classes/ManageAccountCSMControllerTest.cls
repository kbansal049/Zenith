/*****************************************************************************************
Name: ManageAccountCSMControllerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test Class for ManageAccountCSMController Apex Class
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR                   DATE            DETAIL              
1.0                Adarsh Pidaparthy        17/05/2022      CR#4826    CSM Name and CSM Name 2 - Account Team Updates Test Classes
******************************************************************************************/ 
@isTest
public class ManageAccountCSMControllerTest {
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of CR# 4826: Test Class for ManageAccountCSMController Apex Class.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : manageAccountTeamMembersTest .
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/   
    static testMethod void manageAccountTeamMembersTest() {
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Core Sales - CSM' LIMIT 1];
        List<User>usersList = new List<User>();
        User user1 = new User(LastName = 'User1',FirstName='Test',Alias = 'tUAcc', Email = 'test.test@test.com',Username = 'test.testAccount@test.com', ProfileId = profileId.id,TimeZoneSidKey = 'GMT',LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',LocaleSidKey = 'en_US');
        usersList.add(user1);
        User user2 = new User(LastName = 'User2',FirstName='Test',Alias = 'tUAcc2', Email = 'test.test@test2.com',Username = 'test.testAccount2@test.com', ProfileId = profileId.id,TimeZoneSidKey = 'GMT',LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',LocaleSidKey = 'en_US');
        usersList.add(user2);
        User user3 = new User(LastName = 'User3',FirstName='Test',Alias = 'tUAcc3', Email = 'test.test@test3.com',Username = 'test.testAccount3@test.com', ProfileId = profileId.id,TimeZoneSidKey = 'GMT',LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',LocaleSidKey = 'en_US');
        usersList.add(user3);
        insert usersList;
        
        Account eachAcc = new Account(Name = 'Test Account',TAM_Email__c = 'test@test.com',Type= 'Customer',NumberOfEmployees = 5,Load_CSM_Or_TAM_To_Account_Team__c = true);
        TriggerHandler.bypass('AccountTriggerHandler'); 
        insert eachAcc;
        
        AccountTeamMember eachAtm = new AccountTeamMember(userId = userinfo.getUserId(), AccountId = eachAcc.id,TeamMemberRole = 'Customer Success Manager');
        insert eachAtm;
        
        List<Account>accList = new List<Account>();
        Account eachAccount = new Account(Id = eachAcc.Id,CSM_Name_New__c = user1.id,CSM_Name_2__c = user2.id,CS_Business_Alignment__c = user3.id);
        acclist.add(eachAccount);
        String result1 = ManageAccountCSMController.manageAccountTeamMembers(acclist);
        
        List<Account>accList2 = new List<Account>();
        Account eachAccount2 = new Account(Id = eachAcc.Id,CSM_Name_New__c = user2.id,CSM_Name_2__c = user3.id,CS_Business_Alignment__c = user1.id);
        acclist2.add(eachAccount2);
        String result2 = ManageAccountCSMController.manageAccountTeamMembers(acclist2);
        
        Account eachAccount3 = new Account(CSM_Name_New__c = user2.id,CSM_Name_2__c = user3.id,CS_Business_Alignment__c = user1.id);
        acclist2.add(eachAccount3);
        
        try{
            String result3 = ManageAccountCSMController.manageAccountTeamMembers(acclist2);
        }
        catch(DMLException e) {
            system.debug('getMessage'+e.getMessage());
            system.assert(e.getMessage().contains('Id'));
        }
        Database.executeBatch(new ManageBulkAccountsCSMBatch(),5);
        
        Test.startTest();
        
        try{
            Account eachAccount4 = new Account(CSM_Name_New__c = user2.id,CSM_Name_2__c = user3.id,CS_Business_Alignment__c = user1.id,Load_CSM_Or_TAM_To_Account_Team__c = true);
            insert eachAccount4;
            AccountTeamMember eachAtm2 = new AccountTeamMember(userId = userinfo.getUserId(), AccountId = eachAccount4.id,TeamMemberRole = 'Test');
            insert eachAtm2;
            Database.executeBatch(new ManageBulkAccountsCSMBatch(),5);
        }
        catch(DMLException e) {
            system.debug('getMessage'+e.getMessage());
            system.assert(e.getMessage().contains('Name'));
        }
        Test.StopTest();
        
    }
}