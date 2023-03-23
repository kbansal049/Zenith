trigger ProjectTrigger on inspire1__Project__c (after update, after insert, before insert, before update, before delete, after delete) {
    
    /***********************************************************************
     * 
     * NOTE: All the trigger logic can be moved to the following handler
     * 
     **********************************************************************/
    
    try {
        //CR# 2695
        if(Test.isRunningTest() && Trigger.isInsert && !Trigger.new.isEmpty() && Trigger.new.get(0).Management_Notes__c == 'ThrowException') {
            throw new IllegalArgumentException('error');
        }    
        new InspireProjectMasterTriggerHandler().run(); 
    }catch(Exception ex) {
        System.debug(ex.getMessage() + '\r\nLine: ' + ex.getLineNumber() + '\r\n\r\n' + ex.getStackTraceString());
        throw ex;
    } 
  /*  Boolean skiptrigger = false;
    Boolean fillProjectSummaryTriggerExecute = false; //Added by Varun - CR 1069
    
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    
    //User Base Skip Logic
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(usertoskip != null && objname != null &&  usertoskip.Object_s_to_skip__c != null && 
       usertoskip.Object_s_to_skip__c.split(';') != null &&
       usertoskip.Object_s_to_skip__c.split(';').contains(objname))
    {
        skiptrigger = true;
    }
    
    //Trigger Switch Base Skip Logic
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    if(!skiptrigger &&  tsmap != null && !tsmap.isEmpty() &&
       tsmap.containsKey('Execute_Project_Trigger') && tsmap.get('Execute_Project_Trigger') != null &&
       tsmap.get('Execute_Project_Trigger').Execute__c)
    {
        //CR# 43 && CR# 813
        if(TriggerUtility.isProjectCloneExecuted() == false){            
            new ProjectTriggerHandlerClone().MainEntry(Trigger.operationType, trigger.IsExecuting, trigger.new, trigger.newmap, trigger.old, trigger.oldmap);
        }
        
        //Before Insert
        if(Trigger.isBefore && Trigger.isInsert){
            //CR# 688
            PlannerProjectTriggerHandler.FillActionPlanModifiedDate(null,Trigger.new,true);
        }
        
        //Before Update
        if(Trigger.isBefore && Trigger.isUpdate){
            //CR# 688
            PlannerProjectTriggerHandler.FillActionPlanModifiedDate(Trigger.oldMap, Trigger.new,false);
            
            //CR# 291
            PlannerProjectTriggerHandler.fillProjectCompletionDate(Trigger.oldMap, Trigger.newMap);
            
            // Added by Varun - CR 1069 - Start
            if(!fillProjectSummaryTriggerExecute &&  tsmap != null && !tsmap.isEmpty() &&
               tsmap.containsKey('Execute_Fill_Summary_Notes_Dates') && tsmap.get('Execute_Fill_Summary_Notes_Dates') != null &&
               tsmap.get('Execute_Fill_Summary_Notes_Dates').Execute__c){
                   PlannerProjectTriggerHandler.fillProjectSummaryLastModified(Trigger.new,Trigger.oldMap);// Added by Varun - CR 1069
               }
            // Added by Varun - CR 1069 - End
            PlannerProjectTriggerHandler.updateEmailFieldsForPartnerProject(Trigger.new, Trigger.oldMap); 	//Added by Ayush Kangar as part of CR#3541, updated for CR#3763
        }
        
        // Added by Varun - CR 1069 - Start
        if(!fillProjectSummaryTriggerExecute &&  tsmap != null && !tsmap.isEmpty() &&
           tsmap.containsKey('Execute_Fill_Summary_Notes_Dates') && tsmap.get('Execute_Fill_Summary_Notes_Dates') != null &&
           tsmap.get('Execute_Fill_Summary_Notes_Dates').Execute__c){
               if(Trigger.isBefore && Trigger.isInsert){
                   PlannerProjectTriggerHandler.fillProjectSummaryLastModified(Trigger.new,null);
               }
           }
        // Added by Varun - CR 1069 - End
        
        //After Update
        if(Trigger.isAfter && Trigger.isUpdate){
                
            PlannerProjectTriggerHandler.createSurvey(Trigger.oldMap, Trigger.newMap);
            
            //CR# 666
            if(TriggerUtility.iscreateCSMProjectFromCompletedExecuted() == false){
                PlannerProjectTriggerHandler.createCSMProject(Trigger.oldMap, Trigger.newMap);
            }
            
            //CR# 693 and CR# 736
            if(TriggerUtility.isprojectFieldUpdateExecuted() == false && tsmap.containsKey('Execute_SendEmail_Project_Trigger') && tsmap.get('Execute_SendEmail_Project_Trigger') != null &&
               tsmap.get('Execute_SendEmail_Project_Trigger').Execute__c){
                   PlannerProjectTriggerHandler.sendEmailNotification(Trigger.oldMap,trigger.new);
               }
            // CR#2282 PS deployment project--Added by Chetan-Start
            if(tsmap.containsKey('Execute_UpdateProjectResourcesOnPSQ') && tsmap.get('Execute_UpdateProjectResourcesOnPSQ') != null && tsmap.get('Execute_UpdateProjectResourcesOnPSQ').Execute__c){
                PlannerProjectTriggerHandler.updateProjectResourcesOnPSQ(Trigger.oldMap, Trigger.new);
            }
            // CR#2282 PS deployment project--Added by Chetan-End
        }
    }
    
    
    if(!skiptrigger)  {
        if(Trigger.isBefore && Trigger.isInsert)  {
            ProjectBeforInsertAccountExHandler.updateExtentison(Trigger.new, null);
            
            //CR 735
            ProjectBeforInsertAccountExHandler.updateRegionOnProject(Trigger.new);
        }
        
        if(Trigger.isBefore && Trigger.isUpdate)  {
            ProjectBeforInsertAccountExHandler.updateExtentison(Trigger.new, Trigger.oldMap);
        }
    }
    
    //CR# 2204 - Commented the code as the email will be sent using the above trigger logic for CR# 2695
    
    if((!skiptrigger && Trigger.isBefore) && (Trigger.isInsert || Trigger.isUpdate)) {
        
        ProjectAccountCSMGenerator csmGenerator = ProjectAccountCSMGenerator.getInstance();
        csmGenerator.handleAccountCSMGeneration();
    
    }
    
    //CR #4425 Start
    if((!skiptrigger && Trigger.isAfter)) {
        try {
			if(Trigger.isInsert) {
                ProjectSendInternalPartnerHandoverEmail.sendEmailToAccountCSMAndOppOwner(Trigger.newMap);
            }else if(Trigger.isUpdate) {
                ProjectSendInternalPartnerHandoverEmail.sendEmailToAccountCSMAndOppOwner(Trigger.oldMap,Trigger.newMap);
            }
        }catch(Exception ex) {
            System.debug(ex.getMessage() + '\r\nLine: ' + ex.getLineNumber() + '\r\n\r\n' + ex.getStackTraceString());
        } finally {
            ProjectSendInternalPartnerHandoverEmail.isRunningTwice = true;
        }
    }
    //CR #4425 End
    
        /*ErrorLogUtility.createAndInsertErrorLogs(ex,new List<ErrorLogUtility.ErrorLogWrapper> {
    new ErrorLogUtility.ErrorLogWrapper('ProjectSendInternalPartnerHandoverEmail',
    'sendEmailToAccountCSMAndOppOwner',
    'on Project insert/Update','',new List<Id>(Trigger.newMap.KeySet()))
    
}); */

/*
//CR 4582 Start
    if(trigger.isbefore){
        if (trigger.isinsert){
			UpdateProjectNameTriggerHandler.updateProjectName(Trigger.new);
            ProjectUpdateZIAZPAL31DTriggerHandler.updateZIAZPAOnProjectCompletionOnInsert(Trigger.new);
            ProjectUpdateStatusTriggerHandler.setProjectStatusToPendingIfProjectManagerIsNull(Trigger.new);
            ProjectUpdateOwnerTriggerHandler.updateProjectOwnerToProjectManager(Trigger.new);
        }
        if(trigger.isupdate){
            ProjectEscalationTriggerHandler.escalateProject(Trigger.oldmap, Trigger.newmap);
            ProjectDelayedDeployementTriggerHandler.updateDelayedDeploymentStartTime(Trigger.oldmap, Trigger.newmap);
            ProjectUpdateZIAZPAL31DTriggerHandler.updateZIAZPAOnProjectCompletionOnUpdate(Trigger.newMap,Trigger.oldMap);
            ProjectUpdateStatusTriggerHandler.setProjectStatusToPendingIfProjectManagerIsNull(Trigger.new);
            ProjectUpdateOwnerTriggerHandler.updateProjectOwnerToProjectManager(Trigger.new);
        }
    }

    if(trigger.isafter){
        if (trigger.isinsert){
            SendProjectWonEmailTriggerHandler.sendAlertEmail(Trigger.newMap);
        }
        if(trigger.isupdate){
            SendProjectWonEmailTriggerHandler.sendAlertEmail(Trigger.newMap,Trigger.oldMap);    
        PBProjectNotesHistoryTrackingHandler.trackProjectNotesHistory(Trigger.newMap, Trigger.oldMap);
        }
    }
//CR 4582 Start
*/
}