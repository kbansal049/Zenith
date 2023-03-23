/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class extendLinesControllerTest {
    
    /**
Variables declaration
*/
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
    
    /**
*  Description: method to create test data
*  @name      : createTestData
**/
    @testSetup static void createTestData(){    
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> listofSkuCustomSetting = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c zpaContractEndate = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        zpaContractEndate.Name='ZPA_Contract_Date';
        zpaContractEndate.SKU_Codes__c='ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZPA-Remote-PRE;ZS-WFA-BUS-EDITION;ZPA-FED-BUNDLE;ZPA-ZFED-MODERATE';
        listofSkuCustomSetting.add(zpaContractEndate);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaContractEndate = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaContractEndate.Name='ZIA_Contract_Date';
        ziaContractEndate.SKU_Codes__c='ZSC-SIP;ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP;ZIA-PRO-EDITION;ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION;ZIA-PRO-EDITION-LU;';
        listofSkuCustomSetting.add(ziaContractEndate);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c ziaContractEndate1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c();
        ziaContractEndate1.Name='ZIA_Contract_Date1';
        ziaContractEndate1.SKU_Codes__c='ZIA-BUS-EDITION-LU;ZIA-TRANS-EDITION-LU;ZIA-ELA-EDITION-LU;ZSC-RET-KIOSK;Z-O365-PRE;ZS-WFA-BUS-EDITION;EDU-ZIA-SVC-EDGE-BUS;ZIA-FED-BUNDLE;ZIA-ZFED-MODERATE';
        listofSkuCustomSetting.add(ziaContractEndate1);
        insert listofSkuCustomSetting;
        
        accList = (SB_TestCPQDataUtility.createAccount(3));
        accList[0].Domain__c = 'testAccount1.com';
        insert accList;
        
        //Contact con = SB_TestCPQDataUtility.createContact(1,accList[0].Id)[0];
        //insert con;
        
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[1].Id,true,system.today()+365,system.today()-30,'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        insert piList;
        
        productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = '';
        productList[0].Pricing_Meter__c = '';
        insert productList;
        
        customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;
        
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[1].Id,48))[0]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[2].Id,50))[1]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[3].Id,55))[2]);
        insert customPbEntryList;
        
        Opportunity renewalOpp = SB_TestCPQDataUtility.createOpportunity(1, 'TestOpp - Renewal', accList[0].Id)[0];
        renewalOpp.StageName = '4 - Impact Validation';
        renewalOpp.Primary_Partner_Program__c = 'Summit - Discount';
        renewalOpp.Primary_Reseller_Partner__c=accList[1].Id;
        renewalOpp.RecordTypeId = oppRenewal;
        insert renewalOpp;
        SBQQ.TriggerControl.disable();
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, renewalOpp.Id, renewalOpp.AccountId, renewalOpp.Primary_Reseller_Partner__c,renewalOpp.Primary_Reseller_Partner__c,quoteRenewal)[0];
        quoteRec.Partner_Incentive__c = piList[1].Id;
        quoteRec.Partner_Program__c = 'Summit - Discount';
        quoteRec.RecordTypeId = quoteRenewal;
        insert quoteRec;
        
        Date qlDate = system.today() + (365*3);
        List<SBQQ__QuoteLine__c> renewalQL = new List<SBQQ__QuoteLine__c>();
        renewalQL = (SB_TestCPQDataUtility.createQuoteLine(4, quoteRec.Id, productList[0].Id, system.today(), qlDate,50));
        renewalQL[1].SBQQ__Product__c = productList[1].Id;
        renewalQL[2].SBQQ__Product__c = productList[2].Id;
        renewalQL[3].SBQQ__Product__c = productList[3].Id;
        renewalQL[0].SBQQ__Number__c = 1;
        renewalQL[1].SBQQ__Number__c = 2;
        renewalQL[2].SBQQ__Number__c = 3;
        renewalQL[3].SBQQ__Number__c = 4;
        insert renewalQL;
        
        renewalQL[0].SBQQ__Existing__c = true;
        renewalQL[1].SBQQ__RequiredBy__c = renewalQL[0].Id;
        renewalQL[2].SBQQ__RequiredBy__c = renewalQL[0].Id;
        renewalQL[3].SBQQ__RequiredBy__c = renewalQL[0].Id;
        update renewalQL;
        SBQQ.TriggerControl.enable();
        system.debug('renewalQL'+renewalQL);
    }
    
    @isTest static void testExtendLines() {        
        Test.startTest();
        List<String> quoteLineList = new List<String>();
        SBQQ__Quote__c quoteRec = [Select id,RecordTypeId from SBQQ__Quote__c];        
        
        extendLinesController.getAllProducts(quoteRec.Id);
        
        SBQQ__QuoteLine__c ql = [Select id,SBQQ__RequiredBy__c,SBQQ__Quote__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Quantity__c,SBQQ__NetPrice__c,SBQQ__ProductCode__c from SBQQ__QuoteLine__c where SBQQ__RequiredBy__c != null and SBQQ__Quote__c=:quoteRec.Id LIMIT 1];
        
        extendLinesController.getExtendedLinesForAddOn(quoteRec.Id,ql.Id);
        String finalKey=ql.SBQQ__ProductCode__c+ql.Id;
        String qlId = ql.Id;
        String segment = '[{"Segment":"Existing","StartDate":"2023-08-31","EndDate":"2023-08-31","Qty":250,"startDateDisable":true,"disableExistingData":true,"uniqueKey":"'+finalKey+'","sfdcId":"'+qlId+'"},{"Segment":"New 2","StartDate":"2023-09-01","EndDate":"2024-08-31","Qty":250,"disableExistingData":false,"startDateDisable":false,"uniqueKey":null,"sfdcId":null}]';
        extendLinesController.createQuoteLines(String.valueOf(quoteRec.Id),quoteLineList,segment,finalKey,false,false,ql.Id);
        segment = '[{"Segment":"Existing","StartDate":"2023-08-31","EndDate":"2023-08-31","Qty":250,"startDateDisable":true,"disableExistingData":true,"uniqueKey":"'+finalKey+'","sfdcId":"'+qlId+'"}]';
        extendLinesController.createQuoteLines(String.valueOf(quoteRec.Id),quoteLineList,segment,finalKey,false,false,ql.Id);
        extendLinesController.SegmentWrapper Wrp = new extendLinesController.SegmentWrapper( 'New 3','2021-07-16','2023-10-15','500',false,'','',false,'');
        System.assertNotEquals(null,Wrp);
        Test.stopTest();
    }
    
    @isTest static void testContractSubs() {        
        
        SBQQ__Quote__c quoteRec = [Select id,SBQQ__Account__c,SBQQ__Partner__c,Bill_to__c,Partner_Incentive__c from SBQQ__Quote__c]; 
        List<SBQQ__QuoteLine__c> qtLine = [Select id,SBQQ__Number__c,SBQQ__RequiredBy__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quoteRec.Id order by SBQQ__Number__c DESC];
        Partner_Incentive__c pi = [Select id,partner_program__c from Partner_Incentive__c where id=:quoteRec.Partner_Incentive__c];
        List<Product2> productList = new List<Product2>([Select id from Product2 limit 3]);
        system.debug('1st query'+limits.getQueries());
        Contract contractRec = (SB_TestCPQDataUtility.createContracts(String.valueOf(quoteRec.SBQQ__Account__c), String.valueOf(quoteRec.SBQQ__Partner__c), String.valueOf(quoteRec.Bill_to__c),pi,1))[0];
        contractRec.Status = 'Draft';
        Test.startTest();
        SBQQ.TriggerControl.disable();
        insert contractRec;  
        SBQQ.TriggerControl.enable();
        system.debug('2nd query'+limits.getQueries());
        List<SBQQ__Subscription__c> subscriptionList = SB_TestCPQDataUtility.createSubscriptions(contractRec,productList);
        subscriptionList[0].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[1].SBQQ__RenewalQuantity__c = 96;
        subscriptionList[2].SBQQ__RenewalQuantity__c = 96;
        SBQQ.TriggerControl.disable();
        insert subscriptionList;
        SBQQ.TriggerControl.enable();
        
        subscriptionList[1].Required_By_Lookup__c = subscriptionList[0].Id;
        subscriptionList[2].Required_By_Lookup__c = subscriptionList[0].Id;
        system.debug('3rd query'+limits.getQueries());
        SBQQ.TriggerControl.disable();
        update subscriptionList;
        SBQQ.TriggerControl.enable(); 
        
        
        extendLinesController.getAllActiveSubscriptions(quoteRec.Id);
        //extendLinesController.createQuoteLinesFromSubscription(quoteRec.Id,subscriptionList);
        
        qtLine[0].SBQQ__RenewedSubscription__c = subscriptionList[0].Id;
        qtLine[1].SBQQ__RenewedSubscription__c = subscriptionList[1].Id;
        qtLine[2].SBQQ__RenewedSubscription__c = subscriptionList[2].Id;
        SBQQ.TriggerControl.disable();
        update qtLine;
        system.debug('4th query'+limits.getQueries());
        SBQQ.TriggerControl.enable();
        
        system.debug('5th query'+limits.getQueries());
        extendLinesController.createQuoteLinesFromSubscription(quoteRec.Id,subscriptionList);
        Test.stopTest();
    }
}