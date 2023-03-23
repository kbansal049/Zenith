/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* LockRenewalOpportunityHandlerTest
* @description    Test class for LockRenewalOpportunityHandler
*                 Part of CR# 3553
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-11-30
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

@IsTest
private class LockRenewalOpportunityHandlerTest {

    @IsTest
    static void testOwnerUpdate() {
    
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Core Sales - Renewals' LIMIT 1];
        
        List<User> userList = new List<User> ();
        User usr = new User(FirstName='Test', Lastname='Dummy', ForecastLevel__c = 'Level 23',
                            ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com', Email = 'dummytestdummy@zscaler.com', 
                            Alias = 'dumt', CommunityNickname = 'dumt',TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US' );
        
        userList.add(usr);
        
        usr = new User(FirstName='Test1', Lastname='Dummy1', ForecastLevel__c = 'Level 22',
                       ProfileId = p.Id, Username = 'dummytestdummy@zscaler.com1', Email = 'dummytestdummy@zscaler.com1', 
                       Alias = 'dumt1', CommunityNickname = 'dumt1',TimeZoneSidKey = 'GMT',
                       LanguageLocaleKey = 'en_US',
                       EmailEncodingKey = 'UTF-8',
                       LocaleSidKey = 'en_US' );
        userList.add(usr);
        INSERT userList;
        
        System.Test.startTest();
        
        List<Opportunity> oppToInsertList = new List<Opportunity> ();
                
        
        Account acc = new Account(Name = 'Test Account',Type='Prospect');
        acc.Domain__c = 'zscaler.in';
        acc.BillingCity = 'NYC';
        acc.BillingState = 'NYC';
        acc.BillingStreet = 'Test';
        acc.BillingCountry = 'USA';
        INSERT acc;
        
        Contact con = new Contact();
        con.LastName = 'Test contact lastname';
        con.AccountId = acc.Id;
        con.Contacts_that_matter__c = TRUE;
        con.Email = 'testContact@zscaler.com.invalid';
        
        INSERT con;
        
        TriggerUtility.realignPatchReset();
        
        Opportunity opp = new Opportunity(Name = 'Test opportunity1', AccountId = acc.Id, StageName = '1 - Discovery & Qualification', CloseDate = system.Today()+30);
        opp.OwnerId = userList.get(0).Id;
        opp.Customer_Contact__c = con.Id;
        opp.Type = 'Existing Customer (Renewal)';
        opp.NextStep = '06/04/18: Looking to get budget approval in June. SS to chase Morfit';
        oppToInsertList.add(opp);
        
        opp = new Opportunity(Name = 'Test opportunity1', AccountId = acc.Id, StageName = '1 - Discovery & Qualification', CloseDate = system.Today()+30);
        opp.OwnerId = userList.get(0).Id;
        opp.Customer_Contact__c = con.Id;
        opp.Type = 'New Business';
        opp.Deal_Path__c = 'Bridge to BC';
        oppToInsertList.add(opp);
        
        
        INSERT oppToInsertList;
        
        oppToInsertList.get(0).OwnerId = userList.get(1).Id;
        oppToInsertList.get(0).StageName = System.Label.Stage_5C_Opportunity;
        oppToInsertList.get(0).Reason_for_5C__c = 'Test updated';
        opp.NextStep = '06/04/18: Looking to get budget approval in June. SS to chase Morfit Updated';
        opp.Deal_Path__c = 'Bridge';
                    
        UPDATE oppToInsertList;
        
        TriggerUtility.realignPatch();
        
        System.Test.stopTest();
        
        oppToInsertList.get(1).StageName = System.Label.Stage_7_Closed_Lost;
        oppToInsertList.get(1).Sub_Stage__c = label.SubStage_Closed_With_No_Decision;
        UPDATE oppToInsertList;
        
        
    }
}