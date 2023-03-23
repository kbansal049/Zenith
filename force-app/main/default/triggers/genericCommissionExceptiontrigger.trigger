trigger genericCommissionExceptiontrigger on Commission_Exception__c (before insert,before update) {
    if(trigger.isbefore){
        if(trigger.isinsert){
            CommissionExceptiontriggerhandler.beforeInsert(trigger.new);
        }
        if(trigger.isupdate){
            CommissionExceptiontriggerhandler.beforeUpdate(trigger.new,trigger.oldmap);
        }
    }
}