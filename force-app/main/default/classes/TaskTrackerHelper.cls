public without sharing class TaskTrackerHelper {
    //function to update schedule date on insert operation
    public static void updateScheduleDateOnInsert(List<Task_Tracker__c> newTaskTracker)
    {
        for(Task_Tracker__c taskTracker:newTaskTracker)
        {    
            if(taskTracker.Schedule_date__c != null)
            {
                taskTracker.Schedule_date__c=TaskTrackerHelper.getWeekDay(taskTracker.Schedule_date__c);     
            }
        }
    }
    
    //function to update schedule date on update operation
    public static void updateScheduleDateOnUpdate(List<Task_Tracker__c> newTaskTracker,Map<ID,Task_Tracker__c> oldTaskTrackerMap)
    {
        for(Task_Tracker__c taskTracker:newTaskTracker)
        {
            Task_Tracker__c oldTaskTracker = oldTaskTrackerMap.get(taskTracker.Id);
            if(taskTracker.Schedule_date__c != oldTaskTracker.Schedule_date__c)
            {
                taskTracker.Schedule_date__c=TaskTrackerHelper.getWeekDay(taskTracker.Schedule_date__c);
            }
            
        }
    }
    
    //function to get the weekday of the date specified
   	public static Date getWeekDay(Date scheduledDate)
    {
        
                Datetime dt = (DateTime)scheduledDate;
                String dayOfWeek = dt.format('EEEE');
               
                if(dayOfWeek == 'Saturday')
                {
                    scheduledDate-=1;
                }
                else if(dayOfWeek == 'Sunday')
                {
                    scheduledDate-=2;
                }
        return scheduledDate;

    }

}