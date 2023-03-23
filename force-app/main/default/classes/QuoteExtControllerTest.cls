@isTest
public class QuoteExtControllerTest {
    
    /**
    Variables declaration
    */
    private static List<Account> accList = new List<Account>();
    private static PriceBook2 customPb;
    private static List<PricebookEntry> customPbEntryList=new List<PricebookEntry>();
    private static List<Product2> productList=new List<Product2>();
    private static Opportunity opty;
    private static SBQQ__Quote__c quoteRec;
    private static List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();

    /**
    *  Description: method to create test data
    *  @name      : createTestData
    **/
    @testSetup static void createTestData(){        
        accList = (SB_TestCPQDataUtility.createAccount(2));
        insert accList;
        
        productList = (SB_TestCPQDataUtility.createProduct(4,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[0].ProductCode = '';
        productList[0].Pricing_Meter__c = '';
        insert productList;
        
        customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;
        
        PricebookEntry customPbEntry = new PricebookEntry();
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[1].Id,48))[0]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[2].Id,50))[1]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[3].Id,55))[2]);
        insert customPbEntryList;

        opty = (SB_TestCPQDataUtility.createOpportunity(1, 'TestOpp', accList[0].Id))[0];
        insert opty;
        
        String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        quoteRec = (SB_TestCPQDataUtility.createQuote(1, opty.Id, accList[0].Id, accList[1].id, accList[1].id,quoteNewBusiness))[0];
        quoteRec.TCV__c = 1800;
        quoteRec.SBQQ__BillingFrequency__c = 'Custom Schedule';
        insert quoteRec;        
        
        SBQQ__QuoteLine__c q1 = new SBQQ__QuoteLine__c();
        Date qlDate = system.today() + (365*3);
        quoteLines = (SB_TestCPQDataUtility.createQuoteLine(4, quoteRec.Id, productList[0].Id, system.today(), qlDate,50));
        quoteLines[1].SBQQ__Product__c = productList[1].Id;
        quoteLines[2].SBQQ__Product__c = productList[2].Id;
        quoteLines[3].SBQQ__Product__c = productList[3].Id;
        insert quoteLines;
        
        quoteLines[1].SBQQ__RequiredBy__c = quoteLines[0].Id;
        quoteLines[2].SBQQ__RequiredBy__c = quoteLines[0].Id;
        quoteLines[3].SBQQ__RequiredBy__c = quoteLines[0].Id;
        update quoteLines;
    }

    @isTest static void testSubmitApproval() {
        SBQQ__Quote__c qtObj = [Select Id,SBQQ__BillingFrequency__c  from SBQQ__Quote__c Limit 1];
        
        Test.startTest();
        PageReference pageRef = Page.Submit_Quote;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj);
        
        QuoteExtController obj = new QuoteExtController(sc);
        obj.onSubmit();
        
        Billing_Schedule__c billingRec = new Billing_Schedule__c(Amount__c=1000,Quote__c = qtObj.Id,Billing_Date__c =Date.today().addDays(10));
        insert billingRec;
        
        obj = new QuoteExtController(sc);
        obj.onSubmit();
        obj.onRecall();
        Test.stopTest();
    }
    
    @isTest static void testPreviewApproval() {
        SBQQ__Quote__c qtObj = [Select Id,SBQQ__BillingFrequency__c  from SBQQ__Quote__c Limit 1];
        
        Test.startTest();
        PageReference pageRef = Page.Submit_Quote;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(qtObj);
        
        Billing_Schedule__c billingRec = new Billing_Schedule__c(Amount__c=1800,Quote__c = qtObj.Id,Billing_Date__c =Date.today().addDays(10));
        insert billingRec;
        
        QuoteExtController obj = new QuoteExtController(sc);
        obj.onCancel();
        obj.onPreview();
        Test.stopTest();
    }
}