global without sharing class genericApprovalActionController {
    @AuraEnabled
    public static void approveRejectRecord(String action, String comments, List<Id> recIds){
        if(!recIds.isEmpty()){
            Map<Id, ProcessInstanceWorkitem> pItemlst = new Map<Id, ProcessInstanceWorkitem>([Select Id from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId in :recIds]);
            List<Approval.ProcessWorkitemRequest> reqlst = new List<Approval.ProcessWorkitemRequest>(); 
            String SalesOpsSystemAdminUser= ZscalerCustomSetting__c.getInstance('SalesOpsSystemAdminUserID')!=null && ZscalerCustomSetting__c.getInstance('SalesOpsSystemAdminUserID').Value__c!=null ? ZscalerCustomSetting__c.getInstance('SalesOpsSystemAdminUserID').Value__c:'00570000002GeGO';
            id sfAdminUser=id.valueof(SalesOpsSystemAdminUser);
            for(Id pId: pItemlst.keySet()){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments(comments);
                req.setAction(action);
                req.setWorkitemId(pId);
                reqlst.add(req);
            }
            if(!reqlst.isEmpty()){
                Approval.ProcessResult[] result =  Approval.process(reqlst);
            }         
        }
    }
    @AuraEnabled
    public static void submitRecord(List<SubmitRecordWrapper> reqList){
        List<Approval.ProcessSubmitRequest> approvalProcessRequestList = new List<Approval.ProcessSubmitRequest>();
        for(SubmitRecordWrapper req: reqList){
            Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
            if(req.comment != '' && req.comment != null){
                newApprovalRequest.setComments(req.comment);
            }
            if(req.recordId != null && req.recordId != ''){
                newApprovalRequest.setObjectId(req.recordId);
            }
            if(req.submitterId != null && req.submitterId != ''){
                newApprovalRequest.setSubmitterId(req.submitterId);
            }
            if(req.skipEntryCriteria){
                newApprovalRequest.setSkipEntryCriteria(req.skipEntryCriteria);
            }
            if(req.nextApproverIds != null && !req.nextApproverIds.isEmpty()){
                newApprovalRequest.setNextApproverIds(req.nextApproverIds);
            }
            approvalProcessRequestList.add(newApprovalRequest);
        }
        if(approvalProcessRequestList.size() > 0) {
            for (Approval.ProcessSubmitRequest processRequest : approvalProcessRequestList) {
                Approval.ProcessResult result = Approval.process(processRequest);
            }
        }
    }

    public class SubmitRecordWrapper{
        @AuraEnabled
        public string submitterId;
        @AuraEnabled
        public string recordId;
        @AuraEnabled
        public string comment;
        @AuraEnabled
        public List<Id> nextApproverIds;
        @AuraEnabled
        public boolean skipEntryCriteria;
    }
}