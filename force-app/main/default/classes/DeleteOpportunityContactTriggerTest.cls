@isTest
public class DeleteOpportunityContactTriggerTest {
    
    static testmethod void deleteTest(){
        
        Triggers_Switch__c tp = new Triggers_Switch__c();
        tp.name = 'OpportunityCreatorRoleHandler';
        tp.Execute__c = true;

        insert tp;
        
        Triggers_Switch__c tp1 = new Triggers_Switch__c();
        tp1.name = 'OpportunityUpdatesContactHandler';
        tp1.Execute__c = true;
        insert tp1;
        
        Test.startTest();    
        Account a = new Account();
		a.Name = 'Test Co.';
		insert a;
        
        Contact c = new Contact();
		c.FirstName = 'test';
		c.LastName  = 'Test';
		c.AccountId = a.id;
    	insert c;
        
        Opportunity o = new Opportunity();
		o.Name = 'New Record';
		o.StageName = Label.Stage_3_Value_Impact_Validation;
		o.CloseDate = Date.today();
        o.Type = 'New Business';
		o.Description = 'Test1';
		insert o;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.ContactId = c.Id;
		ocr.OpportunityId = o.Id;
		insert ocr;
        
        
        o.StageName = '6 - Closed Won';
        update o;
        try {
            delete ocr;
            
            o.StageName = '6 - Closed Won';
        	update o;
        
        c.Contact_Lead_Status__c = 'Recycled to Marketing';
        c.Involved_in_Active_Oppty__c= false;
        update c;
            
        }catch(Exception e){
            e.getMessage();
        }
        Test.stopTest();  
        
        TriggerUtility.booster();
        
    }

}