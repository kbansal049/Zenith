global class LeadSalesTerritoryAssignedBatchSchd implements Schedulable{
   
    global void execute (SchedulableContext SC){
        
        LeadSalesTerritoryAssignedBatch b = new LeadSalesTerritoryAssignedBatch(new Set<Id>());
        Database.executeBatch(b);
    }  
    
}