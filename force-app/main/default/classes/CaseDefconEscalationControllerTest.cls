@IsTest
public class CaseDefconEscalationControllerTest {
    @testSetup static void setup() {
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
         //Support Case
         Case csSupport = new Case();
         csSupport.Subject = 'Test Support Case';
         csSupport.Product_New__c = 'ZIA';
         csSupport.Status = 'New';
         csSupport.Priority = 'Medium (P3)';
         csSupport.Case_Type__c = 'Problem';
         csSupport.Preferred_Contact_Time_Zone__c = 'Pacific/Chatham';
         csSupport.Preferred_Method_of_Contact__c = 'Phone';  
         csSupport.RecordTypeId = caseSupportRT;              

         Insert csSupport;

          //Escalation Case
        Case csEsc = new Case();
        csEsc.Subject = 'Defcon raised for '+csSupport.CaseNumber;
        csEsc.Case_Escalated_per_Defcon_Process__c = true;
        csEsc.Status = 'New';
        csEsc.Escalation_Reason__c = 'Test Escalation';
        csEsc.Escalation_Category__c = 'Unsatisfied with current support';
        csEsc.ParentId = csSupport.Id;
        //csEsc.EntitlementId = entitle.Id;
        csEsc.Escalated_By__c = UserInfo.getUserId();
        csEsc.Defcon_Level__c = '4';
        csEsc.RecordTypeId = escalationRecordTypeId;
        csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        Insert csEsc;          

    }

    @IsTest 
    static void testCurrentDefcon(){                 
        Test.StartTest();
        String caseParentId = [Select Id,ParentId From Case Where RecordType.Name='Escalation'].ParentId;
        
        CaseDefconEscalationController.getCurrentDefcon(caseParentId);        
        Test.StopTest();
    }

	
}