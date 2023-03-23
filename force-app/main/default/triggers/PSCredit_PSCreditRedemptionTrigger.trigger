/*****************************************************************************************
Name: PSCredit_PSCreditRedemptionTrigger
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex trigger for PS_Credit_Redemption__c
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Sachin Tandon        17/05/2022      CR#4745      PS Credits Redemption Process && PS Credits Redemption Validation.
******************************************************************************************/ 
trigger PSCredit_PSCreditRedemptionTrigger on PS_Credit_Redemption__c (after update, after insert, before insert, before update, before delete, after delete) {
    new PSCredit_PSCreditRedemptionTriggerHdlr().run(); 
}