public class GetDataCentersOfAnEquipment {
    
    public String equipmentRequestId{get;set;}
    
    public String dataCenterIdLink{
        get{
            String baseUrl = URL.getOrgDomainUrl().toExternalForm();
            return baseUrl + '/';
        }
        set;
    }
    
    public List<Datacenter__c> dataCenterRecords{
        get{
            dataCenterRecords = [SELECT Id,Name,Requested_Hardware_Model__c,Quantity_Requested__c,
                                 Quantity_Requested_for_LB__c,Number_of_Users_at_location__c,
                                 Available_Bandwidth_MBPS__c,Download_throughput_ServiceEdge_Gbps__c,
                                 Reason_for_Pitching_PZEN__c
                                 FROM Datacenter__c
                                 WHERE Equipment_Request__c =: equipmentRequestId 
                                 ORDER BY CreatedDate DESC];
            return dataCenterRecords;
        }
        set;
    }
    
}