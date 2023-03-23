/////This test class tests the sync between commercial to Fed 5 Account fields for cloud usage
@isTest
public class SYNCCLOUDUSAGE_test {
    
    @isTest
    static void getlstofleads() {
        Account acc = new Account(Name = 'accname' , Is_Federal_Account_Sync__c = true);
        insert acc;
        Map<String, Account> accmap = new Map<String, Account>();
        //  SELECT Id, Production_Account_ID__c, Authenticated_Users_Deployed__c, Production_Account_Name__c,Purchased_Users_Vs_Authenticated_Users__c ,ZPA_Enrolled_users_L31D_Vs_Purchase__c ,ZPA_Enrolled_Users_L31D__c,ZPA_Enrolled_Users_L90D__c FROM Account where  where Is_Federal_Account_Sync__c = true]){
        accmap.put(acc.id, acc);

        
            Test.startTest();
            // Stsrt the test
            // SYNCCLOUDUSAGE
            Map<String,List<String>> result = SYNCCLOUDUSAGE.doPost(accmap);
            System.debug(result);   
            Test.stopTest();
            
    }
     static void getlstofleads1() {
        Account acc = new Account(Name = 'accname' , Is_Federal_Account_Sync__c = true);
        insert acc;
        Map<String, Account> accmap = new Map<String, Account>();
        //  SELECT Id, Production_Account_ID__c, Authenticated_Users_Deployed__c, Production_Account_Name__c,Purchased_Users_Vs_Authenticated_Users__c ,ZPA_Enrolled_users_L31D_Vs_Purchase__c ,ZPA_Enrolled_Users_L31D__c,ZPA_Enrolled_Users_L90D__c FROM Account where  where Is_Federal_Account_Sync__c = true]){
        accmap.put(acc.id, acc);

        
            Test.startTest();
            delete acc;
            // Stsrt the test
            // SYNCCLOUDUSAGE
            Map<String,List<String>> result = SYNCCLOUDUSAGE.doPost(accmap);
            System.debug(result);   
            Test.stopTest();
            
    }
    
}