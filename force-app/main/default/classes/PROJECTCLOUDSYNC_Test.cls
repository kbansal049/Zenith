@isTest
public class PROJECTCLOUDSYNC_Test{
   
    static testMethod void getlstofleads() {
        
        Account acc = new Account(Name = 'accname');
        insert acc;
        Account acc1 = new Account(Name = 'accname');
        insert acc1;
        Opportunity opp = new Opportunity(name='opp1', stagename = Label.Stage_1_Alignment, closedate = date.today(),accountId = acc.Id, Is_Federal_Opportunity_Sync__c = true);
        insert opp;
        List<Equipment_Request__c> oppartlst = new List<Equipment_Request__c>();
        Equipment_Request__c pt = new Equipment_Request__c();
        pt.Opportunity__c=opp.id;
        pt.name = 'Test Product and services' ;
        oppartlst.add(pt);
        insert oppartlst;
        pt.Approval_Status__c = 'Approved';
        update oppartlst;
        Test.startTest();
        PROJECTCLOUDSYNC.doPost(oppartlst);
        Test.stopTest();

    }

}