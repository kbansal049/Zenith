@isTest
public class TaskCreateRoleTriggerTest {
	public static testMethod void testTask(){
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject='hi';
        t.Status='Not Started';
        t.Priority='Normal';
      

        insert t; 
    }
}