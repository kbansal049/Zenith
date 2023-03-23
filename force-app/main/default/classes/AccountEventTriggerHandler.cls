/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* AccountEventTriggerHandler
* @description    
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Nagesh
* @modifiedBy     
* @maintainedBy   Nagesh
* @version        1.0
* @created        2021-11-05
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change. .
* 2022-05-25      CR# 4912 Bikram - Removed logic for CR# 4906, moved to OpportunityTriggerHandler beforeInsert()
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public without sharing class AccountEventTriggerHandler {
    public AccountEventTriggerHandler() {

    }
    
    public static void process(List<Account_Event__e> accntEvents){
        Set<Id> accIdsForLinkAccountToPatch = new Set<Id>();
        for(Account_Event__e acctEvt:accntEvents){

            Switch on acctEvt.Event_Type__c{
                when 'LinkAccountToPatch'{
                    accIdsForLinkAccountToPatch.add(Id.valueOf(acctEvt.Record_Id__c));
                }
            }
            
        }

        if(!accIdsForLinkAccountToPatch.isEmpty()) {
            TriggerHandler.bypass('AccountTriggerHandler');
            TriggerUtility.SkipAccTriggerExecuted();
            PatchRuleEngineStarter starter = new PatchRuleEngineStarter(new List<Id>(accIdsForLinkAccountToPatch));
            starter.start();
        }
    }

}