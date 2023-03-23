trigger EventCreateRole on Event (before insert) {
    String uRoleId = UserInfo.getUserRoleId();
    String roleName = '';
    
    if(uRoleId != null )  {
        roleName = [select name from UserRole where id =:uRoleId ].name;
    }
    for(Event opp : trigger.new)  {
        opp.Role_of_Creator_When_Created1__c  = roleName;
    }

}