@isTest
public class CreateSurveyForExistingCustomerBatchTest {
    @testSetup
    static void setup() {
        
                Account acc = new Account(Name = 'Test Account',
                                  Type='Prospect',
                                  BillingCountry = '',
                                  BillingState = '',
                                  BillingPostalCode = '',
                                  Domain__c = '',
                                  Industry = '',
                                  Market_Segment__c = '');
        insert acc;
        
        Product2 product1 = new Product2(ProductCode = 'ZIA-TRANS-EDITION', Name = 'Zscaler Internet Security Platform', Family = 'ZIA',
                                         IsActive = true);
        insert product1;
        
        Contract_Detail__c  contract1 = new Contract_Detail__c();
        contract1.Name = 'Test Contract1';
        contract1.Account_Name__c = acc.Id;        
        contract1.Quantity__c = 10000;
        contract1.Contract_Detail_Status__c = 'Active';
        contract1.Product_Name__c = product1.Id;
        contract1.Do_not_Aggregate__c = false;
        contract1.Override_Contract_Detail_Status__c = false;
        contract1.Start_Date__c = Date.today().addDays(-90);
        contract1.End_Date__c = Date.today().addDays(100);
        contract1.Amount_USD__c = 50000.00;
        contract1.ZScaler_Product_Family__c = 'ZIA';
        contract1.Is_Bundle_SKU__c = true;
        insert contract1;
        
       	
        Contact con= new Contact(accountid = acc.Id,lastname = 'testContact1', email='testContact1@abc.com');
        insert con;
       	Contact con1= new Contact(accountid = acc.Id,lastname = 'testContact12', email='testContact2@abc.com');
        insert con1;
        Contact con2= new Contact(accountid = acc.Id,lastname = 'testContact13', email='testContact3@yahoo.it');
        insert con2;
		Contact con3= new Contact(accountid = acc.Id,lastname = 'testContact13', email='testContact4@gmail.com');
        insert con3;
        
        Email_Domains_to_Exclude__c e = new Email_Domains_to_Exclude__c(Name='yahoo.it');
        insert e;
        
    }  
    static testMethod void testMethod1(){
            Test.startTest();
            CreateSurveyForExistingCustomerBatch acc = new CreateSurveyForExistingCustomerBatch();        
       		Database.executeBatch(acc,40);
    }
}