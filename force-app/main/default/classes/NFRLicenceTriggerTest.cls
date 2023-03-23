@isTest
private class NFRLicenceTriggerTest {

    private static testMethod void test() {
          
        Test.StartTest();
        Id TechPartnerRecordTypeId = Schema.SObjectType.NFR__c.getRecordTypeInfosByDeveloperName().get('Technology_Partners').getRecordTypeId();
        Id partnerRecordTypeId=Schema.SObjectType.NFR__c.getRecordTypeInfosByDeveloperName().get('Partners').getRecordTypeId();
		Id NFRRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('NFR Licence').getRecordTypeId();
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        
        Account portalAccount1 = new Account(Name = 'TestAccount');
        insert portalAccount1;

        Contact contact1 = new Contact(FirstName = 'Test',Lastname = 'Amit',AccountId = portalAccount1.Id,Email = 'test@test.com');
        insert contact1;
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        
        Case cs = new Case(Subject='abcd', AccountId =  portalAccount1.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
        List<Case> csList = new List<Case>();
        csList.add(cs);
        
        Profile profileId2 = [SELECT Id FROM Profile WHERE Name = 'Partner Community User' LIMIT 1];
        Profile profileId  = [SELECT Id  from Profile where Name = 'Core Sales - Sales Ops' LIMIT 1];
        
       
        User ur2 = new User(Email='dummy1@dummy.com77',ProfileId=profileId2.id,LastName='Lastname1',FirstName='Firstname1',
                           Alias='testf',Username='test11@asdf123444.com',TimeZoneSidKey='GMT',LanguageLocaleKey='en_US',
                           EmailEncodingKey='UTF-8',LocaleSidKey='en_US',service_Level__c='L1',IsPortalSelfRegistered=true,contactId = contact1.id);
       
        User ur3 = new User(Email='dummy2@dummy.com22',ProfileId=profileId.id,LastName='Lastname2',FirstName='Firstname2',
                           Alias='test2',Username='test11@asdf123444.com',TimeZoneSidKey='GMT',LanguageLocaleKey='en_US',
                           EmailEncodingKey='UTF-8',LocaleSidKey='en_US',service_Level__c='L1',IsPortalSelfRegistered=true);
        insert ur3;
        Contact c=new Contact(
        FirstName='test',
        LastName = 'test',
        Email = 'Test@gmail.com',
        Phone = '0097438003'); 
        insert c;
        
        Product2 prod = new Product2(Name = 'Test', Product_SKU_External_ID__c = 'ZSC-SIP',
                                     Family = 'Hardware');
        insert prod;
        
        NFR__c NFR = new NFR__c();
        //NFR.Name = 'Test';
        NFR.Organisation_Domain__c = 'Test';
        NFR.Partner_Contact__c = c.Id;
        NFR.Preferred_Cloud__c = 'Zscalereone.net';
        NFR.Send_Initial_Credentials_To__c = 'Partner';
        NFR.NFR_Licence_Status__c = 'Not Active';
        NFR.Approval_Status__c = 'Not-Submitted';
        NFR.ZIA_NFR__c = false;
        NFR.ZPA_NFR__c = true;
        NFR.SIP__c = true;
        NFR.Start_Date__c = system.today();
        NFR.Expiry_Date_FromStartDate__c = system.today();
        NFR.RecordTypeId = TechPartnerRecordTypeId;
        NFR.Is_Customer_Using_ZIA__c = 'Yes';
        NFR.User_Authentication_Domains__c = 'Test';
        NFR.Is_Zapp_used__c = 'Yes';
        
        NFR__c NFR1 = new NFR__c(Organisation_Domain__c = 'Test',Partner_Contact__c = c.Id,Preferred_Cloud__c = 'Zscalereone.net',Send_Initial_Credentials_To__c = 'Partner',NFR_Licence_Status__c = 'Not Active',
                               Approval_Status__c = 'Not-Submitted',ZIA_NFR__c = true,ZPA_NFR__c = true,SIP__c = true,Start_Date__c = system.today(),Expiry_Date_FromStartDate__c = system.today(),
                               RecordTypeId = partnerRecordTypeId,Is_Customer_Using_ZIA__c = 'Yes',User_Authentication_Domains__c = 'Test',Is_Zapp_used__c = 'Yes');
        
        
        NFR__c NFR2 = new NFR__c(Organisation_Domain__c = 'Test',Partner_Contact__c = c.Id,Preferred_Cloud__c = 'Zscalereone.net',Send_Initial_Credentials_To__c = 'Partner',NFR_Licence_Status__c = 'Not Active',
                               Approval_Status__c = 'Not-Submitted',ZIA_NFR__c = true,ZPA_NFR__c = true,SIP__c = false,Start_Date__c = system.today(),Expiry_Date_FromStartDate__c = system.today(),
                               RecordTypeId = partnerRecordTypeId,Is_Customer_Using_ZIA__c = 'Yes',User_Authentication_Domains__c = 'Test',Is_Zapp_used__c = 'Yes');
               
      
        
        
        String zia='ZIA';
        String ziaProduct='ZIA-ELA-Edition';
        List<String> productList= new List<String>();
        productList.add(ziaProduct);
        Map<String,List<String>> cloudSkuMap = new Map<String,List<String>>();
        cloudSkuMap.put('ZIA', productList);
        NFR.Cloud_With_POC_Products__c =JSON.serialize(cloudSkuMap);
        NFR2.Cloud_With_POC_Products__c =JSON.serialize(cloudSkuMap);
        NFR1.Cloud_With_POC_Products__c =JSON.serialize(cloudSkuMap);
        List<NFR__c> NFRList = new List<NFR__c>();
        NFRList.Add(NFR);
        NFRList.Add(NFR1);
		NFRList.Add(NFR2);
        
        insert NFRList;
		NFR.Start_Date__c = system.today()+5;
        Update NFR;
        TriggerUtility2.PRNFRFieldInsertExecutedReset();
        //NFR.Name = 'Test1';
        NFR.Approval_Status__c = 'Approved';
        //NFR.Start_Date__c = system.today().addMonths(1);  
        NFR.NFR_Licence_Status__c = 'In-Progress';
        Update NFR;
        NFR.Approval_Status__c = 'Expiration Requested';
        //NFR.Start_Date__c = system.today().addMonths(1);  
        NFR.NFR_Licence_Status__c = 'Expiration Requested';
        Update NFR;
        NFR.Approval_Status__c = 'Extension Requested';
        //NFR.Start_Date__c = system.today().addMonths(1);  
        NFR.NFR_Licence_Status__c = 'Extension Requested';
        Update NFR;
        NFR.Approval_Status__c = 'Expiration Requested';
        Update NFR;
        NFR.RecordTypeId = partnerRecordTypeId;
        NFR.Approval_Status__c = 'Extended';
        Update NFR;
        NFR.Approval_Status__c = 'Submitted';
        nfr.OwnerId=ur3.Id;
        nfr.NFR_Sales_Engineer__c=uR3.Id;
        Update NFR;
        
        NFR2.NFR_Licence_Status__c = 'Expiration Requested';
        NFR2.Approval_Status__c = 'Expiration Requested';
        Update NFR2;
        
                
        Opportunity opp = new opportunity(Name = 'Test opportunity21', Primary_Quote_Exception__c  = true, AccountId = portalAccount1.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        Provisioning_Request__c pr = new Provisioning_Request__c(Opportunity__c = opp.Id,RecordTypeId = NFRRecordTypeId,NFR_Form_Link__c =NFRList[0].id
                                                                 ,Internal_user__c = false,Account__c = portalAccount1.Id,Send_Initial_l__c = 'SE',SE__c = userinfo.getuserId(),
                                                                 Provisioning_Status__c = 'Requested',ZPA_NFR__c = true);
        insert pr;
        
        
     /*   Case cs1 = new Case(Subject='abcd', AccountId =  portalAccount1.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        cs1.Provisioning_Request__c = pr.Id;
        insert cs1; */
        
        
        
        NFRSupportCaseController instance = new NFRSupportCaseController();
        instance.PRrecId =pr.id;
        instance.ZPAPRrecId =pr.id;
        instance.ZDXPRrecId =pr.id;
        instance.NFRrecId = NFRList[0].id;
        
      //  System.debug(instance.url);
      //  System.debug(instance.caseRec);
        
        
        NFRSupportCaseController instance1 = new NFRSupportCaseController();
        //instance1.PRrecId =pr.id;
        //instance.ZPAPRrecId =pr.id;
        //instance.ZDXPRrecId =pr.id;
        instance1.NFRrecId = NFRList[0].id;
        instance1.url ='csList';
        
      //  System.debug(instance1.url);
      //  System.debug(instance1.caseRec);
        
        
        
        Test.StopTest();
    }
    
    private static testMethod void testTriggerHelper(){
        User us =[Select id from user limit 1];
        string UserId = UserInfo.getUserId();
        set<id> OwnerId = new set<id>();
        OwnerId.add(us.id);
        
        Test.StartTest();
        NFRLicenceTriggerHelper Helper = new NFRLicenceTriggerHelper();
        NFRLicenceTriggerHelper.getAccountOwnerEmails(OwnerId);
        NFRLicenceTriggerHelper.getSpecificUserEMails();
        Test.StopTest();
    }
     @isTest static void testMethod3() {  
            
        Id TechPartnerRecordTypeId = Schema.SObjectType.NFR__c.getRecordTypeInfosByDeveloperName().get('Technology_Partners').getRecordTypeId();
   
        PatchTeam__c territory =  new PatchTeam__c();
        territory.Theater__c = 'WW';
        territory.Region__c = 'WW';
        territory.Area__c = 'WW';
        insert territory;
         
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=territory.Id);
        insert patch;
         
        Account acc2 = new Account(Name = 'Test Account2');
        acc2.CSM_Name_New__c = UserInfo.getUserId();
        acc2.Patch__c=patch.Id;
        acc2.Sales_Territory__c=territory.Id;
         
        INSERT acc2;
         
        Account Acc= [Select Id,Region__c,Sales_Territory__c from Account];
    
        system.debug('territory'+territory);
        system.debug('Account Area'+acc.Sales_Territory__c);
        system.debug('Account Region'+acc.Region__c);
         
        NFR__c NFR3 = new NFR__c(Organisation_Domain__c = 'Test',Preferred_Cloud__c = 'Zscalereone.net',Send_Initial_Credentials_To__c = 'Partner',NFR_Licence_Status__c = 'Not Active',
                                 Account_Name__c=acc.Id,Approval_Status__c = 'Not-Submitted',ZIA_NFR__c = true,ZPA_NFR__c = true,SIP__c = false,Start_Date__c = system.today(),Expiry_Date_FromStartDate__c = system.today(),
                                 RecordTypeId = TechPartnerRecordTypeId,Is_Customer_Using_ZIA__c = 'Yes',User_Authentication_Domains__c = 'Test',Is_Zapp_used__c = 'Yes');
        insert NFR3;

        NFR__c nfr = [SELECT Id,Account_Area__c,Account_Name__c,Approval_Status__c,RecordTypeId  From NFR__c where Id=:NFR3.Id];
      
         
       
        nfr.Approval_Status__c='Extension Requested';
        nfr.NFR_Licence_Status__c='Extended';
       
        update nfr;
     
        

        
    }

}