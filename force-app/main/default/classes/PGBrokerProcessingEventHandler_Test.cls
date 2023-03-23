@isTest
public class PGBrokerProcessingEventHandler_Test {
     

    /* @IsTest static void Method5(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30));
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '	1 - Discovery & Qualification',
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
        //	pg.RecordTypeId= recTypeId;
        insert pg;
        
        List< ProvisioningBrokerWrapper.cls_customerInfo> lstcinfo = new  List<ProvisioningBrokerWrapper.cls_customerInfo>();
        ProvisioningBrokerWrapper.cls_customerInfo cInf = new ProvisioningBrokerWrapper.cls_customerInfo();
        cInf.cloudName='ZIA';
        cInf.customerID='2222222224';
        cInf.tenantID='Zia -tenant';
        cInf.requestStatus='Success'; 
        ProvisioningBrokerWrapper.cls_customerInfo cInf1 = new ProvisioningBrokerWrapper.cls_customerInfo();
        cInf1.cloudName='ZPA';
        cInf1.customerID='2222222224';
        cInf1.tenantID='Zia -tenant';
        cInf1.requestStatus='Success'; //
        lstcinfo.add(cinf);
        lstcinfo.add(cInf1);
        
        ProvisioningBrokerWrapper pw = new ProvisioningBrokerWrapper();
        pw.requestID ='22324';
        pw.prGroupId = pg.id;
        pw.sfdcAccountId = String.valueOf(account.id);
        pw.customerInfo = lstcinfo;
        
        RestRequest req = new RestRequest(); 
        req.requestBody = BLOB.valueOf(JSON.serializePretty(pw));
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZSCMTOSFDC'; 
        RestContext.request = req; 
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        Test.startTest();
        BROKERTOSFDC.doPost();
        
        pw.requestID =null;
        pw.prGroupId = pg.id;
        pw.sfdcAccountId = String.valueOf(account.id);
        pw.customerInfo = lstcinfo;
        
        RestRequest req2 = new RestRequest(); 
        req.requestBody = BLOB.valueOf(JSON.serializePretty(pw));
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZSCMTOSFDC'; 
        RestContext.request = req; 
        RestResponse res1 = new RestResponse();
        RestContext.response= res1;
        
        //Test.startTest();
        BROKERTOSFDC.doPost();
        
        Test.stopTest();
        
        
        
    }  */
    
