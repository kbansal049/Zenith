@isTest
public class UpdateParentLocationsAccountBatchTest {
    @IsTest
    static void test1(){
        //Create account
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Partner' Limit 1]; 
        Account account1 = new Account(
            Name = 'TestAccount',
            recordTypeId=rt.id
        );
        Database.insert(account1);
        
        Zscaler_Cloud_ID__c zCloud = new Zscaler_Cloud_ID__c(Name = 'test1', Account__c = account1.Id);
        insert zCloud;
        
        Map<integer, string> monthMap = new Map<Integer, String>();
        monthMap.put(1, 'January');
        monthMap.put(2, 'February');
        monthMap.put(3, 'March');
        monthMap.put(4, 'April');
        monthMap.put(5, 'May');
        monthMap.put(6, 'June');
        monthMap.put(7, 'July');
        monthMap.put(8, 'August');
        monthMap.put(9, 'September');
        monthMap.put(10, 'October');
        monthMap.put(11, 'November');
        monthMap.put(12, 'December');
                                                                                                
        Integer month = System.today().month();

        string monthStr = monthMap.get(month) + ' ' + System.today().year();
        
        system.debug('aaaaaaa - ' + monthStr);        
        Monthly_Policy_Configurations__c mpc = new Monthly_Policy_Configurations__c(Name = monthStr,Zscaler_Cloud_ID__c = zCloud.Id, Account__c = account1.Id, Parent_Location__c = 2);
        insert mpc;
        
        Test.startTest();
        system.schedule('Parent Location Job', '0 0 0 * * ?', new UpdateParentLocationsAccountBatchSch());        

        UpdateParentLocationsAccountBatch batch;
        batch = new UpdateParentLocationsAccountBatch('select id from Account');
        batch.errorlst.add('Test Error');
        Database.executeBatch(batch,10);
        Test.stopTest();        
                
        Customer_Score_Card__c csc = [select id, No_of_Parent_location__c from Customer_Score_Card__c where Account__c =: account1.Id and No_of_Parent_location__c != null limit 1];
        system.assertEquals(csc.No_of_Parent_location__c,2);
        
    }

}