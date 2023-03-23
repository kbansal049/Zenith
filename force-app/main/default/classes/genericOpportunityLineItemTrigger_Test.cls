@isTest
public class genericOpportunityLineItemTrigger_Test {
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
        productList[0].Enable_Ramp__c = true;
        productList[1].Enable_Ramp__c = true;
        productList[2].Enable_Ramp__c = true;
        productList[3].Enable_Ramp__c = true;
        productList[2].Pricing_Meter__c='Per Unit (one-time)';
        insert productList;
        
        customPb = (SB_TestCPQDataUtility.createCustomPriceBooks(1))[0];
        insert customPb;
        
        PricebookEntry customPbEntry = new PricebookEntry();
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[1].Id,48))[0]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[2].Id,50))[1]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[3].Id,55))[2]);
        customPbEntryList.add((SB_TestCPQDataUtility.createPriceBookEntry(1,productList[0].Id,88))[3]);
        insert customPbEntryList;

        opty = (SB_TestCPQDataUtility.createOpportunity(1, 'TestOpp', accList[0].Id))[0];
        opty.pricebook2id = customPb.id;
        INSERT opty;
        
        String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        quoteRec = (SB_TestCPQDataUtility.createQuote(1, opty.Id, accList[0].Id, accList[1].id, accList[1].id,quoteNewBusiness))[0];
        insert quoteRec;        
        
        SBQQ__QuoteLine__c q1 = new SBQQ__QuoteLine__c();
        Date qlDate = system.today() + (365*3);
        quoteLines = (SB_TestCPQDataUtility.createQuoteLine(4, quoteRec.Id, productList[0].Id, system.today(), qlDate,50));
        quoteLines[1].SBQQ__Product__c = productList[1].Id;
        quoteLines[2].SBQQ__Product__c = productList[2].Id;
        quoteLines[3].SBQQ__Product__c = productList[3].Id;
        
        quoteLines[1].ACV_new__c = 100;
        quoteLines[2].ACV_new__c = 200;
        quoteLines[3].ACV_new__c = 300;
        quoteLines[0].ACV_new__c = 400;
        
        insert quoteLines;
        
        quoteLines[1].SBQQ__RequiredBy__c = quoteLines[0].Id;
        quoteLines[2].SBQQ__RequiredBy__c = quoteLines[0].Id;
        quoteLines[3].SBQQ__RequiredBy__c = quoteLines[0].Id;
        update quoteLines;
    }

    @isTest static void testSet_OLISalePrice() {
        
        Test.startTest();
            Opportunity oppty = [SELECT id,pricebook2id FROM Opportunity LIMIT 1];
        PriceBook2 customPb =[SELECT id FROM PriceBook2 WHERE IsActive=true AND IsStandard=false];
        system.assert(customPb.id!=null);
        oppty.Pricebook2Id = customPb.id;
        UPDATE oppty;
         system.assert(oppty.Pricebook2Id!=null);
        List<PricebookEntry> pbeList = [SELECT id,Product2Id,Pricebook2Id FROM PricebookEntry  WHERE Pricebook2Id =:oppty.Pricebook2Id];
        system.assert(pbeList.size()>1);
        List<OpportunityLineItem> newOLI = (SB_TestCPQDataUtility.createOpptyLineItem(pbeList,1,100,oppty.id));
       
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
        Test.stopTest();
    }
     @isTest static void testSet_OLISalePriceUpdate() {
        
        Test.startTest();
            Opportunity oppty = [SELECT id,pricebook2id FROM Opportunity LIMIT 1];
        PriceBook2 customPb =[SELECT id FROM PriceBook2 WHERE IsActive=true AND IsStandard=false];
        system.assert(customPb.id!=null);
        oppty.Pricebook2Id = customPb.id;
        UPDATE oppty;
         system.assert(oppty.Pricebook2Id!=null);
        List<PricebookEntry> pbeList = [SELECT id,Product2Id,Pricebook2Id FROM PricebookEntry  WHERE Pricebook2Id =:oppty.Pricebook2Id];
        system.assert(pbeList.size()>1);
        List<OpportunityLineItem> newOLI = (SB_TestCPQDataUtility.createOpptyLineItem(pbeList,1,100,oppty.id));
       
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
          for(OpportunityLineItem oli:newOLI){
              oli.ACV_New__c =200;
          }
         UPDATE newOLI; 
         DELETE newOLI;
        Test.stopTest();
    }
}