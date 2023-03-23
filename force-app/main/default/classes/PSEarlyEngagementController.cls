//Test class - Equipment_RequestTriggerhandlerTest
public class PSEarlyEngagementController {
    
    public void sendSingleEmailMessage(List<PSEarlyEngagementController.SendSingleEmailMessageWrapper> sendSingleEmailMessageWrapperList){
        
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
        List<String> emailTemplateDeveloperNameList = new List<String>();
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        Map<String,EmailTemplate> developerNameEmailTemplateMap = new Map<String,EmailTemplate>();        
        
        for(PSEarlyEngagementController.SendSingleEmailMessageWrapper sendSingleEmailMessageWrapperRecord : sendSingleEmailMessageWrapperList){
            System.debug('sendSingleEmailMessageWrapperRecord : - ' + sendSingleEmailMessageWrapperRecord);
            emailTemplateDeveloperNameList.add(sendSingleEmailMessageWrapperRecord.emailTemplateDevloperName);
        }
        
        if(!emailTemplateDeveloperNameList.isEmpty()){
            emailTemplateList = [SELECT Id, Subject, Body, HtmlValue, DeveloperName  
                                 FROM EmailTemplate 
                                 WHERE DeveloperName IN :emailTemplateDeveloperNameList];
        }       
        
        for(EmailTemplate emailTemplateRecord : emailTemplateList){
            developerNameEmailTemplateMap.put(emailTemplateRecord.DeveloperName,emailTemplateRecord);
        }
        
        for(PSEarlyEngagementController.SendSingleEmailMessageWrapper sendSingleEmailMessageWrapperRecord : sendSingleEmailMessageWrapperList){
            
            EmailTemplate emailTemplateRecord = developerNameEmailTemplateMap.get(sendSingleEmailMessageWrapperRecord.emailTemplateDevloperName);
            
            String emailBody = String.isBlank(emailTemplateRecord.Body) ? '' : emailTemplateRecord.Body;
            
            string url = System.URL.getSalesforceBaseURL().toExternalForm();
            url  += '/' + sendSingleEmailMessageWrapperRecord.targetObjectRecord.Id;
            emailBody = emailBody.replace('{!name}', sendSingleEmailMessageWrapperRecord.targetObjectRecord.Id).replace('{!link}', url);
            
            List<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
            
            Messaging.SingleEmailMessage emailMessageObj = new Messaging.SingleEmailMessage();
            emailMessageObj.setTargetObjectId(contactId);
            emailMessageObj.setWhatId(sendSingleEmailMessageWrapperRecord.targetObjectRecord.Id);
            emailMessageObj.setTemplateId(emailTemplateRecord.Id);
            emailMessageObj.setHtmlBody(emailTemplateRecord.HtmlValue);
            emailMessageObj.setSubject(String.isBlank(emailTemplateRecord.Subject) ? '' : emailTemplateRecord.Subject);
            emailMessageObj.setToAddresses(sendSingleEmailMessageWrapperRecord.toAddresses);
            emailMessageObj.setCcAddresses(sendSingleEmailMessageWrapperRecord.ccAddresses);
            emailMessageObj.setTreatBodiesAsTemplate(TRUE);
            //CR# 4693 - Added by Arsh
            emailMessageObj.setTreatTargetObjectAsRecipient(FALSE);

            System.debug('emailMessageObj : - ' + emailMessageObj);
            emailMessageList.add(emailMessageObj);
        }
        
        try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessageList);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }catch(Exception e){
            
        }        
    }
    
    public class SendSingleEmailMessageWrapper{
        public List<String> toAddresses;
        public List<String> ccAddresses;
        public String emailTemplateDevloperName;
        public Equipment_Request__c targetObjectRecord;
    }
}