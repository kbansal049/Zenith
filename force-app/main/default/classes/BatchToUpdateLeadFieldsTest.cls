@isTest
public class BatchToUpdateLeadFieldsTest {
    
	public static testMethod void test(){
        
        Contact con = new Contact(
                          FirstName = 'Robin',
                          LastName = 'Koehler',
                          Qualifying_SDR__c = UserInfo.getUserId(),
            			  Qualified_Date__c = System.today() - 120
                          );
        

        Lead lead=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry',Qualifying_SDR__c = UserInfo.getUserId(),
            			  Qualified_Date__c = System.today() - 120, IsConverted = False);
        
		insert con;
        insert lead;
        
        Test.startTest();
        Database.executeBatch(new BatchToUpdateLeadFields('Select Id,Qualifying_SDR__c,Qualification_Status__c From Lead where FirstName=\'John\''),1);
        Database.executeBatch(new BatchToUpdateLeadFields('Select Id,Qualifying_SDR__c,Qualification_Status__c,Latest_Opportunity_Date__c,Qualified_Date__c From Contact where LastName = \'Koehler\''),1);
        Test.stopTest();
    }
    static testmethod void test2(){
        BatchToUpdateLeadandContactSch m = new BatchToUpdateLeadandContactSch();
        String sch = '0 36 1 * * ?';
        //m.errorMap.add('abc');
        String jobID = system.schedule('test update ter  tasks 1', sch, m);
    }
    static testmethod void test3(){
        BatchToUpdateContactSch m = new BatchToUpdateContactSch();
        String sch = '0 36 1 * * ?';
        //m.errorMap.add('abc');
        String jobID = system.schedule('test update ter  tasks 1', sch, m);
    }
    
    
}