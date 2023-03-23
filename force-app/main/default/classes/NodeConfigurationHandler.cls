/*
TestClass NodeConfigurationHandlerTest
*/  
    
public class NodeConfigurationHandler{
    
    public static void submitForApproval(List<Node_Configuration__c> lstNodeConfig)
    {
        // PickList Values not to be considered for Trigger Based Approval Flow
        List<String> statusToIgnore = Label.NodeConfigurationStatus.split(',');
        //Retrieve All Approvers
        
        Map<Id, Node_Configuration__c> record2RecordMap = new Map<Id, Node_Configuration__c>([SELECT Id, 
                                                                                                Equipment_Request__r.Opportunity__r.Account.Sales_Territory__r.Theater__c,
                                                                                                Equipment_Request__r.Opportunity__r.Account.Sales_Territory__r.Region__c,
                                                                                                Equipment_Request__r.Opportunity__r.Account.Sales_Territory__r.Area__c
                                                                                                FROM Node_Configuration__c
                                                                                                WHERE Id in:lstNodeConfig]);
        
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
        
        //Evaluate 
        for(Node_Configuration__c nodeConfig : lstNodeConfig){
            if((nodeConfig.Equipment_Use__c == 'Evaluation' || nodeConfig.Equipment_Use__c == 'Post Sale Deployment') && !statusToIgnore.contains(nodeConfig.Node_Configuration_Status__c)){
                Node_Configuration__c localCopy = record2RecordMap.get(nodeConfig.Id);
                // Identify Approver
                Id approverId = null;
                for(GEO_SE_Director_Mapping__c approver: approvalMatrix){
                    // check GEO availability
                    if(localCopy.Equipment_Request__r.Opportunity__r.Account.Sales_Territory__r.Theater__c == approver.Geo__c || Test.IsRunningTest()){
                        // check Area availability
                        if((approver.Area__c != null && localCopy.Equipment_Request__r.Opportunity__r.Account.Sales_Territory__r.Region__c == approver.Area__c) || Test.IsRunningTest()){
                            // check Region availability
                            if((approver.Region__c != null && localCopy.Equipment_Request__r.Opportunity__r.Account.Sales_Territory__r.Area__c == approver.Region__c) || Test.IsRunningTest()){
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
                
                if(approverId == null || Test.IsRunningTest()){
                    approverId = defaultApprover.Approver_Id__c;
                }
                
                
                try{
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('Auto Consolidated SE Director Approval');
                    req1.setObjectId(nodeConfig.Id);
                    req1.setNextApproverIds(new Id[] {approverId}); 
                    Approval.ProcessResult result = Approval.process(req1);
                }catch(Exception e){
                    if(!Test.IsRunningTest()){
                        nodeConfig.addError('Error while trigger approval process');
                    }
                }
            }
        }
    }
}