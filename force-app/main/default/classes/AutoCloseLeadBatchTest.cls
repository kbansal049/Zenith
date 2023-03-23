@isTest
public class AutoCloseLeadBatchTest {

    @isTest static void myTest() {
        //Removed by Arsh - CR 4717
    	/*
        Contact cnt = new Contact();
        cnt.LastName = 'test2';
        cnt.Contact_Lead_Status__c='Marketing Qualified: Sales Accepted';
        cnt.Last_Opened_Date__c  =Date.today().addDays(-40);
        cnt.Remarks__c='';
        cnt.Outreach_Status__c='';
        
        insert cnt;*/
        
        Contact cnt2 = new Contact();
		cnt2.LastName = 'test20';
        cnt2.Contact_Lead_Status__c='Marketing Qualified: Sales Untouched';
        cnt2.Last_Opened_Date__c =Date.today().addDays(-40);
        cnt2.Remarks__c='';
        cnt2.Outreach_Status__c='';  
        insert cnt2;
    	//added by Swathi : CR 1398 start
		AutoCloseLeadBatch b1 = new AutoCloseLeadBatch(); 
        b1.errorMap.put(cnt2.Id,'');
        database.executebatch(b1,20);

        //Database.executeBatch(new AutoCloseLeadBatch());
    }  
    
    static testmethod void test2(){
        AutoCloseLeadBatch m = new AutoCloseLeadBatch();
        String sch = '0 36 1 * * ?';
        //m.errorMap.add('abc');
        String jobID = system.schedule('test update ter  tasks 1', sch, m);
    }
    //added by Swathi : CR 1398 End
}