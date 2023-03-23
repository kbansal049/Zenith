@isTest
public class CaseEscalationController_LWC_Test {
    @IsTest
    static void test1(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        User ur = [Select Id,Level__c from User where Service_Level__c = null and Profile.name = 'System Administrator' and isActive = true limit 1];
        ur.Level__c = 'Rep';
        update ur;
        List<DEFCON_Ranking__c> drList =new  List<DEFCON_Ranking__c>{new DEFCON_Ranking__c(Name = '1',Rank__c = 5), new DEFCON_Ranking__c(Name = '2',Rank__c = 4),
            new DEFCON_Ranking__c(Name = '3',Rank__c = 3), new DEFCON_Ranking__c(Name = '4',Rank__c = 2),
            new DEFCON_Ranking__c(Name = '5',Rank__c = 1)};
                insert drList;
        List<DEFCON_User_Mapping__c> drUserList = new List<DEFCON_User_Mapping__c>{new DEFCON_User_Mapping__c(Name = '1',Level__c = 'Exec;VP'),
            new DEFCON_User_Mapping__c(Name = '2',Level__c = 'RVP;Sr.RVP'),  new DEFCON_User_Mapping__c(Name = '3',Level__c = 'Rep;Director;Manager')};
                insert        drUserList;
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT,Defcon_Level__c='3');
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs;
        Test.startTest();
        System.runAs(ur){
            CaseEscalationController_LWC.escalateCs(cs.Id, 'abcd', 'handoff', '4', true);
            CaseEscalationController_LWC.escalateCs(cs.Id, 'abcd', 'other', '4', true);
            CaseEscalationController_LWC.escalateCs(cs.Id, 'abcd', 'other', '5', true);
            
            CaseEscalationController_LWC.escalateCs(cs.Id, 'abcd', 'other', null, true);
            CaseEscalationController_LWC.reOpenCs(cs.Id, 'reason');
            CaseEscalationController_LWC.caseHandoff(cs.Id, 'reason');
            CaseEscalationController_LWC.initcaseHandoff(cs.Id);
            CaseEscalationController_LWC.closeCs(cs.Id, 'reason');
            CaseEscalationController_LWC.checkCaseEscalation(cs.Id);
        }
        Test.stopTest();
        
    }
    @IsTest
    static void test2(){
        
        User ur = [Select Id from User where Service_Level__c = null and Profile.name = 'Core Sales - CSM' and isActive = true limit 1];
        ur.Service_Level__c = 'Support Leads';
        ur.Level__c = 'RVP';
        update ur;
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        List<DEFCON_Ranking__c> drList =new  List<DEFCON_Ranking__c>{new DEFCON_Ranking__c(Name = '1',Rank__c = 5), new DEFCON_Ranking__c(Name = '2',Rank__c = 4),
            new DEFCON_Ranking__c(Name = '3',Rank__c = 3), new DEFCON_Ranking__c(Name = '4',Rank__c = 2),
            new DEFCON_Ranking__c(Name = '5',Rank__c = 1)};
        insert drList;
        List<DEFCON_User_Mapping__c> drUserList = new List<DEFCON_User_Mapping__c>{new DEFCON_User_Mapping__c(Name = '1',Level__c = 'Exec;VP'),
            new DEFCON_User_Mapping__c(Name = '2',Level__c = 'RVP;Sr.RVP'),  new DEFCON_User_Mapping__c(Name = '3',Level__c = 'Rep;Director;Manager')};
                insert        drUserList;
        
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)', RecordTypeId=caseSupportRT);
        cs.User__c = ur.id;
        cs.Defcon_Level__c = '4';
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs;
        Id escalationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
        Case csEsc = new Case();
        csEsc.Subject = 'Defcon raised for '+cs.CaseNumber;
        csEsc.Case_Escalated_per_Defcon_Process__c = true;
        csEsc.Status = 'New';
        csEsc.Escalation_Reason__c = 'Test Escalation';
        csEsc.Escalation_Category__c = 'Unsatisfied with current support';
        csEsc.ParentId = cs.Id;
        //csEsc.EntitlementId = entitle.Id;
        csEsc.Escalated_By__c = UserInfo.getUserId();
        csEsc.Defcon_Level__c = '4';
        csEsc.RecordTypeId = escalationRecordTypeId;
        csEsc.Root_Cause_for_DEFCON__c = 'Support Technical capability lacking';
        Insert csEsc;          

        Case_Escalation_Button_Visibility__c ceb = new Case_Escalation_Button_Visibility__c();
        ceb.Name = 'Engineering_Escalation';
        ceb.Level__c = 'RVP';
        insert ceb;
        Test.startTest();
        System.runAs(ur){
            CaseEscalationController_LWC.checkCaseEscalation(cs.Id);
            CaseEscalationController_LWC.escalateCs(cs.Id, 'abcd', 'handoff', '5', true);
            CaseEscalationController_LWC.escalateCs(cs.Id, 'abcd', 'handoff', '3', true);
            CaseEscalationController_LWC.getDefconLevel(cs.Id);
        }
        Test.stopTest();
        
    }
    
    @IsTest
    static void test3(){
        Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        User ur = [Select Id,Level__c from User where Service_Level__c = null and Profile.name = 'System Administrator' and isActive = true limit 1];
        ur.Level__c = 'Rep';
        update ur;
        Case cs = new Case(Subject='abcd', Priority='Urgent (P1)');
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs;
        Case cs2 = new Case(Subject='abcd', Priority='Urgent (P1)');
        TriggerUtility.SkipCaseTriggerExecuted();
        insert cs2;
        Test.startTest();
        System.runAs(ur){
            CaseEscalationController_LWC.issueNotResolved(cs.Id, 'Test Comments');
            CaseEscalationController_LWC.issueResolved(cs2.Id);
        }
        Test.stopTest();
        
    }
}