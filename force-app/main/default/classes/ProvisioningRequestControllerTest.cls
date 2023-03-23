@isTest
public class ProvisioningRequestControllerTest {
    
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
        
        Contact con = new Contact(Lastname = 'Test',AccountId=acctTest.id);
        insert con;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acctTest.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30);
        insert opp;
         
        DefaultData__c Dff = new DefaultData__c(name = 'PRCaseCreationDefault', Account_Id__c = acctTest.id, Category__c='Provisioning Request',Priority__c='Medium (P3)',Product__c='ZIA', Stage_Status__c='New',Type__c='Provisioning');
        Insert Dff;
        
        //Insert Custom Settings
        ZscalerCustomSetting__c setting = new ZscalerCustomSetting__c();
        setting.Name = 'DefaultPRDecommisionContact';
        setting.Value__c = '0034u00002UusGqAAJ';
        insert setting;
    }
    
    @isTest
    public static void testmethod1(){
        Opportunity testOppty = [Select id from opportunity limit 1];
        Contact con = [Select id from Contact limit 1];
        
        Test.startTest();
        
        ProvisioningRequestController.PRValidateWrapper prwrap = ProvisioningRequestController.validateForPRComponent(testOppty.id);
        prwrap.cloud ='Both';
        
        List<ProvisioningRequestController.CredentialDetails> credList = new List<ProvisioningRequestController.CredentialDetails>();
        ProvisioningRequestController.CredentialDetails cred = new ProvisioningRequestController.CredentialDetails();
        cred.Type = 'SE';
        cred.IsUser = true;
        cred.RecID = userinfo.getUserId();
        cred.Index = 0;
        credList.add(cred);
        
        ProvisioningRequestController.CredentialDetails cred1 = new ProvisioningRequestController.CredentialDetails();
        cred1.Type = 'Account Manager';
        cred1.IsUser = true;
        cred1.RecID = userinfo.getUserId();
        cred1.Index = 0;
        credList.add(cred1);
        
        ProvisioningRequestController.CredentialDetails cred2 = new ProvisioningRequestController.CredentialDetails();
        cred2.Type = 'Account Owner';
        cred2.IsUser = true;
        cred2.RecID = userinfo.getUserId();
        cred2.Index = 0;
        credList.add(cred2);
        
        ProvisioningRequestController.CredentialDetails cred3 = new ProvisioningRequestController.CredentialDetails();
        cred3.Type = 'Customer';
        cred3.IsUser = false;
        cred3.RecID = con.id;
        cred3.Index = 0;
        credList.add(cred3);
        
        ProvisioningRequestController.CredentialDetails cred4 = new ProvisioningRequestController.CredentialDetails();
        cred4.Type = 'Partner';
        cred4.IsUser = false;
        cred4.RecID = con.id;
        cred4.Index = 0;
        credList.add(cred4);
        
        prwrap.credDetails =  credList;
            
        prwrap = ProvisioningRequestController.getALLPOCProducts(JSON.serialize(prwrap));
        
        ProvisioningRequestController.createPRrecords(JSON.serialize(prwrap));
        
        Test.stoptest();
    }
    
    @isTest
    public static void testMethod2(){
         user u1= [select id from user where name !='Copado Integration Admin' and Profile.Name='System Administrator' and isActive=true limit 1];
        system.runas(u1){
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.updateSENameFromAccountExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        
        
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skuscs = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_CSB_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZSEC-WEB-ABA');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec2 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_ZPA_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZIA-TRANS-BUNDLE;ZIA-ELA-BUNDLE');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec3 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Credit_SKUs', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec4 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='One_Time_SKU', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG6;ZCES-EDU-CREDIT;ZCES-EDU-LABCREDIT;ZCES-Onetime-ZPA-INT');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec5 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Recurring_SKU', SKU_Codes__c = 'ZCES-SUP-PREM;ZCES-SUP-PREM-SP;ZCES-SUP-TAMT;ZIA-BUS'); //Modified by Swathi: CR#1058
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec6 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_not_To_ADD', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec7 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_to_SKIP_ACV', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT;ZCR-UPY4;ZCR-UPY5');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec8 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Uplift_SKUs', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec9 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG6;ZCES-EDU-CREDIT;ZCES-EDU-LABCREDIT;');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec10 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='One_Time_SKU1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST;ZCES-PQR');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec12 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Contract_Date', SKU_Codes__c = 'ZCES-PRO-SVC-CUST;ZCES-ABC');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec16 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date', SKU_Codes__c = 'ZCES-PRO-SVC-CUST;ZCES-ABE');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec13 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST;ZCES-ABE');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec14 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Included_DAS_Package_SKUs1', SKU_Codes__c = 'ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG4;ZCES-DAS-PKG6;ZCES-DAS-PKG0;ZCES-DEP-ADV;ZCES-DEP-ENT;ZCES-DEP-ENTPLUS;ZCES-DEP-ESS;ZCES-PRO-HEALTH;ZCES-DAS-FED1;ZCES-DAS-FED2;ZCES-DAS-FED3');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec15 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Included_DAS_Package_SKUs2', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-PRO-OPTADV;ZCES-PRO-OPTESS;ZCES-PRO-DZX;ZCES-PRO-OPTENT;ZCES-PRO-POL-PRE;ZCES-PRO-PMI-PRE;ZCES-PRO-SVC-CUST');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec17 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZDX_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION');
        
        skuscs.add(rec1);
        skuscs.add(rec2);
        skuscs.add(rec3);
        skuscs.add(rec4);
        skuscs.add(rec5);
        skuscs.add(rec6);
        skuscs.add(rec7);
        skuscs.add(rec8);
        skuscs.add(rec9);
        skuscs.add(rec10);
        skuscs.add(rec11);
        skuscs.add(rec12);
        skuscs.add(rec13);
        skuscs.add(rec14);
        skuscs.add(rec15);
        skuscs.add(rec16);
        skuscs.add(rec17);
        insert skuscs;
        
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
        
        //Contact con = SB_TestCPQDataUtility.createContact(1,accList[0].Id)[0];
        //insert con;
        
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today()+365,system.today()-30,'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        piList[1].Partner_Role__c='Distributor';
        piList[0].Partner_Role__c='Distributor';
        insert piList;
        
        Test.startTest();
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
        SBQQ.TriggerControl.disable();        
        insert quoteRec;

        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Quote__c = quoteRec.id;
        quoteLine.SBQQ__Product__c = productList.get(0).id;
        quoteLineList.add(quoteLine);

        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
        quoteLine1.SBQQ__Quote__c = quoteRec.id;
        quoteLine1.SBQQ__Product__c = productList.get(1).id;
        quoteLineList.add(quoteLine1);

        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c();
        quoteLine2.SBQQ__Quote__c = quoteRec.id;
        quoteLine2.SBQQ__Product__c = productList.get(2).id;
        quoteLineList.add(quoteLine2);

        SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c();
        quoteLine3.SBQQ__Quote__c = quoteRec.id;
        quoteLine3.SBQQ__Product__c = productList.get(3).id;
        quoteLineList.add(quoteLine3);

        insert quoteLineList;
        
        //renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
        //update renewalOpp;
        
       
        
            ProvisioningRequestController.PRValidateWrapper prwrap = ProvisioningRequestController.validateForPRComponent(renewalOpp.id);
            prwrap.cloud ='Both';
            
            ProvisioningRequestController.CredentialDetails cred = new ProvisioningRequestController.CredentialDetails();
            cred.Type = 'SE';
            cred.IsUser = true;
            cred.RecID = userinfo.getUserId();
            cred.Index = 0;
            
            prwrap.credDetails =  new List<ProvisioningRequestController.CredentialDetails>{cred};
                
                
           	prwrap = ProvisioningRequestController.getALLPOCProducts(JSON.serialize(prwrap));
        
            
            List<ProvisioningRequestController.POCProductWrapper> pocProducts = new List<ProvisioningRequestController.POCProductWrapper>();
            pocProducts.add(new ProvisioningRequestController.POCProductWrapper(productList[0]));
            pocProducts.add(new ProvisioningRequestController.POCProductWrapper(productList[1]));
            pocProducts.add(new ProvisioningRequestController.POCProductWrapper(productList[2]));
            pocProducts.add(new ProvisioningRequestController.POCProductWrapper(productList[3]));
            
            prwrap.pocProducts = pocProducts;
            ProvisioningRequestController.createPRrecords(JSON.serialize(prwrap));
            
            //id prId = [Select id from Provisioning_Request__c limit 1].id;
            
            List<POC_Product__c> pocListToInsert = new List<POC_Product__c>();
            //ProvisioningRequestController.fillpocproductsFromTheQuote(pocListToInsert, prId ,renewalOpp.id, 'ZPA');
            
            Test.stoptest();
	    }
    }

    @isTest
    public static void testMethod3(){
    	user u1 = [select id from user where name !='Copado Integration Admin' and Profile.Name='System Administrator' and isActive=true limit 1];
        system.runas(u1){
            TriggerUtility.SkipAccTriggerExecuted();
            TriggerUtility.updateSENameFromAccountExecuted();
            TriggerUtility.prospectTypeUpdExecuted();
            triggerUtility.contactPatchManagerExecuted();
            triggerUtility.accTerritoryPatchExecuted();
            triggerUtility.oppPatchManagerAfterInsertExecuted();
            triggerUtility.oppPatchManagerAfterUpdateExecuted();
            Test.startTest();
            
            List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skuscs = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_CSB_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZSEC-WEB-ABA');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec2 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='CFW_ZPA_SKUs', SKU_Codes__c = 'ZFW-NG-WITH-LOG;ZIA-TRANS-BUNDLE;ZIA-ELA-BUNDLE');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec3 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Credit_SKUs', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec4 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='One_Time_SKU', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG6;ZCES-EDU-CREDIT;ZCES-EDU-LABCREDIT;ZCES-Onetime-ZPA-INT');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec5 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Recurring_SKU', SKU_Codes__c = 'ZCES-SUP-PREM;ZCES-SUP-PREM-SP;ZCES-SUP-TAMT;ZIA-BUS'); //Modified by Swathi: CR#1058
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec6 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_not_To_ADD', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec7 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='SKUs_to_SKIP_ACV', SKU_Codes__c = 'ZCR-BuyBack;Z-ZPA-BuyBack;Z-CFWCSB-PROMO;Z-CFWZPA-Credit;Z-CREDIT;ZCR-UPY4;ZCR-UPY5');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec8 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Uplift_SKUs', SKU_Codes__c = 'ZCR-UPY4;ZCR-UPY5');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec9 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-DAS-PKG0;ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG6;ZCES-EDU-CREDIT;ZCES-EDU-LABCREDIT;');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec10 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='One_Time_SKU1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST;ZCES-PQR');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec12 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Contract_Date', SKU_Codes__c = 'ZCES-PRO-SVC-CUST;ZCES-ABC');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec16 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date', SKU_Codes__c = 'ZCES-PRO-SVC-CUST;ZCES-ABE');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec13 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST;ZCES-ABE');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec14 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Included_DAS_Package_SKUs1', SKU_Codes__c = 'ZCES-DAS-PKG1;ZCES-DAS-PKG2;ZCES-DAS-PKG3;ZCES-DAS-PKG4;ZCES-DAS-PKG6;ZCES-DAS-PKG0;ZCES-DEP-ADV;ZCES-DEP-ENT;ZCES-DEP-ENTPLUS;ZCES-DEP-ESS;ZCES-PRO-HEALTH;ZCES-DAS-FED1;ZCES-DAS-FED2;ZCES-DAS-FED3');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec15 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='Included_DAS_Package_SKUs2', SKU_Codes__c = 'ZCES-PRO-SVC;ZCES-PRO-OPTADV;ZCES-PRO-OPTESS;ZCES-PRO-DZX;ZCES-PRO-OPTENT;ZCES-PRO-POL-PRE;ZCES-PRO-PMI-PRE;ZCES-PRO-SVC-CUST');
            SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec17 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZDX_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION');
            
            skuscs.add(rec1);
            skuscs.add(rec2);
            skuscs.add(rec3);
            skuscs.add(rec4);
            skuscs.add(rec5);
            skuscs.add(rec6);
            skuscs.add(rec7);
            skuscs.add(rec8);
            skuscs.add(rec9);
            skuscs.add(rec10);
            skuscs.add(rec11);
            skuscs.add(rec12);
            skuscs.add(rec13);
            skuscs.add(rec14);
            skuscs.add(rec15);
            skuscs.add(rec16);
            skuscs.add(rec17);
            insert skuscs;
            
            
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
            SBQQ.TriggerControl.disable();        
            insert quoteRec;

            List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
            quoteLine.SBQQ__Quote__c = quoteRec.id;
            quoteLine.SBQQ__Product__c = productList.get(0).id;
            quoteLineList.add(quoteLine);

            SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c();
            quoteLine1.SBQQ__Quote__c = quoteRec.id;
            quoteLine1.SBQQ__Product__c = productList.get(1).id;
            quoteLineList.add(quoteLine1);

            SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c();
            quoteLine2.SBQQ__Quote__c = quoteRec.id;
            quoteLine2.SBQQ__Product__c = productList.get(2).id;
            quoteLineList.add(quoteLine2);

            SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c();
            quoteLine3.SBQQ__Quote__c = quoteRec.id;
            quoteLine3.SBQQ__Product__c = productList.get(3).id;
            quoteLineList.add(quoteLine3);

            insert quoteLineList;
            
            //renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
            //update renewalOpp;
            
            
            
                ProvisioningRequestController.PRValidateWrapper prwrap = ProvisioningRequestController.validateForPRComponent(renewalOpp.id);
                prwrap.cloud ='Both';
                
                ProvisioningRequestController.CredentialDetails cred = new ProvisioningRequestController.CredentialDetails();
                cred.Type = 'SE';
                cred.IsUser = true;
                cred.RecID = userinfo.getUserId();
                cred.Index = 0;
                
                prwrap.credDetails =  new List<ProvisioningRequestController.CredentialDetails>{cred};
                    
                    
                prwrap = ProvisioningRequestController.getALLPOCProducts(JSON.serialize(prwrap));
            
                
                List<ProvisioningRequestController.POCProductWrapper> pocProducts = new List<ProvisioningRequestController.POCProductWrapper>();
                pocProducts.add(new ProvisioningRequestController.POCProductWrapper(productList[0]));
                pocProducts.add(new ProvisioningRequestController.POCProductWrapper(productList[1]));
                pocProducts.add(new ProvisioningRequestController.POCProductWrapper(productList[2]));
                pocProducts.add(new ProvisioningRequestController.POCProductWrapper(productList[3]));
                
                prwrap.pocProducts = pocProducts;
                prwrap.checkSKU = false;
                ProvisioningRequestController.createPRrecords(JSON.serialize(prwrap));
                
                id prId = [Select id from Provisioning_Request__c limit 1].id;
                
                List<POC_Product__c> pocListToInsert = new List<POC_Product__c>();
                //ProvisioningRequestController.fillpocproductsFromTheQuote(pocListToInsert, prId ,renewalOpp.id, 'ZPA');
                ProvisioningRequestController.booster();
                
            Test.stoptest();
        } 
    }
}