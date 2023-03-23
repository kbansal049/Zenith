@IsTest(seeAllData=true)
public class UserServicePresence_Test {
    @IsTest
    static void test1(){
        
        Test.startTest();
        //UserServicePresence usp = new UserServicePresence();
        //usp.UserId = UserInfo.getUserId();
        //usp.OwnerId = UserInfo.getUserId();
        delete [Select Id from UserservicePresence where IsCurrentState = false order by createddate ASC limit 1];
        UserServicePresenceUtility.booster();
        Test.stopTest();
        
    }
}