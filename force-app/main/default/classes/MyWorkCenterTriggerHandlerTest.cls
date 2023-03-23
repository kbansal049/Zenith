@isTest
private class MyWorkCenterTriggerHandlerTest {
    
    @TestSetup
    private static void createTestData(){
        List<My_WorkCenter__c> myWorkCenterList = new List<My_WorkCenter__c>();
        String loggedInUserRecordId = UserInfo.getUserId();
        My_WorkCenter__c myWorkCenterObj = new My_WorkCenter__c();
        myWorkCenterObj.Name = 'Test My_WorkCenter 1';
        myWorkCenterObj.Manager__c = loggedInUserRecordId;
        myWorkCenterObj.User_Lookup__c = loggedInUserRecordId;
    }
    
    public static void createUser(Id profileId, String lastName){        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'test', 
                         lastName = lastName, 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = profileId
                        );        
        
        insert uu;
    }
    
    @isTest 
    static void createMyWorkCenterRecordTest(){       
		List<My_WorkCenter__c> myWorkCenterList = new List<My_WorkCenter__c>();
        String loggedInUserRecordId = UserInfo.getUserId();
        My_WorkCenter__c myWorkCenterObj = new My_WorkCenter__c();
        myWorkCenterObj.Name = 'Test My_WorkCenter 1';
        myWorkCenterObj.Manager__c = loggedInUserRecordId;
        myWorkCenterObj.User_Lookup__c = loggedInUserRecordId;
        
        myWorkCenterList.add(myWorkCenterObj);
        Test.startTest();
        insert myWorkCenterList;
        Test.stopTest();
    }
    
    @isTest 
    static void updateMyWorkCenterRecordTest(){ 
        
        Profile pf= [Select Id from profile where Name='Core Sales']; 
        createUser(pf.id,'user001');
        
        Id usrRecordId = [SELECT Id from User WHERE lastName = 'user001' LIMIT 1].Id;
		List<My_WorkCenter__c> myWorkCenterList = new List<My_WorkCenter__c>();
        String loggedInUserRecordId = UserInfo.getUserId();
        My_WorkCenter__c myWorkCenterObj = new My_WorkCenter__c();
        myWorkCenterObj.Name = 'Test My_WorkCenter 1';
        myWorkCenterObj.Manager__c = loggedInUserRecordId;
        myWorkCenterObj.User_Lookup__c = loggedInUserRecordId;
        
        myWorkCenterList.add(myWorkCenterObj);
        insert myWorkCenterList;
        
        Test.startTest();
        My_WorkCenter__c myWorkCenterObjToUpdate = [SELECT Id,Manager__c 
                                            FROM My_WorkCenter__c 
                                            WHERE Manager__c = : loggedInUserRecordId
                                           LIMIT 1];
        myWorkCenterObjToUpdate.Manager__c = usrRecordId;
        update myWorkCenterObjToUpdate;
        Test.stopTest();
    }

}