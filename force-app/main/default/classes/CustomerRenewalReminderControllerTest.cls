/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* CustomerRenewalReminderControllerTest
* @description    Test class for OpportunitySplitOwnerEmailService 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-09-13
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
private with sharing class CustomerRenewalReminderControllerTest {
    @IsTest static void testProcess(){
        
        Account acc = new Account(Name = 'Test Account',Type='Prospect');
        acc.Domain__c = 'zscaler.in';
        INSERT acc;
        
        Contact con = new Contact();
        con.LastName = 'Test contact lastname';
        con.AccountId = acc.Id;
        con.Contacts_that_matter__c = TRUE;
        con.Email = 'testContact@zscaler.com.invalid';
        
        INSERT con;
        
                
        List<Opportunity> oppToInsertList = new List<Opportunity> ();
        List<Opportunity> oppToUpdateList = new List<Opportunity> ();
        
        
        Opportunity opp = new opportunity(Name = 'Test opportunity1', AccountId = acc.Id, StageName = '1 - Discovery & Qualification', CloseDate = system.Today()+30);
        opp.LDR_Name__c = UserInfo.getUserId();
        opp.Customer_Contact__c = con.Id;
        oppToInsertList.add(opp);
        
        opp = new opportunity(Name = 'Test opportunity2', AccountId = acc.Id, StageName = '1 - Discovery & Qualification', CloseDate = system.Today()+30);
        opp.LDR_Name__c = UserInfo.getUserId();
        opp.Customer_Contact__c = con.Id;
        oppToInsertList.get(0).Reason_for_5C__c = 'Test';
        oppToInsertList.get(0).StageName = System.Label.Stage_5C_Opportunity;
        
        oppToInsertList.add(opp);
        
        INSERT oppToInsertList;
        
        
        
        oppToInsertList.get(0).StageName = System.Label.Stage_5C_Opportunity;
        oppToInsertList.get(0).Reason_for_5C__c = 'Test updated';
        
        
        oppToInsertList.get(1).Reason_for_5C__c = 'Test1';
        oppToInsertList.get(1).StageName = System.Label.Stage_5C_Opportunity;
        
        //oppToUpdateList.add(opp);
        
        
        
        UPDATE oppToInsertList;
        
        
    }
}