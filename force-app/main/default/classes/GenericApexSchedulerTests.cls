@isTest
private class GenericApexSchedulerTests {
    
    @isTest
    static void testScheduleApexFor404() {
        Apex_Scheduler__c testRecord1 = new Apex_Scheduler__c();
        testRecord1.is_Active__c = true;
        testRecord1.Apex_Class_Name__c = 'EmailNotificationCaseInSupportBatch';
        testRecord1.minute__c = 1;
        testRecord1.hour__c = 1;
        testRecord1.day__c = 1;
        testRecord1.month__c = 1;
        testRecord1.weekday__c = 1;
        testRecord1.Batch_Size__c = 20;
        insert testRecord1;

        Apex_Scheduler__c testRecord2 = new Apex_Scheduler__c();
        testRecord2.is_Active__c = true;
        testRecord2.Apex_Class_Name__c = 'SomeRandonClass';
        testRecord2.minute__c = 1;
        testRecord2.hour__c = 1;
        testRecord2.day__c = 1;
        testRecord2.month__c = 1; 
        testRecord2.weekday__c = 1;
        insert testRecord2;
        
        RestRequest req = new RestRequest(); 
        req.requestBody = Blob.valueOf('{"iMinute" : 1, "iHour" : 1, "iDay": 1, "iMonth" : 1, "iWeekDay" : 1}');
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/GenericApexScheduler'; 
        
        RestContext.request = req; 
        
        RestResponse response = new RestResponse();
        response.responseBody = Blob.valueOf('Success');
        
        RestContext.response = response;
        
        Test.startTest();
            GenericApexScheduler.scheduleApex();
        Test.stopTest();

        RestResponse resultResponse = RestContext.response;
        System.assertEquals(404, resultResponse.statusCode, 'Status code should be 404.');
    }

