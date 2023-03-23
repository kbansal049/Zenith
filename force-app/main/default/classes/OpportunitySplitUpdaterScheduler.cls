global class OpportunitySplitUpdaterScheduler implements Schedulable{        
    global void execute(SchedulableContext SC){
    	OpportunitySplitUpdaterBatch b = new OpportunitySplitUpdaterBatch(new Set<Id>());
		Database.executeBatch(b);	    
    }
}