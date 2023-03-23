trigger genericDealRegTrigger  on Deal_Reg__c (before insert, before update, after insert, after update) {
    Boolean skiptrigger = false;
    Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
    Skip_Triggers_User_Based__c usertoskip = Skip_Triggers_User_Based__c.getInstance(Userinfo.getUserId());
    String SessionId = Userinfo.getSessionId();
    System.debug('1111 '+ Userinfo.getUserId());
    System.debug('2222 '+ Userinfo.getFirstName());
    System.debug('3333 '+ Userinfo.getLocale());
    System.debug('4444 '+ Userinfo.getOrganizationId());
    System.debug('5555 '+ Userinfo.getProfileId());
    System.debug('6666 '+ Userinfo.getSessionId());
    System.debug('7777 '+ Userinfo.getTimeZone());
    System.debug('8888 '+ Userinfo.getUiTheme());
    System.debug('9999 '+ Userinfo.getUiThemeDisplayed());
    System.debug('0000 '+ Userinfo.getUserType());
    System.debug('1999 '+ Userinfo.getUserRoleId());

    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();
    String objname = triggerType.getDescribe().getName();
    if(objname != null && usertoskip.Id != null && usertoskip.Object_s_to_skip__c != null && usertoskip.Object_s_to_skip__c.split(';') != null && !usertoskip.Object_s_to_skip__c.split(';').isEmpty() && usertoskip.Object_s_to_skip__c.split(';').contains(objname)){
        skiptrigger = true;
    }
    
    if(!skiptrigger){
        if(trigger.isBefore && trigger.isInsert && !TriggerUtility.isDealRegBeforeInsertExecuted()){
            DealRegTriggerHelper.beforeInsert(trigger.new);
        }
        
        if(trigger.isAfter && trigger.isInsert && !TriggerUtility.isDealRegAfterInsertExecuted()){
            DealRegTriggerHelper.afterInsert(trigger.new);
        }

        if (Trigger.isAfter && Trigger.isUpdate && !TriggerUtility.isDealRegAfterUpdateExecuted()) {
            DealRegTriggerHelper.afterUpdate(Trigger.oldMap, Trigger.New);
        }

        if (Trigger.isAfter && Trigger.isUpdate && !TriggerUtility.isDRFinalReviewExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_DR_Final_Review_Submission') && tsmap.get('Execute_DR_Final_Review_Submission') != null && tsmap.get('Execute_DR_Final_Review_Submission').Execute__c){
            DealRegTriggerHelper.submitDRforFinalReview(Trigger.oldMap, Trigger.New);
        }

        if (Trigger.isBefore && Trigger.isUpdate && !TriggerUtility.isDealRegBeforeUpdateExecuted()) {
            DealRegTriggerHelper.checkRejectionReasonValidation(Trigger.oldMap, Trigger.New, SessionId);
        }

        if (Trigger.isBefore && Trigger.isUpdate && !TriggerUtility.isDealRegBeforeUpdateExecuted()) {
            DealRegTriggerHelper.beforeUpdate(Trigger.oldMap, Trigger.New);
        }
        
        /* CR# 1923 Chandan Panigrahy */
        
        if (Trigger.IsBefore && (Trigger.IsUpdate || Trigger.IsInsert)) {
            System.debug('-=- Inside CR# 1923 logic -=-=');
            
            CloseProcessTrackingReportingHandler instance = CloseProcessTrackingReportingHandler.getInstance();
            instance.associateTargetCustomer();
            
            //Added by Ayush Kangar as part of CR#2952
            DealRegTriggerHelper.DealRegPartnerDeailsAutoFill(trigger.new); 
        }
        
        
        
        
    }
}