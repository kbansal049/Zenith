public class CaseEscalationResolutionController {
	@AuraEnabled
    public static List<Case_Notes_History__c>  getCaseNotesHistory(Id caseId) {
        List<Case_Notes_History__c>  cnhList = [Select id, Case__c, Customer_Temperature__c, Escalation_Notes__c, 
                                                Escalation_Stage__c,Escalation__c,Case__r.Escalation_Closure_Notes__c FROM Case_Notes_History__c where 
                                                Case__c =: caseId order by createddate desc limit 1];
        return cnhList;
    } 
}