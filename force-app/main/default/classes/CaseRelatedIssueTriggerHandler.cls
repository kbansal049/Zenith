/**
 * Name : CaseRelatedIssueTriggerHandler
 * Description : Handler class for CaseRelatedIssueTrigger
 * Test Class : CaseRelatedIssueTriggerHandlerTest
 * Initial Author : Ankit Bhatnagar
 */
  
public class CaseRelatedIssueTriggerHandler extends TriggerHandler{
    
    public override void beforeInsert(){
        //A Case cannot be related to an already closed Incident
        closedIncidentValidation((List<CaseRelatedIssue>)Trigger.new);
        olderCaseValidation((List<CaseRelatedIssue>)Trigger.new);
    }

    public override void afterInsert() {
        //Added by Chetan - Start
        //Update Reporting fields on Incidents
        UpdateIncidentFields Qjob= new UpdateIncidentFields((List<CaseRelatedIssue>)Trigger.new);
        System.enqueueJob(Qjob);
        //Added by Chetan - End
        CaseRelatedIssuesSendUpdates Qjob2= new CaseRelatedIssuesSendUpdates((List<CaseRelatedIssue>)Trigger.new);
        System.enqueueJob(Qjob2);
    }

    public override void beforeDelete() {
        //Added by Chetan - Start
        //Update Reporting fields on Incidents
        UpdateIncidentFields Qjob= new UpdateIncidentFields((List<CaseRelatedIssue>)Trigger.old);
        System.enqueueJob(Qjob);
        //Added by Chetan - End
    }

    public void closedIncidentValidation(List<CaseRelatedIssue> caseRelatedIssues) {
        Map<String, String> incidentStatusMap = new Map<String, String>();
        for(CaseRelatedIssue cri : caseRelatedIssues) {
            if(cri.RelatedIssueId.getSObjectType().getDescribe().getName() == 'Incident' && !incidentStatusMap.containsKey(cri.RelatedIssueId)) {
                incidentStatusMap.put(cri.RelatedIssueId, '');
            }
        }
        if(!incidentStatusMap.isEmpty()) {
            for(Incident i : [SELECT id,Status FROM Incident WHERE Id IN : incidentStatusMap.keySet() AND RecordType.DeveloperName = 'Cloud_Incident']) {
                incidentStatusMap.put(i.Id, i.Status);
            }
            for(CaseRelatedIssue cri : caseRelatedIssues) {
                if(incidentStatusMap.containsKey(cri.RelatedIssueId) && incidentStatusMap.get(cri.RelatedIssueId)=='Closed') {
                    cri.addError('You cannot associate a case with a Closed Incident.');
                }                
            }  
        }
    }

    public void olderCaseValidation(List<CaseRelatedIssue> caseRelatedIssues) {
        Map<String, String> criIncidentMap = new Map<String, String>();
        Map<String, String> criCaseMap = new Map<String, String>();
        Map<String, Case> caseMap = new Map<String, Case>();
        Map<String, Incident> incidentMap = new Map<String, Incident>();

        for(CaseRelatedIssue cri : caseRelatedIssues) {
            if(cri.RelatedIssueId.getSObjectType().getDescribe().getName() == 'Incident') {
                criIncidentMap.put(cri.Id, cri.RelatedIssueId);
                criCaseMap.put(cri.Id, cri.CaseId);
            }
        }
        if(!criIncidentMap.isEmpty() && !criCaseMap.isEmpty()) {
            for(Incident i : [SELECT id,Status,createdDate FROM Incident WHERE Id IN : criIncidentMap.values() AND RecordType.DeveloperName = 'Cloud_Incident']) {
                incidentMap.put(i.Id, i);
            }
            for(Case c : [SELECT id,Status,createdDate FROM Case WHERE Id IN : criCaseMap.values()]) {
                caseMap.put(c.Id, c);
            }
            for(CaseRelatedIssue cri : caseRelatedIssues) {
                if(incidentMap.containsKey(cri.RelatedIssueId) && caseMap.containsKey(cri.caseId)) {
                    Date incidentDate = Date.valueOf(incidentMap.get(cri.RelatedIssueId).createdDate);
                    Date caseDate = Date.valueOf(caseMap.get(cri.caseId).createdDate);
                    if(incidentDate > caseDate && caseDate.daysBetween(incidentDate) > 3) {
                        cri.addError('This Case is older and cannot be linked to this Incident Record');
                    }
                }                
            }  
        }
    }
}