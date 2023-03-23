//Added By Swathi: CR#1127/CR#1416 - Start
public class UpdateTaskSDRFieldsbasedOnLeadAndCont implements System.Queueable{
    private Set<Id> TaskIds;
    
    public UpdateTaskSDRFieldsbasedOnLeadAndCont(Set<Id> TaskIds) {
        this.TaskIds = TaskIds;
    }
    public void execute(QueueableContext context) {
        
        List<Task> TaskList= new List<Task>();
        Map<id,Task> Taskmap= new Map<id,Task>([Select id, WhoId, WhoCount, SDR_Qualified__c, (SELECT RelationId from TaskWhoRelations) FROM Task where id=:taskIds]);
        Map<Id, List<Task>> leadIdTaskMap = new Map<Id, List<Task>>();
        map<Id, List<Task>> contactIdTaskMap = new Map<Id, List<Task>>();
        Map<Id,String> mapofLeadContactForSDRValue = new Map<Id,String>();
        Map<Id,String> mapofLeadContactForSDRStatus = new Map<Id,String>();
        Boolean track=false;
        Boolean trackSDRQualified = false;
        if(Taskmap!=null){
            for(Task t : Taskmap.values()){
                if(t.WhoId != null){
                    Schema.SObjectType token = t.WhoId.getSObjectType();
                    String objName  = token.getDescribe().getName();
                    if(objName == 'Lead'){
                        if(!leadIdTaskMap.containsKey(t.WhoId)){
                            leadIdTaskMap.put(t.WhoId, new List<Task>());
                        }
                        leadIdTaskMap.get(t.WhoId).add(t);
                    }   
                    if(objName == 'Contact'){
                        if(t.WhoCount<=1){
                            if(!contactIdTaskMap.containsKey(t.WhoId)){
                                contactIdTaskMap.put(t.WhoId, new List<Task>());
                            }
                            contactIdTaskMap.get(t.WhoId).add(t);
                        }
                        else if(t.WhoCount > 1){
                            for (TaskWhoRelation tWho :t.TaskWhoRelations){
                                if(!contactIdTaskMap.containsKey(tWho.RelationId)){
                                    contactIdTaskMap.put(tWho.RelationId, new List<Task>());   
                                }
                                contactIdTaskMap.get(tWho.RelationId).add(t);
                            }
                        }
                    }
                }
            }
        }
        if(!leadIdTaskMap.isEmpty()){
            for(Lead currLead : [select id,Qualifying_SDR__c,Qualification_Status__c from Lead where Id IN:leadIdTaskMap.keyset()]){
                system.debug('### inside lead loop');
                system.debug('### currLead.Qualifying_SDR__c :'+currLead.Qualifying_SDR__c);
                system.debug('### currLead.id :'+currLead.id);
                mapofLeadContactForSDRValue.put(currLead.id,currLead.Qualifying_SDR__c);
                mapofLeadContactForSDRStatus.put(currLead.id,currLead.Qualification_Status__c);
            }
        }
        if(!contactIdTaskMap.isEmpty()){
            for(Contact currContact : [select id,Qualifying_SDR__c,Qualification_Status__c from Contact where Id IN:contactIdTaskMap.keyset()]){
                mapofLeadContactForSDRValue.put(currContact.id,currContact.Qualifying_SDR__c );
                mapofLeadContactForSDRStatus.put(currContact.id,currContact.Qualification_Status__c);
            }
        }
        for(Task currTask : Taskmap.values()){
            track = false;
            trackSDRQualified = false;
            if(currTask.WhoCount<=1){
                if(mapofLeadContactForSDRValue.containsKey(currTask.WhoId) && mapofLeadContactForSDRValue.get(currTask.WhoId) != null){
                    if(!currTask.SDR_Qualified__c){
                        currTask.SDR_Qualified__c = True;
                        trackSDRQualified = true;
                    }
                    if((mapofLeadContactForSDRStatus.containsKey(currTask.WhoId) && mapofLeadContactForSDRStatus.get(currTask.WhoId) == 'Disqualified')){
                        currTask.SDR_Qualified__c = False;
                        trackSDRQualified = true;
                    }
                    if(trackSDRQualified)
                        TaskList.add(currTask);
                }
                else if(mapofLeadContactForSDRValue.containsKey(currTask.WhoId) && mapofLeadContactForSDRValue.get(currTask.WhoId) == null && currTask.SDR_Qualified__c){
                    currTask.SDR_Qualified__c = False;
                    TaskList.add(currTask);
                }
            }else{
                for(TaskWhoRelation tWho :currTask.TaskWhoRelations){
                    system.debug('### tWho Id :'+tWho.RelationId);
                    if((mapofLeadContactForSDRValue.containsKey(tWho.RelationId) && mapofLeadContactForSDRValue.get(tWho.RelationId) != null && !track)){
                        system.debug('### tWho Id inside if');
                        if(/*!currTask.SDR_Qualified__c &&*/ mapofLeadContactForSDRStatus.containsKey(tWho.RelationId) && mapofLeadContactForSDRStatus.get(tWho.RelationId) != 'Disqualified'){
                            system.debug('### tWho Id inside 2nd if');
                            currTask.SDR_Qualified__c = True;
                            trackSDRQualified = true;
                            track = true;
                            TaskList.add(currTask);
                        }
                    }
                }
                if(!track && currTask.SDR_Qualified__c){
                    system.debug('### tWho Id inside 5th if');
                    currTask.SDR_Qualified__c = False;
                    TaskList.add(currTask);
                }
            }
        }
    
        List<String> errorlst = new List<String>();
        List<String> successlst = new List<String>();
        try{
            TriggerUtility.isPopulateCampaignMostRecentOnTaskExecuted();
            TriggerUtility.isCampMemActivityExecuted();
            TriggerUtility.isActivityleadterritoryinsertExecuted();
            TriggerUtility.isActivityleadterritoryupdateExecuted();
            System.debug('TaskList'+TaskList);
            update TaskList;
            successlst.add('Success message');
        }catch(Exception e){ 
            errorlst.add('Exception in Task class: . Exception is ' + e);
        }
        if(!errorlst.isEmpty() || Test.isRunningTest()){
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
            list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
            //if(!errorlst.isEmpty() || Test.isRunningTest()){
                Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
                if ( owea.size() > 0 ) {
                    mail1.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail1.setsenderDisplayName('Sales Ops System Admin');
                }
                mail1.setSubject('Update task field Queueable job failed');
                String msgbody = 'Below are the Ids of ' + errorlst.size() + ' Update task field Queueable job failed: \n';
                /*for(Id s: errorMap.keySet()){
                    msgbody += 'Id : '+s + ' Error Message : '+errorMap.get(s) +'\n';
                }*/
                mail1.setPlainTextBody(msgbody);
                messageList.add(mail1);
            //}
            if(!Test.isRunningTest()){
                Messaging.sendEmail(messageList);
            } 
        }
    }
}
 //Added By Swathi: CR#1127/CR#1416 - End