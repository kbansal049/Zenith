trigger OpportunityAsyncTrigger on OpportunityChangeEvent (after insert) {
	new OpportunityAsyncTriggerHandler().run();
}