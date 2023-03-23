/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ZscalerLWCUtils
* @description      This class is used for any re-usable methods for any LWC.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Zscaler
* @modifiedBy     
* @maintainedBy     Zscaler
* @version          1.0
* @created          2022-07-05
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X              Author Name
* YYYY-MM-DD        Explanation of the change.  Multiple lines can be used to explain the change, but
*                   each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class ZscalerLWCUtils {

/**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method is used to recieve the FieldSet name and return the Field details to LWC.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getFieldSetDetails .
* @param    NAME : String fieldSetName, String objectAPIName .
* @return   TYPE : List<FieldSetWrapper> .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/    
    @AuraEnabled
    public static List<FieldSetWrapper> getFieldSetDetails(String fieldSetName, String objectAPIName){
        List<FieldSetWrapper> fieldSetWrapperList = new List<FieldSetWrapper>();
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet(fieldSetName,objectAPIName);
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            //system.debug('fieldSetMemberObj : ' + fieldSetMemberObj);
            //system.debug('API Name : ' + fieldSetMemberObj.getFieldPath()); 
            //system.debug('Label : ' + fieldSetMemberObj.getLabel());
            //system.debug('Required : ' + fieldSetMemberObj.getRequired());
            //system.debug('DbRequired : ' + fieldSetMemberObj.getDbRequired());
            //system.debug('Type : ' + fieldSetMemberObj.getType());   
            FieldSetWrapper fieldSetWrapperObj = new FieldSetWrapper();
            fieldSetWrapperObj.fieldlabel = fieldSetMemberObj.getLabel();
            fieldSetWrapperObj.fieldApiName = fieldSetMemberObj.getFieldPath();//api name
            fieldSetWrapperObj.fieldtype = String.valueOf(fieldSetMemberObj.getType());//type - STRING,PICKLIST
            fieldSetWrapperObj.isFieldRequired = fieldSetMemberObj.getDbRequired();
                     
            fieldSetWrapperList.add(fieldSetWrapperObj);
        }
        return fieldSetWrapperList;
    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }
    
    public class FieldSetWrapper{
        @AuraEnabled public String fieldlabel;
        @AuraEnabled public String fieldApiName;
        @AuraEnabled public String fieldtype;
        @AuraEnabled public Boolean isFieldRequired;
    }

}