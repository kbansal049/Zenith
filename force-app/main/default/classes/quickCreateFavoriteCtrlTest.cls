@isTest
private class quickCreateFavoriteCtrlTest {
    
    @testSetup
    static void testData(){
		List<Account> lstAccount =  new List<Account>(SB_TestCPQDataUtility.createAccount(2));
		insert lstAccount;
		List<PriceBook2> pb = SB_TestCPQDataUtility.createCustomPriceBooks(2);
		
        List<User> lstUser =  SB_TestCPQDataUtility.createUsers(1, 'system', 'Administrator1' , 'System Administrator');
		insert lstUser;
           
		List<opportunity> lstOpp =  SB_TestCPQDataUtility.createOpportunity(1,'Test', lstAccount[0].Id);
		insert lstOpp;
		
		Id recordTypeId = [Select id from RecordType where name = 'Approved'].id;
	
        List<SBQQ__Quote__c> lstQuote = SB_TestCPQDataUtility.createQuote(1, lstOpp[0].id, lstAccount[0].id, lstAccount[0].id,lstAccount[1].id,recordTypeId);
		insert lstQuote;
		
		List<Favorites__c> lstFavorites = new List<Favorites__c>();
		Favorites__c f1 = new Favorites__c();
		f1.Name = 'Favorites1';
		f1.Global_Favorite__c = true;
		f1.Description__c = 'Testing';
		f1.Original_Quote__c = lstQuote[0].id;
		f1.User__c = lstUser[0].id;
		lstFavorites.add(f1);
		
		Favorites__c f2 = new Favorites__c();
		f2.Name = 'Favorites2';
		f2.Global_Favorite__c = true;
		f2.Description__c = 'Testing2';
		f2.Original_Quote__c = lstQuote[0].id;
		f2.User__c = lstUser[0].id;
		lstFavorites.add(f2);
		insert lstFavorites;
    }
    
    @isTest static void testSetQuickCreateFavoritesId() {
    	Test.startTest();
		List<User> lstUser = [Select id from User where lastName = 'Administrator1' limit 1];
		List<SBQQ__Quote__c> lstQuote = [Select Id from SBQQ__Quote__c limit 1];
		List<Favorites__c> lstFavorites = [Select id from Favorites__c where User__c =: lstUser[0].id];
		String favoriteId = QuickCreateFavoriteCtrl.setQuickCreateFavoritesId(lstQuote[0].id, lstUser[0].Id);
		System.assertEquals(lstFavorites[0].id,favoriteId);
        Test.stopTest();
    }
	
	
	@isTest static void testCheckDuplicateNameExist() {
    	Test.startTest();
		List<SBQQ__Quote__c> lstQuote = [Select Id,Name from SBQQ__Quote__c limit 1];
		List<Favorites__c> lstFavorites = [Select id,Name from Favorites__c limit 1];
		String favoriteId = QuickCreateFavoriteCtrl.checkDuplicateNameExist(lstFavorites[0].Name, lstQuote[0].id);
		System.assertEquals(null,favoriteId);
        Test.stopTest();
    }
	
	@isTest static void testSetGlobalFavorite1() {
    	Test.startTest();
		List<User> lstUser = [Select id from User where lastName = 'Administrator1' limit 1];
        boolean isSet=  QuickCreateFavoriteCtrl.setGlobalFavorite(lstUser[0].id);
		System.assertEquals(true,isSet);
        Test.stopTest();
    }
	
	@isTest static void testSetGlobalFavorite2() {
    	Test.startTest();
		List<User> lstUser = [Select id from User where lastName != 'Administrator1' limit 1];
        boolean isSet=  QuickCreateFavoriteCtrl.setGlobalFavorite(lstUser[0].id);
		System.assertEquals(false,isSet);
        Test.stopTest();
    }

}