/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* InspireProjectMasterTriggerHandler
* @description    This class is the master trigger handler for inspire1__Project__c.
* 				  All the logic related to this object's trigger should be called from here.
*                 REF: CR# 2695
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2022-01-05
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class InspireProjectMasterTriggerHandler extends TriggerHandler {

    public static Boolean skiptrigger = false;
    public static Boolean executeProjectTrigger = false;
    public static Boolean executeFillSummaryNotesDates = false;
    public static Boolean executeSendEmailProjectTrigger = false;
    public static Boolean executeUpdateProjectResourcesOnPSQ = false;
    public static Boolean fillProjectSummaryTriggerExecute = false; //Added by Varun - CR 1069
    public static Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();

    InspireProjectMasterTriggerService helperService = new InspireProjectMasterTriggerService();
    static {
        
        if(tsmap != null && !tsmap.isEmpty() 
            && tsmap.containsKey('Execute_Project_Trigger') 
            && tsmap.get('Execute_Project_Trigger') != null 
            && tsmap.get('Execute_Project_Trigger').Execute__c) {
            	
            executeProjectTrigger = true;          

            if( tsmap.containsKey('Execute_Fill_Summary_Notes_Dates') 
                && tsmap.get('Execute_Fill_Summary_Notes_Dates') != null 
                && tsmap.get('Execute_Fill_Summary_Notes_Dates').Execute__c ) {
                executeFillSummaryNotesDates = true;
            }

            if(tsmap.containsKey('Execute_UpdateProjectResourcesOnPSQ') 
                && tsmap.get('Execute_UpdateProjectResourcesOnPSQ') != null 
                && tsmap.get('Execute_UpdateProjectResourcesOnPSQ').Execute__c) {
                executeUpdateProjectResourcesOnPSQ = true;
            }

            if(tsmap.containsKey('Execute_SendEmail_Project_Trigger') 
                && tsmap.get('Execute_SendEmail_Project_Trigger') != null 
                && tsmap.get('Execute_SendEmail_Project_Trigger').Execute__c) {
                    executeSendEmailProjectTrigger = true;
            }
        }
    }

    public override void beforeInsert() {

        List<Inspire1__Project__c> newProjects = (List<Inspire1__Project__c>)Trigger.new;
        //List<Inspire1__Project__c> oldProjects = (List<Inspire1__Project__c>)Trigger.old;        //Commented as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130

        //System.debug('InspireProjectMasterTriggerHandler Before Insert  SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());

        ProjectOpportunityFieldUpdateHandler instance = ProjectOpportunityFieldUpdateHandler.getInstance();
        instance.updateOpportunityFields();

        if(executeProjectTrigger) {

            //CR# 688 Start - Update Action_Plan_Last_Modified__c if Action_Plan__c is Not Empty
            PlannerProjectTriggerHandler.FillActionPlanModifiedDate(null,newProjects,true);

            if(!fillProjectSummaryTriggerExecute && executeFillSummaryNotesDates) {
                // Added by Varun - CR 1069 - Update Project_Summary_Last_Modified__c with Current time if Management_Notes__c is updated and isNotNull
                PlannerProjectTriggerHandler.fillProjectSummaryLastModified(newProjects,null);
            }
        }      
        
        ProjectBeforInsertAccountExHandler.updateExtentison(newProjects, null);

        //CR 735
        ProjectBeforInsertAccountExHandler.updateRegionOnProject(newProjects);
        
        //System.debug('InspireProjectMasterTriggerHandler Before Insert CR 4582 SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());

        //CR# 4582 - START
        InspireProjectMasterTriggerHelper.updateProjectName(newProjects);
        InspireProjectMasterTriggerHelper.updateZIAZPAOnProjectCompletionOnInsert(newProjects);
        InspireProjectMasterTriggerHelper.setProjectStatusToPendingIfProjectManagerIsNull(newProjects);
        InspireProjectMasterTriggerHelper.updateProjectOwnerToProjectManager(newProjects);
        //CR# 4582 - END

       // System.debug('InspireProjectMasterTriggerHandler Before Insert  SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());

        InspireProjectMasterTriggerHelper.UpdateIsExtensionAllowed(newProjects);     //Added by Ayush Kangar as part of CR#4626
        PlannerProjectTriggerHandler.updateRiskAndEscalationLastUpdatedDate(newProjects,null);	//Added by Ayush Kangar as part of IBA-6050
    }
    
    public override void afterInsert() {
        
        Map<Id,Inspire1__Project__c> newProjectByProjectId = (Map<Id,Inspire1__Project__c>)Trigger.NewMap;
		List<Inspire1__Project__c> newProjects = (List<Inspire1__Project__c>)Trigger.new;

       // System.debug('InspireProjectMasterTriggerHandler After Insert  SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());

        ProjectAccountTeamNotificationHandler instance = ProjectAccountTeamNotificationHandler.getInstance();
        instance.setProjectList(Trigger.new);
        instance.handle();
        
        //CR# 43 && CR# 813
        if(executeProjectTrigger && TriggerUtility.isProjectCloneExecuted() == false) {
            new ProjectTriggerHandlerClone().MainEntry(Trigger.operationType, trigger.IsExecuting, trigger.new, trigger.newmap, trigger.old, trigger.oldmap);
        }
        //IBA-4192 Start
		helperService.createPSQAndProjectRecords(newProjectByProjectId); 
        //IBA-4192 Start
        
        //CR# 4582
        InspireProjectMasterTriggerHelper.sendAlertEmail(newProjectByProjectId);
		ProjectSendInternalPartnerHandoverEmail.sendEmailToAccountCSMAndOppOwner(newProjectByProjectId);
        //Added by Chetan Pednekar - IBA-1046 - Start
        PlannerProjectTriggerHandler.updateExecSummaryOnTask(newProjects, null);
        //Added by Chetan Pednekar - IBA-1046 - Start
        //System.debug('InspireProjectMasterTriggerHandler After Insert  SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
    }
    
    public override void beforeUpdate() {

        Map<Id, Inspire1__Project__c> newProjectMap = new Map<Id, Inspire1__Project__c>();
        Map<Id, Inspire1__Project__c> oldProjectMap = new Map<Id, Inspire1__Project__c>();

        //CR# 4582 - Start
        List<Inspire1__Project__c> newProjects = (List<Inspire1__Project__c>)Trigger.new;
        //List<Inspire1__Project__c> oldProjects = (List<Inspire1__Project__c>)Trigger.old;		//Commented as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        Map<Id,Inspire1__Project__c> newProjectByProjectId = (Map<Id,Inspire1__Project__c>)Trigger.newMap;
        Map<Id,Inspire1__Project__c> oldProjectByProjectId = (Map<Id,Inspire1__Project__c> )Trigger.oldMap;
        //CR# 4582 - END

       // System.debug('InspireProjectMasterTriggerHandler Before Update  SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());

         //CR# 688 - Update Action_Plan_Last_Modified__c with Current Time if Action_Plan__c has been updated
        if(executeProjectTrigger) {
           // System.debug('oldProjectByProjectId-->' +oldProjectByProjectId);
           // System.debug('newProjects-->' + newProjects);
            PlannerProjectTriggerHandler.FillActionPlanModifiedDate(oldProjectByProjectId, newProjects,false);    //SOQL-0
            
            //CR# 291 - Update Project_Completed_Time__c if Project Status has been Updated to 'Completed'
            PlannerProjectTriggerHandler.fillProjectCompletionDate(oldProjectByProjectId, newProjectByProjectId); //SOQL-0

            // Added by Varun - CR# 1069 - Update Project_Summary_Last_Modified__c with Current time if Management_Notes__c is updated and isNotNull
            if(!fillProjectSummaryTriggerExecute && executeFillSummaryNotesDates) {
                PlannerProjectTriggerHandler.fillProjectSummaryLastModified(newProjects,oldProjectByProjectId);     //SOQL-0
            }
            // Added by Varun - CR 1069 - End

            //Added by Ayush Kangar as part of CR#3541, updated for CR#3763
            //CR#3763 - If Project RecordType is updated to Deployment Project update Primary manager with Owner Id Else By Created User
            //Update Partner_Contact_Name__c and Partner_Deployment_Contact_Name__c with email if not null 
            PlannerProjectTriggerHandler.updateEmailFieldsForPartnerProject(newProjects, oldProjectByProjectId);
            //Added by Ankit Bhatnagar - IBA-191 - Start
            PlannerProjectTriggerHandler.updateExecSummaryOnTask(newProjects, oldProjectByProjectId);
            //Added by Ankit Bhatnagar - IBA-191 - Start
			PlannerProjectTriggerHandler.updateRiskAndEscalationLastUpdatedDate(newProjects,oldProjectByProjectId);	//Added by Ayush Kangar as part of IBA-6050
        }
        
        ProjectBeforInsertAccountExHandler.updateExtentison(newProjects, oldProjectByProjectId);
        
        /* 
         * Update At_Risk_Record_Opened_By__c (Record Opened By) when  At_Risk_Account_Required__c is true
         * Included in escalate Project to Save CPU time and an extra for loop
         */
             
        InspireProjectMasterTriggerHelper.escalateProject(oldProjectByProjectId,newProjectByProjectId);
        InspireProjectMasterTriggerHelper.updateDelayedDeploymentStartTime(oldProjectByProjectId,newProjectByProjectId);
        InspireProjectMasterTriggerHelper.updateZIAZPAOnProjectCompletionOnUpdate(newProjectByProjectId,oldProjectByProjectId);
        InspireProjectMasterTriggerHelper.setProjectStatusToPendingIfProjectManagerIsNull(newProjects);
        InspireProjectMasterTriggerHelper.updateProjectOwnerToProjectManager(newProjects);
        InspireProjectMasterTriggerHelper.updateProjectTypeToCreditIfPSOfferingIsPresent(oldProjectByProjectId,newProjectByProjectId);//CR 4884

        //IBA-5909-Bug due to Managed Packaged - EE field getting overwritten
        InspireProjectMasterTriggerService.checkEarlyEngagementsOnProject(oldProjectByProjectId,newProjectByProjectId);
        
        //CR# 4582-END

        for (SObject project: Trigger.new) {
            
            Inspire1__Project__c newProject = (Inspire1__Project__c) project;
            Inspire1__Project__c oldProject = (Inspire1__Project__c) Trigger.oldMap.get(project.Id);
                        
            if(!ManageRecursive.processedOpportunityIds.contains(newProject.Id) || qualifiedUpdate(newProject, oldProject)){
                newProjectMap.put(newProject.Id, newProject);
                oldProjectMap.put(oldProject.Id, oldProject);
            }            
        }

        ProjectOpportunityFieldUpdateHandler instance = ProjectOpportunityFieldUpdateHandler.getInstance();
        instance.updateOpportunityFields();       
        
       // System.debug('InspireProjectMasterTriggerHandler Before Update ENDS SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
    }
    
    public override void afterUpdate() {
        Map<Id, Inspire1__Project__c> newProjectMap = new Map<Id, Inspire1__Project__c>();
        Map<Id, Inspire1__Project__c> oldProjectMap = new Map<Id, Inspire1__Project__c>();
        
        //CR# 4582 - Start
        List<Inspire1__Project__c> newProjects = (List<Inspire1__Project__c>)Trigger.new;
        //List<Inspire1__Project__c> oldProjects = (List<Inspire1__Project__c>)Trigger.old;		//Commented as apperaing in Critical issues in Code Scan - IBA-6050 - SCA-02130
        Map<Id,Inspire1__Project__c> newProjectByProjectId = (Map<Id,Inspire1__Project__c>)Trigger.newMap;
        Map<Id,Inspire1__Project__c> oldProjectByProjectId = (Map<Id,Inspire1__Project__c> )Trigger.oldMap;
        //CR# 4582 - END

       // System.debug('InspireProjectMasterTriggerHandler After Update Starts SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());

        if(executeProjectTrigger) {
            
            if(TriggerUtility.isProjectCloneExecuted() == false) {
            	new ProjectTriggerHandlerClone().MainEntry(Trigger.operationType, trigger.IsExecuting, trigger.new, trigger.newmap, trigger.old, trigger.oldmap);
        	}
            
            /****Commented as part of IBA-4571
            // CR#2282 PS deployment project--Added by Chetan-Start
            if(executeUpdateProjectResourcesOnPSQ) {
                PlannerProjectTriggerHandler.updateProjectResourcesOnPSQ(oldProjectByProjectId, newProjects);
            }
			*******/
            
             //CR# 693 and CR# 736 - 
            if(executeSendEmailProjectTrigger && !TriggerUtility.isprojectFieldUpdateExecuted()) {
                PlannerProjectTriggerHandler.sendEmailNotification(oldProjectByProjectId,newProjects);
            }

            //CR# 666 - It creates more Project records.
            if(TriggerUtility.iscreateCSMProjectFromCompletedExecuted() == false) {
                PlannerProjectTriggerHandler.createCSMProject(oldProjectByProjectId, newProjectByProjectId);
            }
        }

        //CR# 4582 Start
        if(!skipTrigger) {
        	InspireProjectMasterTriggerHelper.trackProjectNotesHistory(newProjectByProjectId, oldProjectByProjectId); 
        	ProjectSendInternalPartnerHandoverEmail.sendEmailToAccountCSMAndOppOwner(oldProjectByProjectId,newProjectByProjectId);
        	InspireProjectMasterTriggerHelper.sendAlertEmail(oldProjectByProjectId,newProjectByProjectId);
            //CR# 5022 - Updated method name
            InspireProjectMasterTriggerHelper.sendEmailNotificationForProjectAtRiskOrEscalation(oldProjectByProjectId,newProjectByProjectId);//CR#4482
            if(executeProjectTrigger) {
                //CreateSurvey Record
            	PlannerProjectTriggerHandler.createSurvey(oldProjectByProjectId, newProjectByProjectId);
            }
    	}
        //CR# 4582 End

        for (SObject project: Trigger.new) {
            
            Inspire1__Project__c newProject = (Inspire1__Project__c) project;
            Inspire1__Project__c oldProject = (Inspire1__Project__c) Trigger.oldMap.get(project.Id);
                        
            if(!ManageRecursive.processedOpportunityIds.contains(newProject.Id) || qualifiedUpdate(newProject, oldProject)){
                newProjectMap.put(newProject.Id, newProject);
                oldProjectMap.put(oldProject.Id, oldProject);
                ManageRecursive.processedOpportunityIds.add(newProject.Id);
            }            
        }
		skiptrigger = true;
        //System.debug('InspireProjectMasterTriggerHandler After Update ENDS SOQLs: '+Limits.getQueries()+';DMLs: '+Limits.getDmlStatements()+ '; CPU: '+Limits.getCpuTime());
    }

    public override void afterDelete() {
		
        if(executeProjectTrigger && TriggerUtility.isProjectCloneExecuted() == false) {
        	new ProjectTriggerHandlerClone().MainEntry(Trigger.operationType, trigger.IsExecuting, trigger.new, trigger.newmap, trigger.old, trigger.oldmap);
        }        
    }
    
    
    public Boolean qualifiedUpdate(Inspire1__Project__c newProject, Inspire1__Project__c oldProject){
        
        Boolean valChanged = false;
        
        valChanged = (newProject.Opportunity__c != oldProject.Opportunity__c);
                
        return valChanged;
    }
    
}