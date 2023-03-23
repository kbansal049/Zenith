@isTest
public class OpportunityContactRoleTriggerHelperTest {
    
    @isTest static void testMethod1() {
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test1';
        con1.LastName = 'Test1';
        con1.AccountId = account.Id;
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Test2';
        con2.Renewal_Notification_Recipient__c = true;
        con2.AccountId = account.Id;
        
        insert new List<Contact> { con1, con2 };
            Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        
        opportunity opp = new opportunity(RecordtypeId = meRecordTypeId, Name = 'Test opportunity', AccountId = account.Id, StageName = '1 - Discovery & Qualification',
                                          SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',
                                          AD_Forecast_Category_Lock__c=true,
                                          Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), 
                                          contract_end_date_new__c = date.today().adddays(65)
                                         );
        insert opp;
        //Added by swathi : CR 1416 start
        opportunity opp1 = new opportunity(Name = 'Test opportunity', AccountId = account.Id, StageName = '1 - Discovery & Qualification',
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test');
        insert opp1;
        //Added by swathi : CR 1416 end
        OpportunityContactRole ocr = new OpportunityContactRole(
            ContactId = con1.Id,
            OpportunityId = opp.Id,
            Role = 'Service Owner'
        );
        OpportunityContactRole ocr1 = new OpportunityContactRole(
            ContactId = con2.Id,
            OpportunityId = opp1.Id,
            Role = 'Economic Buyer',
            IsPrimary = True //Added by swathi
        );
        OpportunityContactRole ocr2 = new OpportunityContactRole(
            ContactId = con2.Id,
            OpportunityId = opp.Id,
            Role = 'Champion (Business)'
        );
        OpportunityContactRole ocr3 = new OpportunityContactRole(
            ContactId = con2.Id,
            OpportunityId = opp.Id,
            Role = 'Deployment Contact'
        );
        insert new List<OpportunityContactRole> { ocr, ocr1,ocr2,ocr3 };
          
        ocr1.Role = 'Service Owner';
        update ocr1;
       }
}