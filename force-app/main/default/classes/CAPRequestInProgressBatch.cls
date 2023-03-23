/**
 * Class : CAPRequestInProgressBatch
 * Added by : Ankit Bhatnagar
 * Description :  Batch that updates In progress violation flag and sends email
 */
public with sharing class CAPRequestInProgressBatch implements Database.Batchable<sObject>, Database.Stateful{
    static final String APEX_CLASS_NAME = 'CAPRequestInProgressBatch';
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CAPRequestInProgressBatch');

    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        String query = 'SELECT Id, Customer_Main_POC_for_Communication__c, Status__c,CAP_Manager__c,' 
                        + ' Last_Email_Sent_In_Progress_Internal__c, In_Progress_Updates_Missed__c, Next_In_Progress_Update__c,' 
                        + ' CAP_In_Progress_Timestamp__c, Progress_update_frequency__c, Notification_day__c,CreatedById' 
                        + ' FROM CAP_Request__c' 
                        + ' WHERE Status__c = \'In Progress\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<CAP_Request__c> scope){
        final String METHOD_NAME = 'execute';
        this.zb.callExecute(scope[0]?.Id, scope.size());
        try {
            Map<Id, CAP_Request__c> capMap = new Map<Id, CAP_Request__c>();
            Set<Id> capNonViolatedMap = new Set<Id>();
            String formattedTime = System.now().format(GCSCommonConstants.TAC_TIME_FORMAT, GCSCommonConstants.AMERICA_LA_TIME_ZONE);
            String dayOfWeek = formattedTime.split(',').get(0);
            Map<String,String> daysOfWeek = new Map<String,String>{
                'Monday' => 'Mon',
                'Tuesday' => 'Tue',
                'Wednesday' => 'Wed',
                'Thursday' => 'Thu',
                'Friday' => 'Fri'
            };
            String dailyTemplateId = GCSCommonConstants.EMPTY_STRING;
            String weeklyTemplateId = GCSCommonConstants.EMPTY_STRING;
            String orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :GCSCommonConstants.ZS_SALESFORCE_EMAIL_ID LIMIT 1].id;
            for(EmailTemplate et : [SELECT Id, Name, DeveloperName, IsActive, HtmlValue, Body, Subject 
                                        FROM EmailTemplate 
                                        WHERE (DeveloperName = 'Milestone_CAP_In_Progress_milestone_Daily_Reminder' 
                                            OR DeveloperName = 'Milestone_CAP_In_Progress_milestone_Weekly_Reminder') 
                                        AND isActive = true]) {
                if(et.DeveloperName == 'Milestone_CAP_In_Progress_milestone_Daily_Reminder') { 
                    dailyTemplateId = et.id;
                }
                else if(et.DeveloperName == 'Milestone_CAP_In_Progress_milestone_Weekly_Reminder') { 
                    weeklyTemplateId = et.id;
                }
            }
            List< Messaging.SingleEmailMessage> emails = new List< Messaging.SingleEmailMessage>();
            List<String> requestIds = new List<String>();
            Set<String> capsToBeUpdated = new Set<String>();

            for(CAP_Request_interaction__c capInt : [SELECT Id, CreatedDate, CAP_Request__r.CAP_In_Progress_Timestamp__c, 
                                                        CAP_Request__r.Next_In_Progress_Update__c 
                                                        FROM CAP_Request_Interaction__c 
                                                        WHERE CAP_Request__c IN :scope 
                                                        AND CAP_Request__r.Status__c = 'In Progress' 
                                                        AND Field_Name__c != 'Next_In_Progress_Update__c']) {
                if(capInt.createdDate <= capInt.CAP_Request__r.Next_In_Progress_Update__c 
                && capInt.createdDate >= capInt.CAP_Request__r.CAP_In_Progress_Timestamp__c) {
                    capNonViolatedMap.add(capInt.CAP_Request__c);
                }
            }
            for(CAP_Request__c cap : scope) {
                if(!capNonViolatedMap.contains(cap.id)){
                    //Set violation Flag
                    if(!cap.In_Progress_Updates_Missed__c 
                        && System.now() >= cap.Next_In_Progress_Update__c) {
                        cap.In_Progress_Updates_Missed__c = true;
                        capMap.put(cap.Id, cap);
                    }

                    //Send Email
                    if(cap.Progress_update_frequency__c == 'Daily' 
                        && (cap.Last_Email_Sent_In_Progress_Internal__c == null 
                            || (System.now().getTime() - cap.Last_Email_Sent_In_Progress_Internal__c.getTime()) / 3600000 >= 72) 
                        && dayOfWeek != 'Sat' 
                        && dayOfWeek != 'Sun') {
                        //CAP Interaction Updates were not made
                        emails.add(frameEmailMessage(cap, dailyTemplateId, orgWideEmail));
                        requestIds.add(cap.id);
                    }else if(cap.Progress_update_frequency__c == 'Weekly' 
                        && String.isNotBlank(cap.Notification_day__c) 
                            && dayOfWeek == daysOfWeek.get(cap.Notification_day__c)) {
                        emails.add(frameEmailMessage(cap, weeklyTemplateId, orgWideEmail));
                        requestIds.add(cap.id);
                    }
                }
            }

            if(!capMap.isEmpty()) {
                List<Database.SaveResult> updateResultList = Database.update(capMap.values(), false);
                GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }

            if(!emails.isEmpty() && !Test.isRunningTest()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
                GCSCommonUtility.logSendEmailError(results, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);

                Integer index = 0;
                for(Messaging.SendEmailResult res : results) {
                    if(res.isSuccess()) {
                        capsToBeUpdated.add(requestIds.get(index++));
                    }
                }
            }

            List<CAP_Request__c> capEmailTimestamp = new List<CAP_Request__c>();
            for(CAP_Request__c cp : scope) {
                if(capsToBeUpdated.contains(cp.id)) {
                    cp.Last_Email_Sent_In_Progress_Internal__c = System.now();
                    capEmailTimestamp.add(cp);
                }
            }
            if(!capEmailTimestamp.isEmpty()){
                List<Database.SaveResult> updateResultList = Database.update(capEmailTimestamp, false);
                GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
        }
        catch(Exception ex) {
            System.debug('Exception Chetan '+ex.getStackTraceString());
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, ex.getStackTraceString(), String.valueOf(ex), ex.getTypeName());
        }
    }
    
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
    }   
    
    static Messaging.SingleEmailMessage frameEmailMessage(CAP_Request__c cap, String emailTemplate, String orgWideEmail) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(emailTemplate);
        mail.setWhatId(cap.id);
        mail.setTargetObjectId(cap.Customer_Main_POC_for_Communication__c);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mail.setOrgWideEmailAddressId(orgWideEmail);
        mail.setToAddresses(new List<String>{cap.CAP_Manager__c});
        return mail;
    }
}