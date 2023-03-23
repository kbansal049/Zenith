/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* ServiceResourceSelector
* @description - This class works as Selector class for ServiceResource object
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     Anup Dhole
* @maintainedBy   Zscaler
* @version        1.0
* @created        
* @modified       2023-01-03
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* 
**/
public class ServiceResourceSelector {
    public static List<ServiceResource> getServiceResourcesForUsers(String fieldSetName, Set<Id> userIds){
        List<ServiceResource> serviceResourceList = new List<ServiceResource>();
        List<Schema.FieldSetMember> fieldDetails = Schema.SObjectType.ServiceResource.FieldSets.getMap().get(fieldSetName).getFields();
        String query = 'SELECT ';
        for(Schema.FieldSetMember fsm : fieldDetails) {
            query += fsm.getFieldPath() + ', ';
        }
        query += ' Id FROM ServiceResource where RelatedRecordId IN :userIds ';
        serviceResourceList = Database.query(query);
        return serviceResourceList;
    }
}