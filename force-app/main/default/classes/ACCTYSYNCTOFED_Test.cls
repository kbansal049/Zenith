/////This test class tests the sync between commercial to Fed 5 Account fields. 

@isTest
public class ACCTYSYNCTOFED_Test {
    
    @isTest
    static void getlstofleads() {
        Account acc = new Account(Name = 'accname' , Is_Federal_Account_Sync__c = true);
        insert acc;
        
        List<Account> acclst = [SELECT Id, Name,type, First_ZDX_Contract_Date__c, No_Of_ZDX_Platform_Users__c , Total_ZPA_Platform_Users_Purchased__c, Total_ZIA_Platform_Users_Purchased__c,First_ZPA_Contract_Date__c,  First_Contract_Date__c, Is_Federal_Account_Sync__c  FROM Account where Is_Federal_Account_Sync__c = true];      
        System.debug('acclst'+ acclst);
        
        Test.startTest();
        // Stsrt the test
        ACCTYSYNCTOFED.doGet();
        Test.stopTest();
        
    }
    
}