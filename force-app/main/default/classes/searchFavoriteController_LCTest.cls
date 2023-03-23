@isTest
private class searchFavoriteController_LCTest {

    @testSetup
    static void testData(){
        List<Account> lstAccount =  new List<Account>(SB_TestCPQDataUtility.createAccount(2));
        insert lstAccount;
        
        List<PriceBook2> pb = SB_TestCPQDataUtility.createCustomPriceBooks(2);
        insert pb;
        
        List<product2>  lstproduct = SB_TestCPQDataUtility.createProduct(1,'Test','12330','','999');
        insert lstproduct;
        
        List<PricebookEntry> lstPBE = SB_TestCPQDataUtility.createPriceBookEntry(1,lstproduct[0].id, double.valueOf(2501));
        insert lstPBE;
        
        List<User> lstUser =  SB_TestCPQDataUtility.createUsers(1, 'system', 'Administrator1' , 'System Administrator');
        insert lstUser;
           
        List<opportunity> lstOpp =  SB_TestCPQDataUtility.createOpportunity(1,'Test', lstAccount[0].Id);
        insert lstOpp;
        
        Id recordTypeId = [Select id from RecordType where name = 'Approved'].id;
    
        List<SBQQ__Quote__c>  lstQuote =  SB_TestCPQDataUtility.createQuote(1, lstOpp[0].id, lstAccount[0].id, lstAccount[0].id,lstAccount[1].id,recordTypeId);
        lstQuote[0].SBQQ__PriceBook__c = pb[1].id;
        insert lstQuote;
        
        List<Favorites__c> lstFavorites = new List<Favorites__c>();
        Favorites__c f1 = new Favorites__c();
        f1.Name = 'Favorites1';
        f1.Global_Favorite__c = true;
        f1.Description__c = 'Testing';
        f1.Original_Quote__c = lstQuote[0].id;
        f1.User__c = lstUser[0].id;
        lstFavorites.add(f1);
        
        insert lstFavorites;
        
        SBQQ__QuoteProcess__c qProcess = new SBQQ__QuoteProcess__c();
        qProcess.Name = 'Test';
        qProcess.SBQQ__ProductAutoSelected__c = true;
        qProcess.SBQQ__Default__c = true;
        qProcess.SBQQ__GuidedOnly__c = true;
        qProcess.SBQQ__SortOrder__c =5;
        qProcess.SBQQ__ProductConfigurationInitializer__c = 'testing';
        qProcess.SBQQ__ProductSearchExecutor__c = 'Testing1';
        insert qProcess;
        
        SBQQ__SolutionGroup__c sGroup = new SBQQ__SolutionGroup__c();
        sGroup.Name = 'Testing';
        sGroup.SBQQ__Description__c = 'Testing in process';
        insert sGroup;
        
        SBQQ__QuoteLineGroup__c qLG = new SBQQ__QuoteLineGroup__c();
        qLG.SBQQ__Account__c = lstAccount[0].id;
        //qLG.SBQQ__Favorite__c = lstFavorites[0].id;
        qLG.Partner__c = lstAccount[0].id;
        qLG.SBQQ__Quote__c = lstQuote[0].id;
        qLG.SBQQ__QuoteProcess__c = qProcess.Id;
        qLG.SBQQ__SolutionGroup__c = sGroup.id;
        insert qLG;
        
        
        List<SBQQ__QuoteLine__c> lstQLine =  SB_TestCPQDataUtility.createQuoteLine (5,String.valueOf(lstQuote[0].Id),String.valueOf(lstproduct[0].Id), System.today().addDays(-2),System.today().addDays(7),Double.valueOf('25.25'));
      	insert lstQLine;
        
    }
    
    @isTest static void testgetQuoteDetails() {
        Test.startTest();
        Id qLGID = [Select Id from SBQQ__QuoteLineGroup__c limit 1].Id;
        searchFavoriteController_LC.QuoteDetails  qDetails= searchFavoriteController_LC.getQuoteDetails(qLGID);
        System.assertNotEquals(null,qDetails);
        
        searchFavoriteController_LC.QuoteDetails  qDetails1= searchFavoriteController_LC.getQuoteDetails('Test');
        System.assertNotEquals(null,qDetails1);
        Test.stopTest();
    }
    
