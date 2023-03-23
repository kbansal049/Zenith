/**
 * @File Name          : OppStageChecklistCntrlTest.cls
 * @Description        : 
 * @Author             : kpullagurla@zscaler.com
 * @Group              : 
 * @Last Modified By   : kpullagurla@zscaler.com
 * @Last Modified On   : 12/21/2021, 12:40:28 PM
 * @Modification Log   : 
 *------------------------------------------------------------------------------
 * Ver         Date                     Author                    Modification
 *------------------------------------------------------------------------------
 * 1.0    12/21/2021, 12:40:28 PM   kpullagurla@zscaler.com     Initial Version
 * 
 **/
@isTest
private class OppStageChecklistCntrlTest {
    
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
                                          CRO_Forecast_Category__c='Pipeline',DM_Forecast_Category__c='Pipeline',Is_Federal_Opportunity_Sync__c=false,
                                          Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), Forecast_Category__c='Pipeline',VP_Forecast_Category__c='Pipeline',
                                          RVP_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true,CRO_Forecast_Category_Lock__c=true,DM_Forecast_Category_Lock__c=true,
                                          RVP_Forecast_Category_Lock__c=true,VP_Forecast_Category_Lock__c=true,contract_end_date_new__c = date.today().adddays(65),
                                          Architecture_Workshop_Complete__c='Yes',Primary_Partner_Program__c='Traditional',Amount=100000,Proposed_Number_of_Users__c=20000,
                                          Competitor__c='AppGate',Is_SE_Involved__c='Yes',Technical_Validation_Start_Date__c=system.today(),Value_Pyramid__c='test',
                                          Primary_Competitor__c='Netskope',Secondary_Competitors__c='Netskope',Requires_signing_customer_documents__c= 'Other');
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
        OppStageChecklistController.DataWrapper obj = OppStageChecklistController.fetchDetails(opps[0].Id);
        system.assertNotEquals(obj.requiredFields,null);
        OppStageChecklistController.updateOpportunityStage(opps[0].Id,'2 - Architecture & Alignment',null,null,null,null,'Highly Competitive','Other','test','Others','Test','Other');
        OppStageChecklistController.DataWrapper obj1 = OppStageChecklistController.fetchDetails(opps[0].Id);
        system.assertNotEquals(obj1.requiredFields,null);
        OppStageChecklistController.updateOpportunityStage(opps[0].Id,'4 - Impact Validation',null,null,null,null,'Highly Competitive','Other','test','Others','Test','Other');
        OppStageChecklistController.DataWrapper obj2 = OppStageChecklistController.fetchDetails(opps[0].Id);
        system.assertNotEquals(obj2.requiredFields,null);
        Test.startTest();
        OppStageChecklistController.updateOpportunityStage(opps[0].Id,'4 - Impact Validation',null,null,null,null,'Highly Competitive','Other','test','Others','Test','Other');
        Map<String,Object> file = new Map<String,Object>();
        file.put('test.pic',Blob.valueOf('Test Content'));
        List<Map<String,Object>> files = new List<Map<String,Object>>();
        files.add(file);
        OppStageChecklistController.linkFileURLtoOpportunity(opps[0].Id, files, 'First_Meeting_Deck_Attached__c');
        OppStageChecklistController.linkFileURLtoOpportunity(opps[0].Id, files, 'First_Meeting_Deck_Attached__c,Value_Pyramid__c');
        OppStageChecklistController.unlinkFileURLFromOpportunity(opps[0].Id, 'First_Meeting_Deck_Attached__c');
        OppStageChecklistController.unlinkFileURLFromOpportunity(opps[0].Id, 'Value_Pyramid__c');
        OppStageChecklistController.getSolutionMapping();
        OppStageChecklistController.getValidationDependencies(opps[0].Id);
        Test.stopTest();
    }

    @isTest static void testfetchDetails1() {
        List<Opportunity> opps = [SELECT Id,Name FROM Opportunity WHERE Name = 'Test New Business Opportunity'];
        OppStageChecklistController cntrl = new OppStageChecklistController();
        OppStageChecklistController.DataWrapper obj = OppStageChecklistController.fetchDetails(opps[0].Id);
        system.assertNotEquals(obj.requiredFields,null);
        
        OppStageChecklistController.updateOpportunityStage(opps[0].Id,'4 - Impact Validation',null,null,null,null,'Highly Competitive','Other','test','Others','Test','Other');
        opps[0].Validation_Stage__c = '6 - Technical Win';
        opps[0].Validation_Plan__c =null;
        update opps[0];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        delete documents;
        OppStageChecklistController.getValidationDependencies(opps[0].Id);
        obj = OppStageChecklistController.fetchDetails(opps[0].Id);
        Boolean flag = OppStageChecklistController.allowPermissionOverride;
        flag =OppStageChecklistController.isRequiredFulfilled;
        List<OppStageChecklistController.FieldWrapper> fields = OppStageChecklistController.requiredFields;
        List<OppStageChecklistController.FieldWrapper> fields1 = OppStageChecklistController.optionalFields;
        String val = OppStageChecklistController.nextStageValue;
        String recType = OppStageChecklistController.recordTypeId;
        String prevStage = OppStageChecklistController.prevStageValue;
        List<OppStageChecklistController.ReferenceWrapper> wraps = OppStageChecklistController.attrs;
        String description = OppStageChecklistController.stageDescription;
        String act = OppStageChecklistController.actorsInvolved;
        Opportunity opp1 = OppStageChecklistController.opp;
        system.assertNotEquals(obj.requiredFields,null);
        OppStageChecklistController.getSolutionMapping();
        OppStageChecklistController.getDetailsForEdit(opps[0].Id);
        
    }
    
    //CR# 4752 Start - Added by Arsh
    @isTest static void testDupOppUpdate() {
		
		List<Account> acc = [SELECT Id,Name FROM Account WHERE Name = 'Test'];
        String newBusinessRTId = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();

        Opportunity dupOpp = new Opportunity(Name = 'Test Dup',AccountId=acc[0].Id,StageName='1 - Discovery & Qualification',RecordTypeId = newBusinessRTId,
                                        SE_name__c = UserInfo.getUserId(),CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '3 - Detailed validation in progress', Qualified_Date__c=system.Today()+5,LDR_Opp_Date__c = system.Today()+6,
                                           Qualification_Notes__c = 'Test Qualification notes',LDR_Name__c = UserInfo.getUserId() , Qualifier_Role__c = 'IT/Business Systems');
        Opportunity opp = new Opportunity(Name = 'Test Main',AccountId=acc[0].Id,StageName='1 - Discovery & Qualification',RecordTypeId = newBusinessRTId,
                                        SE_name__c = UserInfo.getUserId(),CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '3 - Detailed validation in progress');
		List<Opportunity> opps = new List<Opportunity>();
		opps.add(dupOpp); opps.add(opp);
		insert opps;
        OppStageChecklistController.updateLinkedOppSDR(dupOpp.Id,opp.Id);        
    }
}