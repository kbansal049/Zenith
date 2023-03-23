trigger opportunitySplitTrigger on OpportunitySplit (after insert, after delete) {
    //Added by Gurjinder for bypassing trigger for specific user
    boolean skiptrigger=false;
Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
system.debug('usertoskip '+usertoskip);
SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
String objname = triggerType.getDescribe().getName();
if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
    system.debug('inside if of skip triggers on user based +opportunitySplitTrigger ');
    skiptrigger = true;
}
system.debug('inside if of skip triggers on user based opportunitySplitTrigger'+skiptrigger);
    if(!skiptrigger){
        if(trigger.isAfter && trigger.isinsert){
            if(Test.isRunningTest()){
				opportunitySplitTriggerHandler.afterInsert(trigger.new);
			}
            if(opportunitySplitTriggerHandler.isFirstTime){
            	opportunitySplitTriggerHandler.afterInsert(trigger.new);
				opportunitySplitTriggerHandler.isFirstTime = False;
            }
        }   
        if(trigger.isAfter && trigger.isDelete){opportunitySplitTriggerHandler.afterDelete(trigger.old);
        }
    }
}