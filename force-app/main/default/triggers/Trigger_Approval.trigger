trigger Trigger_Approval on sbaa__Approval__c (after insert, after update, before update, before insert) {
    
    if(trigger.isBefore){
        // It is used to populate public group members on Approval.. 
        Trigger_Approval_Handler.populatePublicGroupMembers(trigger.new);
    }  
    if(trigger.isAfter ){
        Trigger_Approval_Handler.updatePreskuandFullskuFields(trigger.new, trigger.oldMap);
    }
}