@isTest
private class MyWorkCenterLandingPageCtrlTest {
    
    @TestSetup
    private static void createTestData(){
        List<My_WorkCenter__c> myWorkCenterList = new List<My_WorkCenter__c>();
        My_WorkCenter__c myWorkCenterObj = new My_WorkCenter__c();
        myWorkCenterObj.Name = 'Test My_WorkCenter 1';
    }
        
    @isTest 
    static void getMyWorkCenterRecordTest(){       
		String loggedInUserRecordId = UserInfo.getUserId();
        Test.startTest();
        MyWorkCenterLandingPageCtrl.getMyWorkCenterRecord(loggedInUserRecordId);
        Test.stopTest();
    }
    
    @isTest 
    static void getTeamWorkCenterRecordsTest(){       
		String loggedInUserRecordId = UserInfo.getUserId();
        Test.startTest();
        MyWorkCenterLandingPageCtrl.getTeamWorkCenterRecords(loggedInUserRecordId);
        Test.stopTest();
    }
    
    @isTest 
    static void isLoggedInUserAManagerTest(){       
		String loggedInUserRecordId = UserInfo.getUserId();
        Test.startTest();
        MyWorkCenterLandingPageCtrl.isLoggedInUserAManager(loggedInUserRecordId);
        Test.stopTest();
    }

}