/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   11-23-2021   Mayank B.     Initial Version CR# 3605
*/
public class MPTransactionLogTriggerClass{

    public static void updateOpportunityBasedOnOfferID(Map<String, AWS_Transaction_Log__c> offerIdToAWSRecordMap){

        List<Opportunity> oppList = [Select id, Offer_Id__c from Opportunity where Offer_Id__c in :offerIdToAWSRecordMap.keySet()];
        Map<String, Opportunity> offerIdToOppMap = new Map<String, Opportunity>();
        for(Opportunity opp: oppList){
            offerIdToOppMap.put(opp.Offer_Id__c, opp);
        }
        for(String offerId: offerIdToAWSRecordMap.keySet()){

            if(offerIdToOppMap.containsKey(offerId)){
                offerIdToAWSRecordMap.get(offerId).Opportunity__c = offerIdToOppMap.get(offerId).Id;
                System.System.debug('Mayank, record tagged to right opp');
            }else{
                offerIdToAWSRecordMap.get(offerId).Opportunity__c = null;
                System.System.debug('Mayank, resetting opp');
            }
        }

    }

}