/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-21-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class SubscriptionPRGCreationTestClass {
    
	private static final Id subsPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
    
    @testSetup
    static void testData() {
        Id ProspectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_User').getRecordTypeId();
        
        List<PatchTeam__c> salesTerritoryList = new List<PatchTeam__c>();
        List<Patch__c> PatchList = new List<Patch__c>();
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Product2> prodList = new List<Product2>();
        
        PatchTeam__c pt1 = new PatchTeam__c();
        pt1.Name = 'Sales1';
        pt1.Theater__c = 'APAC';
        pt1.District__c = 'APAC';
        pt1.Region__c = 'APAC';
        pt1.Territory__c = 'SF Bay Area 1';
        pt1.Sales_Territory_Year__c = 'Current';
        salesTerritoryList.add(pt1);
        
        PatchTeam__c pt2 = new PatchTeam__c();
        pt2.Name = 'Sales2';
        pt2.Theater__c = 'EMEA';
        pt2.District__c = 'EMEA';
        pt2.Region__c = 'EMEA';
        pt2.Territory__c = 'SF Bay Area 1';
        pt2.Sales_Territory_Year__c = 'Current';
        salesTerritoryList.add(pt2);
        
        PatchTeam__c pt3 = new PatchTeam__c();
        pt3.Name = 'Sales3';
        pt3.Theater__c = 'Americas';
        pt3.District__c = 'AMERICAS';
        pt3.Region__c = 'AMERICAS';
        pt3.Territory__c = 'SF Bay Area 1';
        pt3.Sales_Territory_Year__c = 'Current';
        salesTerritoryList.add(pt3);
        
        insert salesTerritoryList;
        
        Patch__c patch1  = new Patch__c();
        patch1.Active__c = true;
        patch1.PatchTeam__c = pt1.Id ;
        patch1.PatchName__c = 'Test Patch1';
        PatchList.add(patch1);
        Patch__c patch2  = new Patch__c();
        patch2.Active__c = true;
        patch2.PatchTeam__c = pt2.Id ;
        patch2.PatchName__c = 'Test Patch2';
        PatchList.add(patch2);
        Patch__c patch3  = new Patch__c();
        patch3.Active__c = true;
        patch3.PatchTeam__c = pt3.Id ;
        patch3.PatchName__c = 'Test Patch3';
        PatchList.add(patch3);
        insert PatchList;
        
        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        acc1.Type= 'Prospect';
        if(ProspectRecordTypeId != null){
            acc1.RecordTypeId = ProspectRecordTypeId;        
        }
        acc1.Sales_Territory__c = pt1.Id;
        acc1.Patch__c = patch1.Id;
        accList.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'Test Account2';
        acc2.Type= 'Prospect';
        if(ProspectRecordTypeId != null){
            acc2.RecordTypeId = ProspectRecordTypeId;        
        }
        acc2.Sales_Territory__c = pt2.Id;
        acc2.Patch__c = patch2.Id;
        accList.add(acc2);
        
        Account acc3 = new Account();
        acc3.Name = 'Test Account3';
        acc3.Type= 'Prospect';
        if(ProspectRecordTypeId != null){
            acc3.RecordTypeId = ProspectRecordTypeId;        
        }
        acc3.Sales_Territory__c = pt3.Id;
        acc3.Patch__c = patch3.Id;
        accList.add(acc3);
        
        insert accList;
        
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-BUS-Edition';
        prod1.ProductCode='ZIA-BUS-Edition';
        prod1.Product_Line__c='ZIA';
        prod1.Provisioning_Product_Family__c='Bundles';
        prod1.Is_Applicable_for_POC__c = TRUE;
        prodList.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Name='ZIA-TRF-Edition';
        prod2.ProductCode='ZIA-TRF-Edition';
        prod2.Product_Line__c='Cross Platform';
        prod2.Provisioning_Product_Family__c='Bundles';
        prod2.Is_Applicable_for_POC__c = TRUE;
        prodList.add(prod2);
        insert prodList;
        
        Product_License__c pl = new Product_License__c();
        pl.Product__c = prod2.Id;
        pl.License_Product_Line__c = 'ZIA;ZPA;ZDX';
        pl.Provisioning_Contact_Type__c = 'BUSINESS_PRIMARY;ZDX_CONTACT;DECEPTION_CONTACT';
        insert pl;
        
        opportunity opp1 = new opportunity(Name = 'Test opportunity1', AccountId = acc1.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'New Business', Netsuite_Sales_Order_Number__c = 'Test Order 1');
        oppList.add(opp1);
        opportunity opp2 = new opportunity(Name = 'Test opportunity2', AccountId = acc2.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'New Business', Netsuite_Sales_Order_Number__c = 'Test Order 2');
        oppList.add(opp2);
        opportunity opp3 = new opportunity(Name = 'Test opportunity3', AccountId = acc3.Id, StageName = '4 - Impact Validation',Renewal_Rep_Forecast_Category__c = 'Commit',
                                           Contract_End_Date_New__c = System.Date.today() + 270,CloseDate = System.Date.today() + 250,Type = 'New Business');
        oppList.add(opp3);
        
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert oppList;
        TriggerHandler.Clearbypass('OpportunityTriggerHandler');
        
        List<Order_Tracker__c> trackerList = new List<Order_Tracker__c>();
        Order_Tracker__c ott1 = new Order_Tracker__c();
        ott1.Opportunity__c = opp1.id;
        trackerList.add(ott1);
        Order_Tracker__c ott2 = new Order_Tracker__c();
        ott2.Opportunity__c = opp2.id;
        trackerList.add(ott2);
        Order_Tracker__c ott3 = new Order_Tracker__c();
        ott3.Opportunity__c = opp3.id;
        trackerList.add(ott3);
        insert trackerList;
        
        List<Order> orderList = new List<order>();
         
        Order o = new Order(name = 'Test Order 1', AccountId = acc1.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        orderList.add(o);

        Order o1 = new Order(name = 'Test Order 2', AccountId = acc2.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24868', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        orderList.add(o1);
        
        Order o2 = new Order(name = 'Test Order 3', AccountId = acc2.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24866', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        orderList.add(o2);
        
        insert orderList;
        
        List<Provisioning_Group__c> prgList = new List<Provisioning_Group__c>();
        List<Provisioning_Product__c> prgProdList = new List<Provisioning_Product__c>();
        
        Provisioning_Group__c originalProvisioningGroup = new Provisioning_Group__c();
        originalProvisioningGroup.Product_Line__c ='ZIA';
        originalProvisioningGroup.Organization_Domain__c = 'testOrg.com';
        originalProvisioningGroup.RecordTypeId = subsPGRecordTypeId;
        originalProvisioningGroup.PG_for_Subscription__c = true;
        originalProvisioningGroup.Status__c = 'Provisioned';
        originalProvisioningGroup.Approval_Status__c = 'Approved';
        originalProvisioningGroup.PG_for_Subscription__c = TRUE;
        originalProvisioningGroup.Start_Date__c = Date.today().addDays(-20);
        originalProvisioningGroup.Opportunity__c = opp1.Id;
        originalProvisioningGroup.Product_Line__c = 'ZIA';
        prgList.add(originalProvisioningGroup);
        
        Provisioning_Group__c originalProvisioningGroup1 = new Provisioning_Group__c();
        originalProvisioningGroup1.Product_Line__c ='ZIA';
        originalProvisioningGroup1.Organization_Domain__c = 'testOrg.com';
        originalProvisioningGroup1.RecordTypeId = subsPGRecordTypeId;
        originalProvisioningGroup1.PG_for_Subscription__c = true;
        originalProvisioningGroup1.Status__c = 'Provisioned';
        originalProvisioningGroup1.Approval_Status__c = 'Approved';
        originalProvisioningGroup1.PG_for_Subscription__c = TRUE;
        originalProvisioningGroup1.Start_Date__c = Date.today().addDays(-20);
        originalProvisioningGroup1.Opportunity__c = opp2.Id;
        originalProvisioningGroup1.Product_Line__c = 'ZIA';
        prgList.add(originalProvisioningGroup1);
        
        Provisioning_Group__c originalProvisioningGroup2 = new Provisioning_Group__c();
        originalProvisioningGroup2.Product_Line__c ='ZIA';
        originalProvisioningGroup2.Organization_Domain__c = 'testOrg.com';
        originalProvisioningGroup2.RecordTypeId = subsPGRecordTypeId;
        originalProvisioningGroup2.PG_for_Subscription__c = true;
        originalProvisioningGroup2.Status__c = 'Provisioned';
        originalProvisioningGroup2.Approval_Status__c = 'Approved';
        originalProvisioningGroup2.PG_for_Subscription__c = TRUE;
        originalProvisioningGroup2.Start_Date__c = Date.today().addDays(-20);
        originalProvisioningGroup2.Opportunity__c = opp2.Id;
        originalProvisioningGroup2.Product_Line__c = 'ZIA';
        prgList.add(originalProvisioningGroup2);
        triggerhandler.bypass('ProvisioningGroupTriggerHandler');
        insert prgList;
        triggerhandler.clearbypass('ProvisioningGroupTriggerHandler');
        
       	Provisioning_Product__c povPrd2 = new Provisioning_Product__c();
        povPrd2.Product__c = prod1.id;
        povPrd2.Provisioning_Group__c = originalProvisioningGroup2.id;
        prgProdList.add(povPrd2);
        
        Provisioning_Product__c povPrd1 = new Provisioning_Product__c();
        povPrd1.Product__c = prod1.id;
        povPrd1.Provisioning_Group__c = originalProvisioningGroup1.id;
        prgProdList.add(povPrd1);
        
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = originalProvisioningGroup.id;
        prgProdList.add(povPrd);
        
        insert prgProdList;
        
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = acc1.Id;
        contractDetail1.Product_Name__c = prod1.Id;
        contractDetail1.Start_Date__c = Date.Today();
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 100;
        contractDetail1.Amount_USD__c = 1000;
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        contractDetail1.List_Price__c = 100;
        contractDetail1.Discount__c = 10;
        contractDetail1.Sales_Order__c = o.Id;
        contractDetail1.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail1);
        
        Contract_Detail__c contractDetail2 = new Contract_Detail__c();
        contractDetail2.Name = 'Migrate as is';
        contractDetail2.Account_Name__c = acc2.Id;
        contractDetail2.Product_Name__c = prod1.Id;
        contractDetail2.Start_Date__c = Date.Today();
        contractDetail2.End_Date__c = Date.Today() + 365;
        contractDetail2.Quantity__c = 100;
        contractDetail2.Amount_USD__c = 1000;
        contractDetail2.Contract_No__c = '100';
        contractDetail2.MRR_USD__c = 100;
        contractDetail2.List_Price__c = 100;
        contractDetail2.Discount__c = 10;
        contractDetail2.Sales_Order__c = o1.Id;
        contractDetail2.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail2);
        
        Contract_Detail__c contractDetail3 = new Contract_Detail__c();
        contractDetail3.Name = 'Migrate as is';
        contractDetail3.Account_Name__c = acc2.Id;
        contractDetail3.Product_Name__c = prod1.Id;
        contractDetail3.Start_Date__c = Date.Today();
        contractDetail3.End_Date__c = Date.Today() + 365;
        contractDetail3.Quantity__c = 100;
        contractDetail3.Amount_USD__c = 1000;
        contractDetail3.Contract_No__c = '100';
        contractDetail3.MRR_USD__c = 100;
        contractDetail3.List_Price__c = 100;
        contractDetail3.Discount__c = 10;
        contractDetail3.Sales_Order__c = o1.Id;
        contractDetail3.Contract_Detail_Status__c = 'Active';
        contractDetailList.add(contractDetail3);
        
        Contract_Detail__c contractDetail4 = new Contract_Detail__c();
        contractDetail4.Name = 'Migrate as is';
        contractDetail4.Account_Name__c = acc2.Id;
        contractDetail4.Product_Name__c = prod1.Id;
        contractDetail4.Start_Date__c = Date.Today();
        contractDetail4.End_Date__c = Date.Today() + 365;
        contractDetail4.Quantity__c = 100;
        contractDetail4.Amount_USD__c = 1000;
        contractDetail4.Contract_No__c = '100';
        contractDetail4.MRR_USD__c = 100;
        contractDetail4.List_Price__c = 100;
        contractDetail4.Discount__c = 10;
        contractDetail4.Sales_Order__c = o1.Id;
        contractDetail4.Contract_Detail_Status__c = 'Active';
        contractDetail4.Opportunity__c = opp1.Id;
        contractDetailList.add(contractDetail4);
        
        Contract_Detail__c contractDetail5 = new Contract_Detail__c();
        contractDetail5.Name = 'Migrate as is';
        contractDetail5.Account_Name__c = acc2.Id;
        contractDetail5.Product_Name__c = prod2.Id;
        contractDetail5.Start_Date__c = Date.Today();
        contractDetail5.End_Date__c = Date.Today() + 365;
        contractDetail5.Quantity__c = 100;
        contractDetail5.Amount_USD__c = 1000;
        contractDetail5.Contract_No__c = '100';
        contractDetail5.MRR_USD__c = 100;
        contractDetail5.List_Price__c = 100;
        contractDetail5.Discount__c = 10;
        contractDetail5.Sales_Order__c = o2.Id;
        contractDetail5.Contract_Detail_Status__c = 'Active';
        contractDetail5.Opportunity__c = opp1.Id;
        contractDetailList.add(contractDetail5);
        
        insert contractDetailList;

    }
    
    @isTest
    static void testForOneProdFamily() {
        List<Contract_Detail__c> conDetailList = [SELECT Id FROM Contract_Detail__c limit 1];
        List<Id> recIds = new List<Id>{conDetailList[0].Id};
        Test.startTest();
            SubscriptionPRGCreationClass.CreateSubscriptionPRG(recIds);
        Test.stopTest();   
    }
    
    @isTest
    static void testForMultiProdFamily() {
        List<Contract_Detail__c> conDetailList = [SELECT Id FROM Contract_Detail__c limit 1];
        List<Id> recIds = new List<Id>{conDetailList[0].Id};
        Test.startTest();
            SubscriptionPRGCreationClass.CreateSubscriptionPRG(recIds);
        Test.stopTest();   
    }
    
    @isTest
    static void testForMultiProd1Family() {
        List<Contract_Detail__c> conDetailList = [SELECT Id FROM Contract_Detail__c limit 1];
        List<Id> recIds = new List<Id>{conDetailList[0].Id};
        Test.startTest();
            SubscriptionPRGCreationClass.CreateSubscriptionPRG(recIds);
        Test.stopTest();   
    }
    
    @isTest
    static void testForMultiProd2Family() {
        List<Contract_Detail__c> conDetailList = [SELECT Id FROM Contract_Detail__c where Sales_Order__r.Name = 'Test Order 2'];
        List<Id> recIds = new List<Id>{conDetailList[0].Id};
        Test.startTest();
            SubscriptionPRGCreationClass.CreateSubscriptionPRG(recIds);
        Test.stopTest();   
    }
    
    @isTest
    static void testForMultiProd3Family() {
        List<Contract_Detail__c> conDetailList = [SELECT Id FROM Contract_Detail__c where Sales_Order__r.Name = 'Test Order 2'];
        List<Id> recIds = new List<Id>{conDetailList[0].Id};
        Test.startTest();
            SubscriptionPRGCreationClass.CreateSubscriptionPRG(recIds);
        Test.stopTest();   
    }
    
     @isTest
    static void testForCrossPlatformFamily() {
        List<Contract_Detail__c> conDetailList = [SELECT Id FROM Contract_Detail__c where Sales_Order__r.Name = 'Test Order 3'];
        List<Id> recIds = new List<Id>{conDetailList[0].Id};
        Test.startTest();
            SubscriptionPRGCreationClass.CreateSubscriptionPRG(recIds);
        Test.stopTest();   
    }
    
}