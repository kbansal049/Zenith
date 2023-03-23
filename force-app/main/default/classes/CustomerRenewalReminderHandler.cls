/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* CustomerRenewalReminderHandler
* @description    This class is the Customer Renewal Reminder Handler for the OpportunityMasterTrigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-07-14
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public with sharing class CustomerRenewalReminderHandler {
    private static CustomerRenewalReminderHandler instance;
    public static CustomerRenewalReminderHandler getInstance() {
        if (instance == NULL) {
            instance = new CustomerRenewalReminderHandler();
        }

        return instance;
    }

    public void handle() {
        
        
        if (!newOpportunityList.isEmpty()) {
            retrieveRelatedOppExtension();
            updateRenewalDateFields();
            TriggerUtility2.OppAfterUpdateExecuted();
        	TriggerUtility2.OppAfterInsertExecuted();
        }

        
    }
    
    private List<Opportunity> newOpportunityList;
    public void setNewOpportunityList(List<Opportunity> newOpportunityList) {  
        
        List<Opportunity> filteredOpportunityList = new List<Opportunity> ();
        
        for (Opportunity opp : newOpportunityList) {
            if (opp.StageName == '4 - Impact Validation' && opp.Type == 'Existing Customer (Renewal)' && opp.Contract_End_Date_New__c != NULL) {
                filteredOpportunityList.add(opp);
            }
        }
        
        this.newOpportunityList = filteredOpportunityList;
        
        if (!filteredOpportunityList.isEmpty()) {
            this.newOpportunityList = [
                SELECT 
                    Id,
                    AccountId,
                    Contract_End_Date_New__c,
                    Account.Owner.Name,
                    Account.OwnerId,
                    Account.CSM_Name_New__c,
                    Account.CSM_Manager__c,
                    Account.Area_Director__c  
                FROM
                    Opportunity
                WHERE
                    Id IN :filteredOpportunityList
                AND
                    Contract_End_Date_New__c != NULL
                AND
                    StageName = '4 - Impact Validation'
                AND
                    Type = 'Existing Customer (Renewal)'
                AND
                    Renewal_Rep_Forecast_Category__c != 'Omitted'
                WITH SECURITY_ENFORCED
            ];
        }
        
        
    }
    
    private Map<Id, Opportunity_Extension__c> oppOppExtensionMap;
    private void setOppOppExtensionMap(Map<Id, Opportunity_Extension__c> oppOppExtensionMap) {
        this.oppOppExtensionMap = oppOppExtensionMap;
    }
    
    private void retrieveRelatedOppExtension() {
        Map<Id, Opportunity_Extension__c> oppOppExtensionMap = new Map<Id, Opportunity_Extension__c> ();
        for (Opportunity_Extension__c ext : [
            SELECT
            	Id,
	            Opportunity__c,
	            Opportunity__r.Contract_End_Date_New__c
            FROM
            	Opportunity_Extension__c
            WHERE
            	Opportunity__c != NULL
            AND
            	Opportunity__r.Contract_End_Date_New__c != NULL
            AND
            	Opportunity__c IN :newOpportunityList
        ]) {
            oppOppExtensionMap.put(ext.Opportunity__c, ext);
        }
        
        setOppOppExtensionMap(oppOppExtensionMap);
    }
    
    private void updateRenewalDateFields() {
        List<Opportunity_Extension__c> oppExtList = new List<Opportunity_Extension__c> ();
        for (Opportunity opp : newOpportunityList) {
            Opportunity_Extension__c ext = oppOppExtensionMap.containsKey(opp.Id) 
                ? oppOppExtensionMap.get(opp.Id) 
                : new Opportunity_Extension__c();
            
            if (ext.Id == NULL) {
                continue;
            }
            
            ext.Renewal_Notice_to_CTMs_100d__c = ext.Opportunity__r.Contract_End_Date_New__c - 100;//System.Date.today() + 100;
            ext.Renewal_Notice_to_CTMs_10d__c  = ext.Opportunity__r.Contract_End_Date_New__c - 10;//System.Date.today() + 10;
            ext.Renewal_Notice_to_CTMs_270d__c = ext.Opportunity__r.Contract_End_Date_New__c - 270;//System.Date.today() + 270;
            
            oppExtList.add(ext);
        }
        
        if (!oppExtList.isEmpty()) {
        	UPSERT oppExtList;    
        }
        
    }

}