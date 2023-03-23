@isTest
private class OppContactRolesTriggerTest {
    
    static testmethod void testprocess(){
         Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30,
            Qualification_Notes__c = 'Text notes',Qualified_Date__c = system.today()+20,LDR_Name__c = Userinfo.getUserId());
        insert opp;
        
        Contact con = new Contact(AccountId = acc.Id,FirstNAme = 'Test',LastName = 'Contact',Qualification_Notes__c = 'Text Notes',Qualified_Date__c = system.today()+20,Qualifying_SDR__c =Userinfo.getUserId());
        insert con;
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = opp.Id,ContactId =con.Id,IsPrimary=true);
        insert ocr;
    }
    
}