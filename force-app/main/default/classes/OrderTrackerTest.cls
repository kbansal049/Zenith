@isTest
public class OrderTrackerTest {
    
    private static List<Account> accList = new List<Account>();
    private static PriceBook2 customPb;
    private static List<PricebookEntry> customPbEntryList=new List<PricebookEntry>();
    private static List<Product2> productList=new List<Product2>();
    private static List<Opportunity> oppList = new List<Opportunity>();
    private static SBQQ__Quote__c quoteRec;
    private static List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
    private static String oppClose = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Business_Close').getRecordTypeId();
    private static String oppRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
    private static String quoteRenewal = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
    
    @testSetup static void setup()
    {
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
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
        sk.Object_s_to_skip__c = 'Account;Opportunity;OpportunitySplit;SBQQ__Subscription__c';
        insert sk;
        
        //Inseret Custom settings
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
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec11 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Deployment_SKUs1', SKU_Codes__c = 'ZCES-PRO-SVC-CUST');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec12 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZPA_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZS-WFA-BUS-EDITION');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec13 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date', SKU_Codes__c = 'ZSC-SIP;ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZCES-SUP-PREM;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP');
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c rec14 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(name='ZIA_Contract_Date1', SKU_Codes__c = 'ZS-WFA-BUS-EDITION');

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
        insert skuscs;
        
        accList = (SB_TestCPQDataUtility.createAccount(3));
        accList[0].Domain__c = 'testAccount1.com';
        accList[0].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[1].Asset_SKU_Codes__c='ZIA-ELA-BUNDLE,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        accList[2].Asset_SKU_Codes__c='ZSEC-ATP,ZIA-TRANS-EDITION,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZSEC-ATP';
        insert accList;
        
        
       
        
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
        renewalOpp.Netsuite_Sales_Order_Internal_ID__c = '234234';
        renewalOpp.Netsuite_Sales_Order_No__c = 'S234234';
        renewalOpp.Netsuite_Sales_Order_Number__c = 'S234234';
        insert renewalOpp;
        
        quoteRec = SB_TestCPQDataUtility.createQuote(1, renewalOpp.Id, renewalOpp.AccountId, renewalOpp.Primary_Reseller_Partner__c,renewalOpp.Primary_Reseller_Partner__c,quoteRenewal)[0];
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
        SBQQ.TriggerControl.disable();        
        insert quoteRec;
        
        
        renewalOpp.SBQQ__PrimaryQuote__c = quoteRec.id;
        update renewalOpp;
        
        
        
        Customers__c customers = new Customers__c();
        customers.Name='test custom setting';
        customers.Latest_Number__c=0;
        insert customers;
        
        RegionMapping__c reg=new RegionMapping__c(Name='americas' ,Region__c='Americas');
        insert reg;
        
        
        
        
        Order_tracker__c testordertracker = new Order_Tracker__c(Email_Subject__c='test class email subject', Status__c='PO Pending for QC', Region__c='EMEA', 
                                                                 Order_Type__c='New', End_User__c='Test class end user',Proposal_for_initiating_QC__c=quoteRec.name);
        insert testordertracker;
        
        
        
