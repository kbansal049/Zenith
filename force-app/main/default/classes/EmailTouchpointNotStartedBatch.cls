Global class EmailTouchpointNotStartedBatch Implements Database.batchable<sobject>,  Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('EmailTouchpointNotStartedBatch');
    global final string query;
    global EmailTouchpointNotStartedBatch(String q) {
        query=q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    
    global  void execute(Database.BatchableContext BC,List<inspire1__Project_Tasks__c> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        EmailTemplate template = [select id,HtmlValue,subject from EmailTemplate where DeveloperName = 'Email_for_touchpoint_not_started'];
        OrgWideEmailAddress ow = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where address = 'support-noreply@zscaler.com'];
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        for(inspire1__Project_Tasks__c task:scope){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> recipients = new List<String>();  
            if(task.inspire1__Project__r.inspire1__Account__r.TAM_Name_New__r.Email!=null){
                recipients.add(task.inspire1__Project__r.inspire1__Account__r.TAM_Name_New__r.Email);
            }
            if(task.inspire1__Project__r.inspire1__Account__r.TAM_Name_New__r.Manager.Email!=null){
                recipients.add(task.inspire1__Project__r.inspire1__Account__r.TAM_Name_New__r.Manager.Email);
            }
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('[TASK_NAME]', task.Name);
            htmlBody = htmlBody.replace('[ACCOUNT_NAME]', task.inspire1__Project__r.inspire1__Account__r.Name);
            htmlBody = htmlBody.replace('[PROJECT_NAME]', task.inspire1__Project__r.Name);
            htmlBody = htmlBody.replace('[START_DATE]', string.valueOfGmt(task.inspire1__StartDate__c));
            htmlBody = htmlBody.replace(']]>', '');
            mail.setOrgWideEmailAddressId(ow.id);
            mail.setHtmlBody(htmlBody);
            mail.setSubject(template.subject);
            if(!recipients.isEmpty()){
                mail.setToAddresses(recipients);
            }
            mail.setSaveAsActivity(false);
            if(!recipients.isEmpty()){
                messageList.add(mail);
            }
        }
        if(messageList.size()>0){
            if(!Test.isRunningTest()){
                Messaging.sendEmail(messageList); 
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
       this.zb.callFinish(BC); 
    }
}