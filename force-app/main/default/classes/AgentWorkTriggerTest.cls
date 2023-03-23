/**
 * @description       : Test class for AgentWorkRoutingTrigger and AgentWorkTriggerUtility and AgentWorkTriggerHandler
 * @author            : Anup Dhole
 * @last modified on  : 03-10-2023
 * @last modified by  : Anup Dhole
 * @ Important Note   : Please do not remove the (seeAllData=true) as it is not possible to create test AgentWork record
 *                      data unless the user is available in Omni-Channel.           
**/

@isTest(seeAllData=true)
public class AgentWorkTriggerTest {
    //Added by Anup : CR#686 - Start
    static testMethod void testUpdate(){
        List<AgentWork> agentWorkData = new List<AgentWork>();
        agentWorkData = [select id from AgentWork limit 1];
        Test.StartTest();
            if(!agentWorkData.isEmpty()){
                update agentWorkData;
            }
        Test.StopTest();
    }
    //Added by Anup : CR#686 - End

    static testMethod void testServiceInfo1(){
        List<AgentWork> agentWorkData = new List<AgentWork>();
        agentWorkData = [select id, WorkItemId, UserId from AgentWork limit 1];
        ServiceResource sr = TestDatafactory_Zscaler.insertServiceResource('test', agentWorkData[0].UserId, 3, 15, 0, 0, 0, 'Frontline');
        AgentWorkTriggerUtility.updateServiceResourceInformation(agentWorkData);
        
        sr.Daily_Quota__c = 0;
        sr.Backlog__c =1;
        update sr;
        AgentWorkTriggerUtility.updateServiceResourceInformation(agentWorkData);
        
        sr.Daily_Quota__c = 0;
        sr.Backlog__c = 0;
        update sr;

        AgentWorkTriggerUtility.updateServiceResourceInformation(agentWorkData);
		AgentWorkTriggerUtility.updateServiceResourceInformation(null);
		AgentWorkTriggerUtility.populateCaseRoutingDetails(null,null);
    }

	static testMethod void testUpdateServiceResourceInformation(){
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs = GCSTestDataFactory.createCase('Test GCS Case', GCSCommonConstants.CASE_PRODUCT_ZPA, GCSCommonConstants.CASE_STATUS_NEW,GCSCommonConstants.CASE_PRIORITY_URGENT,GCSCommonConstants.CASE_ORIGIN_API,GCSCommonConstants.CASE_TYPE_PROBLEM, 'America/Los_Angeles', 'Email', caseRecordTypeId, UserInfo.getUserId(), null);
        insert cs;
        ServiceResource sr = TestDatafactory_Zscaler.insertServiceResource('test', UserInfo.getUserId(), 3, 15, 0, 0, 0, 'Frontline');
        AgentWork ag = new AgentWork();
        ag.UserId = UserInfo.getUserId();
        ag.WorkItemId = cs.Id;
        AgentWorkTriggerUtility.updateServiceResourceInformation(new List<AgentWork>{ag});
        sr.Daily_Quota__c = 0;
        sr.Backlog__c = 1;
        update sr;
        AgentWorkTriggerUtility.updateServiceResourceInformation(new List<AgentWork>{ag});
    }
}