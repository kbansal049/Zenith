public with sharing class OppStageChecklistHelper {
    
    public class HelperWrapper{
        @AuraEnabled
        public String fieldName{set;get;}
        @AuraEnabled
        public String fieldLabel{set;get;}
        @AuraEnabled
        public Boolean isFile{set;get;}
        @AuraEnabled
        public String fileName{set;get;}
        @AuraEnabled
        public String fileId{set;get;}
        @AuraEnabled
        public String fieldType{set;get;}
        @AuraEnabled
        public String value{set;get;}
        @AuraEnabled
        public Boolean booleanValue{set;get;}
        @AuraEnabled
        public Boolean isCustomPicklist{set;get;}
        @AuraEnabled
        public Boolean allowInput{set;get;}
        @AuraEnabled
        public Boolean isRequired{set;get;}
        @AuraEnabled
        public List<HelperWrapper> dependentFields{set;get;}
        

        public HelperWrapper(String fieldName, String fieldLabel, Boolean isFile, String fileName, 
            String fileId, String fieldType, Boolean isCustomPicklist, Boolean allowInput, Boolean isRequired){
           this.fieldName = fieldName;
           this.fieldLabel = fieldLabel;
           this.isFile = isFile;
           this.fileName = fileName;
           this.fileId = fileId;
           this.fieldType = fieldType;
           this.value = value;
           this.booleanValue = booleanValue;
           this.isCustomPicklist = isCustomPicklist;
           this.allowInput = allowInput;
           this.isRequired = isRequired;
           this.dependentFields = dependentFields;
        }
    }
}