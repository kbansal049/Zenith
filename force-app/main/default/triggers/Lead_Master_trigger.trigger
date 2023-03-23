/*
*************************************************
Name :  Lead_Master_trigger
CreatedBy :  Pankaj Verma  <pverma@zscaler.com>
CreatedOn :  27 March 2020
Description :  Master Trigger for Lead object.
*************************************************
*/

trigger Lead_Master_trigger on Lead (before insert, before update, after insert, after update) {
    
    boolean skipTrigger = false;
    List<Skip_Triggers__c> skipTriggers = Skip_Triggers__c.getall().values();
    if(!skipTriggers.isEmpty()){
        //runTrigger = 
        if(skipTriggers[0].Skip_Lead_Triggers__c){
            skipTrigger = true;
        }
    }
    
    if(!skipTrigger && !TriggerUtility.isafterUpdateRelatedLeadExecuted()){
        
        LeadMasterTriggerHandler instTrHand = new LeadMasterTriggerHandler();
        /**********AFTER INSERT START**************/       
        
        if (trigger.isafter && trigger.isinsert){
            
            
        }
        
        /**********AFTER INSERT END**************/   
        
        if(trigger.isbefore && trigger.isupdate){
        }
        if (trigger.isbefore && trigger.isinsert){
            System.debug('Lead_Master_trigger--trigger.new --'+trigger.new);
            instTrHand.onBeforeInsert(trigger.new);
            
        }
        if (trigger.isbefore && trigger.isupdate){
            
        }
        /**********AFTER UPDATE START **************/ 
        if (trigger.isafter && trigger.isupdate){
            system.debug('#### calling after upd trigger');
            instTrHand.onAfterupdate( trigger.newMap,trigger.oldMap);
            
        }
        /**********AFTER UPDATE END **************/ 
    }
}