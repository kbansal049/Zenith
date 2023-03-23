@isTest
private class OppClosedLostDuplicateTest {
    
    @TestSetup 
    static void setUptestRecords(){
	    Account acc = new Account(Name = 'Test Account',APTS_Platform_Subscription_End_Date__c = Date.today());
	    insert acc;
	    Id RecordTypeIdContact = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
	    Opportunity Opp = new Opportunity(RecordTypeId=RecordTypeIdContact,Name = 'test opp', AccountId = acc.Id,Amount = 100.00, StageName = label.Stage_1_Alignment/*'Qualified'*/, CloseDate = Date.Today(), Flexible_Identifier__c ='Customer Over-Usage');
        insert Opp;
        Opportunity Opp1 = new Opportunity(RecordTypeId=RecordTypeIdContact,Name = 'test opp', AccountId = acc.Id,Amount = 100.00, StageName = label.Stage_1_Alignment/*'Qualified'*/, CloseDate = Date.Today());
        insert Opp1;
        
        Provisioning_Request__c Pr = new Provisioning_Request__c(Account__c = acc.Id,Additional_Organization_domains__c = 'Test',Preferred_Cloud__c = 'Zscaler.net',Send_Initial_l__c = 'ATT Usell',Provisioning_Status__c = 'Requested',Opportunity__c = Opp.Id);
        insert Pr;
	}
	
	static testmethod void getOppExtensionInfoTest(){ 
	    Test.startTest();
	    Opportunity Opp = [Select Id,StageName from Opportunity where Flexible_Identifier__c includes('Customer Over-Usage') Limit 1];
	    OppClosedLostDuplicate.getOppExtensionInfo(Opp.Id);
        OppClosedLostDuplicate.isActivePRpresentOnOpp(Opp.Id);
        OppClosedLostDuplicate.decommissionActivePRsOnOpp(Opp.Id);
        OppClosedLostDuplicate.isOverageOpp(Opp.Id);
        Opportunity Opp1 = [Select Id,StageName from Opportunity where Flexible_Identifier__c excludes('Customer Over-Usage') Limit 1];
        OppClosedLostDuplicate.isOverageOpp(Opp1.Id);
	    Test.stopTest();
	}

}