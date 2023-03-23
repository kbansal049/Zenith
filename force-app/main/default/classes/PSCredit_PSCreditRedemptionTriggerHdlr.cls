/*****************************************************************************************
Name: PSCredit_PSCreditRedemptionTriggerHdlr
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex trigger handler for Professional_Services_Credits__c
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Sachin Tandon        17/05/2022      CR#4745      PS Credits Redemption Process && PS Credits Redemption Validation.
******************************************************************************************/ 
public class PSCredit_PSCreditRedemptionTriggerHdlr extends TriggerHandler {

    public override void beforeInsert() {
        List<PS_Credit_Redemption__c> newPSCreditRedemptions = (List<PS_Credit_Redemption__c>)Trigger.new;
        PSCredit_PSCreditRedemptionTriggerHlpr.UpdatePSCreditRedemptionName(newPSCreditRedemptions);
    }
}