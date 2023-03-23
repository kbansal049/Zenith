@isTest
public class DashBoardComponentTest {
    @isTest 
    static void testOrderMethod() 
    {
        DashBoardComponent.getTotalResponedToRepData();
        DashBoardComponent.getTotalOrdersPendingQR();
        DashBoardComponent.getTotalApprovedForProcessingData();
        DashBoardComponent.getTotalPOPendingForQCData();
        DashBoardComponent.getTotalPOPendingForReQRData();
        DashBoardComponent.getDataForExporting('PO Pending for QC');
        DashBoardComponent.getDataForExportingAll();
        DashBoardComponent.getNextResponedToRepData(0,10,'Ticket__c','desc');
        test.startTest();
        DashBoardComponent.getNextResponedToRepData(0,10,'Ticket__c','Asc');
        DashBoardComponent.getNextOrdersPendingQRData(0,10,'Ticket__c','desc');
        DashBoardComponent.getNextOrdersPendingQRData(0,10,'Ticket__c','Asc');
        DashBoardComponent.getNextApprovedForProcessingData(0,10,'Ticket__c','desc');
        DashBoardComponent.getNextApprovedForProcessingData(0,10,'Ticket__c','Asc');
        DashBoardComponent.getNextPOPendingForQCData(0,10,'Ticket__c','desc');
        DashBoardComponent.getNextPOPendingForQCData(0,10,'Ticket__c','Asc');
        DashBoardComponent.getNextPOPendingForReQRData(0,10,'Ticket__c','desc');
        DashBoardComponent.getNextPOPendingForReQRData(0,10,'Ticket__c','Asc');
        
        List<Account> accList = new List<Account>();
          PriceBook2 customPb;
    	  List<PricebookEntry> customPbEntryList=new List<PricebookEntry>();
    	  List<Product2> productList=new List<Product2>();
        
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
        renewalOpp.Netsuite_Sales_Order_Internal_ID__c = '234234';
        renewalOpp.Netsuite_Sales_Order_No__c = 'S234234';
        renewalOpp.Netsuite_Sales_Order_Number__c = 'S234234';
        insert renewalOpp;
        string json2 = '[{"Id":"' +String.valueof(renewalOpp.Id) + '","REASON":"<p>No reasog</p>"}]';
        system.debug(json2);
        DashBoardComponent.updateOpportunity(json2);
        test.stopTest();
    }
}