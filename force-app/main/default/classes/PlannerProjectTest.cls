@isTest
private class PlannerProjectTest {

    @testSetup static  void testdataPrep(){
        Account testAccount = new Account();        
        testAccount.Name='Test Account' ;
        insert testAccount;
                
        List<Contact> conList = new List<Contact>();
        Contact cont = new Contact();
        cont.FirstName='Test';
        cont.LastName='Test';
        cont.Accountid= testAccount.id;
        cont.Email = 'Test@123.com';
              
        Contact cont1 = new Contact();
        cont1.FirstName='Test1';
        cont1.LastName='Test2';
        cont1.Accountid= testAccount.id;
        cont1.Email = 'Test@12.com';       
		conList.add(cont);
        conList.add(cont1);
        insert conList ;
                      
		inspire1__Project__c project = new inspire1__Project__c();
		project.Kickoff_Completed_Date__c = System.today();
        project.Design_Completed_Date__c = System.today().addDays(+1);
        project.Configuration_Completed_Date__c = System.today().addDays(+3);
        project.Pilot_Completed_Date__c = System.today().addDays(+5);
        project.Production_Completed_Date__c = System.today().addDays(+7);
        project.Project_Transition_Completed_Date__c = System.today().addDays(+21);
        project.inspire1__Project_Status__c = 'In Progress';
        project.Primary_Customer_Contact__c = conList[0].Id;
        project.Secondary_Customer_Contact__c = conList[1].id;
        insert project;       
        
    }
       static testmethod void runTest() {
       		inspire1__Project__c prj = [SELECT Id FROM inspire1__Project__c LIMIT 1 ];
			prj.inspire1__Project_Status__c = 'Completed';
           	update prj;
           Integer survey_cnt = [SELECT count() FROM Survey__c ];
           system.assertEquals(survey_cnt, 2);
       }
}