        Email_tracker__c testemailtracker = new Email_Tracker__c(Email_Subject__c='test class email subject', Status__c='Completed', Email_Category__c='Decommissioning',Priority__c='Low');
        insert testemailtracker;
        Mail_Chain__c testmailchain1 = new Mail_chain__c(Email_Subject__c='test class email subject',to__c='test@gmail.com',cc__c='test@gmail.com',order_tracker__c = testordertracker.id);
        insert testmailchain1;
        Mail_Chain__c testmailchain2 = new Mail_chain__c(Email_Subject__c='test class email subject',to__c='test@gmail.com',cc__c='test@gmail.com',email_tracker__c = testemailtracker.id);
        insert testmailchain2;
        List<ContentVersion> conVersionList = new List<ContentVersion>();
        ContentVersion contentVersionFile1 = new ContentVersion();
        contentVersionFile1.ContentLocation = 'S';
        contentVersionFile1.FirstPublishLocationId=testmailchain1.Id;
        contentVersionFile1.PathOnClient =  'po1.pdf'; 
        contentVersionFile1.Title = 'po1.pdf'; 
        contentVersionFile1.VersionData = Blob.valueOf('JVBERi0xLjMKJdLIKMxLWMdv+SgQhWmsKyQ=');
        conVersionList.add(contentVersionFile1); 
        ContentVersion contentVersionFile2 = new ContentVersion();
        contentVersionFile2.ContentLocation = 'S';
        contentVersionFile2.FirstPublishLocationId=testmailchain2.Id;
        contentVersionFile2.PathOnClient =  'po1.pdf'; 
        contentVersionFile2.Title = 'po1.pdf'; 
        contentVersionFile2.VersionData = Blob.valueOf('JVBERi0xLjMKJdLIKMxLWMdv+SgQhWmsKyQ=');
        conVersionList.add(contentVersionFile2); 
        ContentVersion contentVersionFile3 = new ContentVersion();
        contentVersionFile3.ContentLocation = 'S';
        contentVersionFile3.FirstPublishLocationId=testordertracker.Id;
        contentVersionFile3.PathOnClient =  'po1.pdf'; 
        contentVersionFile3.Title = 'po1.pdf'; 
        contentVersionFile3.VersionData = Blob.valueOf('JVBERi0xLjMKJdLIKMxLWMdv+SgQhWmsKyQ=');
        conVersionList.add(contentVersionFile3); 
        insert conVersionList;
        
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        List<OpportunityLineItem> newOLI = (SB_TestCPQDataUtility.createOpptyLineItem(customPbEntryList,1,100,renewalOpp.id));
        List<SBQQ__QuoteLine__c> QLIs = [SELECT id,SBQQ__Product__c,ACV_New__c FROM SBQQ__QuoteLine__c LIMIT 4 ];
        for(OpportunityLineItem oli:newOLI){
            for(SBQQ__QuoteLine__c qli:QLIs){
                if(oli.Product2Id == qli.SBQQ__Product__c){
                    oli.SBQQ__QuoteLine__c = qli.id;
                    oli.ACV_New__c = qli.ACV_New__c;
                }
            }
        }
        INSERT newOLI;
        
        
       
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        
        insert TestDatafactory_Zscaler.liketolike();
        insert TestDatafactory_Zscaler.skusNSInteg();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        
        Account acc = APTS_TestUtil.createAccount ();
        Account acc1 = APTS_TestUtil.createAccount ();
        
        //Added by Swathi:CR#1058 Starts
        acc.NS_Vendor_ID__c = 'abc';
        update acc;
        //Added by Swathi:CR#1058 Ends
       
        Opportunity opp = APTS_TestUtil.createOpportunity (acc.Id,'');
		opp.Netsuite_Sales_Order_Internal_ID__c = '2342345';
        opp.Netsuite_Sales_Order_No__c = 'S2342345';
        opp.Netsuite_Sales_Order_Number__c = 'S2342345';
        update opp;

        ZscalerSetting__c setting = new ZscalerSetting__c(Name = 'NSSOUrl', Value__c = 'https://www.zscaler.test');
        insert setting;
        
        Partner testOpptyPartner = new Partner();
        testOpptyPartner.AccountToId = acc1.Id;
        testOpptyPartner.IsPrimary = true;
		testOpptyPartner.OpportunityId = opp.Id;
        //testOpptyPartner.Role = 'Vendor';
        insert testOpptyPartner;
        
