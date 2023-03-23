/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* IBA-2737 : EmailUtility
* @description    This class is used as Email Utility to send emails.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sachin Tandon
* @modifiedBy     Sachin Tandon
* @maintainedBy   Sachin Tandon
* @version        1.0
* @created        2022-09-27
**/
public class EmailUtility{

    public String emailConfigurationName;
    public EmailTemplate template;    
    public Id templateId;
    public String defaultOWDSenderId;
    public List<String> recipientEmailAddresses;
    public String htmlBody;
    
    public EmailUtility(String emailConfig) {
        this.emailConfigurationName = emailConfig;
        this.initializeEmailConfiguration();
    }
    
    /* 
    * TODO : Add ccAddressRecipients Logic
	*/
    private void initializeEmailConfiguration() {
        
        if(String.isBlank(this.emailConfigurationName)){
            return;
        }
        
        Email_Configuration__mdt emailConfiguration = Email_Configuration__mdt.getInstance(this.emailConfigurationName);
        
        if(emailConfiguration == null) { return; }    		
        List<String> recipientsName = getListOfString((String) emailConfiguration.get('Recipient_Names__c'));
        //Added by Ayush as part of IBA-6552 -Start
        List<String> recipientsListWithName = new List<String>();
        List<String> recipientsListWithEmail = new List<String>();
        for(String name: recipientsName){
            if(name.contains('@')){
                recipientsListWithEmail.add(name);
            }else{
                recipientsListWithName.add(name);
            }
        }
        if(!recipientsName.isEmpty()){
            this.recipientEmailAddresses = getRecipientsEmailAddresses(recipientsListWithName);
        }
        if(!recipientsListWithEmail.isEmpty()){
            this.recipientEmailAddresses.addall(recipientsListWithEmail);
        }
        //Added by Ayush as part of IBA-6552 -End
            
            String sendersEmail = (String) emailConfiguration.get('Senders_Email_Address__c');
            this.defaultOWDSenderId = getSendersEmailId(sendersEmail);   

            String projectTemplate = (String) emailConfiguration.get('Email_Template_Name__c');
            this.template = this.getEmailTemplate(projectTemplate);
            if(this.template != null) {
                this.templateId = this.template.Id;
            }
    }
    
    public Messaging.SingleEmailMessage prepareEmail(Id sObjectId) {
        
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(this.templateId), Null, String.valueOf(sObjectId));
       	mail.setToAddresses(this.recipientEmailAddresses);   
        mail.setOrgWideEmailAddressId(this.defaultOWDSenderId);
        mail.setTreatBodiesAsTemplate(True);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setsaveAsActivity(false);
        
        return mail;
    }

    /**
     * Use this method if we have to add custom users Email addresses. 
     * Not present in Custom Metadata
     */
    
    public Messaging.SingleEmailMessage prepareEmail(List<String> toEmailAddresses ,List<String> ccAddresses, Id sObjectId) {
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(this.templateId), Null, String.valueOf(sObjectId));
        mail.setToAddresses(toEmailAddresses); 
        if(!ccAddresses.isEmpty()) {
         	mail.setCcAddresses(ccAddresses);   
        }
        mail.setOrgWideEmailAddressId(this.defaultOWDSenderId);
        mail.setTreatBodiesAsTemplate(True);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setsaveAsActivity(false);
        return mail;
    }
    
    /**
     * Use this method if we have to add custom users Email addresses. 
     * Not present in Custom Metadata
     */
    
    public Messaging.SingleEmailMessage prepareEmailWithCustomSubject(List<String> toEmailAddresses ,List<String> ccAddresses, Id sObjectId, String subject) {
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(this.templateId), Null, String.valueOf(sObjectId));
        mail.setToAddresses(toEmailAddresses); 
        if(!ccAddresses.isEmpty()) {
         	mail.setCcAddresses(ccAddresses);   
        }
        //Using this line to set the custom subject line sent.
        if(String.isNotBlank(subject)) {
         	mail.setSubject(subject);   
        }
        if(String.isNotBlank(this.htmlBody)) {
            mail.setHtmlBody(this.htmlBody);
        }
        mail.setOrgWideEmailAddressId(this.defaultOWDSenderId);
        mail.setTreatBodiesAsTemplate(True);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setsaveAsActivity(false);
        return mail;
    }

    public Messaging.SingleEmailMessage prepareEmail(Id sObjectId,String htmlBodyText) {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(String.isNotBlank(this.htmlBody)) {
            mail.setHtmlBody(this.htmlBody);
        }
        mail.setToAddresses(this.recipientEmailAddresses);
        mail.setOrgWideEmailAddressId(this.defaultOWDSenderId);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setTreatBodiesAsTemplate(true);
        mail.setWhatId(sObjectId);
        return mail;
    }

    private EmailTemplate getEmailTemplate(String projectTemplate) {
        List<EmailTemplate> templates = [SELECT Id,Subject,HtmlValue FROM EmailTemplate where DeveloperName =: projectTemplate];
        return templates.get(0);
    }

    
    public void sendEmails(List<Messaging.SingleEmailMessage> emailsToBeSend) {
        if(!emailsToBeSend.isEmpty()) {
            Messaging.sendEmail(emailsToBeSend);
        }
    }
    
    private Id getEmailTemplateId(String templateName) {
        return [SELECT Id,Subject,HtmlVAlue FROM EmailTemplate WHERE DeveloperName =: templateName].Id;
    }
    
    private Id getSendersEmailId(String addressId) {
        return  [SELECT id, Address,IsAllowAllProfiles FROM OrgWideEmailAddress WHERE Address =: addressId].Id;
    }
    
    private List<String> getRecipientsEmailAddresses(List<String> usernames) {
        
        List<String> emailAddresses = new List<String>();
        for(User user : [SELECT id,Email FROM User WHERE Name = :usernames]) {
            emailAddresses.add(user.Email);
        }
        return emailAddresses;
    }
    
    private String getFirstElementOfList(List<String> elements) {
        if(elements.isEmpty()) {return '';}
        return elements.get(0); 
    }
    
    private List<String> getListOfString(String str) {
        if(String.isBlank(str)) {return new List<String>(); } 
        return str.split(';');
    }
    
    //Added by Ayush as part of IBA-6552 -Start    
    public Messaging.SingleEmailMessage prepareEmail(List<String> ccAddresses, Id sObjectId){
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(this.templateId), Null, String.valueOf(sObjectId));
        mail.setToAddresses(this.recipientEmailAddresses);   
        if(!ccAddresses.isEmpty()){
            mail.setCcAddresses(ccAddresses);   
        }
        if(String.isNotBlank(this.htmlBody)){
            mail.setHtmlBody(this.htmlBody);
        }
        mail.setOrgWideEmailAddressId(this.defaultOWDSenderId);
        mail.setTreatBodiesAsTemplate(True);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setsaveAsActivity(false);     
        return mail;
    }
    //Added by Ayush as part of IBA-6552 -End  
}