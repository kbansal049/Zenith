/*****************************************************************************************
Name: QuipPSOnboardingDocumentEmailhelper
Copyright © Zscaler
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
Purpose:
--------
1. Apex Controller for Sending Quip Document Created Email.
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       16/09/2022      IBA-2128 - Email notification when Quip PS Onboarding Doc is generated.
******************************************************************************************/ 

public class QuipPSOnboardingDocumentEmailhelper {
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-2128 : To Send Emails with Quip Document Link once the Quip Documents are generated.
This Method will be invoked from the Flow creating the quip Document.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : sendQuipOnboardingDocEmail .
* @param    NAME : List<Opportunity> opportunityList .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    
    @InvocableMethod(label='Send PS Onboarding Document Email On Stage Change' description='Send PS Onboarding Document Email On Stage Change')
    public static void sendQuipOnboardingDocEmail(List<Opportunity> opportunityList) {
        
        try{
            List<Opportunity> opportunityListToSendEmail = New List<Opportunity>();
            Set<Id> opportunityId = New Set<Id>();
            User seManager = New User();
            
            //Looping trough the opportunity list to get the related fields which are not accesible.
            For(Opportunity oppObj : opportunityList){
                opportunityId.add(oppObj.Id);
            }
            //Added by Ayush Kangar as part of IBA-4569- Start
            Id psOnboardingRecordTypeId = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(Label.PS_Onboarding).getRecordTypeId();
            Map<Id,Id> oppIdPsqIdMap = new Map<Id,Id>();
            List<PS_Questionnaire__c> psqList = [select Id,opportunity__c FROM PS_Questionnaire__c
                                                 WHERE opportunity__c in:opportunityId
                                                 AND RecordTypeId =: psOnboardingRecordTypeId ];
            for(PS_Questionnaire__c psq: psqList){
                oppIdPsqIdMap.put(psq.opportunity__c,psq.Id);
            }   
            //Added by Ayush Kangar as part of IBA-4569- End
            opportunityListToSendEmail = [SELECT Id, Name, StageName, SE_Name__c, 
                                          OwnerId, Account.CSM_Name_New__c, Account.Solution_Architect__c,
                                          Account.CSM_Name_New__r.Name, Account.Solution_Architect__r.Name,
                                          SE_Name__r.Manager2__c, Owner.Name, SE_Name__r.Name
                                          FROM Opportunity
                                          WHERE Id IN: opportunityId];
            
            Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;// To set the setTargetObjectId
            
            EmailTemplate emailTemplateForOpportunityStageOtherThan5 = [SELECT Id, Subject, Body, HtmlValue, DeveloperName  
                                                                        FROM EmailTemplate 
                                                                        WHERE DeveloperName =: ZScalarConstants.QUIP_DOCUMENT_EMAIL_TEMPLATE];
            
            EmailTemplate emailTemplateForOpportunityStage5 = [SELECT Id, Subject, Body, HtmlValue, DeveloperName  
                                                               FROM EmailTemplate 
                                                               WHERE DeveloperName =: ZScalarConstants.QUIP_DOCUMENT_EMAIL_TEMPLATE_STAGE5];
            
            OrgWideEmailAddress[] fromAddress = [SELECT Id 
                                                 FROM OrgWideEmailAddress 
                                                 WHERE Address =: ZScalarConstants.SUPPORT_NO_REPLY_EMAIL_ADDRESS];
            
            List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
            
            for(Opportunity opportunityRecordToSendEmail : opportunityListToSendEmail){
                String htmlBody = '';
                String plainTextBody = '';
                Messaging.SingleEmailMessage emailMessageObj = new Messaging.SingleEmailMessage();
                Set<String> toAddressesSet = new Set<String>();
                
                if (opportunityRecordToSendEmail.SE_Name__c != null) {
                    toAddressesSet.add(opportunityRecordToSendEmail.SE_Name__c);
                }
                if (opportunityRecordToSendEmail.OwnerId != null) {
                    toAddressesSet.add(opportunityRecordToSendEmail.OwnerId);
                }
                if (opportunityRecordToSendEmail.Account.CSM_Name_New__c != null) {
                    toAddressesSet.add(opportunityRecordToSendEmail.Account.CSM_Name_New__c);
                }
                if (opportunityRecordToSendEmail.Account.Solution_Architect__c != null) {
                    toAddressesSet.add(opportunityRecordToSendEmail.Account.Solution_Architect__c);
                }
                //Added by Ayush Kangar as part of IBA-4569- Start
                String fullRecordURL = '';
                if(oppIdPsqIdMap.containsKey(opportunityRecordToSendEmail.Id)){
                    fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + oppIdPsqIdMap.get(opportunityRecordToSendEmail.Id);
                }
                //Added by Ayush Kangar as part of IBA-4569- End
                if(opportunityRecordToSendEmail.StageName == ZScalarConstants.Opp_STAGE_4){
                    htmlBody = emailTemplateForOpportunityStageOtherThan5.HtmlValue;
                    plainTextBody = emailTemplateForOpportunityStageOtherThan5.Body;
                    emailMessageObj.setTemplateId(emailTemplateForOpportunityStageOtherThan5.Id);
                    emailMessageObj.setSubject('Action Required: Stage 4 | Complete PS Onboarding Doc for '+opportunityRecordToSendEmail.Name);  
                    //Added by Ayush Kangar as part of IBA-4569- Start
                    htmlBody = htmlBody.replace('PSQuestionnaireLink',fullRecordURL);
                    plainTextBody = plainTextBody.replace('PSQuestionnaireLink',fullRecordURL);
                    //Added by Ayush Kangar as part of IBA-4569- End
                    
                }
                else if(opportunityRecordToSendEmail.StageName == ZScalarConstants.Opp_STAGE_5 ||
                        opportunityRecordToSendEmail.StageName == ZScalarConstants.Opp_STAGE_5A ||
                        opportunityRecordToSendEmail.StageName == ZScalarConstants.Opp_STAGE_5B ||
                        opportunityRecordToSendEmail.StageName == ZScalarConstants.Opp_STAGE_5C ||
                        opportunityRecordToSendEmail.StageName == ZScalarConstants.Opp_STAGE_5D){   
                            htmlBody = emailTemplateForOpportunityStage5.HtmlValue;
                            plainTextBody = emailTemplateForOpportunityStage5.Body;
                            emailMessageObj.setTemplateId(emailTemplateForOpportunityStage5.Id);
                            emailMessageObj.setSubject('Action Required: Stage 5 | Complete PS Onboarding Doc for '+opportunityRecordToSendEmail.Name);
                            //Added by Ayush Kangar as part of IBA-4569- Start
                            htmlBody = htmlBody.replace('PSQuestionnaireLink',fullRecordURL);
                            plainTextBody = plainTextBody.replace('PSQuestionnaireLink',fullRecordURL);
                            //Added by Ayush Kangar as part of IBA-4569- End
                            if (opportunityRecordToSendEmail.SE_Name__r.Manager2__c != null) {
                                seManager = [select Id, Name, Email from user where name =: opportunityRecordToSendEmail.SE_Name__r.Manager2__c LIMIT 1];
                                toAddressesSet.add(seManager.Id);
                            }
                        }
                
                if(opportunityRecordToSendEmail.OwnerId != null){
                    htmlBody = htmlBody.replace('Owner Name', opportunityRecordToSendEmail.Owner.Name);
                    plainTextBody = plainTextBody.replace('Owner Name', opportunityRecordToSendEmail.Owner.Name);
                }
                else{
                    htmlBody = htmlBody.remove('Owner Name,');
                    plainTextBody = plainTextBody.remove('Owner Name,'); 
                }
                
                if(opportunityRecordToSendEmail.Account.CSM_Name_New__r.Name != null){
                    htmlBody = htmlBody.replace('Account CSM Name', opportunityRecordToSendEmail.Account.CSM_Name_New__r.Name);
                    plainTextBody = plainTextBody.replace('Account CSM Name', opportunityRecordToSendEmail.Account.CSM_Name_New__r.Name);
                }
                else{
                    htmlBody = htmlBody.remove('Account CSM Name, ');
                    plainTextBody = plainTextBody.remove('Account CSM Name, '); 
                }
                
                if(opportunityRecordToSendEmail.Account.Solution_Architect__r.Name != null){
                    htmlBody = htmlBody.replace('Solution Architect Name', opportunityRecordToSendEmail.Account.Solution_Architect__r.Name);
                    plainTextBody = plainTextBody.replace('Solution Architect Name', opportunityRecordToSendEmail.Account.Solution_Architect__r.Name);
                }
                else{
                    htmlBody = htmlBody.remove('Solution Architect Name, ');
                    plainTextBody = plainTextBody.remove('Solution Architect Name, ');
                }
                
                if(opportunityRecordToSendEmail.SE_Name__c != null){
                    htmlBody = htmlBody.replace('SE Name', opportunityRecordToSendEmail.SE_Name__r.Name);
                    plainTextBody = plainTextBody.replace('SE Name', opportunityRecordToSendEmail.SE_Name__r.Name);
                }
                else{
                    htmlBody = htmlBody.remove('SE Name, ');
                    plainTextBody = plainTextBody.remove('SE Name, ');
                }
                
                if(opportunityRecordToSendEmail.SE_Name__r.Manager2__c != null){
                    htmlBody = htmlBody.replace('SE Manager Name', opportunityRecordToSendEmail.SE_Name__r.Manager2__c);
                    plainTextBody = plainTextBody.replace('SE Manager Name', opportunityRecordToSendEmail.SE_Name__r.Manager2__c);
                }
                else{
                    htmlBody = htmlBody.remove('SE Manager Name, ');
                    plainTextBody = plainTextBody.remove('SE Manager Name, ');
                }
                
                emailMessageObj.setTargetObjectId(contactId);
                emailMessageObj.setWhatId(opportunityRecordToSendEmail.Id);
                emailMessageObj.setOrgWideEmailAddressId(fromAddress.get(0).Id);
                emailMessageObj.setHtmlBody(htmlBody);
                emailMessageObj.setPlainTextBody(plainTextBody);
                emailMessageObj.setToAddresses(new List<String> (toAddressesSet));
                emailMessageObj.setTreatBodiesAsTemplate(TRUE);
                emailMessageObj.setTreatTargetObjectAsRecipient(FALSE);
                emailMessageList.add(emailMessageObj);
            }
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessageList);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
                ZscalerErrorLogsUtility.insertlogs('QuipPSOnboardingDocumentEmailhelper', 
                                                   'sendQuipOnboardingDocEmail', 
                                                   'Apex', 
                                                   UserInfo.getUserId(),
                                                   'Sales cloud', 
                                                   results[0].errors[0].message, 
                                                   results[0].errors[0].message, 
                                                   'Email Send Failed');
            }
        }catch(Exception e){
            System.debug('The email failed to send: Exception Cause - ' + 
                         e.getCause() + ', Message - ' + 
                         e.getMessage() + ', StackTrace - ' +
                         e.getStackTraceString());
            ZscalerErrorLogsUtility.insertlogs('QuipPSOnboardingDocumentEmailhelper', 
                                               'sendQuipOnboardingDocEmail', 
                                               'Apex', 
                                               UserInfo.getUserId(),
                                               'Sales cloud', 
                                               e.getStackTraceString(), 
                                               e.getMessage(), 
                                               e.getTypeName());
        }
        
    }
    
}