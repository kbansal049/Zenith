@isTest
public class NodeConfigurationHandlerTest {

    @TestSetup
    private static void createTestData(){
        List<PatchTeam__c> salesTerritoryList = NodeConfigTestDataFactory.createPatchTeams(1);
        insert salesTerritoryList;
        
        List<Account> accList = NodeConfigTestDataFactory.createAccounts(1, salesTerritoryList.get(0).Id);
        accList[0].TAM_Email__c = 'Test@test.com';
        accList[0].CSM_Name_New__c = UserInfo.getUserId();
        accList[0].Sales_Engineer__c = UserInfo.getUserId();
        accList[0].Account_Manager__c = UserInfo.getUserId();
        insert accList;
        
        List<Opportunity> oppList = NodeConfigTestDataFactory.createOpportunities(1, accList.get(0).Id);
        insert oppList;
        
        List<Equipment_Request__c> equipmentRequestList = NodeConfigTestDataFactory.createEquipmentRequests(1, oppList.get(0).Id);
        insert equipmentRequestList;
        
        List<Datacenter__c> dataCenterList = NodeConfigTestDataFactory.createDataCenters(4);
        for(Integer i=0;i<dataCenterList.size();i++){
            dataCenterList[i].Facility_City__c = 'Darbhanga'+i;
            dataCenterList[i].Facility_Country__c = 'India'+i;
            dataCenterList[i].Projet_Manager_Email_Address__c = 'test@test'+i+'.com';
            dataCenterList[i].Account__c = accList[0].Id;
        }
        dataCenterList[0].Requested_Hardware_Model__c = L2O_Constants.DataCenterObject.RHM_HW1;
        dataCenterList[1].Requested_Hardware_Model__c = L2O_Constants.DataCenterObject.RHM_SERVICE_EDGE_3;
        dataCenterList[2].Requested_Hardware_Model__c = L2O_Constants.DataCenterObject.RHM_HW3;
        dataCenterList[3].Requested_Hardware_Model__c = L2O_Constants.DataCenterObject.RHM_SERVICE_EDGE_5;
        
        insert dataCenterList;
        
        List<Node_Configuration__c> nodeConfigurationList 
            = NodeConfigTestDataFactory.createNodeConfigurations(1, equipmentRequestList.get(0).Id, dataCenterList.get(0).Id);
        nodeConfigurationList[0].Node_Configuration_Status__c = L2O_Constants.NodeConfigurationObject.STATUS_PENDING_SHIPMENT;
        nodeConfigurationList[0].Organization_ID__c = '2378326479';
        nodeConfigurationList[0].SI_Private_Service_IP__c = '192.168.8.1';
        nodeConfigurationList[0].Private_Service_IP_2__c = '192.168.9.1';
        insert nodeConfigurationList;
    }

    static testmethod void testSendEmailToNcBusiness() {
        Test.startTest();
        List<Node_Configuration__c> ncList = [Select Id,Node_Configuration_Status__c From Node_Configuration__c Where Node_Configuration_Status__c='Pending Shipment' Limit 1];
        ncList[0].Node_Configuration_Status__c = L2O_Constants.NodeConfigurationObject.STATUS_PENDING_DEPLOYMENT;
        update ncList;
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1,invocations,'Mail not send');
    }
}