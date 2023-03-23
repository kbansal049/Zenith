trigger OpportunityUpdatesContactTrigger on Opportunity (after insert, after update) {
    /*
    List<OpportunityContactRole> oppContactRoleList = [SELECT ID,OpportunityId, Opportunity.StageName, Opportunity.Type, ContactId , contact.Contact_Lead_Status__c ,contact.Involved_in_Active_Oppty__c  
                                                       FROM OpportunityContactRole 
                                                       WHERE OpportunityId IN : Trigger.New 
                                                       AND (Opportunity.Type = 'New Business' or Opportunity.Type = 'Existing Customer (Add On)')];
    List<Id> conreclist = new List<Id>();
    List<Id> oppList = new List<Id>();
    Map<id,Opportunity> conOppMap = new Map<id,Opportunity>();
    for(OpportunityContactRole oppcon : oppContactRoleList){
        conreclist.add(oppcon.ContactId);
        oppList.add(oppcon.OpportunityId);
    }
    List<Contact> listOfCon = [Select id,Contact_Lead_Status__c,Involved_in_Active_Oppty__c, (SELECT ID, Opportunity.StageName, Opportunity.Type, ContactId 
                                                                                              FROM OpportunityContactRoles 
                                                                                              WHERE (Opportunity.Type = 'New Business' or Opportunity.Type = 'Existing Customer (Add On)')) 
                               From Contact where id in: conreclist ];
    
    List<Contact> contList = new List<Contact>();
    //OpportunityContactTriggerHandler.updateContact(listOfCon);
    
    Set<Id> setOfId = new Set<Id>();
    Map<id,String> mapString = new Map<id,String>();
    for (Contact con :listOfCon ){
        String closedrecreason = '';
        for (OpportunityContactRole oppContactRole : con.OpportunityContactRoles ){
            Opportunity opp = oppContactRole.Opportunity;
            Opportunity oldOpp = Trigger.oldmap.get(opp.id);
            //Opportunity newOpp = Trigger.newmap.get(opp.id);
            Contact c = new Contact(Id = oppContactRole.ContactId);
            if(oppList.contains(opp.id)){
                closedrecreason = opp.StageName == '6 - Closed Won' ? 'Opportunity - Closed/Won' : 'Opportunity - Closed/Lost' ;
            }
            
            System.debug('--opp.StageName--'+opp.StageName);
                if(opp.StageName == '1 - Alignment' || opp.StageName == '2 - Qualified & Budgeted'|| opp.StageName == '3 - Value & Impact Validation' || opp.StageName == '4 - Economic Buyer Signoff' || opp.StageName =='5 - Contracts Complete') {

                        setOfId.add(c.id);

                }
            
        }
        System.debug('--con--'+con.id);
        System.debug('--setOfId--'+setOfId);
        if(!setOfId.contains(con.Id)){
            Contact c = new Contact(Id = con.Id);
            c.Contact_Lead_Status__c = 'Recycled to Marketing';
            c.Involved_in_Active_Oppty__c = false;
            c.Remarks__c = closedrecreason;
            contList.add(c);
        }else{
            Contact c = new Contact(Id = con.Id);
            c.Contact_Lead_Status__c = 'Actively Engaged';
            c.Involved_in_Active_Oppty__c = true;
            //c.Remarks__c = closedrecreason;
            contList.add(c);
        }
    }
    
    if(!contList.isEmpty()) update contList;
    */
}