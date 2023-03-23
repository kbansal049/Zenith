trigger JiraTicketTrigger on JIRA_Ticket__c (before insert, before update, after insert, after update) {
    
    Boolean skiptrigger = false;
    
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    
    //User Base Skip Logic
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(usertoskip != null && objname != null &&  usertoskip.Object_s_to_skip__c != null && 
       usertoskip.Object_s_to_skip__c.split(';') != null &&
       usertoskip.Object_s_to_skip__c.split(';').contains(objname))
    {
        skiptrigger = true;
    }
    
    //Trigger Switch Base Skip Logic
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    if(!skiptrigger &&  tsmap != null && !tsmap.isEmpty() &&
       tsmap.containsKey('Execute_JIRA_Ticket_Trigger') && tsmap.get('Execute_JIRA_Ticket_Trigger') != null &&
       tsmap.get('Execute_JIRA_Ticket_Trigger').Execute__c)
    {
        
        if(!TriggerUtility.isJiraTicketExecuted()){
            
            if(Trigger.isbefore){
                if(Trigger.isInsert || Trigger.isUpdate){
                
                   Id enhRTId = Schema.SObjectType.JIRA_Ticket__c.getRecordTypeInfosByName().get('Improvement').getRecordTypeId();
                   Id bugRTId = Schema.SObjectType.JIRA_Ticket__c.getRecordTypeInfosByName().get('Bug').getRecordTypeId();
                    for(JIRA_Ticket__c jt : trigger.new){
                        
                        if(jt.Name == null || String.isEmpty(jt.Name)){
                            jt.name = jt.Ticket_Number__c;
                        }
                        if(jt.Ticket_Type__c == 'Improvement'){
                            jt.recordtypeId = enhRTId;
                        }else if(jt.Ticket_Type__c == 'Bug'){
                            jt.recordtypeId = bugRTId;
                        }
                    }              
                }
            }
            
            if(Trigger.isafter){
                if(Trigger.isInsert){
                    System.enqueueJob(new JiraTicketTriggerQueueHandler(trigger.newMAP,true)); 
                }else if(Trigger.isUpdate){
                    System.enqueueJob(new JiraTicketTriggerQueueHandler(trigger.newMAP,false)); 
                }
            }
        }
    }
}