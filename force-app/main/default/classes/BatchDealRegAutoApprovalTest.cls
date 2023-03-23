@isTest
public class BatchDealRegAutoApprovalTest {
    
    @testSetup 
    static void setup() {
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        DealRegTestDataFactory.createPatchTeamsAndGeoLeaderMappings();
        DealRegTestDataFactory.createAccountAndContact('TestCust1', 'testcust1.com', DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id, 'Enterprise', 1);
        
        Deal_Reg__c dealReg = DealRegTestDataFactory.createDealReg('vprakash@zscaler.com', 'IT Authorities', 'TestCust1', 'testcust1.com', 'India', DealRegTestDataFactory.mapPatchTeams.get('EMEA|General Business'), 'SMB');
        
        dealReg.Sales_Territory__c = DealRegTestDataFactory.mapPatchTeams.get('EMEA|Enterprise').Id;
        dealReg.Market_Segment__c = 'Enterprise';
        dealReg.DS_Review_Status__c = 'Complete';
        dealReg.Approval_Status__c = 'Channel Manager Rejected';
        dealReg.Channel_Manager__c = DealRegTestDataFactory.geoLeader.Id;
        dealReg.Account_Manager__c = DealRegTestDataFactory.geoLeader.Id;
        update dealReg;
        
        //Submit Quote for Approval
		//Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
		//app.setObjectId(dealReg.id);
		//Approval.ProcessResult result = Approval.process(app);
              
    }
    
    @isTest static void testMethod1() {
        Database.executeBatch(new BatchDealRegAutoApproval(),1);
        
        BatchDealRegAutoApproval m = new BatchDealRegAutoApproval();
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('Deal Reg 48', sch, m);
        
    }
    
     @isTest static void testMethod2() {
        Database.executeBatch(new BatchDealRegAutoApprovalAD(),1);
        
        BatchDealRegAutoApprovalAD m = new BatchDealRegAutoApprovalAD();
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('Deal Reg 48', sch, m);
        
    }
    
     
     @isTest static void testMethod3() {
        Database.executeBatch(new BatchSetDealRegExpiration(),1);
        
        BatchSetDealRegExpiration m = new BatchSetDealRegExpiration();
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('Deal Reg 48', sch, m);
        
    }

}