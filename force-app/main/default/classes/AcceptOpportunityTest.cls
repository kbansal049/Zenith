@isTest
public class AcceptOpportunityTest {
    @testSetup static void setup() {  
        
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.TAM_Email__c = 'abc@abc.com';
        insert acc;
        
        opportunity oppty= new opportunity();
        oppty.Name = 'Testopportunity';
        oppty.Primary_Quote_Exception__c  = true; 
        oppty.AccountId = acc.Id;
        oppty.StageName = '6 - Closed Won';
        oppty.CloseDate = system.Today()+30;
        oppty.Netsuite_Sales_Order_Number__c = 'TestOrder';
        oppty.Applied_Price_List_Name__c = 'FY20 Pricelist';
        insert Oppty;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud Details').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = Oppty.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        try{
            insert pr;
        }catch(Exception ex){    
        }  
    }
    public static testMethod void convertToContractTest1(){
    
        opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        AcceptOpportunity.acceptOpp(opp.Id);	
        Test.stopTest();
    }
}