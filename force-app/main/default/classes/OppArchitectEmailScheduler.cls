global class OppArchitectEmailScheduler  implements Schedulable{
   global void execute (SchedulableContext SC){
       OppArchitectEmailBatch b = new OppArchitectEmailBatch(new Set<ID>());
        Database.executeBatch(b,50);
    }  
    

}