@IsTest
public class RenewalOppClosedLostSendEmailHelperTest {
	@TestSetup static void SetUpRecs(){
             
        Account acc = new Account(Name = 'Test Account', Type='Prospect');
        INSERT acc;  
        Opportunity opp = new Opportunity(Name='Test Opportunity 1',AccountId = acc.Id,Type='Existing Customer (Renewal)',
                                          StageName = label.Stage_1_Alignment,CloseDate = system.Today()+10,Has_Technology_Partner__c=true);
        INSERT opp;
       
        Significant_Customer_Interaction__c sig = new Significant_Customer_Interaction__c(Opportunity_Name__c=Opp.Id);
        insert sig;
        Churn__c churn = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Churn', Opportunity__c =Opp.Id,Lost_Analysis_Call__c = 'Call Conducted');
        insert churn;
        Churn__c churnLoss = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Loss', Opportunity__c =Opp.Id);
        insert churnLoss;

        
	}
	
	@IsTest static void testChurnForm(){ 
        
        
        Triggers_Switch__c ts1 = new Triggers_Switch__c(name='Execute_Opp_Trigger', Execute__c = true);
        insert ts1;
		
        Opportunity Opp = [Select Id,StageName from Opportunity Limit 1];        
	    Churn__c churn = [Select Id,Type__c,SCINumber__c,Lost_Analysis_Call__c,Opp_Loss_Primary_Reason__c,Opp_Loss_Secondary_Reason__c,ZIA_Primary_Competitor__c,ZIA_Secondary_Competitor__c,ZPA_Primary_Competitor__c,ZPA_Secondary_Competitor__c,Renewalquestion__c from Churn__c  Limit 1];
        Test.startTest();
	    
	    TriggerUtility2.OppAfterUpdateReset();
        
        OppLossReasonCntrl OppLossReasonClass = new OppLossReasonCntrl();
	    OppLossReasonCntrl.saveRecord(churn.Id,Opp.Id,churn.SCINumber__c,System.Label.SubStage_Closed_Lost,True,churn);
	    
        TriggerUtility2.OppAfterUpdateExecuted();
	    Test.stopTest();
	}
    
    
}