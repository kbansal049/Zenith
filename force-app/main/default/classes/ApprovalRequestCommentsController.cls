public class ApprovalRequestCommentsController {

    public ID targetObjectId { get; set; }
    public String comments {
        get {
            if ( comments == null ) {
            	ProcessInstanceStep lastStep = getLastApprovalStep();
            	comments = ( lastStep != null ) ? lastStep.comments : '';
            }
            return comments;
        }
        private set;
    }
    
    public ApprovalRequestCommentsController() {}
    
    // Queries the most recent approval process step for the target record
    private ProcessInstanceStep getLastApprovalStep() {
        List<ProcessInstanceStep> steps = new List<ProcessInstanceStep>([
            SELECT
            	Comments
            FROM
            	ProcessInstanceStep
            WHERE
            	ProcessInstance.TargetObjectId = :targetObjectId
            ORDER BY
            	SystemModStamp DESC
            LIMIT
            	1
        ]);
        return ( steps.size() > 0 ) ? steps[0] : null;
    }
    
}