/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* AccountRiskScoreTriggerHandler
* @description    This is the AccountRiskScore Trigger handler class called from AccountRiskScoreTrigger.
*				  
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Mahesh Tirumalaraju
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2021-12-06
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class AccountRiskScoreTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {
        
        //CR#3662 -Mahesh T --Start	
        List <Account_Extension__c> lstAccountsToUpdate = new List <Account_Extension__c>();
        Map<Id, Decimal> newAccRiskMap = new Map<Id,Decimal>();
        Map<Id, String> newAccRiskSeverityMap = new Map<Id,String>(); // Added by Ayush Kangar as part of CR# 4067
        Account_Risk_Score__c newAccRisk;
        
        for(SObject accRisk:Trigger.new){
            newAccRisk = (Account_Risk_Score__c) accRisk;
            newAccRiskMap.put(newAccRisk.Account_Id__c,newAccRisk.Overall_Risk__c);      
            newAccRiskSeverityMap.put(newAccRisk.Account_Id__c,newAccRisk.Severity__c); // Added by Ayush Kangar as part of CR# 4067
        }
        
        for(Account_Extension__c acc:[SELECT Id,Account__c from Account_Extension__c where Account__c IN: newAccRiskMap.KeySet()]){
            Account_Extension__c accObj = new Account_Extension__c ();
            accObj.Id = acc.Id;
            accObj.Overall_Risk__c = newAccRiskMap.get(acc.Account__c);
            accObj.Severity__c = newAccRiskSeverityMap.get(acc.Account__c);	// Added by Ayush Kangar as part of CR# 4067
            lstAccountsToUpdate.add(accObj);
        }
        
        UPDATE lstAccountsToUpdate;
       //CR#3662 --END    
    }
}