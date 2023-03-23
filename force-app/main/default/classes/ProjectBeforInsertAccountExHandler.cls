public class ProjectBeforInsertAccountExHandler {
    public static void updateExtentison(List<inspire1__Project__c> lstProject, Map<Id,inspire1__Project__c> mapOldProjects)  {
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll(); 
        
        if(tsmap != null && !tsmap.isEmpty() &&
           tsmap.containsKey('UpdateProjectAccountExtentsion') && tsmap.get('UpdateProjectAccountExtentsion') != null &&
           tsmap.get('UpdateProjectAccountExtentsion').Execute__c)  {
            Map<Id, Id> extMap = new Map<Id, Id>();
            Set<String> extIdSet = new Set<String>();
            for(inspire1__Project__c project : lstProject){
                if(mapOldProjects == null || (mapOldProjects.get(project.Id).inspire1__Account__c != project.inspire1__Account__c)){
                    extIdSet.add(project.inspire1__Account__c);
                }
            }
            
            if(extIdSet.size() > 0)  {
                List<Account_Extension__c> accExList = new List<Account_Extension__c>();
                for(Account_Extension__c ae :  [select Id, Account__c from Account_Extension__c where Account__c IN :extIdSet])  {
                    extMap.put(ae.Account__c, ae.id);
                    
                }
                
                for(inspire1__Project__c pro : lstProject){
                    if(mapOldProjects == null || (mapOldProjects.get(pro.Id).inspire1__Account__c != pro.inspire1__Account__c)){
                        pro.Account_Extension__c = extMap.get(pro.inspire1__Account__c);
                    }
                }
            }
        }
    } 
    //for CR 735 -- Start
    public static void updateRegionOnProject(List<inspire1__Project__c> projectList){
        Map<ID,Schema.RecordTypeInfo> rt_Map = inspire1__Project__c.sObjectType.getDescribe().getRecordTypeInfosById();
        Map<id, Account> accountMap = new Map<id, Account>();
        Set<Id> accountId = new Set<Id>();
        
        for(inspire1__Project__c project: projectList){
            system.debug('Inside>> '+rt_map.get(project.recordTypeID).getName().containsIgnoreCase('Deployment Project'));
            if(rt_map.get(project.recordTypeID).getName().containsIgnoreCase(System.label.Label_for_Project_Object_Record_Type_Deployment_Project) && (String.isNotBlank(project.inspire1__Account__c) || project.inspire1__Account__c!=null)){
                accountId.add(project.inspire1__Account__c);
            }
        }
        if(!accountId.isEmpty()){
            accountMap = new Map<id, Account>([SELECT Id, Geo__c FROM Account WHERE Id IN :accountId]);
        }
        
        if(!accountMap.isEmpty()){
            for (inspire1__Project__c project : projectList) {
                project.Region__c = accountMap.get(project.inspire1__Account__c).Geo__c;
            }
        }
    }
    //for CR 735 -- End
}