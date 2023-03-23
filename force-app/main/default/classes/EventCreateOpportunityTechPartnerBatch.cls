public class EventCreateOpportunityTechPartnerBatch  implements Database.Batchable<SObject>,Database.Stateful,Schedulable {
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('EventCreateOpportunityTechPartnerBatch');
    public MAP<String,ID> validDomainsMAP = new MAP<String,ID>();
    
    public EventCreateOpportunityTechPartnerBatch(){
        validDomainsMAP = getValidDomainsList();
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        this.zscalerBatchFrameWorkObj.callStart();
        String query = 'Select Id,Opportunity__c,Technology_Partner_Associated__c,peopleai__Participants__c,StartDateTime from Event where Opportunity__c != null AND peopleai__MeetingStatus__c = \'Completed\' AND Technology_Partner_Associated__c = \'Needs to be Associated\' ';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Event> newEventlst) {
        this.zscalerBatchFrameWorkObj.callExecute(newEventlst[0]?.Id, newEventlst.size());
        System.debug('---validDomainsMAP--'+validDomainsMAP);
        
        Set<ID> oppIdSet = new Set<ID>();
        for(Event ev : newEventlst ){
            oppIdSet.add(ev.Opportunity__c);
        }
        System.debug('---oppIdSet--'+oppIdSet);
       
        MAP<ID,List<ID>> opportunityWithPartners = new MAP<ID,List<ID>>();
        MAP<ID,Opportunity_Partner__c> oppPartnerDetail = new MAP<ID,Opportunity_Partner__c>();
        for(Opportunity_Partner__c oPart : [Select id,Account__c,Account__r.Name,opportunity__c,Meeting_Date__c
                                            from Opportunity_Partner__c where 
                                            opportunity__c in : oppIdSet and 
                                            Partner_Type__c = 'Tech Partner'])
        {
            List<ID> opPartIDList = null;
            if(opportunityWithPartners.containskey(oPart.opportunity__c)){
                opPartIDList = opportunityWithPartners.get(oPart.opportunity__c);
            }else{
                opPartIDList = new List<ID>();
            }
            opPartIDList.add(oPart.Account__c);
            opportunityWithPartners.put(oPart.opportunity__c, opPartIDList);
            
            oppPartnerDetail.put(oPart.Account__c,oPart);
        }
        System.debug('---opportunityWithPartners--'+opportunityWithPartners);
        System.debug('---oppPartnerDetail--'+oppPartnerDetail);
        
        
        
        MAP<ID,Opportunity_Partner__c> oppPartnerToInsert = new  MAP<ID,Opportunity_Partner__c>();
        MAP<ID,Opportunity_Partner__c> oppPartnerToUpdate = new  MAP<ID,Opportunity_Partner__c>();
       	List<Event>  eventRecordtoBeUpdated = new List<Event>();
		
        for(Event ev : newEventlst){
            
            List<ID> eventOppPartIDList = opportunityWithPartners.get(ev.Opportunity__c);
            System.debug('---eventOppPartIDList--'+eventOppPartIDList); 
            
            Set<ID> partnersInEvent =  opportunityTechPartnersToBeAdded(validDomainsMAP,ev.peopleai__Participants__c);
            System.debug('---partnersInEvent--'+partnersInEvent); 
            
            Boolean isInsert = false;
            Boolean isUpdate = false;
            Boolean isAlredyExist = false;
            
            for(ID partnerID : partnersInEvent){
                if(eventOppPartIDList != null && eventOppPartIDList.contains(partnerID)){
                    Opportunity_Partner__c oppTechPartner = oppPartnerDetail.get(partnerID);
                    if(oppTechPartner.Meeting_Date__c == null || String.valueOf(oppTechPartner.Meeting_Date__c) == ''){
                        oppPartnerToUpdate.put(partnerID, new Opportunity_Partner__c(id = oppTechPartner.id, Meeting_Date__c = ev.StartDateTime));
                        isUpdate = true;
                    }else{ 
                        isAlredyExist = true;
                    }
                }else{
                    oppPartnerToInsert.put(partnerID, new Opportunity_Partner__c(Account__c = partnerID, Opportunity__c = ev.Opportunity__c, Meeting_Date__c = ev.StartDateTime, Partner_Type__c = 'Tech Partner'));
                    isInsert = true;
                }
            }
            
            if(isInsert || isUpdate){
                ev.Technology_Partner_Associated__c = 'Associated';
                eventRecordtoBeUpdated.add(ev);  
            }else if(isAlredyExist){
                ev.Technology_Partner_Associated__c = 'Already Associated';
                eventRecordtoBeUpdated.add(ev);  
            }
        }
        
        System.debug('---oppPartnerToInsert--'+oppPartnerToInsert); 
        if(oppPartnerToInsert.size()>0){
            Database.SaveResult[] srList = Database.insert(oppPartnerToInsert.values(),false);
        }
        
        System.debug('---oppPartnerToUpdate--'+oppPartnerToUpdate); 
        if(oppPartnerToUpdate.size()>0){
            Database.SaveResult[] srList = Database.update(oppPartnerToUpdate.values(),false);
        }
        
        System.debug('---eventRecordtOBeUpdated--'+eventRecordtOBeUpdated); 
        if(eventRecordtoBeUpdated.size()>0){
            TriggerUtility.createOpportunityPartnerFromEventExecuted();
            Database.SaveResult[] srList = Database.update(eventRecordtoBeUpdated,false);
        }
        
    }
    
    public void finish(Database.BatchableContext context) {
        this.zscalerBatchFrameWorkObj.callFinish(context);
    }
    
    
    //Get Valid Domains with Partner ID
    public MAP<String,ID> getValidDomainsList(){
        MAP<String,ID> validDomainsMAP = new MAP<String,ID>();
        for(Event_Tech_Partner_Automation__mdt etp : [Select Valid_Domains__c,Partner_ID__c from Event_Tech_Partner_Automation__mdt where Partner_ID__c != null and Valid_Domains__c != null]){
            if(String.isNotEmpty(etp.Valid_Domains__c)  && String.isNotEmpty(etp.Partner_ID__c)){
                for(String dom : etp.Valid_Domains__c.Split(',')){
                    if(dom != null && String.isNotEmpty(dom)){
                        validDomainsMAP.put(dom.trim(), etp.Partner_ID__c);
                    }
                }
            }
        }
        System.debug('--validDomainsMAP--'+validDomainsMAP);
        return validDomainsMAP;
    }
    
	public Set<ID> opportunityTechPartnersToBeAdded(MAP<String,ID> validDomainsMAP,String participants){
        Set<ID> retPartnerIDs = new Set<ID>();
        String parsedDomainList = (Label.Event_People_AI_Participant_Extra_Characters != null &&
                                   String.isNotEmpty(Label.Event_People_AI_Participant_Extra_Characters)
                                  ) ?
            					 participants.remove(Label.Event_People_AI_Participant_Extra_Characters) : 
        						 participants;
        for(String participantEmail : participants.split(',')){
            for(String dom : validDomainsMAP.keyset()){
                String domCheck = '@'+dom;
                if(participantEmail.containsIgnoreCase(domCheck)){
                    retPartnerIDs.add(validDomainsMAP.get(dom));
                }
            }
        }
        return retPartnerIDs;
    }
    
    
    public void execute(SchedulableContext SC){
         Database.executeBatch(new EventCreateOpportunityTechPartnerBatch(),1);
    }
}