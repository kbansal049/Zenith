@RestResource(urlMapping='/NBMSYNC/*')
global with sharing class NBMSYNC {
    //CR: 1078 - Changes Start
    @HttpPost
    global static List<Id> doPost(List<Event> fedEvents, List<String> internalParticipants){
        System.debug('fedEvents->' + fedEvents + ', internalPaticpants->' + internalParticipants);

        //WARNING: The following code depends on the data's order, the two lists for fecEvents and participants sent from Fed MUST not change order before here
        //add internal participants from list input
        for(Integer i = 0; i < fedEvents.size(); i++){
            fedEvents[i].peopleai__Participants__c = internalParticipants[i];
        }

        //insert events
        String eventInsertErrMsg = 'The following errors occurred while trying to insert events during FedRAMP event sync:\n';
        Boolean eventInsertError = false; //true if there were any errors during insert
        Database.SaveResult[] eventInsertResults = Database.insert(fedEvents, false);
        for(Database.SaveResult eventInsertResult : eventInsertResults){
            if(!eventInsertResult.isSuccess()){
                eventInsertError = true;
                eventInsertErrMsg += 'Errors: ' + eventInsertResult.getErrors() + '\n';
            }
        }
        
        //if there were any errors, send an error message to admins
        if(eventInsertError){
            Messaging.SingleEmailMessage adminMail = new Messaging.SingleEmailMessage();
            adminMail.setToAddresses(new String[] {Label.BSYS_ALERT, 'sjelinek@zscaler.com'});
            adminMail.setSubject('Commercial SFDC Error: Automated Sync w/ FedRAMP for Events');
            adminMail.setSaveAsActivity(false);
            adminMail.setPlainTextBody(eventInsertErrMsg);
            Messaging.sendEmail(new Messaging.Email[] { adminMail });
        }
        
        //get list of new Prod IDs and return
        List<Id> fedEventIDs = new List<Id>();
        for(Event fedEvent : fedEvents){
            if(fedEvent.Id != null){
                fedEventIDs.add(fedEvent.Id);
            }else{
                fedEventIDs.add(null);
            }
        }
        
        return fedEventIDs;
    }
    //CR: 1078 - Changes End
}