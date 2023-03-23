@IsTest
private class ProjectAccountCSMGeneratorTest {
    @testSetup  static void setupdata(){
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        List<Triggers_Switch__c> trlst = new List<Triggers_Switch__c>();
        Triggers_Switch__c tr1 = new Triggers_Switch__c(name = 'Execute_Project_Trigger', Execute__c = true);
        Triggers_Switch__c tr2 = new Triggers_Switch__c(name = 'Execute_SendEmail_Project_Trigger', Execute__c = true);
        Triggers_Switch__c tr3 = new Triggers_Switch__c(name = 'Execute_Fill_Summary_Notes_Dates', Execute__c = true);//Added by Varun - CR 1069
        trlst.add(tr1);
        trlst.add(tr2);
        trlst.add(tr3);//Added by Varun - CR 1069
        insert trlst;
        
    }
    
	@IsTest
    static void testHandleAccountCSMGeneration() {
        User testuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = 'title',Alias = 'alias',
                                 TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
                                 LastName = 'last',Email = 'test@zscaler.in',Username = 'test@zscaler.in',CompanyName = 'TEST');
        insert testuser ;
        
        System.runAs(testuser) {
            Account a = new Account(Name='TEST-Z');
            a.CSM_Name_New__c = testuser.Id;
            insert a;
            Contact c = new Contact(LastName='TEST-Z',Email='test@zscaler.in',AccountId=a.id);
            insert c;
            Id RecordTypeIdProject = Schema.SObjectType.Inspire1__Project__c.getRecordTypeInfosByName().get('Deployment Project').getRecordTypeId();
            Inspire1__Project__c IP = new Inspire1__Project__c();
            IP.name = 'Test project 1';
            IP.inspire1__Account__c=a.ID;
            IP.RecordTypeId = RecordTypeIdProject;
            IP.inspire1__Project_Status__c='In Progress';
            IP.Primary_Customer_Contact__c = c.ID;
            IP.Secondary_Customer_Contact__c = c.id;
            IP.inspire1__Timezone__c ='(GMT-07:00) Pacific Daylight Time (America/Los_Angeles)';
            
            
            insert IP;
        }
        
    }
}