    @isTest
    static void testScheduleApexForBatch200() {
        Apex_Scheduler__c testRecord1 = new Apex_Scheduler__c();
        testRecord1.is_Active__c = true;
        testRecord1.Apex_Class_Name__c = 'EmailNotificationCaseInSupportBatch';
        testRecord1.minute__c = 1;
        testRecord1.hour__c = 1;
        testRecord1.day__c = 1;
        testRecord1.month__c = 1;
        testRecord1.weekday__c = 1;
        testRecord1.Batch_Size__c = 200;
        insert testRecord1;
        
        RestRequest req = new RestRequest(); 
        req.requestBody = Blob.valueOf('{"iMinute" : 1, "iHour" : 1, "iDay": 1, "iMonth" : 1, "iWeekDay" : 1}');
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/GenericApexScheduler'; 
        
        RestContext.request = req; 
        
        RestResponse response = new RestResponse();
        response.responseBody = Blob.valueOf('Success');
        
        RestContext.response = response;
        
        Test.startTest();
            GenericApexScheduler.scheduleApex();
        Test.stopTest();

        RestResponse resultResponse = RestContext.response;
        System.assertEquals(200, resultResponse.statusCode, 'Status code should be 200.');
    }

    
    @isTest
    static void testScheduleApexForQueue200() {
        Apex_Scheduler__c testRecord1 = new Apex_Scheduler__c();
        testRecord1.is_Active__c = true;
        testRecord1.Apex_Class_Name__c = 'TAMReassignmentQueueable';
        testRecord1.minute__c = 1;
        testRecord1.hour__c = 1;
        testRecord1.day__c = 1;
        testRecord1.month__c = 1;
        testRecord1.weekday__c = 1;
        insert testRecord1;
        
        RestRequest req = new RestRequest(); 
        req.requestBody = Blob.valueOf('{"iMinute" : 1, "iHour" : 1, "iDay": 1, "iMonth" : 1, "iWeekDay" : 1}');
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/GenericApexScheduler'; 
        
        RestContext.request = req; 
        
        RestResponse response = new RestResponse();
        response.responseBody = Blob.valueOf('Success');
        
        RestContext.response = response;
        
        Test.startTest();
            GenericApexScheduler.scheduleApex();
        Test.stopTest();

        RestResponse resultResponse = RestContext.response;
        System.assertEquals(200, resultResponse.statusCode, 'Status code should be 200.');
    }

    
    @isTest
    static void testScheduleApexForException() {
        RestRequest req = new RestRequest(); 
        
        Test.startTest();
        try {
            
            req.requestBody = Blob.valueOf('{"iMinute" : -1, "iHour" : 1, "iDay": 1, "iMonth" : 1, "iWeekDay" : 1}');
            req.addHeader('httpMethod', 'POST');
            req.requestUri = '/services/apexrest/GenericApexScheduler'; 
            
            RestContext.request = req; 
            
            GenericApexScheduler.scheduleApex();
        } catch(Exception e) {
            System.debug('---e--'+e.getMessage());
            System.assert(e.getMessage().startsWith('The iMinute parameter should'), 'Message should be The iMinute parameter should...');
        }
        
        try {
            req.requestBody = Blob.valueOf('{"iMinute" : 1, "iHour" : -1, "iDay": 1, "iMonth" : 1, "iWeekDay" : 1}');
            req.addHeader('httpMethod', 'POST');
            req.requestUri = '/services/apexrest/GenericApexScheduler'; 
            
            RestContext.request = req;
            
            GenericApexScheduler.scheduleApex();
        } catch(Exception e) {
            System.assert(e.getMessage().startsWith('The iHour parameter'), 'Message should be The iHour parameter...');
        }
        
        try {
            req.requestBody = Blob.valueOf('{"iMinute" : 1, "iHour" : 1, "iDay": -1, "iMonth" : 1, "iWeekDay" : 1}');
            req.addHeader('httpMethod', 'POST');
            req.requestUri = '/services/apexrest/GenericApexScheduler'; 
            
            RestContext.request = req;
            GenericApexScheduler.scheduleApex();
        } catch(Exception e) {
            System.assert(e.getMessage().startsWith('The iDay parameter'), 'Message should be The iDay parameter...');
        }
        
        try {
            req.requestBody = Blob.valueOf('{"iMinute" : 1, "iHour" : 1, "iDay": 1, "iMonth" : -1, "iWeekDay" : 1}');
            req.addHeader('httpMethod', 'POST');
            req.requestUri = '/services/apexrest/GenericApexScheduler'; 
            
            RestContext.request = req;
            GenericApexScheduler.scheduleApex();
        } catch(Exception e) {
            System.assert(e.getMessage().startsWith('The iMonth parameter'), 'Message should be The iMonth parameter...');
        }
        
        try {
            req.requestBody = Blob.valueOf('{"iMinute" : 1, "iHour" : 1, "iDay": 1, "iMonth" : 1, "iWeekDay" : -1}');
            req.addHeader('httpMethod', 'POST');
            req.requestUri = '/services/apexrest/GenericApexScheduler'; 
            
            RestContext.request = req;
            GenericApexScheduler.scheduleApex();
        } catch(Exception e) {
            System.assert(e.getMessage().startsWith('The iWeekDay parameter'), 'Message should be The iWeekDay parameter...');
        }
        
        Test.stopTest();
    }

    @isTest
    static void testLogError() {
        
        Test.startTest();
        	List<Zscaler_Error_Logs__c> errorLogList = new List<Zscaler_Error_Logs__c>();
            GenericApexScheduler.logException(errorLogList, new IllegalArgumentException('Test Exception'));
        	insert errorLogList;
        Test.stopTest();

        List<Zscaler_Error_Logs__c> errorLogsList = [SELECT Id FROM Zscaler_Error_Logs__c];
        System.assertNotEquals(0, errorLogsList.size(), 'ZScaler error log record should be created.');
    }
}