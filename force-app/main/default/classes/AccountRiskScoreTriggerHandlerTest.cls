@isTest
public class AccountRiskScoreTriggerHandlerTest {
	
    @TestSetup
    private static void createTestData(){
        
       
        PatchTeam__c territory =  new PatchTeam__c();
        territory.Theater__c = 'International';
        territory.Region__c = 'SEUR';
        territory.Area__c = 'EMEA';
        insert territory;
        
       
        Account account = new Account(Name = 'Test Account');
        account.CSM_Name_New__c = UserInfo.getUserId();
        account.type = 'Customer'; 
        account.Sales_Territory__c = territory.id;
        account.Prospect_Type__c = 'Pipeline';
        account.NumberOfEmployees=400000;   
        account.No_of_Employees_Users__c='40000+';
        account.TAM_Name_New__c= UserInfo.getUserId();
        insert account;
    }
    
    @isTest 
    static void updateAccountExtentionOverallRiskTest()
    {
		Account accountRecord = [SELECT Id,CSM_Name_New__c,Type,Sales_Territory__c,
                                 Prospect_Type__c,No_of_Employees_Users__c,NumberOfEmployees
                                 FROM Account 
                                 WHERE Name = 'Test Account' LIMIT 1];
        
        Account_Extension__c accExt = TestDatafactory_Zscaler.insertAccountExtension(accountRecord.Id);
        
        Account_Risk_Score__c accRisk = new Account_Risk_Score__c(Account_Id__c = accountRecord.Id);
        accRisk.Overall_Risk__c=7;
        
        insert accRisk;
        
    }
    
}