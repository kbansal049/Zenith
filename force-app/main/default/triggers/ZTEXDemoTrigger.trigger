trigger ZTEXDemoTrigger on ZTEX_Demo_Env__c (before insert,after insert, after update) {
     new ZTEXDemoTriggerHandler().run();
}