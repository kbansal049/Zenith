@isTest
private class FileUploadViewControllerTest {
    
    @TestSetup
    static void createTestData() {   
        Account partnerAccount = new Account(Name = 'PartnerAccount001',
                                             Type = 'Partner');
        TriggerHandler.bypass('AccountTriggerHandler');
        insert partnerAccount;
        TriggerHandler.clearbypass('AccountTriggerHandler');
        
        partnerAccount = [SELECT Id, isPartner, Name 
                          FROM Account 
                          WHERE Name = 'PartnerAccount001' 
                          LIMIT 1];
        partnerAccount.IsPartner = TRUE;
        TriggerHandler.bypass('AccountTriggerHandler');
        update partnerAccount;
        TriggerHandler.clearbypass('AccountTriggerHandler');
        
        Campaign campaignRecord = new Campaign();
        campaignRecord.name='ZPA Interactive';
        campaignRecord.Department__c = '5000-Corporate Marketing';
        campaignRecord.Geo__c = 'GLOBAL';
        campaignRecord.StartDate = Date.today();
        campaignRecord.EndDate = Date.today()+30;
        campaignRecord.Fiscal_Year__c = 'All Time';
        campaignRecord.Type = 'Default';
        campaignRecord.Campaign_Type__c = 'Assets';
        campaignRecord.Recommended_Outreach_Sequence__c ='Testing';
        
        insert campaignRecord;
        
        PartnerMarketingBudget budget = new PartnerMarketingBudget();
        budget.Title = partnerAccount.Name + ' Marketing Budget';
        budget.ChannelPartnerId = partnerAccount.Id;
        budget.Amount = 99999999999.99;
        budget.Type = 'Marketing Funds';
        
        insert budget;
        
        PartnerFundAllocation fundAllocation = new PartnerFundAllocation();
        fundAllocation.Title = partnerAccount.Name + ' Fund Allocation';
        fundAllocation.ChannelPartnerId = partnerAccount.Id;
        fundAllocation.Amount = budget.Amount;
        fundAllocation.BudgetId = budget.Id;
        
        insert fundAllocation;
        
        PartnerFundRequest fundRequest = new PartnerFundRequest(Title = 'FundRequest001',
                                                                Activity = 'Digital Advertising-LinkedIn',
                                                                ChannelPartnerId = partnerAccount.Id,
                                                                AllocationId = fundAllocation.Id,
                                                                CoOp_Status__c = 'Pre-Approved',
                                                                Status = 'APPROVED',
                                                                RequestedAmount = 100.99,
                                                                Zinfi_Co_op_Id__c = 'ZINFI-Id-XYZ001',
                                                                Product__c = 'Zero Trust Exchange (ZTX)',
                                                                Lead_Follow_Up__c = 'Zscaler Lead Nurturing',
                                                                Target_Audience__c = 'End Customer',
                                                                PO_Number__c = 'POMNOP098765',
                                                                CampaignId = campaignRecord.Id,
                                                                Amount_Approved__c = 100);
        
        
        insert fundRequest;
    }
    
