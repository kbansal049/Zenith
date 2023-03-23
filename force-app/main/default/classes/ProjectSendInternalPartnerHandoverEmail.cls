/**
* description       : This class sends an email to Account CSM and Opp Owner when Project object
* 					  Field 'Project Manager(Primary)' is updated to 'Partner Program PM' user.
* 					  It is called from ProjectTrigger
* @author            : Sachin Tandon
* @Change Request    : CR #4425
* @last modified on  : 01-04-2022
* @last mod@desified by  : Sachin Tandon
* Modifications Log 
* Ver   Date         Author             Modification
* 1.0  01-04-2022   Sachin Tandon	   Initial Version
**/

public with sharing class ProjectSendInternalPartnerHandoverEmail {

    private static String PARTNER_PROGRAM_PM = 'Partner Program PM';
    @TestVisible
    private static String SENDERS_EMAILID = 'z-ps-ops@zscaler.com';
    @TestVisible
    private static String TEMPLATE_DEVELOPER_NAME = 'Internal_Partner_Handover_1648704802005';
    @TestVisible
    private static Id PARTNER_PROGRAM_PM_ID = getPartnerProgramPMUserId();
    public static Boolean isRunningTwice = false;
    
    public static void sendEmailToAccountCSMAndOppOwner(Map<Id,inspire1__Project__c> newProjectByProjectId) {

        Map<Id,inspire1__Project__c> validProjects = getValidProjects(newProjectByProjectId);
        if(validProjects == null || validProjects.isEmpty() || isRunningTwice) { return; }
        //System.debug('validProjects-->'+validProjects);
        //System.debug('validProjects Size-->'+validProjects.size());
        prepareAndSendEmails(validProjects);
    }

    public static void sendEmailToAccountCSMAndOppOwner(Map<Id,inspire1__Project__c> oldProjectByProjectId , Map<Id,inspire1__Project__c> newProjectByProjectId) {

        Map<Id,inspire1__Project__c> validProjects = getValidProjects(oldProjectByProjectId,newProjectByProjectId);
        if(validProjects != null && !validProjects.isEmpty() && !isRunningTwice) {
           // System.debug('validProjects-->'+validProjects);
        	prepareAndSendEmails(validProjects);
        }
    }
    
    @TestVisible
    private static void prepareAndSendEmails( Map<Id,inspire1__Project__c> validProjects) {
	 	sendEmails(prepareEmails(validProjects));
        isRunningTwice = true;
    }

    /**
     * @description getValidProjects It filters the Project Id whose Primary Manager has been updated to PARTNER_PROGRAM_PM
     * @param  oldProjectByProjectId  Map<Id,inspire1__Project__c> is Trigger.oldMap 
     * @param  newProjectByProjectId Map<Id,inspire1__Project__c> is Trigger.newMap
     * @return  validProjects Map<Id,inspire1__Project__c> - Map of Project By Project Id whose Primary Manager has been updated to PARTNER_PROGRAM_PM    
     * */  
    private static Map<Id,inspire1__Project__c> getValidProjects(Map<Id,inspire1__Project__c> newProjectByProjectId ) {
        if(newProjectByProjectId == null || newProjectByProjectId.isEmpty() ) { return new Map<Id,inspire1__Project__c>(); }

        Map<Id,inspire1__Project__c> validProjects = new Map<Id,inspire1__Project__c>();
        for(inspire1__Project__c newProjectValue : newProjectByProjectId.values()) {
			//System.debug('newProjectValue.Project_Manager__c-->'+newProjectValue.Project_Manager__c);
            if(isPartnerManagerPM(newProjectValue.Project_Manager__c)) { 
                validProjects.put(newProjectValue.Id,newProjectValue);
            }
        }
        return validProjects;
    }


    private static Map<Id,inspire1__Project__c> getValidProjects(Map<Id,inspire1__Project__c> oldProjectByProjectId , Map<Id,inspire1__Project__c> newProjectByProjectId) {
        if(newProjectByProjectId == null || newProjectByProjectId.isEmpty() ) { return new  Map<Id,inspire1__Project__c>();  }

        Map<Id,inspire1__Project__c> validProjects = new Map<Id,inspire1__Project__c>();
        for(inspire1__Project__c newProjectValue : newProjectByProjectId.values()) {
            
            inspire1__Project__c oldProjectValue = oldProjectByProjectId.get(newProjectValue.Id);
            if(isNewProjectManagerPartnerManagerPM(newProjectValue.Project_Manager__c,oldProjectValue.Project_Manager__c)) {
                validProjects.put(newProjectValue.Id,newProjectValue);
            }
        }
        return validProjects;
    }
    
    @TestVisible
    private static List<Messaging.SingleEmailMessage> prepareEmails(Map<Id,inspire1__Project__c> projectByProjectId) {
        if(projectByProjectId == null || projectByProjectId.isEmpty()) { return new List<Messaging.SingleEmailMessage>();}
        
        String defaultOWDSenderId = getSendersEmailId(SENDERS_EMAILID);
        String templateId = getEmailTemplateId(TEMPLATE_DEVELOPER_NAME);
        Map<Id,List<String>> emailIdsToProjectId = getAccountCSMANDOppOwnerEmailIdsByProjectId(projectByProjectId.keyset());
        List<Messaging.SingleEmailMessage> mailsToBeSend = new List<Messaging.SingleEmailMessage>();

        if(emailIdsToProjectId != null && !emailIdsToProjectId.isEmpty()) {
			for(Id projectId : emailIdsToProjectId.KeySet()) {
               // System.debug('projectId-->'+projectId);
                Messaging.SingleEmailMessage mail = prepareEmail(templateId,defaultOWDSenderId,emailIdsToProjectId.get(projectId),projectId);
                mailsToBeSend.add(mail);
        	}            
        }
        return mailsToBeSend;
    }
    
    @TestVisible
    private static Messaging.SingleEmailMessage prepareEmail(Id templateId, Id defaultOWDSenderId,List<String>toEmailAddresses , Id projectId ) {

        //CR# 4773 START
        List<String> ccAddresses = new List<String> {'z-ps-ops-team@zscaler.com'};
        //CR# 4773 END
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(templateId), Null, String.valueOf(projectId));
            mail.setToAddresses(toEmailAddresses);
            mail.setOrgWideEmailAddressId(defaultOWDSenderId);
            mail.setTreatBodiesAsTemplate(True);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setsaveAsActivity(false);
            //CR# 4773 START
            mail.setCcAddresses(ccAddresses);
            //CR# 4773 END
            return mail;
    }
    
    @TestVisible
    private static void sendEmails(List<Messaging.SingleEmailMessage> emailsToBeSend) {
        if(!emailsToBeSend.isEmpty()) {
            Messaging.sendEmail(emailsToBeSend);
        }
    }

    private static Boolean isNewProjectManagerPartnerManagerPM(Id newManagerId , Id oldManagerId) {
        return isPartnerManagerPM(newManagerId) && oldManagerId != newManagerId ; 
    }

    private static Boolean isPartnerManagerPM(Id newManagerId) {
        return newManagerId == PARTNER_PROGRAM_PM_ID;
    }

    private static Id getPartnerProgramPMUserId() {
        return [SELECT Id FROM User WHERE Name =: PARTNER_PROGRAM_PM LIMIT 1].Id;
    }

    private static Id getSendersEmailId(String addressId) {
       return  [SELECT id, Address,IsAllowAllProfiles FROM OrgWideEmailAddress WHERE Address =: addressId].Id;
    }

    private static Id getEmailTemplateId(String templateName) {
        return [SELECT Id,Subject,HtmlVAlue FROM EmailTemplate where DeveloperName =: templateName].Id;
    }

    private static Map<Id,List<String>> getAccountCSMANDOppOwnerEmailIdsByProjectId(Set<Id> projectIds) {
        
        Map<Id,List<String>> emailIdsToProjectId = new Map<Id,List<String>>();
        List<inspire1__Project__c> projects = getEmailAddresses(projectIds);

        Set<String> toEmailIds;
        if(!projects.isEmpty()) {
             for(inspire1__Project__c project : projects) {
                
                toEmailIds = new Set<String>();
                if (isNotNull(project.inspire1__Account__r.CSM_Name_New__r.Email)) {
                    toEmailIds.add(project.inspire1__Account__r.CSM_Name_New__r.Email);
                }
                
                if (isNotNull(project.Opportunity_Owner__r.Email)) {
                    toEmailIds.add(project.Opportunity_Owner__r.Email);
                }
                
                
                if(!toEmailIds.isEmpty()) {
                    emailIdsToProjectId.put(project.Id,new List<String>(toEmailIds));
                }
            }   
        }
        return emailIdsToProjectId;
    }

    private static Boolean isNotNull(String str) {
        return String.isNotBlank(str);
    }

    private static List<inspire1__Project__c> getEmailAddresses(Set<Id> projectIds) {
        return [
            SELECT  Id,
                inspire1__Account__r.CSM_Name_New__r.Email, 
                Opportunity_Owner__r.Email 
            FROM inspire1__Project__c 
            WHERE Id IN: projectIds ];
    }
}