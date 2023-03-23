/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-09-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger Trigger_Contract on Contract(before insert, before update, after insert, after update) {
    new Trigger_Contract_Handler().run();
}