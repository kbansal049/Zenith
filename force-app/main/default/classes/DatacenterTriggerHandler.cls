public with sharing class DatacenterTriggerHandler extends TriggerHandler{
    public override void afterInsert() {
        Map<id,id> datacenterMap = new map<id,id>();
        Set<id> datacenterIdsSet = new Set<Id>();
        List<Equipment_Request__c> ListToInsert=  new List<Equipment_Request__c>();
        for(Datacenter__c dc : [select id,equipment_request__c from Datacenter__c where id in: Trigger.new]){
            datacenterMap.put(dc.equipment_request__c,dc.id);
        }
        for(Equipment_Request__c ER : [select id,Datacenter__c from equipment_request__c where RecordType.Name ='New Cavium Card' and id In:datacenterMap.keyset()]){
            if(!datacenterMap.isEmpty() && datacenterMap.containsKey(ER.id)){
                ER.Datacenter__c = datacenterMap.get(ER.id);
                ListToInsert.add(ER);
            }
        }
        if(!ListToInsert.isEmpty()){
            update ListToInsert;
        }
    }
}