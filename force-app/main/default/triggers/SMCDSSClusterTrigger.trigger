trigger SMCDSSClusterTrigger on SMCDSS_DLP_Cluster__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new SMCDSSClusterTriggerHandler().run();
}