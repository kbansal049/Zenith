@isTest
public class acctTemplateTest {

    @isTest
    static void testData(){
        test.startTest();
        Security_Requests__c ciso = new Security_Requests__c(CISO_Request_Type__c='Customer Policy Review', Contact_Attendee_Role__c='[{}]');
        insert ciso;
        acctTemplt controller = new acctTemplt();
        controller.requestId = ciso.Id;
        System.assertNotEquals(null, controller.getContactList());
        
        controller.yearVal = '2020';
        System.assertNotEquals(null, controller.yearVal);
        
        controller.baseUrl = Url.getSalesforceBaseUrl().toExternalForm()+'/';
        System.assertNotEquals(null, controller.baseUrl);
        
        controller.lastComment = 'Test';
        System.assertNotEquals(null, controller.lastComment);
        
        controller.approverName = 'Demo';
        System.assertNotEquals(null, controller.approverName);
        
        controller.getCISORequest();      
        
        controller.getLastApprovalStep();
        test.stopTest();
    }
}