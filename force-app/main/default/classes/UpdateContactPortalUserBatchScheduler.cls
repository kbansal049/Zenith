//Added by Abhijit for CR549
global class UpdateContactPortalUserBatchScheduler implements Schedulable{

    global UpdateContactPortalUserBatchScheduler() {}

    //The ContactId on Portal users gets removed when user is made Inactive, so we need 2 different SOQLs for the batch
    global void execute(SchedulableContext SC)
    {
        //To check the flag when Portal user is enabled
        Database.executeBatch(new UpdateContactPortalUserBatch('select id from Contact where Portal_User__c = false and id in (select contactid from User where isActive = true)', 'checkportaluser'), 50);            
        
        //To uncheck the flag when Portal user is disabled
        Database.executeBatch(new UpdateContactPortalUserBatch('select id from Contact where Portal_User__c = true and id not in (select contactid from User where isActive = true)', 'uncheckportaluser'), 50);                        
     }
}