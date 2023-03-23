/**
 * Class Name : CaseDefconEscalationController
 * Test Class : CaseDefconEscalationControllerTest
 * Description : Controller of caseDefconEscalationLWC - Displays Defcon Details from the Case(Escalation) record
 */

public class CaseDefconEscalationController {
    
    @AuraEnabled(cacheable=true)
    public static resultWrapper getCurrentDefcon(String caseId){
        try{
            String defconLevel = '';
            String defconId = '';
            String defconNumber = '';
            String defconSubject = '';
            Boolean isEscalated = false;
            
            Id escRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
            //Added by Ankit - IBA-3048 - Starts
            if(String.isNotBlank(caseId)) {
               List<Case> escalatedCaseList = [SELECT Id, CaseNumber, Subject, ParentId, RecordTypeId, Defcon_Level__c FROM Case WHERE ParentId = :caseId AND RecordTypeId=:escRecordTypeId];
                if(!escalatedCaseList.isEmpty()){
                    defconLevel = escalatedCaseList.get(0).Defcon_Level__c; 
                    defconId = escalatedCaseList.get(0).Id;
                    defconNumber = escalatedCaseList.get(0).CaseNumber;
                    defconSubject = escalatedCaseList.get(0).Subject;
                }   
            }
            //Added by Ankit - IBA-3048 - Ends
            ResultWrapper resultWrapper = new ResultWrapper(defconLevel, defconId, defconNumber, defconSubject);
            return resultWrapper;
        }
        catch(Exception e) {
            ZscalerErrorLogsUtility.insertlogs('CaseDefconEscalationController', 'getCurrentDefcon', 'Apex', UserInfo.getUserId(), 'Service cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ResultWrapper{
        @AuraEnabled public String defconLevel;
        @AuraEnabled public String defconId;
        @AuraEnabled public String defconNumber;
        @AuraEnabled public String defconSubject;

        public ResultWrapper(String defLevel, String defId, String defNumber, String defSubject){
            defconLevel = defLevel;
            defconId = defId;
            defconNumber = defNumber;
            defconSubject = defSubject;
        }
    }
}