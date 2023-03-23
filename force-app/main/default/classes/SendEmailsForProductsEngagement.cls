global without sharing class SendEmailsForProductsEngagement {
    // Start - IBA-6552
    @InvocableMethod(label='sendEmailsForProductsEngagement')
    global static void sendEmailsToProductTeam(List<Id> recordsList){
        List<String> ccAdressList = new List<String>();
        EmailUtility emailUtility;
        List<Product_Engagement__c> engagementRecordList = [SELECT Id,CreatedBy.Email,Engagement_Type__c,Product__c,opportunity__r.Account.Name,
                                                            opportunity__r.Owner.Name,opportunity__r.Opportunity_Sales_Engineer__r.Name,
                                                            opportunity__r.Geo_Account__c,opportunity__r.Account.Market_Segment__c,opportunity__r.Area__c
                                                            FROM Product_Engagement__c
                                                            WHERE Id in :recordsList];
        List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
        List<Email_Configuration__mdt> emailConfigMdtList = [SELECT DeveloperName,business_process__c FROM Email_Configuration__mdt];
        for(Product_Engagement__c engagementRecord : engagementRecordList){    
            String emailConfigCondition = engagementRecord.Product__c+'-'+engagementRecord.Engagement_Type__c;
            String emailConfig;          
            if(engagementRecord.CreatedBy.Email != null){
                ccAdressList.add(engagementRecord.CreatedBy.Email);
            }
            for(Email_Configuration__mdt emailMdt: emailConfigMdtList){
                if(emailMdt.business_process__c == emailConfigCondition){
                    emailConfig = emailMdt.DeveloperName;
                }
            }
            if(emailConfig!=null){
                emailUtility = new EmailUtility(emailConfig);
                String emailTemplateBody = emailUtility.template.HtmlValue;
                if(engagementRecord.opportunity__r.Account.Name!=null){
                    emailTemplateBody = emailTemplateBody.replace('{!Product_Engagement__c.Opportunity__r.Account.Name}',engagementRecord.opportunity__r.Account.Name);
                }
                if(engagementRecord.opportunity__r.Owner.Name!=null){
                    emailTemplateBody = emailTemplateBody.replace('{!Product_Engagement__c.Opportunity__r.Owner.Name}',engagementRecord.opportunity__r.Owner.Name);
                }
                if(engagementRecord.opportunity__r.Opportunity_Sales_Engineer__r.Name!=null){
                    emailTemplateBody = emailTemplateBody.replace('{!Product_Engagement__c.Opportunity__r.Opportunity_Sales_Engineer__r.Name}',engagementRecord.opportunity__r.Opportunity_Sales_Engineer__r.Name);
                }
                if(engagementRecord.opportunity__r.Geo_Account__c!=null){
                    emailTemplateBody = emailTemplateBody.replace('{!Product_Engagement__c.Opportunity__r.Geo}',engagementRecord.opportunity__r.Geo_Account__c);
                }
                if(engagementRecord.opportunity__r.Account.Market_Segment__c!=null){
                    emailTemplateBody = emailTemplateBody.replace('{!Product_Engagement__c.Opportunity__r.Account.Market_Segment__c}',engagementRecord.opportunity__r.Account.Market_Segment__c);
                }
                if(engagementRecord.opportunity__r.Area__c!=null){
                    emailTemplateBody = emailTemplateBody.replace('{Product_Engagement.Opportunity__r.Region}',engagementRecord.opportunity__r.Area__c);
                }
                emailUtility.htmlBody = emailTemplateBody;
                emailsToBeSent.add(emailUtility.prepareEmail(ccAdressList,engagementRecord.Id));                
            }
        }
        if(!emailsToBeSent.isEmpty()){
            emailUtility.sendEmails(emailsToBeSent);
        }
    }
    // End - IBA-6552
}