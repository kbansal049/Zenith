@isTest
public class genericFeedItemTriggerTest {
    public static testMethod void genericFeedItemTest(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        Contact ct = new Contact();
        ct.LastName ='test';
        ct.Email ='test@test.com';
        insert ct;
        feeditem FI1=new feeditem();
        FI1.parentid=ct.id;
        FI1.Body = 'test chatter';
        //FI1.Visibility  = 'AllUsers';
        insert FI1;
    }
    public static testMethod void UpdateLastModifiedOnCaseTest(){
              
        Case c = new Case();
        c.Status = 'Pending Customer';
        c.Subject = 'test';
        c.Description = 'test dessc';
        insert c;
        feeditem FI1=new feeditem();
        FI1.parentid=c.id;
        FI1.Body = 'test chatter';
       	FI1.Visibility  = 'AllUsers';
        insert FI1;
        //Added By Anup-Start
        List<FeedItem> listOfFeedItem = new List<FeedItem>();
        listOfFeedItem.add(FI1);
        FeedItemTriggerUtility.updateCustomerNote(listOfFeedItem);
        //Added By Anup-End
    }
    //Added by Varun - CR 1202 Start
    @isTest(SeeAllData=true)
    public static  void updateKnowledgeCommentTest(){
        Test.startTest();
        KB__ka knowArticle = [Select id from KB__ka limit 1];
        feeditem FI1=new feeditem();
        FI1.parentid=knowArticle.id;
        FI1.Body = 'test chatter';
        insert FI1;
        Test.stopTest();
    }
    //Added by Varun - CR 1202 End
    
}