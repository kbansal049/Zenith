public class InspireProjectMasterTriggerHelper {
    
    private static final Id RT_DEPLOYMENT_PROJECT_ID = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(ZScalarConstants.PROJECT_RT_DEPLOYMENT_PROJECT).getRecordTypeId();
    private static final List<Id> VALID_PROJECT_RECORDTYPE_IDS_FOR_OWNER_UPDATE = new List<Id> {
        Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(ZScalarConstants.PROJECT_RT_DEPLOYMENT_PROJECT).getRecordTypeId(),
            Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(ZScalarConstants.PROJECT_RT_ZCP_SPECIALIST_SERVICES).getRecordTypeId()
            };
                
    private static final String PROJECT_NOTES = 'Project Notes';
    private static final String ESCALATION_NOTES = 'Escalation Notes';
    private static final String DELAYED_DEPLOYMENT_NOTES = 'Delayed Deployment Notes'; 
    private static final String PROJECT_MANAGER_NAME = 'Generic PM';
    
    //WF - Fed Opt Closed Alert Email
    private static final String STAGE_CLOSED_WON = '6 - Closed Won';
    private static final List<String> VALID_DAS_PACKAGES_SUBSTRINGS = getListOfString((String)Opportunity_DAS_Package__mdt.getInstance('WF_Fed_Opt_Closed_Alert_Email').get('Valid_DAS_Packages__c'));
    
    private static  Email_Configuration__mdt emailConfig = Email_Configuration__mdt.getInstance('WF_Fed_Opt_Closed_Alert_Email');
    @TestVisible
    private static String FED_OPT_EMAILTEMPLATE_DEVELOPER_NAME = (String) emailConfig.get('Email_Template_Name__c');
    @TestVisible
    private static String SENDERS_EMAILID = (String) emailConfig.get('Senders_Email_Address__c');
    private static final List<String> ADDITIONAL_EMAIL_IDS = getListOfString((String) emailConfig.get('cc_Email_Addresses__c'));
    
    @TestVisible
    private static final String RECEIPIENT_NAME = getFirstElementOfList(getListOfString((String) emailConfig.get('Recipient_Names__c')));
    public static Boolean isFirstRun = true;
    
    private static final String PROJECT_TYPE_CREDIT = 'Credit';
    
    //WF - Fed Opt Closed Alert Email END
    
    /**
* CR# 4582
* Replaced WorkFlow - Sent New Project Created Notification 
* Updated Full_Project_Name__c field
*/    
    public static void updateProjectName(List<inspire1__Project__c> projects){
        updateProjectNameOnInsert(projects);
    }
    
    public static void updateProjectNameOnInsert(List<inspire1__Project__c> projects){
        for(inspire1__Project__c Ip : projects){
            if(Ip.RecordTypeId == RT_DEPLOYMENT_PROJECT_ID){
                if(String.ISBLANK(Ip.Full_Project_Name__c) || Ip.Full_Project_Name__c == Null){
                    Ip.Name = Ip.Name;
                }
                else{
                    Ip.Name = Ip.Full_Project_Name__c.mid(0,79);
                }
            }
        }
    }
    // Replaced WorkFlow - Sent New Project Created Notification ENDS
    
    //Replaced Workflow - ZIA-ZPA L31D at Completion Start
    public static void updateZIAZPAOnProjectCompletionOnInsert(List<inspire1__Project__c> projects) {
        updateZIAZPAFields(projects);
    }
    
    public static void updateZIAZPAOnProjectCompletionOnUpdate(Map<Id,inspire1__Project__c> newProjectByProjectId, Map<Id,inspire1__Project__c> oldProjectByProjectId) {
        
        List<inspire1__Project__c> projects = new List<inspire1__Project__c>();
        for(inspire1__Project__c newProject : newProjectByProjectId.values()) {
            if(isStatusUpdated(newProject.inspire1__Project_Status__c,oldProjectByProjectId.get(newProject.Id).inspire1__Project_Status__c)) {
                projects.add(newProject);
            }
        }
        updateZIAZPAFields(projects);
    }
    
    public static void updateZIAZPAFields(List<inspire1__Project__c> projectsZiazpa){
        for(inspire1__Project__c project : projectsZiazpa){
            if(isEligibleToUpdateZIAZPAFields(project)) {
                project.ZIA_L31D_at_Completion__c = project.ZIA_L31D__c;
                project.ZPA_L31D_at_Completion__c = project.ZPA_L31D__c;
            }
        }
    }
    
    private static Boolean isStatusUpdated(String newStatus, String oldStatus) {
        return newStatus != oldStatus;
    }
    
    private static Boolean isEligibleToUpdateZIAZPAFields(inspire1__Project__c project) {
        return  project.RecordTypeId == RT_DEPLOYMENT_PROJECT_ID 
            && project.inspire1__Project_Status__c != null
            && project.inspire1__Project_Status__c == ZScalarConstants.PROJECT_STATUS_COMPLETED;
    }
    //Replaced Workflow - ZIA-ZPA L31D at Completion ENDS
    
    //Replaced ProcessBuilder - Project Escalation Process
    public static void escalateProject(Map<id,inspire1__Project__c> oldProjectByProjectId, Map<id,inspire1__Project__c> newProjectByProjectId){
        if(newProjectByProjectId == null || newProjectByProjectId.isEmpty()) { return ;}
        
        for(inspire1__Project__c project : newProjectByProjectId.values()) {
            if(newProjectByProjectId.get(project.Id).Project_Escalation_Required__c && !oldProjectByProjectId.get(project.Id).Project_Escalation_Required__c){
                updateEscalationDetails(project);
                //updateEscalationOwner(project); Commented as part of IBA-2433 : Escalation Owner should be updated manually.
            }

            //CR# 5022 - START
            if(newProjectByProjectId.get(project.Id).At_Risk_Account_Required__c && !oldProjectByProjectId.get(project.Id).At_Risk_Account_Required__c){
                updateAtRiskFields(project);
            }
            //CR# 5022 - END
        }
    }
    
    private static void updateEscalationDetails(inspire1__Project__c project) {
        
        if(project.Escalation_Start_Time__c == null){
            
           //String projectOwnerId = project.OwnerId;
            project.Escalation_Start_Time__c = System.now();
            project.Escalated_By__c = userinfo.getuserid() ;
            project.Escalation_Stage__c = 'Open';  
        }
    }
    
    //Commented as part of IBA-2433 : Escalation Owner should be updated manually.
    //CR# 4822-Start - Process Builder Project Escalation 
    /*public static void updateEscalationOwner(inspire1__Project__c project){
        if(project.Defcon_Level__c == '5'){
            project.Escalation_Owner__c = project.Project_Manager__c;
        }
        else if(project.Defcon_Level__c == '4' || project.Defcon_Level__c == '3' || project.Defcon_Level__c == '2' || project.Defcon_Level__c == '1'){
            project.Escalation_Owner__c = '0050g0000065hSRAAY';
        }
    }*/ //IBA-2433 END

    //CR# 5022 - START
    private static void updateAtRiskFields(inspire1__Project__c project) {
        
        //String projectOwnerId = project.OwnerId;
        if(project.At_Risk_Date_Opened__c == null) {
            project.At_Risk_Record_Opened_By__c = userinfo.getuserid();
            project.At_Risk_Date_Opened__c = System.now();
        }    
    }
    //CR# 5022 - END
    
    /*
    * CR# 5022 - Updated the name of Method 
    * The method sends email if Project is At Risk Or If Project is Escalated
    */
    public static void sendEmailNotificationForProjectAtRiskOrEscalation(Map<id,inspire1__Project__c> oldProjectByProjectId, Map<id,inspire1__Project__c> newProjectByProjectId){
        if(newProjectByProjectId == null || newProjectByProjectId.isEmpty()) { return ;}
       
        //Start IBA-3598 : Federal Email Notification for At Risk/Escalation/Delayed Deployments 
       	
        Set<Id> fedProjectIds = getFedAccountByProjectId(newProjectByProjectId.KeySet());
       	
        List<inspire1__Project__c> fedEscalationEmailNotification = new List<inspire1__Project__c>();
        Set<Id> fedEscalatonAccountIds = new Set<Id>();
        Set<Id> fedEscalatonProjectIds = new Set<Id>();
        
        List<inspire1__Project__c> fedProjectsForAtRiskEmailNotification = new List<inspire1__Project__c>();
        Set<Id> fedAtRiskaccountIds = new Set<Id>();
        Set<Id> fedAtRiskprojectIds = new Set<Id>();
        
        // END IBA-3598 : Federal Email Notification for At Risk/Escalation/Delayed Deployments 
         
        List<inspire1__Project__c> projectsForDefconEmailNotification = new List<inspire1__Project__c>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();

        /*
        * CR# 5022- START 
        * Added Variables to store Project and Account Ids for Project At Risk
        */
        List<inspire1__Project__c> projectsForAtRiskEmailNotification = new List<inspire1__Project__c>();
        Set<Id> atRiskaccountIds = new Set<Id>();
        Set<Id> atRiskprojectIds = new Set<Id>();
        String emailConfigApiName = '';
        //CR# 5022- END

        //Iterate over projects
        for(inspire1__Project__c project : newProjectByProjectId.values()) {
            
            if(newProjectByProjectId.get(project.Id).Project_Escalation_Required__c && !oldProjectByProjectId.get(project.Id).Project_Escalation_Required__c){
                
                //IBA-3598 START : Fed Escalation Email Seperation
                if(fedProjectIds !=null && fedProjectIds.contains(project.Id)) {
                    fedEscalatonAccountIds.add(project.inspire1__Account__c);
                	fedEscalatonProjectIds.add(project.Id);
                	fedEscalationEmailNotification.add(project);
                
                }else {
                    //IBA-3598 END : Fed Escalation Email Seperation
                    //Non-Fed Escalation Email Seperation
                 	accountIds.add(project.inspire1__Account__c);
                	projectIds.add(project.Id);
                	projectsForDefconEmailNotification.add(project);
                   
                }
            }

            /*
            * CR# 5022- START 
            * Filtering Projects At Risk
            */
            
            if(newProjectByProjectId.get(project.Id).At_Risk_Account_Required__c && !oldProjectByProjectId.get(project.Id).At_Risk_Account_Required__c){
                
                //IBA-3598 START : Fed At risk Email Seperation
                if(fedProjectIds !=null && fedProjectIds.contains(project.Id)) {
                    fedAtRiskaccountIds.add(project.inspire1__Account__c);
                	fedAtRiskprojectIds.add(project.Id);
                	fedProjectsForAtRiskEmailNotification.add(project);
                
                }else { 
                    //IBA-3598 END
                    //Non-Fed At risk Email Seperation
                    atRiskaccountIds.add(project.inspire1__Account__c);
                    atRiskprojectIds.add(project.Id);
                    projectsForAtRiskEmailNotification.add(project);
                }
            }
            //CR# 5022 -END

        }

        if(isFirstRun) {
            
            if(!projectsForDefconEmailNotification.isEmpty()) {
                emailConfigApiName = 'PB_Project_Escalation_Defcon_Email';
                sendProjectEmailNotification(projectsForDefconEmailNotification,new List<Id>(accountIds),new List<Id>(projectIds),emailConfigApiName);
            }
            
            /*
            * CR# 5022- START 
            * Sending Email to users for Projects At Risk
            */
            if(!projectsForAtRiskEmailNotification.isEmpty()) {
                emailConfigApiName = 'Project_At_Risk_Notification_Email';
                sendProjectEmailNotification(projectsForAtRiskEmailNotification,new List<Id>(atRiskaccountIds),new List<Id>(atRiskprojectIds),emailConfigApiName);
            }
            
            //IBA-3598 START : Send Fed Emails
            if(!fedEscalationEmailNotification.isEmpty()) {
                emailConfigApiName = 'FED_PB_Project_Escalation_Defcon_Email';
                sendProjectEmailNotification(fedEscalationEmailNotification,new List<Id>(fedEscalatonAccountIds),new List<Id>(fedEscalatonProjectIds),emailConfigApiName);
            }
            
            if(!fedProjectsForAtRiskEmailNotification.isEmpty()) {
                emailConfigApiName = 'FED_Project_At_Risk_Notification_Email';
                sendProjectEmailNotification(fedProjectsForAtRiskEmailNotification,new List<Id>(fedAtRiskaccountIds),new List<Id>(fedAtRiskprojectIds),emailConfigApiName);
            }
            //IBA-3598 END : Send Fed Emails

            isFirstRun = false;
        }        
    }
    
    public static void sendProjectEmailNotification(
        List<inspire1__Project__c> projectsForDefconEmailNotification,
        List<Id> accountIds,
        List<Id> projectIds,
        String emailConfigApiName
    ) {        
        
        Email_Configuration__mdt emailConfiguration = Email_Configuration__mdt.getInstance(emailConfigApiName); //CR# 5022 change
        String PROJECT_TEMPLATE_DEVELOPER_NAME = (String) emailConfiguration.get('Email_Template_Name__c');
        String SENDERS_EMAILID = (String) emailConfiguration.get('Senders_Email_Address__c');
        String RECEIPIENT_NAME = getFirstElementOfList(getListOfString((String) emailConfiguration.get('Recipient_Names__c')));
        List<String> ccEmailAddresses = getListOfString((String) emailConfiguration.get('cc_Email_Addresses__c'));
        
        Id templateId = getEmailTemplateId(PROJECT_TEMPLATE_DEVELOPER_NAME);
        String defaultOWDSenderId = getSendersEmailId(SENDERS_EMAILID);
        String recipientEmailId = getRecipientsEmailAddress(RECEIPIENT_NAME);
         
        	// Commenting the line as part of IBA-2433
        //Map<Id,List<String>> accountTeamMemberEmailIdsByAccountId = getAccountTeamMemberEmailIdsByAccountId(accountIds);
        Map<Id,List<String>> projectMemberEmailIdsByProjectId = getProjectMemberEmailIdsByProjectId(projectIds);
        
        List<String> toAddresses = new List<String>();
        List<Messaging.SingleEmailMessage> mailsToBeSend = new List<Messaging.SingleEmailMessage>();
        
        for(inspire1__Project__c project: projectsForDefconEmailNotification) {
            
            if(String.isNotBlank(recipientEmailId)) {
             	toAddresses.add(recipientEmailId);   
            }
            // Commenting the line as part of IBA-2433
            /*if(accountTeamMemberEmailIdsByAccountId != null && accountTeamMemberEmailIdsByAccountId.size() > 0) {
                toAddresses.addAll(accountTeamMemberEmailIdsByAccountId.get(project.inspire1__Account__c));
            }*/ 
            if(projectMemberEmailIdsByProjectId != null && projectMemberEmailIdsByProjectId.size() > 0) {
               toAddresses.addAll(projectMemberEmailIdsByProjectId.get(project.Id));
            }
            
            Messaging.SingleEmailMessage mail = prepareEmail(templateId,defaultOWDSenderId,toAddresses,ccEmailAddresses,project.Id);
            mailsToBeSend.add(mail);
            toAddresses.clear();
        }
        
        sendEmails(mailsToBeSend);
        
    }
    
    // Commenting the line as part of IBA-2433
    /*private static Map<Id,List<String>> getAccountTeamMemberEmailIdsByAccountId(List<Id> accountIds) {
        
        Map<Id,List<String>> accountTeamMemberEmailIdsByAccountId = new Map<Id,List<String>>();
        List<String> ACCOUNT_TEAM_MEMBERS_TO_SENT_MAIL = new List<String>{
            'Sales Engineer', 
            'Account Owner',
            'Technical Account Manager',
            'Customer Success Manager',
            'Account Manager'
        };
        
        for(AccountTeamMember accTeamMember : [Select Id,AccountId,User.Email FROM AccountTeamMember WHERE AccountId IN:accountIds AND TeamMemberRole IN:ACCOUNT_TEAM_MEMBERS_TO_SENT_MAIL]) {
            if(accountTeamMemberEmailIdsByAccountId.containsKey(accTeamMember.AccountId)) {
               List<String> existingEmails = accountTeamMemberEmailIdsByAccountId.get(accTeamMember.AccountId);
                if(accTeamMember.User.Email != null && !existingEmails.contains(accTeamMember.User.Email)) {
                    existingEmails.add(accTeamMember.User.Email);
                    accountTeamMemberEmailIdsByAccountId.put(accTeamMember.AccountId,existingEmails);    
                }
                
            }else if(accTeamMember.User.Email != null){
                accountTeamMemberEmailIdsByAccountId.put(accTeamMember.AccountId,new List<String>{accTeamMember.User.Email});
            }
        }
        return accountTeamMemberEmailIdsByAccountId;
    }*/
    
    private static Map<Id,List<String>> getProjectMemberEmailIdsByProjectId(List<Id> projectIds) {
        
        Map<Id,List<String>> projectMemberEmailIdsByProjectId = new Map<Id,List<String>>();
        
        //Updated Query as part of IBA-2433
        for(inspire1__Project__c project : [Select Id,Primary_Deployment_Consultant__r.Email,Secondary_Deployment_Consultant__r.Email,Project_Manager__r.Email,
                                            Escalation_Owner__r.Email,
                                            inspire1__Account__r.CSM_Name_New__r.Email,
											inspire1__Account__r.TAM_Name_New__r.Email,
											inspire1__Account__r.Secondary_TAM_Name__r.Email,
                                            Opportunity__r.Owner.Email
                                            FROM inspire1__Project__c WHERE Id IN:projectIds ]) {
            
            Set<String> emailIds = new Set<String>();
            if(project.Primary_Deployment_Consultant__c != null && project.Primary_Deployment_Consultant__r.Email != null) {
               emailIds.add(project.Primary_Deployment_Consultant__r.Email); 
            }
            
            if(project.Secondary_Deployment_Consultant__c != null && project.Secondary_Deployment_Consultant__r.Email != null) {
               emailIds.add(project.Secondary_Deployment_Consultant__r.Email); 
            }
            if(project.Project_Manager__c != null && project.Project_Manager__r.Email != null) {
              emailIds.add(project.Project_Manager__r.Email); 
            }
                                                
			// Added as part of IBA-2433                                                
            /*if(project.Escalation_Owner__c != null && project.Escalation_Owner__r.Email != null) {
               emailIds.add(project.Escalation_Owner__r.Email); 
            }*/

			if(project.inspire1__Account__r.CSM_Name_New__c != null && project.inspire1__Account__r.CSM_Name_New__r.Email != null) {
               emailIds.add(project.inspire1__Account__r.CSM_Name_New__r.Email); 
            }
			if(project.inspire1__Account__r.TAM_Name_New__c != null && project.inspire1__Account__r.TAM_Name_New__r.Email != null) {
               emailIds.add(project.inspire1__Account__r.TAM_Name_New__r.Email); 
            }
			if(project.inspire1__Account__r.Secondary_TAM_Name__c != null && project.inspire1__Account__r.Secondary_TAM_Name__r.Email != null) {
               emailIds.add(project.inspire1__Account__r.Secondary_TAM_Name__r.Email); 
            }
			if(project.Opportunity__c != null && project.Opportunity__r.Owner.Email != null) {
               emailIds.add(project.Opportunity__r.Owner.Email); 
            }
			// IBA-2433 END
            if(!emailIds.isEmpty()) {
               projectMemberEmailIdsByProjectId.put(project.Id,new List<String>(emailIds)); 
            }
        }
        return projectMemberEmailIdsByProjectId;
    }
    //CR# 4822-Ends - Process Builder Project Escalation Process

    //Replaced ProcessBuilder - Project Escalation Process    
    
    //Workflow - Set Project Status to Pending if PM not assigned
    public static void setProjectStatusToPendingIfProjectManagerIsNull(List<inspire1__Project__c> newProjects) {
        setProjectStatusToPending(newProjects);
    }
    
    private static void setProjectStatusToPending (List<inspire1__Project__c> newProjects) {
        List<User> usersList = getUsersByName(new Set<String> {PROJECT_MANAGER_NAME});  
        
        for(inspire1__Project__c project : newProjects) {
            
            if(project.Project_Manager__c == null && project.RecordTypeId == RT_DEPLOYMENT_PROJECT_ID) {
                project.inspire1__Project_Status__c = 'Pending Assignment';
                
                if (Trigger.isInsert == true) {
                    project.Project_Manager__c = !usersList.isEmpty() ? usersList[0].Id : null;
                }
            }
        }

    }
    //Workflow - Set Project Status to Pending if PM not assigned ENDS
    
    // Process Builder -Update project ownership based on Project Owner
    public static void updateProjectOwnerToProjectManager(List<inspire1__Project__c> newProjects) {        
        
        for(inspire1__Project__c project : newProjects){
            if(isProjectManagerAndProjectOwnerSame(project)) {
                updateProjectOwner(project);  
            } 
        }
    }
    
    private static Boolean isProjectManagerAndProjectOwnerSame(inspire1__Project__c project) {
        return  project.Project_Manager__c != null 
            && project.Project_Manager__c != project.OwnerId 
            && VALID_PROJECT_RECORDTYPE_IDS_FOR_OWNER_UPDATE.contains(project.RecordTypeId);
    }
    
    private static void updateProjectOwner(inspire1__Project__c project) {
        project.OwnerId = project.Project_Manager__c;
        return; 
    }
    // Process Builder -Update project ownership based on Project Owner ENDS
    
    //CR#4582 - Replaced ProcessBuilder - Project Deployment Delayed Start
    public static void updateDelayedDeploymentStartTime(Map<id,inspire1__Project__c> oldProjectByProjectId, Map<id,inspire1__Project__c> newProjectByProjectId){
        if(newProjectByProjectId == null || newProjectByProjectId.isEmpty()) { return ;}
        
        for(inspire1__Project__c project : newProjectByProjectId.values()){
            
            if(newProjectByProjectId.get(project.Id).Delayed_Deployment__c && !oldProjectByProjectId.get(project.Id).Delayed_Deployment__c){
                //System.assert(false,'oldProjectByProjectId'+oldProjectByProjectId.get(project.Id).Delayed_Deployment__c+'newProjectByProjectId'+newProjectByProjectId.get(project.Id).Delayed_Deployment__c);
                updateDelayedDeploymentWithCurrentTime(project);
            }
        }
    }
    
    private static void updateDelayedDeploymentWithCurrentTime(inspire1__Project__c project) {
        
        if(project.Delayed_Deployment_Start_Time__c == null){
            project.Delayed_Deployment_Start_Time__c = System.now();
            project.Action_Plan_Owner__c = Userinfo.getuserid();
        }
    }
    //CR#4582 - Replaced ProcessBuilder - Project Deployment Delayed ENDS
    
	/* IBA-5150 START : Track history for At Risk and Escalation Plan/Next Steps Fields
     * Please add field in FieldSet : Project_History_Tracking_Fields to track the fields history
     * Add the field name And title of Project Notes on custom metadata :  Project_TrackFieldHistory__mdt
	*/

    //Process Builder - Project Notes History Tracking
    public static void trackProjectNotesHistory(map<Id,inspire1__Project__c> newProjectIdToProject,map<Id,inspire1__Project__c> oldProjectIdToProject){
        
        List<Project_Notes_History__c> projectNotes = new List<Project_Notes_History__c>();        
        
        Schema.DescribeSObjectResult describeSObject = inspire1__Project__c.sObjectType.getDescribe();
        Schema.FieldSet fieldSet = describeSObject.FieldSets.getMap().get(L2O_Constants.InspireProject.FIELDSET_PROJECT_HISTORY_TRACKING_FIELDS);
        
        Map<String,String> projectNoteHistoryTitleByProjectFieldName = new Map<String,String>();
        
        for(Project_TrackFieldHistory__mdt projectNotesMetadata : Project_TrackFieldHistory__mdt.getAll().values()){
            projectNoteHistoryTitleByProjectFieldName.put(projectNotesMetadata.FieldApiName__c,projectNotesMetadata.ProjectHistoryNoteTitle__c);
        }
        
        for(inspire1__Project__c project : newProjectIdToProject.values()) {
            
            inspire1__Project__c oldProject = oldProjectIdToProject.get(project.Id);
            Map<String,Object> newFieldValuebyFieldName = project.getPopulatedFieldsAsMap();
            Map<String,Object> oldFieldValuebyFieldName = oldProject.getPopulatedFieldsAsMap();
            
            for(Schema.FieldSetMember field : fieldSet.getFields()){
                
                String fieldPath = field.getFieldPath();
                if(newFieldValuebyFieldName.containsKey(fieldPath) || oldFieldValuebyFieldName.containsKey(fieldPath)){
                    
                    String oldValue = string.valueOf(oldFieldValuebyFieldName.get(fieldPath));
                    String newValue = string.valueOf(newFieldValuebyFieldName.get(fieldPath));
                    
                    if(isvalueChanged(newValue,oldValue)){
                        if(projectNoteHistoryTitleByProjectFieldName.containsKey(fieldPath)){
                            projectNotes.add(createProjectNotesHistory(projectNoteHistoryTitleByProjectFieldName.get(fieldPath),newValue,oldValue,project.Id));
                        }else{
                            projectNotes.add(createProjectNotesHistory('Note',newValue,oldValue,project.Id));
            }
                    }
            }
            
            }
        }
        //IBA-5150 END
        
        if(!projectNotes.isEmpty()){
            insert projectNotes;
        }
    }
    
    private static Boolean isValueChanged(String priorValue, String currentValue) {
        if(String.isBlank(currentValue) && String.isBlank(priorValue)) { return false;}
        return currentValue != priorValue ;
    }
    
    @TestVisible
    private static Project_Notes_History__c createProjectNotesHistory(String note, String newValue, String oldValue, Id projectId) {
        
        Project_Notes_History__c projectNote = new Project_Notes_History__c();
        projectNote.Field_Name__c = note;
        projectNote.New_Value__c = newValue;
        projectNote.Old_Value__c = String.isBlank(oldValue) ? '': oldValue ;
        projectNote.Project__c = projectId;
        
        return projectNote;
    }
    //Process Builder - Project Notes History Tracking ENDS
    
    // WF - Fed Opt Closed Alert Email
    //It should run Only when Account or Opportunity is updated.
    public static void sendAlertEmail(Map<Id,inspire1__Project__c> newProjectByProjectId, Map<Id,inspire1__Project__c> oldProjectByProjectId) {
        // System.debug('here-->');
        inspire1__Project__c oldProject = new inspire1__Project__c();
        Map<Id,inspire1__Project__c> projectByProjectId = new Map<Id,inspire1__Project__c>();
        for(inspire1__Project__c newProject : newProjectByProjectId.values()) {
            oldProject = oldProjectByProjectId.get(newProject.Id);
            if(newProject.inspire1__Account__c != oldProject.inspire1__Account__c || newProject.opportunity__c != oldProject.opportunity__c) {
                projectByProjectId.put(newProject.Id,newProject);
            }
        }
        sendAlertEmail(projectByProjectId);
    }
    
    public static void sendAlertEmail(Map<Id,inspire1__Project__c> projectByProjectId) {
        if(projectByProjectId == null || projectByProjectId.isEmpty()) {return;}
        //System.debug('sendAlertEmail-->');
        List<inspire1__Project__c> projectsWithStageClosedAndWon = getProjectsWithStageWonAndDASPackageNotNull(projectByProjectId.KeySet());
        //System.debug('projectsWithStageClosedAndWon>>>>'+projectsWithStageClosedAndWon);
        
        if(!projectsWithStageClosedAndWon.isEmpty() || Test.isRunningTest()) {
            Id templateId = getEmailTemplateId(FED_OPT_EMAILTEMPLATE_DEVELOPER_NAME);
            String defaultOWDSenderId = getSendersEmailId(SENDERS_EMAILID);
            String recipientEmailId = getRecipientsEmailAddress(RECEIPIENT_NAME);
            List<String> toAddresses = new List<String> {recipientEmailId}; 
                
                List<Messaging.SingleEmailMessage> mailsToBeSend = new List<Messaging.SingleEmailMessage>();
            if(!toAddresses.isEmpty()) {
                for(inspire1__Project__c project : projectsWithStageClosedAndWon) {
                    //System.debug('project.inspire1__Account__r.Name'+project.inspire1__Account__r.Name);
                    //System.debug('isSubStringPresent(project.opportunity__r.DAS_Package_New__c)'+isSubStringPresent(project.opportunity__r.DAS_Package_New__c));
                    if(project.inspire1__Account__r.Name.startsWith('A0')  && isSubStringPresent(project.opportunity__r.DAS_Package_New__c)) {
                        Messaging.SingleEmailMessage mail = prepareEmail(templateId,defaultOWDSenderId,toAddresses,ADDITIONAL_EMAIL_IDS,project.Id);
                        mailsToBeSend.add(mail);
                    }
                }
            }
            //System.debug('sendEmails-->'+mailsToBeSend);
            sendEmails(mailsToBeSend);     
        }
    }
    
    @TestVisible
    private static Messaging.SingleEmailMessage prepareEmail(Id templateId, Id defaultOWDSenderId,List<String>toEmailAddresses ,List<String> ccAddresses , Id projectId ) {
        
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(String.valueOf(templateId), Null, String.valueOf(projectId));
        mail.setToAddresses(toEmailAddresses);
        if(ccAddresses != null && ccAddresses.size() > 0) {
            mail.setCcAddresses(ccAddresses);   
        }
        mail.setOrgWideEmailAddressId(defaultOWDSenderId);
        mail.setTreatBodiesAsTemplate(True);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setsaveAsActivity(false);
        
        return mail;
    }
    
    private static List<inspire1__Project__c> getProjectsWithStageWonAndDASPackageNotNull(Set<Id> projectIds) {
        return [ SELECT Id,
                inspire1__Account__r.Name,
                opportunity__r.DAS_Package_New__c,
                opportunity__r.StageName
                FROM inspire1__Project__c 
                WHERE Id IN:projectIds
                AND opportunity__r.StageName = :STAGE_CLOSED_WON
                AND opportunity__r.DAS_Package_New__c != Null
                AND inspire1__Account__r.Name != Null
               ];
    }

    private static List<User> getUsersByName(Set<String> userNamesSet) {
        List<User> usersList = new List<User>();
        if (!userNamesSet.isEmpty()) {
            usersList = [SELECT Id FROM User WHERE Name IN :userNamesSet];
        }
        return usersList;
    }
    
    @TestVisible
    private static Boolean isSubStringPresent(String dasPackage) {
        for(String str : VALID_DAS_PACKAGES_SUBSTRINGS) {
            if(dasPackage.contains(str)) {
                return true;
            } 
        }
        return false;
    }
    
    private static Id getEmailTemplateId(String templateName) {
        return [SELECT Id,Subject,HtmlVAlue FROM EmailTemplate WHERE DeveloperName =: templateName].Id;
    }
    
    private static Id getSendersEmailId(String addressId) {
        return  [SELECT id, Address,IsAllowAllProfiles FROM OrgWideEmailAddress WHERE Address =: addressId].Id;
    }
    
    private static String getRecipientsEmailAddress(String username) {
        if(String.isNotBlank(username)) {
         	return [SELECT id,Email FROM User WHERE Name = :username LIMIT 1].Email;   
        }
        return '';
    }
    
    @TestVisible
    private static void sendEmails(List<Messaging.SingleEmailMessage> emailsToBeSend) {
        if(!emailsToBeSend.isEmpty()) {
            Messaging.sendEmail(emailsToBeSend);
        }
    }
    
    /*
* It will return a list<String> 
* Accepts a String seperated by a ';'
*/
    private static List<String> getListOfString(String str) {
        if(String.isBlank(str)) {return new List<String>(); } 
        return str.split(';');
    }
    
    private static String getFirstElementOfList(List<String> elements) {
        if(elements.isEmpty()) {return '';}
        return elements.get(0); 
    }
    
   //WF - Fed Opt Closed Alert Email ENDS
    //Added by Ayush Kangar as part of CR#4626 - Start
    public static void UpdateIsExtensionAllowed(List<inspire1__Project__c> newList){
        Set<String> allowedSKUs = new Set<String>();
        Boolean CheckTemplate = false;
        Set<String> templateIds = new Set<String>();
        String templateName;
        Map<Id,inspire1__Project__c> projectTemplates = new Map<Id,inspire1__Project__c> (
            [SELECT Id,Name FROM inspire1__Project__c WHERE inspire1__Template__c = true LIMIT 1000]);
        allowedSKUs.addAll(Label.SKUs_allowed_for_PS_Extension.split(','));
        for(inspire1__Project__c project : newList){
            if(project.Deployment_Package__c != null){
                List<String> SKUlst = project.Deployment_Package__c.split(',');
                for(String SKU: SKUlst){
                    CheckTemplate = allowedSKUs.contains(SKU);
                    if(CheckTemplate==false){
                        project.Rejected_SKU__c = SKU;
                        break;
                    }
                }
            }
            
            if(CheckTemplate==false){
                templateName = projectTemplates?.get(project.inspire1__Project_Template__c)?.Name.toLowercase();
                if(templateName!=null && (
                    (templateName.contains('advanced') || templateName.contains('enterprise') || templateName.contains('credit')|| templateName.contains('advance'))
                    &&(!templateName.contains('federal') && !templateName.contains('optimize') && !templateName.contains('opt'))
                )){
                    project.Is_Extension_Allowed__c = true;
                }else if(templateName==null){
                    project.Is_Extension_Allowed__c = false;
                }
            }else{
                project.Is_Extension_Allowed__c = true;
            }
        }
    }
    //Added by Ayush Kangar as part of CR#4626 - End
    
    //CR 4884 Start- Update Project Type to Credit
    public static void updateProjectTypeToCreditIfPSOfferingIsPresent(Map<Id,inspire1__Project__c> oldProjectById, Map<Id,inspire1__Project__c> newProjectById) {
        
        for(inspire1__Project__c project: newProjectById.values()) {
            
            inspire1__Project__c oldProject = oldProjectById.get(project.Id);
            if(project.RecordTypeId == RT_DEPLOYMENT_PROJECT_ID && project.PS_Offering__c != null 
               && oldProject.Project_Type__c != project.Project_Type__c && project.Project_Type__c != PROJECT_TYPE_CREDIT ) {
                project.Project_Type__c = PROJECT_TYPE_CREDIT;
            }
        }
    }
    //CR 4884 END - Update Project Type to Credit
   
    /**
     * IBA-3598 START : It will return Set of Project Ids
     * Having Account with Is_Federal_Account_Sync__c to true
	*/
    public static Set<Id> getFedAccountByProjectId(Set<Id> projectIds) {
        
        Map<id,inspire1__Project__c> projectByprojectId = new Map<id,inspire1__Project__c>( [SELECT Id
                                         FROM inspire1__Project__c 
                                         WHERE Id IN:projectIds
                                         AND inspire1__Account__c != null
										 AND inspire1__Account__r.Is_Federal_Account_Sync__c = true
										]);
        
        if(projectByprojectId == null || projectByprojectId.size() <=0) {return new Set<Id>();} 
        
        return projectByprojectId.keySet();
    }
    
    //IBA-3598 END 
}