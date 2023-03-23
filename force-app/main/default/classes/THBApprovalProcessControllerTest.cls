@isTest
public class THBApprovalProcessControllerTest {
	@isTest
    static void test1(){
        Test.startTest();
        //List<ProcessInstanceWorkItem> listOfData = THBApprovalProcessController.DealRegistrationProcessInstanceItems();
		List<ProcessInstanceWorkItem> listOfData1 = THBApprovalProcessController.retriveDealRegistration('South');
        List<Deal_Reg__c> listOfData2 = THBApprovalProcessController.DealRegistration();
    	Test.stopTest();
    }
}