        Order o = new Order(name = 'Test Order 1', AccountId = acc.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        insert o;
        
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = acc.Id;
        contractDetail1.Start_Date__c = Date.Today();
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 100;
        contractDetail1.Amount_USD__c = 100009; 
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        contractDetail1.List_Price__c = 100;
        contractDetail1.Discount__c = 10;
        contractDetail1.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail1.Sales_Order__c = o.Id;
        contractDetail1.Product_SKU__c = 'ZCES-SUP-PREM'; 
        contractDetail1.Contract_Detail_Status__c = 'Active';
        contractDetail1.ARR_Finance__c = 100;
        contractDetailList.add(contractDetail1);
        insert contractDetailList;
        
        List<Upgrade_SKU_Mapping_NS_Integration__c> upgradecs = new List<Upgrade_SKU_Mapping_NS_Integration__c>();
        upgradecs.add(new Upgrade_SKU_Mapping_NS_Integration__c(Name = 'rec1', IsrenewalorUpsell__c ='renewalupsell', Matching_SKU_On_Cart__c ='ZIA-PRO-BUNDLE', Matching_SKU_On_IB__c ='ZSC-SIP'));
        insert upgradecs;
    }
    
    @isTest 
    static void method1() {
        Order_tracker__c testordertracker = [select id from Order_tracker__c limit 1];
        
        test.startTest();
        OrderTrackerDashboard.updateOrderTrackerStatusFromReply(testordertracker.id,'PO Pending for QC');
        
        OrderTrackerDashboard.getNextOrderTrackers(1, 10, 'All', '', '', '', '', '','','All','','');
        
        test.stopTest();
    }
    
    @isTest 
    static void method2(){
        Order_tracker__c testordertracker = [select id from Order_tracker__c limit 1];
        test.startTest();
        OrderTrackerDashboard.getNextOrderTrackers(1, 10, 'All', 'PO Pending for QC', '', '', '', '','','RPA','','');       
        test.stopTest();
    }
    
    @isTest 
    static void method3(){
        Order_tracker__c testordertracker = [select id from Order_tracker__c limit 1];
        test.startTest();
        OrderTrackerDashboard.getNextOrderTrackers(1, 10, 'Assigned To Me', 'PO Pending for QC', '', '', '', '','','All','','');
        test.stopTest();
    }
    
    @isTest 
    static void method4(){
        Order_tracker__c testordertracker = [select id from Order_tracker__c limit 1];
        test.startTest();
        OrderTrackerDashboard.getNextOrderTrackers(1, 10, 'Assigned To Me', 'All', '', '', '', '','','All','','');
        test.stopTest();
    }
    
    @isTest
    static void method5(){
        Order_tracker__c testordertracker = [select id from Order_tracker__c limit 1];
        test.startTest();
        OrderTrackerDashboard.getMetadataPicklists();
        OrderTrackerDashboard.getOrderTracker(testordertracker.id);
        OrderTrackerDashboard.updateOrderTracker(testordertracker.id,'Updated','All SFDC Processes Updated');
        OrderTrackerDashboard.updateOrderTracker(testordertracker.id,'Updated','Attachment on NS and SF');
        OrderTrackerDashboard.updateOrderTracker(testordertracker.id,'Yes','Bot Auto QC done');
        OrderTrackerDashboard.updateOrderTracker(testordertracker.id,'Updated','Confirm if all dependent PRs are moved to Production');
        OrderTrackerDashboard.updateOrderTracker(testordertracker.id,'No','Bot Re QC Required');
        OrderTrackerDashboard.updateOrderTracker(testordertracker.id,'Processed/Billed','Status');
        OrderTrackerDashboard.updateOrderTracker(testordertracker.id,'Yes','ZA Updated');
        OrderTrackerDashboard.updateOrderTracker(testordertracker.id,'Annual','Billing Frequency');
        OrderTrackerDashboard.updateOrderTracker(testordertracker.id,'APJ','Region');
        test.stopTest();
    }
    
