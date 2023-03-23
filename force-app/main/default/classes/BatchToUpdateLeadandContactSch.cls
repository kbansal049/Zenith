global class BatchToUpdateLeadandContactSch implements Schedulable
{
    global BatchToUpdateLeadandContactSch(){
    }
    
    global void execute(SchedulableContext SC)
    {
        if(!Test.isRunningTest()){
            Database.executeBatch(new BatchToUpdateLeadFields('Select Id,Qualifying_SDR__c,Qualification_Status__c From Lead where Age_Past_Qualification_Date__c >= 90 AND IsConverted = False AND (Qualifying_SDR__c!=Null OR Qualification_Status__c !=Null)'),20);
            //Database.executeBatch(new BatchToUpdateLeadFields('Select Id,Qualifying_SDR__c,Qualification_Status__c,Latest_Opportunity_Date__c,Qualified_Date__c From Contact where Age_Latest_Opportunity_Creation__c >= 90 AND (Qualifying_SDR__c!=Null OR Qualification_Status__c !=Null)'),20);
        }
     }
}