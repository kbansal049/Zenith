@isTest
private class OpportunityTriggerHandlerTest {
    @TestSetup
    private static void createTestData(){
        Profile coreSalesProfile= [Select Id from profile where Name='Core Sales']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName=orgId+dateString + Integer.valueOf(Math.rint(Math.random()*1000000));
        
        User coreSalesUser=new User(firstname = 'Core Sales', 
                                    lastName = 'User', 
                                    email = uniqueName + '@test' + orgId + '.org', 
                                    Username = uniqueName + '@test' + orgId + '.org', 
                                    EmailEncodingKey = 'ISO-8859-1', 
                                    Alias = uniqueName.substring(18, 23), 
                                    TimeZoneSidKey = 'America/Los_Angeles', 
                                    LocaleSidKey = 'en_US', 
                                    LanguageLocaleKey = 'en_US', 
                                    ProfileId = coreSalesProfile.Id);
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

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Domain__c ='Test';
        quote.SBQQ__Primary__c = true;
        quote.Total_ZPA_ACV__c = 50000;
        insert quote;
        
		opportunity opp = new opportunity(Name = 'Test opportunity', 
                                          AccountId = acc.Id, 
                                          StageName = '1 - Discovery & Qualification',
                                          NextStep = 'NextStep - Insert',
                                          Next_Steps__c = 'Technical Validation Next Steps Testing - Insert',
                                          CloseDate = system.Today()+30, 
                                          Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '6 - Technical Win', 
                                          Validation_Plan__c = 'Test',
                                          Deal_Path__c = 'Bridge to ML',
                                          SE_Name__c = UserInfo.getUserId(),
                                          Primary_Competitor__c = 'Cisco',
										  Secondary_Competitors__c = 'Cisco',
                                          SBQQ__PrimaryQuote__c = quote.Id);
        insert opp;        
    }
    
