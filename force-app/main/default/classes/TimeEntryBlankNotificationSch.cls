//Added by Varun - CR 1108
global class TimeEntryBlankNotificationSch implements Schedulable  {
	global TimeEntryBlankNotificationSch() {}

    global void execute(SchedulableContext SC)    
    {
        //Modified query as part of CR#5119
        String queryLimit = Test.isRunningTest()? ' Limit 10':'';
        Database.executeBatch(new TimeEntryBlankNotificationBatch('SELECT Id,email,UserRole.Name  FROM  user where Profile.name=\'Deployment Services v2\'  and IsActive =true and UserRole.Name in '+Label.Excluded_Time_Tracking_Users+queryLimit), 60);//Modified by Varun - CR 1278
    }
}