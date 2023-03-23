//Test Class: CommissionExceptiontriggerhandlerTest
public class CommExceptionApprovalPreviewCtrlr {
    public Commission_Exception__c commExceptionRecord {get;set;}
    public Id recordId {get;set;}
    public Commission_Exceptions_Approval_Matrix__mdt approvalPreview {get;set;}
    public Map<String, User> usersMap {get;set;}
    public List<User> approverNames {get;set;}
    
    public CommExceptionApprovalPreviewCtrlr(ApexPages.StandardController stdController) {        
        this.recordId = stdController.getRecord().Id;
        this.commExceptionRecord = [SELECT Exception_Categories__c, Commission_Amount__c, Geo__c,Region__c FROM Commission_Exception__c WHERE Id = :this.recordId];
        System.debug('commExceptionRecord' + this.commExceptionRecord);
        approvalPreview = getApprovalMatrix(this.commExceptionRecord);
        if(approvalPreview != null){
            usersMap = getUsername(approvalPreview);
            approverNames = getApprovers(approvalPreview,usersMap);
        }        
    } 
    
    public Commission_Exceptions_Approval_Matrix__mdt getApprovalMatrix(Commission_Exception__c commExcep){
        
        Commission_Exceptions_Approval_Matrix__mdt approvalPreview2 = new Commission_Exceptions_Approval_Matrix__mdt();
                
        for(Commission_Exceptions_Approval_Matrix__mdt ce : [SELECT Approval_Type__c,Commission_Amount_LB__c,Commission_Amount_UB__c,Geos__c,Region__c,
                                                               DeveloperName,Executive_Approver_ID_Step_6__c,Executive_Approver_ID_Step_8__c,
                                                               Finance_Approver_ID_Step_3__c,Finance_Approver_ID_Step_5__c,Finance_Approver_ID_Step_7__c,                           
                                                               Sales_Approver_ID_Step_2__c,Sales_Approver_ID_Step_4__c,Sales_Comp_Approver_ID_Step_1__c 
                                                               FROM Commission_Exceptions_Approval_Matrix__mdt WHERE Approval_Type__c = :commExcep.Exception_Categories__c]){
                if(ce.Commission_Amount_LB__c == NULL && ce.Commission_Amount_UB__c == NULL){
                    approvalPreview2 = ce;
                }else {
                    //20000+
                    if(ce.Commission_Amount_UB__c == NULL && ce.Commission_Amount_LB__c != NULL && ce.Commission_Amount_LB__c <= commExcep.Commission_Amount__c){
                        if(String.isNotBlank(commExcep.Geo__c)){
                            //Added for CR#3935
                            if(ce.Geos__c?.containsIgnoreCase(commExcep.Geo__c) || (ce.Region__c !=null && ce.Region__c?.containsIgnoreCase(commExcep.Region__c))){
                                approvalPreview2 = ce;
                            }
                        }
                                                
                    }else if(ce.Commission_Amount_LB__c <= commExcep.Commission_Amount__c  && ce.Commission_Amount_UB__c >= commExcep.Commission_Amount__c){
                        if(String.isNotBlank(commExcep.Geo__c)){
                            //Added for CR#3935
                            if(ce.Geos__c?.containsIgnoreCase(commExcep.Geo__c) || (ce.Region__c !=null && ce.Region__c?.containsIgnoreCase(commExcep.Region__c))){
                                approvalPreview2 = ce;
                            }
                        }    
                    }
                }                                                             
        }
        return approvalPreview2;   
    }
    
    public Map<String, User> getUsername(Commission_Exceptions_Approval_Matrix__mdt matrix){
        Set<String> userIds = new Set<String>{matrix.Sales_Comp_Approver_ID_Step_1__c,matrix.Sales_Approver_ID_Step_2__c,
            							matrix.Finance_Approver_ID_Step_3__c,matrix.Sales_Approver_ID_Step_4__c,
            							matrix.Finance_Approver_ID_Step_5__c,matrix.Executive_Approver_ID_Step_6__c,
            							matrix.Finance_Approver_ID_Step_7__c,matrix.Executive_Approver_ID_Step_8__c};
        userIds.remove(null);                                    
        Map<String, User> userMap = new Map<String, User>();
        for(User u : [SELECT Id, Name, Title FROM User WHERE ID IN :userIds]){ userMap.put(u.Id.to15(),u); }
        return userMap;
    }
    
    public List<User> getApprovers(Commission_Exceptions_Approval_Matrix__mdt matrix,Map<String, User> usersMap){
        approverNames = new List<User>();
        approverNames.add(usersMap.get(matrix.Sales_Comp_Approver_ID_Step_1__c));
        approverNames.add(usersMap.get(matrix.Sales_Approver_ID_Step_2__c));
        approverNames.add(usersMap.get(matrix.Finance_Approver_ID_Step_3__c));
        approverNames.add(usersMap.get(matrix.Sales_Approver_ID_Step_4__c));
        approverNames.add(usersMap.get(matrix.Finance_Approver_ID_Step_5__c));
        approverNames.add(usersMap.get(matrix.Executive_Approver_ID_Step_6__c));
        approverNames.add(usersMap.get(matrix.Finance_Approver_ID_Step_7__c));
        approverNames.add(usersMap.get(matrix.Executive_Approver_ID_Step_8__c));
        return approverNames;
    }
}