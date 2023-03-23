/*****************************************************************************************
Name: PSCredit_PSCreditTriggerHandler
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex trigger handler for Professional_Services_Credits__c.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Sachin Tandon        17/05/2022      CR#4745      PS Credits Redemption Process && PS Credits Redemption Validation.
2.0                Harish Gowda N       13/07/2022      IBA-1099     Create Training credits when opportunity with Training Credit SKU is closed won.
3.0                Harish Gowda N       13/10/2022      IBA-3769     Training Credits Redemption Process.
******************************************************************************************/ 

public class PSCredit_PSCreditTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {}
    
    public override void afterInsert() {
        List<Professional_Services_Credits__c> trainingCreditsInserted = New List<Professional_Services_Credits__c>();
        List<Professional_Services_Credits__c> psCustomerCredits = New List<Professional_Services_Credits__c>();
        
        List<Professional_Services_Credits__c> newPSCredit = (List<Professional_Services_Credits__c>)Trigger.new;
        PSCredit_PSCreditTriggerHelper.updateTotalPurchasedCreditsOnAccount(newPSCredit);
        
        //Looping trough all the new Customer Credits and storing all the Training Credits in a list to process it further.
        for(Professional_Services_Credits__c pscreditObj: newPSCredit ){
            if(pscreditObj.RecordTypeId == ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID){
                trainingCreditsInserted.add(pscreditObj);
            }else if(pscreditObj.RecordTypeId == ZScalarConstants.PS_CREDIT_RECORDTYPEID) {
                psCustomerCredits.add(pscreditObj);
            }
        }
        
        if(trainingCreditsInserted.Size() > 0){
            PSCredit_PSCreditTriggerHelper.generateCreditCodesOnTrainingCredits(trainingCreditsInserted);
            PSCredit_PSCreditTriggerHelper.sendTrainingCreditsInsertEmail(trainingCreditsInserted);
        }
        
        if(psCustomerCredits.size() > 0) {
            PSCredit_PSCreditTriggerHelper.sendPSCreditsNotificationEmail(psCustomerCredits);
        }
        
    }
    
    public override void afterUpdate() {
        List<Professional_Services_Credits__c> newPSCredit = (List<Professional_Services_Credits__c>)Trigger.new;
        List<Professional_Services_Credits__c> oldPSCredit = (List<Professional_Services_Credits__c>)Trigger.old;
        Map<Id,Professional_Services_Credits__c> newPSCreditByPSCreditId = (Map<Id,Professional_Services_Credits__c>)Trigger.newMap;
        Map<Id,Professional_Services_Credits__c> oldPSCreditByPSCreditId = (Map<Id,Professional_Services_Credits__c> )Trigger.oldMap;
        PSCredit_PSCreditTriggerHelper.updateTotalRedeemedCreditsOnAccount(oldPSCreditByPSCreditId,newPSCreditByPSCreditId);
    }
}