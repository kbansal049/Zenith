@isTest
private class ProvisioningGroupTriggerHandlerTest {
    
    public Static Id trialPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
    public Static Id subsPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();
    private static Id zSCloudRecordTypeId = Schema.getGlobalDescribe().get('Zscaler_Cloud_ID__c').getDescribe().getRecordTypeInfosByName().get('ZPA Cloud ID').getRecordTypeId();

    @TestSetup
    static void testData(){
        Triggerhandler.bypass('AccountTriggerHandler');
        Account testAccount = SB_TestCPQDataUtility.createAccount(1)[0];
        insert testAccount;
          Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow');
        insert account;
        Contact ct = new Contact();
        ct.LastName='lastName';
        ct.Email='test@gm.com';
        ct.AccountId = account.id;
        insert ct;
         ZscalerCustomSetting__c setting = new ZscalerCustomSetting__c();
        setting.Name = 'DefaultPRDecommisionContact';
        setting.Value__c = ct.Id;
        insert setting;
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '  1 - Discovery & Qualification',Validation_Plan__c='Hello',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        insert testUser;
        // insert PR
        //Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        //insert testPR;
      DefaultData__c Dff = new DefaultData__c(name = 'PRCaseCreationDefault', Account_Id__c = account.id, Category__c='Provisioning Request',Priority__c='Medium (P3)',Product__c='ZIA', Stage_Status__c='New',Type__c='Provisioning');
        Insert Dff;

        Zscaler_Cloud_ID__c testZscalerCloudId= new Zscaler_Cloud_ID__c(
            Name='Zscloud.net-3926test1',
            Account__c = testAccount.Id,
            NS_Org_ID__c='Zscloud.net-3926test1.beta',
            Zscaler_Cloud_Domain__c='testacc.com.au.test1',
            Org_Name__c='Test Account Org',
            Cloud_Type__c='ZPA', 
            recordTypeId = zSCloudRecordTypeId, 
            ZPA_Enrolled_Users_L31D_Rollup__c = 1, 
            ZPA_Enrolled_Users_L6M_Rollup__c= 1, 
            ZPA_Enrolled_Users_L90D_Rollup__c= 1);
        insert testZscalerCloudId;

        Provisioning_Group__c testPG = new Provisioning_Group__c();
        testPG.Product_Line__c ='ZIA';
        testPG.Organization_Domain__c = 'testOrg1.com';
        testPG.RecordTypeId = trialPGRecordTypeId;
        testPG.PG_for_Subscription__c = true;
        testPG.Status__c = 'Provisioned';
        testPG.Approval_Status__c = 'Approved';
        insert testPG;

        Product2 testProduct = new Product2();
        testProduct.ProductCode ='ZIA-BUS-EDITION';
        testProduct.name='ZIA-BUS-EDITION';
        testProduct.Product_Line__c ='ZIA';
        testProduct.isActive = true;
        insert testProduct;

        List<Provisioning_Product__c> provisioningProductList = new List<Provisioning_Product__c>();
        Provisioning_Product__c provisioningProduct1 = new Provisioning_Product__c();
        provisioningProduct1.Product__c = testProduct.id;
        provisioningProduct1.Provisioning_Group__c = testPG.id;

        Provisioning_Product__c provisioningProduct2 = new Provisioning_Product__c();
        provisioningProduct2.Product__c = testProduct.id;
        provisioningProduct2.Provisioning_Group__c = testPG.id;

        provisioningProductList.add(provisioningProduct1);
        provisioningProductList.add(provisioningProduct2);

        insert provisioningProductList;
    }