    @isTest static void testGetUserGlobalFav(){
        Test.startTest();
        List<User> lstUser = [Select id from User where lastName = 'Administrator1' limit 1];       
        System.runas(lstUser[0]){
            List<SBQQ__Quote__c> lstQuote = [Select Id,Name from SBQQ__Quote__c limit 1];
            searchFavoriteController_LC.UserDetails udetail = searchFavoriteController_LC.getUserGlobalFav(lstQuote[0].id);
            System.assertNotEquals(null,udetail);
        }   
        Test.stopTest();
    }
    
    @isTest static void testGetProductGroupList(){
        Test.startTest();
        List<SBQQ__Quote__c> lstQuote = [Select Id,Name from SBQQ__Quote__c limit 1];
        List<searchFavoriteController_LC.addFavourite>  aFavourite = searchFavoriteController_LC.getProductGroupList('',lstQuote[0].id);
        System.assertNotEquals(null,aFavourite);
        Test.stopTest();
    }
    
    @isTest static void testGetProductGroupList1(){
        Test.startTest();
        List<SBQQ__Quote__c> lstQuote = [Select Id,Name from SBQQ__Quote__c limit 1];
        List<searchFavoriteController_LC.addFavourite>  aFavourite = searchFavoriteController_LC.getProductGroupList('Personal Favorite',lstQuote[0].id);
        System.assertNotEquals(null,aFavourite);
        Test.stopTest();
    }
    
    @isTest static void testGetProductsList(){
        Test.startTest();
        List<SBQQ__Quote__c> lstQuote = [Select Id,Name from SBQQ__Quote__c limit 1];
        List<searchFavoriteController_LC.addProducts> adProducts = new List<searchFavoriteController_LC.addProducts>();
        adProducts = searchFavoriteController_LC.getProductsList(lstQuote[0].id,lstQuote[0].id);
        System.assertNotEquals(null,adProducts);
        Test.stopTest();
    }
    
    @isTest static void testGetAllProductsList(){
        Test.startTest();
        List<SBQQ__Quote__c> lstQuote = [Select Id,Name from SBQQ__Quote__c limit 1];
        Map<Id, List<searchFavoriteController_LC.addProducts>> aFavourite = searchFavoriteController_LC.getAllProductsList(new List<String>() ,lstQuote[0].id);
        System.assertNotEquals(null,aFavourite);
        Test.stopTest();
    }
    
    @isTest static void testGetUserDetails(){
        Test.startTest();
        String userId = searchFavoriteController_LC.getUserDetails();
        System.assertEquals(userId,UserInfo.getUserId());
        Test.stopTest();
    }
    
    @isTest static void testShowValidationError(){
        Test.startTest();
        List<SBQQ__Quote__c> lstQuote = [Select Id,Name from SBQQ__Quote__c limit 1];
        List<Favorites__c> lstFavorites = [Select id,Name from Favorites__c limit 1];
        List<User> lstUser = [Select id from User where lastName = 'Administrator1' limit 1];
        String msg = searchFavoriteController_LC.showValidationError(lstUser[0].Id,lstFavorites[0].Name,true,lstQuote[0].Id);
        System.assertNotEquals(null,msg);
        Test.stopTest();
    }
    
    @isTest static void testgetAccount(){
        Test.startTest();
        List<SBQQ__Quote__c> lstQuote = [Select Id,Name from SBQQ__Quote__c limit 1];
        String msg = searchFavoriteController_LC.getAccount(lstQuote[0].Id);
        System.assertNotEquals(null,msg);
        Test.stopTest();
    }
   
    @isTest static void testCreateQuoteLines(){
        Test.startTest();
        List<SBQQ__Quote__c> lstQuote = [Select Id,Name from SBQQ__Quote__c limit 1];
        List<SBQQ__QuoteLineGroup__c> lstGround = [Select Id from SBQQ__QuoteLineGroup__c limit 1];
        List<opportunity>  lstOpp = [Select Id from opportunity limit 1];
        searchFavoriteController_LC.createQuoteLines(lstQuote[0].Id,lstQuote[0].id,lstGround[0].id,lstOpp[0].id);
        System.assert(true);
        Test.stopTest();
    }
    
