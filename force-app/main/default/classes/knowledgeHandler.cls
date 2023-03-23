/*

TestClass knowledgeHandlerTest

*/
public class knowledgeHandler{
    
    public static void beforeInsert(List<KB__kav> newList){
        for(KB__kav kb : newList){
            if(articleStatusCheck(kb.Article_Status__c) != 1  && kb.Publisher_First_Name__c== null){
                kb.addError('Knowledge should be created in Draft Stage');
            }
        }
    }
    
    public static void beforeUpdate(List<KB__kav> newList, Map<Id, KB__kav> newMap, Map<Id,KB__kav> oldmap){
        
        List<String> accessLevel = Label.Knowledge_Access_Level.split(',');
        Map<String,Integer> accessDefined = new Map<String,Integer>();
        for(String accessControl : accessLevel){
            List<String> getAccess = accessControl.split('-');
            accessDefined.put(getAccess[0],Integer.valueOf(getAccess[1]));
        }
        PermissionSetAssignment psa = null;
        
        List<PermissionSetAssignment> psaLst = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =:UserInfo.getUserId() AND PermissionSetId =: Label.Knowledge_Base_Article_Owner_Access];
        
        if(psaLst.size() > 0 && !psaLst.IsEmpty()){
            psa = psaLst[0];
        }
        
        List<GroupMember> groupMembers = [SELECT Group.DeveloperName,UserOrGroupId FROM GroupMember WHERE Group.DeveloperName IN: accessDefined.KeySet() AND UserOrGroupId =: UserInfo.getUserId()];
        
        Set<String> groupMembersLst = new Set<String>();
        for(GroupMember grpMembr : groupMembers){
            groupMembersLst.add(grpMembr.Group.DeveloperName);
        }
        system.debug('groupMembersLst ' + groupMembersLst);
        system.debug('accessDefined ' + accessDefined);
        
        for(KB__kav kb : newList){
            if(kb.Article_Status__c != oldmap.get(kb.Id).Article_Status__c){
                Integer currentStatus = articleStatusCheck(kb.Article_Status__c);
                Integer oldStatus = articleStatusCheck(oldmap.get(kb.Id).Article_Status__c);
                Boolean canChangeStatus = false;
                if(psa != null && currentStatus <= 2){
                    canChangeStatus = true;
                }
                for(String grpMemLst : groupMembersLst){
                    if(accessDefined.get(grpMemLst) >= currentStatus){
                        canChangeStatus = true;
                        break;
                    }
                }
                if(canChangeStatus){
                    if(oldStatus != (currentStatus - 1) && (currentStatus > oldStatus)){
                        kb.addError('You can only move Article Status to ' + getArticleStatus((oldStatus + 1)) + '.');
                    }
                }else{
                    kb.addError('You are not authorised to move the Article Status to ' + getArticleStatus((currentStatus)) + '.');
                }
            }
        }
    }
    
    public static Integer articleStatusCheck(String status){
        switch on status{
            
            when 'Draft'{
                return 1;
            }
                
            when 'Ready for Review'{
                return 2;
            }
                
            when 'In Review'{
                return 3;
            }
            
            when 'Pending Approval'{
                return 4;
            }
            
            when 'Approved'{
                return 5;
            }
            
            when 'Published'{
                return 6;
            }
            
            when else {
                return 0;
            }
            
        }
    }
    
    public static String getArticleStatus(Integer statusEnum){
        switch on statusEnum{
            when 1{
                return 'Draft';
            }
            
            when 2{
                return 'Ready for Review';
            }
            
            when 3{
                return 'In Review';
            }
            
            when 4{
                return 'Pending Approval';
            }
            
            when 5{
                return 'Approved';
            }
            
            when 6{
                return 'Published';
            }
            
            when else{
                return '';
            }
        }
    }
}