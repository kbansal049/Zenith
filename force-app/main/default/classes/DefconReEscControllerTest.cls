@isTest
public with sharing class DefconReEscControllerTest {
    static final String CASE_SUPPORT_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_SUPPORT_RECORD_TYPE_NAME);
    static final String CASE_ESCALATION_RT_ID = GCSCommonUtility.getCaseRecordTypeId(GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME);

    @testSetup static void setup() {
        //Support Case
        Case csSupport = new Case();
        csSupport.Subject = 'Test Support Case';
        csSupport.Product_New__c = 'ZIA';
        csSupport.Status = 'New';
        csSupport.Priority = 'Medium (P3)';
        csSupport.Case_Type__c = 'Problem';
        csSupport.Preferred_Contact_Time_Zone__c = 'Pacific/Chatham';
        csSupport.Preferred_Method_of_Contact__c = 'Phone';  
        csSupport.RecordTypeId = CASE_SUPPORT_RT_ID;
        insert csSupport;

        //Escalation Case
        Case csEsc = new Case();
        csEsc.Subject = 'Defcon raised for ' + csSupport.CaseNumber;
        csEsc.Case_Escalated_per_Defcon_Process__c = true;
        csEsc.Status = 'New';
        csEsc.Escalation_Reason__c = 'Test Escalation';
        csEsc.Escalation_Category__c = 'Unsatisfied with current support';
        csEsc.ParentId = csSupport.Id;
        csEsc.Escalated_By__c = UserInfo.getUserId();
        csEsc.Defcon_Level__c = '5';
        csEsc.RecordTypeId = CASE_ESCALATION_RT_ID;
        csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        insert csEsc;   

        DEFCON_ReEscalation_Mapping__c mapping = new DEFCON_ReEscalation_Mapping__c();
        mapping.Name='2';
        mapping.Level__c = 'Exec;Director;RVP;Sr.RVP;VP;Manager';
        mapping.Profile_Name__c = 'GCS Leadership Team;Customer Support - Leads - Managers';
        insert mapping;

        DEFCON_ReEscalation_Mapping__c mapping2 = new DEFCON_ReEscalation_Mapping__c();
        mapping2.Name='3';
        mapping2.Level__c = '';
        mapping2.Profile_Name__c = 'Core Sales - CSM;Core Sales - SE';
        insert mapping2;

        DEFCON_ReEscalation_Mapping__c mapping3 = new DEFCON_ReEscalation_Mapping__c();
        mapping3.Name='4';
        mapping3.Level__c = '';
        mapping3.Profile_Name__c = 'TAM (Licensed);System Administrator';
        insert mapping3;
    }

    @IsTest 
    static void testReEsc(){
        String reason='testing1';        Test.StartTest();
            String caseId = [SELECT Id FROM Case WHERE RecordType.Name = :GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME].Id;
            DefconReEscalationController.updateDefcon(reason,  caseId);        
        Test.StopTest();
    }

    @IsTest 
    static void testReEsc2(){
        String reason='testing1';
        Test.StartTest();
            String caseId = [SELECT Id FROM Case WHERE RecordType.Name = :GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME].Id;
            try{
                DefconReEscalationController.IS_INVOKED_FROM_SLACK_SDK = true;
                DefconReEscalationController.updateDefcon(reason,  caseId);
            }catch(AuraHandledException ex){
                System.debug(''+ex.getMessage());
            }
        Test.StopTest();
    }

    @IsTest 
    static void testReEsc3(){
        List<case> escCase = [SELECT Id, Defcon_Level__c, Status FROM Case WHERE RecordType.Name = :GCSCommonConstants.CASE_ESCALATION_RECORD_TYPE_NAME];
        escCase[0].Defcon_Level__c = '2';
        escCase[0].Status = 'Needs Follow Up';
        update escCase;
        
        String reason = 'testing1';
        Test.StartTest();
            String caseId = escCase[0].Id;
            try{            
                DefconReEscalationController.updateDefcon(reason,  caseId);
            }catch(AuraHandledException ex){
                System.debug(''+ex.getMessage());
            }
        Test.StopTest();
    }
}