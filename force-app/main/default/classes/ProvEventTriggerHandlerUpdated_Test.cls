@isTest
public class ProvEventTriggerHandlerUpdated_Test {
    
     @IsTest static void Method1(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow');
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '  1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
        //  pg.RecordTypeId= recTypeId;
        insert pg;
        
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-BUS-Edition';
        prod1.ProductCode='ZIA-BUS-Edition';
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
        
        
        Licenses__c lc = new Licenses__c();
        lc.Name = 'URL Filtering';
        lc.Is_JIRA_Ticket_Needed__c = true;
        lc.POC_Quantity__c ='100';
        lc.License_Code__c = 'C_CASB';
        lc.Product__c =prod1.Id;
        insert lc;
        
        Licenses__c lc1 = new Licenses__c();
        lc1.Name = 'URL Filtering';
        lc1.Is_JIRA_Ticket_Needed__c = true;
        lc1.POC_Quantity__c ='100';
        lc1.License_Code__c = 'C_DLP';
        lc1.Product__c =prod3.Id;
        insert lc1;
        Product_License__c prdLic = new Product_License__c();
        prdLic.License__c = lc.id;
         prdLic.Product__c =prod3.id;
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
        prdLic1.License__c = lc1.id;
        insert prdLic1;
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = pg.id;
        insert povPrd;
		 Provisioning_Product__c povPrd1 = new Provisioning_Product__c();
        povPrd1.Product__c = prod3.id;
        povPrd1.Provisioning_Group__c = pg.id;
        insert povPrd1;
        
        
        
        test.startTest();
         Provisioning_Event__e pvt = new Provisioning_Event__e();
         pvt.PG_ID__c =pg.id;
         Eventbus.publish(pvt);
         pg.RecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Trial').getRecordTypeId();
         pg.PG_Request_Type__c ='Create';
         update pg;
          Provisioning_Event__e pvt1 = new Provisioning_Event__e();
         pvt1.PG_ID__c =pg.id;
         Eventbus.publish(pvt1);
         
         pg.PG_Request_Type__c ='Update';
         update pg;
     Eventbus.publish(pvt1);
           pg.PG_Request_Type__c ='Replace';
         update pg;
     Eventbus.publish(pvt1);

        test.stopTest();
    }

     @IsTest static void Method2(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow');
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '  1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
        //  pg.RecordTypeId= recTypeId;
        insert pg;
        
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-BUS-Edition';
        prod1.ProductCode='ZIA-BUS-Edition';
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
        
        
        Licenses__c lc = new Licenses__c();
        lc.Name = 'URL Filtering';
        lc.Is_JIRA_Ticket_Needed__c = true;
        lc.POC_Quantity__c ='100';
        lc.License_Code__c = 'C_CASB';
        lc.Product__c =prod1.Id;
        insert lc;
        
        Licenses__c lc1 = new Licenses__c();
        lc1.Name = 'URL Filtering';
        lc1.Is_JIRA_Ticket_Needed__c = true;
        lc1.POC_Quantity__c ='100';
        lc1.License_Code__c = 'C_DLP';
        lc1.Product__c =prod3.Id;
        insert lc1;
        Product_License__c prdLic = new Product_License__c();
        prdLic.License__c = lc.id;
         prdLic.Product__c =prod3.id;
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
        prdLic1.License__c = lc1.id;
        insert prdLic1;
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = pg.id;
        insert povPrd;
		 Provisioning_Product__c povPrd1 = new Provisioning_Product__c();
        povPrd1.Product__c = prod3.id;
        povPrd1.Provisioning_Group__c = pg.id;
        insert povPrd1;
        
        
        
        test.startTest();
         Provisioning_Event__e pvt = new Provisioning_Event__e();
         pvt.PG_ID__c =pg.id;
         Eventbus.publish(pvt);
        
        test.stopTest();
    }
   
	
    @IsTest static void Method3(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow');
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '  1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
          pg.RecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Trial').getRecordTypeId();
         pg.PG_Request_Type__c ='Create';
        //  pg.RecordTypeId= recTypeId;
        insert pg;
        
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-BUS-Edition';
        prod1.ProductCode='ZIA-BUS-Edition';
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
        
        
        Licenses__c lc = new Licenses__c();
        lc.Name = 'URL Filtering';
        lc.Is_JIRA_Ticket_Needed__c = true;
        lc.POC_Quantity__c ='100';
        lc.License_Code__c = 'C_CASB';
        lc.Product__c =prod1.Id;
        insert lc;
        
        Licenses__c lc1 = new Licenses__c();
        lc1.Name = 'URL Filtering';
        lc1.Is_JIRA_Ticket_Needed__c = true;
        lc1.POC_Quantity__c ='100';
        lc1.License_Code__c = 'C_DLP';
        lc1.Product__c =prod3.Id;
        insert lc1;
        Product_License__c prdLic = new Product_License__c();
        prdLic.License__c = lc.id;
         prdLic.Product__c =prod3.id;
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
        prdLic1.License__c = lc1.id;
        insert prdLic1;
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = pg.id;
        insert povPrd;
		 Provisioning_Product__c povPrd1 = new Provisioning_Product__c();
        povPrd1.Product__c = prod3.id;
        povPrd1.Provisioning_Group__c = pg.id;
        insert povPrd1;
        
        
        
        test.startTest();
         Provisioning_Event__e pvt = new Provisioning_Event__e();
         pvt.PG_ID__c =pg.id;
         Eventbus.publish(pvt);
       
        test.stopTest();
    }