    @IsTest static void Method1(){
           Id trialPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();//IBA-399
   
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        Opportunity opp =[select id from opportunity limit 1];
          Account account =[select id from Account limit 1];
        Zscaler_Cloud_ID__c zCloud = [select id from Zscaler_Cloud_ID__c];
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
         pg.Is_Jira_Ticket_Required__c = true;
         pg.Status__c= 'Initiated';
         pg.Approval_Status__c='Approved';
         pg.Provisioning_Type__c='Auto';
         pg.RecordTypeId= trialPGRecordTypeId; 
        
        insert pg;
        
          Provisioning_Group__c pg1 = new Provisioning_Group__c();
        pg1.Product_Line__c ='ZIA';
         pg1.Sub_Status__c = 'Order Created';
        pg1.Account__c=account.id;
           pg1.Opportunity__c = opp.id;
         pg1.Status__c= 'Waiting';
         pg1.Approval_Status__c='Approved';
         pg1.Provisioning_Type__c='Auto';
         pg1.PG_Request_Type__c = 'Replace';
         pg1.Associated_Provisioning_Group__c =pg.id;
         pg1.RecordTypeId= subsPGRecordTypeId;
        pg1.Renewed_From_Provisioning_Group__c =pg.id;
         pg1.Provisioning_Process__c='Add SKU';
        //  pg.RecordTypeId= recTypeId;
        insert pg1;
        
       test.startTest();
          
         pg.Status__c='Provisioned';
         pg.Zscaler_Cloud_ID__c = zCloud.id;
         update pg;
        pg.Provisioning_Extension_Status__c='Extended';
        pg.Provisioning_Process__c ='Extension';
            update pg;
         pg1.Status__c='Provisioned';
         pg1.Zscaler_Cloud_ID__c = zCloud.id;
        update pg1;
        pg1.Approval_Status__c='Rejected';
        update pg1;
        
	 test.stopTest();
    } 
    
     @IsTest static void Method11(){
           Id trialPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();//IBA-399
   
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        Opportunity opp =[select id from opportunity limit 1];
          Account account =[select id from Account limit 1];
        Zscaler_Cloud_ID__c zCloud = [select id from Zscaler_Cloud_ID__c];
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='CBI';
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
         pg.Is_Jira_Ticket_Required__c = true;
         pg.Status__c= 'Initiated';
         pg.Approval_Status__c='Approved';
         pg.Provisioning_Type__c='Auto';
         pg.RecordTypeId= trialPGRecordTypeId; 
         pg.Provisioning_Process__c='Add SKU';
        insert pg;
        
          Provisioning_Group__c pg1 = new Provisioning_Group__c();
        pg1.Product_Line__c ='CBI';
         pg1.Sub_Status__c = 'Order Created';
        pg1.Account__c=account.id;
           pg1.Opportunity__c = opp.id;
         pg1.Status__c= 'Waiting';
         pg1.Approval_Status__c='Approved';
         pg1.Provisioning_Type__c='Auto';
         pg1.PG_Request_Type__c = 'Replace';
         pg1.Associated_Provisioning_Group__c =pg.id;
         pg1.RecordTypeId= subsPGRecordTypeId;
        //  pg.RecordTypeId= recTypeId;
        insert pg1;
        
       test.startTest();
          
         pg.Status__c='Provisioned';
         pg.Zscaler_Cloud_ID__c = zCloud.id;
         update pg;
        
         pg.Renewed_From_Provisioning_Group__c = pg1.id;
         test.stopTest();
    }  
     
     @IsTest static void Method12(){
           Id trialPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();//IBA-399
   
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        Opportunity opp =[select id from opportunity limit 1];
          Account account =[select id from Account limit 1];
        Zscaler_Cloud_ID__c zCloud = [select id from Zscaler_Cloud_ID__c];
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Account__c=account.id;
         pg.Start_Date__c= System.today();
         pg.End_Date__c= System.today().addDays(29);
           pg.Opportunity__c = opp.id;
         pg.Is_Jira_Ticket_Required__c = true;
         pg.Status__c= 'Initiated';
         pg.Approval_Status__c='Approved';
         pg.Provisioning_Type__c='Auto';
         pg.RecordTypeId= trialPGRecordTypeId; 
         pg.Provisioning_Process__c='New Tenant';
         pg.PG_Request_Type__c ='Create';
        insert pg;
        Provisioning_Product__c prd = new Provisioning_Product__c();
         prd.Start_Date__c= System.today();
         prd.End_Date__c= System.today().addDays(29);
         prd.Provisioning_Group__c=pg.id;
         prd.Name='name';
         insert prd;
       test.startTest();
         pg.Status__c='Requested';
         update pg;
        test.stopTest();
    } 
    /* @IsTest static void Method13(){
           Id trialPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();//IBA-399
   
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        Opportunity opp =[select id from opportunity limit 1];
          Account account =[select id from Account limit 1];
        Zscaler_Cloud_ID__c zCloud = [select id from Zscaler_Cloud_ID__c];
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Account__c=account.id;
         pg.Start_Date__c= System.today();
         pg.End_Date__c= System.today().addDays(29);
           pg.Opportunity__c = opp.id;
         pg.Is_Jira_Ticket_Required__c = true;
         pg.Status__c= 'Initiated';
         pg.Approval_Status__c='Approved';
         pg.Provisioning_Type__c='Auto';
         pg.RecordTypeId= trialPGRecordTypeId; 
         pg.Provisioning_Process__c='New Tenant';
         pg.PG_Request_Type__c ='Create';
          pg.Is_Internal_Provisioning__c = true;
        insert pg;
        Provisioning_Product__c prd = new Provisioning_Product__c();
         prd.Start_Date__c= System.today();
         prd.End_Date__c= System.today().addDays(29);
         prd.Provisioning_Group__c=pg.id;
         prd.Name='name';
         insert prd;
       test.startTest();
         pg.Status__c='Requested';
         update pg;
        test.stopTest();
    } */
    
