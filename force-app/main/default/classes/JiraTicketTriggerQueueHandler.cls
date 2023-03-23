//CR# 1051
public class JiraTicketTriggerQueueHandler implements queueable {

    //For Input
    private  Map<Id, JIRA_Ticket__c> jiraTicketMap = new Map<Id, JIRA_Ticket__c>();
    private Boolean isInsert = false;
    
    //constructor
    public JiraTicketTriggerQueueHandler(Map<Id, JIRA_Ticket__c>  passedMap, Boolean forInsert) {
        System.debug('--JiraTicketTriggerQueueHandler--passedMap--'+passedMap);
        System.debug('--JiraTicketTriggerQueueHandler--forInsert--'+forInsert);
        jiraTicketMap = passedMap;
        isInsert = forInsert;
    }
    
    //executes the queueable logic
    public void execute(QueueableContext qc) {
        
        if(jiraTicketMap != null && jiraTicketMap.size()>0){
            //IF isInsert = true -->[after Insert]
            if(isInsert){
                createAccountJIRAIntegartionRecords(jiraTicketMap);
            }
            
            //IF isInsert = false -->[after Update || after Delete]
            else{
                 updateAccountJIRAIntegartionRecords(jiraTicketMap);
            }
        }
    }
    
    
    //Call During After Insert
    public void createAccountJIRAIntegartionRecords(Map<ID, JIRA_Ticket__c> mapNew){
        List<Account_JIRA_Integration__c> accountJIRARecords = new List<Account_JIRA_Integration__c>();
        for(JIRA_Ticket__c jt : mapNew.values()){
            if(jt.Account_IDs__c != null && String.isNotBlank(jt.Account_IDs__c)){
                for(ID accID : getValidAccIDs(jt.Account_IDs__c)){
                    accountJIRARecords.add(new Account_JIRA_Integration__c(Account__c =accID, JIRA_Ticket__c = jt.id));
                }
            }
        }
        if(accountJIRARecords.size()>0){
            //Insert accountJIRARecords;
            //IBA-2448
            Database.insert(accountJIRARecords,false);
        }
    }
    
    
    
    //Call During After Update
    public void updateAccountJIRAIntegartionRecords(Map<ID, JIRA_Ticket__c> mapNew){
        List<Account_JIRA_Integration__c> accountJIRARecords = new List<Account_JIRA_Integration__c>();
        
        MAP<ID,List<Account_JIRA_Integration__c>> jtAccAssicationMAP = new MAP<ID,List<Account_JIRA_Integration__c>>();
        
        for(Account_JIRA_Integration__c accJira : [Select ID,Name,JIRA_Ticket__c,Account__c from Account_JIRA_Integration__c where JIRA_Ticket__c in : mapNew.keySet()]){
            List<Account_JIRA_Integration__c> accJiraList = jtAccAssicationMAP.containskey(accJira.JIRA_Ticket__c) 
                ? jtAccAssicationMAP.get(accJira.JIRA_Ticket__c) 
                : new List<Account_JIRA_Integration__c>();
            accJiraList.add(accJira);
            jtAccAssicationMAP.put(accJira.JIRA_Ticket__c,accJiraList);
        }
        System.debug('--jtAccAssicationMAP--'+jtAccAssicationMAP);
        
        MAP<ID,Set<ID>> deleteJiraTicketIntegrationRecords = new MAP<ID,Set<ID>>();
        
        for(JIRA_Ticket__c jiraTicket : mapNew.values()){
            
            if(jtAccAssicationMAP.containskey(jiraTicket.Id)){
                
                List<Account_JIRA_Integration__c> existingList = jtAccAssicationMAP.get(jiraTicket.Id);
                MAP<Id,Id> accJIRAMap = new  MAP<Id,Id>();
                for(Account_JIRA_Integration__c acjt : existingList){
                    if(acjt.Account__c != null){
                        accJIRAMap.put(acjt.Account__c, acjt.Id);
                    }
                }
                System.debug('--accJIRAMap--'+accJIRAMap);
                
                Set<ID> delJiraIDSet = new Set<ID>();
                for(Account_JIRA_Integration__c accJiraInt : existingList){
                    delJiraIDSet.add(accJiraInt.Id);
                }
                
                System.debug('--delJiraIDSet before--'+delJiraIDSet);
                
                
                Set<ID> newAccIDSet = new Set<ID>();
                if(jiraTicket.Account_IDs__c != null && String.isNotBlank(jiraTicket.Account_IDs__c)){
                    for(ID accID : getValidAccIDs(jiraTicket.Account_IDs__c)){
                        System.debug('--accID--'+accID);
                        if(accJIRAMap.keyset().contains(accID)){
                            delJiraIDSet.remove(accJIRAMap.get(accID));
                        }else{
                            newAccIDSet.add(accID);
                        }
                    }
                }
                
                
                System.debug('--delJiraIDSet after--'+delJiraIDSet);
                
                deleteJiraTicketIntegrationRecords.put(jiraTicket.id, delJiraIDSet);
                
                
                System.debug('--newAccIDSet--'+newAccIDSet);
                
                //Insert Account Jira Integration for newly Added account ID
                for(ID accID : newAccIDSet){
                    accountJIRARecords.add(new Account_JIRA_Integration__c(Account__c =accID, JIRA_Ticket__c = jiraTicket.id));
                }
            }
            else{
                if(jiraTicket.Account_IDs__c != null && String.isNotBlank(jiraTicket.Account_IDs__c)){
                    for(ID accID : getValidAccIDs(jiraTicket.Account_IDs__c)){
                        accountJIRARecords.add(new Account_JIRA_Integration__c(Account__c =accID, JIRA_Ticket__c = jiraTicket.id));
                    }
                } 
            }
            
        }
        
        System.debug('--deleteJiraTicketIntegrationRecords--'+deleteJiraTicketIntegrationRecords);
        if(deleteJiraTicketIntegrationRecords.size()>0){
            MAP<ID,Account_JIRA_Integration__c> jiraAccountIntegartionRecordsForDelete = new MAP<ID,Account_JIRA_Integration__c>();
            for(Id jiraticketID : deleteJiraTicketIntegrationRecords.keyset()){
                for(Id assoRecordID : deleteJiraTicketIntegrationRecords.get(jiraticketID)){
                    jiraAccountIntegartionRecordsForDelete.put(assoRecordID,new Account_JIRA_Integration__c(Id = assoRecordID));
                }
            }
            System.debug('--jiraAccountIntegartionRecordsForDelete--'+jiraAccountIntegartionRecordsForDelete);
            if(jiraAccountIntegartionRecordsForDelete.size()>0){
                delete jiraAccountIntegartionRecordsForDelete.values();
            }
        }
       
        
        System.debug('--accountJIRARecords--'+accountJIRARecords);
        if(accountJIRARecords.size()>0){
            //Insert accountJIRARecords;
            //IBA-2448
            Database.insert(accountJIRARecords,false);
        }

    }
    
    public set<ID> getValidAccIDs(String accIDSet){
        set<ID> retList = new set<ID>();
        for(String accID : accIDSet.split(',')){
            if(accID != null && String.isNotBlank(accID.trim()) ){
                string acID = accID.trim();
                if(acID InstanceOf ID && ID.valueOf(acID).getSObjectType() == Account.sObjectType){
                    retList.add(ID.valueOf(acID)); 
                }
            }
        }
        return retList;
    }
    
}