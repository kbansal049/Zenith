/**
* Author: @Grazitti
* This class represents 2 custom objects in Salesforce called Category__c and Sub_Category__c.
* It provides methods for accessing records of these objects based on the access levels of the user.
*/

public without Sharing class Zenith_CategoryController {
    
    /*
* To access the associated records we are quering the objects and returning their results in a wrapper class 
*/
    
    
    @AuraEnabled
    public static List<CategorySubCategoryWrapper> getMoreRecords(Integer offsetVal){
        List<Category__c> categoryList=[SELECT Id,Name,Group_Id__c,
                                        (SELECT Id,Name,Topic_Id__c FROM Sub_Categories__r LIMIT 5)
                                        FROM Category__c  ORDER BY CreatedDate ASC LIMIT 3 OFFSET :offsetVal];
        
        Integer totalRecordCount=[SELECT count() from Category__c ];
        
        List<CategorySubCategoryWrapper> mainWrapper=new List<CategorySubCategoryWrapper>();
        for(Category__c c:categoryList){
            CategorySubCategoryWrapper wrap=new CategorySubCategoryWrapper();
            wrap.category=c;
            wrap.subCategoryList=c.Sub_Categories__r;
            wrap.subCategoryCount=c.Sub_Categories__r.size();
            wrap.totalRecords=totalRecordCount;
            mainWrapper.add(wrap);
        }
        
        return mainWrapper;   
    }
    
    @AuraEnabled
    public static boolean checkAccess(String subCategoryId){
        List<Sub_Category_Access__c> getAccessRecords=[SELECT Id, Sub_Category__r.Id 
                                                       FROM Sub_Category_Access__c  
                                                       WHERE Sub_Category__r.Id = :subCategoryId 
                                                       AND User__r.Id = :userInfo.getUserId()  ];
        if(getAccessRecords.size()>0){
            return true;
        }
        return false;
    }
    
    public class CategorySubCategoryWrapper{
        @AuraEnabled
        public Category__c category {get;set;}
        @AuraEnabled
        public List<Sub_Category__c> subCategoryList {get;set;}
        @AuraEnabled
        public Integer subCategoryCount {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        
    }
    
}