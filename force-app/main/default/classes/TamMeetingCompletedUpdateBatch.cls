public class TamMeetingCompletedUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('TamMeetingCompletedUpdateBatch');
	public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        DateTime currentTime = System.now();
        String query = 'select Id, Date_of_meeting__c, Status__c, Customer_Name__r.Name, Name,Executive_Summary__c from Meeting__c where Status__c=\'Scheduled\' and Date_of_meeting__c<=:currentTime';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<Meeting__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        Map<Id, List<String>> mapOfMeetingAndDocument = new Map<Id, List<String>>();
        List<Id> listOfScopeId = new List<Id>();
        for(Meeting__c meet: scope){
            listOfScopeId.add(meet.Id);
        }
        for(ContentDocumentLink conLink: [select id , LinkedEntityId, ContentDocument.Title, ContentDocument.FileExtension from ContentDocumentLink where LinkedEntityId IN:listOfScopeId and ContentDocument.FileExtension='pdf']){
            system.debug('conLink'+ conLink);
            if(!mapOfMeetingAndDocument.containsKey(conLink.LinkedEntityId)){
                mapOfMeetingAndDocument.put(conLink.LinkedEntityId, new List<String>());
            }
            mapOfMeetingAndDocument.get(conLink.LinkedEntityId).add(conLink.ContentDocument.Title);
        }
        List<Meeting__c> listOfMeetingsToUpdate = new List<Meeting__c>();
        for(Meeting__c meeting:scope){
            if(mapOfMeetingAndDocument.containsKey(meeting.Id) && mapOfMeetingAndDocument.get(meeting.Id) != null && !mapOfMeetingAndDocument.get(meeting.Id).isEmpty()){
                /*String name = meeting.Name+' - '+meeting.Customer_Name__r.Name+'.pdf';
                system.debug('name:'+name);
                if(mapOfMeetingAndDocument.get(meeting.Id).contains(name)){
                    meeting.Status__c = 'Completed';
                    listOfMeetingsToUpdate.add(meeting);
                }*/
                
                //Added By Anup: CR#1817 - Start
                //CR# 4183 - Start
                 if(meeting.Executive_Summary__c!=null){
                    meeting.Status__c = 'Completed';
                    listOfMeetingsToUpdate.add(meeting); 
                }
                //CR# 4183 - End
                //Added By Anup: CR#1817 - End
            }
        }

        if(!listOfMeetingsToUpdate.isEmpty()) {
            Database.update(listOfMeetingsToUpdate, false);
        }       
    }
    public void finish(Database.BatchableContext context){
    	this.zb.callFinish(context);
    }
}