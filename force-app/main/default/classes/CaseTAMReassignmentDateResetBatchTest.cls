@isTest
public class CaseTAMReassignmentDateResetBatchTest {
    @isTest 
    public static void testTAMReassignmentMethods(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        User usr2 = TestDatafactory_Zscaler.insertAdminUser('2xyz@xyz.com', 'test12', 'test', 'ttest12', '2xyz@xyz.com.test', 'GMT', 'en_US', 'UTF-8', 'en_US');
        User usr3 = TestDatafactory_Zscaler.insertAdminUser('2xyz@xy1z.com', 'test121', 'tes1t', 'ttest121', '2xyz@xyz.com.test1', 'GMT', 'en_US', 'UTF-8', 'en_US');
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct = new Account();
        acct.name = 'Test Account 1';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.X3rd_TAM_Name__c = usr2.Id;
        acct.TAM_Name_New__c = usr2.Id;
        acct.Secondary_TAM_Name__c = usr2.Id;
        insert acct;
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acct1 = new Account();
        acct1.name = 'Test Account 1';
        acct1.Type = 'Customer';
        acct1.RecordTypeId = '01270000000EAFsAAO';
        acct1.Secondary_TAM_Name__c = usr3.Id;
        insert acct1;
        
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',Status = 'New');
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs;
        
        Case cs1 = new Case(Subject='abcd1', AccountId =  acct1.Id, Priority='Medium (P3)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem',Status = 'New');
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs1;
        
        Case currentCase = [select id,Account.Secondary_TAM_Name__c,Account.Secondary_TAM_Name__r.Out_Of_Office__c, No_of_TAM_Reassignment_Attempts__c,RecordType.Name,TAM_Assignment__c, OwnerId,Next_TAM_Date__c, Is_TAM_Account__c, Is_Current_Owner_TAM__c, Priority, Product_New__c,Case_Type__c from Case where id=:cs.Id];
        
        CaseTriggerUtility.checkTAMReassignment(new List<Case>{currentCase}, null);
        currentCase.Next_TAM_Date__c = System.Now();
        currentCase.TAM_Assignment__c = 'Assigned To Support';
        update cs;
        TriggerUtility.SkipCaseTriggerReset();
        CaseTriggerUtility.checkTAMReassignment(new List<Case>{currentCase}, null);
        
        usr2.Out_Of_Office__c=  true;
        usr2.Start_Date__c = system.today();
        usr2.Returning_Date__c = system.today().addDays(1);
        update usr2;
        currentCase.TAM_Assignment__c= 'Pending TAM Assignment';
        TriggerUtility.AssignTAMOwnerReset();
        TriggerUtility.SkipCaseTriggerReset();
        //update currentCase;
        
        Map<Id, Case> mapOfIdAndCase = new Map<Id, Case>();
        mapOfIdAndCase.put(currentCase.Id, currentCase);
        //CaseTriggerUtility.assignTamAsOwner(new List<Case>{currentCase}, mapOfIdAndCase);
        
        Case currentCase2 = [select id,Account.Secondary_TAM_Name__c,Account.Secondary_TAM_Name__r.Out_Of_Office__c, No_of_TAM_Reassignment_Attempts__c,RecordType.Name,TAM_Assignment__c, OwnerId,Next_TAM_Date__c, Is_TAM_Account__c, Is_Current_Owner_TAM__c, Priority, Product_New__c from Case where id=:cs1.Id];
        Map<Id, Case> mapOfIdAndCase2 = new Map<Id, Case>();
        mapOfIdAndCase2.put(currentCase2.Id, currentCase2);
        //CaseTriggerUtility.assignTamAsOwner(new List<Case>{currentCase2}, mapOfIdAndCase2);
        
        usr2.Out_Of_Office__c=  false;
        usr2.Returning_Date__c = null;
        usr2.Start_Date__c = null;
        update usr2;
        acct1.Secondary_TAM_Name__c = null;
        acct1.X3rd_TAM_Name__c = usr2.Id;
        update acct1;
        
        Case currentCase3 = [select id,Account.X3rd_TAM_Name__c,Account.X3rd_TAM_Name__r.Out_Of_Office__c, No_of_TAM_Reassignment_Attempts__c,RecordType.Name,TAM_Assignment__c, OwnerId,Next_TAM_Date__c, Is_TAM_Account__c, Is_Current_Owner_TAM__c, Priority, Product_New__c from Case where id=:cs1.Id];
        Map<Id, Case> mapOfIdAndCase3 = new Map<Id, Case>();
        mapOfIdAndCase3.put(currentCase3.Id, currentCase3);
        //CaseTriggerUtility.assignTamAsOwner(new List<Case>{currentCase3}, mapOfIdAndCase3);
    
        cs.Next_TAM_Date__c = System.Now().addDays(-2);
        update cs;
        

        CaseTAMReassignmentDateResetHandler.resetTAMReassignmentDate();
    }
}