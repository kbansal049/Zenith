trigger emailTrackerTrigger on Email_Tracker__c (before insert,before update) {
	if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            emailTrackerHelperClass.updateCompletedDateBeforeInsert(trigger.new);
        }
        else if(trigger.isUpdate)
        {
            emailTrackerHelperClass.updateCompletedDateBeforeUpdate(trigger.new,trigger.oldMap);
        }
    }
}