@isTest
public class trg_ProvProductHandler_Test {
    
 
      @IsTest static void Method3(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();

               

        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow');
          
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
        insert account;
          System.debug(account.Sales_Territory__c+'Sales_Territory__c=='+account.Sales_Territory__r.Theater__c);
     
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '  1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
          opp.Allow_Move_Stage_To_Next__c = true;

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
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
         pg.Opportunity__c = opp.id;
          pg.Zscaler_Cloud_ID__c = zscal.id;
          pg.Preferred_Cloud__c = 'Zscaler.net';
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
        
        lc1.Product__c =prod1.Id;
        insert lc1;
        Product_License__c prdLic = new Product_License__c();
        prdLic.License__c = lc.id;
          prdLic.License_Product_Line__c ='ZDX';
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
        
        String json = '{"Summary":"Enable CASB","Region":null,"PRGId":"aFE8J0000004I9oWAE","Description":"Please assign CASB cluster for ORGID-null","customerId":null,"Cluster":"SMCASB","Cloud":"ZSNet","accountName":"Test Account","accountId":"0018J000009oRcwQAE"}';
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
       
        test.startTest();
       // jiraWrapper wrp = new jiraWrapper();
        jiraWrapper.getjiraJson(pg.id);
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
       
          jiraWrapper.parse(json);
           jiraWrapper.getjiraJson(pg.id);
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
       
           pateam.Theater__c='APJ';
       // pateam.Region__c ='EMEA';
       // pateam.Area__c ='EMEA';
           update pateam;
           jiraWrapper.getjiraJson(pg.id);
          
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
       
         pateam.Theater__c='WW Enterprise';
          pateam.Area__c ='AMS';
           update pateam;
           jiraWrapper.getjiraJson(pg.id);
          
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
       
         pateam.Theater__c='WW Enterprise';
          pateam.Area__c ='EMEA';
           update pateam;
           jiraWrapper.getjiraJson(pg.id);
        
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
       
         pateam.Theater__c='WW Enterprise';
          pateam.Area__c ='APJ';
           update pateam;
           jiraWrapper.getjiraJson(pg.id);
        test.stopTest();
    }

