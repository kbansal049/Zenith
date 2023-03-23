@isTest
public class MeetingTriggerHandlerTest{
    
    static testmethod void test1(){
        
        Triggers_Switch__c trg = new Triggers_Switch__c();
        trg.Name = 'Execute_Meeting_Trigger';
        trg.Object_Name__c = 'Meeting__c';
        trg.Execute__c = true;
        insert trg;
        
        Triggers_Switch__c trg1 = new Triggers_Switch__c();
        trg1.Name = 'Execute_Meeting_Objective_Creation';
        trg1.Object_Name__c = 'Meeting__c';
        trg1.Execute__c = true;
        insert trg1;
        
        Triggers_Switch__c trg2 = new Triggers_Switch__c();
        trg2.Name = 'Auto_Create_ActionPlan';
        trg2.Object_Name__c = 'Action_Plan__c';
        trg2.Execute__c = true;
        insert trg2;
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Account_Extension__c accExt = new Account_Extension__c();
        accExt.Account__c  = account.Id;
        insert accExt;
        
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Case cs1 = new Case(Subject='abcd2', AccountId =  account.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        insert cs1;
        
        Case cs = new Case(Subject='abcd', AccountId =  account.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem', Master_Case__c=cs1.Id);
        insert cs;
        
        Id bulkActionsRTId = Schema.SObjectType.Central_Content__c.getRecordTypeInfosByDeveloperName().get('Bulk_Actions').getRecordTypeId();
		Central_Content__c cc = new Central_Content__c(RecordTypeId = bulkActionsRTId, name = 'Test', expiry_date__c = System.today().addDays(4),Detail_TAM_Notes__c='Test');
        insert cc;
        
        Meeting__c meet = new Meeting__c();
        meet.Customer_Name__c = account.Id;
        meet.Date_of_meeting__c = System.now();
        meet.Executive_Summary__c = 'Test';
        meet.Status__c = 'Completed';
        insert meet;
    }
    
    static testmethod void test2(){
        // MeetingTriggerHandler.beforeUpdate(null, null);
        MeetingTriggerHandler.afterUpdate(null, null, null);
    }
    
    static testmethod void test3(){
        Triggers_Switch__c trg = new Triggers_Switch__c();
        trg.Name = 'Execute_ValidateCompletedStatus';
        trg.Object_Name__c = 'Meeting__c';
        trg.Execute__c = true;
        insert trg;
        Account account = new Account(Name = 'Test Account');
        insert account;
        Meeting__c meet = new Meeting__c();
        meet.Customer_Name__c = account.Id;
        meet.Date_of_meeting__c = System.now();
        meet.Executive_Summary__c = 'Test 2';
        meet.Status__c = 'Scheduled';
        meet.Participants__c='test@test.com';
        insert meet;
        Id meetingId=meet.Id;
        EmailMessage em= new EmailMessage();
        em.RelatedToId=meetingId;
        em.Incoming=false;
        em.HtmlBody='test';
        em.ToAddress='test@test.com';
        insert em;
        meet.Status__c='Completed';
        update meet;
    }
    static testmethod void test4(){
        Triggers_Switch__c trg = new Triggers_Switch__c();
        trg.Name = 'Execute_UpdateParticipants';
        trg.Object_Name__c = 'Meeting__c';
        trg.Execute__c = true;
        insert trg;
         Triggers_Switch__c trg2 = new Triggers_Switch__c();
        trg2.Name = 'Execute_Meeting_Trigger';
        trg2.Object_Name__c = 'Meeting__c';
        trg2.Execute__c = true;
        insert trg2;
        Account account = new Account(Name = 'Test Account');
        insert account;
        Meeting__c meet = new Meeting__c();
        meet.Customer_Name__c = account.Id;
        meet.Date_of_meeting__c = System.now();
        meet.Executive_Summary__c = 'Test 2';
        meet.Status__c = 'Scheduled';
        meet.Participants__c='test@test.com';
        meet.Copy_CC_List_From_Previous_TAM_Meeting__c=true;
        insert meet;
    }
}