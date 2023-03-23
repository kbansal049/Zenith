//Note: this event can only be ran with a single record
trigger AmberRoadAccountScreenListener on Amber_Road_Screen_Account__e (after insert) {
    System.debug('AmberRoadAccountScreenListener Trigger trigger.new : ' + trigger.new);
    //screen amber road account
    /*
    if(trigger.new[0].Account__c != null){
        System.debug('AmberRoadAccountScreenListener Trigger trigger.new[0] : ' + trigger.new[0]);
        System.debug('AmberRoadAccountScreenListener Trigger trigger.new[0].Account__c : ' + trigger.new[0].Account__c);
        AmberRoadService.screenAccountFuture(Trigger.new[0].Account__c, false, true);
    }
	
    for(Amber_Road_Screen_Account__e record : Trigger.new){
        System.debug('AmberRoadAccountScreenListener Trigger record : ' + record);
        AmberRoadService.screenAccountFuture(record.Account__c, false, true);
    }
	*/
}