    @isTest
    static void getRelatedFilesTest(){
        
        PartnerFundRequest fundRequest = [SELECT Id, Title, Status, CoOp_Status__c,AllocationId
                                          FROM PartnerFundRequest 
                                          WHERE Title = 'FundRequest001' 
                                          LIMIT 1];
        PartnerFundClaim fundClaim = new PartnerFundClaim(Title = 'FundClaim001',
                                                          RequestId = fundRequest.Id,
                                                          Claim_Status__c = 'Pending Submission',
                                                          Amount = 20.99,
                                                          Zinfi_Claim_Id__c = 'ZINFI-Id-XYZ001');
        insert fundClaim;
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('ZINFI-Id-XYZ001 Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = fundClaim.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        Test.startTest();
        FileUploadViewController.getRelatedFiles(fundClaim.Id);
        Test.stopTest();
    }
    
    @isTest
    static void updateFileOwnerTest(){
        
        PartnerFundRequest fundRequest = [SELECT Id, Title, Status, CoOp_Status__c,AllocationId
                                          FROM PartnerFundRequest 
                                          WHERE Title = 'FundRequest001' 
                                          LIMIT 1];
        PartnerFundClaim fundClaim = new PartnerFundClaim(Title = 'FundClaim001',
                                                          RequestId = fundRequest.Id,
                                                          Claim_Status__c = 'Pending Submission',
                                                          Amount = 20.99,
                                                          Zinfi_Claim_Id__c = 'ZINFI-Id-XYZ001');
        insert fundClaim;
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('ZINFI-Id-XYZ001 Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = fundClaim.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        
        Test.startTest();
        FileUploadViewController.updateFileOwner(conDocId);
        Test.stopTest();
    }
    
    @isTest
    static void deleteFileRecordTest(){
        
        PartnerFundRequest fundRequest = [SELECT Id, Title, Status, CoOp_Status__c,AllocationId
                                          FROM PartnerFundRequest 
                                          WHERE Title = 'FundRequest001' 
                                          LIMIT 1];
        PartnerFundClaim fundClaim = new PartnerFundClaim(Title = 'FundClaim001',
                                                          RequestId = fundRequest.Id,
                                                          Claim_Status__c = 'Pending Submission',
                                                          Amount = 20.99,
                                                          Zinfi_Claim_Id__c = 'ZINFI-Id-XYZ001');
        insert fundClaim;
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('ZINFI-Id-XYZ001 Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = fundClaim.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        
        Test.startTest();
        FileUploadViewController.deleteFileRecord(conDocId);
        
        //Create Document
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document';
        cv1.PathOnClient = 'TestDocument.pdf';
        cv1.VersionData = Blob.valueOf('ZINFI-Id-XYZ001 Test Content');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        //Get Content Documents
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = fundClaim.Id;
        cdl1.ContentDocumentId = conDocId1;
        cdl1.shareType = 'V';
        Insert cdl1;
        
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Finance v2' LIMIT 1];
        User usr = new User(LastName = 'test',
                            FirstName='test',
                            Alias = 'pbhar',
                            Email = 'test.test@asdf.com',
                            Username = 'test.test@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        conDocId1 = null;
        system.runAs(usr){
            FileUploadViewController.deleteFileRecord(conDocId1);
        }
        Test.stopTest();
    }
    
    @isTest
    static void getFileRecordTest(){
        List<Account> accountList = TestDatafactory_Zscaler.createAccounts(1,false);
        TriggerHandler.bypass('AccountTriggerHandler');
        insert accountList;
        TriggerHandler.clearBypass('AccountTriggerHandler');
        List<Opportunity> opportunityList = TestDatafactory_Zscaler.createOpportunities(1,false);
        for(Opportunity opp : opportunityList){
            opp.accountId = accountList[0].Id;
            opp.Primary_Reseller_Partner__c =  accountList[0].Id;
            opp.ForecastCategoryName = 'Commit';
            opp.Forecast_Category__c = 'Commit';
            opp.AD_Forecast_Category__c = 'Commit';
            opp.CRO_Forecast_Category__c = 'Commit';
            opp.DM_Forecast_Category__c = 'Commit';
            opp.VP_Forecast_Category__c = 'Commit';
            opp.RVP_Forecast_Category__c = 'Commit';
            opp.Validation_Plan__c = 'test';
            opp.Value_Pyramid__c = 'value pyramid';
            opp.X3_Why__c = '3 Whys Link';
            opp.Validation_Stage__c = '4 - Delivering validation findings report';
            opp.Technical_Validation_Start_Date__c = Date.today().addDays(30);
            opp.Validation_End_Date__c = Date.today().addDays(60);
            opp.Proposed_Number_of_Users__c = 600;
            opp.ZIA_Use_Case__c = 'Data Protection';
        }     
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerHandler.bypass('AccountTriggerHandler');
        insert opportunityList;
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        TriggerHandler.clearbypass('AccountTriggerHandler');
        Opportunity opp = [SELECT Id,StageName,Product_Type__c,Proposed_Number_of_Users__c,
                           Economic_Buyer_Contact__c
                           FROM Opportunity 
                           WHERE Name = 'ZS Opportunity 0'
                           LIMIT 1];
        Id PsOnboardingRecordTypeId = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(Label.PS_Onboarding).getRecordTypeId();  
        PS_Questionnaire__c psq = TestDatafactory_Zscaler.insertPSQuestionnaireforPSOnboarding(accountList[0].Id,opp.Id);  
        
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('ZINFI-Id-XYZ001 Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = psq.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        
        Test.startTest();
        FileUploadViewController.deleteFileRecord(conDocId);
        
        //Create Document
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document';
        cv1.PathOnClient = 'TestDocument.pdf';
        cv1.VersionData = Blob.valueOf('ZINFI-Id-XYZ001 Test Content');
        cv1.IsMajorVersion = true;
        Insert cv1;
        
        //Get Content Documents
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = psq.Id;
        cdl1.ContentDocumentId = conDocId1;
        cdl1.shareType = 'V';
        Insert cdl1;
        
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Finance v2' LIMIT 1];
        User usr = new User(LastName = 'test',
                            FirstName='test',
                            Alias = 'pbhar',
                            Email = 'test.test@asdf.com',
                            Username = 'test.test@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        conDocId1 = null;
        system.runAs(usr){
            FileUploadViewController.getRelatedFilesForPOD(psq.Id);
            FileUploadViewController.getDocumentUrl(cdl1.ContentDocumentId);
            FileUploadViewController.updateUrlOnPsqRecord('',psq.Id,'BVA');
            FileUploadViewController.updateUrlOnPsqRecord('',psq.Id,'3 Whys Link');
            FileUploadViewController.updateUrlOnPsqRecord('',psq.Id,'Value Pyramid');
            FileUploadViewController.updateUrlOnPsqRecord('',psq.Id,'POV Playback');
            FileUploadViewController.updateUrlOnPsqRecord('',psq.Id,'POV Plan');
            FileUploadViewController.updateUrlOnPsqRecord('',psq.Id,'Service Proposal');
            FileUploadViewController.updateUrlOnPsqRecord('',psq.Id,'Architecture Document');
        }
        Test.stopTest();
    }
    
}