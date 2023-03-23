trigger CaseIntegration on Case_Integration__c (before insert, before update, after insert, after update) {
    
    Boolean skiptrigger = false;
    
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    System.debug('CaseIntegration Trigger');
    //User Base Skip Logic
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(usertoskip != null && objname != null &&  usertoskip.Object_s_to_skip__c != null && 
       usertoskip.Object_s_to_skip__c.split(';') != null &&
       usertoskip.Object_s_to_skip__c.split(';').contains(objname)) 
    {
        skiptrigger = true;
    }
    
    System.debug('CaseIntegrationHandler skiptrigger'+skiptrigger);
    //Trigger Switch Base Skip Logic
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    if(!skiptrigger &&  tsmap != null && !tsmap.isEmpty() &&
       tsmap.containsKey('Execute_CASE_Integration_Trigger') && tsmap.get('Execute_CASE_Integration_Trigger') != null &&
       tsmap.get('Execute_CASE_Integration_Trigger').Execute__c)
    {        
        
        //Field Update
        System.debug('--TriggerUtility.isCaseIntegartionExecuted()--'+TriggerUtility.isCaseIntegartionExecuted());
        if(!TriggerUtility.isCaseIntegartionExecuted()){
            new CaseIntegrationHandler().MainEntry(Trigger.operationType, trigger.IsExecuting, trigger.new, trigger.newmap, trigger.old, trigger.oldmap);
        }
        
        //Patch through API
        System.debug('--TriggerUtility.isCaseIntegartionPatchExecuted()--'+TriggerUtility.isCaseIntegartionPatchExecuted());
        if(!TriggerUtility.isCaseIntegartionPatchExecuted()){
            
            System.debug('-----in pacth 1----'+Trigger.operationType);
            IF(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
                TriggerUtility.caseCaseIntegartionPatchSetTrue();
                System.debug('-----in pacth 2----');
                new CaseIntegrationHandler().callSiemensPatch(trigger.newmap, trigger.oldmap);
            }
        }
    }

    if(Trigger.isBefore && Trigger.isUpdate && tsmap != null && !tsmap.isEmpty() &&
    tsmap.containsKey('Execute_Field_Changed_Check') && tsmap.get('Execute_Field_Changed_Check') != null &&
    tsmap.get('Execute_Field_Changed_Check').Execute__c && !CaseIntegrationHandler.isexecuteFieldUpdateCheckExecuted()){
        CaseIntegrationHandler.getUpdatedFields(Trigger.newMap, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate && tsmap != null && !tsmap.isEmpty() &&
    tsmap.containsKey('Execute_File_Association_With_Cases') && tsmap.get('Execute_File_Association_With_Cases') != null &&
    tsmap.get('Execute_File_Association_With_Cases').Execute__c && !CaseIntegrationHandler.isExecuteFilesAssociationToCaseExecuted()){
        CaseIntegrationHandler.associateAllCaseIntFilesWithCase(Trigger.new, Trigger.oldMap);
    }
}