    @isTest
    static void method6(){
        Order_tracker__c testordertracker = [select id from Order_tracker__c limit 1];
        
        Email_Tracker__c testemailtracker = [select id from Email_Tracker__c limit 1];
        List<Map<String, Object>> files = new List<Map<String, Object>>();
        Map<string,object> filesMap = new Map<string,object>();
        filesMap.put('PathOnClient','po1.pdf');
        filesMap.put('Title','po1.pdf');
        filesMap.put('VersionData',Blob.valueOf('JVBERi0xLjMKJdLIKMxLWMdv+SgQhWmsKyQ='));
        files.add(filesMap);
        map<string,string> mailMap= new map<string,string>();
        mailMap.put('To','test@gmail.com');
        mailMap.put('CC','test@gmail.com');
        mailMap.put('BCC','test@gmail.com');
        mailMap.put('Subject','test subject');
        mailMap.put('Body','test body');
        test.startTest();
        OrderTrackerDashboard.editRemarksofOrderTracker(testordertracker.id,'test');
        OrderTrackerDashboard.editPartnerEndUserofOrderTracker(testordertracker.id,'test','Partner');
        OrderTrackerDashboard.editPartnerEndUserofOrderTracker(testordertracker.id,'test','End User');
        OrderTrackerDashboard.editPartnerEndUserofOrderTracker(testordertracker.id,'test','Proposal for initiating QC');
        OrderTrackerDashboard.editCurrencyNumberofOrderTracker(testordertracker.id,20.00,'ACV');
        OrderTrackerDashboard.editCurrencyNumberofOrderTracker(testordertracker.id,30.00,'PO Amount');
        OrderTrackerDashboard.editCurrencyNumberofOrderTracker(testordertracker.id,40.00,'1st Billing Amount');
        OrderTrackerDashboard.getEmailTemplate('Completed', testemailtracker.id, 'Email_Tracker__c');
        OrderTrackerDashboard.getEmailTemplate('PO Pending for Booking', testordertracker.id, 'Order_Tracker__c');
        OrderTrackerDashboard.getAllFieldsName('Email_Tracker__c');
        OrderTrackerDashboard.getRelatedAttachments(new Set<Id>{testordertracker.Id});
        OrderTrackerDashboard.sendMailMethod(mailMap,files,testordertracker.Id,'<CANbFOQF=kTOPpCcw2WFKhMwTcpXqT59mbH==-svwUV+H=+w4+w@mail.gmail.com>',false);
        test.stopTest();
    }
    
    @isTest
    static void method7(){
        Opportunity relatedOpp = [select name,Amount ,APTSCU_New_ACV__c,Type,
                                  Renewal_ACV__c,TCV__c  from Opportunity limit 1];
        
        
        Map<Id, opportunity> oppMap=new Map<Id,opportunity>();
        oppMap.put(relatedOpp.Id, relatedOpp);
        
        SBQQ__Quote__c quoteRecd = [Select Id,Name from SBQQ__Quote__c limit 1];
        
        test.startTest();  
        
        OrderTrackerHelper.bypassOrderTrackerTrigger = true;
        
        PO_Detail__c poDet = new PO_Detail__c();
        poDet.PO_Number__c = 'XYZZ';
        poDet.Source__c='EDI';
        poDet.Proposal_Quote_Number__c = quoteRecd.name;
        insert poDet;
        
        
        
        OrderTrackerHelper.bypassOrderTrackerTrigger = false;
        List<Order_Tracker__c> newOrderTracker = new List<Order_Tracker__c>();
        
        Order_tracker__c testordertracker = new Order_Tracker__c(Email_Subject__c='in test method subject', Status__c='PO Pending for QR', Region__c='EMEA',BOT_Email_Id__c='test@gmail.com',
                                                                 Order_Type__c='New', End_User__c='Test class end user',Proposal_for_initiating_QC__c=quoteRecd.name, PO_Detail__c = poDet.id);
        newOrderTracker.add(testordertracker);
        insert newOrderTracker;
        
        Mail_Chain__c mc  = new Mail_Chain__c();
        mc.Order_Tracker__c = testordertracker.id;
        mc.From__c = 'test@testmail.com';
        insert mc;
        
        OrderTrackerHelper.sendEmailToBot(newOrderTracker[0]);
        
        Order_Tracker__c testordertracker2 = [select id,name,Email_Subject__c,Proposal_for_initiating_QC__c from order_tracker__c where PO_Detail__c != null limit 1];
        testordertracker2.Proposal_for_initiating_QC__c=quoteRecd.name;
        update testordertracker2;
        OrderTrackerHelper.setOrderTrackersData(oppMap.keySet(), oppMap);
        
        
        OrderTrackerHelper.bypassOrderTrackerTrigger = false;
        testordertracker2.Status__c = 'Processed/Billed';
        update testordertracker2;
        
        test.stopTest();
    }
    
