/**********************************************************************************************************************
* @TestClass	: GetCaseDetails_Test
* @Author   	: Priyanka J
* @Date     	: 08/01/2021
* @Description	: Test Class for GetCaseDetails
************************************************************************************************************************/
@isTest(SeeAllData=True)
public class GetCaseDetails_Test {
    
    @isTest
    private static void testCaseDetailsMethod(){
        
        AgentWork agRec = [select id from AgentWork limit 1]; 
        System.assertNotEquals(null, agRec.Id, 'Agent work record does not exist');
        Test.StartTest();         
        
        GetCaseDetails  testCaseDetails = new GetCaseDetails();
        testCaseDetails.equipmentRequestRecordId =  agRec.Id;
        testCaseDetails.typeofTemplate = 'Test';
        String url = testCaseDetails.url;
        testCaseDetails.getER();
        testCaseDetails.getCase();
        
        Test.StopTest();
    }
    
}