/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ValueCreationEngagementHelper
* @description    This is the Value Creation Engagement Trigger Helper class called synchronously 
                  from ValueCreationEngagementHandler.
*                 Contains the helper methods that can be called from ValueCreationEngagementHandler class.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2023-01-17
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            Aman Jain
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2023-01-17      IBA-5937 Aman - Creation of the class for adding the helper method to populate
                  Overall BVA Score and update Opportunity with BVA score and value creation stage
                  from Value creation record
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public with sharing class ValueCreationEngagementHelper {

    /**
     * Fetch VC_and_Opportunity_Stage_Mapping__mdt Metadata records
     */
    public static Map<String, VC_and_Opportunity_Stage_Mapping__mdt> mappingRecords {
        get {
            if (mappingRecords == null) {
                mappingRecords = VC_and_Opportunity_Stage_Mapping__mdt.getAll();
            }
            return mappingRecords;
        } set;
    }

    public static final List<String> PARAMETER_LIST = new List<String>{
        'Collaboration__c',
        'EB_Read_out__c',
        'Customer_Metrics__c',
        'Timeliness__c'
    };

    public static final String ASSESSMENT_ENGAGEMENT_TYPE = 'Assessment';
    public static final String REALIZATION_ENGAGEMENT_TYPE = 'Realization';
    public static final String CONSULTING_ENGAGEMENT_TYPE = 'Consulting';

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to populate Overall BVA Score on the 
                                                          VCE record.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : setBVAScore .
    * @param    NAME : List<Value_Creation_Engagements__c> VCE list .
    * @param    NAME : Map<Id, Value_Creation_Engagements__c> VCE Map. 
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void setBVAScore(
        List<Value_Creation_Engagements__c> triggerNew, 
        Map<Id, Value_Creation_Engagements__c> triggerOldMap
    ) {
        Map<String,Double> bvaScoreMdtMap = fetchBVAScoreMetadataMap();
        if (bvaScoreMdtMap.isEmpty()) {
            return;
        }
        for (Value_Creation_Engagements__c record : triggerNew) {
            Boolean isValidRecord = record.Link_to_SFDC_Opportunity__c != null;
            Boolean isNewValueConsulting = record.Engagement_Type__c == CONSULTING_ENGAGEMENT_TYPE;
            Boolean isOldValueConsulting = triggerOldMap == null 
                    || (triggerOldMap.get(record.Id).Engagement_Type__c != ASSESSMENT_ENGAGEMENT_TYPE
                    && triggerOldMap.get(record.Id).Engagement_Type__c != REALIZATION_ENGAGEMENT_TYPE);
            //Check if all parameters are not null
            Boolean parameterNotPresent = String.isBlank(record.Collaboration__c)
                    && String.isBlank(record.EB_Read_out__c)
                    && String.isBlank(record.Customer_Metrics__c)
                    && String.isBlank(record.Timeliness__c);
            //Check if BVA needs to be reset
            Boolean resetBvaScore = (!isValidRecord)
                    || isNewValueConsulting
                    || parameterNotPresent;            
			if (resetBvaScore) {
				record.Overall_BVA_Score__c = 0.0;
				continue;
			}
            //Check for only engagement change
            Boolean isEngagementTypeChanged = isOldValueConsulting;
            //Check for the parameters changes
            Boolean isParameterChanged = triggerOldMap == null 
                    || record.Collaboration__c != triggerOldMap.get(record.Id).Collaboration__c
                    || record.EB_Read_out__c != triggerOldMap.get(record.Id).EB_Read_out__c
                    || record.Customer_Metrics__c != triggerOldMap.get(record.Id).Customer_Metrics__c
                    || record.Timeliness__c != triggerOldMap.get(record.Id).Timeliness__c;
            //If changes are made then update the BVA score
            if (isEngagementTypeChanged || isParameterChanged) {
                record.Overall_BVA_Score__c = fetchBVAScore(bvaScoreMdtMap, record);
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to calculate Overall BVA Score
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : fetchBVAScore .
    * @param    NAME : Map<String,Double> bvaScoreMdtMap.
    * @param    NAME : Value_Creation_Engagements__c vceRecord. 
    * @return   TYPE : Double .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Double fetchBVAScore(Map<String,Double> bvaScoreMdtMap, Value_Creation_Engagements__c vceRecord) {
        Double score = 0.0;
        for (String parmeter : PARAMETER_LIST) {
            String parameterValue = (String)vceRecord.get(parmeter);
            if (bvaScoreMdtMap.containsKey(parmeter + parameterValue)) {
                score += bvaScoreMdtMap.get(parmeter + parameterValue);
            }
        }
        return score;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to get BVA score mapping metrics from Metadata.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : fetchBVAScoreMetadataMap.
    * @return   TYPE : Map<String,Double>.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String,Double> fetchBVAScoreMetadataMap() {
        Map<String,Double> bvaScoreMdtMap = new Map<String,Double>();
        if (!mappingRecords.isEmpty()) {
            for (VC_and_Opportunity_Stage_Mapping__mdt metadataRecord: mappingRecords.values()) {
                bvaScoreMdtMap.put(metadataRecord.Field_Name__c+metadataRecord.VC_Value__c,Double.valueof(metadataRecord.BVA_Score__c));
            }
        }
        return bvaScoreMdtMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to update Value creation stage and BVA 
                                                          score on Opportunity
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : setOpportunityStageAndScore .
    * @param    NAME : Map<Id,Value_Creation_Engagements__c> opportunityIdVsVceMap. 
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void setOpportunityStageAndScore(
        Map<Id,Value_Creation_Engagements__c> opportunityIdVsVceMap
    ) {
        List<Opportunity> filteredOpportunityList = fetchFilteredOpportunityList(
            opportunityIdVsVceMap
        );
        if (!filteredOpportunityList.isEmpty()){
            TriggerHandler.bypass('OpportunityTriggerHandler');
            try {
                update filteredOpportunityList;
            }
            catch (Exception ex) {
                ZscalerErrorLogsUtility.insertLogs('ValueCreationEngagementHelper', 'setOpportunityStageAndScore', 'Apex', 
                    UserInfo.getUserId(), 'Sales Cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
                throw new ValueCreationEngagementHelperException(ex.getMessage());
            }
            finally {
                TriggerHandler.clearBypass('OpportunityTriggerHandler');
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to get opportunity list which needs to be updated.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : fetchFilteredOpportunityList.
    * @param    NAME : Map<Id,Value_Creation_Engagements__c> opportunityIdVsVceMap.
    * @return   TYPE : List<Opportunity>.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Opportunity> fetchFilteredOpportunityList
    (
        Map<Id,Value_Creation_Engagements__c> opportunityIdVsVceMap
    ) {
        List<Opportunity> filteredOpportunityList = new List<Opportunity>();
        Map<String,String> vcAndOpportunityStageMdtMap = fetchVCAndOpportunityStageMetadataMap();
        if (!opportunityIdVsVceMap.isEmpty()) {
            List<Opportunity> opportunityList = [SELECT  Value_Creation_Stage__c,
                    Overall_BVA_Score__c, 
                    (SELECT Id,
                        Value_Creation_Stage__c,
                        Overall_BVA_Score__c
                        FROM Value_Creation_Engagements__r 
                        WHERE Engagement_Type__c = :ASSESSMENT_ENGAGEMENT_TYPE OR
                        Engagement_Type__c = :REALIZATION_ENGAGEMENT_TYPE
                        ORDER BY Name DESC 
                        LIMIT 1
                    ) 
                    FROM Opportunity 
                    WHERE Id IN :opportunityIdVsVceMap.keySet()
                    LIMIT 20000];
            for (Opportunity opportunityRecord : opportunityList) {
                List<Value_Creation_Engagements__c> vceRecords = opportunityRecord.Value_Creation_Engagements__r;
                if ((!vceRecords.isEmpty()) 
                    && (opportunityRecord.Overall_BVA_Score__c != vceRecords[0].Overall_BVA_Score__c
                        || opportunityRecord.Value_Creation_Stage__c != vceRecords[0].Value_Creation_Stage__c
                    )
                ) {
                    Value_Creation_Engagements__c vceRecord = vceRecords[0];
                    opportunityRecord.Overall_BVA_Score__c = vceRecord.Overall_BVA_Score__c;
                    opportunityRecord.Value_Creation_Stage__c = ((!vcAndOpportunityStageMdtMap.isEmpty()) && 
                        vcAndOpportunityStageMdtMap.containsKey(vceRecord.Value_Creation_Stage__c))  
                        ? vcAndOpportunityStageMdtMap.get(vceRecord.Value_Creation_Stage__c) 
                        : null;
                    filteredOpportunityList.add(opportunityRecord);
                } else if (vceRecords.isEmpty()) {
                    opportunityRecord.Overall_BVA_Score__c = 0.0;
                    opportunityRecord.Value_Creation_Stage__c = null;
                    filteredOpportunityList.add(opportunityRecord);
                }
            }
        }
        return filteredOpportunityList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5937 : to get Opportunity and VC mapping metrics 
                                                          from Metadata.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : fetchVCAndOpportunityStageMetadataMap.
    * @return   TYPE : Map<String,String>.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String,String> fetchVCAndOpportunityStageMetadataMap() {
        Map<String,String> vcAndOpportunityStageMdtMap = new Map<String,String>();
        if (!mappingRecords.isEmpty()) {
            for (VC_and_Opportunity_Stage_Mapping__mdt metadataRecord : mappingRecords.values()) {
                if (metadataRecord.Field_Name__c == 'Value_Creation_Stage__c') {
                    vcAndOpportunityStageMdtMap.put(metadataRecord.VC_Value__c,metadataRecord.Opportunity_Value__c);
                }
            }
        }
        return vcAndOpportunityStageMdtMap;
    }

    private class ValueCreationEngagementHelperException extends Exception {
    }
}