@isTest
private class CaseEscalationResolutionController_Test {

    @isTest static void testmethod1() {
        Case c = new Case();
        c.Status = 'Pending Customer';
        c.Subject = 'test';
        c.Description = 'test dessc';
        insert c;
        
        Case_Notes_History__c cs = new Case_Notes_History__c(); 
        cs.Escalation_Notes__c = 'dfds';
        cs.case__c = c.id;
        insert cs;
        
        test.startTest();
        CaseEscalationResolutionController.getCaseNotesHistory(c.id);
        
        test.stopTest();
        
    }
}