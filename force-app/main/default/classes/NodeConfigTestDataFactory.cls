@IsTest
public class NodeConfigTestDataFactory {
    
    public static List<PatchTeam__c> createPatchTeams(Integer numOfRecords) {
        
        List<PatchTeam__c> patchTeamList = new List<PatchTeam__c>();
        
        for (Integer index = 0; index < numOfRecords; index++) {
            
            PatchTeam__c salesTerritory =  new  PatchTeam__c();
            salesTerritory.Name= 'Test Sales Territory';
            salesTerritory.Area__c = 'AMERICAS';
            salesTerritory.Region__c ='ANZ';
            salesTerritory.Theater__c='Americas';
            
            patchTeamList.add(salesTerritory);
            
        }
        
        
        return patchTeamList;
    }
    
    public static List<Account> createAccounts(Integer numOfRecords, Id salesTerritoryId) {
        
        List<Account> accList = new List<Account>();
        
        for (Integer index = 0; index < numOfRecords; index++) {
            
            Account account = new Account();
            account.Name = 'Test Account';
            account.Sales_Territory__c = salesTerritoryId;
            accList.add(account);
        }
        
        return accList;
        
    }
    
    public static List<Opportunity> createOpportunities(Integer numOfRecords, Id accountId) {
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        for (Integer index = 0; index < numOfRecords; index++) {
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity';
            opp.StageName = '6 - Closed Won';
            opp.CloseDate =  System.Today(); 
            opp.AccountId = accountId;
            
            oppList.add(opp);
        }
        
        
        return oppList;
    }
    
    public static List<Equipment_Request__c> createEquipmentRequests(Integer numOfRecords, Id oppId) {
        
        List<Equipment_Request__c> equipmentRequestList = new List<Equipment_Request__c>();
        
        for (Integer index = 0; index < numOfRecords; index++) {
            Equipment_Request__c equipmentRequest = new Equipment_Request__c();
            equipmentRequest.Name = 'Test Equipment Request';
            equipmentRequest.Opportunity__c = oppId;
            equipmentRequest.Equipment_Use__c = 'Evaluation'; 
            
            equipmentRequestList.add(equipmentRequest);
            
        }
        
        return equipmentRequestList;
    }    
    
    public static List<Datacenter__c> createDataCenters(Integer numOfRecords) {
        
        List<Datacenter__c> dataCenterList = new List<Datacenter__c>();
        
        for (Integer index = 0; index < numOfRecords; index++) {
            Datacenter__c dataCenter =  new Datacenter__c();
            dataCenter.Name = 'Test Data Center';
            dataCenter.Facility_City__c = 'New York City';
            dataCenter.Facility_Country__c = 'USA';
            dataCenterList.add(dataCenter);
            
        }
        
        
        return dataCenterList;
    }
    
    public static List<Node_Configuration__c> createNodeConfigurations(Integer numOfRecords, Id equipmentRequestId, Id dataCenterId) {
        
        List<Node_Configuration__c> nodeConfigurationList = new List<Node_Configuration__c>();
        
        for (Integer index = 0; index < numOfRecords; index++) {
            Node_Configuration__c nodeConfiguration = new Node_Configuration__c();
            nodeConfiguration.Name = 'Test Node Configuration';
            nodeConfiguration.Node_Configuration_Status__c = 'Not Submitted';
            nodeConfiguration.Equipment_Request__c = equipmentRequestId;
            nodeConfiguration.Datacenter__c = dataCenterId;
            nodeConfigurationList.add(nodeConfiguration);
            
        }
        
        
        return nodeConfigurationList;
    }
}