     @IsTest static void Method4(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow');
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '  1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
          pg.RecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Subscription').getRecordTypeId();
         pg.PG_Request_Type__c ='Create';
        //  pg.RecordTypeId= recTypeId;
        insert pg;
        
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-BUS-Edition';
        prod1.ProductCode='ZIA-BUS-Edition';
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
        
        
        Licenses__c lc = new Licenses__c();
        lc.Name = 'URL Filtering';
        lc.Is_JIRA_Ticket_Needed__c = true;
        lc.POC_Quantity__c ='100';
        lc.License_Code__c = 'C_CASB';
        lc.Product__c =prod1.Id;
        insert lc;
        
        Licenses__c lc1 = new Licenses__c();
        lc1.Name = 'URL Filtering';
        lc1.Is_JIRA_Ticket_Needed__c = true;
        lc1.POC_Quantity__c ='100';
        lc1.License_Code__c = 'C_DLP';
        lc1.Product__c =prod3.Id;
        insert lc1;
        Product_License__c prdLic = new Product_License__c();
        prdLic.License__c = lc.id;
         prdLic.Product__c =prod3.id;
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
        prdLic1.License__c = lc1.id;
        insert prdLic1;
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = pg.id;
        insert povPrd;
		 Provisioning_Product__c povPrd1 = new Provisioning_Product__c();
        povPrd1.Product__c = prod3.id;
        povPrd1.Provisioning_Group__c = pg.id;
        insert povPrd1;
        
        
        
        test.startTest();
         Provisioning_Event__e pvt = new Provisioning_Event__e();
         pvt.PG_ID__c =pg.id;
         Eventbus.publish(pvt);
       
        test.stopTest();
    }

      @IsTest static void Method5(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow');
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '  1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
          pg.RecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Subscription').getRecordTypeId();
         pg.PG_Request_Type__c ='Update';
        //  pg.RecordTypeId= recTypeId;
        insert pg;
        
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-BUS-Edition';
        prod1.ProductCode='ZIA-BUS-Edition';
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
        
        
        Licenses__c lc = new Licenses__c();
        lc.Name = 'URL Filtering';
        lc.Is_JIRA_Ticket_Needed__c = true;
        lc.POC_Quantity__c ='100';
        lc.License_Code__c = 'C_CASB';
        lc.Product__c =prod1.Id;
        insert lc;
        
        Licenses__c lc1 = new Licenses__c();
        lc1.Name = 'URL Filtering';
        lc1.Is_JIRA_Ticket_Needed__c = true;
        lc1.POC_Quantity__c ='100';
        lc1.License_Code__c = 'C_DLP';
        lc1.Product__c =prod3.Id;
        insert lc1;
        Product_License__c prdLic = new Product_License__c();
        prdLic.License__c = lc.id;
         prdLic.Product__c =prod3.id;
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
        prdLic1.License__c = lc1.id;
        insert prdLic1;
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = pg.id;
        insert povPrd;
		 Provisioning_Product__c povPrd1 = new Provisioning_Product__c();
        povPrd1.Product__c = prod3.id;
        povPrd1.Provisioning_Group__c = pg.id;
        insert povPrd1;
        
        
        
        test.startTest();
         Provisioning_Event__e pvt = new Provisioning_Event__e();
         pvt.PG_ID__c =pg.id;
         Eventbus.publish(pvt);
       
        test.stopTest();
    }

     @IsTest static void Method6(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow');
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '  1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
          pg.RecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Subscription').getRecordTypeId();
         pg.PG_Request_Type__c ='Replace';
        //  pg.RecordTypeId= recTypeId;
        insert pg;
        Provisioning_Contact__c pgCon = new Provisioning_Contact__c();
         pgCon.User__c = testuser.id;
         pgCon.Provisioning_Group__c = pg.id;
         insert pgCon;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-BUS-Edition';
        prod1.ProductCode='ZIA-BUS-Edition';
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
        
        
        Licenses__c lc = new Licenses__c();
        lc.Name = 'URL Filtering';
        lc.Is_JIRA_Ticket_Needed__c = true;
        lc.POC_Quantity__c ='100';
        lc.License_Code__c = 'C_CASB';
        lc.Product__c =prod1.Id;
        insert lc;
        
        Licenses__c lc1 = new Licenses__c();
        lc1.Name = 'URL Filtering';
        lc1.Is_JIRA_Ticket_Needed__c = true;
        lc1.POC_Quantity__c ='100';
        lc1.License_Code__c = 'C_DLP';
        lc1.Product__c =prod3.Id;
        insert lc1;
        Product_License__c prdLic = new Product_License__c();
        prdLic.License__c = lc.id;
         prdLic.Product__c =prod3.id;
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
        prdLic1.License__c = lc1.id;
        insert prdLic1;
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = pg.id;
        insert povPrd;
		 Provisioning_Product__c povPrd1 = new Provisioning_Product__c();
        povPrd1.Product__c = prod3.id;
        povPrd1.Provisioning_Group__c = pg.id;
        insert povPrd1;
        
        
        
        test.startTest();
         Provisioning_Event__e pvt = new Provisioning_Event__e();
         pvt.PG_ID__c =pg.id;
         Eventbus.publish(pvt);
       
        test.stopTest();
    }

}