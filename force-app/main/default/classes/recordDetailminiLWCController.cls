/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-25-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   08-24-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

public class recordDetailminiLWCController {
    
    
    @AuraEnabled(cacheable=true)
    public static resultWrapper getSObjetFieldsFromFieldSet(String fieldSetName, String ObjectName){
        
        System.debug('--recordDetailLWCController--getSObjetFieldsFromFieldSet--fieldSetName ::'+fieldSetName);
        System.debug('--recordDetailLWCController--getSObjetFieldsFromFieldSet--ObjectName ::'+ObjectName);
        
        resultWrapper rWrap = new resultWrapper();
        try{
            
            //Check if object is valid
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
            System.debug('-----GlobalDescribeMap contavins sObject--'+GlobalDescribeMap.containskey(ObjectName));
            if(ObjectName == null || String.isBlank(ObjectName) || (!GlobalDescribeMap.containskey(ObjectName)) ){
                rWrap.fldList = null;
                rWrap.hasError = true;
                rWrap.errorMsg = 'Please provide valid sObject API Name.';
                rWrap.errorDetail = ObjectName +'not avaiable in GlobalDescribeMap.';
                return rWrap;
            }
            
            //Check if Fieldset Name is valid
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            Map<String, Schema.FieldSet> fldSetMap = DescribeSObjectResultObj.FieldSets.getMap();
            
            if(fieldSetName == null || String.isBlank(fieldSetName) || (!fldSetMap.containskey(fieldSetName)) ){
                rWrap.fldList = null;
                rWrap.hasError = true;
                rWrap.errorMsg = 'Please provide valid '+ObjectName+' Field Set.';
                rWrap.errorDetail = fieldSetName+'not avaiable in '+ObjectName+' fldSetMap.';
                return rWrap;
            } 
            
            //Fill FieldSet Wrapper
            MAP<string, SObjectField> sobjectFields = getFieldList(ObjectName);
            System.debug('--recordDetailLWCController--getSObjetFieldsFromFieldSet--sobjectFields ::'+sobjectFields);
            
            List<ObjectFieldSet> fldList = new list<ObjectFieldSet>();
            for(Schema.FieldSetMember f : fldSetMap.get(fieldSetName).getFields()) {
                SObjectField sobjFld = sobjectFields.get(f.getFieldPath());
                fldList.add(new ObjectFieldSet(f.getLabel(),f.getFieldPath(),string.valueof(f.getType()),
                                               f.getRequired(),isAccessible(sobjFld),isFormula(sobjFld),
                                               isEditatble(sobjFld), isLookup(sobjFld)));
            }
            rWrap.fldSetLabel =fldSetMap.get(fieldSetName).getLabel();
            rWrap.fldList = fldList;
            rWrap.hasError = false;
            rWrap.errorMsg = '';
            rWrap.errorDetail = '';
        }catch(Exception ex){
            rWrap.hasError = true;
            rWrap.errorMsg = 'Error Occured, Please Contact Administartor';
            rWrap.errorDetail = 'Execption :: Message ['+ex.getMessage()+'] Line ['+ex.getLineNumber()+']';
        }
        System.debug('--recordDetailLWCController--getSObjetFieldsFromFieldSet--rWrap ::'+rWrap);
        return rWrap;
    }
    
    
    
    @AuraEnabled
    public static sObject getSObjectDetails(Id recordID, List<String> fldList,String objName,String fieldname,String activeObjFieldName){
        sObject sobj = null;
        Schema.sObjectType sobjectName = recordID.getSObjectType();
        
        String tempQuery = 'select '+activeObjFieldName+ ' from ' +sobjectName.getDescribe().getName() + ' where id =:recordID ';
        List<sObject> lstSo = Database.query(tempQuery);
        String idval = (String)lstSo.get(0).get(activeObjFieldName);
        List<String> queryBuilder = new List<String>();
        queryBuilder.add('SELECT');
        queryBuilder.add(String.join(fldList, ','));
        queryBuilder.add('FROM');
        queryBuilder.add(objName);
        queryBuilder.add('WHERE');
        queryBuilder.add(fieldname + ' =:idval');
        String query = String.join(queryBuilder, ' ');
        System.debug('--getSObjectDetails--query-'+query);
        List<Sobject> sobjList = Database.query(query);
        if(sobjList != null && sobjList.size()>0){
            sobj = sobjList[0];
        }
        
        return sobj;
    }
    
    
    
    
    //Check if Field is Formula
    public static Boolean isFormula(SObjectField field){
        return field.getDescribe().isCalculated();
    }
    
    //Check if Field is Editable
    public static Boolean isEditatble(SObjectField field){
        return field.getDescribe().isUpdateable();
    }
    
    //Check if Field is Accesible
    public static Boolean isAccessible(SObjectField field){
        return field.getDescribe().isAccessible();
    }
    
   	//Check if Field is LookUp
    public static Boolean isLookup(SObjectField field){
        return field.getDescribe().getType() ==  Schema.DisplayType.Reference ? true : false;
    }
    
    public static string LookupObjectName(SObjectField field){
        String apiName;
        if(field.getDescribe().getType() ==  Schema.DisplayType.Reference){
            for(Schema.SObjectType reference : field.getDescribe().getReferenceTo()) {
                apiName = reference.getDescribe().getName();
            }
        }   
        return apiName;
    }
    
    
    public static MAP<string, SObjectField> getFieldList(String sObjectAPIName){
        System.debug('---getFieldList--sObjectAPIName:'+sObjectAPIName);
        MAP<string, SObjectField> fieldList = new MAP<string, SObjectField>();
        if(sObjectAPIName != null){
            fieldList = schema.getGlobalDescribe().get(sObjectAPIName).getDescribe().fields.getMap();
        }else{
            return null;
        }
        return fieldList;
    }
    
    public class resultWrapper{
        //Error handling
        @AuraEnabled
        public boolean hasError;
        @AuraEnabled
        public String errorMsg;
        @AuraEnabled
        public String errorDetail;
        @AuraEnabled
        public String fldSetLabel;
        @AuraEnabled
        public List<ObjectFieldSet> fldList;
    }
    
    
    public class ObjectFieldSet{
        @AuraEnabled
        public string fieldLabel;
        @AuraEnabled
        public String fieldAPIName;
        @AuraEnabled
        public String fieldType;
        @AuraEnabled
        public boolean isRequired;
        @AuraEnabled
        public boolean isAccessible;
        @AuraEnabled
        public boolean isFormula;
        @AuraEnabled
        public boolean isEditable;
        @AuraEnabled
        public boolean isLookup;
        
        public ObjectFieldSet(string fieldLabel,string fieldAPIName,string fieldType,boolean isRequired,boolean isAccessible, boolean isFormula, boolean isEditable, boolean isLookup){
            this.fieldLabel = fieldLabel;
            this.fieldAPIName = fieldAPIName;
            this.isRequired = isRequired;
            this.fieldType = fieldType;
            this.isAccessible = isAccessible;
            this.isFormula = isFormula;
            this.isEditable = isEditable;
            this.isLookup = isLookup;
        }
    }    
}