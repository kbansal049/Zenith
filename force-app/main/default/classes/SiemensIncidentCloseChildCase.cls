public class SiemensIncidentCloseChildCase implements queueable {
    
    //For Input
    private  List<Id> caseIntegartionIdList = new List<Id>();
    
    //constructors
    public SiemensIncidentCloseChildCase(List<Id> caseIntegartionIdList) {
        this.caseIntegartionIdList = caseIntegartionIdList;
    }
    
    //executes the queueable logic
    public void execute(QueueableContext qc) {
        
        System.debug('--SiemensIncidentCloseChildCase--caseIntegartionIdList--'+caseIntegartionIdList);
        
        if(caseIntegartionIdList != null && caseIntegartionIdList.size()>0){
            List<Case_Integration__c> csiupdate = new  List<Case_Integration__c>();
            
            List<String> parentTicketIDList = new List<String>();
            for(Case_Integration__c ci : [Select id,name,External_ID__c,Ticket_Status__c from Case_Integration__c where id in :caseIntegartionIdList and Ticket_Status__c = 'Closed']){
                parentTicketIDList.add(ci.External_ID__c);
            }
            
            System.debug('--SiemensIncidentCloseChildCase--parentTicketIDList--'+parentTicketIDList);
            
            for(Case_Integration__c ciChild : [Select id,name,External_ID__c,Ticket_Status__c,Parent_Incident__c 
                                               from Case_Integration__c where Parent_Incident__c != null and 
                                               Parent_Incident__c in :parentTicketIDList and Ticket_Status__c != 'Closed'])
            {
                ciChild.Ticket_Status__c = 'Closed';
                csiupdate.add(ciChild);
            }
            
            System.debug('--SiemensIncidentCloseChildCase--childTicket--csiupdate--'+csiupdate);
            
            
            //Importnant Step to break the Loop
            TriggerUtility.caseCaseIntegartionPatchSetTrue();
            TriggerUtility.SkipCaseTriggerExecuted();
            update csiupdate;
        }
    }
}