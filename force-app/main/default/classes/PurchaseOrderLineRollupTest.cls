/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   23-02-2022   Mahesh T.    Initial Version
*/
@isTest
public class PurchaseOrderLineRollupTest {

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
        insert cm1;
        
        Purchase_Order_Line__c c1 = new Purchase_Order_Line__c();
        c1.Purchase_Order_Line_Campaign__c = cm1.id;
        
        insert c1;
        c1.Purchase_Order_Line_Amount_USD__c = 500;
       // List<Purchase_Order_Line__c> i1 = [select id from Purchase_Order_Line__c where id=:c1.Id]; 
       //System.debug('id of i1-->'+i1);
        update c1;
        Purchase_Order_Line__c c2 = new Purchase_Order_Line__c();
        c2.Purchase_Order_Line_Campaign__c = cm1.id;
     
        insert c2;
        c2.Purchase_Order_Line_Amount_USD__c = 200;
        //list<Purchase_Order_Line__c> i2 = [select id from Purchase_Order_Line__c where id=:c2.Id];
        update c2;
    }
    

    
}