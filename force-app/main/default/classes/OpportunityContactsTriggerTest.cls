@isTest
public class OpportunityContactsTriggerTest {
	
    Static testMethod void createTest(){
        test.startTest();
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        List<Contact> conlist = new List<Contact>();
        Contact con1 = new Contact();
        con1.FirstName = 'Test1';
        con1.LastName = 'Test1';
        con1.AccountId = account.Id;
        conlist.add(con1);
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Test2';
       	con2.AccountId = account.Id;
        conlist.add(con2);
        //insert new List<Contact> { con1, con2  };
        
        Contact con3 = new Contact();
        con3.FirstName = 'Test3';
        con3.LastName = 'Test3';
        con3.AccountId = account.Id;
        conlist.add(con3);
        
        Contact con4 = new Contact();
        con4.FirstName = 'Test4';
        con4.LastName = 'Test4';
       	con4.AccountId = account.Id;
        con4.Involved_in_Active_Oppty__c = false;
        conlist.add(con4);
        
       // Contact con3 = new Contact(Lastname = 'dem0',Involved_in_Active_Oppty__c = false);
       
        
        insert conlist;
        List<Opportunity> opplist = new List<Opportunity>();
        Opportunity o = new Opportunity();
		
		o.Name = 'New Record';
		o.StageName = Label.Stage_2_Qualified_Budgeted;
		o.CloseDate = Date.today()+30;
        o.Type = 'New Business';
		o.Description = 'Test Record';
		//insert o;
        opplist.add(o);
        
        Opportunity o1 = new Opportunity();
		
		o1.Name = 'New1 Record';
		o1.StageName = '6 - Closed Won';
        o.Sub_Stage__c ='Opportunity - Closed/Won';
		o1.CloseDate = Date.today();
        o1.Type = 'New Business';
		o1.Description = 'Testing';
		//insert o1;
		opplist.add(o1);
        insert opplist;
        
        List<OpportunityContactRole> opproleList = new List<OpportunityContactRole>();
         OpportunityContactRole ocr = new OpportunityContactRole(
            ContactId = con1.Id,
            OpportunityId = o.Id,
            Role = 'Service Owner'
        );
        opproleList.add(ocr);
        OpportunityContactRole ocr1 = new OpportunityContactRole(
            ContactId = con2.Id,
            OpportunityId = o.Id,
            Role = 'Economic Buyer'
         );    
            opproleList.add(ocr1);
        //insert new List<OpportunityContactRole> { ocr, ocr1};
            
             OpportunityContactRole ocr2 = new OpportunityContactRole(
            ContactId = con3.Id,
            OpportunityId = o1.Id,
            Role = 'Service Owner'
        );
        opproleList.add(ocr2);
        OpportunityContactRole ocr3 = new OpportunityContactRole(
            ContactId = con4.Id,
            OpportunityId = o1.Id,
            Role = 'Economic Buyer'
         );    
            opproleList.add(ocr3);
        //insert new List<OpportunityContactRole> { ocr, ocr1,ocr2, ocr3};
        insert opproleList;
            
        
        TriggerUtility.startOpportunityUpdatesContactHandler();
	Triggers_Switch__c ts = new Triggers_Switch__c(name='OpportunityUpdatesContactHandler', Execute__c = true);
	insert ts;
	Triggers_Switch__c ts1 = new Triggers_Switch__c(name='Execute_Opp_Trigger', Execute__c = true);
	insert ts1;
        o1.StageName = Label.Stage_4_Economic_Buyer_Signoff;
        update o1;
        o.StageName = '6 - Closed Won';
        o.Sub_Stage__c ='Opportunity - Closed/Won';
        //update o;
        test.stopTest();
     
      
    }
}