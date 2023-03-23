trigger UpdateEventNotes on ContentVersion (after insert,after update) {
    system.debug('inside UpdateEventNotes    ');
    if(!TriggerUtility.isUpdateEventNotesExecuted()){	// Added by Ayush Kangar as part of CR# 3483
    	ContentVersionTriggerHelper.UpdateEventNotes(trigger.new);
        TriggerUtility.UpdateEventNotesExecuted();		// Added by Ayush Kangar as part of CR# 3483
    }
    if(Trigger.isAfter && Trigger.isInsert) {
        ContentVersionTriggerHelper.syncProjectFilesOnAccountTask(trigger.new);
    }
}