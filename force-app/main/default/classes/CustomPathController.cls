public without sharing class CustomPathController {
    @AuraEnabled(cacheable=true)
    public static List<CategoryDataWrapper> getPathCategoryMapping(String category, Boolean isCategory, String recordId, String recordTypeId){
        system.debug('This is getPathCategoryMapping :'+category);
        system.debug('isCategory --> '+isCategory);
        system.debug('recordId -->'+recordId);
        system.debug('recordTypeId -->'+recordTypeId);
        List<CategoryDataWrapper> listOfResultData = new List<CategoryDataWrapper>();
        String recordTypeName = '';
        if(String.isBlank(recordTypeId) && !String.isBlank(recordId)){
           recordTypeName = [select id, RecordType.Name from PS_Questionnaire__c where Id=:recordId].RecordType.Name;
        }
        else{
           recordTypeName = Schema.getGlobalDescribe().get('PS_Questionnaire__c').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        }
        if(isCategory){
            String query = 'select id, Category__c, Sub_Category__c, Sub_Category_Id__c, Sub_Category_Order__c, Category_Order__c, Category_Id__c, Field_Set__c, Columns__c from Path_Category_Mapping__mdt where Category_Order__c != null';
            if(recordTypeName == 'ZPA'){
                query += ' and Use_For_ZPA__c = true';
            }else{
            	query += ' and Use_For_ZIA__c = true';    
            }
            query += ' order by Category_Order__c ASC';
            Set<String> setOfCategoryId = new Set<String>();
            List<Path_Category_Mapping__mdt> listOfPathMapping  = Database.query(query);
            for(Path_Category_Mapping__mdt catData : listOfPathMapping){
                if(!setOfCategoryId.contains(catData.Category_Id__c) && catData.Category_Id__c != null){
            		String className = '';
                    if(catData.Category_Order__c == 1){
                        className = 'slds-path__item slds-is-current slds-is-active';
                    }else{
                        className = 'slds-path__item slds-is-incomplete';
                    }
                    Integer columns;
                    if(catData.Columns__c != null){
                        columns = Integer.valueOf(catData.Columns__c);
                    }else{
                        columns = 2;
                    }
                    CategoryDataWrapper currData = new CategoryDataWrapper(catData.Category__c, catData.Category__c, catData.Category_Id__c,catData.Category_Order__c, className, null, null, columns); 
                    listOfResultData.add(currData);     
                    setOfCategoryId.add(catData.Category_Id__c);
                }
            }
        }
        else{
            if(!String.isBlank(category)){
                String query2 = 'select id, Category__c, Sub_Category__c, Sub_Category_Id__c, Sub_Category_Order__c, Field_Set__c, Columns__c from Path_Category_Mapping__mdt where Category__c=:category and Sub_Category__c != null';
                if(recordTypeName == 'ZPA'){
                    query2 += ' and Use_For_ZPA__c = true';
                }else{
                    query2 += ' and Use_For_ZIA__c = true';    
                }
                query2 += ' order by Sub_Category_Order__c ASC';
                List<Path_Category_Mapping__mdt> listOfPathMapping2  = Database.query(query2);
                Boolean firstSubCatChecked = false;
                for(Path_Category_Mapping__mdt catData : listOfPathMapping2){
                    String className = '';
                    String recordFormClass = '';
                    if(!firstSubCatChecked){
                        className = 'slds-path__item slds-is-current slds-is-active';
                        recordFormClass = 'slds-show';
                        firstSubCatChecked = true;
                    }else{
                        className = 'slds-path__item slds-is-incomplete';
                        recordFormClass = 'slds-hide';
                    }
                    
                    Integer columns;
                    if(catData.Columns__c != null){
                        columns = Integer.valueOf(catData.Columns__c);
                    }else{
                        columns = 2;
                    }
                    CategoryDataWrapper currData = new CategoryDataWrapper(catData.Category__c, catData.Sub_Category__c, catData.Sub_Category_Id__c,catData.Sub_Category_Order__c, className, catData.Field_Set__c, recordFormClass, columns); 
                    listOfResultData.add(currData);
                }
            }
        }
        
        system.debug('listOfResultData :'+listOfResultData);
        return listOfResultData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<categoryWrapper> getAllMainCategories(String recordId, String recordTypeId){
        List<categoryWrapper> listOfCatId = new List<categoryWrapper>();
        String recordTypeName = '';
        if(String.isBlank(recordTypeId) && !String.isBlank(recordId)){
           recordTypeName = [select id, RecordType.Name from PS_Questionnaire__c where Id=:recordId].RecordType.Name;
        }
        else{
           recordTypeName = Schema.getGlobalDescribe().get('PS_Questionnaire__c').getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        }
        if(recordTypeName == 'ZPA'){
            for(Path_Category_Mapping__mdt catData : [select id, Category__c, Sub_Category__c, Sub_Category_Id__c, Sub_Category_Order__c, Category_Order__c, Category_Id__c, Field_Set__c from Path_Category_Mapping__mdt where Use_For_ZPA__c=true and Category_Order__c != null order by Category_Order__c ASC]){
                listOfCatId.add(new categoryWrapper(catData.Category__c, catData.Category_Id__c));
            }
        }else{
            for(Path_Category_Mapping__mdt catData : [select id, Category__c, Sub_Category__c, Sub_Category_Id__c, Sub_Category_Order__c, Category_Order__c, Category_Id__c, Field_Set__c from Path_Category_Mapping__mdt where Use_For_ZIA__c=true and Category_Order__c != null order by Category_Order__c ASC]){
                listOfCatId.add(new categoryWrapper(catData.Category__c, catData.Category_Id__c));
            }
        }
        
        system.debug('listOfCatId ---->'+listOfCatId);
        return listOfCatId;
    }
    
    @AuraEnabled(cacheable=true)
    public static mainDetails getMainDetails(Id opportunityId, Id projectId){
        if(!String.isBlank(projectId)){
            inspire1__Project__c currProject = [select id, inspire1__Account__c, Opportunity__c from inspire1__Project__c where Id=:projectId];
        	mainDetails md = new mainDetails(currProject.Opportunity__c, currProject.inspire1__Account__c);
        	return md;
        }else if(!String.isBlank(opportunityId)){
            Opportunity opp = [select id, AccountId from Opportunity where Id=:opportunityId];
            mainDetails md = new mainDetails(opportunityId, opp.AccountId);
        	return md;
        }else{
            return null;
        }
    }
    
    public class mainDetails{
        @AuraEnabled
        public Id oppId;
        @AuraEnabled
        public Id accId;
        
        public mainDetails(Id oppId, Id accId){
            this.oppId = oppId;
            this.accId = accId;
        }
    }
    public class categoryWrapper{
        @AuraEnabled
        public String cat;
        @AuraEnabled
        public String catId;
        
        public categoryWrapper(String category, String categoryId){
            this.cat = category;
            this.catId = categoryId;
        }
    }
    public class CategoryDataWrapper{
        @AuraEnabled
        public String category;
        @AuraEnabled
        public String subCategory;
        @AuraEnabled
        public String subCatId;
        @AuraEnabled
        public Decimal subCatOrder;
        @AuraEnabled
        public String pathClass;
        @AuraEnabled
        public String fieldSetName;
        @AuraEnabled
        public String recordFormClass;
        @AuraEnabled
        public Decimal columns;
        
        public CategoryDataWrapper(String category, String subCategory, String subCatId, Decimal subCatOrder, String pathClass, String fieldSetName, String recordFormClass, Integer columns){
            this.category = category;
            this.subCategory = subCategory;
            this.subCatId = subCatId;
            this.subCatOrder = subCatOrder;
            this.pathClass = pathClass;
            this.fieldSetName = fieldSetName;
            this.recordFormClass = recordFormClass;
            this.columns = columns;
        }
        
    }
}