      // cover jira 
    @IsTest static void Method2(){
        Id subsPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();//IBA-399
   
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        Opportunity opp =[select id from opportunity limit 1];
          Account account =[select id from Account limit 1];
        Zscaler_Cloud_ID__c zCloud = [select id from Zscaler_Cloud_ID__c];
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
         pg.Is_Jira_Ticket_Required__c = true;
         pg.Status__c= 'Provisioning In Progress';
         pg.Approval_Status__c='Approved';
         pg.Provisioning_Type__c='Auto';
         pg.RecordTypeId= subsPGRecordTypeId;
         pg.PG_Request_Type__c = 'Replace';
          //  pg.RecordTypeId= recTypeId;
        insert pg;
        
         Provisioning_Group__c pg1 = new Provisioning_Group__c();
        pg1.Product_Line__c ='ZDX';
         pg1.Sub_Status__c = 'Order Created';
        pg1.Account__c=account.id;
           pg1.Opportunity__c = opp.id;
         pg1.Status__c= 'Waiting';
         pg1.Approval_Status__c='Approved';
         pg1.Provisioning_Type__c='Auto';
         pg1.PG_Request_Type__c = 'Replace';
         pg1.Associated_Provisioning_Group__c =pg.id;
         pg1.RecordTypeId= subsPGRecordTypeId;
        //  pg.RecordTypeId= recTypeId;
        insert pg1;
         Provisioning_Contact__c pcon2 = new Provisioning_Contact__c();
        pcon2.Type__c = 'SALES_ENGINEER';
        pcon2.Provisioning_Group__c=pg.Id;
        Insert pcon2;
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
           pg.Provisioning_Type__c ='Manual';
           pg.Zscaler_Cloud_ID__c = zCloud.id;
         update pg;
        pg.Status__c='Provisioned';
       update pg;
         Case cs = ProvisioningGroupTriggerHandler.prepareCaseRecord(pg,'sub');
        List<Case> csList = new List<Case>();
        csList.add(cs);
        update pg;
         ProvisioningGroupTriggerHandler.caseRetryMethod(csList,1,'Support');
         List<Provisioning_Group__c> lstpg = new List<Provisioning_Group__c>();
         lstpg.add(pg);
         ProvisioningGroupTriggerHandler.getFieldNamesOfSObject('Account');
         ProvisioningGroupTriggerHandler.getPGAndRelatedProvisioningProducts(lstpg);
         pg.Approval_Status__c='Not Submitted';
         update pg;
         pg.Approval_Status__c='Rejected';
         update pg;
         test.stopTest();
    }
    
    @isTest
    static void testAutoCreatePGForSubscription(){
        
        Provisioning_Group__c testPG = [SELECT Id, Zscaler_Cloud_ID__c FROM Provisioning_Group__c WHERE  Organization_Domain__c = 'testOrg1.com' LIMIT 1];
        ZScaler_Cloud_Id__c testZSCloudIdRecord = [SELECT Id FROM ZScaler_Cloud_Id__c WHERE Name = 'Zscloud.net-3926test1' LIMIT 1];
        
        Test.startTest();
            testPG.Zscaler_Cloud_ID__c = testZSCloudIdRecord.Id;
            update testPG;
        Test.stopTest();
    }
    
