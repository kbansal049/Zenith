/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SubmitForApprovalNodeConfigTest
* @description    In this test class we are inserting the test data for all the related objects of 
                  node configuration object for the class SubmitForApprovalNodeConfig
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-06-09
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

@IsTest
private class SubmitForApprovalNodeConfigTest {
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In setup method we are setting the data for custom setting object
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    directorList    List variable for inserting records 
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    
    @TestSetup
    static void setup() {
        
        List<GEO_SE_Director_Mapping__c> directorList = new List<GEO_SE_Director_Mapping__c>();
        
        GEO_SE_Director_Mapping__c director = new GEO_SE_Director_Mapping__c();
        director.Name = 'Approval Record 16 WW Test 1';
        director.Approver_Id__c = System.UserInfo.getUserId();
        director.Area__c = 'WW';
        director.Geo__c = 'WW';
        director.Region__c = 'WW';
        
        directorList.add(director);
        
        director = new GEO_SE_Director_Mapping__c();
        director.Name = 'Approval Record 16 WW Test 2';
        director.Approver_Id__c = System.UserInfo.getUserId();
        director.Geo__c = 'WW';
        director.Region__c = 'WW';
        director.Area__c = NULL;
        
        directorList.add(director);
        
        director = new GEO_SE_Director_Mapping__c();
        director.Name = 'Approval Record 16 WW Test 3';
        director.Approver_Id__c = System.UserInfo.getUserId();
        director.Area__c = 'WW';
        director.Geo__c = 'WW';
        director.Region__c = NULL;
        
        directorList.add(director);
        
        INSERT directorList;
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In testEvaluateRecordLEX method for lightning component we are setting the data for Node 
    * Configuration object and the record is validated if Equipment Use is evaluation
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    nodeConfigurationList    List variable for inserting records
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    @IsTest static void testEvaluateRecordLEX() {
        List<PatchTeam__c> salesTerritoryList = NodeConfigTestDataFactory.createPatchTeams(1);
        INSERT salesTerritoryList;
        
        List<Account> accList = NodeConfigTestDataFactory.createAccounts(1, salesTerritoryList.get(0).Id);
        INSERT accList;
        
        List<Opportunity> oppList = NodeConfigTestDataFactory.createOpportunities(1, accList.get(0).Id);
        INSERT oppList;
        
        List<Equipment_Request__c> equipmentRequestList = NodeConfigTestDataFactory.createEquipmentRequests(1, oppList.get(0).Id);
        INSERT equipmentRequestList;
        
        List<Datacenter__c> dataCenterList = NodeConfigTestDataFactory.createDataCenters(1);
        INSERT dataCenterList;
        
        List<Node_Configuration__c> nodeConfigurationList 
            = NodeConfigTestDataFactory.createNodeConfigurations(1, equipmentRequestList.get(0).Id, dataCenterList.get(0).Id);
        
        INSERT nodeConfigurationList;
        
        SubmitForApprovalNodeConfig.evaluateRecordLEX(nodeConfigurationList.get(0).Id);
        
        Node_Configuration__c nodeConfig = [SELECT Id, Node_Configuration_Status__c FROM Node_Configuration__c WHERE Id = :nodeConfigurationList.get(0).Id];
        
        System.assert(nodeConfig.Node_Configuration_Status__c.equalsIgnoreCase('Pending SE Review'));
        
        
    }     
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In testEvaluateRecordLEXNotEvaluation method for lightning component we are setting the data for Node 
    * Configuration object and the record is validated if Equipment Use is not equal to evaluation
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    nodeConfigurationList   List variable for inserting records and here handling the 
    * exceptions
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    
    @IsTest static void testEvaluateRecordLEXNotEvaluation() {
        List<PatchTeam__c> salesTerritoryList = NodeConfigTestDataFactory.createPatchTeams(1);
        INSERT salesTerritoryList;
        
        List<Account> accList = NodeConfigTestDataFactory.createAccounts(1, salesTerritoryList.get(0).Id);
        INSERT accList;
        
        List<Opportunity> oppList = NodeConfigTestDataFactory.createOpportunities(1, accList.get(0).Id);
        INSERT oppList;
        
        List<Equipment_Request__c> equipmentRequestList = NodeConfigTestDataFactory.createEquipmentRequests(1, oppList.get(0).Id);
        
        equipmentRequestList.get(0).Equipment_Use__c = 'Test';
        
        INSERT equipmentRequestList;
        
        List<Datacenter__c> dataCenterList = NodeConfigTestDataFactory.createDataCenters(1);
        INSERT dataCenterList;
        
        List<Node_Configuration__c> nodeConfigurationList 
            = NodeConfigTestDataFactory.createNodeConfigurations(1, equipmentRequestList.get(0).Id, dataCenterList.get(0).Id);
        
        INSERT nodeConfigurationList;
        
        try {
            SubmitForApprovalNodeConfig.evaluateRecordLEX(nodeConfigurationList.get(0).Id);
        } catch(Exception e) {
            System.debug('-=- exception message -=-= '+e.getMessage());
            
            System.assert(String.isNotBlank(e.getMessage()));
        }
        
    }  
        /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In testEvaluateRecordLEXPending method for lightning component we are setting the data for Node 
    * Configuration object and the record is validated if status is equal to pending
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    nodeConfigurationList   List variable for inserting records and handling the exception
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    
    @IsTest static void testEvaluateRecordLEXPending() {
        List<PatchTeam__c> salesTerritoryList = NodeConfigTestDataFactory.createPatchTeams(1);
        INSERT salesTerritoryList;
        
        List<Account> accList = NodeConfigTestDataFactory.createAccounts(1, salesTerritoryList.get(0).Id);
        INSERT accList;
        
        List<Opportunity> oppList = NodeConfigTestDataFactory.createOpportunities(1, accList.get(0).Id);
        INSERT oppList;
        
        List<Equipment_Request__c> equipmentRequestList = NodeConfigTestDataFactory.createEquipmentRequests(1, oppList.get(0).Id);
        INSERT equipmentRequestList;
        
        List<Datacenter__c> dataCenterList = NodeConfigTestDataFactory.createDataCenters(1);
        INSERT dataCenterList;
        
        List<Node_Configuration__c> nodeConfigurationList 
            = NodeConfigTestDataFactory.createNodeConfigurations(1, equipmentRequestList.get(0).Id, dataCenterList.get(0).Id);
        
        nodeConfigurationList.get(0).Node_Configuration_Status__c = 'Pending';
        
        INSERT nodeConfigurationList;
        
        try {
            SubmitForApprovalNodeConfig.evaluateRecordLEX(nodeConfigurationList.get(0).Id);    
        } catch(Exception e) {
            
            System.assert(String.isNotBlank(e.getMessage()));
        }
        
        
    }
    
      /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In testvalidateRecordLock method for lightning component we are validating for the RecordLock
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    nodeConfigurationList   List variable for inserting records and handling the exception
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    
    @IsTest static void testvalidateRecordLock() {
        List<PatchTeam__c> salesTerritoryList = NodeConfigTestDataFactory.createPatchTeams(1);
        INSERT salesTerritoryList;
        
        List<Account> accList = NodeConfigTestDataFactory.createAccounts(1, salesTerritoryList.get(0).Id);
        INSERT accList;
        
        List<Opportunity> oppList = NodeConfigTestDataFactory.createOpportunities(1, accList.get(0).Id);
        INSERT oppList;
        
        List<Equipment_Request__c> equipmentRequestList = NodeConfigTestDataFactory.createEquipmentRequests(1, oppList.get(0).Id);
        INSERT equipmentRequestList;
        
        List<Datacenter__c> dataCenterList = NodeConfigTestDataFactory.createDataCenters(1);
        INSERT dataCenterList;
        
        List<Node_Configuration__c> nodeConfigurationList 
            = NodeConfigTestDataFactory.createNodeConfigurations(1, equipmentRequestList.get(0).Id, dataCenterList.get(0).Id);
        
        //nodeConfigurationList.get(0).Node_Configuration_Status__c = 'Pending';
        
        INSERT nodeConfigurationList;
        
        SubmitForApprovalNodeConfig.evaluateRecordLEX(nodeConfigurationList.get(0).Id);
        
        
        try {
            SubmitForApprovalNodeConfig.validateRecordLock(nodeConfigurationList.get(0).Id);    
        } catch(Exception e) {            
            System.assert(String.isNotBlank(e.getMessage()));
        }        
        
    }
    
          /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In testEvaluateRecord method for visual force page we are setting the data for Node 
    * Configuration object and the record is validated if Equipment Use is evaluation
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    nodeConfigurationList   List variable for inserting records
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    @IsTest static void testEvaluateRecord() {
        List<PatchTeam__c> salesTerritoryList = NodeConfigTestDataFactory.createPatchTeams(1);
        INSERT salesTerritoryList;
        
        List<Account> accList = NodeConfigTestDataFactory.createAccounts(1, salesTerritoryList.get(0).Id);
        INSERT accList;
        
        List<Opportunity> oppList = NodeConfigTestDataFactory.createOpportunities(1, accList.get(0).Id);
        INSERT oppList;
        
        List<Equipment_Request__c> equipmentRequestList = NodeConfigTestDataFactory.createEquipmentRequests(1, oppList.get(0).Id);
        INSERT equipmentRequestList;
        
        List<Datacenter__c> dataCenterList = NodeConfigTestDataFactory.createDataCenters(1);
        INSERT dataCenterList;
        
        List<Node_Configuration__c> nodeConfigurationList 
            = NodeConfigTestDataFactory.createNodeConfigurations(1, equipmentRequestList.get(0).Id, dataCenterList.get(0).Id);
        
        INSERT nodeConfigurationList;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(nodeConfigurationList.get(0));
        SubmitForApprovalNodeConfig submitForApproval = new SubmitForApprovalNodeConfig(sc);
        
        PageReference pageRef = Page.SubmitForApproval;
        pageRef.getParameters().put('id', String.valueOf(nodeConfigurationList.get(0).Id));
        Test.setCurrentPage(pageRef);
        
        submitForApproval.evaluateRecord();
        
    }
     /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In testEvaluateRecordRecordLock method for visual force page we are validating for the RecordLock
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    nodeConfigurationList   List variable for inserting records and handling the exception
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    @IsTest static void testEvaluateRecordRecordLock() {
        List<PatchTeam__c> salesTerritoryList = NodeConfigTestDataFactory.createPatchTeams(1);
        INSERT salesTerritoryList;
        
        List<Account> accList = NodeConfigTestDataFactory.createAccounts(1, salesTerritoryList.get(0).Id);
        INSERT accList;
        
        List<Opportunity> oppList = NodeConfigTestDataFactory.createOpportunities(1, accList.get(0).Id);
        INSERT oppList;
        
        List<Equipment_Request__c> equipmentRequestList = NodeConfigTestDataFactory.createEquipmentRequests(1, oppList.get(0).Id);
        
        equipmentRequestList.get(0).Equipment_Use__c = 'Test';
        
        INSERT equipmentRequestList;
        
        List<Datacenter__c> dataCenterList = NodeConfigTestDataFactory.createDataCenters(1);
        INSERT dataCenterList;
        
        List<Node_Configuration__c> nodeConfigurationList 
            = NodeConfigTestDataFactory.createNodeConfigurations(1, equipmentRequestList.get(0).Id, dataCenterList.get(0).Id);
        
        INSERT nodeConfigurationList;
        ApexPages.StandardController sc = new ApexPages.StandardController(nodeConfigurationList.get(0));
        SubmitForApprovalNodeConfig submitForApproval = new SubmitForApprovalNodeConfig(sc);
        
        PageReference pageRef = Page.SubmitForApproval;
        pageRef.getParameters().put('id', String.valueOf(nodeConfigurationList.get(0).Id));
        Test.setCurrentPage(pageRef);
        
        submitForApproval.evaluateRecord();
        
        try {
            submitForApproval.evaluateRecord();
        } catch(Exception e) {
            System.debug('-=- exception message -=-= '+e.getMessage());
            
            System.assert(String.isNotBlank(e.getMessage()));
        }
        
    }  
    
     /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In testEvaluateRecordPending method for visual force page we are setting the data for Node 
    * Configuration object and the record is validated if status is equal to pending
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    nodeConfigurationList   List variable for inserting records and handling the exception
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/ 
    @IsTest static void testEvaluateRecordPending() {
        List<PatchTeam__c> salesTerritoryList = NodeConfigTestDataFactory.createPatchTeams(1);
        INSERT salesTerritoryList;
        
        List<Account> accList = NodeConfigTestDataFactory.createAccounts(1, salesTerritoryList.get(0).Id);
        INSERT accList;
        
        List<Opportunity> oppList = NodeConfigTestDataFactory.createOpportunities(1, accList.get(0).Id);
        INSERT oppList;
        
        List<Equipment_Request__c> equipmentRequestList = NodeConfigTestDataFactory.createEquipmentRequests(1, oppList.get(0).Id);
        INSERT equipmentRequestList;
        
        List<Datacenter__c> dataCenterList = NodeConfigTestDataFactory.createDataCenters(1);
        INSERT dataCenterList;
        
        List<Node_Configuration__c> nodeConfigurationList 
            = NodeConfigTestDataFactory.createNodeConfigurations(1, equipmentRequestList.get(0).Id, dataCenterList.get(0).Id);
        
        nodeConfigurationList.get(0).Node_Configuration_Status__c = 'Pending';
        
        INSERT nodeConfigurationList;
        
        
        try {
            ApexPages.StandardController sc = new ApexPages.StandardController(nodeConfigurationList.get(0));
            SubmitForApprovalNodeConfig submitForApproval = new SubmitForApprovalNodeConfig(sc);
            
            PageReference pageRef = Page.SubmitForApproval;
            pageRef.getParameters().put('id', String.valueOf(nodeConfigurationList.get(0).Id));
            Test.setCurrentPage(pageRef);
            
            submitForApproval.evaluateRecord();
        } catch(Exception e) {
            System.debug('-=- exception message -=-= '+e.getMessage());
            
            System.assert(String.isNotBlank(e.getMessage()));
        }
        
        
    }
    
    
    
}