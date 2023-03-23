@isTest
public class UpdateTAMEmailonCase_Test{
    static testmethod void test1(){
        
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User ur = [Select Id from User where Service_Level__c = null and Profile.name = 'System Administrator' and isActive = true limit 1];
        System.runAs(ur){
            Account acct = new Account();
            acct.name = 'Test Account';
            acct.Type = 'Customer';
            acct.RecordTypeId = '01270000000EAFsAAO';
            acct.X3rd_TAM_Name__c = userinfo.getuserid();
            acct.TAM_Name_New__c = userinfo.getuserid();
            acct.Secondary_TAM_Name__c = userinfo.getuserid();
            
            insert acct;
            
            Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
            
            TriggerUtility.CaseBeforeUpdateExecuted();
            TriggerUtility.CaseAfterUpdateExecuted();
            
            insert cs;
            
            
            String query = 'Select Id,Accountid,Account.X3rd_TAM_Name__r.email,Account.TAM_Name_New__r.email,Account.Secondary_TAM_Name__r.email,Primary_TAM_Email__c,X3rd_TAM_Email__c,Secondary_TAM_Email__c from Case';
            UpdateTAMEmailonCase btch = new UpdateTAMEmailonCase(query,'Support');
            database.executebatch(btch,200);
        }
    }
    
}