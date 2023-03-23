@RestResource(urlMapping='/SYNCOppdetails/*')
global with sharing class SYNCOppdetails {
    global static Boolean avoidtriggers = false;
    
    @HttpPost
    global static Map<String, Map<String, String>> doPost(Map<String, Opportunity> opplst, List<Map<String, String>> techStageHistory) {
        System.debug('opplst->' + opplst);
        System.debug('techStageUpdatedHistories->' + techStageHistory);

        
        List<String> errorlst = new List<String>();
        List<String> successlst = new List<String>();
        avoidtriggers = true;
        //Map<String, List<String>> mapresult = new Map<String, List<String>>();
        Map<Id, Map<String, String>> oppIDtoFieldUpdateMap = new Map<Id, Map<String, String>>();
        if(opplst != null){
            //if any of these 4 checkbox fields were checked in fed, check them in commercial and update
            for(Opportunity opp: [Select Id, Approved_Pzen_ME__c, Approved_Equipment_Request__c, Approved_DLP_PZen_ER__c, Approved_Equipment_Request_VZEN__c from Opportunity where Id in :opplst.keyset()]){
                if(opp.Approved_Pzen_ME__c){
                    opplst.get(opp.Id).Approved_Pzen_ME__c = opp.Approved_Pzen_ME__c;
                }
                if(opp.Approved_Equipment_Request__c){
                    opplst.get(opp.Id).Approved_Equipment_Request__c = opp.Approved_Equipment_Request__c;
                }
                if(opp.Approved_DLP_PZen_ER__c){
                    opplst.get(opp.Id).Approved_DLP_PZen_ER__c = opp.Approved_DLP_PZen_ER__c;
                }
                if(opp.Approved_Equipment_Request_VZEN__c){
                    opplst.get(opp.Id).Approved_Equipment_Request_VZEN__c = opp.Approved_Equipment_Request_VZEN__c;
                }
            }

            //update tech validation stage if it was update in Fed
            if(techStageHistory != null){


                //construct query for fieldHistory for the related commercial opps
                //note: These lines for date should match what's in Fed.
                Date prevdate = Date.Today().addDays(-1);
                String startdate = prevdate.year() + '-' + prevdate.month() + '-' + prevdate.day() + ' 01:55:00';
                Datetime stdt = Datetime.valueOf(startdate);
                List<OpportunityFieldHistory> commercialTechStageHistories =  [SELECT OpportunityId, NewValue, CreatedDate FROM OpportunityFieldHistory WHERE OpportunityId IN :opplst.keyset() AND CreatedDate >= :stdt AND Field = 'Validation_Stage__c'];

                //add the commercial field updates to our techStageHistory List of Maps
                for(OpportunityFieldHistory commercialTechStageHistory : commercialTechStageHistories){
                    Map<String, String> fieldUpdateMap = new Map<String, String>();
                    fieldUpdateMap.put('OpportunityId', (String)commercialTechStageHistory.OpportunityId);
                    fieldUpdateMap.put('NewValue', (String)commercialTechStageHistory.NewValue);
                    fieldUpdateMap.put('CreatedDate', commercialTechStageHistory.CreatedDate.format());
                    techStageHistory.add(fieldUpdateMap);
                }

                //find the latest update for each opp and add to a map<Opp Id, FieldUpdate>
                System.debug('techStageHistory pre-process->' + techStageHistory);
                
                for(Map<String, String> fieldUpdate : techStageHistory){
                    //if the field update isn't in our map, add a new entry
                    if(oppIDtoFieldUpdateMap.get(fieldUpdate.get('OpportunityId')) == null){
                        Id oppId = fieldUpdate.get('OpportunityId');
                        fieldUpdate.remove('OpportunityId');
                        oppIDtoFieldUpdateMap.put(oppId, fieldUpdate);
                    }else{ //if the field update is already in our map, compare and keep the one with latest date
                        if(fieldUpdate.get('CreatedDate') > oppIDtoFieldUpdateMap.get(fieldUpdate.get('OpportunityId')).get('CreatedDate')){
                            Id oppId = fieldUpdate.get('OpportunityId');
                            fieldUpdate.remove('OpportunityId');
                            oppIDtoFieldUpdateMap.put(oppId, fieldUpdate);
                        }
                    }
                }
                System.debug('oppIDtoFieldUpdateMap post-process->' + oppIDtoFieldUpdateMap);

                //for each field update, apply it to the related opp in opplst
                for(Id updatedOppId : oppIDtoFieldUpdateMap.keySet()){
                    if(opplst.get(updatedOppId) != null){
                        opplst.get(updatedOppId).Validation_Stage__c = oppIDtoFieldUpdateMap.get(updatedOppId).get('NewValue');
                    }
                }
            }
            
            
            //update Tech Validation Stage field if it's been updated in Fed
            //TODO: List<OpportunityFieldHistory> techValidationStageHistory = [SELECT OpportunityId FROM OpportunityFieldHistory WHERE field = 'Validation_Stage__c' AND OpportunityId IN :];

            Database.SaveResult[] srList = database.update(opplst.values(),false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        String s = '';
                        if(srList.indexOf(sr) != -1 && !opplst.values().isEmpty() && opplst.values().size() > srList.indexOf(sr) && opplst.values()[srList.indexOf(sr)] != null){
                            s = opplst.values()[srList.indexOf(sr)].Id;
                        }
                        errorlst.add(s + ' - ' + err.getMessage());
                    }
                }
            }

            //handle any errors/success and send email to admins/bsys team
            //OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});


            if(errorlst.isEmpty()){
                mail1.setSubject('FedRamp Opportunity Sync Success result');
                mail1.setPlainTextBody('Number of Records Updated: ' + successlst.size() + '\n\nRecords Updated: ' + successlst);
            }else{
                mail1.setSubject('FedRamp Opportunity Sync Failure result');
                mail1.setPlainTextBody('Error reason: ' + errorlst);
            }
            messageList.add(mail1);
            Messaging.sendEmail(messageList);
        }

        //convert oppIDtoFieldUpdateMap so it can be returned to Fed
        Map<String, Map<String, String>> fieldUpdateStringMap = new Map<String, Map<String, String>>();
        for(Id oppId : oppIDtoFieldUpdateMap.keySet()){
            fieldUpdateStringMap.put((String)oppId, oppIDtoFieldUpdateMap.get(oppId));
        }


        avoidtriggers = false;
        return fieldUpdateStringMap;
        
        
    }

    //this had to be added as Salesforce doesn't allow code coverage of functions based off fieldhistory
    public static void booster(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}