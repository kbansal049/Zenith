@isTest
public class DeleteUserPresenceBatchTest {
    @isTest 
    public static void deleteUserPresence(){
        User ur = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        
        Integer limitMonths = 0 - Integer.valueOf(System.Label.DeleteUserPresenceInterval_in_Months);
        Date limitDate = System.today().addMonths(limitMonths);
        
        UserservicePresence usp=new UserservicePresence();
        usp.CreatedDate=limitDate.addDays(-5);
        usp.UserId=ur.Id;
        insert usp;
        
        Test.startTest();
        DeleteUserPresenceHandler.deleteUserPresenceRecords();
        Test.stopTest();
    }
}