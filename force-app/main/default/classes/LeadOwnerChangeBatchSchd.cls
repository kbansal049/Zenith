global class LeadOwnerChangeBatchSchd implements Schedulable{
   
    global void execute (SchedulableContext SC){
        
        LeadOwnerChangeBatch b = new LeadOwnerChangeBatch(new Set<Id>());
        Database.executeBatch(b);
    }  
    
}