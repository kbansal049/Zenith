/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-05-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class QuoteLineTriggerServicesTest {
    
    private static List<Account> accList = new List<Account>();
    private static PriceBook2 customPb;
    private static List<PricebookEntry> customPbEntryList=new List<PricebookEntry>();
    private static List<Product2> productList=new List<Product2>();
    private static Opportunity opty;
    private static SBQQ__Quote__c quoteRec;
    private static List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
    
    
     @testSetup static void createTestData(){        
        accList = (SB_TestCPQDataUtility.createAccount(2));
        insert accList;
        Test.startTest();
        productList = (SB_TestCPQDataUtility.createProduct(6,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = '';
        productList[0].Pricing_Meter__c = '';
        productList[0].Enable_Ramp__c = true;
        productList[1].Enable_Ramp__c = true;
        productList[2].Enable_Ramp__c = true;
        productList[3].Enable_Ramp__c = true;
        productList[4].Name ='ZIA Transformation Edition';
        productList[4].ProductCode ='ZIA-Trans-Edition';
        productList[5].Name ='ZIA Transformation Edition';
        productList[5].ProductCode ='ZIA-TForm-Edition';
        insert productList;
        
        customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;
        
        PricebookEntry customPbEntry = new PricebookEntry();
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[1].Id,48))[0]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[2].Id,50))[1]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[3].Id,55))[2]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[4].Id,55))[3]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[5].Id,55))[4]);
        insert customPbEntryList;
        String recordType = Schema.SObjectType.CPQ_Generic_Object__c.getRecordTypeInfosByDeveloperName().get('Product_Upgrade').getRecordTypeId();
        
        CPQ_Generic_Object__c cpqObject = new CPQ_Generic_Object__c();
        cpqObject.Original_SKU__c = productList[4].Id;
        cpqObject.Upgrade_SKU__c = productList[5].Id;
        cpqObject.Price_List__c = 'FY23 Editions Price List';
        cpqObject.RecordTypeId = recordType;
        insert cpqObject;

        opty = (SB_TestCPQDataUtility.createOpportunity(1, 'TestOpp', accList[0].Id))[0];
        insert opty;
         
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = opty.Id,Partner_Type__c = 'Reseller',Account__c = accList[0].Id);
        insert OppPartner;
        
        Opportunity_Partner__c OppPartner1 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opty.Id,Partner_Type__c = 'Distributor',Account__c = accList[0].Id);
        insert OppPartner1;
        
        String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        quoteRec = (SB_TestCPQDataUtility.createQuote(1, opty.Id, accList[0].Id, accList[1].id, accList[1].id,quoteNewBusiness))[0];
        quoteRec.Partner_Program__c = 'Traditional';
        quoteRec.Price_List__c = 'FY21 Single Tier Price List';
        insert quoteRec;
         
        List<SBQQ__ProductOption__c> opList = new List<SBQQ__ProductOption__c>();
        SBQQ__ProductOption__c po = new SBQQ__ProductOption__c();
        po.SBQQ__ConfiguredSKU__c = productList[0].Id;
        po.SBQQ__OptionalSKU__c = productList[4].Id;
        po.SBQQ__Number__c =1;
        SBQQ__ProductOption__c po1 = new SBQQ__ProductOption__c();
        po1.SBQQ__ConfiguredSKU__c = productList[0].Id;
        po1.SBQQ__OptionalSKU__c = productList[5].Id;
        po1.SBQQ__Number__c =2;
        opList.add(po);
        opList.add(po1);
        insert opList;

        SBQQ__QuoteLine__c q1 = new SBQQ__QuoteLine__c();
        Date qlDate = system.today() + (365*3);
        quoteLines = (SB_TestCPQDataUtility.createQuoteLine(4, quoteRec.Id, productList[0].Id, system.today(), qlDate,50));
        quoteLines[1].SBQQ__Product__c = productList[1].Id;
        quoteLines[1].ACV_New__c = 10000; 
        quoteLines[2].SBQQ__Product__c = productList[2].Id;
        quoteLines[2].ACV_New__c = 15000;
        quoteLines[3].SBQQ__Product__c = productList[3].Id;
        quoteLines[3].ACV_New__c = 20000;
        insert quoteLines;
        
        quoteLines[1].SBQQ__RequiredBy__c = quoteLines[0].Id;
        quoteLines[2].SBQQ__RequiredBy__c = quoteLines[0].Id;
        quoteLines[3].SBQQ__RequiredBy__c = quoteLines[0].Id;
        update quoteLines;
        Test.stopTest();
    }
    
    /* @isTest static void Test1() {
        
        List<sObject> qlines = [SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c];
        Map<Id,sObject> qlinesMapNew = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]);
        Map<Id,sObject> qlinesMapOld = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]);

        Test.startTest();
        
            QuoteLineTriggerServices objQL = new QuoteLineTriggerServices(qlines,qlinesMapNew,qlinesMapOld);
            objQL.createYWSLines(qlines);
        Test.stopTest();
    } */
    
    
     /* @isTest static void Test2() {
        
        List<SBQQ__QuoteLine__c> qlines = [SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c LIMIT 1];
        Map<Id,sObject> qlinesMapNew = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]);
        Map<Id,sObject> qlinesMapOld = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]); 
        
        Test.startTest();
            QuoteLineTriggerServices objQL = new QuoteLineTriggerServices(qlines,qlinesMapNew,qlinesMapOld);
            objQL.deleteYWSLines(qlines);
        Test.stopTest();
    } */
    
    
     /* @isTest static void Test3() {
        
        List<SBQQ__QuoteLine__c> qlines = [SELECT Id,Name,SBQQ__Quote__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Quantity__c,SBQQ__NetTotal__c from SBQQ__QuoteLine__c LIMIT 1];
        Map<Id,sObject> qlinesMapNew = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Quantity__c,SBQQ__NetTotal__c from SBQQ__QuoteLine__c]);
        Map<Id,sObject> qlinesMapOld = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Quantity__c,SBQQ__NetTotal__c from SBQQ__QuoteLine__c]); 
        
        Test.startTest();
            QuoteLineTriggerServices objQL = new QuoteLineTriggerServices(qlines,qlinesMapNew,qlinesMapOld);
            objQL.checkUpdatedValues(qlines,(Map<Id, SBQQ__QuoteLine__c>) qlinesMapOld);
        Test.stopTest();
    } */
    
    
     @isTest static void Test4() {
       
        List<SBQQ__QuoteLine__c> qlines = [SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c LIMIT 1];
        Map<Id,sObject> qlinesMapNew = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]);
        Map<Id,sObject> qlinesMapOld = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]); 
        
        Test.startTest();
            QuoteLineTriggerServices objQL = new QuoteLineTriggerServices(qlines,qlinesMapNew,qlinesMapOld);
            objQL.setSortOrder(qlines);
        Test.stopTest();
    }
    
     @isTest static void Test5() {
        List<SBQQ__QuoteLine__c> qlines = [SELECT Id,Name,SBQQ__Quote__c,SBQQ__RenewedSubscription__c from SBQQ__QuoteLine__c LIMIT 1];
        Map<Id,sObject> qlinesMapNew = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]);
        Map<Id,sObject> qlinesMapOld = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]); 
        Test.startTest();
            TriggerUtility.blnQLInsert = true;
            QuoteLineTriggerServices objQL = new QuoteLineTriggerServices(qlines,qlinesMapNew,qlinesMapOld);
            objQL.resetAdditionalDiscountAmountForRenewals(qlines);
        Test.stopTest();
    }
    
     @isTest static void Test6() { 
       
        List<SBQQ__QuoteLine__c> qlines = [SELECT Id,Name,SBQQ__Quote__c,SBQQ__RenewedSubscription__c from SBQQ__QuoteLine__c LIMIT 1];
        Map<Id,sObject> qlinesMapNew = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]);
        Map<Id,sObject> qlinesMapOld = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]); 
        
        Test.startTest();
            TriggerUtility.blnQLInsert = true;
            QuoteLineTriggerServices objQL = new QuoteLineTriggerServices(qlines,qlinesMapNew,qlinesMapOld);
            objQL.resetRampFieldsOnRenewal(qlines);
        Test.stopTest();
    }

    /* @isTest static void testAnnualBreakdown() { 
        
        List<SBQQ__QuoteLine__c> qlines = [SELECT Id,Name,SBQQ__Quote__c,SBQQ__RenewedSubscription__c from SBQQ__QuoteLine__c LIMIT 1];
        Map<Id,sObject> qlinesMapNew = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]);
        Map<Id,sObject> qlinesMapOld = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]); 
        
        Test.startTest();
            TriggerUtility.blnQLInsert = true;
            QuoteLineTriggerServices objQL = new QuoteLineTriggerServices(qlines,qlinesMapNew,qlinesMapOld);
            objQL.createAnnualBreakdownLines(qlines);
            objQL.deleteAnnualBreakdownLines(qlines);
        Test.stopTest();
    } */
    
    @isTest static void testAnnualBreakdownYWS() { 
        
        List<SBQQ__QuoteLine__c> qlines = [SELECT Id,Name,SBQQ__Quote__c,SBQQ__RenewedSubscription__c from SBQQ__QuoteLine__c LIMIT 1];
        Map<Id,sObject> qlinesMapNew = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]);
        Map<Id,sObject> qlinesMapOld = new Map<ID, SBQQ__QuoteLine__c>([SELECT Id,Name,SBQQ__Quote__c from SBQQ__QuoteLine__c]); 
        
        Test.startTest();
            TriggerUtility.blnQLInsert = true;
            QuoteLineTriggerServices objQL = new QuoteLineTriggerServices(qlines,qlinesMapNew,qlinesMapOld);
            objQL.createAnnualBreakdownYWSLines(qlines);
            objQL.deleteAnnualBreakdownYWSLines(qlines);
        Test.stopTest();
    }
    @isTest static void upgradeProductTest() { 
       String opportunityRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
       Opportunity op = [SELECT Id FROM Opportunity limit 1];
       op.RecordTypeId= opportunityRecordType;
       update op;
       SBQQ__Quote__c quoteRec = [SELECT Id,Price_List__c FROM SBQQ__Quote__c LIMIT 1];
       quoteRec.Price_List__c = 'FY23 Editions Price List';
       update quoteRec;
       List<Product2> prd = [SELECT Id, Name,ProductCode FROM Product2 where ProductCode ='ZIA-Trans-Edition'] ;
       SBQQ__ProductOption__c po= [SELECT Id FROM SBQQ__ProductOption__c where SBQQ__OptionalSKU__c=:prd[0].Id];
       List<SBQQ__QuoteLine__c> qline = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c=null Limit 1];
       List<SBQQ__QuoteLine__c> q1 = new List<SBQQ__QuoteLine__c>();
        Date qlDate = system.today() + (365*3);
        Test.startTest();
        q1 = (SB_TestCPQDataUtility.createQuoteLine(1, quoteRec.Id, prd[0].Id, system.today(), qlDate,50));
        q1[0].SBQQ__RequiredBy__c = qline[0].Id;
        q1[0].SBQQ__ProductOption__c = po.Id;
        insert q1;
        Test.stopTest();
        SBQQ__QuoteLine__c newLine =[SELECT Id,SBQQ__Product__c,SBQQ__ProductCode__c FROM SBQQ__QuoteLine__c where Id =:q1[0].Id];
        System.assertEquals(newLine.SBQQ__ProductCode__c, 'ZIA-TForm-Edition','Upgrade the product');
    }
    @isTest static void upgradeProductQuoteTest() { 
        String opportunityRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
        Opportunity op = [SELECT Id FROM Opportunity limit 1];
        op.RecordTypeId= opportunityRecordType;
        update op;
        
        List<Product2> prd = [SELECT Id, Name,ProductCode FROM Product2 where ProductCode ='ZIA-Trans-Edition'] ;
        SBQQ__ProductOption__c po= [SELECT Id FROM SBQQ__ProductOption__c where SBQQ__OptionalSKU__c=:prd[0].Id];
        List<SBQQ__QuoteLine__c> qline = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c=null Limit 1];
        List<SBQQ__QuoteLine__c> q1 = new List<SBQQ__QuoteLine__c>();
        SBQQ__Quote__c quoteRec = [SELECT Id,Price_List__c FROM SBQQ__Quote__c LIMIT 1];
        Date qlDate = system.today() + (365*3);
         Test.startTest();
         q1 = (SB_TestCPQDataUtility.createQuoteLine(1, quoteRec.Id, prd[0].Id, system.today(), qlDate,50));
         q1[0].SBQQ__RequiredBy__c = qline[0].Id;
         q1[0].SBQQ__ProductOption__c = po.Id;
         insert q1;
         
         quoteRec.Price_List__c = 'FY23 Editions Price List';
         update quoteRec;
         Test.stopTest();
         SBQQ__Quote__c newLine =[SELECT Id,Price_List__c FROM SBQQ__Quote__c where Id =:quoteRec.Id];
         System.assertEquals(newLine.Price_List__c, 'FY23 Editions Price List');
     }
 
}