trigger PSExtensionTrigger on PS_Extension__c (before insert, before update, after insert, after update) {
	new PSExtensionTriggerHandler().run();
}