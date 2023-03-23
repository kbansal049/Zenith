@isTest(SeeAllData = true)
public class SelectSCITypeCtrlTest {
	@isTest
    public static void SelectSCITest(){
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ManageSCITestDataHelper.createTestData();
        
        List<String> uIDs = new List<String>{me.Id};
            
        PatchTeam__c salestert  = new PatchTeam__c();
        salestert.District__c = 'AMERICAS';
        salestert.Theater__c = 'Americas';
        salestert.Region__c = 'AMERICAS';
        salestert.Area__c = 'AMERICAS';
        salestert.Territory__c = 'SF Bay Area 1';
        salestert.Name = 'Sales Team';
        salestert.Sales_Territory_Year__c = 'Current';
        insert salestert;  
        
        Account acc= ManageSCITestDataHelper.mapAccounts.get('Test Account3');
        acc.Sales_Territory__c = salestert.Id;
        update acc;
            
        List<RecordType> recordTypeNameDescription = new List<RecordType>();
		Significant_Customer_Interaction__c returnSci = new Significant_Customer_Interaction__c();
        Significant_Customer_Interaction__c returnSubmitSci = new Significant_Customer_Interaction__c();
        List<String> fetchInternalAttendeeString = new List<String>();
        List<Significant_Customer_Interaction__c> significantList = new List<Significant_Customer_Interaction__c>();
        
        DateTime dT = System.now();
		Date currentDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        Test.startTest();
        recordTypeNameDescription = SelectSCITypeCtrl.fetchRecordTypeNameDescription();
        returnSci = SelectSCITypeCtrl.fatchRecordTypeId(ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id,ManageSCITestDataHelper.mapExistingSCIs.get('sci3').RecordTypeId);
        fetchInternalAttendeeString = SelectSCITypeCtrl.fetchInternalAttendee(ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id);
        significantList = SelectSCITypeCtrl.fetchSignificantCustomer(currentDate, ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id);
        returnSubmitSci = SelectSCITypeCtrl.submitSCIAction(String.valueOf(ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Method_of_Interaction__c) ,String.valueOf(ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Type_of_Interaction__c) ,String.valueOf(ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Date__c) );
        SelectSCITypeCtrl.suggestedAttendees(ManageSCITestDataHelper.mapAccounts.get('Test Account3').Id, uIDs);
        SelectSCITypeCtrl.addLoginUser(ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id);
        SelectSCITypeCtrl.deleteSciOnCancel(ManageSCITestDataHelper.mapExistingSCIs.get('sci3').Id);
        SelectSCITypeCtrl.fetchInternalAttendee('');
        SelectSCITypeCtrl.suggestedAttendees('', uIDs);
        SelectSCITypeCtrl.addLoginUser('');
        Test.stopTest();
        
        
        
        
    }
}