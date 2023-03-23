@isTest
public class updateAccountCloseCaseDate_Test {
    public testMethod static void UpdatePriorOwnerofCase()
    {
        Account acc_ob=new Account();
        acc_ob.Name='acc1';
        insert acc_ob;
        
        
		Id typeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Weekly_Meeting').getRecordTypeId();
        Case case_ob=new Case();
        case_ob.AccountId=acc_ob.id;
        case_ob.Status='Closed';
		case_ob.subject='Test';
        case_ob.RecordTypeId=typeId;
        insert case_ob;
       
        
		Account_Extension__c ob=new Account_Extension__c();
        ob.Account__c=acc_ob.Id;
        insert ob;
            
        Test.startTest();
        	database.executeBatch(new updateAccountCloseCaseDate());
        Test.stopTest();
        
    }

}