    @isTest
    static void method9(){
        Opportunity relatedOpp = [select name,Amount,APTSCU_New_ACV__c,Type,
                                  Renewal_ACV__c,TCV__c  from Opportunity limit 1];
        
        
        Map<Id, opportunity> oppMap=new Map<Id,opportunity>();
        oppMap.put(relatedOpp.Id, relatedOpp);
        
        SBQQ__Quote__c quoteRecd = [Select Id,Name from SBQQ__Quote__c limit 1];
        
        test.startTest();  
        
        OrderTrackerHelper.bypassOrderTrackerTrigger = true;
        
        PO_Detail__c poDet = new PO_Detail__c();
        poDet.PO_Number__c = 'XYZZ';
        poDet.Source__c='EDI';
        poDet.Proposal_Quote_Number__c = quoteRecd.name;
        insert poDet;
        
        
        
        OrderTrackerHelper.bypassOrderTrackerTrigger = false;
        List<Order_Tracker__c> newOrderTracker = new List<Order_Tracker__c>();
        
        Order_tracker__c testordertracker = new Order_Tracker__c(Email_Subject__c='in test method subject', Status__c='PO Pending for QR', Region__c='EMEA',BOT_Email_Id__c='test@gmail.com',
                                                                 Order_Type__c='New', End_User__c='Test class end user',Proposal_for_initiating_QC__c=quoteRecd.name, PO_Detail__c = poDet.id);
        newOrderTracker.add(testordertracker);
        insert newOrderTracker;
        
        Mail_Chain__c mc  = new Mail_Chain__c();
        mc.Order_Tracker__c = testordertracker.id;
        mc.From__c = 'test@testmail.com';
        insert mc;
        
        OrderTrackerHelper.sendEmailToBot(newOrderTracker[0]);
        
        Order_Tracker__c testordertracker2 = [select id,name,Email_Subject__c,Proposal_for_initiating_QC__c from order_tracker__c where PO_Detail__c != null limit 1];
        testordertracker2.Proposal_for_initiating_QC__c='test';
        update testordertracker2;
        OrderTrackerHelper.setOrderTrackersData(oppMap.keySet(), oppMap);
        
        
        OrderTrackerHelper.bypassOrderTrackerTrigger = false;
        testordertracker2.Status__c = 'Processed/Billed';
        update testordertracker2;
        
        test.stopTest();
    } 
    
    
    @isTest
    static void method8(){
        List<Opportunity> oppList =  [select name,Amount, APTSCU_New_ACV__c,Type,
                                  Renewal_ACV__c,TCV__c  from Opportunity];
        
        System.debug('---oppList ---'+oppList);
        
        Opportunity relatedOpp = [select name,Amount, APTSCU_New_ACV__c,Type,
                                  Renewal_ACV__c,TCV__c  from Opportunity where Name = 'test opportunity' limit 1];

        SBQQ__Quote__c quoteRecd = [Select Id,Name from SBQQ__Quote__c limit 1];
        
        test.startTest();  
                
        OrderTrackerHelper.bypassOrderTrackerTrigger = true;

        PO_Detail__c poDet = new PO_Detail__c();
        poDet.PO_Number__c = 'XYZZ';
        poDet.Proposal_Quote_Number__c = quoteRecd.name;
        poDet.Source__c='EDI';
        insert poDet;
        
        OrderTrackerHelper.bypassOrderTrackerTrigger = false;
        List<Order_Tracker__c> newOrderTracker = new List<Order_Tracker__c>();
        Order_tracker__c testordertracker = new Order_Tracker__c(Email_Subject__c='in test method subject', Status__c='PO Pending for QR', Region__c='EMEA',BOT_Email_Id__c='test@gmail.com',
                                                                 Order_Type__c='New', End_User__c='Test class end user', PO_Detail__c = poDet.Id);
        
        
        Order_tracker__c testordertracker1 = new Order_Tracker__c(Email_Subject__c='in test method subject', Status__c='PO Pending for QR', Region__c='EMEA',BOT_Email_Id__c='test@gmail.com',
                                                                 Order_Type__c='New', End_User__c='Test class end user',
                                                                 PO__c = 'XYZZ');
        
        
        
        
        newOrderTracker.add(testordertracker);
        newOrderTracker.add(testordertracker1);
        insert newOrderTracker;
        
        Mail_Chain__c mc  = new Mail_Chain__c();
        mc.Order_Tracker__c = testordertracker.id;
        mc.From__c = 'test@testmail.com';
        insert mc;
        
        OrderTrackerHelper.sendEmailToBot(newOrderTracker[0]);
        
        
        Order_Tracker__c testordertracker2 = [select id,name,Email_Subject__c,Proposal_for_initiating_QC__c from order_tracker__c where Opportunity__c != null and Opportunity__r.Netsuite_Sales_Order_Number__c != null and PO_Detail__c != null limit 1];
        update testordertracker2;
        
        
        Map<Id, opportunity> oppMap=new Map<Id,opportunity>();
        oppMap.put(relatedOpp.Id, relatedOpp);
        OrderTrackerHelper.setOrderTrackersData(oppMap.keySet(), oppMap);
        
        
        OrderTrackerHelper.bypassOrderTrackerTrigger = false;
        testordertracker2.Status__c = 'PO Pending for Booking';
        update testordertracker2;
        
        testordertracker2.Order_Type__c = 'Renewal';
        update testordertracker2;
        
        test.stopTest();
    }

        
    @isTest 
    static void method10(){
        Order_tracker__c testordertracker = [select id from Order_tracker__c limit 1];
        test.startTest();
        OrderTrackerDashboard.getNextOrderTrackers(1, 10, 'Assigned To Me', 'All', '', '', '', '','','RPA','','');
        OrderTrackerDashboard.getNextOrderTrackers(1, 10, 'Assigned To Me', 'All', '', '', '', '','','RPA','Test','');
        OrderTrackerDashboard.getNextOrderTrackers(1, 10, 'All', 'All', '', '', '', '','','RPA','Test','');
        test.stopTest();
    }
    
