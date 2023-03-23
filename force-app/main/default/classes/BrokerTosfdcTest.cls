@istest
public class BrokerTosfdcTest {
    
   /* @testSetUp
    static void dataSetUp(){
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
        
          User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
          insert testUser;
        // insert PR
          Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
          insert testPR;
     
        Provisioning_Group__c pg = new Provisioning_Group__c();
            pg.Product_Line__c ='ZIA';
        	pg.Provisioning_Request__c = testPR.id;
        	pg.Account__c=account.id;
        	pg.RecordTypeId= recTypeId;
        insert pg;
        
        
        
    }  */
    
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
        
          User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
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
        /* cInf.cloudName='ZIA';
         cInf.tenantID='Zia -tenant';
         cInf.requestStatus='Success';  */
         lstcinfo.add(cinf);
        
         ProvisioningBrokerWrapper pw = new ProvisioningBrokerWrapper();
         /*pw.requestID ='22324';
         pw.prGroupId = pg.id;
         pw.sfdcAccountId = String.valueOf(account.id);
         pw.customerInfo = lstcinfo; */
         
         RestRequest req = new RestRequest(); 
         req.requestBody = null;//BLOB.valueOf(JSON.serializePretty(pw));
         
          req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZSCMTOSFDC'; 
        RestContext.request = req; 
        RestResponse res = new RestResponse();
        RestContext.response= res;
        
        Test.startTest();
        BROKERTOSFDC.doPost();
         
        /*  pw.requestID =null;
         pw.prGroupId = pg.id;
         pw.sfdcAccountId = String.valueOf(account.id);
         pw.customerInfo = lstcinfo; */
         
         RestRequest req2 = new RestRequest(); 
         req.requestBody = null;//BLOB.valueOf(JSON.serializePretty(pw));
         
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
        
          User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
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
        
          User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
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
         cInf.tenantID='Zia -tenant';
         cInf.requestStatus='Success';
         lstcinfo.add(cinf);
        
         ProvisioningBrokerWrapper pw = new ProvisioningBrokerWrapper();
         pw.requestID ='';
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
        Test.stopTest();
         
         
         
     }
    
     @IsTest static void Method3(){
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
        
          User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
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
         cInf.tenantID='Zia -tenant';
         cInf.requestStatus='Success';
         lstcinfo.add(cinf);
        
         ProvisioningBrokerWrapper pw = new ProvisioningBrokerWrapper();
         pw.requestID ='22324';
         pw.prGroupId = '';//pg.id;
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
          
            pw.requestID ='2324';
         pw.prGroupId ='as468348732jdh';
         pw.sfdcAccountId = String.valueOf(account.id);
         pw.customerInfo = lstcinfo;
           BROKERTOSFDC.doPost();
        Test.stopTest();
         
         
         
     } 
     
      @IsTest static void Method4(){
          Id recTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByDeveloperName().get('Trial').getRecordTypeId();
   
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
        
          User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
          insert testUser;
        // insert PR
          Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
          insert testPR;
     
        Provisioning_Group__c pg = new Provisioning_Group__c();
            pg.Product_Line__c ='ZIA';
        	pg.Provisioning_Request__c = testPR.id;
        	pg.Account__c=account.id;
        	pg.RecordTypeId= recTypeId;
        insert pg;
        
         List< ProvisioningBrokerWrapper.cls_customerInfo> lstcinfo = new  List<ProvisioningBrokerWrapper.cls_customerInfo>();
        ProvisioningBrokerWrapper.cls_customerInfo cInf = new ProvisioningBrokerWrapper.cls_customerInfo();
         cInf.cloudName='ZIA';
         cInf.tenantID='Zia -tenant';
         cInf.requestStatus='Success';
         lstcinfo.add(cinf);
        
         ProvisioningBrokerWrapper pw = new ProvisioningBrokerWrapper();
         pw.requestID ='22324';
         pw.prGroupId = pg.id;
         pw.sfdcAccountId =''; //String.valueOf(account.id);
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
       // Test.stopTest();
         
        //
         ProvisioningBrokerWrapper.cls_customerInfo cInf1 = new ProvisioningBrokerWrapper.cls_customerInfo();
         cInf1.cloudName='ZIA';
         cInf1.tenantID='Zia -tenant';
         cInf1.requestStatus='Failure';
           lstcinfo.add(cInf1);
         pw.requestID ='22324';
         pw.prGroupId = pg.id;
         pw.sfdcAccountId = String.valueOf(account.id);
         pw.customerInfo = lstcinfo;
         
        
         req.requestBody = BLOB.valueOf(JSON.serializePretty(pw));
         
          req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/ZSCMTOSFDC'; 
        RestContext.request = req; 
        RestResponse res1 = new RestResponse();
        RestContext.response= res1;
        
       // Test.startTest();
        BROKERTOSFDC.doPost();
        Test.stopTest();
         
         
     }
 

     @IsTest static void Method5(){
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
        
          User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
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
         cInf.tenantID='Zia -tenant';
         cInf.requestStatus='Success';
         lstcinfo.add(cinf);
        
         ProvisioningBrokerWrapper pw = new ProvisioningBrokerWrapper();
         pw.requestID ='';
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
         
          pw.requestID ='32453';
         pw.prGroupId = String.valueOf(account.id);
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



}