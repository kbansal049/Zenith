@isTest
public class AnnualBreakdownYWSUtilTest {
        
    //Variables declaration
    private static List<Account> accList = new List<Account>();
    private static PriceBook2 customPb;
    private static List<PricebookEntry> customPbEntryList=new List<PricebookEntry>();
    private static List<Product2> productList=new List<Product2>();
    private static Opportunity opty;
    private static SBQQ__Quote__c quoteRec;
    private static List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
    private static User usrCon;

    @testSetup 
    public static void createTestData(){
        usrCon = (SB_TestCPQDataUtility.createUsers(1, 'TestUserFN', 'TestUserLN', 'Core Sales'))[0];
        usrCon.Email = 'zscalerUser123@zscaler.com';
        insert usrCon;
        
        accList = (SB_TestCPQDataUtility.createAccount(2));
        insert accList;
        Test.startTest();        
        productList = (SB_TestCPQDataUtility.createProduct(6,'Zscaler Internet Access','ZIA-','Renewable','Per User Per Year'));
        productList[3].Name = 'Uplift for Year 4';
        productList[3].ProductCode = 'ZCR-UPY4';
        productList[3].SBQQ__SubscriptionType__c = 'One-time';
        productList[3].Pricing_Meter__c = '% of Net Price (Year 3 Price)';
        productList[4].Name = 'Uplift for Year 5';
        productList[4].ProductCode = 'ZCR-UPY5';
        productList[4].SBQQ__SubscriptionType__c = 'One-time';
        productList[4].Pricing_Meter__c = '% of Net Price (Year 4 Price)';
        productList[5].Name = 'ZWS Buy Back';
        productList[5].ProductCode = 'ZWS-BUYBACK-PROMO';
        productList[5].SBQQ__SubscriptionType__c = 'One-time';
        productList[5].Pricing_Meter__c = 'Per Unit (one-time)';
        //productList.add(pro);
        insert productList;
        
        customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;
        
        PricebookEntry customPbEntry = new PricebookEntry();
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[0].Id,600))[0]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[1].Id,48))[1]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[2].Id,50))[2]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[3].Id,55))[3]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[4].Id,75))[4]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[5].Id,45))[5]);
        system.debug('customPbEntryList'+customPbEntryList);
        insert customPbEntryList;

        opty = (SB_TestCPQDataUtility.createOpportunity(1, 'TestOpp', accList[0].Id))[0];
        insert opty;
        
        String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        quoteRec = (SB_TestCPQDataUtility.createQuote(1, opty.Id, accList[0].Id, accList[1].id, accList[1].id,quoteNewBusiness))[0];
        quoteRec.SBQQ__EndDate__c = Date.today().addYears(5).addDays(-1);
        quoteRec.SBQQ__SubscriptionTerm__c = 60;
        insert quoteRec;        
        
        SBQQ__QuoteLine__c q1 = new SBQQ__QuoteLine__c();
        Date qlEndDate = Date.today().addYears(5).addDays(-1);
        qlEndDate = qlEndDate.addMonths(3).addDays(10);

        quoteLines = (SB_TestCPQDataUtility.createQuoteLine(4, quoteRec.Id, productList[0].Id, system.today(), qlEndDate,50));
        quoteLines[0].SBQQ__SubscriptionTerm__c = 36;
        quoteLines[0].Finance_Term__c = 36;
        quoteLines[0].Is_Ramped__c = true;
        quoteLines[0].Ramp_Label__c = 'Ramp 1';
        quoteLines[0].Last_Ramp_Quantity__c = quoteLines[0].SBQQ__Quantity__c;
        quoteLines[1].SBQQ__Product__c = productList[3].Id;
        quoteLines[1].SBQQ__SubscriptionTerm__c = 12;
        quoteLines[1].Finance_Term__c = 12;
        quoteLines[2].SBQQ__Product__c = productList[4].Id;
        quoteLines[2].SBQQ__SubscriptionTerm__c = 12;
        quoteLines[2].Finance_Term__c = 12;
        quoteLines[3].SBQQ__EndDate__c = Date.today().addMonths(7); //For Error Quote
        quoteLines[3].SBQQ__SubscriptionTerm__c = 7;//For Error Quote
        quoteLines[3].Finance_Term__c = 7;//For Error Quote
        insert quoteLines;
        Test.stopTest();
    }

    @isTest 
    public static void testAnnualBreakdown() {
        Test.startTest();
        quoteRec = [SELECT Id, Name, Generate_Year_Wise_Split__c, Is_Year_Wise_Split_Data_Incorrect__c,SBQQ__StartDate__c, 
                    SBQQ__EndDate__c, Number_Of_Year_Wise_Split_Years__c, SBQQ__Opportunity2__c, SBQQ__Account__c,
                    SBQQ__Partner__c,Bill_to__c,SBQQ__Distributor__c,SBQQ__SubscriptionTerm__c, Annual_Breakdown_Error__c
                    FROM SBQQ__Quote__c LIMIT 1];
        quoteRec.Generate_Year_Wise_Split__c = true;
        quoteRec.Annual_Breakdown_Error__c = true;
        update quoteRec;
        Set<Id> quoteIdSet = new Set<ID>();
        quoteIdSet.add(quoteRec.Id);
        system.enqueuejob(new AnnualBreakdownYWSUtilQueueable(quoteIdSet));
        AnnualBreakdownYWSUtil.createCases(new Map<Id, SBQQ__Quote__c> { quoteRec.Id => quoteRec });
        AnnualBreakdownYWSUtil.getYearWiseSplitsList(quoteRec.Id);
        Test.stopTest();
    }
}