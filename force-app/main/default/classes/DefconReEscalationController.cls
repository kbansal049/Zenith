/**
* @File Name          : DefconReEscalationController.cls
* @Description        : Defcon is updated when an already escalated case is being escalated again
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
public class DefconReEscalationController {
    static final String APEX_CLASS_NAME = 'DefconReEscalationController';
    public static Boolean IS_INVOKED_FROM_SLACK_SDK = false;

    @AuraEnabled
    public static String updateDefcon(String reason, String caseId){
        final String METHOD_NAME = 'updateDefcon';
        String result = GCSCommonConstants.EMPTY_STRING;
        Boolean isDefconUpdated = false;
        Boolean notEligible = false;
        Case parentCase = new Case();

        try{
            Case dcs = [SELECT Id, Defcon_Level__c, Escalation_Reason__c, ParentId FROM Case WHERE Id = :caseId];
            dcs.Escalation_Reason__c = reason;
            dcs.Escalation_Start_Time__c = System.now();
            dcs.Escalated_By__c = UserInfo.getUserId();
            List<User> usrinfo = [SELECT Id, Level__c, Service_Level__c, Profile.name FROM User WHERE Id = :UserInfo.getUserId()];
            if(!usrinfo.isEmpty()){
                String currentUserLevel = usrinfo[0].Level__c;
                dcs.Level_of_Escalator__c = currentUserLevel;
                for(DEFCON_ReEscalation_Mapping__c dum: DEFCON_ReEscalation_Mapping__c.getAll().values()){
                    if((dum.Level__c != null 
                            && currentUserLevel != null 
                            && dum.Level__c.contains(currentUserLevel)) 
                        || (dum.Profile_Name__c != null 
                            && dum.Profile_Name__c.contains(usrinfo[0].Profile.Name))){
                        if(integer.valueof(dcs.Defcon_Level__c) > integer.valueof(dum.name)){
                            dcs.Defcon_Level__c = dum.name;
                            if(DefconReEscalationController.IS_INVOKED_FROM_SLACK_SDK){ // Added By Rakesh Nayini for IBA - 5575
                                dcs.Origin = 'Slack App';
                            } else {
                                dcs.Origin = 'Service Console';
                            }
                            isDefconUpdated = true;

                            //Added by Bhagya for Defcon Hypercare IBA-5356
                            parentCase.Id = dcs.ParentId;
                            parentCase.Defcon_Level__c = dcs.Defcon_Level__c;
                        }else if(integer.valueof(dcs.Defcon_Level__c) <= integer.valueof(dum.name)){
                            notEligible = true;
                        }
                    }
                }
            }

            if(isDefconUpdated){
                List<Database.SaveResult> updateResultList = Database.update(new List<Case>{dcs}, false);
                GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);

                updateResultList = Database.update(new List<Case>{parentCase}, false);
                GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);

                result = 'SUCCESS';
            }
            else if(notEligible){
                result = 'NOTELIGIBLE';
            }
            else{
                result = 'VALIDATION';
            }  
        }
        catch(Exception e){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
            
            if(DefconReEscalationController.IS_INVOKED_FROM_SLACK_SDK){
                return e.getMessage();
            }
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
}