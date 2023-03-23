@isTest
public class CloudIDrollupsyncTest {
    
    @isTest
    static void testSandboxPostCopyScript() {
		//Create account
		TriggerHandler.bypass('AccountTriggerHandler');
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
                
        Monthly_Policy_Configurations__c mpc = new Monthly_Policy_Configurations__c(Name = monthStr,Zscaler_Cloud_ID__c = zCloud.Id,
                                                                                    Account__c = account1.Id,
                                                                                    Parent_Location__c = 2);
        insert mpc;
        
        Test.startTest();
        Database.executeBatch(new CloudIDrollupsync('Select id,(Select id,Number_of_GRE_tunnels__c,Number_of_IP__c,unique_Z_app_Users__c,Total_SSL_Inspected_Transactions__c from Monthly_Policy_Configurations__r) from Zscaler_Cloud_ID__c'));
        Test.stopTest();
    }

}