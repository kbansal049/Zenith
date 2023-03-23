/////This test class tests the sync between commercial to Fed 5 Account fields for cloud usage

@isTest
public class SYNCACCCLOUDUSAGE_Test {
    
    @isTest
    static void getlstofleads1() {
        Account acc = new Account(name= 'accName');
        insert acc;
        Customer_Score_Card__c cust = new Customer_Score_Card__c(Account__c= acc.id, Auth_ZIA_users_deployed_LM_Vs_LM_1__c = 1, Auth_ZIA_users_deployed_LM_Vs_LM_6__c=2);
        insert cust;
        
        Map<String, Account> accmap = new Map<String, Account>();
        accmap.put(acc.id, acc);

        Map<String,Customer_Score_Card__c> mapScoreCard = new Map<String,Customer_Score_Card__c>();
        
        mapScoreCard.put(acc.id, cust);
        
        SYNCACCCLOUDUSAGE.doPost(accmap, mapScoreCard);
            Test.startTest();
            // Stsrt the test
            // SYNCCLOUDUSAGE
            Map<String,List<String>> result =   SYNCACCCLOUDUSAGE.doPost(accmap, mapScoreCard);
            System.debug(result);   
            Test.stopTest();
        }
    }