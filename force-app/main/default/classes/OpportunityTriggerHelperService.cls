/*****************************************************************************************
Name: OpportunityTriggerHelperService
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex Opportunity Trigger Helper Service.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Sachin Tandon        25/10/2022      CR#2737 New Project Creation.
2.0                Sachin Tandon        25/10/2022      CR#5632 New Project Creation from LWC Comp.
3.0                Sachin Tandon        25/01/2023      CR#6239 Update Project Creation Logic
******************************************************************************************/ 

public class OpportunityTriggerHelperService{
    
    private static final String PRODUCT_CATEGORY_SUBTYPE_SERVICES = 'Services';
    private static final String CLASSNAME = 'OpportunityTriggerHelperService';
    private static Id deploymentProjectRecordId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(ZScalarConstants.PROJECT_RT_DEPLOYMENT_PROJECT).getRecordTypeId();
    
    //IBA-5632 Start
    public static void updateOpportunitiesEligibleForDeploymentProjectCreation(Set<Id> closedWonOpportunityIds) {
        updateOpportunityExtensionIfEligibleForProjectCreation(closedWonOpportunityIds);
    }
    
    public static void updateOpportunitiesEligibleForDeploymentProjectCreation(Map<Id,opportunity> newOpportunitiesById, Map<Id,opportunity> oldOpportunitiesById) {
		
        Set<Id> closedWonOpportunityIds = opportunitiesUpdatedToClosedWon(newOpportunitiesById,oldOpportunitiesById);
        if(closedWonOpportunityIds.isEmpty()) {
            return;
        }
        updateOpportunityExtensionIfEligibleForProjectCreation(closedWonOpportunityIds);
    }
    //IBA-5632 END

    //IBA-2737 Start
    public static void updateOpportunityExtensionIfEligibleForProjectCreation(Set<Id> closedWonOpportunityIds) {

        Map<Id,List<String>> deployemntProjectSKUsByOpportunityId = getDeployemntProjectSKUsByOpportunityId(closedWonOpportunityIds);
        Map<Id,List<String>> opportunitySKUsByOpportunityId = getOpportunitySKUsByOpportunityId(closedWonOpportunityIds);
        List<Opportunity_Extension__c> opportunityExtensions = getOpportunityExtensionsToBeUpdated(deployemntProjectSKUsByOpportunityId,closedWonOpportunityIds,opportunitySKUsByOpportunityId);
        if(!opportunityExtensions.isEmpty()) {
            DMLManager.updateAsSystem(opportunityExtensions, '');
        }
    }

    //IBA-2737 END
    
    //IBA-2737 START
    private static Set<Id> opportunitiesUpdatedToClosedWon(Map<Id,opportunity> newOpportunitiesById, Map<Id,opportunity> oldOpportunitiesById) {
        Set<Id> closedWonOpportunityIds = new Set<Id>();
        for(Opportunity opp : newOpportunitiesById.values()) {
            String stageName = oldOpportunitiesById.get(opp.Id).StageName;
            if(opp.StageName != stageName && opp.StageName == label.Stage_6_Closed_Won) {
                closedWonOpportunityIds.add(opp.Id);
            }
        }
		return  closedWonOpportunityIds;       

    } 
    
    public static Map<Id,List<String>> getDeployemntProjectSKUsByOpportunityId(Set<Id> closedWonOpportunityIds) {
        
        Map<Id,List<String>> deployemntProjectSKUsByOpportunityId = new Map<Id,List<String>>();
        for( inspire1__Project__c existingProject: [SELECT Id,Opportunity__c,Deployment_Package__c 
                                                    FROM inspire1__Project__c 
                                                    WHERE Opportunity__c IN : closedWonOpportunityIds 
                                                    AND RecordTypeId = :deploymentProjectRecordId
                                                    AND CreatedBy.Name = :System.Label.Workato_Integration_User_Name
                                                    AND PS_Offering__c = null]) {
            
            if(!deployemntProjectSKUsByOpportunityId.containsKey(existingProject.Opportunity__c) && String.isNotEmpty(existingProject.Deployment_Package__c)) { 
                deployemntProjectSKUsByOpportunityId.put(existingProject.Opportunity__c,new List<String>());
            }
            if(String.isNotEmpty(existingProject.Deployment_Package__c)) {
                deployemntProjectSKUsByOpportunityId.get(existingProject.Opportunity__c).add(existingProject.Deployment_Package__c);
            }
        }
        
        return deployemntProjectSKUsByOpportunityId;

    }
    
