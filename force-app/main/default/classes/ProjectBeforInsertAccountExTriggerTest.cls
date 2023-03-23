@isTest
public class ProjectBeforInsertAccountExTriggerTest {
    
    static testMethod void myUnitProjectTest() {
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        
        Triggers_Switch__c triSwitch = new Triggers_Switch__c(Name='UpdateProjectAccountExtentsion', Object_Name__c='inspire1__Project__c', Execute__c=true);
        insert triSwitch;
        
        Triggers_Switch__c triSwitch1 = new Triggers_Switch__c(Name='Execute_Project_Trigger', Object_Name__c='inspire1__Project__c', Execute__c=true);
        insert triSwitch1;
        
        PatchTeam__c team = new PatchTeam__c(Name='Test',Theater__c='International');
        insert team;
        
        Account testAccount = new Account(Name='My test Project account', Sales_Territory__c= team.Id); 
        insert testAccount;
        
        Account_Extension__c testAccountEx = new Account_Extension__c(Account__c = testAccount.id);
        insert testAccountEx; 
        
        Test.startTest();
        inspire1__Project__c testProject = new inspire1__Project__c(inspire1__Account__c= testAccountEx.Account__c);
        insert testProject;
        Test.stopTest();
        
        
    }

}