    @isTest
    private static void testOpptUpdate1(){
        Test.startTest();
            Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Name = 'Test opportunity'];
            opp.StageName = '3 - Sponsorship';
            opp.Next_Steps__c = 'Technical Validation Next Steps Testing - Update';
            opp.Deal_Path__c = 'Bridge to BC';
            opp.Number_Of_Upsell_Split_Lines__c = 5;
            opp.APTS_Primary_Proposal__c  = 'Testing';
            update opp;
        Test.stopTest();
    }
    
    @isTest
    private static void testOpptUpdate2(){
        Test.startTest();
            Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Name = 'Test opportunity'];
            opp.StageName = '4 - Impact Validation';
            update opp;
        Test.stopTest();
    }
    
    @isTest
    private static void testOpptUpdate3(){
        Test.startTest();
            Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Name = 'Test opportunity'];
        	opp.StageName = '2 - Architecture & Alignment';
        	update opp;
        Test.stopTest();
    }
    
    @isTest
    private static void testOpptUpdate4(){
        Test.startTest();
            Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Name = 'Test opportunity'];
            opp.StageName = '5 - Procurement';
            update opp;
        
        opp.stageName = Label.Stage_5A_Opportunity;
        update opp;
        Test.stopTest();
    }
    
    @isTest
    private static void testOpptUpdate5(){
        Test.startTest();
            Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Name = 'Test opportunity'];
            opp.StageName = System.Label.Stage_5C_Opportunity;
        	opp.Reason_for_5C__c = 'Test';
            opp.Type = 'Existing Customer (Renewal)';
            //update opp;
        Test.stopTest();
    }
    
    @isTest
    private static void testOpptUpdate6(){
        Test.startTest();
            Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Name = 'Test opportunity'];
            opp.StageName = '7 - Closed Lost';
            opp.Sub_Stage__c = 'Closed With No Decision';
            update opp;
        Test.stopTest();
    }
    
    @isTest
    private static void testOpptUpdate7(){
        Test.startTest();
            Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Name = 'Test opportunity'];
            opp.StageName = '6 - Closed Won';
            opp.NextStep = 'NextStep - Update';
            opp.Deal_Path__c = 'Bridge to BC';
            opp.Renewal_VP_In_my_Number__c = false;
            opp.RVP_In_my_Number__c = false;
            opp.SE_Znumber__c = '12345';
            //update opp;
        Test.stopTest();
    }
    
    @isTest
    private static void testOpptUpdate8(){
        Test.startTest();
            Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Name = 'Test opportunity'];
            opp.StageName = '7 - Closed Lost';
            opp.Sub_Stage__c = 'Closed Lost';
            update opp;
        Test.stopTest();
    }
    
    @isTest
    private static void testOpptUpdate9(){
        Test.startTest();
            Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Name = 'Test opportunity'];
            opp.StageName = '7 - Closed Lost';
        	opp.Sub_Stage__c = 'Closed With No Decision';
        	update opp;
        Test.stopTest();
    }
    
    @isTest
    private static void testOpptUpdate10(){
        Test.startTest();
            Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Name = 'Test opportunity'];
            opp.StageName = '7 - Closed Lost';
        	opp.Sub_Stage__c = 'Closed: Delete Duplicate';
        	update opp;
        Test.stopTest();
    }
    
    @isTest
    private static void testOpptDelete1(){        
        Test.startTest();
        	Opportunity opp = [SELECT Id,StageName FROM Opportunity WHERE Name = 'Test opportunity'];
        	delete opp;
            undelete opp;
        Test.stopTest();
    }
    
    @isTest
    private static void testOppAmberValidation1(){
        Test.startTest();
            User coreSalesUser= [SELECT Id FROM User WHERE firstname = 'Core Sales'];
            
            Account acc = new Account(Name='Prospect Test Account', Type='Prospect',BillingCity = 'San Jose',
                                      BillingCountry = 'United States',
                                      BillingPostalCode = '95134',
                                      BillingState = 'California',
                                      BillingStreet = '110 Rose Orchard Way',
                                      Fax = '',
                                      Phone = '+1 408.533.0288',
                                      Market_Segment__c='SMB',
                                      Amber_Road_Status__c = 'Potential Match');
            insert acc;
            
            Contact con = new Contact(Lastname = 'Test');
            insert con;
            
            String newBusinessRTId = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
            Opportunity opp = new Opportunity(Name = 'Test New Business Opportunity',
                                              AccountId=acc.Id,
                                              StageName='1 - Discovery & Qualification',
                                              RecordTypeId = newBusinessRTId,
                                              NextStep = 'Test 1',
                                          	  Next_Steps__c = 'Technical Validation Next Steps Testing - Insert',
                                              CloseDate = system.Today()+30,
                                              Primary_Quote_Exception__c = true, 
                                              Validation_Stage__c = '3 - Detailed validation in progress', 
                                              Validation_Plan__c = 'Test', 
                                              Is_Federal_Opportunity_Sync__c=false,
                                              AD_Forecast_Category__c='Pipeline',
                                              CRO_Forecast_Category__c='Pipeline',
                                              DM_Forecast_Category__c='Pipeline',
                                              Forecast_Category__c='Pipeline',
                                              VP_Forecast_Category__c='Pipeline',
                                              RVP_Forecast_Category__c='Pipeline',
                                              AD_Forecast_Category_Lock__c=true,
                                              CRO_Forecast_Category_Lock__c=true,
                                              DM_Forecast_Category_Lock__c=true,
                                              RVP_Forecast_Category_Lock__c=true,
                                              VP_Forecast_Category_Lock__c=true,
                                              contract_end_date_new__c = date.today().adddays(65),
                                              Architecture_Workshop_Complete__c='Yes',
                                              Primary_Partner_Program__c='Traditional',
                                              Amount=100000,
                                              Proposed_Number_of_Users__c=20000,
                                              Competitor__c='AppGate',
                                              Is_SE_Involved__c='Yes',
                                              Technical_Validation_Start_Date__c=system.today(),
                                              Validation_End_Date__c = system.today() + 30,
                                              Value_Pyramid__c='test',
                                              Business_Champion_Contact__c = con.Id,
                                              OwnerId = coreSalesUser.Id,
                                              SE_Name__c = UserInfo.getUserId(),
                                              SE_Znumber__c = '67890',
                                              Created_from_Lead__c = true,
                                              Opportunity_Account_Manager__c = UserInfo.getUserId());
            insert opp;
        
        
        Test.stopTest();
    }
}