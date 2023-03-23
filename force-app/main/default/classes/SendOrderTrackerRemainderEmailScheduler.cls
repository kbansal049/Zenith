global class SendOrderTrackerRemainderEmailScheduler implements schedulable{

    global void execute(SchedulableContext SC) 
    {
        SendOrderTracerRemainderEmail remainderEmail = new SendOrderTracerRemainderEmail();
    
        Database.executeBatch(remainderEmail,10);
    }    
}