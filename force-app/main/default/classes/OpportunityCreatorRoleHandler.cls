public class OpportunityCreatorRoleHandler {
    
    public static void before(List<Opportunity> lst)  {
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('OpportunityCreatorRoleHandler') && tsmap.get('OpportunityCreatorRoleHandler') != null && tsmap.get('OpportunityCreatorRoleHandler').Execute__c && !TriggerUtility.isOpportunityCreatorRoleHandler()){
            updateCreatorRole(lst);
        }
    }
    
    public static void updateCreatorRole(List<Opportunity> lst)  {  
        String uRoleId = UserInfo.getUserRoleId();
        String roleName = '';
        if(uRoleId != null )  {
            roleName = [select name from UserRole where id =:uRoleId ].name;
        }
        for(Opportunity opp : lst)  {
            opp.Role_of_Creator_When_Created1__c  = roleName;
        }
    }
}