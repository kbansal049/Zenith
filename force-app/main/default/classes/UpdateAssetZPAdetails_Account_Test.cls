@isTest
public class UpdateAssetZPAdetails_Account_Test{
    
    static testmethod void test1(){
        
        PatchTeam__c SalesTerritory = new PatchTeam__c();
        SalesTerritory.Name = 'Test';
        SalesTerritory.Theater__c = 'CHANNEL';
        SalesTerritory.Account_Manager__c = userinfo.getuserid();
        SalesTerritory.Theater__c = 'CHANNEL';
        SalesTerritory.Region__c = 'Channel SP/SI';
        SalesTerritory.District__c = 'Channel SP';
        SalesTerritory.Area__c = 'Channel SP';
        
        insert SalesTerritory;
        
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.CSM_Name_New__c = userinfo.getuserid();
        acct.First_ZPA_Contract_Date__c = system.today().adddays(-11);
        acct.Sales_Territory__c = SalesTerritory.Id;
        insert acct;
        
        String query='Select id from Account';
        UpdateAssetZPAdetails_Account cae= new UpdateAssetZPAdetails_Account(query);
        database.executebatch(cae,1);
    }
}