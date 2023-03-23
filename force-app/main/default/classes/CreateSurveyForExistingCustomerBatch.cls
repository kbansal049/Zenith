global class CreateSurveyForExistingCustomerBatch implements Database.Batchable<sObject>, Database.stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CreateSurveyForExistingCustomerBatch');
    global Integer RecordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
       	return Database.getQueryLocator('Select Id, Email,AccountId from Contact Where Account.Type =\'Customer\' and email!=null and Id Not in(Select Contact__c from survey__c where RecordType.Name = \'Customer Success\')');
    }
    global void execute(Database.BatchableContext BC, List<Contact> conList){
        this.zb.callExecute(conList[0]?.Id, conList.size());
        Id csmRecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('Customer_Success').getRecordTypeId();
        List<Survey__c> lSurveys = new List<Survey__c>();
        List<String> domainsToExclude = CaseTriggerUtility.fetchDomainsToExclude();
        for(Contact con: conList){  
            
            Survey__c survey = new Survey__c(Account__c = con.AccountId,
                                             Contact__c=con.Id,
                                             RecordTypeId=csmRecordTypeId
                                            ); 
            if(CaseTriggerUtility.checkEmailDomainsExclude(con.Email, domainsToExclude)){
                survey.Contact_Email_Includes_Public_Domain__c = true;
                survey.Survey_Status__c='Survey not Sent due to Public Domain';
            }                                
            lSurveys.add(survey);
            RecordsProcessed = RecordsProcessed +1; 
        }
        try {
            system.debug('total surveys:'+lSurveys.size());
            system.debug(Limits.getCpuTime());
            system.debug(Limits.getLimitCpuTime());
            SurveyTriggerHelper.skipTrigger = TRUE;
            insert lSurveys;
        } catch (Exception e){
            system.debug('Error msg'+e.getmessage());
            Zscaler_Error_Logs__c errorLog  = new Zscaler_Error_Logs__c(class_Name__c = 'AccountAsyncTriggerHelper',Exception_info__c = e.getMessage(),Method_Name__c = 'createSurveys',Operation__c = 'Creates Surveys for New Customers');
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
        Message += 'Number of Processed Records are: ';   
        Message += RecordsProcessed;
        Message += '<br/>Thank you';
        Emailmessage.setHtmlBody(Message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {Emailmessage});
    }
}