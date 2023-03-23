public with sharing class OppClosedLostDuplicate 
{
    @AuraEnabled
    public static OpportunityWrapper getOppExtensionInfo(String opportunityId){
        try 
        { //is_Duplicate_Opportunity_Linked__c

            OpportunityWrapper oppWrapper = new OpportunityWrapper();

            List<Opportunity_Extension__c> oppExtensionList = new List<Opportunity_Extension__c>();
            oppExtensionList = [select Id,Duplicate_Opportunity__c,Opportunity__c from 
                            Opportunity_Extension__c where Opportunity__c = :opportunityId limit 1];
            Opportunity opp = [select Id,Name,StageName, Sub_Stage__c from Opportunity where Id =:opportunityId];
            
            oppWrapper.oppObj = opp;
            if(!oppExtensionList.isEmpty())
            {
                oppWrapper.oppExtensionObj = oppExtensionList[0];
                oppWrapper.isSuccess = true;
            }
            else 
            {
                oppWrapper.isSuccess = false;
                oppWrapper.errorMessage = 'No extension record found';

            }
            return oppWrapper;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean isActivePRpresentOnOpp(String opportunityId){
        Set<String> prStatusSet = new Set<String>();
        prStatusSet.add('Requested');
        prStatusSet.add('In Progress');
        prStatusSet.add('Provisioned');
        
        List<Provisioning_Request__c> countActivePR = [SELECT Id
                                                       FROM Provisioning_Request__c 
                                                       WHERE Opportunity__c =: opportunityId 
                                                       AND Provisioning_Status__c IN: prStatusSet];

        return (countActivePR.size() != 0 && countActivePR != null) ? true :false;
    }
    
    @AuraEnabled
    public static Boolean decommissionActivePRsOnOpp(String opportunityId){
        
        List<Provisioning_Request__c> PRListToUpdate = new List<Provisioning_Request__c>();
        Set<String> prStatusSet = new Set<String>();
        prStatusSet.add('Requested');
        prStatusSet.add('In Progress');
        prStatusSet.add('Provisioned');
        
        List<Provisioning_Request__c> activePRList = [SELECT Id, Provisioning_Status__c
                                                       FROM Provisioning_Request__c 
                                                       WHERE Opportunity__c =: opportunityId 
                                                       AND Provisioning_Status__c IN: prStatusSet];
        if(!activePRList.isEmpty()){
            for(Provisioning_Request__c prRecord : activePRList){
                prRecord.Provisioning_Status__c = 'Request Decommission';
                PRListToUpdate.add(prRecord);
            }
        }else {
            return TRUE;
        }
        try{
            if(!PRListToUpdate.isEmpty()){
                update PRListToUpdate;
            }
            return TRUE;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class OpportunityWrapper
    {
        @AuraEnabled
        public Opportunity oppObj{get;set;}

        @AuraEnabled 
        public Opportunity_Extension__c oppExtensionObj{get;set;} 

        @AuraEnabled
        public Boolean isSuccess {get;set;}
        
        @AuraEnabled
        public string errorMessage {get;set;}
        

    }
    // Added by Ayush kangar as part of IBA-2490 - Start
    @AuraEnabled
    public static OverageOppFields isOverageOpp(Id opportunityId){
        OverageOppFields oppWrapper = new OverageOppFields();
        List<Opportunity> oppList = [SELECT Id,Flexible_Identifier__c from Opportunity where Id =:opportunityId AND Flexible_Identifier__c includes('Customer Over-Usage') limit 1];
        if(!oppList.isEmpty()){
            oppWrapper.FlexibleIdentifier = oppList[0].Flexible_Identifier__c;
            oppWrapper.isOverage = true;
        }else{
            oppWrapper.isOverage = false;
        }
        return oppWrapper;
    }

    public class OverageOppFields
    {
        @AuraEnabled
        public Boolean isOverage {get;set;}

        @AuraEnabled 
        public String FlexibleIdentifier {get;set;}

    }
    // Added by Ayush kangar as part of IBA-2490 - End
}