/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* ResourceAbsenceTriggerHelper
* @description - This class works as Helper class for ResourceAbsenceTrigger
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     Anup Dhole
* @maintainedBy   Zscaler
* @version        1.0
* @created        
* @modified       2023-02-02
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* 
**/
public class ResourceAbsenceTriggerHelper {
    static final String APEX_CLASS_NAME = 'ResourceAbsenceTriggerHelper';

    public static void updateOutOfOfficeOnServiceResource(List<ResourceAbsence> newList){
        final String METHOD_NAME = 'updateOutOfOfficeOnServiceResource';
        try{
            Map<Id, ServiceResource> mapOfResources = new Map<Id, ServiceResource>(); 
            Set<Id> setOfResourceId = new Set<Id>();           
            for(ResourceAbsence ra : newList){
                Timezone agentPrefTimezone = Timezone.getTimeZone(ra.timezone__c);
                DateTime currentTimeAgentTimeZone = Datetime.now().addSeconds((agentPrefTimezone.getOffset(Datetime.now())/1000));
                DateTime startInAgentTime = ra.Start.addSeconds((agentPrefTimezone.getOffset(ra.Start)/1000));
                Datetime endInAgentTime = ra.End.addSeconds((agentPrefTimezone.getOffset(ra.End)/1000));                

                if(!mapOfResources.containsKey(ra.ResourceId)){
                    mapOfResources.put(ra.ResourceId, new ServiceResource(Id=ra.ResourceId));
                }
                if(startInAgentTime <= currentTimeAgentTimeZone && endInAgentTime > currentTimeAgentTimeZone){
                    Date returnDate = Date.newinstance(endInAgentTime.year(), endInAgentTime.month(), endInAgentTime.day());
                    mapOfResources.get(ra.ResourceId).Out_Of_Office__c = true;
                    mapOfResources.get(ra.ResourceId).Returning_Date__c = returnDate;
                    mapOfResources.get(ra.ResourceId).OOO_Slack_Notification__c = true;
                    mapOfResources.get(ra.ResourceId).Absence_Record_Id_for_DM_Notification__c = ra.Id;                                                           
                    setOfResourceId.add(ra.ResourceId);                    
                }
                else{
                    if(!setOfResourceId.contains(ra.ResourceId)){
                        mapOfResources.get(ra.ResourceId).Out_Of_Office__c = false;
                        mapOfResources.get(ra.ResourceId).Returning_Date__c = null;
                    }
                }
            }
            if(!mapOfResources.isEmpty()){
                List<Database.SaveResult> updateResultList = Database.update(mapOfResources.values(), false);
                GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
        }catch(Exception ex){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, ex.getStackTraceString(), String.valueOf(ex), ex.getTypeName());
        }
    }
    
