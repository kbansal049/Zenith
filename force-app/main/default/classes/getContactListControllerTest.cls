@isTest
private class getContactListControllerTest {
    @testSetup static void setup(){
        Account accRec = new Account(Name='Test');
	    insert accRec;   
        AccountTeamMember newTeamRec = new AccountTeamMember(AccountId = accRec.ID,
		TeamMemberRole = 'Sales Engineer',UserId = UserInfo.getUserId());
        insert newTeamRec;
    }

	private static testMethod void insertAccountTeamMember() {
        getContactListController getContactListRec = new getContactListController();
        getContactListController.getContactList();
        
	}

}