/**********************************************************************************************************************
* @ClassName	: NFR_ApprovalController
* @TestClass	: NFR_ApprovalControllerTest
* @Author   	: Priyanka J
* @Date     	: 28 Dec, 2020
* @Description	: This is an apex class that is invoked from Quick Action on NFR License record page, to automatically 
				submit record for approval
************************************************************************************************************************/
public class NFR_ApprovalController {
    
    public NFR_ApprovalController(ApexPages.StandardController stdController) {
    }
 
    @AuraEnabled
    public static Boolean submitForApproval(Id recId) {
        Approval.ProcessSubmitRequest reqApp = new Approval.ProcessSubmitRequest();
        reqApp.setObjectId(recId);
        reqApp.setComments('Submitting request for approval from lightning component.');
        Approval.ProcessResult result = Approval.process(reqApp);
        System.debug('Submitted for approval successfully:'+result.isSuccess());
        return result.isSuccess();
    }
}