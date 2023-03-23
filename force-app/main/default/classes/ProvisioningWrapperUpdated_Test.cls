@isTest
public class ProvisioningWrapperUpdated_Test {
    @testSetup
    static void createTestData() {
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow');
        insert account;
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '  1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId()
                                         );
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert opp;
        TriggerHandler.clearByPass('OpportunityTriggerHandler');
    }
 
      @IsTest static void Method111(){ 
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id,SE_Name__c FROM Opportunity LIMIT 1];

        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
        insert testUser;
        // insert PR
        //Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id, Account__c = account.Id, Opportunity__c = opp.Id); //, RecordTypeId = recordTypeId
        //insert testPR;
           Sandbox_Cluster__c sc = new Sandbox_Cluster__c();
         sc.name='smba-fra-cluster';
         sc.cloud__c='ZSCALERTWO';
         sc.clusterId__c='2';
         sc.Cluster_External_Id__c='ZSCALERTWO-3';
         sc.type__c='SMBA';
         insert sc;
         Nanolog_Cluster__c nc= new Nanolog_Cluster__c();
         nc.Name='zs2smsmcluster';
         nc.cloud__c='ZSCALERTWO';
         nc.clusterId__c='2';
         nc.Cluster_External_Id__c='ZSCALERTWO-3';
         nc.type__c='Storage';
         insert nc;
			SMCDSS_DLP_Cluster__c dlpsc = new SMCDSS_DLP_Cluster__c();
			 dlpsc.Name='smdlpcds-cluster';
          dlpsc.cloud__c='ZSCALERTWO';
         dlpsc.clusterId__c='2062';
         dlpsc.Cluster_External_Id__c='ZSCALERTWO-2062';
         dlpsc.type__c='DLP_CDSS';
         insert dlpsc;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Account__c = account.id;
        pg.Provisioning_Process__c = 'New Tenant';
        pg.PG_Request_Type__c = 'Create';
         pg.Preferred_Cloud__c='ZscalerTwo.net';
           pg.Opportunity__c = opp.id;
         pg.Sandbox_Cluster__c = sc.id;
         pg.Nanolog_Cluster__c = nc.id;
         pg.SMCDSS_DLP_Cluster__c = dlpsc.id;
        pg.SE_Manager_Email__c = opp.SE_Name__c;
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
         prdLic.License_Product_Line__c ='ZIA;ZDX';
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
          prdLic.License_Product_Line__c ='ZDX';
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
         //update pg;
          Provisioning_Event__e pvt1 = new Provisioning_Event__e();
         pvt1.PG_ID__c =pg.id;
         Eventbus.publish(pvt1);
         
         pg.PG_Request_Type__c ='Update';
         update pg;
     Eventbus.publish(pvt1);
           pg.PG_Request_Type__c ='Replace';
         update pg;
     Eventbus.publish(pvt1);
		ProvisioningWrapperUpdated pwrp = new ProvisioningWrapperUpdated();
        test.stopTest();
    }
    
   
      @IsTest static void Method5(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
         Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926.beta',Account__c=account.Id,NS_Org_ID__c='Zscloud.net-3926.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA');
       insert Zsc1;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZPA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
            pg.RecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Subscription').getRecordTypeId();
         pg.PG_Request_Type__c ='Replace';
       
           pg.Opportunity__c = opp.id;
      //  pg.Status__c ='Provisioned';
 pg.Opportunity__c = opp.id;
		pg.Associated_ZIA_Zscaler_Cloud__c  =Zsc1.id;
        //  pg.RecordTypeId= recTypeId;
        insert pg;
        Provisioning_Contact__c pcont = new Provisioning_Contact__c();
        pcont.User__c = testuser.id;
        pcont.Provisioning_Group__c = pg.id;
        insert pcont;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-BUS-Edition';
        prod1.ProductCode='ZIA-BUS-Edition';
        prod1.Product_Line__c='ZPA';
        prod1.Provisioning_Product_Family__c='Bundles';
        //prod1.prod
        insert prod1;
        // prod1.
        
        Product2 prod3 = new Product2();
        prod3.Name='50,000 Additional URLs';
        prod3.ProductCode='ZIA-ADD50K-URLS';
        prod3.Product_Line__c='ZPA';
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
         prdLic.License_Product_Line__c ='ZPA';
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
          prdLic.License_Product_Line__c ='ZPA';
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
        
        
        
		ProvisioningWrapperUpdated pwrp = new ProvisioningWrapperUpdated();
        String json = '{"requestID":"REQ1655481609289","prGroupId":"aNU4C0000004DOZWA2","pgNumber":"PRG-02962","sfdcAccountId":"0014C00000isBJtQAM","customerInfo":[{"productionCustomerId":"68368","customerName":null,"cloudName":"ZIA","tenantID":"ZSCALERTWO.NET-67411","tenantName":null,"domain":null,"additionalDomains":null,"tenantStatus":null,"subscriptionId":null,"subscriptionName":null,"accountType":null,"partnerInfo":null,"requestStatus":"success","failureReason":null},{"productionCustomerId":"68368","customerName":null,"cloudName":"ZDX","tenantID":null,"tenantName":null,"domain":null,"additionalDomains":null,"tenantStatus":"Subscription","subscriptionId":null,"subscriptionName":null,"accountType":null,"partnerInfo":null,"requestStatus":"success","failureReason":null}]}';
		ProvisioningWrapperUpdated.parse(json);       
        test.stopTest();
    } 
   
      @IsTest static void Method7(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
         Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926.beta',Account__c=account.Id,NS_Org_ID__c='Zscloud.net-3926.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA');
       insert Zsc1;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZDX';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
 pg.Opportunity__c = opp.id;
		pg.Associated_ZIA_Zscaler_Cloud__c  =Zsc1.id;
           pg.RecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Trial').getRecordTypeId();
         pg.PG_Request_Type__c ='Update';
          pg.status__c='Pending Archival';
          pg.Zscaler_Cloud_ID__c = Zsc1.id;
        //pg.Zscaler_Cloud_ID__c = Zsc1.Id;
        
        //  pg.RecordTypeId= recTypeId;
        insert pg;
        
           Provisioning_Group__c pg1 = new Provisioning_Group__c();
        pg1.Product_Line__c ='ZDX';
        pg1.Provisioning_Request__c = testPR.id;
        pg1.Account__c=account.id;
          pg1.status__c='Pending Archival';
           pg1.Opportunity__c = opp.id;
 pg1.Opportunity__c = opp.id;
          pg1.Zscaler_Cloud_ID__c = Zsc1.id;
		pg1.Associated_ZIA_Zscaler_Cloud__c  =Zsc1.id;
           pg1.RecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Trial').getRecordTypeId();
         pg1.PG_Request_Type__c ='Update';
        //pg.Zscaler_Cloud_ID__c = Zsc1.Id;
        
        //  pg.RecordTypeId= recTypeId;
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
         prdLic.License_Product_Line__c ='ZIA;ZDX';
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
          prdLic.License_Product_Line__c ='ZDX';
        prdLic1.License__c = lc1.id;
        insert prdLic1;
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = pg.id;
          povPrd.Zscaler_Cloud_ID__c = Zsc1.id;
        insert povPrd;
		 Provisioning_Product__c povPrd1 = new Provisioning_Product__c();
        povPrd1.Product__c = prod3.id;
        povPrd1.Provisioning_Group__c = pg.id;
          povPrd1.Zscaler_Cloud_ID__c = Zsc1.id;
        insert povPrd1;
        
         Provisioning_Product__c povPrd2 = new Provisioning_Product__c();
        povPrd2.Product__c = prod3.id;
        povPrd2.Provisioning_Group__c = pg1.id;
          povPrd2.Zscaler_Cloud_ID__c = Zsc1.id;
        insert povPrd2;

        
        test.startTest();
       //  Provisioning_Event__e pvt = new Provisioning_Event__e();
        // pvt.PG_ID__c =pg.id;
        // Eventbus.publish(pvt);
        // update pg;
         
        
		ProvisioningWrapperUpdated pwrp = new ProvisioningWrapperUpdated();
        pwrp.getZscmEndDate(String.valueOf(ZSc1.Id));
        pwrp.getProductLicenseDetails(String.valueOf(ZSc1.Id),'ZIA');
        pwrp.getProductLicenseDetails(String.valueOf(ZSc1.Id),'ZDX');
        test.stopTest();
    } 
    
     @IsTest static void Method9(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
         Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926.beta',Account__c=account.Id,NS_Org_ID__c='Zscloud.net-3926.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA');
       insert Zsc1;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZDX';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
 pg.Opportunity__c = opp.id;
		pg.Associated_ZIA_Zscaler_Cloud__c  =Zsc1.id;
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
         prdLic.License_Product_Line__c ='ZIA;ZDX';
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
          prdLic.License_Product_Line__c ='ZDX';
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
         update pg;
         
        
		ProvisioningWrapperUpdated pwrp = new ProvisioningWrapperUpdated();
        test.stopTest();
    }
    
    
      @IsTest static void Method6(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
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
          
        Product2 prod4 = new Product2();
        prod4.Name='ZIA-DLP-EDM';
        prod4.ProductCode='ZIA-DLP-EDM';
        prod4.Product_Line__c='ZIA';
        prod4.Provisioning_Product_Family__c='Addon';
        insert prod4;
        
        
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
          
        Licenses__c lc2 = new Licenses__c();
        lc2.Name = 'DLP Exact Data Match';
        lc2.Is_JIRA_Ticket_Needed__c = true;
        lc2.POC_Quantity__c ='100';
        lc2.License_Code__c = 'Z_DLP_EDM';
        lc2.Product__c =prod4.Id;
        insert lc2;
        
        Product_License__c prdLic5 = new Product_License__c();
        prdLic5.License__c = lc2.id;
        prdLic5.Product__c =prod4.id;
        insert prdLic5;
        
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
       ProvisioningWrapperUpdated pw = new ProvisioningWrapperUpdated();
          pw.getEpoc(System.today(),pg);
          pw.getApproxQuantityForBroker(5, 'Z_DLP_EDM');
          pw.getApproxQuantityForBroker(5, 'ZIA_ADD50K_URLS');
        test.stopTest();
    } 
    
       @IsTest static void CoverTime(){
           TriggerHandler.bypass('OpportunityTriggerHandler');
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
          
             Patch__c pat = new Patch__c(PatchName__c = 'Test Patch' );
        insert pat;
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='EMEA';
        pateam.Region__c ='EMEA';
        pateam.Area__c ='EMEA';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        pat.PatchTeam__c=pateam.Id;
        account.Sales_Territory__c = pateam.Id;
        account.Patch__c = pat.Id;
       // insert acc;
        update account;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
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
        
        pg = [select id,Name,
                 
                 RecordType.DeveloperName,
                 RecordType.Name,Proxy_Cloud__c,
                 
                 Product_Line__c,Preferred_Cloud__c,
                 Organization_Domain__c,Provisioning_Process__c,
                 Additional_Organization_domains__c,
                 Start_Date__c,
                 End_Date__c,
                 Send_Initial_Login_Credentials_To__c,
                 Status__c,Approval_Status__c,
                 PG_Request_Type__c,ZSCM_End_Date__c,
                 
                 //Cloud Details
                 Zscaler_Cloud_ID__c,
                 Zscaler_Cloud_ID__r.Name,
                 
                 //Associated Cloud Details
                 Associated_ZIA_Zscaler_Cloud__c,
                 Associated_ZIA_Zscaler_Cloud__r.Name,
                 
                 ZPA_Preferred_Cloud__c,
                 
                 //Opportunity
                 opportunity__c,
                 opportunity__r.Name,
                 opportunity__r.Type,opportunity__r.Id,
                 
                 //Customer
                 Account__r.name,Account__r.Parent.name,Account__r.Operational_HQ__c,Account__r.Region_New__c,
                 Account__r.BillingCountry,Account__r.ZIA_Customer_Id__c,Account__r.ZPA_Customer_ID__c,Account__r.Area__c ,
                 Account__r.Type,Account__r.No_of_Employees_Users__c,Account__r.Industry,Account__r.Geo__c,Account__r.FP_A_Parent_industry__c,
                 Account__r.Sales_Territory__r.Provisioning_Geographical_Region__c,
                 Account__r.Sales_Territory__r.Provisioning_Region__c,Account__r.District__c,
                 
                 CreatedDate,LastModifiedDate,Owner.Name,Owner.email,Owner.Username
                 
            from Provisioning_Group__c where id =: pg.id
        ];
        
        test.startTest();
       
      
         //  insert rd;
            System.debug('pg.RecordType.Name'+pg.RecordType.Name);
             ProvisioningWrapperUpdated pw = new ProvisioningWrapperUpdated();
          	pw.getEpoc(System.today(),pg);
            pateam.Theater__c='Americas';
       // pateam.Region__c ='EMEA';
       // pateam.Area__c ='EMEA';
           update pateam;
            pg = [select id,Name,
                 
                 RecordType.DeveloperName,
                 RecordType.Name,Proxy_Cloud__c,
                 
                 Product_Line__c,Preferred_Cloud__c,
                 Organization_Domain__c,Provisioning_Process__c,
                 Additional_Organization_domains__c,
                 Start_Date__c,
                 End_Date__c,
                 Send_Initial_Login_Credentials_To__c,
                 Status__c,Approval_Status__c,
                 PG_Request_Type__c,ZSCM_End_Date__c,
                 
                 //Cloud Details
                 Zscaler_Cloud_ID__c,
                 Zscaler_Cloud_ID__r.Name,
                 
                 //Associated Cloud Details
                 Associated_ZIA_Zscaler_Cloud__c,
                 Associated_ZIA_Zscaler_Cloud__r.Name,
                 
                 ZPA_Preferred_Cloud__c,
                 
                 //Opportunity
                 opportunity__c,
                 opportunity__r.Name,
                 opportunity__r.Type,opportunity__r.Id,
                 
                 //Customer
                 Account__r.name,Account__r.Parent.name,Account__r.Operational_HQ__c,Account__r.Region_New__c,
                 Account__r.BillingCountry,Account__r.ZIA_Customer_Id__c,Account__r.ZPA_Customer_ID__c,Account__r.Area__c ,
                 Account__r.Type,Account__r.No_of_Employees_Users__c,Account__r.Industry,Account__r.Geo__c,Account__r.FP_A_Parent_industry__c,
                 Account__r.Sales_Territory__r.Provisioning_Geographical_Region__c,
                 Account__r.Sales_Territory__r.Provisioning_Region__c,Account__r.District__c,
                 
                 CreatedDate,LastModifiedDate,Owner.Name,Owner.email,Owner.Username
                 
            from Provisioning_Group__c where id =: pg.id
        ];
        
           	pw.getEpoc(System.today(),pg);
           
           pateam.Theater__c='WW Enterprise';
       	 pateam.Area__c ='AMS';
           update pateam;
            pg = [select id,Name,
                 
                 RecordType.DeveloperName,
                 RecordType.Name,Proxy_Cloud__c,
                 
                 
                 //Customer
                 Account__r.name,Account__r.Parent.name,Account__r.Operational_HQ__c,Account__r.Region_New__c,
                 Account__r.BillingCountry,Account__r.ZIA_Customer_Id__c,Account__r.ZPA_Customer_ID__c,Account__r.Area__c ,
                 Account__r.Type,Account__r.No_of_Employees_Users__c,Account__r.Industry,Account__r.Geo__c,Account__r.FP_A_Parent_industry__c,
                 Account__r.Sales_Territory__r.Provisioning_Geographical_Region__c,
                 Account__r.Sales_Territory__r.Provisioning_Region__c,Account__r.District__c,
                 
                 CreatedDate,LastModifiedDate,Owner.Name,Owner.email,Owner.Username
                 
            from Provisioning_Group__c where id =: pg.id
        ];
        
           	pw.getEpoc(System.today(),pg);
           
           
             pateam.Theater__c='WW Enterprise';
      pateam.Region__c ='EMEA';
        pateam.Area__c ='EMEA';
           update pateam;
            pg = [select id,Name,
                 
                 RecordType.DeveloperName,
                 RecordType.Name,Proxy_Cloud__c,
                 
                 Product_Line__c,Preferred_Cloud__c,
                 Organization_Domain__c,Provisioning_Process__c,
                 Additional_Organization_domains__c,
                 Start_Date__c,
                 End_Date__c,
                 Send_Initial_Login_Credentials_To__c,
                 Status__c,Approval_Status__c,
                 PG_Request_Type__c,ZSCM_End_Date__c,
                 
                 //Cloud Details
                 Zscaler_Cloud_ID__c,
                 Zscaler_Cloud_ID__r.Name,
                 
                 //Associated Cloud Details
                 Associated_ZIA_Zscaler_Cloud__c,
                 Associated_ZIA_Zscaler_Cloud__r.Name,
                 
                 ZPA_Preferred_Cloud__c,
                 
                 //Opportunity
                 opportunity__c,
                 opportunity__r.Name,
                 opportunity__r.Type,opportunity__r.Id,
                 
                 //Customer
                 Account__r.name,Account__r.Parent.name,Account__r.Operational_HQ__c,Account__r.Region_New__c,
                 Account__r.BillingCountry,Account__r.ZIA_Customer_Id__c,Account__r.ZPA_Customer_ID__c,Account__r.Area__c ,
                 Account__r.Type,Account__r.No_of_Employees_Users__c,Account__r.Industry,Account__r.Geo__c,Account__r.FP_A_Parent_industry__c,
                 Account__r.Sales_Territory__r.Provisioning_Geographical_Region__c,
                 Account__r.Sales_Territory__r.Provisioning_Region__c,Account__r.District__c,
                 
                 CreatedDate,LastModifiedDate,Owner.Name,Owner.email,Owner.Username
                 
            from Provisioning_Group__c where id =: pg.id
        ];
        
           	pw.getEpoc(System.today(),pg);
           
           
        test.stopTest();
    }

    

     @IsTest static void CoverTime2(){
         TriggerHandler.bypass('OpportunityTriggerHandler');
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
          
             Patch__c pat = new Patch__c(PatchName__c = 'Test Patch' );
        insert pat;
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='WW Commercial';
        pateam.Region__c ='AMS';
        pateam.Area__c ='EMEA';
         pateam.District__c ='AMS';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        pat.PatchTeam__c=pateam.Id;
        account.Sales_Territory__c = pateam.Id;
        account.Patch__c = pat.Id;
       // insert acc;
        update account;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
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
        pg = [select id,Name,
                 
                 RecordType.DeveloperName,
                 RecordType.Name,Proxy_Cloud__c,
                 
                 Product_Line__c,Preferred_Cloud__c,
                 Organization_Domain__c,Provisioning_Process__c,
                 Additional_Organization_domains__c,
                 Start_Date__c,
                 End_Date__c,
                 Send_Initial_Login_Credentials_To__c,
                 Status__c,Approval_Status__c,
                 PG_Request_Type__c,ZSCM_End_Date__c,
                 
                 //Cloud Details
                 Zscaler_Cloud_ID__c,
                 Zscaler_Cloud_ID__r.Name,
                 
                 //Associated Cloud Details
                 Associated_ZIA_Zscaler_Cloud__c,
                 Associated_ZIA_Zscaler_Cloud__r.Name,
                 
                 ZPA_Preferred_Cloud__c,
                 
                 //Opportunity
                 opportunity__c,
                 opportunity__r.Name,
                 opportunity__r.Type,opportunity__r.Id,
                 
                 //Customer
                 Account__r.name,Account__r.Parent.name,Account__r.Operational_HQ__c,Account__r.Region_New__c,
                 Account__r.BillingCountry,Account__r.ZIA_Customer_Id__c,Account__r.ZPA_Customer_ID__c,Account__r.Area__c ,
                 Account__r.Type,Account__r.No_of_Employees_Users__c,Account__r.Industry,Account__r.Geo__c,Account__r.FP_A_Parent_industry__c,
                 Account__r.Sales_Territory__r.Provisioning_Geographical_Region__c,
                 Account__r.Sales_Territory__r.Provisioning_Region__c,Account__r.District__c,
                 
                 CreatedDate,LastModifiedDate,Owner.Name,Owner.email,Owner.Username
                 
            from Provisioning_Group__c where id =: pg.id
        ];
        
        test.startTest();
       
      
         //  insert rd;
            System.debug('pg.RecordType.Name'+pg.RecordType.Name);
             ProvisioningWrapperUpdated pw = new ProvisioningWrapperUpdated();
          	pw.getEpoc(System.today(),pg);
            pateam.Theater__c='WW Commercial';
          pateam.District__c ='EMEA';
       // pateam.Region__c ='EMEA';
       // pateam.Area__c ='EMEA';
           update pateam;
            pg = [select id,Name,
                 
                 RecordType.DeveloperName,
                 RecordType.Name,Proxy_Cloud__c,
                 
                 Product_Line__c,Preferred_Cloud__c,
                 Organization_Domain__c,Provisioning_Process__c,
                 Additional_Organization_domains__c,
                 Start_Date__c,
                 End_Date__c,
                 Send_Initial_Login_Credentials_To__c,
                 Status__c,Approval_Status__c,
                 PG_Request_Type__c,ZSCM_End_Date__c,
                 
                 //Cloud Details
                 Zscaler_Cloud_ID__c,
                 Zscaler_Cloud_ID__r.Name,
                 
                 //Associated Cloud Details
                 Associated_ZIA_Zscaler_Cloud__c,
                 Associated_ZIA_Zscaler_Cloud__r.Name,
                 
                 ZPA_Preferred_Cloud__c,
                 
                 //Opportunity
                 opportunity__c,
                 opportunity__r.Name,
                 opportunity__r.Type,opportunity__r.Id,
                 
                 //Customer
                 Account__r.name,Account__r.Parent.name,Account__r.Operational_HQ__c,Account__r.Region_New__c,
                 Account__r.BillingCountry,Account__r.ZIA_Customer_Id__c,Account__r.ZPA_Customer_ID__c,Account__r.Area__c ,
                 Account__r.Type,Account__r.No_of_Employees_Users__c,Account__r.Industry,Account__r.Geo__c,Account__r.FP_A_Parent_industry__c,
                 Account__r.Sales_Territory__r.Provisioning_Geographical_Region__c,
                 Account__r.Sales_Territory__r.Provisioning_Region__c,Account__r.District__c,
                 
                 CreatedDate,LastModifiedDate,Owner.Name,Owner.email,Owner.Username
                 
            from Provisioning_Group__c where id =: pg.id
        ];
        
           	pw.getEpoc(System.today(),pg);
           
           pateam.Theater__c='WW Enterprise';
       	 pateam.Area__c ='EMEA';
           update pateam;
            pg = [select id,Name,
                 
                 RecordType.DeveloperName,
                 RecordType.Name,Proxy_Cloud__c,
                 
                 
                 //Customer
                 Account__r.name,Account__r.Parent.name,Account__r.Operational_HQ__c,Account__r.Region_New__c,
                 Account__r.BillingCountry,Account__r.ZIA_Customer_Id__c,Account__r.ZPA_Customer_ID__c,Account__r.Area__c ,
                 Account__r.Type,Account__r.No_of_Employees_Users__c,Account__r.Industry,Account__r.Geo__c,Account__r.FP_A_Parent_industry__c,
                 Account__r.Sales_Territory__r.Provisioning_Geographical_Region__c,
                 Account__r.Sales_Territory__r.Provisioning_Region__c,Account__r.District__c,
                 
                 CreatedDate,LastModifiedDate,Owner.Name,Owner.email,Owner.Username
                 
            from Provisioning_Group__c where id =: pg.id
        ];
        
           	pw.getEpoc(System.today(),pg);
           
           
        test.stopTest();
    } 
    
     @IsTest static void CoverUtility(){
         TriggerHandler.bypass('OpportunityTriggerHandler');
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
          
             Patch__c pat = new Patch__c(PatchName__c = 'Test Patch' );
        insert pat;
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='EMEA';
        pateam.Region__c ='EMEA';
        pateam.Area__c ='EMEA';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        pat.PatchTeam__c=pateam.Id;
        account.Sales_Territory__c = pateam.Id;
        account.Patch__c = pat.Id;
       // insert acc;
        update account;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
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
       test.startTest();
       HTTPResponse resp = new HTTPResponse();
         string testresp = '{"id":"REQ1660252731436","message":"Success"}';
        ProvisioningGroupHttpUtility.testResponse= testresp;
         ProvisioningGroupHttpUtility.callPGBroker(pg.id, testresp);
        ProvisioningGroupHttpUtility.createIntegrationLog(String.valueOf(pg.id),'DB_PGBroker','request',testresp,202,'success'); 
          
        test.stopTest();
    }  
    @IsTest static void Method112() {
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();

        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
        insert testUser;
        // insert PR
        //Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id, Account__c = account.Id, Opportunity__c = opp.Id); //, RecordTypeId = recordTypeId
        //insert testPR;
        Sandbox_Cluster__c sc = new Sandbox_Cluster__c();
        sc.name = 'smba-fra-cluster';
        sc.cloud__c = 'ZSCALERTWO';
        sc.clusterId__c = '2';
        sc.Cluster_External_Id__c = 'ZSCALERTWO-3';
        sc.type__c = 'SMBA';
        insert sc;
        Nanolog_Cluster__c nc = new Nanolog_Cluster__c();
        nc.Name = 'zs2smsmcluster';
        nc.cloud__c = 'ZSCALERTWO';
        nc.clusterId__c = '2';
        nc.Cluster_External_Id__c = 'ZSCALERTWO-3';
        nc.type__c = 'Storage';
        insert nc;
        SMCDSS_DLP_Cluster__c dlpsc = new SMCDSS_DLP_Cluster__c();
        dlpsc.Name = 'smdlpcds-cluster';
        dlpsc.cloud__c = 'ZSCALERTWO';
        dlpsc.clusterId__c = '2062';
        dlpsc.Cluster_External_Id__c = 'ZSCALERTWO-2062';
        dlpsc.type__c = 'DLP_CDSS';
        insert dlpsc;

        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c = 'ZIA';
        pg.Account__c = account.id;
        pg.Provisioning_Process__c = 'New Tenant';
        pg.PG_Request_Type__c = 'Create';
        pg.Preferred_Cloud__c = 'ZscalerTwo.net';
        pg.Opportunity__c = opp.id;
        pg.Sandbox_Cluster__c = sc.id;
        pg.Nanolog_Cluster__c = nc.id;
        pg.SMCDSS_DLP_Cluster__c = dlpsc.id;
        pg.RecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Trial').getRecordTypeId();
        insert pg;


        List < Product2 > prodList = new List < Product2 > ();
        Product2 prod1 = new Product2();
        prod1.Name = 'ZIA-BUS-Edition';
        prod1.ProductCode = 'ZIA-BUS-Edition';
        prod1.Product_Line__c = 'ZIA';
        prod1.Provisioning_Product_Family__c = 'Bundles';
        //prod1.prod
        insert prod1;
        // prod1.

        Product2 prod3 = new Product2();
        prod3.Name = '50,000 Additional URLs';
        prod3.ProductCode = 'ZIA-ADD50K-URLS';
        prod3.Product_Line__c = 'ZIA';
        prod3.Provisioning_Product_Family__c = 'Addon';
        insert prod3;


        Licenses__c lc = new Licenses__c();
        lc.Name = 'URL Filtering';
        lc.Is_JIRA_Ticket_Needed__c = true;
        lc.POC_Quantity__c = '100';
        lc.License_Code__c = 'C_CASB';
        lc.Product__c = prod1.Id;
        insert lc;

        Licenses__c lc1 = new Licenses__c();
        lc1.Name = 'URL Filtering';
        lc1.Is_JIRA_Ticket_Needed__c = true;
        lc1.POC_Quantity__c = '100';
        lc1.License_Code__c = 'C_DLP';
        lc1.Product__c = prod3.Id;
        insert lc1;
        Product_License__c prdLic = new Product_License__c();
        prdLic.License__c = lc.id;
        prdLic.Product__c = prod3.id;
        prdLic.License_Product_Line__c = 'ZIA;ZDX';
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
        prdLic.License_Product_Line__c = 'ZDX';
        prdLic1.License__c = lc1.id;
         prdLic1.Product__c = prod1.id;
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
        pvt.PG_ID__c = pg.id;
        Eventbus.publish(pvt);
        ProvisioningWrapperUpdated pwrp = new ProvisioningWrapperUpdated();
        test.stopTest();
    }
	 @IsTest static void Method113() {
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();

        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
        insert testUser;
        // insert PR
        //Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id, Account__c = account.Id, Opportunity__c = opp.Id); //, RecordTypeId = recordTypeId
        //insert testPR;
        Sandbox_Cluster__c sc = new Sandbox_Cluster__c();
        sc.name = 'smba-fra-cluster';
        sc.cloud__c = 'ZSCALERTWO';
        sc.clusterId__c = '2';
        sc.Cluster_External_Id__c = 'ZSCALERTWO-3';
        sc.type__c = 'SMBA';
        insert sc;
        Nanolog_Cluster__c nc = new Nanolog_Cluster__c();
        nc.Name = 'zs2smsmcluster';
        nc.cloud__c = 'ZSCALERTWO';
        nc.clusterId__c = '2';
        nc.Cluster_External_Id__c = 'ZSCALERTWO-3';
        nc.type__c = 'Storage';
        insert nc;
        SMCDSS_DLP_Cluster__c dlpsc = new SMCDSS_DLP_Cluster__c();
        dlpsc.Name = 'smdlpcds-cluster';
        dlpsc.cloud__c = 'ZSCALERTWO';
        dlpsc.clusterId__c = '2062';
        dlpsc.Cluster_External_Id__c = 'ZSCALERTWO-2062';
        dlpsc.type__c = 'DLP_CDSS';
        insert dlpsc;

        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c = 'ZIA';
        pg.Account__c = account.id;
        pg.Provisioning_Process__c = 'New Tenant';
        pg.PG_Request_Type__c = 'Create';
        pg.Preferred_Cloud__c = 'ZscalerTwo.net';
        pg.Opportunity__c = opp.id;
        pg.Sandbox_Cluster__c = sc.id;
        pg.Nanolog_Cluster__c = nc.id;
        pg.SMCDSS_DLP_Cluster__c = dlpsc.id;
        pg.RecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Subscription').getRecordTypeId();
        insert pg;


        List < Product2 > prodList = new List < Product2 > ();
        Product2 prod1 = new Product2();
        prod1.Name = 'ZIA-BUS-Edition';
        prod1.ProductCode = 'ZIA-BUS-Edition';
        prod1.Product_Line__c = 'ZIA';
        prod1.Provisioning_Product_Family__c = 'Bundles';
        //prod1.prod
        insert prod1;
        // prod1.

        Product2 prod3 = new Product2();
        prod3.Name = '50,000 Additional URLs';
        prod3.ProductCode = 'ZIA-ADD50K-URLS';
        prod3.Product_Line__c = 'ZIA';
        prod3.Provisioning_Product_Family__c = 'Addon';
        insert prod3;


        Licenses__c lc = new Licenses__c();
        lc.Name = 'URL Filtering';
        lc.Is_JIRA_Ticket_Needed__c = true;
        lc.POC_Quantity__c = '100';
        lc.License_Code__c = 'C_CASB';
        lc.Product__c = prod1.Id;
        insert lc;

        Licenses__c lc1 = new Licenses__c();
        lc1.Name = 'URL Filtering';
        lc1.Is_JIRA_Ticket_Needed__c = true;
        lc1.POC_Quantity__c = '100';
        lc1.License_Code__c = 'C_DLP';
        lc1.Product__c = prod3.Id;
        insert lc1;
        Product_License__c prdLic = new Product_License__c();
        prdLic.License__c = lc.id;
        prdLic.Product__c = prod3.id;
        prdLic.License_Product_Line__c = 'ZIA;ZDX';
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
        prdLic.License_Product_Line__c = 'ZDX';
        prdLic1.License__c = lc1.id;
         prdLic1.Product__c = prod1.id;
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
        pvt.PG_ID__c = pg.id;
        Eventbus.publish(pvt);
        ProvisioningWrapperUpdated pwrp = new ProvisioningWrapperUpdated();
        test.stopTest();
    }
    
    
    // commented methods

 /*  @IsTest static void Method1() {
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id,SE_Name__c FROM Opportunity LIMIT 1];
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
        pg.SE_Manager_Email__c = opp.SE_Name__c;
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
         prdLic.License_Product_Line__c ='ZIA;ZDX';
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
          prdLic.License_Product_Line__c ='ZDX';
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
		ProvisioningWrapperUpdated pwrp = new ProvisioningWrapperUpdated();
        test.stopTest();
    } */
    
   
    /* @IsTest static void Method3(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id,SE_Name__c FROM Opportunity LIMIT 1];
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
         Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926.beta',Account__c=account.Id,NS_Org_ID__c='Zscloud.net-3926.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA');
       insert Zsc1;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZDX';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
 pg.Opportunity__c = opp.id;
		pg.Associated_ZIA_Zscaler_Cloud__c  =Zsc1.id;
        pg.SE_Manager_Email__c = opp.SE_Name__c;
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
         prdLic.License_Product_Line__c ='ZIA;ZDX';
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
          prdLic.License_Product_Line__c ='ZDX';
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
         //update pg;
          Provisioning_Event__e pvt1 = new Provisioning_Event__e();
         pvt1.PG_ID__c =pg.id;
         Eventbus.publish(pvt1);
         
         pg.PG_Request_Type__c ='Update';
         update pg;
     Eventbus.publish(pvt1);
           pg.PG_Request_Type__c ='Replace';
         update pg;
     Eventbus.publish(pvt1);
		ProvisioningWrapperUpdated pwrp = new ProvisioningWrapperUpdated();
        test.stopTest();
    } */
    
   /* @IsTest static void Method4(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
         Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926.beta',Account__c=account.Id,NS_Org_ID__c='Zscloud.net-3926.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA');
       insert Zsc1;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZDX';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
      //  pg.Status__c ='Provisioned';
 pg.Opportunity__c = opp.id;
		pg.Associated_ZIA_Zscaler_Cloud__c  =Zsc1.id;
        //  pg.RecordTypeId= recTypeId;
        insert pg;
        Provisioning_Contact__c pcont = new Provisioning_Contact__c();
        pcont.User__c = testuser.id;
        pcont.Provisioning_Group__c = pg.id;
        insert pcont;
        
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
         prdLic.License_Product_Line__c ='ZIA;ZDX';
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
          prdLic.License_Product_Line__c ='ZDX';
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
         //update pg;
          Provisioning_Event__e pvt1 = new Provisioning_Event__e();
         pvt1.PG_ID__c =pg.id;
         Eventbus.publish(pvt1);
        
		ProvisioningWrapperUpdated pwrp = new ProvisioningWrapperUpdated();
        String json = '{"requestID":"REQ1655481609289","prGroupId":"aNU4C0000004DOZWA2","pgNumber":"PRG-02962","sfdcAccountId":"0014C00000isBJtQAM","customerInfo":[{"productionCustomerId":"68368","customerName":null,"cloudName":"ZIA","tenantID":"ZSCALERTWO.NET-67411","tenantName":null,"domain":null,"additionalDomains":null,"tenantStatus":null,"subscriptionId":null,"subscriptionName":null,"accountType":null,"partnerInfo":null,"requestStatus":"success","failureReason":null},{"productionCustomerId":"68368","customerName":null,"cloudName":"ZDX","tenantID":null,"tenantName":null,"domain":null,"additionalDomains":null,"tenantStatus":"Subscription","subscriptionId":null,"subscriptionName":null,"accountType":null,"partnerInfo":null,"requestStatus":"success","failureReason":null}]}';
		ProvisioningWrapperUpdated.parse(json);       
        test.stopTest();
    } */
   
    
   /*  @IsTest static void Method8(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'
            LIMIT 1
        ][0].Id);
        insert testUser;
        // insert PR
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        insert testPR;
         Zscaler_Cloud_ID__c ZSc1= new Zscaler_Cloud_ID__c(Name='Zscloud.net-3926.beta',Account__c=account.Id,NS_Org_ID__c='Zscloud.net-3926.beta',Zscaler_Cloud_Domain__c='testacc.com.au.test1',Org_Name__c='Test Account Org',Cloud_Type__c='ZIA');
       insert Zsc1;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
         pg.Zscaler_Cloud_ID__c=Zsc1.id;
           pg.Opportunity__c = opp.id;
 pg.Opportunity__c = opp.id;
		pg.Associated_ZIA_Zscaler_Cloud__c  =Zsc1.id;
           pg.RecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Subscription').getRecordTypeId();
         pg.PG_Request_Type__c ='Replace';
        
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
        prod3.Provisioning_Product_Family__c='Bundles';
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
         prdLic.License_Product_Line__c ='ZIA;ZDX';
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
          prdLic.License_Product_Line__c ='ZDX';
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
         update pg;
         pg.PG_Request_Type__c ='Replace';
         update pg;
        
		ProvisioningWrapperUpdated pwrp = new ProvisioningWrapperUpdated();
        test.stopTest();
    } */

}