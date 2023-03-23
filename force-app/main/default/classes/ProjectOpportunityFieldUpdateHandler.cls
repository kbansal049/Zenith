/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ProjectOpportunityFieldUpdateHandler
* @description    This class is used to update the Opportunity fields of inspire1__Project__c object.
*				  We have deactivated the following WF rule : Update Project with Opportunity Fields.
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
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       21/06/2022      CR#4995      Deployment Package should be populated dynamically on project.
2.0                Harish Gowda N       27/07/2022      CR#5111      RE: Deployment Service Package: BLANK.
1.0                Harish Gowda N       16/08/2022      CR#4995      Deployment Package should be populated dynamically on project.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class ProjectOpportunityFieldUpdateHandler {
    private static ProjectOpportunityFieldUpdateHandler instance;
    public static ProjectOpportunityFieldUpdateHandler getInstance() {
        
        if (instance == NULL) {
            instance = new ProjectOpportunityFieldUpdateHandler();
        }
        
        return instance;
        
    }
    
    private Map<Id, Opportunity> relatedOpportunityMap;
    private void setRelatedOpporutnityMap(Map<Id, Opportunity> relatedOpportunityMap) {
        this.relatedOpportunityMap = relatedOpportunityMap;
    }
    
    private void retrieveRelatedOppMap() {
        
        Set<Id> oppIdSet = new Set<Id> ();
        
        for (Inspire1__Project__c project : (List<Inspire1__Project__c>) Trigger.new) {
            if (project.Opportunity__c != NULL) {
                oppIdSet.add(project.Opportunity__c);
            }
        }
        
        
        
        Map<Id, Opportunity> relatedOpportunityMap = new Map<Id, Opportunity> (
            [
                SELECT
                Id,
                StageName,
                CloseDate,
                OwnerId,
                Owner.Full_Name__c,
                Netsuite_Sales_Order_Number__c,
                DAS_Package_New__c,
                Netsuite_Promo_Code__c,
                Total_ZIA_ACV__c,
                Total_ZPA_ACV__c
                FROM
                Opportunity
                WHERE
                Id IN :oppIdSet
            ]
        );
        
        setRelatedOpporutnityMap(relatedOpportunityMap);
        
    }
    
    
    public void updateOpportunityFields() {
        
        retrieveRelatedOppMap();
        
        Map<Id, Inspire1__Project__c> oldProjectMap = Trigger.isUpdate ? (Map<Id, Inspire1__Project__c>) Trigger.oldMap : NULL;
        
        for (Inspire1__Project__c newProject : (List<Inspire1__Project__c>) Trigger.new) {
            
            Inspire1__Project__c oldProject = (oldProjectMap != NULL) ? oldProjectMap.get(newProject.Id) : NULL;
            
            //If Opportunity is not updated skip this record for Update scenario
            
            if ((oldProject != NULL) && (newProject.Opportunity__c == oldProject.Opportunity__c)) {
                continue;
            }
            
            //If Opportunity is NULL the related values should also be NULL
            
            Opportunity opp = ((newProject.Opportunity__c != NULL) && (relatedOpportunityMap.containsKey(newProject.Opportunity__c))) ? relatedOpportunityMap.get(newProject.Opportunity__c) : NULL;
            
            newProject.Netsuite_Sales_Order__c      = (opp != NULL) ? opp.Netsuite_Sales_Order_Number__c : NULL;
            newProject.Opportunity_Close_Date__c    = (opp != NULL) ? opp.CloseDate : NULL;
            newProject.Opportunity_Owner__c         = (opp != NULL) ? opp.OwnerId : NULL;
            //CR# CR#4995 && CR# 5111 - Changes to fix the Deployment Service Package: BLANK Issue.
            //IBA-2737 added newProject.Deployment_Package__c check
            if(newProject.project_type__c != 'Credit' && newProject.PS_Offering__c == null && newProject.Template_ID__c == null){
                newProject.Deployment_Package__c   = (opp != NULL) ? opp.DAS_Package_New__c : NULL; 
            }
            newProject.Promo_Code__c                = (opp != NULL) ? opp.Netsuite_Promo_Code__c : NULL;
            newProject.Opportunity_Stage__c         = (opp != NULL) ? opp.StageName : NULL;
            newProject.ZPA_ACV__c                   = (opp != NULL) ? opp.Total_ZPA_ACV__c	: NULL;	
            newProject.ZIA_ACV__c                   = (opp != NULL) ? opp.Total_ZIA_ACV__c : NULL;
        }
        
    }
    
}