    @isTest 
    static void method11(){
        Order_tracker__c testordertracker = [select id from Order_tracker__c limit 1];
        test.startTest();
        OrderTrackerDashboard.getNextOrderTrackers(1, 10, 'Assigned To Me', 'PO Pending for QC', '', '', '', '','','RPA','','');
        OrderTrackerDashboard.getNextOrderTrackers(1, 10, 'All', 'All', '', '', '', '','','All','','');
        OrderTrackerDashboard.getNextOrderTrackers(1, 10, 'All', 'All', '', '', '', '','','RPA','','');
        test.stopTest();
    }

    @isTest 
    static void method12(){
        Order_tracker__c testordertracker = [select id from Order_tracker__c limit 1];
        Opportunity oppty = [SELECT Id,Name FROM Opportunity LIMIT 1];
        testordertracker.opportunity__c = oppty.Id;
        update testordertracker;
        test.startTest();
        OrderTrackerDashboard.sendMailNotificationMethod(testordertracker.Id);
        test.stopTest();
    }
    @isTest
    Static void method13(){
       	Order_tracker__c testordertracker = new Order_Tracker__c(Email_Subject__c='test class email subject', Status__c='PO Pending for QC', Region__c='EMEA', 
                                                                 Order_Type__c='New', End_User__c='Test class end user',Proposal_for_initiating_QC__c='test');
        insert testordertracker;
        Order_tracker__c testordertracker2 = new Order_Tracker__c(Email_Subject__c='test class email subject', Status__c='PO Pending for QC', Region__c='EMEA', 
                                                                 Order_Type__c='New', End_User__c='Test class end user',Proposal_for_initiating_QC__c= 'test');
        insert testordertracker2;
        String jsonString = '[{\"Id\":\"'+ testordertracker.ID + '\",\"primary\":true},{\"Id\":\"'+ testordertracker2.Id+ '\",\"primary\":false}]';
        OrderTrackerDashboard.mergeRecords(jsonString);
    }
    
