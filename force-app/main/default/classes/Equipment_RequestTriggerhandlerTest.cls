/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-01-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class Equipment_RequestTriggerhandlerTest {
    
    private static List<Account> accList = new List<Account>();
    private static PriceBook2 customPb;
    private static List<PricebookEntry> customPbEntryList=new List<PricebookEntry>();
    private static List<Product2> productList=new List<Product2>();
    private static List<Opportunity> oppList = new List<Opportunity>();
    private static SBQQ__Quote__c quoteRec;
    private static List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
    private static List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
    private static List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
    
    private static String depRecordTypeId = (Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Deployment Project') != null) ? Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByName().get('Deployment Project').getRecordTypeId() : Null;
    private static String oppClose = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Business_Close').getRecordTypeId();
    private static String oppRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
    private static String quoteRenewal = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
    private static String professionalServicesRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Professional_Services').getRecordTypeId();
    
    @TestSetup
    private static void createTestData(){        
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.SkipOppTriggerExecuted();
        TriggerUtility.updateSENameFromAccountExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();        
        
        Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
        sk.SetupOwnerId = userInfo.getUserId();
        sk.Object_s_to_skip__c = 'Account;Opportunity;OpportunitySplit;Apttus_Proposal__Proposal__c';
        insert sk;
        
        //CR# 4543
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User user1 = new User(LastName = 'test',
                              FirstName='test',
                              Alias = 'alias',
                              Email = 'testER@testER.com',
                              Username = 'userNameER@testER.com',
                              ProfileId = profileId.id,
                              TimeZoneSidKey = 'America/Los_Angeles',
                              EmailEncodingKey = 'UTF-8',
                              LanguageLocaleKey = 'en_US',
                              LocaleSidKey = 'en_US'
                             );
        insert user1;
        
        accList = (SB_TestCPQDataUtility.createAccount(3));
        accList[0].Domain__c = 'testAccount1.com';
        accList[0].Account_Manager__c = user1.id;
        accList[0].CSM_Name_New__c = user1.id;
        accList[0].CSM_Name_2__c = user1.id;
        accList[0].TAM_Name_New__c = user1.id;
        accList[0].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[1].Asset_SKU_Codes__c='ZIA-ELA-BUNDLE,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[2].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        insert accList;
        
        Contact con = SB_TestCPQDataUtility.createContact(1,accList[0].Id)[0];
        insert con;
        
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today()+365,system.today()-30,'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        piList[1].Partner_Role__c='Distributor';
        piList[0].Partner_Role__c='Distributor';
        insert piList;
        
        productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = 'ZIA-SVC-EDGE-3';
        productList[0].Pricing_Meter__c = '';
        productList[0].SKU_Type__c='PRE';
        productList[0].Product_Family__c='Bundle Platforms';
        productList[1].Product_Family__c='Zscaler Internet Access';
        productList[2].Product_Family__c='Zscaler Private Access';
        productList[3].Product_Family__c='Pre SKUs';
        
        productList[0].Zscaler_Product_Family__c = 'ZIA';
        productList[1].Zscaler_Product_Family__c = 'ZIA';
        productList[2].Zscaler_Product_Family__c = 'ZPA';
        productList[2].Zscaler_Product_Family__c = 'ZDX';
        insert productList;
        
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
        renewalOpp.PS_SKU_System__c = 'ZCES-DEP-ENTPLUS';
        insert renewalOpp;
        
        List<Zscaler_Cloud_ID__c> ZSClIDlist = new List<Zscaler_Cloud_ID__c>();
        String ridZPA = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZPA Cloud ID').getRecordTypeId();
        String ridZIA = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZIA Cloud ID').getRecordTypeId();
        Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test1',Account__c= accList[0].Id,NS_Org_ID__c='Zscloud.net-3926test1.beta',
                                                          Zscaler_Cloud_Domain__c='testacc.com.au.test1',
                                                          Org_Name__c='Test Account Org',Cloud_Type__c='ZIA',recordTypeId = ridZIA, 
                                                          ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc1);
        Zscaler_Cloud_ID__c ZSc2= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926test2',Account__c= accList[0].Id,
                                                          NS_Org_ID__c='Zscloud.net-3926test2.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test2',
                                                          Org_Name__c='Test Account Org',Cloud_Type__c='ZPA', recordTypeId = ridZPA, 
                                                          ZPA_Enrolled_Users_L31D_Rollup__c = 1, ZPA_Enrolled_Users_L6M_Rollup__c= 1, ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        ZSClIDlist.add(ZSc2);
        insert ZSClIDlist;
        
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, renewalOpp.Id, renewalOpp.AccountId, renewalOpp.Primary_Reseller_Partner__c,renewalOpp.Primary_Reseller_Partner__c,quoteRenewal)[0];
        quoteRec.Partner_Incentive__c = piList[1].Id;
        quoteRec.Partner_Program__c = Label.Partner_Program_Summit_Discount;
        quoteRec.Include_Value_Summary_Feature_Additions__c= true;
        quoteRec.Special_Terms__c='This is test terms';
        quoteRec.Include_Value_Summary_Feature_Additions__c = true;
        quoteRec.Include_Value_Summary_Feature_Additions__c =true;
        quoteRec.Include_Value_Summary_Feature_Additions__c  =true;
        quoteRec.SBQQ__partner__c=accList[0].id;
        quoteRec.Bill_to__c =accList[1].id;
        quoteRec.SBQQ__Type__c='Renewal';
        quoteRec.Line_Item_SKU_Approval__c ='ZPA-ZFED-MODERATE,ZCES-PRO-DZX,ZCES-PRO-SVC,ZCES-PRO-SVC,ZCES-DAS-PKG6,'+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+','+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+',ZCES-EDU-CREDIT,ZCES-PRO-OPTESS,ZCES-PRO-OPTADV,ZCES-DEP-ADV,ZCES-DEP-ENT,ZCES-DAS-PKG0,ZCR-BuyBack,ZCES-EDU-CREDIT,Z-Credit,ZIA-ELA-BUNDLE,ZIA-SANDBOX,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZIA-TRANS-EDITION,';
        quoteRec.SBQQ__BillingFrequency__c = 'Custom Schedule';
        quoteRec.ApprovalStatus__c ='Approved';
        quoteRec.SBQQ__Primary__c = true;
        quoteRec.Included_DAS_Package__c = 'ZCES-DEP-ENTPLUS';
        SBQQ.TriggerControl.disable();        
        insert quoteRec;      
    }
    
    @isTest 
    static void equipmentRequestUpdateTest1(){
        List<PS_EarlyEngagement_ApprovalEmail_CC_List__mdt> ccListMdtList
                        = PS_EarlyEngagement_ApprovalEmail_CC_List__mdt.getAll().values();		      
        Opportunity renewalOpp = [SELECT Id,SBQQ__PrimaryQuote__c 
                                  FROM Opportunity 
                                  WHERE Name like '%TestOpp - Renewal%' 
                                  LIMIT 1];
        SBQQ__Quote__c quoteRec = [SELECT Id,SBQQ__Opportunity2__c 
                                  FROM SBQQ__Quote__c 
                                  WHERE SBQQ__Opportunity2__c = : renewalOpp.Id
                                  LIMIT 1]; 
        renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
        update renewalOpp;
        Test.startTest();
        List<Equipment_Request__c> equipReqList = new List<Equipment_Request__c>();
        
        Equipment_Request__c equipReq1 = new Equipment_Request__c();
        equipReq1.Opportunity__c=renewalOpp.Id;
        equipReq1.Localized_content__c=true;
        equipReq1.RecordTypeId = professionalServicesRecordTypeId;
        equipReq1.Type__c = 'Early Engagement';
        equipReq1.Early_Engagement_Approval_Process_Status__c = 'Approval Process 1 (One Step Approval) - Submitted';
        equipReqList.add(equipReq1);
        
        Equipment_Request__c equipReq2 = new Equipment_Request__c();
        equipReq2.Opportunity__c=renewalOpp.Id;
        equipReq2.Localized_content__c=true;
        equipReq2.RecordTypeId = professionalServicesRecordTypeId;
        equipReq2.Type__c = 'Early Engagement';
        equipReq2.Early_Engagement_Approval_Process_Status__c = 'Approval Process 1 (One Step Approval) - Submitted';
        equipReqList.add(equipReq2);
        
        insert equipReqList;
        
        System.debug('equipReqList : ' + equipReqList);
        Equipment_Request__c equipReqRecordList = new Equipment_Request__c();
        equipReqRecordList = [SELECT Id,Early_Engagement_Approval_Process_Status__c 
                                             FROM Equipment_Request__c
                                             WHERE Early_Engagement_Approval_Process_Status__c = 'Approval Process 1 (One Step Approval) - Submitted' LIMIT 1];
        System.debug('equipReqRecordList : ' + equipReqRecordList);
       
        if(equipReqRecordList != NULL){
            equipReqRecordList.Early_Engagement_Approval_Process_Status__c = 'Approval Process 1 (One Step Approval) - Approved';
            Database.update(equipReqRecordList,false);
        }
        
        Test.stopTest();
        
    }
    
    @isTest 
    static void equipmentRequestUpdateTest2(){
        List<PS_EarlyEngagement_ApprovalEmail_CC_List__mdt> ccListMdtList
                        = PS_EarlyEngagement_ApprovalEmail_CC_List__mdt.getAll().values();
        Opportunity renewalOpp = [SELECT Id,SBQQ__PrimaryQuote__c 
                                  FROM Opportunity 
                                  WHERE Name like '%TestOpp - Renewal%' 
                                  LIMIT 1];
        SBQQ__Quote__c quoteRec = [SELECT Id,SBQQ__Opportunity2__c 
                                  FROM SBQQ__Quote__c 
                                  WHERE SBQQ__Opportunity2__c = : renewalOpp.Id
                                  LIMIT 1]; 
        renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
        update renewalOpp;
        List<Equipment_Request__c> equipReqList = new List<Equipment_Request__c>();
        
        Equipment_Request__c equipReq1 = new Equipment_Request__c();
        equipReq1.Opportunity__c=renewalOpp.Id;
        equipReq1.Localized_content__c=true;
        equipReq1.RecordTypeId = professionalServicesRecordTypeId;
        equipReq1.Type__c = 'Early Engagement';
        equipReq1.Early_Engagement_Approval_Process_Status__c = 'Approval Process 1 (One Step Approval) - Submitted';
        //equipReqList.add(equipReq1);
        
        Equipment_Request__c equipReq2 = new Equipment_Request__c();
        equipReq2.Opportunity__c=renewalOpp.Id;
        equipReq2.Localized_content__c=true;
        equipReq2.RecordTypeId = professionalServicesRecordTypeId;
        equipReq2.Type__c = 'Early Engagement';
        equipReq2.Early_Engagement_Approval_Process_Status__c = 'Approval Process 2 (Geo based approval) - Submitted';
        equipReqList.add(equipReq2);
        
        insert equipReqList;
        
        System.debug('equipReqList : ' + equipReqList);
        
        Test.startTest();
        List<Equipment_Request__c> equipReqRecordList = [SELECT Id,Early_Engagement_Approval_Process_Status__c 
                                                   FROM Equipment_Request__c];
        System.debug('equipReqRecordList : ' + equipReqRecordList);
        Equipment_Request__c equipReqRecord = new Equipment_Request__c();
        equipReqRecord = [SELECT Id,Early_Engagement_Approval_Process_Status__c 
                          FROM Equipment_Request__c LIMIT 1];
        if(equipReqRecord != NULL){
            equipReqRecord.Early_Engagement_Approval_Process_Status__c = 'Approval Process 2 (Geo based approval) - Approved';
            Database.update(equipReqRecord,false);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void equipmentRequestUpdateTest3(){
        List<PS_EarlyEngagement_ApprovalEmail_CC_List__mdt> ccListMdtList
                        = PS_EarlyEngagement_ApprovalEmail_CC_List__mdt.getAll().values();
        Opportunity renewalOpp = [SELECT Id,SBQQ__PrimaryQuote__c 
                                  FROM Opportunity 
                                  WHERE Name like '%TestOpp - Renewal%' 
                                  LIMIT 1];
        SBQQ__Quote__c quoteRec = [SELECT Id,SBQQ__Opportunity2__c 
                                  FROM SBQQ__Quote__c 
                                  WHERE SBQQ__Opportunity2__c = : renewalOpp.Id
                                  LIMIT 1]; 
        renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
        update renewalOpp;
        List<Equipment_Request__c> equipReqList = new List<Equipment_Request__c>();
        
        Equipment_Request__c equipReq1 = new Equipment_Request__c();
        equipReq1.Opportunity__c=renewalOpp.Id;
        equipReq1.Localized_content__c=true;
        equipReq1.RecordTypeId = professionalServicesRecordTypeId;
        equipReq1.Type__c = 'Early Engagement';
        equipReq1.Early_Engagement_Approval_Process_Status__c = 'Approval Process 1 (One Step Approval) - Submitted';
        equipReqList.add(equipReq1);
        
        insert equipReqList;
        
        System.debug('equipReqList : ' + equipReqList);
        
        Test.startTest();
        List<Equipment_Request__c> equipReqRecordList = [SELECT Id,Early_Engagement_Approval_Process_Status__c 
                                                   FROM Equipment_Request__c];
        System.debug('equipReqRecordList : ' + equipReqRecordList);
        Equipment_Request__c equipReqRecord = new Equipment_Request__c();
        equipReqRecord = [SELECT Id,Early_Engagement_Approval_Process_Status__c 
                          FROM Equipment_Request__c LIMIT 1];
        if(equipReqRecord != NULL){
            equipReqRecord.Early_Engagement_Approval_Process_Status__c = 'Approval Process 1 (One Step Approval) - Rejected';
            Database.update(equipReqRecord,false);
        }
        Test.stopTest();
    }
    
     @isTest 
    static void equipmentRequestUpdateTest4(){
        List<PS_EarlyEngagement_ApprovalEmail_CC_List__mdt> ccListMdtList
                        = PS_EarlyEngagement_ApprovalEmail_CC_List__mdt.getAll().values();
        Opportunity renewalOpp = [SELECT Id,SBQQ__PrimaryQuote__c 
                                  FROM Opportunity 
                                  WHERE Name like '%TestOpp - Renewal%' 
                                  LIMIT 1];
        SBQQ__Quote__c quoteRec = [SELECT Id,SBQQ__Opportunity2__c 
                                  FROM SBQQ__Quote__c 
                                  WHERE SBQQ__Opportunity2__c = : renewalOpp.Id
                                  LIMIT 1]; 
        renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
        update renewalOpp;
        List<Equipment_Request__c> equipReqList = new List<Equipment_Request__c>(); 
        
        Equipment_Request__c equipReq2 = new Equipment_Request__c();
        equipReq2.Opportunity__c=renewalOpp.Id;
        equipReq2.Localized_content__c=true;
        equipReq2.RecordTypeId = professionalServicesRecordTypeId;
        equipReq2.Type__c = 'Early Engagement';
        equipReq2.Early_Engagement_Approval_Process_Status__c = 'Approval Process 2 (Geo based approval) - Submitted';
        equipReqList.add(equipReq2);
        
        insert equipReqList;
        
        System.debug('equipReqList : ' + equipReqList);
        
        Test.startTest();
        List<Equipment_Request__c> equipReqRecordList = [SELECT Id,Early_Engagement_Approval_Process_Status__c 
                                                   FROM Equipment_Request__c];
        System.debug('equipReqRecordList : ' + equipReqRecordList);
        Equipment_Request__c equipReqRecord = new Equipment_Request__c();
        equipReqRecord = [SELECT Id,Early_Engagement_Approval_Process_Status__c 
                          FROM Equipment_Request__c LIMIT 1];
        if(equipReqRecord != NULL){
            equipReqRecord.Early_Engagement_Approval_Process_Status__c = 'Approval Process 2 (Geo based approval) - Rejected';
            Database.update(equipReqRecord,false);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void equipmentRequestDeleteTest1(){
        List<PS_EarlyEngagement_ApprovalEmail_CC_List__mdt> ccListMdtList
                        = PS_EarlyEngagement_ApprovalEmail_CC_List__mdt.getAll().values();
        Opportunity renewalOpp = [SELECT Id,SBQQ__PrimaryQuote__c 
                                  FROM Opportunity 
                                  WHERE Name like '%TestOpp - Renewal%' 
                                  LIMIT 1];
        SBQQ__Quote__c quoteRec = [SELECT Id,SBQQ__Opportunity2__c 
                                  FROM SBQQ__Quote__c 
                                  WHERE SBQQ__Opportunity2__c = : renewalOpp.Id
                                  LIMIT 1]; 
        renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
        update renewalOpp;
        List<Equipment_Request__c> equipReqList = new List<Equipment_Request__c>();
        
        Equipment_Request__c equipReq1 = new Equipment_Request__c();
        equipReq1.Opportunity__c=renewalOpp.Id;
        equipReq1.Localized_content__c=true;
        equipReq1.RecordTypeId = professionalServicesRecordTypeId;
        equipReq1.Type__c = 'Early Engagement';
        equipReq1.Early_Engagement_Approval_Process_Status__c = 'Approval Process 1 (One Step Approval) - Submitted';
        //equipReqList.add(equipReq1);
        
        Equipment_Request__c equipReq2 = new Equipment_Request__c();
        equipReq2.Opportunity__c=renewalOpp.Id;
        equipReq2.Localized_content__c=true;
        equipReq2.RecordTypeId = professionalServicesRecordTypeId;
        equipReq2.Type__c = 'Early Engagement';
        equipReq2.Early_Engagement_Approval_Process_Status__c = 'Approval Process 2 (Geo based approval) - Submitted';
        equipReqList.add(equipReq2);
        
        insert equipReqList;
        
        System.debug('equipReqList : ' + equipReqList);
        
        Test.startTest();
        Equipment_Request__c equipReqRecord = new Equipment_Request__c();
        equipReqRecord = [SELECT Id,Early_Engagement_Approval_Process_Status__c 
                          FROM Equipment_Request__c LIMIT 1];
        if(equipReqRecord != NULL){
            delete equipReqRecord;
        }
        
        Test.stopTest();
    }
    
}