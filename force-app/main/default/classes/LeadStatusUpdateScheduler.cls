global class LeadStatusUpdateScheduler implements Schedulable{        
    global void execute(SchedulableContext SC){
        LeadStatusUpdateBatch b = new LeadStatusUpdateBatch(new Set<Id>());
        Database.executeBatch(b);       
    }

}