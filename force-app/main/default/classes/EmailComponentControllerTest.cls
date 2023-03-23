@isTest
public class EmailComponentControllerTest {
    public static testMethod void EmailComponentTest(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        case cs = new case();
        cs.Status ='New';
        cs.Subject ='test sub';
        cs.AccountId = acc.Id;
        insert cs;
        test.startTest();
        EmailComponentController ec = new EmailComponentController();
        ec.accountId = acc.Id;
        ec.lingeringC = true;
        ec.getcases();
        //Added by Anup : CR#505- Start
        ec.lingeringC=false;
        ec.closedCases = true;
        ec.getcases();
        //Added by Anup : CR#505- End
        test.stopTest();
    }
    
    public static testMethod void EmailComponentTest1(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        case cs = new case();
        cs.Status ='New';
        cs.Subject ='test sub';
        cs.AccountId = acc.Id;
        insert cs;
        test.startTest();
        EmailComponentController ec = new EmailComponentController();
        ec.accountId = acc.Id;
        ec.lingeringC = true;
        ec.getcases();
        
        ec.plannerProjectsLimit = 50;
        ec.getplannerProjects();
        
        ec.plannerProjectsLimit = 0;
        ec.getplannerProjects();
        
        test.stopTest();
    }
}