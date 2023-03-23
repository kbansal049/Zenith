/**********************************************************************************************************************
* @TestClass	: GetCasedetailsforCustomerEmail_Test
* @Author   	: Priyanka J
* @Date     	: 08/01/2021
* @Description	: Test Class for GetCasedetailsforCustomerEmail
************************************************************************************************************************/
@isTest
public class GetCasedetailsforCustomerEmail_Test {
    //Creating Test Data
    @testSetup 
    static void setupData(){
        
        //Insert Account
        Account accRec= new Account(Name='TestAccount-GetCaseDetails',Type='Prospect',Domain__c='usda.gov'+'.com');
        insert accRec;
        
        //Insert Case
        Case caseRec = new Case();
        caseRec.Subject = 'testCase';
        caseRec.Description = 'Test Case';
        caseRec.OwnerId =  UserInfo.getUserId(); 
        caseRec.Status = 'Work-in-Progress';
        caseRec.Case_Category__c = 'Other';
        insert caseRec;
        
         //Insert Custom Settings
        ZscalerCustomSetting__c setting = new ZscalerCustomSetting__c();
        setting.Name = 'OrgURL';
        setting.Value__c = 'https://zscaler.my.salesforce.com';
        insert setting;
        
    }
    
    @isTest
    private static void testCustomerEmailMethod(){
        //Query the inserted case
        Case csRec = [Select Id from Case LIMIT 1][0];  
       	System.assertNotEquals(null, csRec.Id, 'No Case Record found');
        
        //Query the inserted custom setting
        ZscalerCustomSetting__c setting = [Select Name, Value__c from ZscalerCustomSetting__c LIMIT 1];
        System.assertEquals('OrgURL', setting.Name, 'Custom Setting name is not OrgURL');
        
        Test.StartTest(); 
        
        GetCasedetailsforCustomerEmail  testCaseDetailsEmail = new GetCasedetailsforCustomerEmail();
        testCaseDetailsEmail.url =  setting.Value__c;
        testCaseDetailsEmail.getER();
        testCaseDetailsEmail.equipmentRequestRecordId =  csRec.Id;
        testCaseDetailsEmail.typeofTemplate = 'Test';
        testCaseDetailsEmail.Case1 = csRec;
        String url = testCaseDetailsEmail.url;
        testCaseDetailsEmail.getER();
        
        Test.StopTest();
    }
    
}