public with sharing class ProvisioningRequestNewController {
	public static Map<Id, String> recordtypemap {get;set;}
    
   @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Provisioning_Request__c.SObjectType.getDescribe().getRecordTypeInfos();
        recordtypemap = new Map<Id, String>();
        List<String> RecordTypeName = new List<String>();
        RecordTypeName = Label.ProvisioningReqRecordType.split(';');
        for(RecordTypeInfo rt : recordtypes){
            if(!System.Label.Core_Sales_SE.contains(userInfo.getProfileId())){
                if(rt.getName() != 'Master')
            		recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }//Add by Swathi : CR#2558 Start
            else{
                if(RecordTypeName.contains(rt.getName()))
            		recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }//Add by Swathi : CR#2558 End
        }
        return recordtypemap.values(); 
    }
    
    @AuraEnabled
    public static Opportunity getOpp(String recId){
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = [Select id,StageName,Account_Org_Domain__c,Name,SE_Name__c,AccountId from Opportunity where id= :recId];
        if(!oppList.isEmpty())
        	return oppList[0];
        else
            return null;
    } 
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
        return recid;
        
    }  
    
    @AuraEnabled
    public static String getUserRole(){
        User uObj = [Select id, UserRoleId, UserRole.Name from User where id = :Userinfo.getUserId()];     
        if(uObj.UserRoleId != null)
            return uObj.UserRole.Name;
        return null;
    }  
}