   @IsTest static void Method4(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();

        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow');
       
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
        
       insert account;
          System.debug(account.Sales_Territory__c+'Sales_Territory__c=='+account.Sales_Territory__r.Theater__c);
     
        
        opportunity opp = new opportunity( Name = 'Test opportunity', AccountId = account.Id, Amount = 20,
                                          CloseDate = system.Today()+30,Architect__c = UserInfo.getUserId(),
                                          StageName = '  1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
       opp.Allow_Move_Stage_To_Next__c = true;

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
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
         pg.Opportunity__c = opp.id;
          pg.Zscaler_Cloud_ID__c = zscal.id;
          pg.Preferred_Cloud__c = 'Zscaler.net';
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
        
        
        
        Licenses__c lc = new Licenses__c();
        lc.Name = 'URL Filtering';
        lc.Is_JIRA_Ticket_Needed__c = true;
        lc.POC_Quantity__c ='100';
        lc.License_Code__c = 'C_DLP';
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
         prdLic.Product__c =prod1.id;
        insert prdLic;
        Product_License__c prdLic1 = new Product_License__c();
        prdLic1.License__c = lc1.id;
           prdLic.Product__c =prod1.id;
        insert prdLic1;
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = pg.id;
        insert povPrd;
     Provisioning_Product__c povPrd1 = new Provisioning_Product__c();
        povPrd1.Product__c = prod1.id;
        povPrd1.Provisioning_Group__c = pg.id;
        insert povPrd1;
        
        String json = '{"Summary":"Enable CASB","Region":null,"PRGId":"aFE8J0000004I9oWAE","Description":"Please assign CASB cluster for ORGID-null","customerId":null,"Cluster":"SMCASB","Cloud":"ZSNet","accountName":"Test Account","accountId":"0018J000009oRcwQAE"}';
        
        test.startTest();
       // jiraWrapper wrp = new jiraWrapper();
        jiraWrapper.getjiraJson(pg.id);
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
       
        pateam.Theater__c='WW Commercial';
          pateam.District__c ='EMEA';
       // pateam.Region__c ='EMEA';
       // pateam.Area__c ='EMEA';
           update pateam;
           jiraWrapper.getjiraJson(pg.id);
       
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
       
         pateam.Theater__c='WW Commercial';
          pateam.District__c ='APJ';
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
       
         pateam.Theater__c='WW Commercial';
          pateam.District__c ='AMS';
       // pateam.Region__c ='EMEA';
       // pateam.Area__c ='EMEA';
           update pateam;
           jiraWrapper.getjiraJson(pg.id);
       
       
       
         Set<Id> lstidNew = new Set<Id>();
       lstidNew.add(pg.id);
       trg_ProvProductHandler.updateNSSPG(lstidNew);
        test.stopTest();
    }

    @IsTest static void Method5(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();

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
                                          StageName = '  1 - Discovery & Qualification',
                                          Flexible_Identifier__c = Null,Type='New Business',Opportunity_Area_Director__c= UserInfo.getUserId() , 
                                          Opportunity_Account_Manager__c =  UserInfo.getUserId() ,SE_Name__c = UserInfo.getUserId()
                                         );
        opp.Allow_Move_Stage_To_Next__c = true;

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
        Provisioning_Group__c pg = new Provisioning_Group__c();
        pg.Product_Line__c ='ZIA';
        pg.Provisioning_Request__c = testPR.id;
        pg.Account__c=account.id;
         pg.Opportunity__c = opp.id;
          pg.Zscaler_Cloud_ID__c = zscal.id;
          pg.Preferred_Cloud__c = 'Zscaler.net';
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
        
        
        
        Licenses__c lc3 = new Licenses__c();
        lc3.Name = 'URL Filtering';
        lc3.Is_JIRA_Ticket_Needed__c = true;
        lc3.POC_Quantity__c ='100';
        lc3.License_Code__c = 'C_DLP';
        lc3.Product__c =prod1.Id;
        insert lc3;
         
          Licenses__c lc2 = new Licenses__c();
        lc2.Name = 'URL Filtering';
        lc2.Is_JIRA_Ticket_Needed__c = true;
        lc2.POC_Quantity__c ='100';
        lc2.License_Code__c = 'C_CASB';
        lc2.Product__c =prod1.Id;
        insert lc2;
        
      
        Product_License__c prdLic = new Product_License__c();
        prdLic.License__c = lc3.id;
         prdLic.Product__c =prod1.id;
        insert prdLic;
         
          Product_License__c prdLic1 = new Product_License__c();
        prdLic1.License__c = lc2.id;
         prdLic1.Product__c =prod1.id;
        insert prdLic1;
       
        Provisioning_Product__c povPrd = new Provisioning_Product__c();
        povPrd.Product__c = prod1.id;
        povPrd.Provisioning_Group__c = pg.id;
        insert povPrd;
 
        
        String json = '{"Summary":"Enable CASB","Region":null,"PRGId":"aFE8J0000004I9oWAE","Description":"Please assign CASB cluster for ORGID-null","customerId":null,"Cluster":"SMCASB","Cloud":"ZSNet","accountName":"Test Account","accountId":"0018J000009oRcwQAE"}';
        
        test.startTest();
       // jiraWrapper wrp = new jiraWrapper();
        jiraWrapper.getjiraJson(pg.id);
          salestert.Theater__c ='APJ';
          update salestert;
          jiraWrapper.parse(json);
           jiraWrapper.getjiraJson(pg.id);
           salestert.Theater__c ='EMEA';
          update salestert;
           jiraWrapper.getjiraJson(pg.id);
        test.stopTest();
    }

    //cover NssCloudcompController class
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
         opp.Allow_Move_Stage_To_Next__c = true;

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
          prdLic.License_Product_Line__c ='ZDX';
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
        NSSCloudCompController obj = new NSSCloudCompController();
        obj.prgIdRec = pg.id;
     	 obj.getPRGrecord();
        test.stopTest();
    } 
    
    
    /*  @IsTest static void CoverTime(){
        Id recTypeId = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByDeveloperName().get('ZscmToSfdc').getRecordTypeId();
        
        Account account = new Account(Name = 'Test Account',Solution_Architect__c = UserInfo.getUserId(),Type = 'Prospect',
                                      Last_Architecture_Workshop_Date__c = system.today().addDays(-30),billingCountry='Lucknow');
          
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
        
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
        
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
        
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
                 
                 from Provisioning_Group__c  where id =:pg.id];
        
           	pw.getEpoc(System.today(),pg);
           
           
        test.stopTest();
    } */

   
}