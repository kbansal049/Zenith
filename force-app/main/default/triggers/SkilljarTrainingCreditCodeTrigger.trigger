/*****************************************************************************************
Name: SkilljarTrainingCreditCodeTrigger
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex trigger for skilljar__Training_Credit_Code__c
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       13/10/2022      IBA-3769      Training Credits Redemption Process.
******************************************************************************************/ 
trigger SkilljarTrainingCreditCodeTrigger on skilljar__Training_Credit_Code__c (after update, after insert, before insert, before update, before delete, after delete) {
    new SkilljarTrainingCreditCodeTriggerHandler().run();
}