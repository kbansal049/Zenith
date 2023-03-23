trigger GenericNoteTrigger on Note (after insert) {
	Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
	if(tsmap.containsKey('NoteUpdateRFPRequest') && tsmap.get('NoteUpdateRFPRequest') != null && tsmap.get('NoteUpdateRFPRequest').Execute__c){
		NoteTriggerHandler.UpdateRFPRequest(trigger.new);
	}
}