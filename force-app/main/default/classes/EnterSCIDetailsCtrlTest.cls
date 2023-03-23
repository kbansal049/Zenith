@isTest(SeeAllData = true)
public class EnterSCIDetailsCtrlTest {

    @isTest
    public static void createTestData(){
        
        User usr = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
      
        
        contact con = new contact();
        con = ManageSCITestDataHelper.mapContacts.get('Test3 Test3');
        
        account acc= new account();
        acc = ManageSCITestDataHelper.mapAccounts.get('Test Account3');
        
        Significant_Customer_Interaction__c sci = new Significant_Customer_Interaction__c();
        sci = ManageSCITestDataHelper.mapExistingSCIs.get('sci3');
        
        List<SCI_Zscaler_Attendee__c> sciInternal = new List<SCI_Zscaler_Attendee__c>();
        sciInternal = [SELECT Attendee_Name__c,Organizer__c,Participation__c,Significant_Customer_Interaction__c from SCI_Zscaler_Attendee__c where Significant_Customer_Interaction__c=:sci.Id limit 100];
        SCI_External_Attendee__c sciExternal = [SELECT Id, Name,Significant_Customer_Interaction__c FROM SCI_External_Attendee__c Where Significant_Customer_Interaction__c=:sci.Id LIMIT 1];
        
        String sciInternalStr2 = '[{"AccountName__c":"","Title":"","Email":"rchettri@zscaler.com.invalid","Phone":"+918197192835","Name":"Rajesh Chettri","Department":"Manager, Customer Succcess Operations - WW","attendeeType":false,"Participation":"In Person","parentRecordId":"'+sci+'","recId":"'+sciInternal[0].Id+'"}]';
        String conDataStr = '[{"Name":"test 2","AccountId":"'+acc.Id+'","AccountName__c":"test account","Title":"test ttk","IT_Executive__c":false,"Head_of_Security_Account__c":false,"Head_of_Networking_CTO_Account__c":false,"Budget_Authority__c":false,"Procurement_Contact__c":false,"Cloud_Architect__c":false,"Service_Owner__c":false,"Account":{"Name":"test account","Type":"Prospect"},"parentRecordId":"'+sci+'","type":"Customer"}]';
        String cmtDataStr = '[{"Name":"test 2","AccountId":"'+acc.Id+'","AccountName__c":"test account","Title":"test ttk","IT_Executive__c":false,"Head_of_Security_Account__c":false,"Head_of_Networking_CTO_Account__c":false,"Budget_Authority__c":false,"Procurement_Contact__c":false,"Cloud_Architect__c":false,"Service_Owner__c":false,"Account":{"Name":"test account","Type":"Prospect"},"parentRecordId":"'+sci+'","type":"Customer"}]';
        string sciInternalStr = '[{"AccountName__c":"","Title":"","Email":"ujain@zscaler.com","Phone":"+91 7017200410","Name":"Udit Jain","Department":"IT/Business Systems","attendeeType":false,"Participation":"In Person","parentRecordId":"'+sci+'","recId":"'+sciInternal[0].Id+'"}]';
        string sciExternalStr = '[{"Id":"'+con.Id+'","Name":"test 2","AccountId":"'+acc.Id+'","AccountName__c":"test account","Title":"test ttk","IT_Executive__c":false,"Head_of_Security_Account__c":false,"Head_of_Networking_CTO_Account__c":false,"Budget_Authority__c":false,"Procurement_Contact__c":false,"Cloud_Architect__c":false,"Service_Owner__c":false,"Account":{"Name":"test account","Type":"Prospect"},"parentRecordId":"'+sci+'","type":"Customer","recId":"'+sciExternal.Id+'"}]';
      	
        
        string userId = UserInfo.getUserId();
        
        List<contact> displayConRecordConList = new List<contact>();
        List<contact> displayDataConRecordConList = new List<contact>();
        List<contact> displayCMTConRecordConList = new List<contact>();
        List<contact> displayDataCMTConRecordConList = new List<contact>();
        List<user> displayUserRecordList = new List<user>();
        String fetchPushDataStr;
        String fetchPushDataStr1;
        contact fetchContactDataCon = new contact();
        Lead fetchLeadDataLead = new Lead();
        List<SCI_Zscaler_Attendee__c> insertZscalarAttendees1 = new List<SCI_Zscaler_Attendee__c>();
        List<SCI_Zscaler_Attendee__c> insertZscalarAttendees2 = new List<SCI_Zscaler_Attendee__c>();
        List<SCI_Zscaler_Attendee__c> insertZscalarAttendees3 = new List<SCI_Zscaler_Attendee__c>();
        List<String> fetchExistingExternalAttendees1 = new List<String>();
        List<String> fetchExistingExternalAttendees2 = new List<String>();
        List<SCI_External_Attendee__c> insertExternalAttendees1 = new List<SCI_External_Attendee__c>();
        
        Test.startTest();
        displayConRecordConList = EnterSCIDetailsCtrl.displayConRecord(acc.id);
        displayDataConRecordConList = EnterSCIDetailsCtrl.displayDataConRecord(acc.id,conDataStr);
        displayCMTConRecordConList = EnterSCIDetailsCtrl.displayCMTConRecord(acc.id);
        displayDataCMTConRecordConList = EnterSCIDetailsCtrl.displayDataCMTConRecord(acc.id,cmtDataStr);
        fetchPushDataStr = EnterSCIDetailsCtrl.fetchPushData(userId);
        fetchPushDataStr1 = EnterSCIDetailsCtrl.fetchPushData(usr.Id);
        fetchContactDataCon = EnterSCIDetailsCtrl.fetchContactData(con.Id);
        //fetchLeadDataLead = EnterSCIDetailsCtrl.fetchLeadData(ld.Id);
        fetchExistingExternalAttendees1 = EnterSCIDetailsCtrl.fetchExistingExternalAttendees(sci.id);
        fetchExistingExternalAttendees2 = EnterSCIDetailsCtrl.fetchExistingExternalAttendees(sciExternal.Significant_Customer_Interaction__c);
        EnterSCIDetailsCtrl.fetchInternalAttendeeData(sci.id);
        insertZscalarAttendees1 = EnterSCIDetailsCtrl.insertZscalarAttendees(sciInternalStr,sci.id);
        insertZscalarAttendees2 = EnterSCIDetailsCtrl.insertZscalarAttendees(sciInternalStr,sci.Id);
        insertZscalarAttendees3 = EnterSCIDetailsCtrl.insertZscalarAttendees(sciInternalStr2,sci.Id);
        insertExternalAttendees1 = EnterSCIDetailsCtrl.insertExternalAttendees(sciExternalStr,sci.id);
        displayUserRecordList = EnterSCIDetailsCtrl.displayUserRecord(usr.Id);
        EnterSCIDetailsCtrl.fetchInternalAttendeeData('');
        Test.stopTest();
        
    }
}