    private static List<Opportunity_Extension__c> getOpportunityExtensionsToBeUpdated(Map<Id,List<String>> deployemntProjectSKUsByOpportunityId,Set<Id> closedWonOpportunityIds,Map<Id,List<String>> opportunitySKUsByOpportunityId) {

        List<Opportunity_Extension__c> oppExtensions = new List<Opportunity_Extension__c>();
        for(Opportunity_Extension__c oppextension : [SELECT Id,Opportunity__c,Project_Creation_Status__c 
                                                     FROM Opportunity_Extension__c 
                                                     WHERE Opportunity__c IN :closedWonOpportunityIds]){
            oppextension.Project_Creation_Status__c = shouldCreateDeploymentProject(oppextension.Opportunity__c, deployemntProjectSKUsByOpportunityId, opportunitySKUsByOpportunityId) ;
			oppExtensions.add(oppextension);                                                         
        }
        
        return oppExtensions;
    }

    public static List<Opportunity_Extension__c> getOpportunityExtensionsToBeUpdated(Map<Id,List<String>> deployemntProjectSKUsByOpportunityId,List<Opportunity_Extension__c> oppExtensions,Map<Id,List<String>> opportunitySKUsByOpportunityId) {

        List<Opportunity_Extension__c> oppExtensionsToBeUpdated = new List<Opportunity_Extension__c>();
        for(Opportunity_Extension__c oppextension : oppExtensions){
                       
            oppextension.Project_Creation_Status__c = shouldCreateDeploymentProject(oppextension.Opportunity__c, deployemntProjectSKUsByOpportunityId, opportunitySKUsByOpportunityId) ;
			oppExtensionsToBeUpdated.add(oppextension);                                                         
        }
        
        return oppExtensionsToBeUpdated;
    }

    private static Map<Id,List<String>> getOpportunitySKUsByOpportunityId(Set<Id> closedWonOpportunityIds) {
        Map<Id,List<String>> opportunitySKUsByOpportunityId = new Map<Id,List<String>>();
        for (OpportunityLineItem opportunityProduct : [SELECT   Id,
                                                                ProductCode,
                                                                OpportunityId
                                                       FROM     OpportunityLineItem
                                                       WHERE    Product_Category_Subtype__c = :PRODUCT_CATEGORY_SUBTYPE_SERVICES
                                                       AND      OpportunityId IN :closedWonOpportunityIds]){
            if(!opportunitySKUsByOpportunityId.containsKey(opportunityProduct.OpportunityId)) {
                opportunitySKUsByOpportunityId.put(opportunityProduct.OpportunityId,new List<String>());
            }
            opportunitySKUsByOpportunityId.get(opportunityProduct.OpportunityId).add(opportunityProduct.ProductCode);
        }
        
        return opportunitySKUsByOpportunityId;
    }

    private static String shouldCreateDeploymentProject(Id oppId, Map<Id,List<String>> deployemntProjectSKUsByOpportunityId, Map<Id,List<String>> opportunitySKUsByOpportunityId) {
        Boolean isDeploymentSkuAvailableOnOpportunity = doesOpportunityHaveDeploymentSkUs(oppId,opportunitySKUsByOpportunityId);
        Boolean isDeploymentProjectSKusAvailable = doesProjectHaveDeploymentSKUs(oppId,deployemntProjectSKUsByOpportunityId);
         
        if(!isDeploymentSkuAvailableOnOpportunity) {
            return updateProjectCreationStatusToNotApplicable();
        }else {
            if(!isDeploymentProjectSKusAvailable) {
                return updateProjectCreationStatusToPending();
            }else{
                List<String> projectSkus = deployemntProjectSKUsByOpportunityId.get(oppId);
                for(String sku : opportunitySKUsByOpportunityId.get(oppId)) {
                    if(projectSkus != null && String.isNotBlank(sku) && !projectSkus.contains(sku)) {
                        return updateProjectCreationStatusToPending();
                    }
                } 
            }
        }
        return updateProjectCreationStatusToSuccess();
    }

    @TestVisible
    private static String updateProjectCreationStatusToPending() {
        return L2O_Constants.OpportunityExtensionObject.PROJECT_CREATION_STATUS_PENDING;
    }
    
    private static String updateProjectCreationStatusToNotApplicable() {
        return L2O_Constants.OpportunityExtensionObject.PROJECT_CREATION_STATUS_NOT_APPLICABLE;
    }

    @TestVisible
    private static String updateProjectCreationStatusToSuccess() {
        return L2O_Constants.OpportunityExtensionObject.PROJECT_CREATION_STATUS_SUCCESS;
    }

    private static Boolean doesOpportunityHaveDeploymentSkUs(Id oppId, Map<Id,List<String>> opportunitySKUsByOpportunityId) {
        return opportunitySKUsByOpportunityId != null && opportunitySKUsByOpportunityId.containsKey(oppId);
    }

    public static Boolean doesProjectHaveDeploymentSKUs(Id oppId, Map<Id,List<String>> deployemntProjectSKUsByOpportunityId) {
        return deployemntProjectSKUsByOpportunityId != null && deployemntProjectSKUsByOpportunityId.containsKey(oppId);
    }

    //IBA-2737 END
}