    @isTest
    static void testSplitCreatePGForSubscription(){
        Opportunity opp =[select id from opportunity limit 1];
        Account account =[select id from Account limit 1];
        Zscaler_Cloud_ID__c zCloud = [select id from Zscaler_Cloud_ID__c]; 
        
         Provisioning_Group__c pg1 = new Provisioning_Group__c();
         pg1.Product_Line__c ='ZIA';
         pg1.Sub_Status__c = 'Waiting for order';
         pg1.Account__c=account.id;
         pg1.Opportunity__c = opp.id;
         pg1.Status__c= 'Waiting';
         pg1.Approval_Status__c='Approved';
         pg1.Provisioning_Type__c='Auto';
         pg1.PG_Request_Type__c = 'Replace';
         pg1.RecordTypeId= subsPGRecordTypeId;
        //  pg.RecordTypeId= recTypeId;
        insert pg1;
         Provisioning_Contact__c pcon2 = new Provisioning_Contact__c();
         pcon2.Type__c = 'SALES_ENGINEER';
         pcon2.Provisioning_Group__c=pg1.Id;
         Insert pcon2;
        Provisioning_Contact__c pcon3 = new Provisioning_Contact__c();
         pcon3.Type__c = 'SALES_ENGINEER';
         pcon3.Provisioning_Group__c=pg1.Id;
         Insert pcon3;
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-BUS-Edition';
        prod1.ProductCode='ZIA-BUS-Edition';
        prod1.Product_Line__c='ZIA';
        prod1.Provisioning_Product_Family__c='Bundles';
        //prod1.prod
        prodList.add(prod1);
        // prod1.
        Product2 prod3 = new Product2();
        prod3.Name='50,000 Additional URLs';
        prod3.ProductCode='ZIA-ADD50K-URLS';
        prod3.Product_Line__c='ZIA';
        prod3.Provisioning_Product_Family__c='Addon';
        prodList.add(prod3);
        insert prodList;
        
        List<Provisioning_Product__c> prdList = New List<Provisioning_Product__c>();
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = pg1.id;
        povPrd.Start_Date__c = Date.today()+30;
        povPrd.End_Date__c = Date.today()+395;
        prdList.add(povPrd);
        Provisioning_Product__c povPrd2 = new Provisioning_Product__c();
        povPrd2.Product__c = prod1.id;
        povPrd2.Provisioning_Group__c = pg1.id;
        povPrd2.Start_Date__c = Date.today()+396;
        povPrd2.End_Date__c = Date.today()+615;
        prdList.add(povPrd2);
     	Provisioning_Product__c povPrd1 = new Provisioning_Product__c();
        povPrd1.Product__c = prod3.id;
        povPrd1.Provisioning_Group__c = pg1.id;
        povPrd1.Start_Date__c = Date.today()+250;
        povPrd1.End_Date__c = Date.today()+615;
        prdList.add(povPrd1);
        insert prdList;
        
        Test.startTest();
        	pg1.Sub_Status__c = 'Order Created';
        	update pg1;
        Test.stopTest();
    } 
    @IsTest static void Method14(){
           Id trialPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();//IBA-399
   
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        Opportunity opp =[select id from opportunity limit 1];
          Account account =[select id from Account limit 1];
        Zscaler_Cloud_ID__c zCloud = [select id from Zscaler_Cloud_ID__c];
        
        Product2 testProduct = new Product2();
        testProduct.ProductCode ='ZIA-TFORM-EDITION';
        testProduct.name='ZIA-TFORM-EDITION';
        testProduct.Product_Line__c ='Cross Platform';
        testProduct.isActive = true;
        insert testProduct;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='CBI';
        pg.Account__c=account.id;
           pg.Opportunity__c = opp.id;
         pg.Is_Jira_Ticket_Required__c = true;
         pg.Status__c= 'Initiated';
         pg.Approval_Status__c='Approved';
         pg.Provisioning_Type__c='Auto';
         pg.RecordTypeId= trialPGRecordTypeId; 
         pg.Provisioning_Process__c='Add SKU';
        insert pg;
        
          Provisioning_Group__c pg1 = new Provisioning_Group__c();
        pg1.Product_Line__c ='CBI';
         pg1.Sub_Status__c = 'Order Created';
        pg1.Account__c=account.id;
           pg1.Opportunity__c = opp.id;
         pg1.Status__c= 'Waiting';
         pg1.Approval_Status__c='Approved';
         pg1.Provisioning_Type__c='Auto';
         pg1.PG_Request_Type__c = 'Replace';
         pg1.Associated_Provisioning_Group__c =pg.id;
         pg1.RecordTypeId= subsPGRecordTypeId;
        //  pg.RecordTypeId= recTypeId;
        insert pg1;
        Provisioning_Product__c prd = new Provisioning_Product__c();
         prd.Start_Date__c= System.today();
         prd.End_Date__c= System.today().addDays(29);
         prd.Provisioning_Group__c=pg.id;
         prd.Name='name';
        prd.Product__c = testProduct.id;
         insert prd;
       test.startTest();
          
         pg.Status__c='Provisioned';
         pg.Zscaler_Cloud_ID__c = zCloud.id;
         update pg;
        
         pg.Renewed_From_Provisioning_Group__c = pg1.id;
         test.stopTest();
    }
    
