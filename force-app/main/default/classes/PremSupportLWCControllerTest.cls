/**
* @description       : 
* @author            : rakshitha
* @group             : 
* @last modified on  : 07-29-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class PremSupportLWCControllerTest {
    private static List<Account> accList = new List<Account>();
    private static PriceBook2 customPb;
    private static List<PricebookEntry> customPbEntryList=new List<PricebookEntry>();
    private static List<Product2> productList=new List<Product2>();
    private static List<Opportunity> oppList = new List<Opportunity>();
    private static SBQQ__Quote__c quoteRec;
    private static List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
    private static List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
    private static List<Premium_support_range__c> psList = new List<Premium_support_range__c>();
    private static String oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Business_Open').getRecordTypeId();
    private static String quoteAmend = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
    
    @TestSetup
    static void createTestData(){
        accList = (SB_TestCPQDataUtility.createAccount(3));
        accList[0].Domain__c = 'testAccount1.com';
        insert accList;
        Test.startTest();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accList[0].Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList[0].Partner_Role__c='Reseller';
        insert piList;
        
        productList = (SB_TestCPQDataUtility.createProduct(7,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = '';
        productList[0].Pricing_Meter__c = '';
        productList[0].SKU_Type__c = 'PRE';
        productList[0].ProductCode = 'ZPA 123';
        productList[0].Product_Family__c = 'Bundle Platforms';
        productList[1].Name = 'Premium support';
        productList[1].Product_Family__c = 'Support';
        productList[1].ProductCode ='ZCES-SUP-PREM';
        productList[2].Name = 'Premium support plus';
        productList[2].Product_Family__c = 'Support';
        productList[2].ProductCode ='ZCES-SUP-PREM-PLUS';
        productList[3].Name = 'Premium Support Plus-16';
        productList[3].Product_Family__c = 'Support';
        productList[3].ProductCode ='ZCES-SUP-PREM-PLUS-16';
        productList[4].Product_Family__c = 'Bundle Platforms';
        productList[5].product_Family__c = 'Bundle Platforms';
        productList[6].Name = 'Premium Support Plus-24';
        productList[6].Product_Family__c = 'Support';
        productList[6].ProductCode ='ZCES-SUP-PREM-PLUS-24';
        insert productList;
        
        customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;
        
        PricebookEntry customPbEntry = new PricebookEntry();
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[1].Id,48))[0]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[2].Id,50))[1]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[3].Id,55))[2]);
        insert customPbEntryList;
        
        Opportunity oppRec = SB_TestCPQDataUtility.createOpportunity(1, 'TestOpp', accList[0].Id)[0];
        oppRec.StageName = '4 - Impact Validation';
        oppRec.Primary_Partner_Program__c = 'Summit - Discount';
        oppRec.Primary_Reseller_Partner__c=accList[1].Id;
        oppRec.RecordTypeId = oppRecType;
        insert oppRec;  
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = oppRec.Id,Partner_Type__c = 'Reseller',Account__c = accList[1].Id);
        insert OppPartner;
        
        SBQQ__Quote__c quoteRec = SB_TestCPQDataUtility.createQuote(1, oppRec.Id, oppRec.AccountId, oppRec.Primary_Reseller_Partner__c,oppRec.Primary_Reseller_Partner__c,quoteAmend)[0];
        quoteRec.Partner_Incentive__c = piList[0].Id;
        quoteRec.Partner_Program__c = 'Summit - Discount';
        quoteRec.Include_Value_Summary_Feature_Additions__c= true;
        quoteRec.Special_Terms__c='This is test terms';
        quoteRec.SBQQ__partner__c=accList[1].id;  
        quoteRec.Bill_to__c =accList[1].id;
        quoteRec.Line_Item_SKU_Approval__c ='ZPA-ZFED-MODERATE,ZCES-PRO-DZX,ZCES-PRO-SVC,ZCES-PRO-SVC,ZCES-DAS-PKG6,'+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+','+APTS_CONSTANTS.PROD_SKU_ZPA_PRO_LU+','+APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE_LU+',ZCES-EDU-CREDIT,ZCES-PRO-OPTESS,ZCES-PRO-OPTADV,ZCES-DEP-ADV,ZCES-DEP-ENT,ZCES-DAS-PKG0,ZCR-BuyBack,ZCES-EDU-CREDIT,Z-Credit,ZIA-ELA-BUNDLE,ZIA-SANDBOX,ZSEC-WEB-ABA,ZSEC-WEB-ABA,ZIA-TRANS-EDITION,';
        quoteRec.SBQQ__BillingFrequency__c = 'Custom Schedule';
        quoteRec.Price_List__c ='FY23 Editions Price List';
        
        SBQQ.TriggerControl.disable();        
        insert quoteRec;
        
        Date qlDate = system.today() + (365*3);
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines = (SB_TestCPQDataUtility.createQuoteLine(4, quoteRec.Id, productList[0].Id, system.today(), qlDate,50));
        quoteLines[1].SBQQ__Product__c = productList[1].Id;
        quoteLines[2].SBQQ__Product__c = productList[2].Id;
        quoteLines[3].SBQQ__Product__c = productList[3].Id;
        quoteLines[0].SBQQ__Number__c = 1;
        quoteLines[1].SBQQ__Number__c = 2;
        quoteLines[2].SBQQ__Number__c = 3;
        quoteLines[3].SBQQ__Number__c = 4;
        quoteLines[1].SBQQ__SpecialPrice__c = 100;
        insert quoteLines;
        
        psList.add(SB_TestCPQDataUtility.createPremiumSupportRange(0,30000,'8/5 TAM Coverage','Premium Support','ZCES-SUP-PREM'));
        psList.add(SB_TestCPQDataUtility.createPremiumSupportRange(30000,60000,'8/5 TAM Coverage','Premium Support Plus','ZCES-SUP-PREM-Plus'));
        psList.add(SB_TestCPQDataUtility.createPremiumSupportRange(40000,60000,'16/5 TAM Coverage','Premium Support Plus','ZCES-SUP-PREM-PLUS-16'));
        psList.add(SB_TestCPQDataUtility.createPremiumSupportRange(40000,60000,'24/5 TAM Coverage','Premium Support Plus','ZCES-SUP-PREM-PLUS-24'));
        psList[0].Price_List__c ='FY23 Editions Price List';
        psList[1].Price_List__c ='FY23 Editions Price List';
        psList[2].Price_List__c ='FY23 Editions Price List';
        psList[3].Price_List__c ='FY23 Editions Price List';
        insert psList;
        
        Year_Wise_Split__c yws = new Year_Wise_Split__c();
        yws.Quote__c =  quoteRec.Id;
        insert yws;
        
        List<Equipment_Request__c> requestList = new List<Equipment_Request__c>();
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=oppRec.Id, Localized_content__c=true,Product__c = productList[3].Id);
        Equipment_Request__c EquiReq1=new Equipment_Request__c(Opportunity__c=oppRec.Id, Localized_content__c=true,Product__c = productList[6].Id);
        Equipment_Request__c EquiReq2=new Equipment_Request__c(Opportunity__c=oppRec.Id, Localized_content__c=true);
        requestList.add(EquiReq);
        requestList.add(EquiReq1);
        requestList.add(EquiReq2);
        insert requestList;
         Test.stopTest();
    }
    @isTest static void getQuoteDetailTestWithoutPS() {
        
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Test.startTest();

        premSupportLWCController.getQuoteDetails(quoteRec.Id);
        Test.stopTest();
    }
    @isTest static void getQuoteDetailTestWithPS16() {
        Opportunity oppRec = [SELECT Id,Approved_PRE_SKUs_ER__c FROM Opportunity limit 1];
        oppRec.Approved_PRE_SKUs_ER__c = 'ZCES-SUP-PREM-PLUS-16';
        Test.startTest();
        update oppRec;
        
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        premSupportLWCController.getQuoteDetails(quoteRec.Id);
        Test.stopTest();
    }
    @isTest static void getQuoteDetailTestWithPS24() {
        Opportunity oppRec = [SELECT Id,Approved_PRE_SKUs_ER__c FROM Opportunity limit 1];
        oppRec.Approved_PRE_SKUs_ER__c = 'ZCES-SUP-PREM-PLUS-24';
        Test.startTest();
        update oppRec;
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Equipment_Request__c equipRec = [SELECT Id FROM Equipment_Request__c LIMIT 1];
        premSupportLWCController.getQuoteDetails(quoteRec.Id);
        premSupportLWCController.deleteYWS(quoteRec.Id);
        premSupportLWCController.sendPSApproval(equipRec.Id);
        Test.stopTest();
    }
}