@isTest
private class OpportunityDataActivitybatchTest {  
    
    @TestSetup
    private static void createTestData(){
        
        Profile coreSalesProfile= [Select Id from profile where Name='Core Sales']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User coreSalesUser=new User(firstname = 'Core Sales', 
                                    lastName = 'User', 
                                    email = uniqueName + '@test' + orgId + '.org', 
                                    Username = uniqueName + '@test' + orgId + '.org', 
                                    EmailEncodingKey = 'ISO-8859-1', 
                                    Alias = uniqueName.substring(18, 23), 
                                    TimeZoneSidKey = 'America/Los_Angeles', 
                                    LocaleSidKey = 'en_US', 
                                    LanguageLocaleKey = 'en_US', 
                                    ProfileId = coreSalesProfile.Id
                                   ); 
        
        
        insert coreSalesUser;

        PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'AMERICAS';
        salestert.Theater__c = 'Americas';
        salestert.Region__c = 'AMERICAS';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        salestert.Sales_Territory_Year__c = 'Current';
        insert salestert;
        
        Patch__c patch  = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = salestert.Id ;
        patch.PatchName__c = 'Test Patch';
        insert patch;
        
    Account acc = new Account();
        acc.Name='testacc';
        acc.Type ='Prospect';
        acc.Sales_Territory__c = salestert.Id;
        acc.Patch__c = patch.Id;
        insert acc;

    opportunity opp = new opportunity(Name = 'Test opportunity', 
                                          AccountId = acc.Id, 
                                          StageName = '1 - Discovery & Qualification',
                                          NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, 
                                          Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '6 - Technical Win', 
                                          Validation_Plan__c = 'Test');
        insert opp; 
        system.debug('opp '+opp);
    }
    
    @isTest
    private static void updateOpp1(){
        /* Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Name = 'Test opportunity'];
        opp.StageName = '3 - Sponsorship';
        update opp;
        
        opp.StageName = '4 - Impact Validation';
        update opp;
        Test.startTest();
        opp.StageName = '5 - Procurement';
        update opp;
        Test.stopTest(); */
        
        OpportunityDataActivitybatch btch= new OpportunityDataActivitybatch();
        database.executebatch(btch,5);
    }
   
}