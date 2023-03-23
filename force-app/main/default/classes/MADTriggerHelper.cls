/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* MADTriggerHelper
* @description      This is the M_A_D_Details__c Trigger helper class called synchronously 
from MADTriggerHandler.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Zscaler
* @modifiedBy     
* @maintainedBy     Zscaler
* @version          1.0
* @created          2022-08-20
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X              Author Name
* YYYY-MM-DD        Explanation of the change.  Multiple lines can be used to explain the change, but
*                   each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public with sharing class MADTriggerHelper {

    @TestVisible
    private static Exception circuitBreaker;
    
    /**
     * @description Custom exception class
     */
    public class MADTriggerHelperException extends Exception {
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method setEnagagementType was added as part of IBA-2042 for setting the confidence level
    * field using SSO or Non-SSO Account and Confidentiality Checkbox
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME :  setEnagagementType.
    * @param    NAME : List<M_A_D_Details__c> newMADList .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void setEnagagementType(List<M_A_D_Details__c> newMADList){
        for(M_A_D_Details__c madRecord : newMADList){
            if(madRecord.Sales_Effort__c == 'Sales Leading' && madRecord.Source__c == 'MADS / ADV / GSI')
            {
                madRecord.Engagement_type__c = 'Direct Engagement with Customer (Customer Consulting role)';
            }
            else if (madRecord.Sales_Effort__c == 'Sales Leading' && madRecord.Source__c == 'Sales / SDR / CSM')
            {
                madRecord.Engagement_type__c = 'Indirect Engagement through account team (Sales Enablement role)';
            }

            else if (madRecord.Sales_Effort__c == 'MADS Leading' && madRecord.Source__c == 'MADS / ADV / GSI')
            {
                madRecord.Engagement_type__c = 'Direct Engagement with Customer & Partner (Strategic Partner role)';
            }
            else if (madRecord.Sales_Effort__c == 'MADS Leading' && madRecord.Source__c == 'Sales / SDR / CSM')
            {
                madRecord.Engagement_type__c = 'Direct Engagement with Customer (Customer Consulting role)';
            }

            else if (madRecord.Sales_Effort__c == 'Joint effort' && madRecord.Source__c == 'MADS / ADV / GSI')
            {
                madRecord.Engagement_type__c = 'Direct Engagement with Customer & Partner (Strategic Partner role)';
            }
            else if (madRecord.Sales_Effort__c == 'Joint effort' && madRecord.Source__c == 'Sales / SDR / CSM')
            {
                madRecord.Engagement_type__c = 'Direct Engagement with Customer (Customer Consulting role)';
            }

            else if (madRecord.Sales_Effort__c == 'External Influence' && madRecord.Source__c == 'MADS / ADV / GSI')
            {
                madRecord.Engagement_type__c = 'Influenced Engagement through Partners (Partnership Enablement role)';
            }
            else if (madRecord.Sales_Effort__c == 'External Influence' && madRecord.Source__c == 'Sales / SDR / CSM')
            {
                madRecord.Engagement_type__c = 'Direct Engagement with Customer & Partner (Strategic Partner role)';
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method setBuyerSellerDetails sets the buyer and seller account manager and area director
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : setBuyerSellerDetails.
    * @param    NAME : List<M_A_D_Details__c> newMADList .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void setBuyerSellerDetails(List<M_A_D_Details__c> newMADList){

        Set<Id> buyerAccIdSet = new Set<Id>();
        Set<Id> sellerAccIdSet = new Set<Id>();
        Map<Id,Account> buyerAccIdAccRecMap = new Map<Id,Account>();
        Map<Id,Account> sellerAccIdAccRecMap = new Map<Id,Account>();

        for(M_A_D_Details__c madRecord : newMADList){
            if(madRecord.Buyer__c != NULL){
                buyerAccIdSet.add(madRecord.Buyer__c);
            }
            if(madRecord.Seller__c != NULL){
                sellerAccIdSet.add(madRecord.Seller__c);
            }            
        }
        //Get Account related fields
        if(!buyerAccIdSet.isEmpty()){
            buyerAccIdAccRecMap = getRelatedAccDetails(buyerAccIdSet);
        }
        if(!sellerAccIdSet.isEmpty()){
            sellerAccIdAccRecMap = getRelatedAccDetails(sellerAccIdSet);
        }
        //Set Buyer Seller Details
        for(M_A_D_Details__c madRecord : newMADList){
            madRecord.Buyer_Manager__c = buyerAccIdAccRecMap?.get(madRecord.Buyer__c)?.Account_Manager__c;
            madRecord.Buyer_Area_Director__c = buyerAccIdAccRecMap?.get(madRecord.Buyer__c)?.Area_Director__c;
            madRecord.Seller_Manager__c = sellerAccIdAccRecMap?.get(madRecord.Seller__c)?.Account_Manager__c;
            madRecord.Seller_Area_Director__c = sellerAccIdAccRecMap?.get(madRecord.Seller__c)?.Area_Director__c;
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method setAccountLookup sets the Account based on Oppotunity 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : setAccountLookup.
    * @param    NAME : List<M_A_D_Details__c> newMADList .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void setAccountLookup(List<M_A_D_Details__c> newMADList){

        Set<Id> oppIdSet = new Set<Id>();
        Map<Id,Opportunity> oppIdOppRecMap = new Map<Id,Opportunity>();

        for(M_A_D_Details__c madRecord : newMADList){
            if(madRecord.Opportunity__c != NULL){
                oppIdSet.add(madRecord.Opportunity__c);
            }          
        }
        //Get Opp related fields
        if(!oppIdSet.isEmpty()){
            oppIdOppRecMap = getOppDetails(oppIdSet);
        }
        
        //Set Buyer Seller Details
        for(M_A_D_Details__c madRecord : newMADList){
            Boolean isSSOAccount = oppIdOppRecMap?.get(madRecord.Opportunity__c)?.Account.Name.containsIgnoreCase('SSO');
            if(isSSOAccount){
                madRecord.Probability__c = 'Target';
                madRecord.Stage__c = 'Lead level 0: No Action/ Interaction started';
            }
            madRecord.Account__c = oppIdOppRecMap?.get(madRecord.Opportunity__c)?.AccountId;
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method getRelatedAccDetails returns the related field details from Account
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : getRelatedAccDetails.
    * @param    NAME : Set<Id> oppIdSet.
    * @return   TYPE : Map<Id,Account>.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id,Account> getRelatedAccDetails(Set<Id> accIdSet){
        Map<Id,Account> accIdAccRecMap;
        if(!accIdSet.isEmpty()){
            accIdAccRecMap = new Map<Id,Account>([Select Id, Name, Area__c, 
                                Industry,Market_Segment__c, Type, OwnerId,
                                Global_2000_Rank__c, Fortune_500__c, 
                                Account_Manager__c, Area_Director__c
                                FROM Account 
                                WHERE Id=:accIdSet]);
        }
        
        return accIdAccRecMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method getOppDetails returns the related field details from Opportunity
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : getOppDetails.
    * @param    NAME : Set<Id> oppIdSet.
    * @return   TYPE : Map<Id,Opportunity>.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id,Opportunity> getOppDetails(Set<Id> oppIdSet){
        Map<Id,Opportunity> oppIdOppRecMap;
        if(!oppIdSet.isEmpty()){
            oppIdOppRecMap = new Map<Id,Opportunity>([Select Id, AccountId, Account.Name
                                FROM Opportunity 
                                WHERE Id=:oppIdSet]);
        }
        
        return oppIdOppRecMap;
    }

}