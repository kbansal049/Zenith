/*
*  Author : Ayush Kangar
*/
@isTest
public class OpportunityPsOnboardingTest{
    @TestSetup
    private static void createTestData(){
        
        //CoreSales User
        List<User> userList = TestDatafactory_Zscaler.createUsers(2,false,'Core Sales',
                                                                  'ZS','CoreSales User',
                                                                  'zscoresalesuser@test.com');
        insert userList;
        
        PatchTeam__c territory =  new PatchTeam__c();
        territory.Theater__c = 'International';
        territory.Region__c = 'SEUR';
        territory.Area__c = 'EMEA';
        insert territory;
        
        List<PatchTeamMember__c> ptms = new List<PatchTeamMember__c>();
        
        PatchTeamMember__c ptm = new PatchTeamMember__c();
        ptm.PatchTeam__c = territory.Id;
        ptm.Role__c = 'Account Manager';
        ptm.User__c = userList[0].Id;
        ptms.add(ptm);
        
        PatchTeamMember__c ptm1 = new PatchTeamMember__c();
        ptm1.PatchTeam__c = territory.Id;
        ptm1.Role__c = 'Channel Manager';
        ptm1.User__c = userList[0].Id;
        ptms.add(ptm1);
        
        PatchTeamMember__c ptm2 = new PatchTeamMember__c();
        ptm2.PatchTeam__c = territory.Id;
        ptm2.Role__c = 'Area Director';
        ptm2.User__c = userList[0].Id;
        ptms.add(ptm2);
        
        insert ptms;
        
        Market_Segmentation_Setting__c ms = new Market_Segmentation_Setting__c();
        ms.Name = '1';
        ms.End_Range__c = 1000000;
        ms.Is_EMEA_Region__c = false;
        ms.Market_Segmentation__c = 'Commercial';
        ms.Start_Range__c = 1;
        
        insert ms;
        
        List<Account> accountList = TestDatafactory_Zscaler.createAccounts(3,false);
        for(Account acc : accountList){
            acc.Sales_Territory__c = territory.Id;
        }
        System.runAs(userList[0])
        {
            TriggerHandler.bypass('AccountTriggerHandler');
            insert accountList;
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }       
        
        //Contact        
        Contact con = new Contact();
        con.LastName = 'Contact last Name';
        con.accountId = accountList[0].Id;
        con.Partner_Deal_Reg_Account_Name__c= null;
        ContactTriggerHelper.skipTrigger = true;
        System.runAs(userList[0])
        {
            insert con;
        }   
        
        
        //Opportunity
        Date closeDate = system.today() + 5;       
        List<Opportunity> opportunityList = TestDatafactory_Zscaler.createOpportunities(3,false);
        for(Opportunity opp : opportunityList){
            opp.OwnerId = userList[0].Id;
            opp.accountId = accountList[0].Id;
            //opp.Primary_Reseller_Partner__c =  accountList[0].Id;
            opp.ForecastCategoryName = 'Commit';
            opp.Forecast_Category__c = 'Commit';
            opp.AD_Forecast_Category__c = 'Commit';
            opp.CRO_Forecast_Category__c = 'Commit';
            opp.DM_Forecast_Category__c = 'Commit';
            opp.VP_Forecast_Category__c = 'Commit';
            opp.RVP_Forecast_Category__c = 'Commit';
            opp.Validation_Plan__c = 'test';
            opp.Business_Champion_Contact__c = con.id;
            opp.Value_Pyramid__c = 'value pyramid';
            opp.X3_Why__c = '3 Whys Link';
            opp.Validation_Stage__c = '4 - Delivering validation findings report';
            opp.Technical_Validation_Start_Date__c = Date.today().addDays(30);
            opp.Validation_End_Date__c = Date.today().addDays(60);
            opp.Proposed_Number_of_Users__c = 600;
            opp.ZIA_Use_Case__c = 'Data Protection';
            opp.Primary_Competitor__c = 'Palo Alto Networks';
            opp.Secondary_Competitors__c = 'Palo Alto Networks';
        }
        
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert opportunityList;
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        
        List<Product2> productList=new List<Product2>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        Test.startTest();
        //Product2
        
        productList = (SB_TestCPQDataUtility.createProduct(6,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = '';
        productList[0].Pricing_Meter__c = '';
        productList[0].Enable_Ramp__c = true;
        productList[1].Enable_Ramp__c = true;
        productList[2].Enable_Ramp__c = true;
        productList[3].Enable_Ramp__c = true;
        productList[4].Name ='ZIA Transformation Edition';
        productList[4].ProductCode ='ZIA-Trans-Edition';
        productList[5].Name ='ZIA Transformation Edition';
        productList[5].ProductCode ='ZIA-TForm-Edition';
        insert productList;
        
        //SBQQ__Quote__c
        
        quote.Domain__c ='Test';
        quote.SBQQ__Primary__c = true;
        quote.Total_ZPA_ACV__c = 100;
        quote.SBQQ__Opportunity2__c = opportunityList[0].Id;
        insert quote;        
        
        
        SBQQ__QuoteLine__c q1 = new SBQQ__QuoteLine__c();
        Date qlDate = system.today() + (365*3);
        quoteLines = (SB_TestCPQDataUtility.createQuoteLine(4, quote.Id, productList[0].Id, system.today(), qlDate,50));
        quoteLines[1].SBQQ__Product__c = productList[1].Id;
        quoteLines[1].ACV_New__c = 10000; 
        quoteLines[2].SBQQ__Product__c = productList[2].Id;
        quoteLines[2].ACV_New__c = 15000;
        quoteLines[3].SBQQ__Product__c = productList[3].Id;
        quoteLines[3].ACV_New__c = 20000;
        insert quoteLines;
        Test.stopTest();
        
        //Update Opp with Primary Quote
        TriggerHandler.bypass('OpportunityTriggerHandler');
        opportunityList[0].SBQQ__PrimaryQuote__c = quote.Id;
        update opportunityList[0];
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        
        //Opportunity opp1 = TestDatafactory_Zscaler.insertOpportunity1('Test opportunity1', false, acc2.Id, Label.Stage_1_Alignment, closeDate , null, null, null, null,null, null, null, null, null, null, true);
        //opp1.OwnerId = userList[0].Id;
        
    }
    
    @isTest
    private static void testCreatePSOnboardingDoc()
    {
        Test.startTest();
        User coreSalesUser = [SELECT Id,Username,profile.Name 
                              FROM User 
                              WHERE Email ='zscoresalesuser@test.com'
                              LIMIT 1]; 
        Contact con = [SELECT Id, LastName 
                       FROM Contact
                       WHERE LastName = 'Contact last Name'];
        Opportunity opp = [SELECT Id,StageName,Product_Type__c,Proposed_Number_of_Users__c,
                           Economic_Buyer_Contact__c
                           FROM Opportunity 
                           WHERE Name = 'ZS Opportunity 0'
                           LIMIT 1];
        
        System.runAs(coreSalesUser)
        {
            opp.StageName =  Label.Stage_4_Economic_Buyer_Signoff;
            opp.Product_Type__c = 'Web';
            opp.Proposed_Number_of_Users__c = 600;
            opp.Economic_Buyer_Contact__c = con.id;
            opp.Primary_Competitor__c = 'Palo Alto Networks';
            opp.Secondary_Competitors__c = 'Palo Alto Networks';
            update opp;
        }    
        Test.stopTest();
        Id PsOnboardingRecordTypeId = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(Label.PS_Onboarding).getRecordTypeId();
        List<PS_Questionnaire__c> PSrecordList = [select Id,Opportunity__c FROM PS_Questionnaire__c WHERE opportunity__c =: opp.Id AND RecordTypeId =:PsOnboardingRecordTypeId];
        system.assertEquals(opp.Id,PSrecordList[0].opportunity__c,'PS Questionnaire should be attached to Opportunity');
        system.assertEquals(1,PSrecordList.size(),'One PS Questionnaire should be attached to Opportunity');
    }
    
    @isTest
    private static void testUpdatePSOnboardingDoc(){
        Test.startTest();
        User coreSalesUser = [SELECT Id,Username,profile.Name 
                              FROM User 
                              WHERE Email ='zscoresalesuser@test.com'
                              LIMIT 1]; 
        Opportunity opp = [SELECT Id,StageName,Product_Type__c,Proposed_Number_of_Users__c,
                           Economic_Buyer_Contact__c
                           FROM Opportunity 
                           WHERE Name = 'ZS Opportunity 2'
                           LIMIT 1];
        Id PsOnboardingRecordTypeId = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(Label.PS_Onboarding).getRecordTypeId();  
        Account acc = [SELECT Id FROM Account WHERE Name = 'ZS Account 1'];
        PS_Questionnaire__c psq = TestDatafactory_Zscaler.insertPSQuestionnaireforPSOnboarding(acc.Id,opp.Id);  
        System.runAs(coreSalesUser)
        {        
            opp.Primary_Reseller_Partner__c =  acc.Id;
            update opp;
        }
        Test.stopTest();
        PS_Questionnaire__c psqr = [select Id,Opportunity__c,Primary_Reseller_Partner__c FROM PS_Questionnaire__c WHERE opportunity__c =: opp.Id  AND RecordTypeId =:PsOnboardingRecordTypeId LIMIT 1];
        system.assertEquals(opp.Primary_Reseller_Partner__c,psqr.Primary_Reseller_Partner__c,'Primary Reseller Partner on Opportunity and PS Questionnaire should be same');       
    }
    
    @isTest
    static void testException(){
        //Test method to cover coverage of exception catch block
        Test.startTest();
        OpportunityPsOnboarding.throwTestError = true;
        Exception exceptionObj;
        User coreSalesUser = [SELECT Id,Username,profile.Name 
                              FROM User 
                              WHERE Email ='zscoresalesuser@test.com'
                              LIMIT 1]; 
        Opportunity opp = [SELECT Id,StageName,Product_Type__c,Proposed_Number_of_Users__c,
                           Economic_Buyer_Contact__c
                           FROM Opportunity 
                           WHERE Name = 'ZS Opportunity 2'
                           LIMIT 1];
        Contact con = [SELECT Id, LastName 
                       FROM Contact
                       WHERE LastName = 'Contact last Name'];
        Account acc2 = [SELECT Id FROM Account WHERE Name = 'ZS Account 2'];
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'ZS Account 1'];
        PS_Questionnaire__c psq = TestDatafactory_Zscaler.insertPSQuestionnaireforPSOnboarding(acc1.Id,opp.Id);  
        System.runAs(coreSalesUser)
        {        
            opp.Primary_Reseller_Partner__c =  acc2.Id; 
            opp.Primary_Competitor__c = 'Palo Alto Networks';
            opp.Secondary_Competitors__c = 'Palo Alto Networks';
            try{
                update opp;
            }catch(Exception e){
                exceptionObj = e;
            }
        }
        Test.stopTest();
        //System.assertEquals(TRUE,exceptionObj.getMessage().containsIgnoreCase('Update Failed'),'Exception was not handled');           
    }
}