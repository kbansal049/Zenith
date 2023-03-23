@isTest
public class test_updatecontactrolecount
{
    @testSetup static void setUpData()
    {
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Type = 'Prospect';
        insert acct;

        Contact[] cont = new Contact[]
        {
            new Contact(LastName = 'testcontact1', AccountId= acct.Id, email='adafs@ewrw.com',Project_Role__c='Other',LeadSource='Advertisement'),
            new Contact(LastName = 'testcontact2',AccountId= acct.Id, email='adafs45@ewrw.com',Project_Role__c='Other',LeadSource='Advertisement')
        };    
        insert cont; 

        Opportunity Oppty = new Opportunity(Name='Oppty_test1',AccountId= acct.Id, Amount = 5000,StageName= Label.Stage_1_Alignment,Type ='New Business', ForecastCategoryName = 'Pipeline', CloseDate=System.Today());
        insert Oppty;
    }

    @isTest static void testcreateopptywithconditionandrole()
    {
        Opportunity Oppty = [select Id,StageName from Opportunity limit 1];
        List<Contact> cont = [select Id from Contact];
        OpportunityContactRole [] ocr = new OpportunityContactRole[]
        {
            new OpportunityContactRole(Role ='Business User',OpportunityId=Oppty.id ,Contactid = cont[0].id ,Isprimary = False),
            new OpportunityContactRole(Role ='Business User',OpportunityId=Oppty.id ,Contactid = cont[0].id ,Isprimary = True)
        };

        insert ocr;    
        Oppty.StageName = label.Stage_2_Qualified_Budgeted;    
         
        Test.StartTest();
            update Oppty;
        Test.StopTest();
    
        Oppty =[SELECT Number_of_Contacts_Roles_Assigned__c,Primary_Contact_Assigned__c FROM Opportunity WHERE Id = :Oppty.Id];
             
    } 
    
    @isTest static void testOppContactRole()
    {
        Opportunity Oppty = [select Id,StageName from Opportunity limit 1];
        List<Contact> cont = [select Id from Contact];
        OpportunityContactRole [] ocr = new OpportunityContactRole[]
        {
            new OpportunityContactRole(Role ='Service Owner',OpportunityId=Oppty.id ,Contactid = cont[0].id ,Isprimary = False),
            new OpportunityContactRole(Role ='Economic Buyer',OpportunityId=Oppty.id ,Contactid = cont[0].id ,Isprimary = True),
            new OpportunityContactRole(Role ='Business User',OpportunityId=Oppty.id ,Contactid = cont[0].id ,Isprimary = True)
        };

        insert ocr; 
        
        OpportunityContactRole [] ocr1 = new OpportunityContactRole[]
        {
            new OpportunityContactRole(Role ='Service Owner',OpportunityId=Oppty.id ,Contactid = cont[1].id ,Isprimary = False),
            new OpportunityContactRole(Role ='Economic Buyer',OpportunityId=Oppty.id ,Contactid = cont[1].id ,Isprimary = True),
            new OpportunityContactRole(Role ='Business User',OpportunityId=Oppty.id ,Contactid = cont[1].id ,Isprimary = True)
        };
        insert ocr1;     
        update ocr;
        
    }
}