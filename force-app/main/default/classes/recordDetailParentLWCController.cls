public class recordDetailParentLWCController {
	 @AuraEnabled(cacheable=true)
    public static resultWrapper getSObjetFieldsFromFieldSet(String fieldSetName, String ObjectName){      
        resultWrapper rWrap = new resultWrapper();
        try{
            
            //Check if object is valid
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
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
            
            List<ObjectFieldSet> fldList = new list<ObjectFieldSet>();
            for(Schema.FieldSetMember f : fldSetMap.get(fieldSetName).getFields()) {
                if(String.valueOf(f.getFieldPath()).contains('__r')){
                    fldList.add(new ObjectFieldSet(f.getLabel(),f.getFieldPath(),string.valueof(f.getType()),
                                                   f.getRequired(),true,false,
                                                   true, true,true));
                }else{
                    SObjectField sobjFld = sobjectFields.get(f.getFieldPath());
                    fldList.add(new ObjectFieldSet(f.getLabel(),f.getFieldPath(),string.valueof(f.getType()),
                                                   f.getRequired(),isAccessible(sobjFld),isFormula(sobjFld),
                                                   isEditatble(sobjFld),isLookup(sobjFld),false));
                }
                
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
        return rWrap;
    }
       
    
    @AuraEnabled
    public static sObject getSObjectDetails(Id recordID, List<String> fldList){
        try{
             sObject sobj = null;
        Schema.sObjectType sobjectName = recordID.getSObjectType();
        
        List<String> queryBuilder = new List<String>();
        queryBuilder.add('SELECT');
        queryBuilder.add(String.join(fldList, ','));
        queryBuilder.add('FROM');
        queryBuilder.add(sobjectName.getDescribe().getName());
        queryBuilder.add('WHERE');
        queryBuilder.add('Id =:recordID');
        String query = String.join(queryBuilder, ' ');
        List<Sobject> sobjList = Database.query(query);
        if(sobjList != null && sobjList.size()>0){
            sobj = sobjList[0];
        }
        return sobj;
        }catch(exception ex){
            return null;
        }
       
    }
    
    
    @AuraEnabled
    public static sObject getSObjectDetailsNew(Id recordID, List<String> fldList){
        try{
            sObject sobj = null;
        if(recordID != null){
            List<String> queryBuilder = new List<String>();
            queryBuilder.add('SELECT Id,');
            queryBuilder.add(String.join(fldList, ','));
            queryBuilder.add('FROM');
            queryBuilder.add('Account_Extension__c');
            queryBuilder.add('WHERE');
            queryBuilder.add('Account__r.Id =:recordID');
            String query = String.join(queryBuilder, ' ');
            List<Sobject> sobjList = Database.query(query);
            if(sobjList != null && sobjList.size()>0){
                sobj = sobjList[0];
            }
        }
        return sObj;
        }catch(exception ex){
            return null;
        }
    }
    
    
    //Check if Field is Formula
    public static Boolean isFormula(SObjectField field){
        try{
                    return field.getDescribe().isCalculated();
        }catch(exception ex){
            return false;
        }
    }
    
    //Check if Field is Editable
    public static Boolean isEditatble(SObjectField field){
        
        try{
            return field.getDescribe().isUpdateable();
        }catch(exception ex){
            return false;
        }
    }
    
    //Check if Field is Accesible
    public static Boolean isAccessible(SObjectField field){
        try{
            return field.getDescribe().isAccessible();
        }catch(exception ex){
            return false;
        }
    }
    
    //Check if Field is LookUp
    public static Boolean isLookup(SObjectField field){
        try{
            return field.getDescribe().getType() ==  Schema.DisplayType.Reference ? true : false;
        }catch(exception ex){
            return false;
        }
    }
    
    public static MAP<string, SObjectField> getFieldList(String sObjectAPIName){
        try{
            
        MAP<string, SObjectField> fieldList = new MAP<string, SObjectField>();
        if(sObjectAPIName != null){
            fieldList = schema.getGlobalDescribe().get(sObjectAPIName).getDescribe().fields.getMap();
        }else{
            return null;
        }
        return fieldList;
        }catch(exception ex){
            
            return null;
        }
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
        @AuraEnabled
        public boolean isParentField;
        
        public ObjectFieldSet(string fieldLabel,string fieldAPIName,string fieldType,boolean isRequired,boolean isAccessible, boolean isFormula, boolean isEditable, boolean isLookup,boolean isParentField){
            try{
              this.fieldLabel = fieldLabel;
            this.fieldAPIName = fieldAPIName;
            this.isRequired = isRequired;
            this.fieldType = fieldType;
            this.isAccessible = isAccessible;
            this.isFormula = isFormula;
            this.isEditable = isEditable;
            this.isLookup = isLookup;  
            this.isParentField = isParentField;
            }catch(exception ex){
        }
        }
    }    
}