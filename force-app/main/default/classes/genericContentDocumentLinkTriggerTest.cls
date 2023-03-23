/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-20-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class genericContentDocumentLinkTriggerTest {
    
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
        trlst.add(tr3);
        insert trlst;
        
        Triggers_Switch__c ts = new Triggers_Switch__c(name = 'Execute_Project_Design_Plan_Uploaded', Execute__c = true);
        insert ts;
        
        Triggers_Switch__c ts1 = new Triggers_Switch__c(name = 'Execute_ContentDocumentLink_Trigger', Execute__c = true);
        insert ts1;
        
        Triggers_Switch__c ts2 = new Triggers_Switch__c(name = 'Execute_EmailMessageCDL_to_CaseCDL', Execute__c = true);
        insert ts2;
        
        Triggers_Switch__c ts3 = new Triggers_Switch__c(name = 'Execute_Lightning_UpdateRFPRequest', Execute__c = true);
        insert ts3;
        
        Triggers_Switch__c ts4 = new Triggers_Switch__c(name = 'Execute_Associate_CDL_With_Case', Execute__c = true);
        insert ts4;
            
        
        
        
    }
    
    
    public static testMethod void genericContentDocumentLinkTest(){
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Subject = 'test sub';
        insert cs;
        Contact ct =new Contact();
        ct.LastName = 'test';
        ct.Email = 'test@test.com';
        insert ct;
        
        EmailMessage outGoingMail= new EmailMessage();
        outGoingMail.fromaddress='test@test.com';
        outGoingMail.toAddress = ct.Email;
        outGoingMail.subject = 'Opt Out Test Message';
        outGoingMail.TextBody= 'This is the message body BR-Interno.';
        outGoingMail.ParentId = cs.Id;
        outGoingMail.Incoming = true;
        insert outGoingMail;
        
        ContentVersion ContentVer = new ContentVersion();
        ContentVer.Title = 'My Doc';
        ContentVer.ContentUrl= 'test.com';
        Insert ContentVer;
        ContentDocumentLink ContentDL = new ContentDocumentLink();
        ContentDL.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: ContentVer.Id].ContentDocumentId;
        ContentDL.LinkedEntityId=outGoingMail.id;
        ContentDL.ShareType='V';
        Insert ContentDL;
        ContentDL = [SELECT Id,ShareType FROM ContentDocumentLink WHERE Id =:ContentDL.Id];
    }
    
    public static testMethod void genericContentDocumentLinkTest3(){
        
        Case cs = new Case();
        cs.Status = 'New';
        cs.Subject = 'test sub';
        insert cs;
        Contact ct =new Contact();
        ct.LastName = 'test';
        ct.Email = 'test@test.com';
        insert ct;
        
        EmailMessage outGoingMail= new EmailMessage();
        outGoingMail.fromaddress='test@test.com';
        outGoingMail.toAddress = ct.Email;
        outGoingMail.subject = 'Opt Out Test Message';
        outGoingMail.TextBody= 'This is the message body BR-Interno.';
        outGoingMail.ParentId = cs.Id;
        outGoingMail.Incoming = false;
        insert outGoingMail;
        
        ContentVersion ContentVer = new ContentVersion();
        ContentVer.Title = 'My Doc';
        ContentVer.ContentUrl= 'test.com';
        Insert ContentVer;
        ContentDocumentLink ContentDL = new ContentDocumentLink();
        ContentDL.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: ContentVer.Id].ContentDocumentId;
        ContentDL.LinkedEntityId=outGoingMail.id;
        ContentDL.ShareType='V';
        Insert ContentDL;
        ContentDL = [SELECT Id,ShareType FROM ContentDocumentLink WHERE Id =:ContentDL.Id];
    }
    public static testMethod void genericContentDocumentLinkTest1(){
        
        User testuser = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,Title = 'title',Alias = 'alias',
                                 TimeZoneSidKey = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',
                                 LastName = 'last',Email = 'max@bupa.com',Username = 'max@bupa.com',CompanyName = 'TEST');
        insert testuser;
        
        Account a = new Account(Name='TEST-Z');
        insert a;
        Contact c = new Contact(LastName='TEST-Z',Email='max@bupa.com',AccountId=a.id);
        insert c;
        
        
        inspire1__Project__c testProject = new inspire1__Project__c();
        testProject.Name = 'Test';
        testProject.inspire1__Account__c = a.Id;
        insert testProject;
        
        
        ContentVersion ContentVer = new ContentVersion();
        ContentVer.Title = 'My Doc';
        ContentVer.ContentUrl= 'test.com';
        Insert ContentVer;
        
        ContentDocumentLink ContentDL = new ContentDocumentLink();
        ContentDL.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: ContentVer.Id].ContentDocumentId;
        ContentDL.LinkedEntityId= testProject.id;
        ContentDL.ShareType='V';
        Insert ContentDL;
        
    }
    public static testMethod void genericContentDocumentLinkTest2(){
        RFP_Request__c rfp = new RFP_Request__c();
        Account Acc= new Account(Name='Test Account',Type='Partner');
        insert Acc;
        
        rfp.Account_Name__c = Acc.id;
        rfp.Due_Date__c = system.today();
        rfp.Proposed_Solution__c = 'ZIA';
        rfp.Request_Status__c = 'Completed';
        //rfp.Post_Request_Status__c = 'Completed';
        
        insert rfp;
        
        ContentVersion ContentVer = new ContentVersion();
        ContentVer.Title = 'My Doc';
        //ContetnVer.OwnerId = ;
        ContentVer.ContentUrl= 'test.com';
        Insert ContentVer;
        
        ContentDocumentLink ContentDL = new ContentDocumentLink();
        ContentDL.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: ContentVer.Id].ContentDocumentId;
        ContentDL.LinkedEntityId= rfp.id;
        ContentDL.ShareType='V';
        Insert ContentDL;
    }
    
    public static testMethod void insertFeedItemWithAttachments_Test(){
        Case cs = new Case();
        cs.Status = 'New';
        cs.Subject = 'test sub';
        cs.origin = 'Chatbot Portal';
        insert cs;
        ContentVersion ContentVer = new ContentVersion();
        ContentVer.Title = 'My Doc';
        ContentVer.ContentUrl= 'test.com';
        Insert ContentVer;
        ContentDocumentLink ContentDL = new ContentDocumentLink();
        ContentDL.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: ContentVer.Id].ContentDocumentId;
        ContentDL.LinkedEntityId=cs.id;
        ContentDL.ShareType='V';
        ContentDL.Visibility = 'AllUsers';
        Insert ContentDL;
    }

    /*@isTest 
    static void quoteSatusToGenerated_Test() {
        List<Account> accList = (SB_TestCPQDataUtility.createAccount(2));
        insert accList;

        List<Product2> productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = '';
        productList[0].Pricing_Meter__c = '';
        insert productList;
        
        PriceBook2 customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;
        
        List<PricebookEntry> customPbEntryList = new List<PricebookEntry>();
        PricebookEntry customPbEntry = new PricebookEntry();
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[1].Id,48))[0]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[2].Id,50))[1]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[3].Id,55))[2]);
        insert customPbEntryList;
        Opportunity opty = (SB_TestCPQDataUtility.createOpportunity(1, 'TestOpp', accList[0].Id))[0];
        insert opty;
        
        String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        SBQQ__Quote__c quoteRec = (SB_TestCPQDataUtility.createQuote(1, opty.Id, accList[0].Id, accList[1].id, accList[1].id,quoteNewBusiness))[0];
        quoteRec.TCV__c = 1800;
        quoteRec.SBQQ__BillingFrequency__c = 'Custom Schedule';
        quoteRec.SBQQ__Status__c = 'Approved';
        insert quoteRec; 
        ContentVersion cv=new Contentversion();
        cv.title='Quote Template';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = quoteRec.Id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        SBQQ__Quote__c quote =[SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id =:quoteRec.Id];
        System.assertEquals(quote.SBQQ__Status__c,'Generated');
    }*/
}