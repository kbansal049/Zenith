@isTest
public class PurchaseInvoiceBatchTest {
	@testSetup
    static void setup(){
        List<Campaign> CmpgnList= new List<Campaign>();
        Campaign cm = new Campaign();
        cm.name='ZPA Interactive';
        cm.Department__c = '5000-Corporate Marketing';
        cm.Geo__c = 'GLOBAL';
        cm.StartDate = Date.today();
        cm.EndDate = Date.today()+30;
        cm.Fiscal_Year__c = 'All Time';
        cm.Type = 'Default';
        cm.Campaign_Type__c = 'Assets';
        //cm.Activity_Details__c = 'ebook';
        cm.Recommended_Outreach_Sequence__c ='Testing';
        CmpgnList.add(cm);
        insert cm;
        
        List<Purchase_Invoice__c> PIlist = new List<Purchase_Invoice__c>();
        Purchase_Invoice__c p = new Purchase_Invoice__c();
        p.Campaign__c = cm.id;
        p.Amount__c = 200;
        p.Coupa_Invoice_Number__c = 'abc';
        
        PIlist.add(p);
        
        Purchase_Invoice__c p1 = new Purchase_Invoice__c();
        p1.Campaign__c = cm.id;
        p1.Amount__c = 200;
        p1.Coupa_Invoice_Number__c = 'abcd';
        
        PIlist.add(p1);
        
        insert PIlist;
        
        
    }
    
    @isTest static void test() {
        Test.startTest();
        PurchaseInvoiceBatch pi = new PurchaseInvoiceBatch();
        Id batchId = Database.executeBatch(pi);
        Test.stopTest();
        
        //System.assertEquals(10, [select count() from contact where MailingCity = 'New York']);
    }
}