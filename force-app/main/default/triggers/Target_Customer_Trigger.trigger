trigger Target_Customer_Trigger on Target_Customer__c (before insert, before update, after update,after insert) {
	if(trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
        if(Trigger.isInsert && !TriggerUtility2.isTargetafterInsertAndUpdate()){
        	TargetCustomerHelper.createTargetCustomerHistory(Trigger.New,null);
        	TargetCustomerHelper.updateTargetCustomerOnEvent(Trigger.New,null);
        }
        if(Trigger.isUpdate && !TriggerUtility2.isTargetafterInsertAndUpdate()){
        	TargetCustomerHelper.createTargetCustomerHistory(Trigger.New,Trigger.oldMap);
        	TargetCustomerHelper.updateTargetCustomerOnEvent(Trigger.New,Trigger.oldMap);
        }
	}
}