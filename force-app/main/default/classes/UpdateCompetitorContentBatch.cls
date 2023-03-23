global class UpdateCompetitorContentBatch implements Database.Batchable<sObject>, Database.stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateCompetitorContentBatch');
	global Integer RecordsProcessed = 0;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
       	return Database.getQueryLocator('SELECT Id,Competitor__c,Competitor_Content_Technical__c FROM Opportunity WHERE StageName != \'6 - Closed Won\' AND StageName != \'7 - Closed Lost\' AND  Competitor__c != NULL AND Competitor_Content_Technical__c = NULL');  	
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        this.zb.callExecute(oppList[0]?.Id, oppList.size());
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        System.debug(oppList.size());
		For(Opportunity objOpp : oppList) {
            Set<String> selections = new Set<String>(objOpp.Competitor__c.split(';')) ;
            objOpp.Competitor_Content_Technical__c = '';
            if(selections.contains('Netskope')){
                    objOpp.Competitor_Content_Technical__c = objOpp.Competitor_Content_Technical__c + ' Netskope ';
                    selections.remove('Netskope');
            }
            if(selections.contains('Palo Alto Networks')){
                    objOpp.Competitor_Content_Technical__c = objOpp.Competitor_Content_Technical__c + ' PaloAltoNetworks ';
                    selections.remove('Palo Alto Networks');
            }
            if(selections.size()>0){
                    objOpp.Competitor_Content_Technical__c = objOpp.Competitor_Content_Technical__c + ' Others ';
            }
            oppToUpdate.add(objOpp);
            RecordsProcessed = RecordsProcessed +1; 
        }
                
        try {
            system.debug('total records:'+oppToUpdate.size());
            system.debug(Limits.getCpuTime());
            system.debug(Limits.getLimitCpuTime());
            TriggerUtility.SkipOpportunityTriggerExecutedSetTrue();
            update oppToUpdate;
            
        } catch (Exception e){
            Zscaler_Error_Logs__c errorLog  = new Zscaler_Error_Logs__c(Class_Name__c = 'Trigger_Opportunity_Helper',Exception_info__c = e.getMessage(),Method_Name__c = 'setCompetitorContext',Operation__c = 'Creates Surveys for New Customers');
            insert errorLog;    
        }
        
    }
    global void finish(Database.BatchableContext BC){
        this.zb.callFinish(BC);
        system.debug('Records Processed:'+RecordsProcessed); 
        List<String> lstSendToEmails = new List<String>();
        lstSendToEmails.add(UserInfo.getUserId());
        Messaging.SingleEmailMessage Emailmessage = new Messaging.SingleEmailMessage();
        Emailmessage.toaddresses = lstSendToEmails;
        Emailmessage.subject='Processed Records';
        String Message = 'Hi, <br/>';
        Message += 'Number of Processed Records for CreateSurveyForNewCustomerBatch are: ';   
        Message += RecordsProcessed;
        Message += '<br/>Thank you';
        Emailmessage.setHtmlBody(Message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {Emailmessage});
    }
}