        @isTest
    Static void method14(){
       	Order_tracker__c testordertracker = new Order_Tracker__c(Email_Subject__c='test class email subject', Status__c='PO Pending for QC', Region__c='EMEA', 
                                                                 Order_Type__c='New', End_User__c='Test class end user',Proposal_for_initiating_QC__c='test');
        insert testordertracker;
        Order_tracker__c testordertracker2 = new Order_Tracker__c(Email_Subject__c='test class email subject', Status__c='PO Pending for QC', Region__c='EMEA', 
                                                                 Order_Type__c='New', End_User__c='Test class end user',Proposal_for_initiating_QC__c= 'test');
        insert testordertracker2;

        testordertracker.Status__c = 'PO Pending With Sales';
        testordertracker2.Status__C = 'PO Pending For QR';
        update testordertracker;
        update testordertracker2; 
        testordertracker.Status__c = 'PO Pending For QR';
        testordertracker2.Status__C = 'PO Pending With Sales';
        update testordertracker;
        update testordertracker2; 
        testordertracker2.Status__C = 'PO Pending For Booking';
        update testordertracker2;
        testordertracker2.Status__C = 'PO Pending For QR';
        update testordertracker2;
        
        Test.startTest();
        testordertracker.Status__c = 'PO Pending With Sales';
        testordertracker.Time_In_PendingWithSales__c = 1;
        testordertracker2.Status__C = 'PO Pending For QR';
        testordertracker.Time_In_PendingWithQR__c = 1;
        update testordertracker;
        update testordertracker2; 
        testordertracker.Status__c = 'PO Pending For QR';
        testordertracker2.Status__C = 'PO Pending With Sales';
        update testordertracker;
        update testordertracker2; 
        testordertracker2.Status__C = 'PO Pending For Booking';
        testordertracker.Time_In_PendingForBooking__c = 1;
        update testordertracker2;
        testordertracker2.Status__C = 'PO Pending For QR';
        update testordertracker2;
        
        testordertracker2.Status__C = 'PO Pending For QC';
        testordertracker.Time_In_PendingForQC__c = 1;
        update testordertracker2;
        Test.stopTest();

        
    }
    
    @isTest
    Static void method15(){ 
           	Order_tracker__c testordertracker = new Order_Tracker__c(Email_Subject__c='test class email subject', Status__c='PO Pending for Booking', Region__c='EMEA', 
                                                                 Order_Type__c='New', End_User__c='Test class end user',Proposal_for_initiating_QC__c='test');
        insert testordertracker;
        Order_tracker__c testordertracker2 = new Order_Tracker__c(Email_Subject__c='test class email subject', Status__c='Processed/Billed', Region__c='EMEA', 
                                                                 Order_Type__c='New', End_User__c='Test class end user',Proposal_for_initiating_QC__c= 'test');
        insert testordertracker2;
        
        testordertracker.Proposal_for_initiating_QC__c = 'test2';
        update testordertracker;
    
    }


    @isTest
    Static void method16(){ 
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        acc.Partner_Type__c = 'Partner-Reseller';
        acc.Sales_Engineer__c = UserInfo.getUserId();
        insert acc;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User userOne = new User(LastName = 'User Account',
                                FirstName='Test',
                                Alias = 'tUAcc',
                                Email = 'test@test.com',
                                Username = 'test.testAccount@test.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US'
                               );
        insert userOne;

        List<Contact> ContactList= new List<Contact>();
        Contact con= new Contact(accountid = acc.Id,lastname = 'testContact1', email='testContact1@abc.com',Contacts_that_matter__c = false,Level_From_CIO__c = '1',Qualification_Status__c = 'Disqualified', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
        ContactList.add(con);
        
        Contact con1= new Contact(accountid = acc.Id,lastname = 'testContact1', email='testContact1@abc.com',Contacts_that_matter__c = false,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true,Send_CIO_Report__c='Send');
        ContactList.add(con1);
        
        insert ContactList;

        OrderTrackerHelper.SearchRecords('test@test.com','User',null);
    
    }
}