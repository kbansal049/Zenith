@isTest
public with sharing class ProvisioningRequestTriggerHelperTest {
    
    /*@isTest
public static void runBooster(){
ProvisioningRequestTriggerHelper.booster();
}*/
    //Added by Varun - CR 1003 - Start
    
    //Added by Swathi : CR#1451 Start
    @testSetup static void setup() {
        
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('OpportunityTriggerHandler');
        
        
        Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        //create test User

        User testUser = new User(LastName = 'TestUser',  Email = 'test@zscaler.com', Username = 'testuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id/*, ContactId = [SELECT Id FROM Contact LIMIT 1][0].Id*/);
        testUser.FirstName='Test';
        insert testUser;
        
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        //Account
        Account acctTest = new Account(Name = 'Test Account',Sales_Engineer__c=testUser.id,Type='Prospect');
        insert acctTest;
        
        Contact con = new Contact(Lastname = 'Test',AccountId=acctTest.id);
        insert con;
        
        List<Opportunity> lstopp = new List<Opportunity>();
        Opportunity testOppty = new Opportunity(Name = 'Test Opportunity',SE_Name__c=testUser.id, StageName = label.Stage_1_Alignment,CloseDate = Date.today());
        testOppty.AccountID = acctTest.Id;
          lstopp.add(testOppty);
       // insert testOppty;
         Opportunity testOppty1 = new Opportunity(Name = 'Test Opportunity',SE_Name__c=testUser.id, StageName = label.Stage_6_Closed_Won,CloseDate = Date.today());
        testOppty1.AccountID = acctTest.Id;
       // insert testOppty1;
      lstopp.add(testOppty1);
        insert lstopp;
        
        DefaultData__c Dff = new DefaultData__c(name = 'PRCaseCreationDefault', Account_Id__c = acctTest.id, Category__c='Provisioning Request',Priority__c='Medium (P3)',Product__c='ZIA', Stage_Status__c='New',Type__c='Provisioning');
        Insert Dff;
        
        //Insert Custom Settings
        ZscalerCustomSetting__c setting = new ZscalerCustomSetting__c();
        setting.Name = 'DefaultPRDecommisionContact';
        setting.Value__c = '0034u00002UusGqAAJ';
        insert setting;
        
        //create test PR
        List<Provisioning_Request__c> ListPR = new List<Provisioning_Request__c>();
        Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = acctTest.Id, Opportunity__c=testOppty.Id, RecordTypeId = recordTypeId,Provisioning_Status__c='Requested');
        ListPR.add(testPR);
         Provisioning_Request__c testPR3 = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = acctTest.Id, Opportunity__c=testOppty1.Id, RecordTypeId = recordTypeId,Provisioning_Status__c='Requested');
        ListPR.add(testPR3);
       
     //   Provisioning_Request__c testPR1 = new Provisioning_Request__c(Organization_Domain__c = 'test1.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = acctTest.Id, Opportunity__c=testOppty.Id, RecordTypeId = recordTypeId);
       // ListPR.add(testPR1);
       // Provisioning_Request__c testPR2 = new Provisioning_Request__c(Organization_Domain__c = 'test2.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = acctTest.Id, Opportunity__c=testOppty.Id, RecordTypeId = recordTypeId);
       // ListPR.add(testPR2);
        Insert ListPR;
    }
    
    //addedby shubham
      @IsTest static void testdeception(){
         
      
       
            
        Account account = [select id from Account limit 1];
         
        opportunity opp = [select id from opportunity limit 1];
       // insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        //insert testUser;
        // insert PR
        Provisioning_Request__c testPR =[select id,Organization_Domain__c,Preferred_Cloud__c,Send_Initial_l__c,SE__c,Account__c, Opportunity__c,Provisioning_Status__c
                                         from Provisioning_Request__c where Provisioning_Status__c = 'Requested' limit 1 ];
       // Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        //insert testPR;
     /*   Zscaler_Cloud_ID__c zscal = new Zscaler_Cloud_ID__c();
        zscal.Account__c=account.Id;
        zscal.Org_Name__c='TestOrg';
        zscal.Name='Test88';
        Insert zscal; */
       
         List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZPA-TRANS-EDITION';
        prod1.ProductCode='ZPA-TRANS-EDITION';
        prod1.Product_Line__c='ZPA';
       
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
          System.debug('pocPr=='+pocPr);

       test.startTest();
           System.debug('testPR=='+testPR);
           Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
            testPR.RecordTypeId = recordTypeId;
          testPR.Provisioning_Status__c='Provisioned';
          update testPR;
          System.debug('testPR=='+testPR);
       // jiraWrapper wrp = new jiraWrapper();
        test.stopTest();
    }
    
       //addedby shubham
      @IsTest static void testdeception1(){
         
      
       
            
        Account account = [select id from Account limit 1];
         
        opportunity opp = [select id from opportunity where StageName=:label.Stage_6_Closed_Won limit 1];
			
      
       // insert opp;
        
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        //insert testUser;
        // insert PR
        Provisioning_Request__c testPR =[select id,Organization_Domain__c,Preferred_Cloud__c,Send_Initial_l__c,SE__c,Account__c, Opportunity__c,Provisioning_Status__c
                                         from Provisioning_Request__c where Provisioning_Status__c = 'Requested' and Opportunity__r.stagename=:label.Stage_6_Closed_Won limit 1 ];
       // Provisioning_Request__c testPR = new Provisioning_Request__c(Organization_Domain__c = 'test.domain.com', Preferred_Cloud__c = 'Zscaler.net', Send_Initial_l__c = 'SE', SE__c = testUser.Id,Account__c = account.Id, Opportunity__c=opp.Id);//, RecordTypeId = recordTypeId
        //insert testPR;
     /*   Zscaler_Cloud_ID__c zscal = new Zscaler_Cloud_ID__c();
        zscal.Account__c=account.Id;
        zscal.Org_Name__c='TestOrg';
        zscal.Name='Test88';
        Insert zscal; */
       
         List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZIA-TRANS-EDITION';
        prod1.ProductCode='ZIA-TRANS-EDITION';
        prod1.Product_Line__c='ZIA';
    
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
          System.debug('pocPr=='+pocPr);

       test.startTest();
           System.debug('testPR=='+testPR);
           Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
            testPR.RecordTypeId = recordTypeId;
          testPR.Provisioning_Status__c='Provisioned';
          update testPR;
          System.debug('testPR=='+testPR);
       // jiraWrapper wrp = new jiraWrapper();
        test.stopTest();
    }
    
     //Added by Varun - CR 1003 - Start
    @isTest//(SeeAllData=true)
    public static void testWorkflowOptimization(){
        TriggerUtility.SkipAccTriggerExecuted();
        Test.startTest();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
       
        Patch__c pat = new Patch__c(PatchName__c = 'Test Patch' );
        insert pat;
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='Americas';
        pateam.Region__c ='US West';
        pateam.Area__c ='US South West';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        pat.PatchTeam__c=pateam.Id;
        acc.Sales_Territory__c = pateam.Id;
        acc.Patch__c = pat.Id;
        insert acc;
        Opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        
        insert pr;
        pateam.Theater__c='Public Sector';
        update pateam;
        pr.Send_Initial_l__c = 'SE';
        update pr;
        pateam.Region__c='EMEA';
        update pateam;
        update pr;
        pateam.Region__c='APJ';
        update pateam;
        update pr;
        Test.stopTest();
    }//Added by Varun - CR 1003 - End
    
    
    //Added by Swathi : CR#1451 Start
    @isTest
    public static void test(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        TriggerUtility.SkipAccTriggerExecuted();
         Test.startTest();
        Patch__c pat = new Patch__c(PatchName__c = 'Test Patch' );
        insert pat;
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='Americas';
        pateam.Region__c ='US West';
        pateam.Area__c ='US South West';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        pat.PatchTeam__c=pateam.Id;
        acc.Sales_Territory__c = pateam.Id;
        acc.Patch__c = pat.Id;
        insert acc;
        //DefaultData__c Dff1 = new DefaultData__c(name = 'PRCaseCreationDefault', Account_Id__c = acc.id, Category__c='Provisioning Request',Priority__c='Medium (P3)',Product__c='ZIA', Stage_Status__c='New',Type__c='Provisioning');
        //Insert Dff1;
        Opportunity opp = new opportunity(Name = 'Test opportunity21', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        Id ZPAInteractiveRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('ZPA Interactive').getRecordTypeId();
        Id NFRRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('NFR Licence').getRecordTypeId();
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        List<Provisioning_Request__c> prList = new List<Provisioning_Request__c>();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Internal_user__c = false;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'Requested';
        pr.ZPA_NFR__c = true;
        prList.add(pr);
        Provisioning_Request__c pr1 = new Provisioning_Request__c();
        pr1.Opportunity__c = opp.Id;
        pr1.RecordTypeId = ZPAInteractiveRecordTypeId;
        pr1.Internal_user__c = false;
        pr1.Account__c = acc.Id;
        pr1.Send_Initial_l__c = 'SE';
        pr1.SE__c = userinfo.getuserId();
        pr1.Provisioning_Status__c = 'Requested';
        pr1.ZIA_NFR__c = true;
        prList.add(pr1);
       
        insert prList;
        Test.stopTest();
    }
    
    @isTest
    public static void test11(){
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.updateSENameFromAccountExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        TriggerUtility.ProspectEntitlementExecuted();
        Triggerhandler.bypass('OpportunityTriggerHandler');
        
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        
        PatchTeam__c pateam = new PatchTeam__c(Name = 'patchteam',Theater__c='Americas',Region__c ='US West',Area__c ='US South West',Territory_Type__c ='Channel');
        insert pateam;
        Patch__c pat = new Patch__c(PatchName__c = 'Test Patch',PatchTeam__c=pateam.Id );
        insert pat;
        acc.Sales_Territory__c = pateam.Id;
        acc.Patch__c = pat.Id;
        insert acc;
        
        Opportunity opp = new opportunity(Name = 'Test opportunity21', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        Contact c=new Contact(FirstName='test',LastName = 'test',Email = 'Test@gmail.com',Phone = '0097438003'); 
        insert c;
        Id TechPartnerRecordTypeId = Schema.SObjectType.NFR__c.getRecordTypeInfosByName().get('Partners').getRecordTypeId();
        NFR__c NFR1 = new NFR__c(Organisation_Domain__c = 'Test',Partner_Contact__c = c.Id,Preferred_Cloud__c = 'Zscalereone.net',Send_Initial_Credentials_To__c = 'Partner',NFR_Licence_Status__c = 'Not Active',
                                 Approval_Status__c = 'Approved',ZIA_NFR__c = true,ZPA_NFR__c = true,SIP__c = true,Start_Date__c = system.today(),Expiry_Date_FromStartDate__c = system.today(),
                                 RecordTypeId = TechPartnerRecordTypeId,Is_Customer_Using_ZIA__c = 'Yes',User_Authentication_Domains__c = 'Test',Is_Zapp_used__c = 'Yes');
        insert NFR1;
        
        Id ZPAInteractiveRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('ZPA Interactive').getRecordTypeId();
        Id NFRRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('NFR Licence').getRecordTypeId();
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        List<Provisioning_Request__c> prList = new List<Provisioning_Request__c>();
        Provisioning_Request__c pr = new Provisioning_Request__c(Opportunity__c = opp.Id,RecordTypeId = NFRRecordTypeId,NFR_Form_Link__c = NFR1.Id
                                                                 ,Internal_user__c = false,Account__c = acc.Id,Send_Initial_l__c = 'SE',SE__c = userinfo.getuserId(),
                                                                 Provisioning_Status__c = 'Requested',ZPA_NFR__c = true);
        prList.add(pr);
        Provisioning_Request__c pr1 = new Provisioning_Request__c(Opportunity__c = opp.Id,RecordTypeId = ZPAInteractiveRecordTypeId,NFR_Form_Link__c = NFR1.Id
                                                                  ,Internal_user__c = false,Account__c = acc.Id,Send_Initial_l__c = 'SE',SE__c = userinfo.getuserId(),
                                                                  Provisioning_Status__c = 'Requested',ZPA_NFR__c = true);
        prList.add(pr1);
        Test.startTest();
        insert prList;
        Test.stopTest();
    }
    
    @isTest
    public static void test7(){
        List<Provisioning_Request__c> newPRRec = [select Provisioning_Status__c from Provisioning_Request__c where Organization_Domain__c = 'test.domain.com' limit 1];
        User testUser = [Select  id,name from User limit 1 ];
        Account acctTest2 = new Account(Name = 'Test Account',Sales_Engineer__c=testUser.id,Type='Prospect');
        insert acctTest2;
        
        Contact c=new Contact(
        FirstName='test',
        LastName = 'test',
        Email = 'Test@gmail.com',
        Phone = '0097438003'); 
        insert c;
        
        Contact c2=new Contact(
        FirstName='test',
        LastName = 'test',
        Email = 'Test@gmail.com',
        Phone = '0097438003'); 
        insert c2;
        Id partnerRecordTypeId=Schema.SObjectType.NFR__c.getRecordTypeInfosByDeveloperName().get('Partners').getRecordTypeId();
        NFR__c NFR2 = new NFR__c(Organisation_Domain__c = 'Test',Partner_Contact__c = c.Id,Preferred_Cloud__c = 'Zscalereone.net',Send_Initial_Credentials_To__c = 'Partner',NFR_Licence_Status__c = 'Not Active',
                               Approval_Status__c = 'Not-Submitted',ZIA_NFR__c = true,ZPA_NFR__c = true,SIP__c = false,Start_Date__c = system.today(),Expiry_Date_FromStartDate__c = system.today(),
                               RecordTypeId = partnerRecordTypeId,Is_Customer_Using_ZIA__c = 'Yes',User_Authentication_Domains__c = 'Test',Is_Zapp_used__c = 'Yes');
               
 		insert NFR2;
        newPRRec[0].NFR_Form_Link__c=NFR2.id;
        if(!newPRRec.isEmpty()){
            Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('NFR Licence').getRecordTypeId();
            newPRRec[0].RecordTypeId = recordTypeId;
            newPRRec[0].Provisioning_Status__c = 'Requested';
            newPRRec[0].Additional_Organization_domains__c = 'Testdomain@zscaler.com';
            newPRRec[0].NFR_SE_Email_PR__c = 'ndeshpande@zscaler.com.invalid';
            newPRRec[0].Number_of_Users__c = 400;
            newPRRec[0].Organization_Domain__c = 'test domain';
            newPRRec[0].Eval_Comments__c = 'Test Comments ';
            newPRRec[0].Send_Initial_l__c = 'Partner';
            newPRRec[0].User_Authentication_Domains__c = 'domain';
            newPRRec[0].Is_Customer_Using_ZIA__c = 'Yes';
            newPRRec[0].Is_Zapp_used__c = 'Yes';
            newPRRec[0].Partner_Contact__c=c2.Id;
            //newPRRec[0].Account__c=acctTest2.id;
            update newPRRec[0];
            newPRRec[0].Provisioning_Status__c='Provisioned';
            newPRRec[0].Product_Line_for_PR__c='ZDX';
            update newPRRec[0];
            //Id NFRRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('NFR Licence').getRecordTypeId();
            //newPRRec[0].RecordTypeId = NFRRecordTypeId;
            //update newPRRec[0];
        }
    }
    @isTest
    public static void test3(){
        List<Provisioning_Request__c> newPRRec = [select Provisioning_Status__c from Provisioning_Request__c where Organization_Domain__c = 'test1.domain.com' limit 1];
        system.debug(newPRRec.size());
        if(!newPRRec.isEmpty()){
            newPRRec[0].Provisioning_Status__c = 'Purge Stopped';
            update newPRRec;
            ProvisioningRequestTriggerHelper.createCase(newPRRec[0], 'Test Purged', False, False,false);
        }
    }
    @isTest
    public static void test4(){
        List<Provisioning_Request__c> newPRRec = [select Provisioning_Status__c from Provisioning_Request__c where Organization_Domain__c = 'test2.domain.com' limit 1];
        system.debug(newPRRec.size());
        if(!newPRRec.isEmpty()){
            newPRRec[0].Provisioning_Status__c = 'Request Decommission';
            try{
                update newPRRec;
            }catch(exception e){
                
            }
            
        }
    }
    @isTest
    public static void test2(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        TriggerUtility.SkipAccTriggerExecuted();
         Test.startTest();
        Patch__c pat = new Patch__c(PatchName__c = 'Test Patch' );
        insert pat;
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='Public Sector';
        //pateam.Region__c ='US West';
        pateam.Area__c ='SLED';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        pat.PatchTeam__c=pateam.Id;
        acc.Sales_Territory__c = pateam.Id;
        acc.Patch__c = pat.Id;
        insert acc;
        Opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        pr.ZIA_NFR__c = true;
       
        insert pr;
        Test.stopTest();
    }
    
    @isTest
    public static void test5(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        TriggerUtility.SkipAccTriggerExecuted();
          Test.startTest();
        Patch__c pat = new Patch__c(PatchName__c = 'Test Patch' );
        insert pat;
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='International';
        pateam.Region__c ='EMEA';
        pateam.Area__c ='EMEA';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        pat.PatchTeam__c=pateam.Id;
        acc.Sales_Territory__c = pateam.Id;
        acc.Patch__c = pat.Id;
        insert acc;
        Opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        pr.ZIA_NFR__c = true;
      
        insert pr;
        Test.stopTest();
    }
    
    @isTest
    public static void test6(){
        TriggerUtility.SkipAccTriggerExecuted();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        TriggerUtility.SkipAccTriggerExecuted();
        Patch__c pat = new Patch__c(PatchName__c = 'Test Patch' );
          Test.startTest();
        insert pat;
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='International';
        pateam.Region__c ='APJ';
        pateam.Area__c ='APJ';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        pat.PatchTeam__c=pateam.Id;
        acc.Sales_Territory__c = pateam.Id;
        acc.Patch__c = pat.Id;
        insert acc;
        Opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
      
        insert pr;
        Test.stopTest();
    }
    
    @isTest
    public static void test8(){
        Provisioning_Request__c newPRRec = [select id, Provisioning_Status__c from Provisioning_Request__c where Organization_Domain__c = 'test.domain.com' limit 1];
        if(newPRRec.id != NULL){
            Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
            newPRRec.RecordTypeId = recordTypeId;
            newPRRec.Provisioning_Status__c = 'To be Purged';
            try{
                update newPRRec;
            }catch(exception e){
                
            }
            
        }
    }
    @isTest
    public static void test9(){
        List<Provisioning_Request__c> newPRRec = [select Provisioning_Status__c from Provisioning_Request__c where Organization_Domain__c = 'test.domain.com' limit 3];
        system.debug(newPRRec.size());
        if(!newPRRec.isEmpty()){
            Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
            newPRRec[0].RecordTypeId = recordTypeId;
            newPRRec[0].Provisioning_Status__c = 'Provisioned';
            update newPRRec;
            newPRRec[0].Provisioning_Status__c = 'Production';
            update newPRRec;
            newPRRec[0].Provisioning_Status__c = 'Decommissioned';
            update newPRRec;
        }
    }
    //Added by Swathi : CR#1451 Ends
    
    @isTest
    public static void test12(){
        List<Provisioning_Request__c> newPRRec = [select Provisioning_Status__c from Provisioning_Request__c where Organization_Domain__c = 'test.domain.com' limit 1];
        system.debug(newPRRec.size());
        if(!newPRRec.isEmpty()){
            Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
            newPRRec[0].RecordTypeId = recordTypeId;
            newPRRec[0].Provisioning_Status__c = 'Requested';
            newPRRec[0].Approval_Status__c='Approved';
            try{
                update newPRRec;
            }catch(exception e){
                
            }
        }
    }
    
	@isTest
    public static void test112(){
        Provisioning_Request__c newPRRec = [select id, Provisioning_Status__c from Provisioning_Request__c where Organization_Domain__c = 'test.domain.com' limit 1];
        if(newPRRec.id != NULL){
            Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
            newPRRec.RecordTypeId = recordTypeId;
            newPRRec.Provisioning_Status__c = 'Purge Stopped';
            try{
                update newPRRec;
            }catch(exception e){
                
            }
            
        }
    }
     
    @IsTest static void testdeception2(){
         
      
       
            
        Account account = [select id from Account limit 1];
         
        opportunity opp = [select id from opportunity limit 1];
        opp.StageName = '5A - Submitted for Order Review';
        opp.Primary_Competitor__c = 'Netskope';
        opp.Secondary_Competitors__c = 'Netskope';
        triggerhandler.bypass('OpportunityTriggerHandler');
        update opp;
        triggerhandler.clearBypass('OpportunityTriggerHandler');
        User testUser = new User(LastName = 'TestUser', Email = 'test@zscaler.com', Username = 'tes321tuser@zscaler.com', alias = 'testaaa', timezonesidkey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', EmailEncodingKey='ISO-8859-1', ProfileId = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' LIMIT 1][0].Id);
        //insert testUser;
        // insert PR
        Provisioning_Request__c testPR =[select id,Organization_Domain__c,Preferred_Cloud__c,Send_Initial_l__c,SE__c,Account__c, Opportunity__c,Provisioning_Status__c
                                         from Provisioning_Request__c where Provisioning_Status__c = 'Requested' limit 1 ];
       
         List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name='ZPA-TRANS-EDITION';
        prod1.ProductCode='ZPA-TRANS-EDITION';
        prod1.Product_Line__c='ZPA';
       
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
          System.debug('pocPr=='+pocPr);

       test.startTest();
           System.debug('testPR=='+testPR);
           Id recordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
            testPR.RecordTypeId = recordTypeId;
          testPR.Provisioning_Status__c='Provisioned';
          update testPR;
          System.debug('testPR=='+testPR);
       // jiraWrapper wrp = new jiraWrapper();
        test.stopTest();
    }
}