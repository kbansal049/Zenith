@isTest
public class DeceptionCaseCreationTest {

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
        
    
           DefaultData__c Dff = new DefaultData__c(name = 'PRCaseCreationDefault', Account_Id__c = acctTest.id, Category__c='Provisioning Request',Priority__c='Medium (P3)',Product__c='ZIA', Stage_Status__c='New',Type__c='Provisioning');
        Insert Dff;
        
      }
    
    
         @IsTest static void Method3(){
         
      
       
               PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'AMERICAS';
        salestert.Theater__c = 'Americas';
        salestert.Region__c = 'AMERICAS';
        salestert.Area__c = 'AMERICAS';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        salestert.Sales_Territory_Year__c = 'Current';
          
        insert salestert; 
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow',Sales_Territory__c=salestert.id);
        insert account;
          System.debug(account.Sales_Territory__c+'Sales_Territory__c=='+account.Sales_Territory__r.Theater__c);
     
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = System.label.Stage_3_Value_Impact_Validation,
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
        Zscaler_Cloud_ID__c zscal = new Zscaler_Cloud_ID__c();
        zscal.Account__c=account.Id;
        zscal.Org_Name__c='TestOrg';
        zscal.Name='Test88';
        Insert zscal;
        
        
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-TRANS-EDITION';
        prod1.ProductCode='ZIA-TRANS-EDITION';
        prod1.Product_Line__c='ZIA';
        //prod1.prod
        insert prod1;
        // prod1.
        
        Product2 prod3 = new Product2();
        prod3.Name='50,000 Additional URLs';
        prod3.ProductCode='ZIA-ADD50K-URLS';
        prod3.Product_Line__c='ZIA';
        insert prod3;
               POC_Product__c pocPr = new POC_Product__c();
         pocPr.Product__c = prod1.id;
         pocPr.Provisioning_Request__c = testPR.id;
         insert pocPr;
             
             
             List<Order> orderList = new List<order>();
         
        Order o = new Order(name = 'Test Order 1', AccountId = account.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        orderList.add(o);

        
        insert orderList;
        
              List<Contract_Detail__c> conDetail = new List<Contract_Detail__c>();
          
            
            Contract_Detail__c  contract = new Contract_Detail__c();
            contract.Name = 'Test Contract';
             contract.Sales_Order__c= orderList[0].id;
             contract.Account_Name__c = account.Id;  
             contract.Product_SKU__c= 'ZIA-TRANS-EDITION';
            contract.Quantity__c = 5000;
            contract.Contract_Detail_Status__c = 'Active';
            contract.Product_Name__c = prod1.Id;
            contract.Do_not_Aggregate__c = false;
            contract.Override_Contract_Detail_Status__c = false;
            contract.Start_Date__c = Date.today().addDays(-100);
            contract.End_Date__c = Date.today().addDays(100);
            contract.Amount_USD__c = 50000.00;
            contract.ZScaler_Product_Family__c = 'ZIA';
            contract.Is_Bundle_SKU__c = true;
            contract.Opportunity__c= opp.id;
            //conDetail.add(contract);
            
            insert contract;
             List<Id> lstid = new List<Id>();
             lstid.add(contract.id);
         test.startTest();
      	DeceptionCaseCreation.createDeceptionCase(lstid); 
        test.stopTest();
    }
    
    
         @IsTest static void Method4(){
         
      
                      PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'AMERICAS';
        salestert.Theater__c = 'Americas';
        salestert.Region__c = 'AMERICAS';
        salestert.Area__c = 'AMERICAS';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        salestert.Sales_Territory_Year__c = 'Current';
          
        insert salestert; 
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow',Sales_Territory__c=salestert.id);
        insert account;
          System.debug(account.Sales_Territory__c+'Sales_Territory__c=='+account.Sales_Territory__r.Theater__c);
     
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = System.label.Stage_7_Closed_Lost, Sub_Stage__c='Closed Lost',Primary_Competitor__c='Cisco',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
        Zscaler_Cloud_ID__c zscal = new Zscaler_Cloud_ID__c();
        zscal.Account__c=account.Id;
        zscal.Org_Name__c='TestOrg';
        zscal.Name='Test88';
        Insert zscal;
        
        
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-TRANS-EDITION';
        prod1.ProductCode='ZIA-TRANS-EDITION';
        prod1.Product_Line__c='ZIA';
       //prod1.prod
        insert prod1;
        // prod1.
        
        Product2 prod3 = new Product2();
        prod3.Name='50,000 Additional URLs';
        prod3.ProductCode='ZIA-ADD50K-URLS';
        prod3.Product_Line__c='ZIA';
        insert prod3;
               POC_Product__c pocPr = new POC_Product__c();
         pocPr.Product__c = prod1.id;
         pocPr.Provisioning_Request__c = testPR.id;
         insert pocPr;
             
             
             List<Order> orderList = new List<order>();
         
        Order o = new Order(name = 'Test Order 1', AccountId = account.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        orderList.add(o);

        
        insert orderList;
        
              List<Contract_Detail__c> conDetail = new List<Contract_Detail__c>();
          
            
            Contract_Detail__c  contract = new Contract_Detail__c();
            contract.Name = 'Test Contract';
             contract.Sales_Order__c= orderList[0].id;
             contract.Account_Name__c = account.Id;  
             //updated product details 
             contract.Product_SKU__c= 'ZPA-TRANS-EDITION';
            contract.Quantity__c = 5000;
            contract.Contract_Detail_Status__c = 'Active';
            contract.Product_Name__c = prod1.Id;
            contract.Do_not_Aggregate__c = false;
            contract.Override_Contract_Detail_Status__c = false;
            contract.Start_Date__c = Date.today().addDays(-100);
            contract.End_Date__c = Date.today().addDays(100);
            contract.Amount_USD__c = 50000.00;
            contract.ZScaler_Product_Family__c = 'ZPA';
            contract.Is_Bundle_SKU__c = true;
            contract.Opportunity__c= opp.id;
            //conDetail.add(contract);
            
            insert contract;
             List<Id> lstid = new List<Id>();
             lstid.add(contract.id);
             List<String> decprod = new List<String>();
             decprod.add(contract.Product_SKU__c); 
         test.startTest();
      	DeceptionCaseCreation.createDeceptionCase(lstid);
         DeceptionCaseCreation.createCase(opp.id ,contract,'Deception Case','Order',decprod,true);
        test.stopTest();
    }


    /* @IsTest static void Method5(){
         
      
       
               PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'AMERICAS';
        salestert.Theater__c = 'Americas';
        salestert.Region__c = 'AMERICAS';
        salestert.Area__c = 'AMERICAS';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        salestert.Sales_Territory_Year__c = 'Current';
          
        insert salestert; 
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow',Sales_Territory__c=salestert.id);
        insert account;
          System.debug(account.Sales_Territory__c+'Sales_Territory__c=='+account.Sales_Territory__r.Theater__c);
     
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = System.label.Stage_5_Contracts_Complete,Netsuite_Sales_Order_Number__c='Test Order 1',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
        Zscaler_Cloud_ID__c zscal = new Zscaler_Cloud_ID__c();
        zscal.Account__c=account.Id;
        zscal.Org_Name__c='TestOrg';
        zscal.Name='Test88';
        Insert zscal;
        
        
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-TRANS-EDITION';
        prod1.ProductCode='ZIA-TRANS-EDITION';
        prod1.Product_Line__c='ZIA';
        prod1.Provisioning_Product_Family__c='Bundles';
        //prod1.prod
        insert prod1;
        // prod1.
        
        Product2 prod3 = new Product2();
        prod3.Name='50,000 Additional URLs';
        prod3.ProductCode='ZIA-ADD50K-URLS';
        prod3.Product_Line__c='ZIA';
        prod3.Provisioning_Product_Family__c='Addon';
        insert prod3;
               POC_Product__c pocPr = new POC_Product__c();
         pocPr.Product__c = prod1.id;
         pocPr.Provisioning_Request__c = testPR.id;
         insert pocPr;
             
             
             List<Order> orderList = new List<order>();
         
        Order o = new Order(name = 'Test Order 1', AccountId = account.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        orderList.add(o);

        
        insert orderList;
        
              List<Contract_Detail__c> conDetail = new List<Contract_Detail__c>();
          
            
            Contract_Detail__c  contract = new Contract_Detail__c();
            contract.Name = 'Test Contract';
             contract.Sales_Order__c= orderList[0].id;
             contract.Account_Name__c = account.Id;  
             contract.Product_SKU__c= 'ZIA-TRANS-EDITION';
            contract.Quantity__c = 5000;
            contract.Contract_Detail_Status__c = 'Active';
            contract.Product_Name__c = prod1.Id;
            contract.Do_not_Aggregate__c = false;
            contract.Override_Contract_Detail_Status__c = false;
            contract.Start_Date__c = Date.today().addDays(-100);
            contract.End_Date__c = Date.today().addDays(100);
            contract.Amount_USD__c = 50000.00;
            contract.ZScaler_Product_Family__c = 'ZIA';
            contract.Is_Bundle_SKU__c = true;
           // contract.Opportunity__c= opp.id;
            //conDetail.add(contract);
            
            insert contract;
             List<Id> lstid = new List<Id>();
             lstid.add(contract.id);
         test.startTest();
      	DeceptionCaseCreation.createDeceptionCase(lstid); 
        test.stopTest();
    } */
}