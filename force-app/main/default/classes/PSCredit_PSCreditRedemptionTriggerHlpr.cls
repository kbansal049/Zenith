/*****************************************************************************************
Name: PSCredit_PSCreditRedemptionTriggerHlpr
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex trigger helper for PS_Credit_Redemption__c to update name of PS_Credit_Redemption__c
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Sachin Tandon        17/05/2022      CR#4745      PS Credits Redemption Process && PS Credits Redemption Validation.
******************************************************************************************/ 
public class PSCredit_PSCreditRedemptionTriggerHlpr {

    private static String SUFFIX_RF = 'RF';
    private static Map<Id,String> accountNameById = new Map<Id,String>();
    private static Map<Id,String> offeringNameById = new Map<Id,String>();
    
    public static void UpdatePSCreditRedemptionName(List<PS_Credit_Redemption__c> newPSCreditRedemptions){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> offeringIds = new Set<Id>();
        Set<PS_Credit_Redemption__c> validRedemptions = new Set<PS_Credit_Redemption__c>();
        Map<String,AggregateResult> redemptionByredemptionName = new Map<String,AggregateResult>();
        
        for(PS_Credit_Redemption__c creditRedemption : newPSCreditRedemptions) {
            if(creditRedemption.Account__c != null && creditRedemption.PS_Offering__c != null ) {
            	accountIds.add(creditRedemption.Account__c);
            	offeringIds.add(creditRedemption.PS_Offering__c);
                validRedemptions.add(creditRedemption);
            }
        }
        
        if(!validRedemptions.isEmpty()) {
            
            String uniqueKey = '';
            String redemptionName;
            redemptionByredemptionName = getRedemptionCountByAccountPSOfferingId(accountIds,offeringIds);
            accountNameById = getAccountNameById(accountIds);
    		offeringNameById = getOfferingNameById(offeringIds);
                
            for(PS_Credit_Redemption__c redemption : validRedemptions) {
                redemptionName = '';
                uniqueKey = redemption.Account__c+''+redemption.PS_Offering__c;
                
                if(redemptionByredemptionName.containsKey(uniqueKey)) {
                    AggregateResult redemptionAggr = redemptionByredemptionName.get(uniqueKey);
                    redemption.PS_Credit_Redemption_Name__c = getRedemptionName(redemptionAggr);
                }else {
                    redemption.PS_Credit_Redemption_Name__c = getRedemptionName(redemption);
                }
            }
        }
    }
    
    private static String getRedemptionName(AggregateResult redemptionAggr) {
        Integer count = Integer.valueOf(redemptionAggr.get('redemptionCount'))+1;
        return (String)redemptionAggr.get('accountName') +'-'+ (String)redemptionAggr.get('psOfferingName')+'-' + SUFFIX_RF + count;
    }
    
    private static String getRedemptionName(PS_Credit_Redemption__c redemption) {
        return accountNameById.get(redemption.Account__c) +'-'+ offeringNameById.get(redemption.PS_Offering__c)+'-'+ SUFFIX_RF+'1';
    }
    
    private static Map<String,AggregateResult> getRedemptionCountByAccountPSOfferingId(Set<Id> accountIds, Set<Id> offeringIds) {
        
        Map<String,AggregateResult> redemptionByredemptionName = new Map<String,AggregateResult>();
        List<AggregateResult> redemptionAggrResult = getRedemptionAggregrateResults(accountIds,offeringIds);
                   
        String accountId = '';
        String offeringId = '';
        String uniqueKey = '';
        
        for(AggregateResult redemptionAggrResultrecord : redemptionAggrResult) {
            accountId = (String)redemptionAggrResultrecord.get('accountId');
            offeringId = (String)redemptionAggrResultrecord.get('psOfferingId');
            uniqueKey = accountId + offeringId;
            redemptionByredemptionName.put(uniqueKey,redemptionAggrResultrecord);
        }
        
        return redemptionByredemptionName;
    }
    
    private static List<AggregateResult> getRedemptionAggregrateResults(Set<Id> accountIds, Set<Id> offeringIds) {
        
        return [SELECT COUNT(Id) redemptionCount, 
                Account__r.Name accountName,
                PS_Offering__r.Name psOfferingName ,
                Account__c accountId,
                PS_Offering__c psOfferingId
                FROM PS_Credit_Redemption__c 
                WHERE Account__c IN: accountIds
                AND PS_Offering__c IN : offeringIds
                GROUP BY Account__c, PS_Offering__c,Account__r.name,PS_Offering__r.name 
               ];
    }
    
    private static Map<Id,String> getAccountNameById(Set<Id> accountIds) {
        Map<Id,String> accountNameById = new Map<Id,String>(); 
        for(Account acc : [Select Id,Name From Account where Id IN :accountIds ]){
        	accountNameById.put(acc.Id, acc.Name);
    	}
    return accountNameById;
        
    }
    
    private static Map<Id,String> getOfferingNameById(Set<Id> offeringIds) {
        Map<Id,String> offeringNameById = new Map<Id,String>(); 
        for( PS_offering__c offering : [Select Id,Name From PS_offering__c where Id IN :offeringIds ]){
        	offeringNameById.put(offering.Id, offering.Name);
    	}
    return offeringNameById;
        
    }    
        
}