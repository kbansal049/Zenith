/**********************************************************************************************************************
* @TestClass	: NFR_ApprovalControllerTest
* @Author   	: Priyanka J
* @Date     	: 31 Dec, 2020
* @Description	: Test Class for NFR_ApprovalController
************************************************************************************************************************/
@IsTest
public class NFR_ApprovalControllerTest {
    
    //Creating testData
    @TestSetup
    public static void createData(){
        
        Id TechPartnerRecordTypeId = Schema.SObjectType.NFR__c.getRecordTypeInfosByName().get('Partners').getRecordTypeId();
        Id AccPartnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        
        Profile coreProfile = [SELECT Id FROM Profile WHERE Name='Power User_New']; 
        User usrMgr = new User(Alias = 'standt1', Email='test@crsy12.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = coreProfile.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='test@coresalesprf123.com', GEO__c='WW');
        insert usrMgr;
        System.assertEquals('WW', usrMgr.GEO__c, 'Geo value is not as expected');
        User usrRec = new User(Alias = 'standt', Email='test@crsy13.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = coreProfile.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='test@coresalesprfManager.com');
        usrRec.ManagerId = usrMgr.Id;        
        insert usrRec;
        System.assertNotEquals(null, usrRec.Id);
        Contact conRec=new Contact(
            FirstName='test',
            LastName = 'test',
            Email = 'Test@gmail.com',
            Phone = '0097438003'); 
        insert conRec;
        System.assertEquals('test', conRec.FirstName, 'Contact FirstName does not match');
        Account accRec=new Account(
            Name='BT UK MSS',
            Account_Manager__c = usrRec.Id,
            RecordTypeId = AccPartnerRecordTypeId); 
        insert accRec;
        System.assert(accRec.Account_Manager__c != null, 'Account Manager is not populated');
        
        //Inserting NFR records
        NFR__c NFR = new NFR__c();
        NFR.Organisation_Domain__c = 'Test';
        NFR.Account_Name__c = accRec.Id;
        NFR.Partner_Contact__c = conRec.Id;
        NFR.Preferred_Cloud__c = 'Zscalereone.net';
        NFR.Send_Initial_Credentials_To__c = 'Partner';
        NFR.NFR_Licence_Status__c = 'Not Active';
        NFR.Approval_Status__c = 'Rejected';
        NFR.ZIA_NFR__c = false;
        NFR.ZPA_NFR__c = true;
        NFR.SIP__c = true;
        NFR.Start_Date__c = system.today();
        NFR.Expiry_Date_FromStartDate__c = system.today();
        NFR.RecordTypeId = TechPartnerRecordTypeId;
        NFR.Is_Customer_Using_ZIA__c = 'Yes';
        NFR.User_Authentication_Domains__c = 'Test';
        NFR.Is_Zapp_used__c = 'Yes';
        insert NFR; 
    }
    @isTest static void testMethod1() {  
        NFR__c NFR = [Select Id, Name from NFR__c]; 
        System.assertNotEquals(null, NFR.Id, 'No NFR is retrieved in query');
        Test.StartTest(); 
        NFR_ApprovalController.submitForApproval(NFR.Id);
        Test.stopTest();
        
    }
}