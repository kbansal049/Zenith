/*****************************************************************************************
Name: TAMCaseOwnerUpdateController
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex Controller to update PriorOwnerId field of Case as part of Slack TAM Case Owner - New Flow .
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR                   DATE            DETAIL              
1.0                Adarsh Pidaparthy        02/20/2023      
******************************************************************************************/ 

public class TAMCaseOwnerUpdateController {
    static final String APEX_CLASS_NAME = 'TAMCaseOwnerUpdateController';
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added to update PriorOwnerId field of Case as part of Slack TAM Case Owner - New Flow 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : updateCasePriorOwnerId.
    * @param    NAME : List<Case>.
    * @return   TYPE : List<Case>
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @InvocableMethod(category='Case' label='Update Case Prior OwnerId' description='Update the case PriorOwnerId field to null for specified Cases and returns the list of updated Cases.')
    public static List<Case> updateCasePriorOwnerId(List<Id> caseIdList) {
        final String METHOD_NAME = 'updateCasePriorOwnerId';
        List<Case>casesToUpdate = new List<Case>();
        
        try{
            if(!caseIdList.isEmpty()){
                for(Id eachCaseId : caseIdList){
                    Case newCase = new Case();
                    newCase.Id = eachCaseId;
                    newCase.Prior_Owner_Id__c = null;
                    casesToUpdate.add(newCase);
                }
                if(!casesToUpdate.isEmpty()){
                    TriggerHandler.bypass('CaseTriggerHandler');
                    TriggerHandler.bypass('ContactTriggerHandler');
                    TriggerHandler.bypass('AccountTriggerHandler');
                    List<Database.SaveResult> srList = Database.update(casesToUpdate, false);
                    GCSCommonUtility.logDBInsertOrUpdateError(srList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
                    TriggerHandler.clearByPass('CaseTriggerHandler');
                    TriggerHandler.clearByPass('ContactTriggerHandler');
                    TriggerHandler.clearByPass('AccountTriggerHandler');
                    if(test.isRunningTest()){
                        throw new TAMCaseOwnerUpdateException('TAMCaseOwnerUpdateException from Test');
                    }
                } 
            }      
        }
        catch(Exception ex){
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
				GCSCommonConstants.EMPTY_STRING, ex.getStackTraceString(), String.valueOf(ex), ex.getTypeName());
        }
        return casesToUpdate;
    }
    
    public class TAMCaseOwnerUpdateException extends Exception {}
}