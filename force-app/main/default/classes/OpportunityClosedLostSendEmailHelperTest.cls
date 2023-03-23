@IsTest
private class OpportunityClosedLostSendEmailHelperTest {
    
    @TestSetup static void SetUpRecs(){
	    PatchTeam__c emeaPatchTeam1 = new PatchTeam__c();
        emeaPatchTeam1.Area__c = 'EMEA';
        emeaPatchTeam1.Region__c = 'EMEA';
        emeaPatchTeam1.Territory_Type__c = 'Catch All';
        emeaPatchTeam1.Theater__c = 'EMEA';
        
        TriggerUtility.realignPatchReset();
        INSERT emeaPatchTeam1;
        
        PatchFieldMapping__c mapping = new PatchFieldMapping__c(Name='EMEA', Object__c='Lead', Type__c='Field', Field__c='Name', Value__c='Company');
        INSERT mapping;
        PatchFieldMapping__c mapping2 = new PatchFieldMapping__c(Name='EMEA acc', Object__c='Account', Type__c='Field', Field__c='Name', Value__c='Company');
        INSERT mapping2;
        

        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=emeaPatchTeam1.Id, Role__c='EMEA', User__c=UserInfo.getUserId());
        INSERT member;
        
        Patch__c patch = new Patch__c(PatchName__c='EMEA', Active__c=true,PatchTeam__c=emeaPatchTeam1.Id);
        INSERT patch;
                
        Account acc = new Account(Name = 'Test Account', Type='Prospect', Patch__c = patch.Id,PatchLocked__c = true);
        INSERT acc;  
        Opportunity opp = new Opportunity(Name='Test Opportunity 1',AccountId = acc.Id,Type='New Business', StageName = label.Stage_1_Alignment,CloseDate = system.Today()+10,Has_Technology_Partner__c=true );
        INSERT opp;
        
        List<Opportunity_Extension__c> oppExtList = new List<Opportunity_Extension__c>();
        
        oppExtList.add(new Opportunity_Extension__c(Opportunity__c = opp.Id));
        
        INSERT oppExtList;
        
        Significant_Customer_Interaction__c sig = new Significant_Customer_Interaction__c(Opportunity_Name__c=Opp.Id);
        insert sig;
        Churn__c churn = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Churn', Opportunity__c =Opp.Id,Lost_Analysis_Call__c = 'Call Conducted');
        insert churn;
        Churn__c churnLoss = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Loss', Opportunity__c =Opp.Id);
        insert churnLoss;

        
	}
	
	@IsTest static void testChurnForm(){ 
        
        Triggers_Switch__c ts = new Triggers_Switch__c(name='OpportunityUpdatesContactHandler', Execute__c = true);
        insert ts;
        Triggers_Switch__c ts1 = new Triggers_Switch__c(name='Execute_Opp_Trigger', Execute__c = true);
        insert ts1;
		
        Opportunity Opp = [Select Id,StageName from Opportunity Limit 1];        
	    Churn__c churn = [Select Id,Type__c,SCINumber__c,Lost_Analysis_Call__c,Opp_Loss_Primary_Reason__c,Opp_Loss_Secondary_Reason__c,ZIA_Primary_Competitor__c,ZIA_Secondary_Competitor__c,ZPA_Primary_Competitor__c,ZPA_Secondary_Competitor__c,Renewalquestion__c from Churn__c Where Type__c='Loss' Limit 1];
        Test.startTest();
	    
	    TriggerUtility2.OppAfterUpdateReset();
        
        OppLossReasonCntrl OppLossReasonClass = new OppLossReasonCntrl();
	    OppLossReasonCntrl.saveRecord(churn.Id,Opp.Id,churn.SCINumber__c,System.Label.SubStage_Closed_Lost,True,churn);
	    
        TriggerUtility2.OppAfterUpdateExecuted();
	    Test.stopTest();
	}
    
    @IsTest static void testChurnForm1(){ 
        
        Triggers_Switch__c ts = new Triggers_Switch__c(name='OpportunityUpdatesContactHandler', Execute__c = true);
        insert ts;
        Triggers_Switch__c ts1 = new Triggers_Switch__c(name='Execute_Opp_Trigger', Execute__c = true);
        insert ts1;
		
        Opportunity Opp = [Select Id,StageName from Opportunity Limit 1];        
	    Churn__c churn = [Select Id,Type__c,SCINumber__c,Lost_Analysis_Call__c,Opp_Loss_Primary_Reason__c,Opp_Loss_Secondary_Reason__c,ZIA_Primary_Competitor__c,ZIA_Secondary_Competitor__c,ZPA_Primary_Competitor__c,ZPA_Secondary_Competitor__c,Renewalquestion__c from Churn__c Where Type__c='Loss' Limit 1];
        Test.startTest();
        
        TriggerUtility2.OppAfterUpdateReset();
        
        OppLossReasonCntrl OppLossReasonClass = new OppLossReasonCntrl();
	    OppLossReasonCntrl.saveRecord(churn.Id,Opp.Id,churn.SCINumber__c,'Closed With No Decision',True,churn);
        
        TriggerUtility2.OppAfterUpdateExecuted();
	    Test.stopTest();
	}
    
    @IsTest static void testChurnForm2(){ 
        
        Triggers_Switch__c ts = new Triggers_Switch__c(name='OpportunityUpdatesContactHandler', Execute__c = true);
        insert ts;
        Triggers_Switch__c ts1 = new Triggers_Switch__c(name='Execute_Opp_Trigger', Execute__c = true);
        insert ts1;
		
        Opportunity Opp = [Select Id,StageName from Opportunity Limit 1];        
	    Churn__c churn = [Select Id,Type__c,SCINumber__c,Lost_Analysis_Call__c,Opp_Loss_Primary_Reason__c,Opp_Loss_Secondary_Reason__c,ZIA_Primary_Competitor__c,ZIA_Secondary_Competitor__c,ZPA_Primary_Competitor__c,ZPA_Secondary_Competitor__c,Renewalquestion__c from Churn__c Where Type__c='Loss' Limit 1];
        Test.startTest();
	    
        TriggerUtility2.OppAfterUpdateReset();
        
        OppLossReasonCntrl OppLossReasonClass = new OppLossReasonCntrl();
        OppLossReasonCntrl.saveRecord(churn.Id,Opp.Id,churn.SCINumber__c,'Closed: Delete Duplicate',True,churn);
        
        TriggerUtility2.OppAfterUpdateExecuted();
	    Test.stopTest();
	}
}