    public static void updateOutOfOfficeOnDeletion(List<ResourceAbsence> oldList){
        final String METHOD_NAME = 'updateOutOfOfficeOnDeletion';
        List<ServiceResource> resourceList = new List<ServiceResource>();
        
        try{
            for(ResourceAbsence absence : oldList){
                resourceList.add(new ServiceResource(Id = absence.ResourceId,
                                                     Out_Of_Office__c = false, 
                                                     Returning_Date__c = null));      
            }
            
            if(!resourceList.isEmpty()){
                List<Database.SaveResult> updateResultList = Database.update(resourceList, false);
                GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
            }
        }catch(Exception ex){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, ex.getStackTraceString(), String.valueOf(ex), ex.getTypeName());
        }  
    }

    //IBA-7578 Added by Chetan - Start
    public static void sendEmailToInlineManager(List<ResourceAbsence> newList,Map<Id,ResourceAbsence> oldMap){
        final String METHOD_NAME = 'sendEmailToInlineManager';
        try {
            Map<Id, ServiceResource> mapOfResources = new Map<Id, ServiceResource>();
            Set<Id> setOfResourceIds = new Set<Id>();
            Map<String,EmailTemplate> mapOfEmailTemplates = new Map<String, EmailTemplate>();
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress owea = GCSCommonUtility.getOrgWideEmailAddresses(
                new List<String>{GCSCommonConstants.ZS_SUPPORT_NO_REPLY_EMAIL_ID}).get(GCSCommonConstants.INTEGER_0);
            String contactId = GCSCommonUtility.getContactId();
            List<EmailTemplate> emailTemplates = GCSCommonUtility.getEmailTemplate(
                new List<String>{'SF_Scheduler_Absence_is_added','SF_Scheduler_Absence_is_updated','SF_Scheduler_Absence_is_deleted'});
            for(EmailTemplate et : emailTemplates) {
                mapOfEmailTemplates.put(et.DeveloperName, et);
            }
            if(!mapOfEmailTemplates.isEmpty()){
                EmailTemplate etAdded = mapOfEmailTemplates.get('SF_Scheduler_Absence_is_added');
                EmailTemplate etUpdated = mapOfEmailTemplates.get('SF_Scheduler_Absence_is_updated');
                EmailTemplate etDeleted = mapOfEmailTemplates.get('SF_Scheduler_Absence_is_deleted');
                for(ResourceAbsence ra : newList){
                    setOfResourceIds.add(ra.ResourceId);
                } 
                for(ServiceResource sr : [SELECT Id, Inline_Manager_Email__c, Name 
                                            FROM ServiceResource 
                                            WHERE Id IN :setOfResourceIds]){
                    mapOfResources.put(sr.Id, sr);
                }
                for(ResourceAbsence ra : newList){
                    if(!mapOfResources.isEmpty() && mapOfResources.containsKey(ra.ResourceId)){
                        if(Trigger.isInsert){
                            Messaging.SingleEmailMessage mail = createEmail(mapOfResources.get(ra.ResourceId),etAdded,ra,owea,contactId);
                            mailList.add(mail);
                        }else if(Trigger.isUpdate && ((ra.Start!=oldMap.get(ra.Id).Start) || (ra.End!=oldMap.get(ra.Id).End) || (ra.Type!=oldMap.get(ra.Id).Type))){
                            Messaging.SingleEmailMessage mail = createEmail(mapOfResources.get(ra.ResourceId),etUpdated,ra,owea,contactId);
                            mailList.add(mail);
                        }else if(Trigger.isDelete){
                            Messaging.SingleEmailMessage mail = createEmail(mapOfResources.get(ra.ResourceId),etDeleted,ra,owea,contactId);
                            mailList.add(mail);
                        }  
                    }
                } 
                if(!mailList.isEmpty() && !Test.isRunningTest()){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
                }
            }
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    private static Messaging.SingleEmailMessage createEmail(ServiceResource sr,EmailTemplate et,ResourceAbsence ra,OrgWideEmailAddress owea,String contactId){
        Messaging.SingleEmailMessage mail = GCSCommonUtility.prepareEmailMessage(
            et.Id,contactId,false,owea.Id);
        List<String> listOfAddress = new List<String>();
        String managerEmail = sr.Inline_Manager_Email__c;
        String name = sr.Name;
        String htmlBody = et.HtmlValue;
        String emailSubject = et.Subject;
        String URL = Label.BCP_URL+ ra.Id;
        emailSubject = emailSubject.replace('[[SERVICE_RESOURCE_NAME]]',name);
        htmlBody = htmlBody.replace('[[SERVICE_RESOURCE_NAME]]',name);
        htmlBody = htmlBody.replace('[[ABSENCE_START]]',String.valueOf(ra.Start));
        htmlBody = htmlBody.replace('[[ABSENCE_END]]',String.valueOf(ra.End));
        htmlBody = htmlBody.replace('[[TIMEZONE]]',ra.Timezone__c);
        htmlBody = htmlBody.replace('[[URL]]',URL);
        htmlBody = htmlBody.replace('[[ABSENCE_TYPE]]',ra.Type);
        listOfAddress.add(managerEmail);
        mail.setHtmlBody(htmlBody);
        mail.setSubject(emailSubject);
        mail.setWhatId(ra.Id);
        mail.setToAddresses(listOfAddress);
        return mail;
    }
    //IBA-7578 Added by Chetan - End

   
}