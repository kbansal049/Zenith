@isTest
public class PurchaseInvoiceRollupTest {
  
    public static testMethod void test(){
      Campaign cm1 = new Campaign();
        cm1.name = 'test';
        cm1.Department__c = '5000-Corporate Marketing';
        cm1.Geo__c = 'GLOBAL';
        cm1.StartDate = Date.today();
        cm1.EndDate = Date.today()+30;
        cm1.Fiscal_Year__c = 'All Time';
        cm1.Type = 'Default';
        cm1.Campaign_Type__c = 'Assets';
        cm1.Activity_Details__c = 'ebook';
        //insert cm1;
        
        Purchase_Invoice__c c1 = new Purchase_Invoice__c();
        c1.Campaign__c = cm1.id;
        c1.Coupa_Invoice_Number__c = 'fdf';
        insert c1;
        c1.Amount__c = 500;
       // List<Purchase_Invoice__c> i1 = [select id from Purchase_Invoice__c where id=:c1.Id]; 
       //System.debug('id of i1-->'+i1);
        update c1;
        Purchase_Invoice__c c2 = new Purchase_Invoice__c();
        c2.Campaign__c = cm1.id;
        c2.Coupa_Invoice_Number__c = 'ffdf';
        insert c2;
        c2.Amount__c = 200;
        //list<Purchase_Invoice__c> i2 = [select id from Purchase_Invoice__c where id=:c2.Id];
    }
    
}