    @IsTest static void Method15(){
           Id trialPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();//IBA-399
   
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        Opportunity opp =[select id from opportunity limit 1];
          Account account =[select id from Account limit 1];
        Zscaler_Cloud_ID__c zCloud = [select id from Zscaler_Cloud_ID__c];
        
        Product2 testProduct = new Product2();
        testProduct.ProductCode ='ZPA-TFORM-EDITION';
        testProduct.name='ZPA-TFORM-EDITION';
        testProduct.Product_Line__c ='ZPA';
        testProduct.isActive = true;
        insert testProduct;
        
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZPA';
        pg.Account__c=account.id;
        pg.Opportunity__c = opp.id;
         pg.Is_Jira_Ticket_Required__c = true;
         pg.Status__c= 'Initiated';
         pg.Approval_Status__c='Approved';
         pg.Provisioning_Type__c='Auto';
         pg.RecordTypeId= trialPGRecordTypeId; 
         pg.Provisioning_Process__c='New Tenant';
         pg.PG_Request_Type__c = 'Create';
        insert pg;
        
          Provisioning_Group__c pg1 = new Provisioning_Group__c();
        pg1.Product_Line__c ='ZPA';
        pg1.Account__c=account.id;
           pg1.Opportunity__c = opp.id;
         pg1.Status__c= 'Waiting';
         pg1.Approval_Status__c='Submitted';
         pg1.Provisioning_Type__c='Auto';
         pg1.RecordTypeId= trialPGRecordTypeId; 
         pg1.Provisioning_Process__c='New Tenant';
         pg1.PG_Request_Type__c = 'Create';
        //  pg.RecordTypeId= recTypeId;
        insert pg1;
        Provisioning_Product__c prd = new Provisioning_Product__c();
         prd.Start_Date__c= System.today();
         prd.End_Date__c= System.today().addDays(29);
         prd.Provisioning_Group__c=pg.id;
         prd.Name='name';
        prd.Product__c = testProduct.id;
         insert prd;
       	test.startTest();
         
         List<Provisioning_Group__c> pglist = new List<Provisioning_Group__c>();
         pg1.Approval_Status__c='approved';
        pglist.add(pg1);
        pg.Send_for_Provisioning__c = true;
        pglist.add(pg);
         update pglist;
        
         pg.Renewed_From_Provisioning_Group__c = pg1.id;
         test.stopTest();
    }
    @IsTest static void Method16(){
           Id trialPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();//IBA-399
   
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        Opportunity opp =[select id from opportunity limit 1];
          Account account =[select id from Account limit 1];
        Zscaler_Cloud_ID__c zCloud = [select id from Zscaler_Cloud_ID__c];
        
        Product2 testProduct = new Product2();
        testProduct.ProductCode ='ZIA-TFORM-EDITION';
        testProduct.name='ZIA-TFORM-EDITION';
        testProduct.Product_Line__c ='ZIA';
        testProduct.isActive = true;
        insert testProduct;
        
        Nanolog_Cluster__c nc = new Nanolog_Cluster__c();
        nc.name = 'smsm-pdx-cluster';
        nc.SF_Cloud__c = 'Zscalerone.net';
        nc.cloud__c = 'ZSCALERONE';
        nc.Cluster_External_Id__c = 'ZSCALERONE-2';
        insert nc;
        
        Sandbox_Cluster__c sc = new Sandbox_Cluster__c();
        sc.name = 'smba-pdx-cluster';
        sc.SF_Cloud__c = 'Zscalerone.net';
        sc.cloud__c = 'ZSCALERONE';
        sc.Cluster_External_Id__c = 'ZSCALERONE-4';
        insert sc;
        
        
        
        SMCDSS_DLP_Cluster__c smcdss = new SMCDSS_DLP_Cluster__c();
        smcdss.name = 'smsm-pdx-cluster';
        smcdss.SF_Cloud__c = 'Zscalerone.net';
        smcdss.cloud__c = 'ZSCALERONE';
        smcdss.Cluster_External_Id__c = 'ZSCALERONE-2';
        insert smcdss;
        List<Provisioning_Group__c> insertPgList = new List<Provisioning_Group__c>();
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Account__c=account.id;
        pg.Opportunity__c = opp.id;
         pg.Status__c= 'Initiated';
         pg.Approval_Status__c='Approved';
         pg.Provisioning_Type__c='Auto';
         pg.RecordTypeId= trialPGRecordTypeId; 
         pg.Provisioning_Process__c='New Tenant';
         pg.PG_Request_Type__c = 'Create';
        pg.Preferred_Cloud__c = 'Zscalerone.net';
        pg.Nanolog_Cluster__c = nc.id;
            pg.Sandbox_Cluster__c = sc.id;
            pg.SMCDSS_DLP_Cluster__c = smcdss.id;
        insertPgList.add(pg);
        
          Provisioning_Group__c pg1 = new Provisioning_Group__c();
        pg1.Product_Line__c ='ZIA';
        pg1.Account__c=account.id;
           pg1.Opportunity__c = opp.id;
         pg1.Status__c= 'Initiated';
         pg1.Approval_Status__c='Submitted';
         pg1.Provisioning_Type__c='Auto';
         pg1.RecordTypeId= trialPGRecordTypeId; 
         pg1.Provisioning_Process__c='New Tenant';
         pg1.PG_Request_Type__c = 'Create';
        pg1.Preferred_Cloud__c = 'Zscalerone.net';
        pg1.Nanolog_Cluster__c = nc.id;
            pg1.Sandbox_Cluster__c = sc.id;
            pg1.SMCDSS_DLP_Cluster__c = smcdss.id;
        insertPgList.add(pg1);
        Provisioning_Group__c pg2 = new Provisioning_Group__c();
        pg2.Product_Line__c ='ZIA';
        pg2.Account__c=account.id;
           pg2.Opportunity__c = opp.id;
         pg2.Status__c= 'Waiting';
         pg2.Approval_Status__c='Submitted';
         pg2.Provisioning_Type__c='Auto';
         pg2.RecordTypeId= trialPGRecordTypeId; 
         pg2.Provisioning_Process__c='Decommission';
        insertPgList.add(pg2);
        insert insertPgList;
        Provisioning_Product__c prd = new Provisioning_Product__c();
         prd.Start_Date__c= System.today();
         prd.End_Date__c= System.today().addDays(29);
         prd.Provisioning_Group__c=pg.id;
         prd.Name='name';
        prd.Product__c = testProduct.id;
         insert prd;
       	test.startTest();
         
         List<Provisioning_Group__c> pglist = new List<Provisioning_Group__c>();
         pg1.Approval_Status__c='approved';
        pglist.add(pg1);
        pg2.Status__c = 'Request Decommission';
        pglist.add(pg2);
         update pglist;
        
         test.stopTest();
    }
}