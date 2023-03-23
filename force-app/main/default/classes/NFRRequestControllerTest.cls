@isTest
public class NFRRequestControllerTest {
    
    private static List<Account> accList = new List<Account>();
    private static PriceBook2 customPb;
    private static List<PricebookEntry> customPbEntryList=new List<PricebookEntry>();
    private static List<Product2> productList=new List<Product2>();
    private static List<Opportunity> oppList = new List<Opportunity>();
    private static SBQQ__Quote__c quoteRec;
    private static List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
    private static List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
    private static List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
    private static Contract contractRec;
    private static String oppClose = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Business_Close').getRecordTypeId();
    private static String oppRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
    private static String quoteRenewal = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
    
    @testSetup static void setup() {
        User testUser = new User(LastName = 'TestUser',  Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id/*, ContactId = [SELECT Id FROM Contact LIMIT 1][0].Id*/);
        testUser.FirstName='Test';
        insert testUser;
        
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.SkipContactTriggerExecuted(); 
        TriggerUtility.SkipOppTriggerExecuted();
        leadTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        //Account
        Account acctTest = new Account(Name = 'Test Account',Sales_Engineer__c=testUser.id,Type='Prospect');
        insert acctTest;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acctTest.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30);
        insert opp;
        
        Contact con = new Contact(Lastname = 'Test',AccountId=acctTest.id);
        insert con;

        Id TechPartnerRecordTypeId = Schema.SObjectType.NFR__c.getRecordTypeInfosByName().get('Partners').getRecordTypeId();
        
        NFR__c NFR = new NFR__c();
        //NFR.Name = 'Test';
        NFR.Organisation_Domain__c = 'Test';
        NFR.Partner_Contact__c = con.Id;
        NFR.Preferred_Cloud__c = 'Zscalereone.net';
        NFR.Send_Initial_Credentials_To__c = 'Partner';
        NFR.NFR_Licence_Status__c = 'Not Active';
        NFR.Approval_Status__c = 'Approved';
        NFR.Start_Date__c = system.today();
        NFR.Expiry_Date_FromStartDate__c = system.today();
        NFR.RecordTypeId = TechPartnerRecordTypeId;
        NFR.Is_Customer_Using_ZIA__c = 'Yes';
        NFR.User_Authentication_Domains__c = 'Test';
        NFR.Is_Zapp_used__c = 'Yes';
        NFR.Send_Initial_Credentials_To__c ='Partner';
        insert NFR;
         