      @IsTest static void Method8(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30));
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '	1 - Discovery & Qualification',
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
        //	pg.RecordTypeId= recTypeId;
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
         Provisioning_Contact__c pcont = new Provisioning_Contact__c();
        pcont.User__c = testuser.id;
        pcont.Provisioning_Group__c = pg.id;
        insert pcont;
        
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
        
        lc1.Product__c =prod1.Id;
        insert lc1;
        Product_License__c prdLic = new Product_License__c();
        prdLic.License__c = lc.id;
         prdLic.Product__c =prod3.id;
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
        prdLic1.License__c = lc1.id;
           prdLic.Product__c =prod3.id;
        insert prdLic1;
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = pg.id;
        insert povPrd;
     Provisioning_Product__c povPrd1 = new Provisioning_Product__c();
        povPrd1.Product__c = prod3.id;
        povPrd1.Provisioning_Group__c = pg.id;
        insert povPrd1;
        
        
        List< ProvisioningBrokerWrapper.cls_customerInfo> lstcinfo = new  List<ProvisioningBrokerWrapper.cls_customerInfo>();
        ProvisioningBrokerWrapper.cls_customerInfo cInf = new ProvisioningBrokerWrapper.cls_customerInfo();
        cInf.cloudName='ZIA';
        cInf.tenantID='Zia -tenant';
        cInf.requestStatus='Success'; 
        ProvisioningBrokerWrapper.cls_customerInfo cInf1 = new ProvisioningBrokerWrapper.cls_customerInfo();
        cInf1.cloudName='ZPA';
        cInf1.betaCustomerId='2222222224';
        cInf1.tenantID='Zia -tenant';
        cInf1.requestStatus='Success'; //
        lstcinfo.add(cinf);
        lstcinfo.add(cInf1);
        
        ProvisioningBrokerWrapper pw = new ProvisioningBrokerWrapper();
        pw.requestID ='22324';
        pw.prGroupId = pg.id;
        pw.sfdcAccountId = String.valueOf(account.id);
        pw.customerInfo = lstcinfo;
        
        RestRequest req = new RestRequest(); 
        req.requestBody = BLOB.valueOf(JSON.serializePretty(pw));
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZSCMTOSFDC'; 
        RestContext.request = req; 
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        Test.startTest();
        BROKERTOSFDC.doPost();
        
        pw.requestID =null;
        pw.prGroupId = pg.id;
        pw.sfdcAccountId = String.valueOf(account.id);
        pw.customerInfo = lstcinfo;
        
        RestRequest req2 = new RestRequest(); 
        req.requestBody = BLOB.valueOf(JSON.serializePretty(pw));
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZSCMTOSFDC'; 
        RestContext.request = req; 
        RestResponse res1 = new RestResponse();
        RestContext.response= res1;
        
        //Test.startTest();
        BROKERTOSFDC.doPost();
        
        Test.stopTest();
        
        
        
    } 
    // cover cross platform
     @IsTest static void Method81(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30));
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '	1 - Discovery & Qualification',
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
         pg.Cross_Platform_Selected__c = true;
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
        //	pg.RecordTypeId= recTypeId;
        insert pg;
          Provisioning_Group__c pg1 = new Provisioning_Group__c();
        pg1.Product_Line__c ='ZDX';
         pg1.Cross_Platform_Selected__c = true;
        pg1.Provisioning_Request__c = testPR.id;
        pg1.Account__c=account.id;
         pg1.Associated_Provisioning_Group__c= pg.id;
        //	pg.RecordTypeId= recTypeId;
        insert pg1;
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
         Provisioning_Contact__c pcont = new Provisioning_Contact__c();
        pcont.User__c = testuser.id;
        pcont.Provisioning_Group__c = pg.id;
        insert pcont;
        
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
        
        lc1.Product__c =prod1.Id;
        insert lc1;
        Product_License__c prdLic = new Product_License__c();
        prdLic.License__c = lc.id;
         prdLic.Product__c =prod3.id;
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
        prdLic1.License__c = lc1.id;
           prdLic.Product__c =prod3.id;
        insert prdLic1;
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = pg.id;
        insert povPrd;
     Provisioning_Product__c povPrd1 = new Provisioning_Product__c();
        povPrd1.Product__c = prod3.id;
        povPrd1.Provisioning_Group__c = pg.id;
        insert povPrd1;
        
        
        List< ProvisioningBrokerWrapper.cls_customerInfo> lstcinfo = new  List<ProvisioningBrokerWrapper.cls_customerInfo>();
        ProvisioningBrokerWrapper.cls_customerInfo cInf = new ProvisioningBrokerWrapper.cls_customerInfo();
        cInf.cloudName='ZIA';
        cInf.betaCustomerId='2222222224';
        cInf.tenantID='Zia -tenant';
        cInf.requestStatus='Success'; 
        ProvisioningBrokerWrapper.cls_customerInfo cInf1 = new ProvisioningBrokerWrapper.cls_customerInfo();
        cInf1.cloudName='ZPA';
        cInf1.betaCustomerId='222222224';
        cInf1.tenantID='Zpa -tenant';
        cInf1.requestStatus='Success'; //
        lstcinfo.add(cinf);
        lstcinfo.add(cInf1);
        
        ProvisioningBrokerWrapper pw = new ProvisioningBrokerWrapper();
        pw.requestID ='22324';
        pw.prGroupId = pg.id;
        pw.sfdcAccountId = String.valueOf(account.id);
        pw.customerInfo = lstcinfo;
        
        RestRequest req = new RestRequest(); 
        req.requestBody = BLOB.valueOf(JSON.serializePretty(pw));
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZSCMTOSFDC'; 
        RestContext.request = req; 
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        Test.startTest();
        BROKERTOSFDC.doPost();
        
        pw.prGroupId = pg.id;
        pw.sfdcAccountId = String.valueOf(account.id);
        pw.customerInfo = lstcinfo;
        
        RestRequest req2 = new RestRequest(); 
        req.requestBody = BLOB.valueOf(JSON.serializePretty(pw));
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZSCMTOSFDC'; 
        RestContext.request = req; 
        RestResponse res1 = new RestResponse();
        RestContext.response= res1;
        
        //Test.startTest();
        BROKERTOSFDC.doPost();
        
        Test.stopTest();
        
        
        
    } 
    
    @IsTest static void Method1(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30));
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '	1 - Discovery & Qualification',
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
        //	pg.RecordTypeId= recTypeId;
        insert pg;
        
        List< ProvisioningBrokerWrapper.cls_customerInfo> lstcinfo = new  List<ProvisioningBrokerWrapper.cls_customerInfo>();
        ProvisioningBrokerWrapper.cls_customerInfo cInf = new ProvisioningBrokerWrapper.cls_customerInfo();
        cInf.cloudName='ZIA';
        cInf.betaCustomerId='2222222224';
        cInf.tenantID='Zia -tenant';
        cInf.requestStatus='Success'; 
        lstcinfo.add(cinf);
        
        ProvisioningBrokerWrapper pw = new ProvisioningBrokerWrapper();
        pw.requestID ='22324';
        pw.prGroupId = pg.id;
        pw.sfdcAccountId = String.valueOf(account.id);
        pw.customerInfo = lstcinfo;
        
        RestRequest req = new RestRequest(); 
        req.requestBody = BLOB.valueOf(JSON.serializePretty(pw));
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZSCMTOSFDC'; 
        RestContext.request = req; 
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        Test.startTest();
        BROKERTOSFDC.doPost();
        
        pw.requestID =null;
        pw.prGroupId = pg.id;
        pw.sfdcAccountId = String.valueOf(account.id);
        pw.customerInfo = lstcinfo;
        
        RestRequest req2 = new RestRequest(); 
        req.requestBody = BLOB.valueOf(JSON.serializePretty(pw));
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZSCMTOSFDC'; 
        RestContext.request = req; 
        RestResponse res1 = new RestResponse();
        RestContext.response= res1;
        
        //Test.startTest();
        BROKERTOSFDC.doPost();
        
        Test.stopTest();
        
        
        
    } 
    
    
   @IsTest static void Method2(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        Id pgRecType = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Trial').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30));
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '	1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tese21tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
        pg.RecordTypeId = pgRecType;
        //	pg.RecordTypeId= recTypeId;
        insert pg;
        
        List< ProvisioningBrokerWrapper.cls_customerInfo> lstcinfo = new  List<ProvisioningBrokerWrapper.cls_customerInfo>();
        ProvisioningBrokerWrapper.cls_customerInfo cInf = new ProvisioningBrokerWrapper.cls_customerInfo();
        cInf.cloudName='ZIA';
        cInf.betaCustomerId='2222222224';
        cInf.tenantID='Zia -tenant';
        cInf.requestStatus='Success'; 
        lstcinfo.add(cinf);
        
        ProvisioningBrokerWrapper pw = new ProvisioningBrokerWrapper();
        pw.requestID =null;
        pw.prGroupId = pg.id;
        pw.sfdcAccountId = String.valueOf(account.id);
        pw.customerInfo = lstcinfo;
        
        RestRequest req = new RestRequest(); 
        req.requestBody = BLOB.valueOf(JSON.serializePretty(pw));
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZSCMTOSFDC'; 
        RestContext.request = req; 
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        Test.startTest();
        BROKERTOSFDC.doPost();
        Set<Id> setId = new set<Id>();
        setId.add(opp.id);
        // PGBrokerProcessingEventHandler.getOppRecord(setId);
        
        Test.stopTest();
        
        
        
    } 
    
     @IsTest static void Method6(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30));
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '	1 - Discovery & Qualification',
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
        //	pg.RecordTypeId= recTypeId;
        insert pg;
        
        List< ProvisioningBrokerWrapper.cls_customerInfo> lstcinfo = new  List<ProvisioningBrokerWrapper.cls_customerInfo>();
        ProvisioningBrokerWrapper.cls_customerInfo cInf = new ProvisioningBrokerWrapper.cls_customerInfo();
        cInf.cloudName='ZIA';
        cInf.betaCustomerId='2222222224';
        cInf.tenantID='Zia -tenant';
        cInf.requestStatus='Failure'; 
        ProvisioningBrokerWrapper.cls_customerInfo cInf1 = new ProvisioningBrokerWrapper.cls_customerInfo();
        cInf1.cloudName='ZPA';
        cInf1.betaCustomerId='2222222224';
          cInf1.subscriptionId='2222222224';
          cInf1.subscriptionName='Name224';
        cInf1.tenantID='Zia -tenant';
        cInf1.requestStatus='Failure'; //
        lstcinfo.add(cinf);
        lstcinfo.add(cInf1);
        
        ProvisioningBrokerWrapper pw = new ProvisioningBrokerWrapper();
        pw.requestID ='22324';
        pw.prGroupId = pg.id;
        pw.sfdcAccountId = String.valueOf(account.id);
        pw.customerInfo = lstcinfo;
        
      
           Provisioning_Integration_Log__c logNew1 = new Provisioning_Integration_Log__c();
      //  logNew1.Request__c = req.requestBody.toString();
      //  logNew1.Endpoint__c = URL.getSalesforceBaseUrl().toExternalForm() + req.resourcePath;
       // logNew1.Response__c =  JSON.serializePretty(response);
        logNew1.Request_Status__c =  'Success';
        logNew1.Status__c =  'Received';
        lognew1.Failure_Reason__c = 'god';
         lognew1.Request__c ='{"requestID":"REQ1655481609289","prGroupId":"aNU4C0000004DOZWA2","pgNumber":"PRG-02962","sfdcAccountId":"0014C00000isBJtQAM","customerInfo":[{"betaCustomerId":"68368","customerName":null,"cloudName":"ZIA","tenantID":"ZSCALERTWO.NET-67411","tenantName":null,"domain":null,"additionalDomains":null,"tenantStatus":null,"subscriptionId":null,"subscriptionName":null,"accountType":null,"partnerInfo":null,"requestStatus":"success","failureReason":null},{"betaCustomerId":"68368","customerName":null,"cloudName":"ZDX","tenantID":null,"tenantName":null,"domain":null,"additionalDomains":null,"tenantStatus":"Subscription","subscriptionId":null,"subscriptionName":null,"accountType":null,"partnerInfo":null,"requestStatus":"success","failureReason":null}]}';
         lognew1.Provisioning_Group__c = pg.id;
         insert lognew1;
       //  lognew1.status__c ='Failed';
       //  update lognew1;
        
        Test.startTest();
         
         Provisioning_Broker_Processing_Event__e pevnt = new Provisioning_Broker_Processing_Event__e();
         pevnt.Provisioning_Integration_Log_ID__c =lognew1.id;
         Eventbus.publish(pevnt);
         //insert pevnt;
       Test.stopTest();
        
        
        
    }
    

    
     @IsTest static void Method7(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30));
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '	1 - Discovery & Qualification',
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
         pg.Provisioning_Type__c='Auto';
          pg.Opportunity__c = opp.id;
        //	pg.RecordTypeId= recTypeId;
        insert pg;
        
        List< ProvisioningBrokerWrapper.cls_customerInfo> lstcinfo = new  List<ProvisioningBrokerWrapper.cls_customerInfo>();
        ProvisioningBrokerWrapper.cls_customerInfo cInf = new ProvisioningBrokerWrapper.cls_customerInfo();
        cInf.cloudName='ZIA';
        cInf.betaCustomerId='2222222224';
        cInf.tenantID='Zia -tenant';
        cInf.requestStatus='Failure'; 
        ProvisioningBrokerWrapper.cls_customerInfo cInf1 = new ProvisioningBrokerWrapper.cls_customerInfo();
        cInf1.cloudName='ZPA';
        cInf1.betaCustomerId='2222222224';
          cInf1.subscriptionId='2222222224';
          cInf1.subscriptionName='Name224';
        cInf1.tenantID='Zia -tenant';
        cInf1.requestStatus='Failure'; //
        lstcinfo.add(cinf);
        lstcinfo.add(cInf1);
        
        ProvisioningBrokerWrapper pw = new ProvisioningBrokerWrapper();
        pw.requestID ='22324';
        pw.prGroupId = pg.id;
        pw.sfdcAccountId = String.valueOf(account.id);
        pw.customerInfo = lstcinfo;
        
      
           Provisioning_Integration_Log__c logNew1 = new Provisioning_Integration_Log__c();
      //  logNew1.Request__c = req.requestBody.toString();
      //  logNew1.Endpoint__c = URL.getSalesforceBaseUrl().toExternalForm() + req.resourcePath;
       // logNew1.Response__c =  JSON.serializePretty(response);
        logNew1.Request_Status__c =  'Success';
        logNew1.Status__c =  'Received';
        lognew1.Failure_Reason__c = 'god';
         lognew1.Request__c ='{"requestID":"REQ1655481609289","prGroupId":"'+pg.id+'","pgNumber":"PRG-02962","sfdcAccountId":"'+pg.Account__c+'","customerInfo":[{"betaCustomerId":"68368","customerName":null,"cloudName":"ZIA","tenantID":"ZSCALERTWO.NET-67411","tenantName":null,"domain":null,"additionalDomains":null,"tenantStatus":null,"subscriptionId":null,"subscriptionName":null,"accountType":null,"partnerInfo":null,"requestStatus":"success","failureReason":null},{"betaCustomerId":"68368","customerName":null,"cloudName":"ZDX","tenantID":null,"tenantName":null,"domain":null,"additionalDomains":null,"tenantStatus":"Subscription","subscriptionId":"dgjw","subscriptionName":"gjstc","accountType":null,"partnerInfo":null,"requestStatus":"success","failureReason":null}]}';
         lognew1.Provisioning_Group__c = pg.id;
         insert lognew1;
       //  lognew1.status__c ='Failed';
       //  update lognew1;
        
        Test.startTest();
         
         Provisioning_Broker_Processing_Event__e pevnt = new Provisioning_Broker_Processing_Event__e();
         pevnt.Provisioning_Integration_Log_ID__c =lognew1.id;
         Eventbus.publish(pevnt);
         //insert pevnt;
       
         
        Test.stopTest();
        
        
        
    }
    
   
   
    
}