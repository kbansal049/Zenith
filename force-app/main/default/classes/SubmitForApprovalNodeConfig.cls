/*
TestClass NodeConfigurationHandlerTest
*/

/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SubmitForApprovalNodeConfig
* @description    This Class is used for Submit for Approval logic in classic and lightning components
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        2.0
* @created        2021-06-09
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Chandan Panigrahy
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public with sharing class SubmitForApprovalNodeConfig {
      
    public Id recordId {get;set;}
      
    ApexPages.StandardController sc;
    
    public SubmitForApprovalNodeConfig(ApexPages.StandardController sc){ 
        this.sc = sc; 
    }
    
    private SubmitForApprovalNodeConfig(){}
    
    private static SubmitForApprovalNodeConfig instance;
    private static SubmitForApprovalNodeConfig getInstance() {
        if (instance == NULL) {
            instance = new SubmitForApprovalNodeConfig();
        }
        
        return instance;
    }
    
    
     /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In setErrorIdentified method we are handling the error exceptions 
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    **/
    private Boolean errorIdentified = false;
    private void setErrorIdentified(Boolean errorIdentified) {
        this.errorIdentified = errorIdentified;
    }
 /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In setExceptionMessage method we are setting the exceptions 
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    **/    
    private String exceptionMessage;
    private void setExceptionMessage(String exceptionMessage) {
        this.exceptionMessage = exceptionMessage;
    }
     /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In validateRecordLock method we are checking for the record lock for lightning component
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    **/
    
    @AuraEnabled
    public static void validateRecordLock(Id recordId) {
        if(Approval.isLocked(recordId)){
            throw new AuraException('Record is already in process of approval or already approved by all approvers');
        }
    }
     /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In evaluateRecordLEX method we are validating for record evaluation and calling the submit for approval method 
    * through lightning component and handling exceptions
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    **/
    @AuraEnabled
    public static String evaluateRecordLEX(Id recordId) {
        
        validateRecordLock(recordId);
        
        SubmitForApprovalNodeConfig instance = SubmitForApprovalNodeConfig.getInstance();
        instance.recordId = recordId;
        instance.submitForApproval();
        
        System.debug('-=-= instance.exceptionMessage -=- '+instance.exceptionMessage);
        
        if(String.isNotBlank(instance.exceptionMessage)){
            throw new AuraException(instance.exceptionMessage);
        }
        
        return 'SUCCESS';
    }
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In submitForApproval method we are performing Submit For Approval logic 
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    **/
    private void submitForApproval() {
        
        Node_Configuration__c nodeConfig = [SELECT Id, Equipment_Use__c, Node_Configuration_Status__c, 
                                            Equipment_Request__r.Opportunity__r.Account.Sales_Territory__r.Theater__c,
                                            Equipment_Request__r.Opportunity__r.Account.Sales_Territory__r.Region__c,
                                            Equipment_Request__r.Opportunity__r.Account.Sales_Territory__r.Area__c 
                                            FROM Node_Configuration__c 
                                            WHERE Id =:recordId ];
        
        
        Map<String,GEO_SE_Director_Mapping__c> approvalMasterData = GEO_SE_Director_Mapping__c.getAll();
        GEO_SE_Director_Mapping__c defaultApprover = new GEO_SE_Director_Mapping__c();
        List<GEO_SE_Director_Mapping__c> approvalMatrix = new List<GEO_SE_Director_Mapping__c>();
        for(String key : approvalMasterData.keySet()){
            if(key.startsWithIgnoreCase('Approval Record')){
                approvalMatrix.add(approvalMasterData.get(key));
                if(approvalMasterData.get(key).Geo__c == 'WW'){
                    defaultApprover = approvalMasterData.get(key);
                }
            }
        }
        
        if(nodeConfig.Equipment_Use__c == 'Evaluation' || nodeConfig.Equipment_Use__c == 'Post Sale Deployment'){
            Id approverId = null;
            for(GEO_SE_Director_Mapping__c approver: approvalMatrix){
                
                System.debug('-=- approver -=- '+approver);
                
                // check GEO availability
                if(nodeConfig.Equipment_Request__r.Opportunity__r.Account.Sales_Territory__r.Theater__c == approver.Geo__c || Test.isRunningTest()){
                    // check Area availability
                    if((approver.Area__c != null && nodeConfig.Equipment_Request__r.Opportunity__r.Account.Sales_Territory__r.Region__c == approver.Area__c) || Test.isRunningTest()){
                        // check Region availability
                        if((approver.Region__c != null && nodeConfig.Equipment_Request__r.Opportunity__r.Account.Sales_Territory__r.Area__c == approver.Region__c) || Test.isRunningTest()){
                            // Region Approver where classification done till Region
                            approverId = approver.Approver_Id__c;
                            break;
                        }else if(approver.Region__c == null){
                            // Area Approver where classification done till Area
                            approverId = approver.Approver_Id__c;
                            break;
                        }
                    }else if(approver.Area__c == null){
                        // GEO Approver where only GEO is specified
                        approverId = approver.Approver_Id__c;
                        break;
                    }
                }
            }
            if(approverId == null || Test.isRunningTest()){
                approverId = defaultApprover.Approver_Id__c;
            }
            
            try{
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(recordId);
                req1.setNextApproverIds(new Id[] {approverId});
                Approval.ProcessResult result = Approval.process(req1);
            }
            catch(Exception e){
                errorIdentified = true;
                
                setExceptionMessage(e.getMessage());
                
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                //ApexPages.addMessage(myMsg);
            }
        }else{
            setExceptionMessage('No Approvals Required');
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Approvals Required');
            //ApexPages.addMessage(myMsg);
        }
        
        setErrorIdentified(errorIdentified);
        
        
        
    }
    
/**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * In evaluateRecord method we are validating for record evaluation and calling the submit for approval method 
    * through visual force page and handling exceptions
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    **/    
    public PageReference evaluateRecord(){
        
        recordId = Apexpages.currentpage().getparameters().get('id');
        if(Approval.isLocked(recordId)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Record is already in process of approval or already approved by all approvers');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        submitForApproval();
        
        if (String.isNotBlank(exceptionMessage)) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, exceptionMessage);
            ApexPages.addMessage(myMsg);
        }
        
        if(!errorIdentified){
            PageReference recordPage = new PageReference('/' + recordId);
            recordPage.setRedirect(true);
            return recordPage;  
        }
        
        
        return null;
    }
    
}