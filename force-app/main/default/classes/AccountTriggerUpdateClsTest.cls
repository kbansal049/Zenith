@isTest
public class AccountTriggerUpdateClsTest {

     
    @isTest 
    private static void isPartnerUpdateTest(){
        
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Partner', null, null, null);     
        acc.Type='Ex - Partner';
        
        update acc;
    }
    
  /*  @isTest 
    private static void updateCTMTest2(){
        
        Account ac = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Contact cont = TestDatafactory_Zscaler.insertContact('Test Contact', ac.Id, null);
        
       	ac.HeadOfSecurity__c = cont.Id;
        ac.HeadOfSecurity_Primary__c = true;
        update ac;
    }
    
    @isTest  
    private static void updateCTMTest3(){
        
        Account ac = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Contact cont = TestDatafactory_Zscaler.insertContact('Test Contact', ac.Id, null);
        
       	ac.HeadOfNetworking__c = cont.Id;
        ac.HeadOfNetworking_Primary__c = true;
        update ac;
    }
    
    @isTest  
    private static void updateCTMTest4(){
        
        Account ac = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        Contact cont = TestDatafactory_Zscaler.insertContact('Test Contact', ac.Id, null);

		ac.HeadOfIT__c	= cont.Id;
		ac.HeadOfIT_CIO_Primary__c = true;
        update ac;
    }  */
    
}