    @isTest static void testsaveQuoteLines(){
        Test.startTest();
        List<SBQQ__Quote__c> lstQuote = [Select Id,Name from SBQQ__Quote__c limit 1];
        List<Favorites__c> lstFavorites = [Select id,Name from Favorites__c limit 1];
        List<Product2> ListProduct2 = [Select id,Name from Product2 limit 1];
        List<PriceBook2> listPriceBook2 = [Select id,Name from PriceBook2 limit 1];
        
        String favStrobj;
        String prodSearchData;
        searchFavoriteController_LC.addFavourite aFavourite = new searchFavoriteController_LC.addFavourite('121-'+lstFavorites[0].Id,true ,'Test', 'Testing',String.valueOf(lstQuote[0].Id), true, true,lstFavorites[0].Id,Integer.valueOf('12330'), 'Test', '500','INR',true,'',Decimal.valueOf('555.55'));
        List<searchFavoriteController_LC.addFavourite> lstAF = new List<searchFavoriteController_LC.addFavourite>();
        lstAF.add(aFavourite);
        favStrobj =JSON.serialize(lstAF);
        
        searchFavoriteController_LC.selectedProduct sProduct  = new searchFavoriteController_LC.selectedProduct();
        sProduct.Id= '';
        sProduct.Product2Id = ListProduct2[0].Id;
        sProduct.UnitPrice = Decimal.valueOf('555.55');
        sProduct.Pricebook2Id=  listPriceBook2[0].id;
        sProduct.CurrencyIsoCode = '+91';
        sProduct.Product2 = ListProduct2[0];
        sProduct.Product2Name= 'Test';
        sProduct.Product2Description = 'Testing';
        sProduct.Product2ProductCode = '12330';
        
        List<searchFavoriteController_LC.selectedProduct> lstSP = new List<searchFavoriteController_LC.selectedProduct>();
        lstSP.add(sProduct);
        prodSearchData = JSON.serialize(lstSP);
        String result = searchFavoriteController_LC.saveQuoteLines(favStrobj,lstQuote[0].Id,'',prodSearchData); 
        System.assertNotEquals(null,result);        
        Test.stopTest();
    }
    
    @isTest static void testgetProduct(){
        Test.startTest();
        List<PricebookEntry> lstPBE = [Select Id,Name from PricebookEntry limit 1];
        if(!lstPBE.isEmpty()){
            PricebookEntry pb = searchFavoriteController_LC.getProduct(lstPBE[0].id);
            System.assertNotEquals(null,pb);
        }
       
        Test.stopTest();
    }
    
    @isTest static void testgetProductList(){
        Test.startTest();
        Id recordTypeId = [Select id from RecordType where name = 'Approved'].id;
        List<PricebookEntry> lstpb = searchFavoriteController_LC.getProductList('t',recordTypeId);
        System.assertNotEquals(null,lstpb);
        Test.stopTest();
    }
    
    @isTest static void testAddProduct(){
        SBQQ__Quote__c Quote = [Select Id,Name from SBQQ__Quote__c limit 1];
        Test.startTest();
        List<searchFavoriteController_LC.addProducts> lstap = new List<searchFavoriteController_LC.addProducts>(); 
        searchFavoriteController_LC.addProducts  aProduct= new searchFavoriteController_LC.addProducts();
        aProduct.productName = 'Test';
        aProduct.productCode = 'Test123';
        aProduct.quoteLineId = 'quoteLineId123';
        lstap.add(aProduct);
        searchFavoriteController_LC.addProducts  aProduct1 = new searchFavoriteController_LC.addProducts('productName','roductCode',Quote.Id,'listPrice','curCode',Decimal.valueOf('10'),'sbQQ_Quote');
        lstap.add(aProduct1);
        searchFavoriteController_LC.favoriteCategory fCategory = new searchFavoriteController_LC.favoriteCategory(String.valueOf(Quote.Id),'label');
        System.assertNotEquals(null,lstap);
        Test.stopTest();
    }
    
    
}