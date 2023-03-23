global class BatchToUpdateContactSch implements Schedulable
{
    global BatchToUpdateContactSch(){
    }
    
    global void execute(SchedulableContext SC)
    {
        if(!Test.isRunningTest()){
            Database.executeBatch(new BatchToUpdateLeadFields('Select Id,Qualifying_SDR__c,Qualification_Status__c,Latest_Opportunity_Date__c,Qualified_Date__c From Contact where Age_Latest_Opportunity_Creation__c >= 90 AND (Qualifying_SDR__c!=Null OR Qualification_Status__c !=Null)'),1);
        }
     }
}