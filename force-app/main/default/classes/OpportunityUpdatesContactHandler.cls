@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
public class OpportunityUpdatesContactHandler {
    
    public static void afterUpdate(Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap)  {
        List<Id> lstOppIds = new List<Id>();
        system.debug('inside OpportunityUpdatesContactHandler ');
        for(Id oppID : newMap.KeySet())  {
            Opportunity opp = newMap.get(oppId);
            if(oldMap.get(oppID).StageName != opp.StageName )  {
                lstOppIds.add(opp.Id);
            }
        } 
        system.debug('lstOppIds '+lstOppIds);
        if(lstOppIds.size() > 0)  {
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('OpportunityUpdatesContactHandler') && tsmap.get('OpportunityUpdatesContactHandler') != null && tsmap.get('OpportunityUpdatesContactHandler').Execute__c && !TriggerUtility.isOpportunityUpdatesContactHandler()){
            updateContactRoles(lstOppIds);
        }
        }
    }
    
    
    public static void updateContactRoles(List<Id> lstOppIds)  {
        List<OpportunityContactRole> oppContactRoleList = [SELECT ID,isprimary,OpportunityId, Opportunity.StageName, Opportunity.Type, ContactId , contact.Contact_Lead_Status__c ,contact.Involved_in_Active_Oppty__c  
                                                           FROM OpportunityContactRole 
                                                           WHERE OpportunityId IN : lstOppIds 
                                                           AND (Opportunity.Type = 'New Business' or Opportunity.Type = 'Existing Customer (Add On)')]; // Removed 'FOR UPDATE' part of IBA-5602
        
        List<Id> conreclist = new List<Id>();
        List<Id> oppList = new List<Id>();
        Map<id,Opportunity> conOppMap = new Map<id,Opportunity>();
        for(OpportunityContactRole oppcon : oppContactRoleList){
            system.debug('oppcon '+oppcon);
            conreclist.add(oppcon.ContactId);
            oppList.add(oppcon.OpportunityId);
        }
        system.debug('conreclist '+conreclist);
        system.debug('oppList '+oppList);
        List<Contact> listOfCon = [Select id,Contact_Lead_Status__c,Involved_in_Active_Oppty__c, (SELECT ID,isprimary, Opportunity.StageName, Opportunity.Type, ContactId 
                                                                                                  FROM OpportunityContactRoles 
                                                                                                  WHERE (Opportunity.Type = 'New Business' or Opportunity.Type = 'Existing Customer (Add On)')) 
                                   From Contact where id in: conreclist ];  // and Contact_Lead_Status__c!='Actively Engaged (System Use)'
        //added Contact_Lead_Status__c condition for CR# 2489 : Gurjinder
        List<Contact> contList = new List<Contact>();
        //OpportunityContactTriggerHandler.updateContact(listOfCon);
        
        Set<Id> setOfId = new Set<Id>();
        Set<Id> setOfId2 = new Set<Id>();
        Set<Id> setOfId3 = new Set<Id>();
        Map<id,String> mapString = new Map<id,String>();
        for (Contact con :listOfCon ){
            system.debug('con   '+con);
            String closedrecreason = '';
            for (OpportunityContactRole oppContactRole : con.OpportunityContactRoles ){
                Opportunity opp = oppContactRole.Opportunity;
                //Opportunity oldOpp = Trigger.oldmap.get(opp.id);
                //Opportunity newOpp = Trigger.newmap.get(opp.id);
                Contact c = new Contact(Id = oppContactRole.ContactId);
                if(oppList.contains(opp.id)){
                    closedrecreason = opp.StageName == System.Label.Stage_6_Closed_Won  ? 'Opportunity - Closed/Won' : 'Opportunity - Closed/Lost' ;
                }
                
                System.debug('--opp.StageName--'+opp.StageName);
                 if(opp.StageName != Label.Stage_6_Closed_Won && opp.StageName != Label.Stage_7_Closed_Lost) {
                    system.debug(' inside if opp stage is not Closed won/lost  ');
                    setOfId.add(c.id);
                    
                } 
                /* if(opp.StageName== Label.Stage_6_Closed_Won || opp.StageName == Label.Stage_7_Closed_Lost) {
                   system.debug(' inside if opp stage is Closed won/lost  ');
                    setOfId.add(c.id);
                    
                } */else{
                    system.debug(' inside if opp stage is Closed won/lost  ');
                    setOfId3.add(c.id);
                }
                
                if(con.Contact_Lead_Status__c=='Actively Engaged (System Use)'){
                    system.debug(' inside of setOfId2 if');
                    setOfId2.add(c.id);
                }
            }
            
            system.debug('setOfId '+setOfId);
            system.debug('setOfId2 '+setOfId2);
            system.debug('setOfId3 '+setOfId3);
            if(!setOfId.contains(con.Id) ){ //For Closed Won/Lost Opportunities
                system.debug('inside first if');
                Contact c = new Contact(Id = con.Id);
                //Added By Gurjinder : For Fullcircle :Start
                    c.Contact_Lead_Status__c = 'Recycled to Marketing';
                
                c.Involved_in_Active_Oppty__c = false;
                c.Remarks__c = closedrecreason;
                contList.add(c);
            }else {  //For Open Opportunities
            system.debug('inside else');
                Contact c = new Contact(Id = con.Id);
                //Added By Gurjinder : For Fullcircle :Start
                if(!setOfId2.contains(con.Id)){
                    system.debug('inside second if');
                    c.Contact_Lead_Status__c = 'Actively Engaged';   
                }               
                c.Involved_in_Active_Oppty__c = true;
                //c.Remarks__c = closedrecreason;
                contList.add(c);
            }
        }
        
        if(!contList.isEmpty()) update contList;
    }
}