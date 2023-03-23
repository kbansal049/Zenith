@isTest
public class ProvisioningIntegrationTrigger_Test {
    
     @IsTest static void Method2(){
    
         Provisioning_Integration_Log__c logNew1 = new Provisioning_Integration_Log__c();
      //  logNew1.Request__c = req.requestBody.toString();
      //  logNew1.Endpoint__c = URL.getSalesforceBaseUrl().toExternalForm() + req.resourcePath;
       // logNew1.Response__c =  JSON.serializePretty(response);
        logNew1.Request_Status__c =  'Success';
        logNew1.Status__c =  'Received';
        lognew1.Failure_Reason__c = 'god';
         insert lognew1;
         lognew1.status__c ='Failed';
         update lognew1;
       // logNew1.RecordTypeId = recTypeId;

     }
}