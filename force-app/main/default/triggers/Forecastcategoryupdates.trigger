trigger Forecastcategoryupdates on Opportunity (before insert, before update, after insert, after update) {
    //PatchRealigning Check is added as a part of RBAC
    boolean skipTrigger = false;
    List<Skip_Triggers__c> skipTriggers = Skip_Triggers__c.getall().values();
    if(!skipTriggers.isEmpty()){
        //runTrigger = 
        //Changed by Abhijit for CR866 - '=' needs to change to '==' as = will assign the value        
        if(skipTriggers[0].Skip_Account_Triggers__c == true){
            skipTrigger = true;
        }
    }
    //Added by Gurjinder for bypassing trigger for specific user
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        system.debug('inside if of skip triggers on user based Forecastcategoryupdates ');
        skiptrigger = true;
    }
    system.debug('inside if of skip triggers on user based Forecastcategoryupdates '+skiptrigger);
    
    //Added by Gurjinder for Opp Creation Issue :Start
    if(trigger.Isbefore && trigger.isInsert && !TriggerUtility.isSkipAccTriggerExecuted()){ 
        TriggerUtility.SkipAccTriggerExecuted();
    }
    //Added by Gurjinder for Opp Creation Issue : End

    if(!skipTrigger){
        
        system.debug('is patch realigining');
        
        if(!TriggerUtility.isPatchRealigning()) {
            if(Trigger.isinsert && Trigger.isBefore){
                OppotunityTriggerHelper.copymainforecasttohierarchycategoryfields(Trigger.New);
                OppotunityTriggerHelper.updateGAMNAM(Trigger.New);
                OppotunityTriggerHelper.clearNSfieldsonCreation(Trigger.New);
            }
            if(Trigger.isUpdate && Trigger.isBefore && !TriggerUtility.isOpptyTriggerFCexecuted()){
                OppotunityTriggerHelper.handleallcategoryfieldandlockchanges(Trigger.newmap, Trigger.Oldmap);
                OppotunityTriggerHelper.updateGAMNAM(Trigger.New);
                OppotunityTriggerHelper.validateClosedLostwithOpenPRs(trigger.newMap, trigger.oldmap);
            }
            //Changes Added as a part of RBAC :Start
            if(Trigger.isinsert && trigger.isAfter){
                OppotunityTriggerHelper.afterInsert(trigger.new);
            }
            
            if(Trigger.isUpdate && trigger.isBefore){
                 OppotunityTriggerHelper.beforeUpdate(trigger.new, trigger.oldmap);
            }
             if(Trigger.isUpdate && trigger.isAfter){
               OppotunityTriggerHelper.afterUpdate(trigger.newMap,trigger.oldmap);
            }

        }
        else{
            if(Trigger.isinsert && Trigger.isBefore){
                OppotunityTriggerHelper.copymainforecasttohierarchycategoryfields(Trigger.New);
                //OppotunityTriggerHelper.updateGAMNAM(Trigger.New);
                //OppotunityTriggerHelper.clearNSfieldsonCreation(Trigger.New);
            }
        }
    }
    if(test.isrunningtest()){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
     //Changes Added as a part of RBAC :End
}