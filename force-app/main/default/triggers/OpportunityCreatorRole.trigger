trigger OpportunityCreatorRole on Opportunity (before insert) {
    /*
    String uRoleId = UserInfo.getUserRoleId();
    String roleName = '';
    if(uRoleId != null )  {
        roleName = [select name from UserRole where id =:uRoleId ].name;
    }
    for(Opportunity opp : trigger.new)  {
        opp.Role_of_Creator_When_Created1__c  = roleName;
    }
	*/
}