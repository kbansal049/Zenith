/**
 * @description       : This class acts as Controller for LWC/Aura Component - BookMeetingScheduler_Aura.cmp
 * @author            : Bhagyalaxmi Deshmukh
 * @last modified on  : 01-20-2023
 * @last modified by  : Bhagyalaxmi Deshmukh
**/

public class BookMeetingSchedulerController {
    static final String APEX_CLASS_NAME = 'BookMeetingSchedulerController';

    /**
    * This method is used to get details of Case and send them to LWC component 
    * so that this data is fed to Flow - 'Book Meeting Flow'.
    * @param  caseRecordId Case Record Id
    */
    @AuraEnabled(Cacheable=true)
    public static BookMeetingWrapper getDetails(String caseRecordId){
        final String METHOD_NAME = 'getDetails';
        BookMeetingWrapper wrapperObj = new BookMeetingWrapper();
        try {
            List<String> profileTACList = Label.TAC_Profile_List.split(GCSCommonConstants.COMMA_STRING);
            List<String> profileDutyMgrList = Label.Duty_Manager_Profile_List.split(GCSCommonConstants.COMMA_STRING);
            List<String> profileTAMList = Label.TAM_Profile_List.split(GCSCommonConstants.COMMA_STRING);
            
            User userData = [SELECT Id, ProfileId, Profile.Name, Skills__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            String profileName = userData != null ? userData.Profile.Name : GCSCommonConstants.EMPTY_STRING;

            wrapperObj.currentUserType = profileTACList.contains(profileName) ? GCSCommonConstants.TAC_STRING : wrapperObj.currentUserType;
            wrapperObj.currentUserType = profileDutyMgrList.contains(profileName) ? GCSCommonConstants.DUTY_MANAGER_STRING : wrapperObj.currentUserType;
            wrapperObj.currentUserType = profileTAMList.contains(profileName) ? GCSCommonConstants.SERVICE_RESOURCE_TYPE_TAM : wrapperObj.currentUserType;
            if(userData.Skills__c!=null && userData.Skills__c != ''){
                wrapperObj.currentUserType = userData.Skills__c.contains(GCSCommonConstants.CS_CASE_SKILL) ? GCSCommonConstants.CS_CASE_SKILL : wrapperObj.currentUserType;
            }
            
            if(String.isNotBlank(caseRecordId)){
                Case currentCase = [SELECT Id, AccountId, Internal_Escalation__c, Priority, Case_Type__c, Case_source__c, 
                                    Case_Category__c, Case_Support_Type__c, Customer_Segment__c, Product_New__c 
                                    FROM Case 
                                    WHERE Id = :caseRecordId LIMIT 1];                

                wrapperObj.caseId = currentCase.Id;
                wrapperObj.caseProduct = currentCase.Product_New__c == GCSCommonConstants.CASE_PRODUCT_ZPA ? GCSCommonConstants.CASE_PRODUCT_ZPA : GCSCommonConstants.CASE_PRODUCT_PLATINUM;
                
                if(currentCase.Internal_Escalation__c){
                    wrapperObj.caseSupportType = GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE;
                    wrapperObj.isInternallyEscalated = true;
                }else{
                    wrapperObj.caseSupportType = setSupportType(currentCase);
                    wrapperObj.isInternallyEscalated = false;
                }
            }
        }catch(Exception e){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
        return wrapperObj;
    }

    /**
    * This method calculates Support Type for flow - 'Book Meeting Flow' based on Case Object
    * @param  caseObj Case Record
    */
    Public Static string setSupportType(Case caseObj){
        final String METHOD_NAME = 'setSupportType';
        String caseSupportType;
        try{
            Map<Id, Account> accmap = new Map<Id, Account>();
            Set<Id> prioritizedCaseRoutingAccountsSet = new Set<Id>();
            Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
            Account acc = [SELECT Id, Type, TAM_Name_New__c, Name, Secondary_TAM_Name__c, X3rd_TAM_Name__c, 
                            Customer_Support_Segment__c, Support_Type__c, Prospect_Type__c, Exclude_Partner_Support__c, 
                            Language_Support__c, District__c, CAP_Level__c, 
                            (SELECT Id, CAP_Level__c, Prioritized_Case_Routing__c, Status__c 
                                FROM CAP_Requests__r 
                                WHERE Status__c != :GCSCommonConstants.CASE_STATUS_CLOSED 
                                ORDER BY LastModifiedDate DESC LIMIT 1) 
                            FROM Account 
                            WHERE Id = :caseObj.AccountId];
            accmap.put(acc.Id, acc);
        
            if(!acc.CAP_Requests__r.isEmpty() 
                && String.isNotBlank(acc.CAP_Level__c) 
                && acc.CAP_Requests__r.get(0).Prioritized_Case_Routing__c) {
                prioritizedCaseRoutingAccountsSet.add(acc.Id);
            }
        
            if(caseObj.AccountId != null 
                && accmap.get(caseObj.AccountId).Type == GCSCommonConstants.ACCOUNT_PARTNER_RECORD_TYPE_NAME 
                && (caseObj.case_type__c != GCSCommonConstants.CASE_TYPE_PROVISIONING 
                    || caseObj.case_type__c != GCSCommonConstants.CASE_TYPE_CATEGORIZATION 
                    || caseObj.Case_Category__c != GCSCommonConstants.CASE_TYPE_PROVISIONING_REQUEST) 
                && caseObj.case_source__c != GCSCommonConstants.CASE_CASE_SOURCE_INTEGRATION){
                caseSupportType = psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.PLATINUM_CASE_SKILL) 
                                    ? psesupportmap.get(GCSCommonConstants.PLATINUM_CASE_SKILL).Primary_Support__c 
                                    : GCSCommonConstants.EMPTY_STRING;
            }else if(caseObj.AccountId != null 
                && prioritizedCaseRoutingAccountsSet.contains(caseObj.AccountId) 
                && (caseObj.priority == GCSCommonConstants.CASE_PRIORITY_HIGH 
                    || caseObj.priority == GCSCommonConstants.CASE_PRIORITY_URGENT) 
                && (caseObj.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                    || caseObj.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION)){
                caseSupportType = GCSCommonConstants.CASE_PRIORITY_SUPPORT_BACKLINE;
            }else if(caseObj.AccountId != null 
                && !accmap.isEmpty() 
                && accmap.containsKey(caseObj.AccountId) 
                && accmap.get(caseObj.AccountId) != null){
                String segmentForCase = accmap.get(caseObj.AccountId).Customer_Support_Segment__c;
                    String premiumPlusTypes = Label.Premium_Plus_Support_Types;
                    List<String> premiumPlusTypesList = premiumPlusTypes.split(GCSCommonConstants.SEMI_COLON_STRING);
                    
                    String premiumPlusProducts = Label.Prem_Plus_P1_Routing_Products;
                    List<String> premiumPlusProductsList =  premiumPlusProducts.split(GCSCommonConstants.COMMA_STRING);
                    
                    if(!premiumPlusProductsList.isEmpty() 
                        && premiumPlusProductsList.contains(caseObj.Product_New__c) 
                        && caseObj.Priority == GCSCommonConstants.CASE_PRIORITY_URGENT 
                        && (caseObj.Case_Type__c == GCSCommonConstants.CASE_TYPE_PROBLEM 
                            || caseObj.Case_Type__c == GCSCommonConstants.CASE_TYPE_QUESTION)){
                        segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                    }else if(String.isBlank(segmentForCase) 
                        || accmap.get(caseObj.AccountId).Prospect_Type__c == GCSCommonConstants.PROSPECT_TYPE_POC){
                        segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                    }else if(premiumPlusTypesList != null 
                        && !premiumPlusTypesList.isEmpty() 
                        && accmap.get(caseObj.AccountId).Support_Type__c != null 
                        && premiumPlusTypesList.contains(accmap.get(caseObj.AccountId).Support_Type__c)){
                        segmentForCase = GCSCommonConstants.PLATINUM_CASE_SKILL;
                    }
                    caseSupportType = psesupportmap != null && psesupportmap.containsKey(segmentForCase) 
                                        ? psesupportmap.get(segmentForCase).Primary_Support__c 
                                        : GCSCommonConstants.EMPTY_STRING;
            }else{
                caseSupportType = psesupportmap != null && psesupportmap.containsKey(GCSCommonConstants.CS_CASE_SKILL) 
                                    ? psesupportmap.get(GCSCommonConstants.CS_CASE_SKILL).Primary_Support__c 
                                    : GCSCommonConstants.EMPTY_STRING;
            }
        }catch(Exception e){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
        return caseSupportType;
    }

    /**
     * This method is used to set Slack Message Template 
     * @param absenceList List of Absences sent from Flow - 'Slack_Notification_to_DM_and_RM_When_Absence_is_Created_or_Updated'
     */
    @InvocableMethod(label='Get Template')
    public static List<string> setSlackTemplate(List<ResourceAbsence> absenceList){
        final String METHOD_NAME = 'setSlackTemplate';
        String messageTemplate;
        try {
            if(!absenceList.isEmpty()){
                ResourceAbsence absence = absenceList.get(0);
                Date absenceStartDate = absence.Start.date();
                Date absenceEndDate = absence.End.date();
                String resourceId = absence.ResourceId;
                string startDateTime = absence.Start.formatGmt(GCSCommonConstants.DATETIME_DATABASE_FORMAT);
                string endDateTime = absence.End.formatGmt(GCSCommonConstants.DATETIME_DATABASE_FORMAT);
                String baseLink = URL.getSalesforceBaseUrl().toExternalForm() + '/';
                String resourceName = [SELECT Id,Name FROM ServiceResource WHERE Id = :absence.ResourceId].Name; 
                String caseobj = GCSCommonConstants.CASE_STRING;
                String status = GCSCommonConstants.SUPPORT_MEETING_STATUS_CANCELED;
                String queryMeetings = 'SELECT Id, ServiceResourceId,ServiceResource.Name, ServiceResource.RelatedRecordId, ServiceResource.RelatedRecord.Email,' 
                                        + ' ServiceResource.RelatedRecord.ManagerId, ServiceAppointmentId,ServiceAppointment.AppointmentNumber,' 
                                        + ' ServiceAppointment.SchedStartTime, ServiceAppointment.StatusCategory, ServiceAppointment.Account.Name,' 
                                        + ' ServiceAppointment.SchedEndTime, ServiceAppointment.Status, ServiceAppointment.ParentRecordType,' 
                                        + ' ServiceAppointment.ParentRecordId, ServiceAppointment.Case_Number__c' 
                                        + ' FROM AssignedResource' 
                                        + ' WHERE ServiceResourceId = :resourceId' 
                                        + ' AND ServiceAppointment.ParentRecordType = : caseobj' 
                                        + ' AND ((ServiceAppointment.SchedStartTime >= ' + startDateTime 
                                                + ' AND ServiceAppointment.SchedStartTime <= '+ endDateTime + ')'
                                            + ' OR (ServiceAppointment.SchedEndTime <= ' + endDateTime 
                                                + ' AND ServiceAppointment.SchedEndTime >= ' + startDateTime + '))'
                                        + ' AND ServiceAppointment.StatusCategory != :status ' 
                                        + ' Order By ServiceAppointment.SchedStartTime';

                if(absenceStartDate == System.today() 
                    || (absenceStartDate < System.today() 
                        && absenceEndDate > System.today()) 
                    || absenceEndDate == System.today()){
                    messageTemplate = 'An absence has been added from ' + absence.Start 
                                        + ' (GMT) to ' + absence.End 
                                        + ' (GMT) for ' + resourceName 
                                        + ', this service resource (agent) has the following customer support meetings reserved' 
                                        + ' during his/her OOO period.\n\n';
                }else if(absenceStartDate > System.today()){
                    messageTemplate = 'An absence has been added from ' + absence.Start 
                                        + ' (GMT) to '+ absence.End 
                                        + ' (GMT) for ' + resourceName 
                                        + ', this service resource (agent) has following customer support meetings scheduled' 
                                        + ' during his/her OOO period. Kindly manage these meetings.\n\n';
                }
                
                String meetingTemplate = GCSCommonConstants.EMPTY_STRING;
                for(AssignedResource aresource : Database.query(queryMeetings)){
                    meetingTemplate += 'Account Name: ' + aresource.ServiceAppointment.Account.Name 
                                        + '\nCase Number: ' + aresource.ServiceAppointment.Case_Number__c                                         
                                        + '\nMeeting Start Time: ' + aresource.ServiceAppointment.SchedStartTime 
                                        + ' (GMT) '+
                                        + '\nMeeting End Time: ' + aresource.ServiceAppointment.SchedEndTime 
                                        + ' (GMT) '+
                                        + '\nMeeting Link: ' + baseLink+aresource.ServiceAppointmentId 
                                        + '\n\n'; 
                }

                if(String.isNotBlank(meetingTemplate)){
                    messageTemplate += meetingTemplate;
                }else{
                    messageTemplate = GCSCommonConstants.EMPTY_STRING;
                }
            }
        }catch (Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
        return new List<String>{messageTemplate};
    }


    public class BookMeetingWrapper{
        @AuraEnabled
        public String caseId{ get; set; }
        @AuraEnabled
        public String caseProduct{ get; set; }
        @AuraEnabled
        public String caseSupportType{ get; set; }
        @AuraEnabled
        public string currentUserType{ get; set; }
        @AuraEnabled
        public boolean isInternallyEscalated{ get; set; }
    }
}