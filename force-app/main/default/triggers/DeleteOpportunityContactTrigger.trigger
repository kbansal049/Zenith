trigger DeleteOpportunityContactTrigger on OpportunityContactRole (before delete) {
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    
    if(!skiptrigger)  {
    List<OpportunityContactRole> oppContactRoleList = [SELECT ID, Opportunity.StageName, Opportunity.Type, ContactId , contact.Contact_Lead_Status__c ,contact.Involved_in_Active_Oppty__c  
                                                       FROM OpportunityContactRole 
                                                       WHERE ID IN : Trigger.old  
                                                       AND (Opportunity.Type = 'New Business' or Opportunity.Type = 'Existing Customer (Add On)')];
    List<Id> conreclist = new List<Id>();
    
    for(OpportunityContactRole oppcon : oppContactRoleList){
        conreclist.add(oppcon.ContactId);
    }
    
    List<Contact> listOfCon = [Select id,Contact_Lead_Status__c,Involved_in_Active_Oppty__c, (SELECT ID, Opportunity.StageName, IsPrimary, Opportunity.Type, ContactId 
                                                                                              FROM OpportunityContactRoles 
                                                                                              WHERE ID IN : Trigger.old 
                                                                                              AND (Opportunity.Type = 'New Business' or Opportunity.Type = 'Existing Customer (Add On)')) 
                               From Contact where id in: conreclist];
    
    OpportunityContactTriggerHandler.updateContact(listOfCon);
    } 
}