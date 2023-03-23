/*****************************************************************************************
Name: SkilljarTrainingCreditCodeTriggerHandler
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex trigger handler for skilljar__Training_Credit_Code__c.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       13/10/2022      IBA-3769      Training Credits Redemption Process.
******************************************************************************************/ 

public class SkilljarTrainingCreditCodeTriggerHandler extends TriggerHandler {
    
    public override void afterInsert() {
        List<skilljar__Training_Credit_Code__c> newTrainingCreditCode = (List<skilljar__Training_Credit_Code__c>)Trigger.new;
        Map<Id,skilljar__Training_Credit_Code__c> oldTrainingCreditCode = (Map<Id,skilljar__Training_Credit_Code__c>)Trigger.oldMap;
        
        SkilljarTrainingCreditCodeTriggerHelper.populateTrainingCodeTrainingCredit(newTrainingCreditCode,oldTrainingCreditCode);
    }
    
    public override void afterUpdate() {
        List<skilljar__Training_Credit_Code__c> newTrainingCreditCode = (List<skilljar__Training_Credit_Code__c>)Trigger.new;
        Map<Id,skilljar__Training_Credit_Code__c> oldTrainingCreditCode = (Map<Id,skilljar__Training_Credit_Code__c>)Trigger.oldMap; 
        SkilljarTrainingCreditCodeTriggerHelper.populateTrainingCodeTrainingCredit(newTrainingCreditCode,oldTrainingCreditCode);
    }
    
}