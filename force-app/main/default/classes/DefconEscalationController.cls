/**
* @File Name          : DefconEscalationController.cls
* @Description        : 
* @Author             : Ankit Bhatnagar
* @Group              : 
* @Last Modified By   : Ankit Bhatnagar
* @Last Modified On   : 10/01/2022
* @Modification Log   : 
*------------------------------------------------------------------------------
* Ver         Date                     Author                    Modification
*------------------------------------------------------------------------------
* 1.0       10/01/2022                 Ankit Bhatnagar           Initial Version
**/
public without sharing class DefconEscalationController {
    static final String APEX_CLASS_NAME = 'DefconEscalationController';
    public static Boolean IS_INVOKED_FROM_SLACK_SDK = false;
    
    @AuraEnabled
    public static String createDefcon(String reason, Boolean escalationOnBehalf, String caseId){
        final String METHOD_NAME = 'createDefcon';
        String result = GCSCommonConstants.EMPTY_STRING;
        try{
            List<User> usrinfo = [SELECT Id, Level__c, Service_Level__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
            Id escalationRecordTypeId = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME);
            Case dcs = new Case();
            dcs.Status = GCSCommonConstants.CASE_STATUS_NEW;
            dcs.RecordTypeId = escalationRecordTypeId;
            dcs.Escalation_Level__c = GCSCommonConstants.CASE_ESCALATION_LEVEL_LEVEL_0;
            dcs.Escalation_Reason__c = reason;
            dcs.Escalation_on_behalf_of_Customer__c = escalationOnBehalf;
            dcs.Case_Escalated_per_Defcon_Process__c = true;
            dcs.Escalation_Start_Time__c = System.now();
            dcs.Escalated_By__c = UserInfo.getUserId();

            String origin = GCSCommonConstants.EMPTY_STRING;
            String currentUserProfileName = usrinfo[0].Profile.Name;
            String currentUserLevel = usrinfo[0].Level__c;
            
            if(DefconEscalationController.IS_INVOKED_FROM_SLACK_SDK){// Added By Rakesh Nayini for IBA - 5575
                origin = GCSCommonConstants.CASE_ORIGIN_SLACK_APP;
            }
            else if(currentUserProfileName.contains(GCSCommonConstants.CUSTOMER_COMMUNITY_USER_PROFILE_NAME)){
                origin = GCSCommonConstants.CASE_ORIGIN_SUPPORT_PORTAL;
            }
            else if(currentUserProfileName.contains(GCSCommonConstants.PARTNER_COMMUNITY_USER_PROFILE_NAME) 
                || currentUserProfileName.contains(GCSCommonConstants.ZS_PARTNER_COMMUNITY_USER_PROFILE_NAME)){
                origin = GCSCommonConstants.CASE_ORIGIN_PARTNER_PORTAL;
            }
            else{
                origin = GCSCommonConstants.CASE_ORIGIN_SERVICE_CONSOLE;
            }

            //Added by Bhagyalaxmi for IBA-4058 Start
            if(!usrinfo.isEmpty() && currentUserLevel != null){
                dcs.Level_of_Escalator__c = currentUserLevel;
            }
            //Added by Bhagyalaxmi for IBA-4058 End
            //Added/Modified by Rakesh Nayini for IBA-3525
            Map<Id, Case> csMap = new Map<Id, Case>([SELECT Id, CaseNumber, Owner.Email, Product_New__c, OwnerId, Origin, ContactId, 
                                                        Priority, Escalation_on_behalf_of_Customer__c, ParentId, IsEscalated, 
                                                        Customer_Temperature__c, Owner.Profile.Name, 
                                                        AccountId, Account.Support_Type__c, Account.Support_Offering__c 
                                                        FROM Case
                                                        WHERE (Id = :caseId) 
                                                            OR (ParentId = :caseId AND RecordType.DeveloperName = :GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME)]);
            List<Case> defconCases = new List<Case>([SELECT Id, CaseNumber, Defcon_Level__c,
                                                        Escalation_Reason__c, OwnerId, Origin, ContactId, Priority, 
                                                        Escalation_on_behalf_of_Customer__c, AccountId, ParentId, 
                                                        IsEscalated, Customer_Temperature__c, Owner.Profile.Name 
                                                        FROM Case 
                                                        WHERE ParentId = :caseId 
                                                            AND RecordType.DeveloperName = :GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME]);
            if(!csMap.isEmpty() && csMap.size() == 1 && csMap.get(caseId).IsEscalated == false){
                Case parentCase = csMap.get(caseId);
                dcs.Subject = 'DEFCON raised for case ' + parentCase.CaseNumber;
                dcs.ParentId = parentCase.Id;
                dcs.AccountId = parentCase.AccountId;
                dcs.ContactId = parentCase.ContactId;
                dcs.Origin = origin;
                dcs.Priority = parentCase.Priority;
                dcs.Customer_Temperature__c = parentCase.Customer_Temperature__c;
                dcs.Product_New__c = parentCase.Product_New__c;
                //IBA-6457 Added by Ram -- Start
                if(String.isNotBlank(parentCase.AccountId) 
                    && String.isNotBlank(parentCase.Account.Support_Type__c) 
                    && parentCase.Account.Support_Type__c == GCSCommonConstants.PREMIUM_SUPPORT_PLUS_IN_COUNTRY 
                    && String.isNotBlank(parentCase.Account.Support_Offering__c) 
                    && parentCase.Account.Support_Offering__c.contains(GCSCommonConstants.PREMIUM_SUPPORT_PLUS) 
                    && parentCase.Account.Support_Offering__c.contains(GCSCommonConstants.UNITED_STATES)){
                    dcs.OwnerId = System.Label.In_Country_USA_Defcon_Queue_Id;
                }
                else{
                    dcs.OwnerId = UserInfo.getUserId();
                }
                //IBA-6457 Added by Ram -- End

                if(String.valueOf(parentCase.OwnerId).startsWith('005') 
                    && parentCase.Owner.Profile.Name != GCSCommonConstants.CUSTOMER_COMMUNITY_USER_PROFILE_NAME
                    && parentCase.Owner.Profile.Name != GCSCommonConstants.ZS_PARTNER_COMMUNITY_USER_PROFILE_NAME){
                    dcs.Parent_Case_Owner_EmailId__c = parentCase.Owner.Email;
                }

                if(escalationOnBehalf){
                    dcs.Defcon_Level__c = '4';
                }
                else if(parentCase.OwnerId == UserInfo.getUserId()){
                    dcs.Defcon_Level__c = '5';
                }
                else{
                    if(!usrinfo.isEmpty()){
                        for(DEFCON_User_Mapping__c dum : DEFCON_User_Mapping__c.getAll().values()){
                            if((dum.Level__c != null 
                                    && currentUserLevel != null 
                                    && dum.Level__c.contains(currentUserLevel)) 
                                || (dum.Profile_Name__c != null 
                                    && dum.Profile_Name__c.contains(currentUserProfileName))){
                                dcs.Defcon_Level__c = dum.Name;
                                break;
                            }
                        }
                    }  
                }
                List<Database.SaveResult> insertResultList = Database.insert(new List<Case>{dcs}, false);
                GCSCommonUtility.logDBInsertOrUpdateError(insertResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);

                TriggerUtility.SkipCaseTriggerExecuted();
                parentCase.IsEscalated = true;
                List<Database.SaveResult> updateResultList = Database.update(new List<Case>{parentCase}, false);
                GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);

                result = 'SUCCESS';
            }
            else if(!csMap.isEmpty() 
                && csMap.get(caseId).IsEscalated == true 
                && !defconCases.isEmpty()){
                Case defconCase = defconCases.get(0);
                defconCase.Defcon_Level__c = '4';
                defconCase.Escalation_Reason__c = reason;
                defconCase.Escalation_on_behalf_of_Customer__c = escalationOnBehalf;
                defconCase.Escalation_Start_Time__c = System.now();
                defconCase.Escalated_By__c = UserInfo.getUserId();
                defconCase.Origin = origin;
                defconCase.Level_of_Escalator__c = currentUserLevel;
                List<Database.SaveResult> updateResultList = Database.update(new List<Case>{defconCase}, false);
                GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);

                result = 'SUCCESS';
            }
        }
        catch(Exception e){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
            
            if(DefconEscalationController.IS_INVOKED_FROM_SLACK_SDK){
                return e.getMessage();
            }
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static String getSupportRecordTypeId() {
        return GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
    }
}