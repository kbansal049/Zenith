@isTest
public class GetDataCentersOfAnEquipmentTest {
    
    @isTest static void myTest() {
        GetDataCentersOfAnEquipment obj = new GetDataCentersOfAnEquipment();
        Id equipmentRequestId = obj.equipmentRequestId;
        String dcURL = obj.dataCenterIdLink;
        List<Datacenter__c> dcRecords = obj.dataCenterRecords;
    }

}