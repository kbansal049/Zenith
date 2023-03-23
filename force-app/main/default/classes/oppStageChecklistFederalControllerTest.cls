@isTest
private class oppStageChecklistFederalControllerTest {
    @TestSetup
    static void makeData(){
        
        Account acc = new Account(Name='Test', Type='Reseller',BillingCity = 'San Jose',
                                  BillingCountry = 'United States',
                                  BillingPostalCode = '95134',
                                  BillingState = 'California',
                                  BillingStreet = '110 Rose Orchard Way',
                                  Fax = '',
                                  Phone = '+1 408.533.0288',Market_Segment__c='SMB');
        insert acc;
        Contact con = new Contact(Lastname = 'Test');
        insert con;
        String newBusinessRTId = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Opportunity opp = new Opportunity(Name = 'Test New Business Opportunity',AccountId=acc.Id,StageName='1 - Discovery & Qualification',RecordTypeId = newBusinessRTId,
                                          SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '3 - Detailed validation in progress', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',
                                          CRO_Forecast_Category__c='Pipeline',DM_Forecast_Category__c='Pipeline',Is_Federal_Opportunity_Sync__c=true,
                                          Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), Forecast_Category__c='Pipeline',VP_Forecast_Category__c='Pipeline',
                                          RVP_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true,CRO_Forecast_Category_Lock__c=true,DM_Forecast_Category_Lock__c=true,
                                          RVP_Forecast_Category_Lock__c=true,VP_Forecast_Category_Lock__c=true,contract_end_date_new__c = date.today().adddays(65),
                                          Architecture_Workshop_Complete__c='Yes',Primary_Partner_Program__c='Traditional',Amount=100000,Proposed_Number_of_Users__c=20000,
                                          Competitor__c='AppGate',Is_SE_Involved__c='Yes',Technical_Validation_Start_Date__c=system.today(),Value_Pyramid__c='test');
        insert opp;
        List<ContentVersion> versions = new List<ContentVersion>();
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'), 
            Source_fileupload__c = 'Value_Pyramid__c',
            IsMajorVersion = true);
        versions.add(contentVersion);
        ContentVersion contentVersion1 = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'), 
            Source_fileupload__c = 'Attach POV Plan',
            IsMajorVersion = true);
        versions.add(contentVersion1);
        ContentVersion contentVersion2 = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Attach POV Playback/Validation Report'), 
            Source_fileupload__c = 'Attach POV Plan',
            IsMajorVersion = true);
        versions.add(contentVersion2);
        insert versions;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for(ContentDocument doc: documents){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = opp.Id;
            cdl.ContentDocumentId = doc.Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            links.add(cdl);
        }
        
        insert links;
        
        
    }
    @isTest static void testfetchDetails() {
        List<Opportunity> opps = [SELECT Id,Name FROM Opportunity WHERE Name = 'Test New Business Opportunity'];
        oppStageChecklistFederalController.DataWrapper obj = oppStageChecklistFederalController.fetchDetails(opps[0].Id);
        system.assertNotEquals(obj.requiredFields,null);
        oppStageChecklistFederalController.DataWrapper obj1 = oppStageChecklistFederalController.fetchDetails(opps[0].Id);
        system.assertNotEquals(obj1.requiredFields,null);
        oppStageChecklistFederalController.DataWrapper obj2 = oppStageChecklistFederalController.fetchDetails(opps[0].Id);
        system.assertNotEquals(obj2.requiredFields,null);
        Test.startTest();
        Map<String,Object> file = new Map<String,Object>();
        file.put('test.pic',Blob.valueOf('Test Content'));
        List<Map<String,Object>> files = new List<Map<String,Object>>();
        files.add(file);
        Test.stopTest();
    }
    
    @isTest static void testfetchDetails1() {
        List<Opportunity> opps = [SELECT Id,Name FROM Opportunity WHERE Name = 'Test New Business Opportunity'];
        oppStageChecklistFederalController cntrl = new oppStageChecklistFederalController();
        oppStageChecklistFederalController.DataWrapper obj = oppStageChecklistFederalController.fetchDetails(opps[0].Id);
        system.assertNotEquals(obj.requiredFields,null);
        
        opps[0].Validation_Stage__c = '6 - Technical Win';
        opps[0].Validation_Plan__c =null;
        update opps[0];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        delete documents;
        obj = oppStageChecklistFederalController.fetchDetails(opps[0].Id);
        system.assertNotEquals(obj.requiredFields,null);
        
    }
    
    
}