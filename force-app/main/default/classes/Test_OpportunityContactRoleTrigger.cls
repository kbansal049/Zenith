@isTest
private class Test_OpportunityContactRoleTrigger {

	private static testMethod void test() {
	   
	   
        Contact ct = new Contact();
	    ct.FirstName = 'test';
	    ct.LastName = 'test';
	    ct.Email = 'test@test.com';
	    insert ct;
	    
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = Label.Stage_1_Alignment;
        opp.CloseDate = System.today();
        opp.ZIA_Use_Case__c = 'SD-WAN';
        opp.has_Required_Contact_Roles__c = true;
        insert opp;
        
        OpportunityContactRole opr = new OpportunityContactRole();
        opr.ContactId = ct.Id;
        opr.OpportunityId = opp.Id;
        opr.Role = 'Deployment Contact';
        
        test.startTest();
        insert opr;
        opp.has_Required_Contact_Roles__c = true;
        update opp;
        update opr;
        delete opr;
        test.stopTest();
        
	}
}