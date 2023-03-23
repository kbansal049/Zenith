@isTest
public class GCSTestDataFactory {
    
    @TestVisible
    static Case createCase(String subject, String productName, String status, String priority,String origin,String caseType, String timeZone, String methodOfContact,Id recordTypeId, Id ownerId, Id contactId){
        Case cs = new Case();
        cs.Subject = subject;
        cs.Product_New__c = productName;
        cs.Status = status;
        cs.Priority = priority;
        cs.Origin = origin;
        cs.Case_Type__c = caseType;
        cs.Preferred_Contact_Time_Zone__c = timeZone;
        cs.Preferred_Method_of_Contact__c = methodOfContact;
        cs.RecordTypeId = recordTypeId;
        cs.OwnerId = ownerId;
        cs.contactId = contactId;
        return cs;
    }
    
    @TestVisible
    static User createUser(String email, String lastName, String firstName, String alias, String userName, String timeZoneSidKey, String languageLocaleKey, String emailEncodingKey, String localeSidKey){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr = new User();
        usr.LastName = lastname;
        usr.FirstName=Firstname;
        usr.Alias = alias;
        usr.Email = email;
        usr.Username = userName;
        usr.ProfileId = profileId.id;
        usr.TimeZoneSidKey = timeZoneSidKey;
        usr.LanguageLocaleKey = languageLocaleKey;
        usr.EmailEncodingKey = EmailEncodingKey;
        usr.LocaleSidKey = localeSidKey;
        return usr;
    }
    
    @TestVisible
    static Account createAccount(String name, String type, Id recordTypeId){
        Account acct = new Account();
        acct.name = name;
        acct.Type = type;
        acct.RecordTypeId = recordTypeId;
        return acct;
    }
    
    @TestVisible
    static Contact createContact(String lastName, String firstName, String accountId,String email){
        Contact con = new Contact();
        con.LastName = lastName;
        con.FirstName = firstName;
        con.accountId = accountId;
        con.Email = email;
        return con;
    }
    
    @TestVisible
    static Engineer_Schedule__c createEngineerSchedule(String typeStr, Time startTime, Time endTime, 
        String product, Id dutyManager, Id backupDutyManager, Id serviceAgentInfo, String segment, String priority){
        Engineer_Schedule__c es = new Engineer_Schedule__c();
        es.Type__c = typeStr;
        es.Start_Time__c = startTime;
        es.End_Time__c = endTime;
        es.Product__c = product;
        es.Duty_Manager__c = dutyManager;
        es.Backup_Duty_Manager__c = backupDutyManager;
        es.Service_Agent_Information__c = serviceAgentInfo;
        es.Segment__c = segment;
        es.Priority__c = priority;
        return es;
    }
    
    @TestVisible
    static EmailMessage createEmailMessage(Id relatedToId, Id parentId, Boolean incoming, String testBody, String fromAddress){
        EmailMessage emsg = new EmailMessage();
        emsg.RelatedToId = relatedToId;
        emsg.ParentId = parentId;
        emsg.Incoming = incoming;
        emsg.TextBody = testBody;
        emsg.FromAddress = fromAddress;
        return emsg;
    }
    
    @TestVisible
    static Case_Integration__c createCaseIntegration(Id caseId, String caseOrigin, String incidentType){
        Case_Integration__c cInt = new Case_Integration__c();
        cInt.Case__c = caseId;
        cInt.Case_Origin__c = caseOrigin;
        cInt.Incident_Type__c = incidentType;
        return cInt;
    }
    
    @TestVisible
    static Case_Quota_Management__c createCQM(Integer blDailyQuota,Integer blWeeklyQuota,Integer flDailyQuota,Integer flWeeklyQuota,String omniStatus,String profileNames,String skills,String tz,Integer weekdayEndTime,Integer weekdayStartTime,Integer weekendEndTime,Integer weekendStartTime,String weekendEndDay,String weekendStartDay){
        Case_Quota_Management__c cs = new Case_Quota_Management__c();
        cs.SetupOwnerId = UserInfo.getOrganizationId();
        cs.Backline_Daily_Quota__c = blDailyQuota;
        cs.Backline_Weekly_Quota__c = blWeeklyQuota;
        cs.Frontline_Daily_Quota__c = flDailyQuota;
        cs.Frontline_Weekly_Quota__c = flWeeklyQuota;
        cs.Online_Omni_Status__c = omniStatus;
        cs.Profiles_Allowed__c = profileNames;
        cs.Skills_to_Skip__c = skills;
        cs.Timezone__c = tz;
        cs.Weekday_End_Time__c = weekdayEndTime;
        cs.Weekday_Start_Time__c = weekdayStartTime;
        cs.Weekend_End_Day__c = weekendEndDay;
        cs.Weekend_End_Time__c = weekendEndTime;
        cs.Weekend_Start_Day__c = weekendStartDay;
        cs.Weekend_Start_Time__c = weekendStartTime;
        return cs;
    }
    
    @TestVisible
    static Service_Agent_Information__c createSAI(Id userId,Integer dailyQuota,Integer weeklyQuota ,Integer backlog){
        Service_Agent_Information__c sai = new Service_Agent_Information__c();
        sai.user__c = userId;
        sai.daily_quota__c = dailyQuota;
        sai.weekly_quota__c = weeklyQuota;
        sai.backlog__c = backlog;
        return sai;
    }
    
