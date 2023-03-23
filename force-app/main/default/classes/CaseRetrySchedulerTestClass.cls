@isTest
public class CaseRetrySchedulerTestClass {
    @isTest static void testMethod1() {
        List<case> caseList = new List<case>();
    	case cs=  new case();
		cs.Case_Category__c = 'Accounts';
		cs.Case_Sub_Category__c = 'Other';
		cs.TAM_Unassigned_Reason__c = 'test';
		cs.accountId = '0018J00000CbQrAQAV';
        cs.subject = 'testcase';
        cs.Product_New__c = 'ZIA';
        cs.status = 'New';
        caseList.add(cs);
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second() + 5);
        string num = ss + ' ' + min + ' ' + hour+ ' 1';
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        CaseRetrySchedulerClass cst = new CaseRetrySchedulerClass(caseList,5,'test');
        System.schedule('Case retry Job Started '+num, nextFireTime,cst);    
    }
    @isTest static void testMethod2() {
        List<case> caseList = new List<case>();
    	case cs=  new case();
		cs.Case_Category__c = 'Accounts';
		cs.Case_Sub_Category__c = 'Other';
		cs.TAM_Unassigned_Reason__c = 'test';
		cs.accountId = '0018J00000CbQrAQAV';
        cs.subject = 'testcase';
        cs.Product_New__c = 'ZIA';
        cs.status = 'New';
        caseList.add(cs);
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second() + 5);
        string num = ss + ' ' + min + ' ' + hour+ ' 1';
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        CaseRetrySchedulerClass cst = new CaseRetrySchedulerClass(caseList,3,'test');
        System.schedule('Case retry Job Started '+num, nextFireTime,cst);    
    }
}