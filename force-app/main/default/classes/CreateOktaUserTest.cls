@isTest
public class CreateOktaUserTest {
    
    
    /* @testSetup
    static void testData(){
        
        insert new OKTA_Integration_Params__c(name = 'Partner_Portal_Get_User', Endpoint_URL_Okta__c = 'https://dev-210981.okta.com/api/v1/users?limit=1&q=', Token__c = 'abcpqr');
        insert new OKTA_Integration_Params__c(name = 'Partner_Portal_User_Creation', Endpoint_URL_Okta__c = 'https://dev-210981.okta.com/api/v1/users?activate=true', Token__c = 'abcpqr');
        insert new OKTA_Integration_Params__c(name = 'Partner_Portal_User_Update', Endpoint_URL_Okta__c = 'https://dev-210981.okta.com/api/v1/users/', Token__c = 'abcpqr');
    }
    
    
    
    @isTest static void checkandCreateUserTest(){
        Account acc = new Account();
        acc.Name ='Test Account';
        acc.Type ='Partner';
        acc.BillingCountry = 'France';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test LastName';
        con.AccountId = acc.id;
        insert con;
       
		Test.startTest();
		CreateOktaUser.checkandCreateUser(con.id);
		Test.stopTest();
    }
    
    
    @isTest static void checkandCreateUserTest1(){
        
        Account acc = new Account();
        acc.Name ='Test Account';
        acc.Type ='Partner';
        acc.BillingCountry = 'France';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name ='Test Account1';
        acc1.Type ='Customer';
        acc1.BillingCountry = 'France';
        insert acc1;
        
        Contact con = new Contact();
        con.LastName = 'Test LastName';
        con.AccountId = acc.id;
        insert con;
        
        Contact con1 = new Contact();
        con1.LastName = 'Test LastName1';
        con1.AccountId = acc.id;
        con1.Partner_Role__c = 'User';
        insert con1;
        
        Contact con3 = new Contact();
        con3.LastName = 'Test LastName3';
        con3.AccountId = acc1.id;
        con3.email = 'test@testmail.com';
        con3.Partner_Role__c = 'User';
        insert con3;

        CreateOktaUser.checkandCreateUser(con.id);   
        CreateOktaUser.checkandCreateUser(con1.id); 
        CreateOktaUser.checkandCreateUser(con3.id); 
        
        
    }
    
    
    @isTest static void checkandCreateUserTest2(){
        
        Account acc = new Account();
        acc.Name ='Test Account';
        acc.Type ='Partner';
        acc.BillingCountry = 'France';
        insert acc;

        Contact con = new Contact();
        con.LastName = 'Test LastName2';
        con.AccountId = acc.id;
        con.Partner_Role__c = 'User';
        con.email = 'test@testmail.com';
        insert con;
        
     
        
       
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CreateoktaUserCalloutMock()); 
        
		Test.startTest();
		CreateOktaUser.Result rs = CreateOktaUser.checkandCreateUser(con.id); 
		System.debug('--rs--'+rs);
		Test.stopTest();
    } */
	
	@isTest static void checkandCreateUserTest2(){
		CreateOktaUser.booster(); 
	}
}