    @TestVisible
    static Entitlement createEntitlement(String name,Id accountId,Date startDate,Id slaProcessId){
        Entitlement entitle = new Entitlement();
        entitle.Name = name;
        entitle.AccountId = accountId;
        entitle.StartDate = startDate;
        entitle.SlaProcessId = slaProcessId;
        return entitle;
    }
    
    @TestVisible
    static Account_Extension__c createAccountExtension(Id accountId){
        Account_Extension__c actExtn = new Account_Extension__c();
        actExtn.Account__c = accountId;
        actExtn.X4th_TAM_Name__c = userInfo.getUserId();
        return actExtn;
    }
    
    @TestVisible
    static Action_Plan__c createActionPlan(Id caseId){
        Action_Plan__c ap = new Action_Plan__c();
        ap.Case__c = caseId;
        ap.Status__c = 'Completed';
        return ap;
    }
    
    @TestVisible
    static Triggers_Switch__c createTriggersSwitch(String name){
        return new Triggers_Switch__c(name = name, Execute__c = true);
    }
    
    @TestVisible
    static Primary_Secondary_Escalation_Support_Map__c getPrimarySecondaryEscMap(String nameStr, String escalationSupportStr, String primarySupportStr, String secondarySupportStr){
        Primary_Secondary_Escalation_Support_Map__c objPrimarySecondaryEscalationSupport = new Primary_Secondary_Escalation_Support_Map__c();
        objPrimarySecondaryEscalationSupport.name = nameStr;
        objPrimarySecondaryEscalationSupport.Escalation_Support__c = escalationSupportStr;
        objPrimarySecondaryEscalationSupport.Primary_Support__c = primarySupportStr;
        objPrimarySecondaryEscalationSupport.Secondary_Support__c = secondarySupportStr;
        return objPrimarySecondaryEscalationSupport;
    }
    
    @TestVisible
    static EmailMessage createEmailMessage(String statusStr, String relatedToIdSTr, String fromAddressStr, String fromNameStr, String toAddressStr, String subjectStr, String htmlBodyStr ){
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.status = statusStr;
        emailMessage.relatedToId = relatedToIdSTr;
        emailMessage.fromAddress = fromAddressStr;
        emailMessage.fromName = fromNameStr;
        emailMessage.toAddress = toAddressStr;
        emailMessage.Subject = subjectStr;
        emailMessage.HtmlBody = htmlBodyStr;
        return emailMessage;
    }
    
    @TestVisible
    static Case_Integration__c createCaseIntegration(String integrationStatusStr, String externalIDStr, String categoryIDStr, String subCategoryIDStr,
                                                     String subSubCategoryIDStr, String dataPointsStr, String customerCommunicationStr, String ticketStatusStr,
                                                     String detailedDescriptionStr, String internalWorkNotesStr,
                                                     String severityStr, String shortDescriptionStr, String assignmentGroupStr, String caseOriginStr, String incidentTypeStr, Id caseStr){
        Case_Integration__c ci = new Case_Integration__c();
        ci.Integration_Status__c = integrationStatusStr;
        ci.External_ID__c = externalIDStr;
        ci.Category_ID__c = categoryIDStr;
        ci.SubCategory_ID__c = subCategoryIDStr;
        ci.SubSubCategory_ID__c = subSubCategoryIDStr;
        ci.Data_Points__c = dataPointsStr;
        ci.Customer_Communication__c = customerCommunicationStr;
        ci.Ticket_Status__c = ticketStatusStr;
        ci.Detailed_Description__c = detailedDescriptionStr;
        ci.Internal_Work_Notes__c = internalWorkNotesStr;
        ci.Severity__c = severityStr;
        ci.Short_Description__c = shortDescriptionStr;
        ci.Assignment_Group__c = assignmentGroupStr;
        ci.Case_Origin__c = caseOriginStr;
        ci.Incident_Type__c = incidentTypeStr;
        ci.Case__c = caseStr;
        return ci;
    }

    @TestVisible
    static CAP_Request__c createCAPRequests(Id accountId,String status, String level, Boolean raiseForCAPCall){
        CAP_Request__c cap = new CAP_Request__c();
        cap.Account__c = accountId;
        cap.Status__c = status;
        cap.CAP_Level__c = level;
        cap.Raise_for_CAP_Call__c = raiseForCAPCall;
        return cap;
    }
    
    @TestVisible
    static Timezone_Region_Mapping__c createTRM(String nameStr,String timezoneStr, String regionStr,String tacRegionStr){
        Timezone_Region_Mapping__c timezoneRegionMapping = new Timezone_Region_Mapping__c();
        timezoneRegionMapping.name = nameStr;
        timezoneRegionMapping.Timezone__c = timezoneStr;
        timezoneRegionMapping.Region__c = regionStr;
        timezoneRegionMapping.TAC_Region__c = tacRegionStr;
        return timezoneRegionMapping;
    }

    @TestVisible
    static ServiceResource createServiceResources(String name,Id relatedRecordID, Date returningDate, Boolean outOfOffice){
        ServiceResource sr = new ServiceResource();
        sr.Name = name;
        sr.relatedRecordID = relatedRecordID;
        sr.Returning_Date__c = returningDate;
        sr.Out_Of_Office__c = outOfOffice;
        return sr;
    }

}