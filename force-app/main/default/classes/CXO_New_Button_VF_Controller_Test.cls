/*

** Added by Ayush Kangar As Part Of CXO Project.

*/
@isTest
public class CXO_New_Button_VF_Controller_Test {
	public static testmethod void test1(){
    	 	Account ac = TestDatafactory_Zscaler.insertAccount('Test Account', null, 'Customer', null, null, null);
        	CXO_Advisor_Request__c cxo = new CXO_Advisor_Request__c();
        	insert cxo;
            Test.StartTest(); 
        	Id recID = Schema.SObjectType.CXO_Advisor_Request__c.getRecordTypeInfosByName().get('Field CTO').getRecordTypeId();
        	String recordTypeDeveloperName = Schema.SObjectType.CXO_Advisor_Request__c.getRecordTypeInfosById().get(recID).getDeveloperName();
			ApexPages.StandardController sc = new ApexPages.StandardController(cxo);
        	ApexPages.currentPage().getParameters().put('RecordType', recID);
        	ApexPages.currentPage().getParameters().put('recordTypeDeveloperName', recordTypeDeveloperName);
			CXO_New_Button_VF_Controller  vfController = new CXO_New_Button_VF_Controller(sc);
			Test.StopTest();
    }
}