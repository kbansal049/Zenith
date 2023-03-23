/*
 *  @purpose: Covers all trigger events in Churn object.
 *            Please extend this same trigger for additional functionality
 * 
 *  @author : Pranjal Singh
 */
trigger ChurnMasterTrigger on Churn__c (before insert,before update,before delete,after update) {
    if(Trigger.isBefore){
        if(Trigger.isinsert){
            Util_ChurnReasonMethods.checkChurnPresentFlag_onOpp(Trigger.new);
        }
        //CR#1313 Start
        if(Trigger.isUpdate){
            Util_ChurnReasonMethods.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
        //CR#1313 End
        if(Trigger.isDelete){
            Util_ChurnReasonMethods.checkChurnPresentFlag_onOpp(Trigger.old);       
        }
    }
    //CR#1313 Start
    if(Trigger.isAfter){
        if(Trigger.isinsert){
            Util_ChurnReasonMethods.checkChurnPresentFlag_onOpp(Trigger.new);
        }
        if(Trigger.isupdate){
            Util_ChurnReasonMethods.afterUpdate(Trigger.new,Trigger.oldMap);
        }
    }
    //CR#1313 End
}