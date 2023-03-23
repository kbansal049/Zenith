public class KnowledgeRecallApprovals {

    @InvocableMethod(label='Recall KB Approval Processes')
    public static List<Boolean> recallKnowledgeApprovals(List<String> knowledgeId) {
        Boolean isError = false;
        List<Approval.ProcessWorkitemRequest> reqs = new List<Approval.ProcessWorkitemRequest>();
        List<ProcessInstanceWorkitem> piwiList = new List<ProcessInstanceWorkitem>([SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId,ProcessInstance.Status
                                                                                    FROM ProcessInstanceWorkitem 
                                                                                    WHERE ProcessInstance.TargetObjectId IN :knowledgeId AND ProcessInstance.Status='Pending']);
        for(ProcessInstanceWorkitem piwi : piwiList) {
            System.debug('## 2 : piwi' + piwi);
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Removed');       
            req.setWorkitemId(piwi.Id);
            reqs.add(req);
        }
        if(!reqs.isEmpty()) {
            Approval.ProcessResult[] results = Approval.process(reqs,false);
            if(!results.isEmpty() && !results.get(0).isSuccess() && !results.get(0).getErrors().isEmpty()) {
                if(String.valueOf(results.get(0).getErrors().get(0).getStatusCode()) == 'INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY') {
                    isError = true;
                }
            }
        }
        return new List<Boolean>{isError};
    }
}