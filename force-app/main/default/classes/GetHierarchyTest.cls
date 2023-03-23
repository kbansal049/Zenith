@isTest
public class GetHierarchyTest {
    
    @testSetup
    static void testData(){
        Account acc = new Account();
        acc.Name ='Test Account';
        acc.Type ='Partner';
        acc.BillingCountry = 'France';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name ='Test Account1';
        acc1.Type ='Partner';
        acc1.BillingCountry = 'France';
        acc1.parentid = acc.id;
        insert acc1;
        
        Account acc2 = new Account();
        acc2.Name ='Test Account2';
        acc2.Type ='Partner';
        acc2.BillingCountry = 'France';
        acc2.parentid = acc.id;
        insert acc2;  
        
        Account acc21 = new Account();
        acc21.Name ='Test Account21';
        acc21.Type ='Partner';
        acc21.BillingCountry = 'France';
        insert acc21; 
        
        Account acc22 = new Account();
        acc22.Name ='Test Account22';
        acc22.Type ='Partner';
        acc22.BillingCountry = 'France';
        insert acc22;
        
      
    }
    
    @isTest static void testmethod1(){
        Set<ID> accountIDSet = new Set<ID>();
        for(Account acc : [Select id from account where name in ('Test Account','Test Account2')]){
            accountIDSet.add(acc.id);
        }
        GetHierarchy.getHierarchyfromUltimateParent(accountIDSet, 2, 'Account');
    }
    
}