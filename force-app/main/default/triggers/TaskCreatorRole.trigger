trigger TaskCreatorRole on Task (before insert) {
    String uRoleId = UserInfo.getUserRoleId();
    String roleName = '';
    
    if(uRoleId != null )  {
        roleName = [select name from UserRole where id =:uRoleId ].name;
    }
    for(Task opp : trigger.new)  {
        opp.Role_of_Creator_When_Created1__c  = roleName;
        
    }
}