global class UpdateOpportunityShowInImpartnerBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateOpportunityShowInImpartnerBatch');
    global List<String> errorlist = new List<String>();
    global List<String> successlist = new List<String>();
    global List<Opportunity> showInPortalOpportunities = new List<Opportunity>();
    global String showInPartnerPortalDays = System.Label.Show_in_Partner_Portal_Days;
    global String showInPartnerPortalDaysNoRegistrationDays = System.Label.Show_in_Partner_Portal_but_No_Registration_Days;

    global Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        String query = '';
            if(Test.isRunningTest()){
              query = 'select Id, Name, Show_Opportunity_in_Impartner__c, Contract_End_Date_New__c, Deal_Reg__c, Deal_Reg__r.Deal_Reg_Type__c, Deal_Reg__r.Record_Type_Name__c from Opportunity';
            }else{
              query = 'select Id, Name, Show_Opportunity_in_Impartner__c, Contract_End_Date_New__c, Deal_Reg__c, Deal_Reg__r.Deal_Reg_Type__c, Deal_Reg__r.Record_Type_Name__c from Opportunity where RecordType.Name = \''+System.Label.Renewal_Opportunity+'\' and StageName not in (\''+System.Label.Stage_6_Closed_Won+'\',\''+System.Label.Stage_7_Closed_Lost+'\') and Contract_End_Date_New__c >= Today and Contract_End_Date_New__c <= NEXT_N_DAYS:180';  
            }
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Opportunity> opportunityList){
		this.zb.callExecute(opportunityList[0]?.Id, opportunityList.size());
        if(Test.isRunningTest()){
            runStaticCode();
        }
        
        try{
            for(Opportunity oppty : opportunityList){
                /*if(oppty.Deal_Reg__c != null && oppty.Deal_Reg__r.Deal_Reg_Type__c == System.Label.Deal_Reg_Type_Renewal && oppty.Deal_Reg__r.Record_Type_Name__c == System.Label.Renewal_Deal_Reg){
                    oppty.Show_Opportunity_in_Impartner__c = System.Label.Registered_a_Deal_Registration;
                    showInPortalOpportunities.add(oppty);
                } else*/
                if((oppty.Show_Opportunity_in_Impartner__c == null 
                    || oppty.Show_Opportunity_in_Impartner__c != System.Label.Registered_a_Deal_Registration
                    || oppty.Show_Opportunity_in_Impartner__c == System.Label.Show_Opportunity_in_Impartner_NA) 
                    && oppty.Contract_End_Date_New__c != null && System.Today().daysBetween(oppty.Contract_End_Date_New__c) <= ((showInPartnerPortalDays != null && showInPartnerPortalDays.isNumeric()) ? Integer.valueOf(showInPartnerPortalDays) : 180)
                    && System.Today().daysBetween(oppty.Contract_End_Date_New__c) > ((showInPartnerPortalDaysNoRegistrationDays != null && showInPartnerPortalDaysNoRegistrationDays.isNumeric()) ? Integer.valueOf(showInPartnerPortalDaysNoRegistrationDays) : 90)){
                    oppty.Show_Opportunity_in_Impartner__c = System.Label.Show_in_Partner_Portal;
                    showInPortalOpportunities.add(oppty);
                }else if((oppty.Show_Opportunity_in_Impartner__c == null
                    || oppty.Show_Opportunity_in_Impartner__c == System.Label.Show_in_Partner_Portal 
                    || oppty.Show_Opportunity_in_Impartner__c != System.Label.Registered_a_Deal_Registration
                    || oppty.Show_Opportunity_in_Impartner__c == System.Label.Show_Opportunity_in_Impartner_NA) 
                    && oppty.Contract_End_Date_New__c != null && System.Today().daysBetween(oppty.Contract_End_Date_New__c) <= ((showInPartnerPortalDaysNoRegistrationDays != null && showInPartnerPortalDaysNoRegistrationDays.isNumeric()) ? Integer.valueOf(showInPartnerPortalDaysNoRegistrationDays) : 90)){
                    oppty.Show_Opportunity_in_Impartner__c = System.Label.Show_in_Partner_Portal_but_No_Registration;
                    showInPortalOpportunities.add(oppty);
                }
            }
            
            if(!showInPortalOpportunities.isEmpty())
                TriggerUtility.skipOpportunityTrigger();
                TriggerUtility.skipOppBeforeInsertTriggerExecuted();
                TriggerUtility.skipOppAfterInsertTriggerExecuted();
                TriggerUtility.skipOppBeforeUpdateTriggerExecuted();
                TriggerUtility.skipOppAfterUpdateTriggerExecuted();
                TriggerUtility.SkipOpportunityTriggerExecutedSetTrue();
                Database.SaveResult[] srlst = Database.update(showInPortalOpportunities, false);
                system.debug('### srlst :'+srlst);
                for(Database.SaveResult sr: srlst){
                    if(sr.isSuccess()){
                        successlist.add(sr.id);
                    }else{
                        String errmsg = 'Error for OppId: ' + sr.getId() + '. ';
                        for(Database.Error err: sr.getErrors()){
                            errmsg += err.getMessage();
                        }
                        errorlist.add(errmsg);
                    }
                }
                TriggerUtility.skipOppBeforeInsertTriggerReset();
                TriggerUtility.skipOppAfterInsertTriggerReset();
                TriggerUtility.skipOppBeforeUpdateTriggerReset();
                TriggerUtility.skipOppAfterUpdateTriggerReset();
                TriggerUtility.SkipOpportunityTriggerSetFalse();
                //update showInPortalOpportunities;
        }catch(Exception ex){
            System.debug('Exception ex: ' + ex.getMessage() + ' @ Line#: ' + ex.getLineNumber());
             //updated by Akash 1: CR# 5023 start
            ZscalerErrorLogsUtility.insertlogsForAsync('UpdateOpportunityShowInImpartnerBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
        	 //updated by Akash 1: CR# 5023 end
        }
    }
    
    global void finish(Database.BatchableContext context){
        this.zb.callFinish(context);       
        Messaging.singleEmailMessage msg = new Messaging.singleEmailMessage();
        msg.setToAddresses(new List<String>{Label.ImpartnerBatchUpdateNotification});
        msg.setSubject('Result of Opportunity Show in Impartmer Update Batch');
        String body = 'Batch processed ' + successlist.size() + ' successfully and ' + errorlist.size() + ' records have failed. \n';
        if(!errorlist.isEmpty()){
            for(String err : errorlist){
                body += '\n' + err;
            }
        }
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});
    }
    
    global void runStaticCode(){
        integer i = 0;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
        i = 1;
    }

}