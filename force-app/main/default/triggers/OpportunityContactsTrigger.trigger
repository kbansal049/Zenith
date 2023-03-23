trigger OpportunityContactsTrigger on OpportunityContactRole (after insert, after update) {
    Boolean skiptrigger = false;
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    
    if(!skiptrigger)  {
    List<Id> lstIDs = new List<id>();
    for(OpportunityContactRole op : Trigger.New)  {
        if(Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(op.Id).ContactId != op.ContactId))  {
            lstIDs.add(op.Id);
        }
    }
    system.debug('lstIDs '+lstIDs);
    if(lstIDs.size() > 0)  {
        List<OpportunityContactRole> oppContactRoleList = [SELECT ID,IsPrimary, Opportunity.StageName, Opportunity.Type, ContactId , contact.Contact_Lead_Status__c ,contact.Involved_in_Active_Oppty__c  
                                                           FROM OpportunityContactRole 
                                                           WHERE ID IN : lstIDs 
                                                           AND (Opportunity.Type = 'New Business' or Opportunity.Type = 'Existing Customer (Add On)')];
        List<Id> conreclist = new List<Id>();
        
        for(OpportunityContactRole oppcon : oppContactRoleList){
            system.debug('oppcon  '+oppcon);
            conreclist.add(oppcon.ContactId);
        }
        system.debug('conreclist '+conreclist);
        List<Contact> listOfCon = [Select id,Contact_Lead_Status__c,Involved_in_Active_Oppty__c, (SELECT ID,IsPrimary ,Opportunity.StageName, Opportunity.Type, ContactId 
                                                                                                  FROM OpportunityContactRoles 
                                                                                                  WHERE ID IN : Trigger.New 
                                                                                                  AND (Opportunity.Type = 'New Business' or Opportunity.Type = 'Existing Customer (Add On)') ) 
                                   From Contact where id in: conreclist and Contact_Lead_Status__c!='Actively Engaged (System Use)'];
        
        system.debug('before calling OpportunityContactTriggerHandler.updateContact ' );
        OpportunityContactTriggerHandler.updateContact(listOfCon);
    } 
        }
    
}