/*****************************************************************************************
Name: CreateDeploymentProjectBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex to Create Deployment Project Batch.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Sachin Tandon        25/10/2022      CR#2737 New Project Creation.
******************************************************************************************/

global class CreateDeploymentProjectBatch implements Database.batchable<sObject>, Database.Stateful, Schedulable {
        
    private String query = null;
    public String exceptionErrorMsg = '';
    public Exception exceptionInCreation;
    public String className = 'CreateDeploymentProjectBatch';
    
    ZscalerBatchFramework zb = new ZscalerBatchFramework(className);

    List<Opportunity_Extension__c> newOpportunityExtensionList = new List<Opportunity_Extension__c>();
    
    //The Sets collects Opp.Product SKU and Sub Region Used to get Metadata
    Set<String> opportunityProductSKUs = new Set<String>();
    Set<String> opportunitiesSubRegion = new Set<String>();

    //Maps store the value of custom Metadata
    Map<String,Id> projectTemplateIdByTemplateSKU = new Map<String,Id>();
    Map<String,List<Project_Geo_Mapping__mdt>> projectGeoMapping = new Map<String,List<Project_Geo_Mapping__mdt>>();
    Map<Id,inspire1__Project__c> projectByTemplateId = new Map<Id,inspire1__Project__c>();


    //The Map is used in finally to filter out failed opportunity and send Emails
    Map<Id,List<OpportunityLineItem>> opportunityLineItemsByOpportunityId = new Map<Id,List<OpportunityLineItem>>();
    Map<Id,List<inspire1__Project__c>> projectsByOpportunityId = new Map<Id,List<inspire1__Project__c>>();

    global CreateDeploymentProjectBatch(String oppExtQuery){
        if(oppExtQuery != null){
            query = oppExtQuery;
        }
    }
    
    global CreateDeploymentProjectBatch(){

    }
    
    global database.QueryLocator start(Database.BatchableContext info){
        this.zb.callStart();
        String projectCreationStatus = L2O_Constants.OpportunityExtensionObject.PROJECT_CREATION_STATUS_PENDING;
        if(this.query == null){
            query = 'SELECT id ,name,Project_Creation_Failure_Reason__c,Project_Creation_Status__c,Opportunity__c FROM Opportunity_Extension__c WHERE Project_Creation_Status__c=:projectCreationStatus ';
        }
        return Database.getQueryLocator(query); 
    }     
    
    global void execute(Database.BatchableContext info, List<Opportunity_Extension__c> newOpportunityExtensions){

        try {
            newOpportunityExtensionList.addAll(newOpportunityExtensions);
            this.zb.callExecute(newOpportunityExtensions[0]?.Id, newOpportunityExtensions.size());
            this.createDeploymentProjectsAndJunctionRecords(newOpportunityExtensions);
            
        }catch(Exception e) {
            exceptionInCreation = e;
            exceptionErrorMsg = e.getStackTraceString()+' ' + e.getMessage() +' '+ e.getCause()+' at line : '+e.getLineNumber();
        }
    }      
    
    global void finish(Database.BatchableContext info){
     
        Set<Id> failedOpportunityIds = CreateDeploymentProjectBatchHelper.getOpportunityIdsFailedProjectCreation(newOpportunityExtensionList);
        exceptionErrorMsg =  String.isNotBlank(exceptionErrorMsg) ? exceptionErrorMsg : 'Project Creation failed';
        
        this.zb.callFinish(info);
        
        if(failedOpportunityIds != null && !failedOpportunityIds.isEmpty()) {
            CreateDeploymentProjectBatchHelper.insertDebugLogs(failedOpportunityIds,exceptionInCreation);
            CreateDeploymentProjectBatchHelper.notifyUsersOfError(failedOpportunityIds,exceptionErrorMsg);
        }
    }

    private void createDeploymentProjectsAndJunctionRecords(List<Opportunity_Extension__c> newOpportunityExtensions) {
        
        Map<Id,Opportunity_Extension__c> opportunityExtensionByOpportunityId = CreateDeploymentProjectBatchHelper.getOpportunityExtensionByOpportunityIdpportunityId(newOpportunityExtensions);
        Map<Id,List<String>> deployemntProjectSKUsByOpportunityId = OpportunityTriggerHelperService.getDeployemntProjectSKUsByOpportunityId(opportunityExtensionByOpportunityId.keySet());
        
        List<OpportunityLineItem> opportunityLineItems = CreateDeploymentProjectBatchHelper.getOpportunityLineItems(opportunityExtensionByOpportunityId.keySet());
        opportunityLineItemsByOpportunityId = this.getOpportunityLineItemsByOpportunityId(opportunityLineItems);
        Map<Id,List<String>> opportunitySKUsByOpportunityId = CreateDeploymentProjectBatchHelper.getOpportunitySKUsByOpportunityId(opportunityLineItemsByOpportunityId);
        
        newOpportunityExtensions = OpportunityTriggerHelperService.getOpportunityExtensionsToBeUpdated(deployemntProjectSKUsByOpportunityId,newOpportunityExtensions, opportunitySKUsByOpportunityId);
        Map<Id,List<OpportunityLineItem>> opportunityLineItemsForProjectCreationByOpportunityId = CreateDeploymentProjectBatchHelper.getOpportunitiesWithDeploymentSKU(opportunityLineItemsByOpportunityId, deployemntProjectSKUsByOpportunityId);
        
        Map<Id,List<Inspire1__Project__c>> projectsByOppId = new Map<Id,List<Inspire1__Project__c>>();
        try {
            projectsByOppId = insertDeploymentProjects(opportunityLineItemsForProjectCreationByOpportunityId);
        }catch(Exception e) {
            exceptionInCreation = e;
            exceptionErrorMsg = e.getStackTraceString()+' ' + e.getMessage() +' '+ e.getCause()+' at line : '+e.getLineNumber();
        }
        
        newOpportunityExtensions = CreateDeploymentProjectBatchHelper.updateOppExtensionStatus(newOpportunityExtensions,projectsByOppId,opportunityLineItemsForProjectCreationByOpportunityId);
        this.createProjectAndPSQuestionnaireJunctionRecords();

        updateOpportunityExtensions(newOpportunityExtensions,exceptionErrorMsg);

    }

    public Map<Id,List<OpportunityLineItem>> getOpportunityLineItemsByOpportunityId(List<OpportunityLineItem> opportunityLineItems) {

        Map<Id,List<OpportunityLineItem>> opportunityLineItemsByOpportunityId = new Map<Id,List<OpportunityLineItem>>();
        for (OpportunityLineItem opportunityProduct : opportunityLineItems
            ){
                if(opportunityLineItemsByOpportunityId.containsKey(opportunityProduct.OpportunityId)) {
                    List<OpportunityLineItem> existingOpportunityProducts = opportunityLineItemsByOpportunityId.get(opportunityProduct.OpportunityId);
                    existingOpportunityProducts.add(opportunityProduct);
                    opportunityLineItemsByOpportunityId.put(opportunityProduct.OpportunityId,existingOpportunityProducts);
                }else {
                    opportunityLineItemsByOpportunityId.put(opportunityProduct.OpportunityId,new List<OpportunityLineItem>{ opportunityProduct});
                }
                
                opportunityProductSKUs.add(opportunityProduct.ProductCode);
                opportunitiesSubRegion.add(opportunityProduct.Opportunity.District_Account__c);
            }

        return opportunityLineItemsByOpportunityId;
    }

    /**
     * @description : This method creates deployment projects on Onpoortunity
     */
    public Map<Id,List<Inspire1__Project__c>> insertDeploymentProjects(Map<Id,List<OpportunityLineItem>> opportunityLineItemsByOpportunityId) {        
        
        List<inspire1__Project__c> projectsToBeInserted = new List<inspire1__Project__c>();          
        projectsToBeInserted = getDeploymentProjectsToBeInserted(opportunityLineItemsByOpportunityId);
        if(projectsToBeInserted.isEmpty()) {return null;}

        Map<Id,List<Inspire1__Project__c>> projectsByOppId = getNewlyCreatedProjectIds(projectsToBeInserted); 
        projectsByOpportunityId.putAll(projectsByOppId);
        
        return projectsByOppId;
    }

    private List<inspire1__Project__c> getDeploymentProjectsToBeInserted( Map<Id,List<OpportunityLineItem>> opportunityLineItemsByOpportunityId ) {

        setProjectTemplateIdByTemplateSKU();
        setProjectGeoMapping();
        getProjectByProjectTemplateId();

        List<inspire1__Project__c> projectsToBeInserted = new List<inspire1__Project__c>();
        for (Id oppId : opportunityLineItemsByOpportunityId.keySet()) {
            
            List<OpportunityLineItem> opportunityProducts = opportunityLineItemsByOpportunityId.get(oppId);
            for(OpportunityLineItem opportunityProduct : opportunityProducts) {
                projectsToBeInserted.add(this.createDeployementProject(opportunityProduct));
            }
        }
        
        return projectsToBeInserted;
    }

    private Map<Id,List<inspire1__Project__c>> getNewlyCreatedProjectIds(List<inspire1__Project__c> projectsToBeInserted) {
        
        List<Id> projectIds = new List<Id>();
        if(!system.isQueueable() && Limits.getQueueableJobs() != Limits.getLimitQueueableJobs()) {
          
            Database.SaveResult[] insertedRecords = Database.insert(projectsToBeInserted, false);
            for (Database.SaveResult insertedRecord : insertedRecords) {                
                if (insertedRecord.isSuccess()) {
                    projectIds.add(insertedRecord.getId());
                }else {
                    for(Database.Error err : insertedRecord.getErrors()) {
                        exceptionErrorMsg = err.getStatusCode() + ': ' + err.getMessage() + 'Fields: '+ err.getFields();                 
                    }
                }
            }
        }        
        return getDeploymentProjectIds(projectIds);
    }

    private Map<Id,List<inspire1__Project__c>> getDeploymentProjectIds(List<Id> projectIds) {
        Map<Id,List<inspire1__Project__c>> projectIdByOpportunityId = new Map<Id,List<inspire1__Project__c>>();
        if(!projectIds.isEmpty()) {
            for(inspire1__Project__c project : [SELECT Id,Opportunity__c,Deployment_Package__c,inspire1__Account__c,inspire1__Project_Template__c,Template_ID__c from inspire1__Project__c where Id IN :projectIds ]) {
                
                project.inspire1__Project_Template__c = project.Template_ID__c;
                
                if(!projectIdByOpportunityId.containsKey(project.Opportunity__c)) {
                    projectIdByOpportunityId.put(project.Opportunity__c,new List<inspire1__Project__c>{});
                }
                projectIdByOpportunityId.get(project.Opportunity__c).add(project);
            }
        }
        return projectIdByOpportunityId;
    }    
    
    private inspire1__Project__c createDeployementProject(OpportunityLineItem opportunityProduct) {
        
        inspire1__Project__c project = new inspire1__Project__c();
        project.RecordTypeId = L2O_Constants.InspireProject.RT_DEPLOYMENT_PROJECT_ID;
        project.inspire1__Project_Status__c = 'Pending Assignment';
        project.Project_Type__c = 'Deployment';
        
        project.inspire1__Account__c = opportunityProduct.opportunity.AccountId;
        project.CSM_User__c = opportunityProduct.Opportunity.Account.CSM_Name_New__c;
        
        project.Opportunity__c = opportunityProduct.OpportunityId;
        project.Opportunity_Stage__c = opportunityProduct.Opportunity.StageName;
        project.Opportunity_Close_Date__c = opportunityProduct.Opportunity.CloseDate;
        project.Netsuite_Sales_Order__c = opportunityProduct.opportunity.Netsuite_Sales_Order_Number__c;
        
        //Geo field
        project.Region__c = getProjectGeo(opportunityProduct);
        project.Deployment_Start_Date__c = opportunityProduct.QLI_Start_Date__c;
        project.Deployment_Expiration_Date__c = opportunityProduct.QLI_End_Date__c;
        project.inspire1__sysOverrideDuplicateMergeValidation__c = true;
        
        project.Deployment_Package__c = opportunityProduct.ProductCode;
        
        /*if(opportunityProduct.Quantity != null) {
            project.Billable_Blocks__c = String.valueOf((Integer)opportunityProduct.Quantity);
        } */      
        
        String oppName = opportunityProduct.Opportunity.Name ;
        project.Full_Project_Name__c = getProjectName(oppName,opportunityProduct.ProductCode);
        
        Id templateId = getProjectTemplateId(opportunityProduct.ProductCode);
        if(templateId != null) {
           	
            inspire1__Project__c templateProject = getTemplateProject(templateId);
            project.Template_ID__c = templateProject != null ? templateProject.Id : null;
        	project.Primary_Deployment_Consultant__c = templateProject != null ? templateProject.Primary_Deployment_Consultant__c : UserInfo.getUserId();
        	project.Project_Manager__c = templateProject != null ? templateProject.Project_Manager__c : UserInfo.getUserId();
        }
        return project;
    }

    public void setProjectTemplateIdByTemplateSKU() {
        
        for(Project_Template_Ids_By_SKU__mdt templateBySKU : [  SELECT   SKU_Name__c,
                                                                        TemplateId__c 
                                                                FROM    Project_Template_Ids_By_SKU__mdt
                                                                WHERE SKU_Name__c IN :opportunityProductSKUs ]) {
            
            projectTemplateIdByTemplateSKU.put(templateBySKU.SKU_Name__c,templateBySKU.TemplateId__c);
        }        
    }

    public void setProjectGeoMapping() {
        
        for(Project_Geo_Mapping__mdt projectGeo : [  SELECT  Is_Federal_Opportunity_Sync__c,
                                                                Project_Geo__c,
                                                                Opportunity_Sub_Region__c 
                                                        FROM  Project_Geo_Mapping__mdt
                                                        WHERE Opportunity_Sub_Region__c IN :opportunitiesSubRegion ]) {
            
            if(!projectGeoMapping.containsKey(projectGeo.Opportunity_Sub_Region__c)) {
                projectGeoMapping.put(projectGeo.Opportunity_Sub_Region__c,new List<Project_Geo_Mapping__mdt>{});
            }
            projectGeoMapping.get(projectGeo.Opportunity_Sub_Region__c).add(projectGeo);
        }
    }

    public void getProjectByProjectTemplateId() {
                
        if(projectTemplateIdByTemplateSKU != null) {
            List<Id> projectIds = projectTemplateIdByTemplateSKU.values();
            for(inspire1__Project__c project :[SELECT Id,Primary_Deployment_Consultant__c,Project_Manager__c
                                               FROM inspire1__Project__c WHERE Id IN :projectIds]) {
                projectByTemplateId.put(project.Id,project);
            }
        }
    }

    public Id getProjectTemplateId(String sku) {
        if(projectTemplateIdByTemplateSKU.containsKey(sku)) {
            return projectTemplateIdByTemplateSKU.get(sku);
        }
        
        return null;
    }

    public String getProjectName(String oppName, String sku) {
        
        String projectName = String.isNotBlank(oppName) ? (oppName.length() > 20 ? oppName.substring(0,20) : oppName) : ''  ;
        projectName = projectName + ' - ' +(String.isNotBlank(sku) ? sku : '');
        return projectName.length() > 80 ? projectName.substring(0,80) : projectName;
    }
    
    public inspire1__Project__C getTemplateProject(Id templateId) {
        return projectByTemplateId.containsKey(templateId) ? projectByTemplateId.get(templateId) : null;
    }
    
    public String getProjectGeo(OpportunityLineItem lineItem) {
        if(!projectGeoMapping.isEmpty() && projectGeoMapping.containsKey(lineItem.opportunity.District_Account__c)) {
        	List<Project_Geo_Mapping__mdt> datas = projectGeoMapping.get(lineItem.opportunity.District_Account__c);
            if(!datas.isEmpty()) {
                if( datas.size() >=1) {
                    for(Project_Geo_Mapping__mdt data : datas) {
                        if(data.Is_Federal_Opportunity_Sync__c ==  lineItem.Opportunity.Is_Federal_Opportunity_Sync__c) {
                            return data.Project_Geo__c;
                        }
                    }
                }else {
                    return datas[0].Project_Geo__c;
                }
            }    
        }
        
        return '';                                           
    }


    /**
     * @description createProjectAndPSQuestionnaireJunctionRecords - Creation of Project and PS Questionnaires Junction records
     * @param  projectsByOpportunityId             Map<Id,List<inspire1__Project__c>> 
     * @param  opportunityLineItemsByOpportunityId Map<Id,List<OpportunityLineItem>>
     */
    private void createProjectAndPSQuestionnaireJunctionRecords() {
        
        Map<Id,List<Id>> psQuestionnairesToBeMappedByOpportunityId = getPSQuestionnaireOnOpportunity(opportunityLineItemsByOpportunityId);
        createProjectPSQuestionnairesRecords(psQuestionnairesToBeMappedByOpportunityId );
    }
    
    private void createProjectPSQuestionnairesRecords( 
        Map<Id,List<Id>> psQuestionnairesToBeMappedByOpportunityId
    ) {        
        List<Projects_PS_Questionnaire_Junction__c> junctionRecords = new List<Projects_PS_Questionnaire_Junction__c>();
        
        if(psQuestionnairesToBeMappedByOpportunityId != null) {
            for(Id oppId : projectsByOpportunityId.keySet()) {
                List<inspire1__Project__c> projects = projectsByOpportunityId.get(oppId);
                for(inspire1__Project__c project : projects) {
                    
                    if(psQuestionnairesToBeMappedByOpportunityId.containsKey(oppId)) {
                        for(Id psQuestionnaireId : psQuestionnairesToBeMappedByOpportunityId.get(oppId)) {
                            junctionRecords.add(createJunctionRecord(project,psQuestionnaireId));
                        }
                    }
                }
            }   
        }
        if(!junctionRecords.isEmpty()) {
         	Database.insert(junctionRecords);   
        }
    }
    
    /**
	Create Project and PS Questionnaire Junction object Records
	*/
    @TestVisible
    private Projects_PS_Questionnaire_Junction__c createJunctionRecord(inspire1__Project__c project, Id psQuestionnaireId) {
        Projects_PS_Questionnaire_Junction__c junction = new Projects_PS_Questionnaire_Junction__c();
        junction.project__c = project.Id;
        junction.opportunity__c = project.Opportunity__c;
        junction.Account__c = project.inspire1__Account__c;
        if(psQuestionnaireId != null) {
            junction.PS_Questionnaire__c = psQuestionnaireId;
        }
        return junction;
    }
    

    private Map<Id,List<Id>> getPSQuestionnaireOnOpportunity(Map<Id,List<OpportunityLineItem>> opportunityLineItemsByOpportunityId) {
        
        return getpsQuestionnaireIdsByOpportunityId(opportunityLineItemsByOpportunityId.KeySet());
        
    }
    
    private Map<Id,List<Id>> getpsQuestionnaireIdsByOpportunityId(Set<Id> opportunityIds) {
        
        Map<Id,List<Id>> psQuestionnairesByOpportunityId = new Map<Id,List<Id>>();
        for(PS_Questionnaire__c ps : [SELECT Id,opportunity__c FROM PS_Questionnaire__c 
                                      WHERE recordType.DeveloperName != 'ZPA' AND recordtype.DeveloperName != 'ZIA' AND   //Updated by Ayush as part of IBA-6048
                                      opportunity__c IN :opportunityIds]){
                                          
            if(!psQuestionnairesByOpportunityId.containsKey(ps.opportunity__c)) {
                psQuestionnairesByOpportunityId.put(ps.opportunity__c,new List<Id>());   
            }                                          
            psQuestionnairesByOpportunityId.get(ps.opportunity__c).add(ps.Id);                                       
        }
        return psQuestionnairesByOpportunityId;
    }

    /**
     * updateOpportunityExtensions : to update the exception message on extension
     */
    private void updateOpportunityExtensions(List<Opportunity_Extension__c> newOpportunityExtensionList,String exceptionMsg) {
        List<Opportunity_Extension__c> opportunityExtenList = new List<Opportunity_Extension__c>();
        for(Opportunity_Extension__c opExt  : newOpportunityExtensionList){
            if(opExt.Project_Creation_Status__c == L2O_Constants.OpportunityExtensionObject.PROJECT_CREATION_STATUS_FAILED){
                opExt.Project_Creation_Failure_Reason__c = opExt.Project_Creation_Failure_Reason__c + exceptionMsg;
            }
            opportunityExtenList.add(opExt);
        }
            
        DMLManager.updateAsSystem(opportunityExtenList, className);
    }
  
    /**
     * @description This is execute method to execute the batch from scheduler interface.
     */
    global void execute(SchedulableContext sc) {
        CreateDeploymentProjectBatch deploymentProjectCreationBatch = new CreateDeploymentProjectBatch(); 
        Database.executeBatch(deploymentProjectCreationBatch);
    }

    /**
     * @description This is an Exception class for the batch
     */
    public Class CreateDeploymentProjectException extends Exception {

    }	
}