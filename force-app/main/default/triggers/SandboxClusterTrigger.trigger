trigger SandboxClusterTrigger on Sandbox_Cluster__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new SandboxClusterTriggerHandler().run();
}