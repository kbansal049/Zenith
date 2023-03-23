@isTest
public class QuoteApproval_VFControllerTest {
    
     // - static variables
	static User adminUser;
    
    @testSetup static void setup() {
        
        List<Account> lstAccount =  new List<Account>(SB_TestCPQDataUtility.createAccount(1));
		insert lstAccount;
        
        List<PriceBook2> pb = SB_TestCPQDataUtility.createCustomPriceBooks(2);
		insert pb;
        
        List<product2>  lstproduct = SB_TestCPQDataUtility.createProduct(1,'Test','12330','','999');
        insert lstproduct;
        
        List<PricebookEntry> lstPBE = SB_TestCPQDataUtility.createPriceBookEntry(1,lstproduct[0].id, double.valueOf(2501));
        insert lstPBE;
        
        List<opportunity> lstOpp =  SB_TestCPQDataUtility.createOpportunity(1,'Test Opp', lstAccount[0].Id);
		insert lstOpp;
        
        String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        SBQQ__Quote__c quoteRec = (SB_TestCPQDataUtility.createQuote(1,lstOpp[0].Id, lstAccount[0].Id, lstAccount[0].Id, lstAccount[0].Id,quoteNewBusiness))[0];
        insert quoteRec;   

        adminUser =  SB_TestCPQDataUtility.createUsers(1, 'system', 'Administrator1' , 'System Administrator')[0];
		insert adminUser;
         
        System.runAs(adminUser) {
           // Create Public Group..
           Group grp = new Group();
           grp.name = 'Test Group1';
           grp.Type = 'Regular'; 
           Insert grp; 
     
           //Create Group Member
           GroupMember grpMem1 = new GroupMember();
           grpMem1.UserOrGroupId = adminUser.Id;
           grpMem1.GroupId = grp.Id;
           Insert grpMem1;
            
           // Create Approver
           sbaa__Approver__c objApprover = new sbaa__Approver__c();
           objApprover.sbaa__User__c = adminUser.Id;
           objApprover.Name	 = 'AMS DD Approval'; 
           INSERT objApprover;
            
           // Create Approval Chain
           sbaa__ApprovalChain__c objApprChain = new sbaa__ApprovalChain__c();
           objApprChain.sbaa__TargetObject__c = 'SBQQ__Quote__c';
           objApprChain.Name = 'Approval Chain 1'; 
           INSERT objApprChain;
            
           // Create Approval 
           sbaa__Approval__c objAppr = new sbaa__Approval__c();
           objAppr.sbaa__Status__c  = 'Requested';
           objAppr.Quote__c = quoteRec.Id;
           objAppr.sbaa__ApprovalStep__c = 1;
           objAppr.sbaa__Approver__c = objApprover.Id;
           objAppr.sbaa__AssignedTo__c = null;
           objAppr.sbaa__AssignedGroupId__c = grp.Id;  
           objAppr.sbaa__Rule__c = null;
           objAppr.sbaa__ApprovalChain__c = objApprChain.Id;  
           objAppr.sbaa__RecordField__c	 = 'Quote__c';    
           
           INSERT objAppr;
           
       }
    }
     
    @isTest static void testMethod1() {
        
			Test.startTest();
            	
        		sbaa__Approval__c objApproval = [Select Id, Name from sbaa__Approval__c Limit 1];
                
                PageReference pageRef = Page.ApproveOrRejectFromHomePage; 
		     	pageRef.getParameters().put('Id',objApproval.Id);
			    Test.setCurrentPage(pageRef);
            
				QuoteApproval_VFController objQuoteApproval_VFController = new QuoteApproval_VFController();
				objQuoteApproval_VFController.approve();
        		objQuoteApproval_VFController.reject();
        
			Test.stopTest();
    }

}