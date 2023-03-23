/*****************************************************************************************
Name: InspireProjectMasterTriggerService
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex trigger helper for inspire1__Project__c
2. It is being called by InspireProjectMasterTriggerHandler.
3. Please make all the methods non static and call them from InspireProjectMasterTriggerHandler.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Sachin Tandon        23/11/2022      IBA-4192      PS Questionnaire Revamp Project
******************************************************************************************/ 

public class InspireProjectMasterTriggerService {

    private static final Id RT_DEPLOYMENT_PROJECT_ID = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get('Deployment_Project').getRecordTypeId();
    private static final List<String> OPP_STAGES_EXCLUDE_EE_UPDATE = new List<String>{
        L2O_Constants.OpportunityObject.STAGE_CLOSED_WON,
        L2O_Constants.OpportunityObject.STAGE_CLOSED_LOST
    };
    //IBA-4192 : START 
    public void createPSQAndProjectRecords(Map<Id,inspire1__Project__c> projects){
        
        Map<Id,List<inspire1__Project__c>> projectsByOpportunityId = getProjectIdsByOpportunityId(projects.values());
        if(projectsByOpportunityId == null || projectsByOpportunityId.isEmpty()) {
            return;
        }
        
        Map<Id,List<Id>> psqIdsByOpportunityId = getPSQIdsByOpportunityId(projectsByOpportunityId.keySet());
        if(psqIdsByOpportunityId == null || psqIdsByOpportunityId.isEmpty()) {
            return;
        }
        
        insertJunctionObjectRecords(projectsByOpportunityId,psqIdsByOpportunityId);
    }
    
    private Map<Id,List<inspire1__Project__c>> getProjectIdsByOpportunityId(List<inspire1__Project__c> projects) {
        
        Map<Id,List<inspire1__Project__c>> projectsByOpportunityId = new Map<Id,List<inspire1__Project__c>>();
        
        for(inspire1__Project__c project : projects){
           if( isValidProject(project)){
                if(!projectsByOpportunityId.containsKey(project.Opportunity__c)) {
                 	projectsByOpportunityId.put(project.Opportunity__c,new List<inspire1__Project__c>());   
                }
                projectsByOpportunityId.get(project.Opportunity__c).add(project);
           }
        }
        
        return projectsByOpportunityId;   
    }
    
    private Map<Id,List<Id>> getPSQIdsByOpportunityId(Set<Id> opportunityIds) {
        
        Map<Id,List<Id>> psqIdsByOpportunityId = new Map<Id,List<Id>>();
        for(PS_Questionnaire__c psQuestionnaire : [SELECT Id,Opportunity__c
                                         	FROM PS_Questionnaire__c 
                                         	WHERE recordType.DeveloperName != 'ZPA' AND recordtype.DeveloperName != 'ZIA' AND		//Updated by Ayush as part of IBA-6048
                                            Opportunity__c IN : opportunityIds
        	]){
                if(!psqIdsByOpportunityId.containsKey(psQuestionnaire.Opportunity__c)) {
                 	psqIdsByOpportunityId.put(psQuestionnaire.Opportunity__c,new List<Id>());   
                }
                psqIdsByOpportunityId.get(psQuestionnaire.Opportunity__c).add(psQuestionnaire.Id);
        }
        
        return psqIdsByOpportunityId;
    }
    
   public void insertJunctionObjectRecords(Map<Id,List<inspire1__Project__c>> projectsByOpportunityId, Map<Id,List<Id>> psqIdsByOpportunityId) {
        
        List<Projects_PS_Questionnaire_Junction__c> junctionRecords = new List<Projects_PS_Questionnaire_Junction__c>();
        for(Id oppId : projectsByOpportunityId.keySet()) {
            junctionRecords.addAll(createJunctionRecords(psqIdsByOpportunityId.get(oppId),projectsByOpportunityId.get(oppId),oppId));
             
        }
        
       if(!junctionRecords.isEmpty()){
           Database.SaveResult[] srList = Database.insert(junctionRecords, false);
           for (Database.SaveResult sr : srList) {
               if (!sr.isSuccess()) {
                   for(Database.Error err : sr.getErrors()) {
                       ZscalerErrorLogsUtility.insertLogs('InspireProjectMasterTriggerService', 'insertJunctionObjectRecords', 'Apex',userInfo.getUserId(),'Sales cloud', err.getMessage(), err.getMessage(),err.getMessage());
                   }
               }
           }
       }
    }
    
    public List<Projects_PS_Questionnaire_Junction__c> createJunctionRecords(List<Id> psqs, List<inspire1__Project__c> projects,Id oppId) {
        
        List<Projects_PS_Questionnaire_Junction__c> junctionRecords = new List<Projects_PS_Questionnaire_Junction__c>();
        for(inspire1__Project__c project : projects) {
            for(Id psqId : psqs) {
                Projects_PS_Questionnaire_Junction__c junctionRecord = new Projects_PS_Questionnaire_Junction__c();
                junctionRecord.PS_Questionnaire__c = psqId;
                junctionRecord.Project__c = project.Id; 
                junctionRecord.Opportunity__c = oppId;
                junctionRecord.Account__c = project.inspire1__Account__c;
                junctionRecords.add(junctionRecord);
            }
        }
        return junctionRecords;
    }
   
    /**
	 * Template_ID__c check will avoid project creation batch
	*/
    private Boolean isValidProject(inspire1__Project__c project) {
        return project.Opportunity__c != null && project.Template_ID__c == null 
            && project.RecordTypeId == RT_DEPLOYMENT_PROJECT_ID;
    }
    //IBA-4912 END
    
    //IBA-5909 Start
    public static void checkEarlyEngagementsOnProject(Map<Id,Inspire1__Project__c> oldProjectByProjectId, Map<Id,Inspire1__Project__c> newProjectByProjectId) {
        
        Set<Id> opportunityIds = getOpportunityIds(newProjectByProjectId.values());
        if(opportunityIds.isEmpty()) {
            return;
        }
        
        Map<Id,Opportunity> opportunityByOpportunityId = new Map<Id,Opportunity>([SELECT Id, StageName FROM Opportunity WHERE Id IN : opportunityIds]);
        for(Inspire1__Project__c newProject : newProjectByProjectId.values()) {
            Inspire1__Project__c oldProject = oldProjectByProjectId.get(newProject.Id);
            if(shouldUpdateEEFieldOnProject(newProject, oldProject,opportunityByOpportunityId)) {
                newProject.Early_Engagements__c = true;
            }
        }
    }
    
    private static Set<Id> getOpportunityIds(List<Inspire1__Project__c> projects) {
        Set<Id> opportunityIds = new Set<Id>();
        for(Inspire1__Project__c project : projects){
            if(project.opportunity__c != null){
                opportunityIds.add(project.opportunity__c);
            }
        }
        
        return opportunityIds;
    }
    
    private static Boolean shouldUpdateEEFieldOnProject(Inspire1__Project__c newProject, Inspire1__Project__c oldProject,Map<Id,Opportunity> opportunityByOpportunityId) {
        return oldProject.Early_Engagements__c 
               &&  !newProject.Early_Engagements__c 
               && !OPP_STAGES_EXCLUDE_EE_UPDATE.contains(opportunityByOpportunityId.get(newProject.Opportunity__c).StageName);
    }
    
    //IBA-5909 END
}