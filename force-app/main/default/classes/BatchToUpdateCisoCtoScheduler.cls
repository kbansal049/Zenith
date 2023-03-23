global class BatchToUpdateCisoCtoScheduler implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {

        String query = 'Select Id,Account__r.Region__c,Account__r.Area__c from Account_Extension__c';
        BatchToUpdateCisoCtoOnAccountExtention accExt = new BatchToUpdateCisoCtoOnAccountExtention(query);
        
        Database.executeBatch(accExt,1);

    }

   
}