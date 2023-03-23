/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* createNewMADRecordController
* @description      This class will be used to retrieve account details of an opportunity during M,A&D record creation
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author           Zscaler
* @modifiedBy     
* @maintainedBy     Zscaler
* @version          1.0
* @created          2022-08-23
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X              Author Name
* YYYY-MM-DD        Explanation of the change.  Multiple lines can be used to explain the change, but
*                   each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public with sharing class createNewMADRecordController {

    /**
     * @description Custom exception class
     */
    public class createNewMADRecordControllerException extends Exception {
    }

/** 
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method returns the New_MAD_Record_LWC__mdt records
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : fetchFieldCustomMetadata
* @param    NAME : 
* @return   TYPE : List <New_MAD_Record_LWC__mdt>
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    @AuraEnabled( cacheable=true )  
    public static List <New_MAD_Record_LWC__mdt> fetchFieldCustomMetadata() {
        
        return [SELECT Id, DeveloperName, Row_Number__c, 
                Field_API_Name__c, Is_Column_1__c, 
                Is_Column_2__c
                FROM New_MAD_Record_LWC__mdt 
                Order By Row_Number__c ASC];
        
    }

    /** 
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method returns related Account details from Opportunity.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : fetchAccountRelatedToOpp
* @param    NAME : String OpportunityId .
* @return   TYPE : Opportunity .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@AuraEnabled
public static Opportunity fetchAccountRelatedToOpp(String opportunityId){
    if(String.isNotBlank(opportunityId)){
        Opportunity oppRecord = [Select Id, Name, Account.Name, Account.Area__c, 
                                Account.Industry, AccountId, 
                                Account.Market_Segment__c, Account.Type, Account.OwnerId,
                                Account.Global_2000_Rank__c, Account.Fortune_500__c 
                                FROM Opportunity 
                                WHERE Id=:opportunityId
                                LIMIT 1];
        return oppRecord;
    }else {
        return new Opportunity();
    }
    
}
}