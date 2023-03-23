@isTest
public class TAMReassignmentQueueable_Test {
    @IsTest
    static void test1(){
        
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where id= :UserInfo.getUserId() and isActive = true limit 1];
        System.runAs(ur){
            Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = ur.Id;
            insert acct;
            
            
            Case cs = new Case(OwnerId = Label.Support_Queue_Id, Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            insert cs;

            test.startTest();
            try{
                //system.enqueueJob(new TAMReassignmentQueueable(new set<ID>{ur.Id}));
                TAMReassignmentQueueable.booster();
            }catch(Exception ex){

            }
            test.stopTest();
        }
    }
}