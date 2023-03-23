@IsTest
public class CaseSpecialInstructionCmpCtrlTest {
    @IsTest
    public static void test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.Account_Special_Instructions__c='Test Instruction';
        insert acct;
        Case cs = new Case(Subject='abcd', AccountId =  acct.Id, Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        insert cs;
		String caseId = cs.Id;
        String inst = CaseSpecialInstructionCmpCtrl.fetchAccountSpecialInst(cs.Id);

        acct.Account_Special_Instructions__c=null;
        update acct;
        String inst2 = CaseSpecialInstructionCmpCtrl.fetchAccountSpecialInst(cs.Id);
        String inst3 = CaseSpecialInstructionCmpCtrl.fetchAccountSpecialInst(null);
        /*Case cs2 = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT, Defcon_Level__c='3', Description='abcdDes', Case_type__c = 'Problem');
        insert cs2;*/
        delete cs;
        String inst4 = CaseSpecialInstructionCmpCtrl.fetchAccountSpecialInst(caseId);
    }
    
}