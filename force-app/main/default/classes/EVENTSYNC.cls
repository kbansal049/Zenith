@RestResource(urlMapping='/EVENTSYNC/*')
global class EVENTSYNC{
    global static Boolean avoidtriggers = false;
    @HttpPost
    global static String doPost(List<Event> fedEvents , String internalParticipants ){
        
        System.debug('fedEvents->' + fedEvents);
        Map<Id,Event> mapEvent = new Map<Id,Event>();
        mapEvent.putall(fedEvents);
        System.debug('internalParticipants->' + internalParticipants);
        fedEvents[0].peopleai__Participants__c = internalParticipants;
        System.debug('fedEvents[0].peopleai__Participants__c->' + fedEvents[0].peopleai__Participants__c);

        // This block will delete AccountTeamMember to sync the AccountTeamMember which were changed in Fed
        List<String> teamdelerrorlst = new List<String>();
        List<String> teamdelsuccesslst = new List<String>(); 
       
        /// Updated to exclude all comm team roles account team members deletion what are not coming from Fed //
         
        // This block create lists to store DML success/failures
        //update accounts with patch/territory data
        List<String> accerrorlst = new List<String>();
        List<String> accsuccesslst = new List<String>();
        List<Event> listfedAccounts = new List<Event>();
        try{            
            if (mapEvent!=null){
                listfedAccounts = mapEvent.values(); 
                System.debug('listfedAccounts->' + listfedAccounts);

                Database.SaveResult[] acctSRList = database.update(fedEvents,false);               
                for (Database.SaveResult accountSaveResult : acctSRList) {
                    if (accountSaveResult.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        accsuccesslst.add(accountSaveResult.getId());
                    }                    
                    else {
                        for(Database.Error err : accountSaveResult.getErrors()){
                            String s = '';
                            if(acctSRList.indexOf(accountSaveResult) != -1 && !fedEvents.isEmpty() && fedEvents.size() > acctSRList.indexOf(accountSaveResult) && fedEvents[acctSRList.indexOf(accountSaveResult)] != null){
                                s = listfedAccounts[acctSRList.indexOf(accountSaveResult)].Id;
                            }
                            accerrorlst.add(s + ' - ' + err.getMessage());
                        }
                    }                    
                }
            }
            System.debug('accsuccesslst->' + accsuccesslst);
            System.debug('accerrorlst->' + accerrorlst);            
        }
        catch(Exception e){
            System.debug('in catch fedAccounts:='+ e.getMessage()+ e.getStackTraceString());
        }       
        
          String jsonstr = '{"accsuccesslst": ' + JSON.serialize(accsuccesslst) ;
        
        // When no unexpected exception thrown then return Pass. If null is passed check debug at Fed side that data did not even pushed from there or at comm some unexpected exception thrown 
        // make sure when search for  'catch' in debug logs to verify that all data dml opearation was successful and errorlst is null as well
        return  jsonstr ;       
    }  
}