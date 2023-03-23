/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-10-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger trg_ProvisioningGroup on Provisioning_Group__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new ProvisioningGroupTriggerHandler().run();
}