        DefaultData__c Dff = new DefaultData__c(name = 'PRCaseCreationDefault', Account_Id__c = acctTest.id, Category__c='Provisioning Request',Priority__c='Medium (P3)',Product__c='ZIA', Stage_Status__c='New',Type__c='Provisioning');
        Insert Dff;
        
        
    }
    
    
    
    @isTest
    public static void testmethod1(){
        Opportunity testOppty = [Select id from opportunity limit 1];
        Contact con = [Select id from Contact limit 1];
        Account acc= [Select id from Account limit 1];
        Test.startTest();
        Zscaler_Cloud_ID__c  cloudId = new Zscaler_Cloud_ID__c();
        cloudId.Name = '1441203345204183';
        cloudId.Account__c = acc.Id;
        cloudId.Status__c = 'Production';
        cloudId.Cloud_Type__c = 'ZIA';
        cloudId.RecordTypeId = '0120g000000YUcQAAW';
        
        insert cloudId;
        
        NFRRequestController.NFRValidateWrapper prwrap = NFRRequestController.validateForNFRComponent(acc.id);
        prwrap.cloud ='Both';
        prwrap.numberOfUsers =50;
        prwrap.additionalInfo='Test comments';
        prwrap.contractTerm=12;
        prwrap.justification=false;
        prwrap.accountId =acc.id;
        prwrap.additionalDomain ='domain';
        prwrap.startDate=System.today();
        prwrap.domain='domain';
        prwrap.preferredZIA='Zscaler.net';
        prwrap.preferredZPA ='ZPA Beta';
        prwrap.ziaCloudIdForZPA =cloudId.id;
        
        String zia='ZIA';
        String ziaProduct='ZIA-ELA-Edition';
        List<String> productList= new List<String>();
        productList.add(ziaProduct);
        Map<String,List<String>> cloudSkuMap = new Map<String,List<String>>();
        cloudSkuMap.put('ZIA', productList);
        prwrap.cloudSkuMap =cloudSkuMap;
        System.debug('prwrap'+prwrap);
        
        List<NFRRequestController.CredentialDetails> credList = new List<NFRRequestController.CredentialDetails>();
        NFRRequestController.CredentialDetails cred = new NFRRequestController.CredentialDetails();
        cred.Type = 'SE';
        cred.IsUser = true;
        cred.RecID = userinfo.getUserId();
        cred.Index = 0;
        credList.add(cred);
        
        NFRRequestController.CredentialDetails cred1 = new NFRRequestController.CredentialDetails();
        cred1.Type = 'Account Manager';
        cred1.IsUser = true;
        cred1.RecID = userinfo.getUserId();
        cred1.Index = 0;
        credList.add(cred1);
        
        
        NFRRequestController.CredentialDetails cred4 = new NFRRequestController.CredentialDetails();
        cred4.Type = 'Partner';
        cred4.IsUser = false;
        cred4.RecID = con.id;
        cred4.Index = 0;
        credList.add(cred4);
        
        prwrap.credDetails =  credList;
            System.debug('prwrap'+prwrap);
            prwrap = NFRRequestController.getALLPOCProducts(JSON.serialize(prwrap));
        
        NFRRequestController.createNFRrecords(JSON.serialize(prwrap));
        
        Test.stoptest();
    }
    
    @isTest
    public static void testMethod2(){
        
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.updateSENameFromAccountExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        
   
        
        
        Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
        sk.SetupOwnerId = userInfo.getUserId();
        sk.Object_s_to_skip__c = 'Account;Opportunity;OpportunitySplit';
        insert sk;
        
        
        
        accList = (SB_TestCPQDataUtility.createAccount(3));
        accList[0].Domain__c = 'testAccount1.com';
        accList[0].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[1].Asset_SKU_Codes__c='ZIA-ELA-BUNDLE,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[2].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        insert accList;
        Contact con = [Select id from Contact limit 1];
        //Contact con = SB_TestCPQDataUtility.createContact(1,accList[0].Id)[0];
        //insert con;
        
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today()+365,system.today()-30,'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        piList[1].Partner_Role__c='Distributor';
        piList[0].Partner_Role__c='Distributor';
        insert piList;
        
        productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        
        productList[0].ProductCode = 'ZIA-SVC-EDGE-3';
        productList[1].ProductCode = 'ZCES-SUP-PREM';
        
        productList[0].Product_Family__c='Bundle Platforms';
        productList[1].Product_Family__c='Zscaler Internet Access';
        productList[2].Product_Family__c='Zscaler Private Access';
        productList[3].Product_Family__c='Pre SKUs';
        
        productList[0].Product_Line__c='ZIA';
        productList[1].Product_Line__c='ZPA';
        productList[2].Product_Line__c='Workload Protection';
        productList[3].Product_Line__c='Cross Platform';
        
        productList[0].POC_Products__c='Popular';
        productList[1].POC_Products__c='Popular';
        productList[2].POC_Products__c='Regular';
        productList[3].POC_Products__c='Regular';
        
        productList[0].Zscaler_Product_Family__c = 'ZIA';
        productList[1].Zscaler_Product_Family__c = 'ZPA';
        productList[2].Zscaler_Product_Family__c = 'ZIA';
        productList[3].Zscaler_Product_Family__c = 'ZPA';
        
        productList[0].Rev_Model__c = 'Subscription';
        productList[1].Rev_Model__c = 'Subscription';
        productList[2].Rev_Model__c = 'Subscription';
        productList[3].Rev_Model__c = 'Subscription';
        
        insert productList;
        
        Zscaler_Cloud_ID__c  cloudId = new Zscaler_Cloud_ID__c();
        cloudId.Name = '1441203345204183';
        cloudId.Account__c = accList[0].Id;
        cloudId.Status__c = 'Production';
        cloudId.Cloud_Type__c = 'ZIA';
        cloudId.RecordTypeId = '0120g000000YUcQAAW';
        customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;
        
        PricebookEntry customPbEntry = new PricebookEntry();
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[1].Id,48))[0]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[2].Id,50))[1]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[3].Id,55))[2]);
        insert customPbEntryList;
        
        Opportunity renewalOpp = SB_TestCPQDataUtility.createOpportunity(1, 'TestOpp - Renewal', accList[0].Id)[0];
        renewalOpp.StageName = '4 - Impact Validation';
        renewalOpp.Primary_Partner_Program__c = Label.Partner_Program_Summit_Discount;
        renewalOpp.Primary_Reseller_Partner__c=accList[1].Id;
        renewalOpp.RecordTypeId = oppRenewal;
        insert renewalOpp; 
        
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = renewalOpp.Id,Partner_Type__c = 'Reseller',Account__c = accList[0].Id);
        insert OppPartner;
        
        
       // renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
       // update renewalOpp;
        
        
        Test.startTest();
        
        NFRRequestController.NFRValidateWrapper prwrap = NFRRequestController.validateForNFRComponent(accList[0].id);
        prwrap.cloud ='Both';
        prwrap.numberOfUsers =50;
        prwrap.additionalInfo='Test comments';
        prwrap.contractTerm=12;
        prwrap.justification=false;
        prwrap.accountId =accList[0].id;
        prwrap.additionalDomain ='domain';
        prwrap.startDate=System.today();
        prwrap.domain='domain';
        prwrap.preferredZIA='Zscaler.net';
        prwrap.preferredZPA ='ZPA Beta';
        prwrap.ziaCloudIdForZPA =cloudId.id;
        
        String zia='ZIA';
        String ziaProduct='ZIA-ELA-Edition';
        List<String> productList= new List<String>();
        productList.add(ziaProduct);
        Map<String,List<String>> cloudSkuMap = new Map<String,List<String>>();
        cloudSkuMap.put('ZIA', productList);
        prwrap.cloudSkuMap =cloudSkuMap;
        System.debug('prwrap'+prwrap);
        
        List<NFRRequestController.CredentialDetails> credList = new List<NFRRequestController.CredentialDetails>();
        NFRRequestController.CredentialDetails cred = new NFRRequestController.CredentialDetails();
        cred.Type = 'SE';
        cred.IsUser = true;
        cred.RecID = userinfo.getUserId();
        cred.Index = 0;
        credList.add(cred);
        
        NFRRequestController.CredentialDetails cred1 = new NFRRequestController.CredentialDetails();
        cred1.Type = 'Account Manager';
        cred1.IsUser = true;
        cred1.RecID = userinfo.getUserId();
        cred1.Index = 0;
        credList.add(cred1);
        
        
        NFRRequestController.CredentialDetails cred4 = new NFRRequestController.CredentialDetails();
        cred4.Type = 'Partner';
        cred4.IsUser = false;
        cred4.RecID = con.id;
        cred4.Index = 0;
        credList.add(cred4);
        
        prwrap.credDetails =  credList;
            System.debug('prwrap'+prwrap);
            prwrap = NFRRequestController.getALLPOCProducts(JSON.serialize(prwrap));
            NFRRequestController.createNFRrecords(JSON.serialize(prwrap));
            
            //id prId = [Select id from Provisioning_Request__c limit 1].id;
            
            List<POC_Product__c> pocListToInsert = new List<POC_Product__c>();
          //  NFRRequestController.fillpocproductsFromTheQuote(pocListToInsert, prId ,renewalOpp.id, 'ZPA');
            
            Test.stoptest();
    }

    @isTest
    public static void testMethod3(){
        
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.updateSENameFromAccountExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        
       
        
        Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
        sk.SetupOwnerId = userInfo.getUserId();
        sk.Object_s_to_skip__c = 'Account;Opportunity;OpportunitySplit';
        insert sk;
        
        
      
        accList = (SB_TestCPQDataUtility.createAccount(3));
        accList[0].Domain__c = 'testAccount1.com';
        accList[0].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[1].Asset_SKU_Codes__c='ZIA-ELA-BUNDLE,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[2].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        insert accList;
         Zscaler_Cloud_ID__c  cloudId = new Zscaler_Cloud_ID__c();
        cloudId.Name = '1441203345204183';
        cloudId.Account__c = accList[0].id;
        cloudId.Status__c = 'Production';
        cloudId.Cloud_Type__c = 'ZIA';
        cloudId.RecordTypeId = '0120g000000YUcQAAW';
        //Contact con = SB_TestCPQDataUtility.createContact(1,accList[0].Id)[0];
        //insert con;
        Contact con = [Select id from Contact limit 1];
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today()+365,system.today()-30,'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        piList[1].Partner_Role__c='Distributor';
        piList[0].Partner_Role__c='Distributor';
        insert piList;
        
        productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        
        productList[0].ProductCode = 'ZIA-SVC-EDGE-3';
        productList[1].ProductCode = 'ZCES-SUP-PREM';
        
        productList[0].Product_Family__c='Bundle Platforms';
        productList[1].Product_Family__c='Zscaler Internet Access';
        productList[2].Product_Family__c='Zscaler Private Access';
        productList[3].Product_Family__c='Pre SKUs';
        
        productList[0].Product_Line__c='ZIA';
        productList[1].Product_Line__c='ZPA';
        productList[2].Product_Line__c='Workload Protection';
        productList[3].Product_Line__c='Cross Platform';
        
        productList[0].POC_Products__c='Popular';
        productList[1].POC_Products__c='Popular';
        productList[2].POC_Products__c='Regular';
        productList[3].POC_Products__c='Regular';
        
        productList[0].Zscaler_Product_Family__c = 'ZIA';
        productList[1].Zscaler_Product_Family__c = 'ZPA';
        productList[2].Zscaler_Product_Family__c = 'ZIA';
        productList[3].Zscaler_Product_Family__c = 'ZPA';
        
        productList[0].Rev_Model__c = 'Subscription';
        productList[1].Rev_Model__c = 'Subscription';
        productList[2].Rev_Model__c = 'Subscription';
        productList[3].Rev_Model__c = 'Subscription';
        
        insert productList;
        
        
        customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;
        
        
        Opportunity renewalOpp = SB_TestCPQDataUtility.createOpportunity(1, 'TestOpp - Renewal', accList[0].Id)[0];
        renewalOpp.StageName = '4 - Impact Validation';
        renewalOpp.Primary_Partner_Program__c = Label.Partner_Program_Summit_Discount;
        renewalOpp.Primary_Reseller_Partner__c=accList[1].Id;
        renewalOpp.RecordTypeId = oppRenewal;
        insert renewalOpp; 
        
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = renewalOpp.Id,Partner_Type__c = 'Reseller',Account__c = accList[0].Id);
        insert OppPartner;
        
        
       // renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
       // update renewalOpp;
        
        
        Test.startTest();
        
        NFRRequestController.NFRValidateWrapper prwrap = NFRRequestController.validateForNFRComponent(accList[0].id);
        prwrap.cloud ='Both';
        prwrap.numberOfUsers =50;
        prwrap.additionalInfo='Test comments';
        prwrap.contractTerm=12;
        prwrap.justification=false;
        prwrap.accountId =accList[0].id;
        prwrap.additionalDomain ='domain';
        prwrap.startDate=System.today();
        prwrap.domain='domain';
        prwrap.preferredZIA='Zscaler.net';
        prwrap.preferredZPA ='ZPA Beta';
        prwrap.ziaCloudIdForZPA =cloudId.id;
        
        String zia='ZIA';
        String ziaProduct='ZIA-ELA-Edition';
        List<String> productList= new List<String>();
        productList.add(ziaProduct);
        Map<String,List<String>> cloudSkuMap = new Map<String,List<String>>();
        cloudSkuMap.put('ZIA', productList);
        prwrap.cloudSkuMap =cloudSkuMap;
        System.debug('prwrap'+prwrap);
        
        List<NFRRequestController.CredentialDetails> credList = new List<NFRRequestController.CredentialDetails>();
        NFRRequestController.CredentialDetails cred = new NFRRequestController.CredentialDetails();
        cred.Type = 'SE';
        cred.IsUser = true;
        cred.RecID = userinfo.getUserId();
        cred.Index = 0;
        credList.add(cred);
        
        NFRRequestController.CredentialDetails cred1 = new NFRRequestController.CredentialDetails();
        cred1.Type = 'Account Manager';
        cred1.IsUser = true;
        cred1.RecID = userinfo.getUserId();
        cred1.Index = 0;
        credList.add(cred1);
        
        
        NFRRequestController.CredentialDetails cred4 = new NFRRequestController.CredentialDetails();
        cred4.Type = 'Partner';
        cred4.IsUser = false;
        cred4.RecID = con.id;
        cred4.Index = 0;
        credList.add(cred4);
        List<NFRRequestController.POCProductWrapper> pocProducts = new List<NFRRequestController.POCProductWrapper>();
        pocProducts.add(new NFRRequestController.POCProductWrapper());
        
        
        prwrap.credDetails =  credList;
            System.debug('prwrap'+prwrap);
            prwrap = NFRRequestController.getALLPOCProducts(JSON.serialize(prwrap));
            NFRRequestController.createNFRrecords(JSON.serialize(prwrap));
            
            //id prId = [Select id from Provisioning_Request__c limit 1].id;
            
            List<POC_Product__c> pocListToInsert = new List<POC_Product__c>();
          //  NFRRequestController.fillpocproductsFromTheQuote(pocListToInsert, prId ,renewalOpp.id, 'ZPA');
          //NFRRequestController.booster();
            
            Test.stoptest();
    }
}