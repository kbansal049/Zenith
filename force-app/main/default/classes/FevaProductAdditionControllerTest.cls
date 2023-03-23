/*****************************************************************************************
Name: FevaProductAdditionControllerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for FevaProductAdditionController class.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            22-Aug-2016    Initial Development
******************************************************************************************/ 

@isTest/*(seeAllData = true)*/
public class FevaProductAdditionControllerTest{
    @isTest static void test(){
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        test.starttest();
        
        Account acc = new Account(Name = 'Test Account',Type = 'Customer');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        
        try{
            insert pr;
        }catch(Exception ex){
            
        }
        
        PageReference pageRef = new PageReference('/apex/FevaProductAddition?reqId='+pr.Id);
        Test.setCurrentPage(pageRef);
        try{
            FevaProductAdditionController controller = new FevaProductAdditionController();
            controller.addProduct();
            controller.removeProduct();
            controller.saveProduct();
            PageReference pageRef1 = new PageReference('/apex/FevaProductAddition?reqId='+pr.Id);
            Test.setCurrentPage(pageRef1);
            FevaProductAdditionController controller1 = new FevaProductAdditionController();
            
            controller1.productId = controller1.addedProductList[0].Id;
            controller1.removeProduct();
            controller1.productId = controller1.allProductList[0].Id;
            
            controller1.addProduct();
            controller1.saveProduct();
        }catch(Exception ex){}
        test.stoptest();
        
    }
    @isTest static void test1(){
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        test.starttest();
        
        Account acc = new Account(Name = 'Test Account',Type = 'Customer');
        insert acc;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Internal_user__c = true;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        pr.Approval_Status__c='Pending Approval';
        
        
        try{
            insert pr;
            Product2 productSO = new Product2();
            productSO.Name = 'Product2';
            productSO.Family = 'Products';
          
            productSO.IsActive = true;
         
            productSO.Zscaler_Product_Family__c = 'ZIA';
           
            productSO.POC_Products__c = 'Popular';
            productSO.VZen__c = true;
            insert productSO;
            POC_Product__c poc = new POC_Product__c();
            poc.Product__c=productSO.id;
            poc.Provisioning_Request__c = pr.id;
            insert poc;
            
        }catch(Exception ex){
            
        }
        
        PageReference pageRef = new PageReference('/apex/FevaProductAddition?reqId='+pr.Id);
        Test.setCurrentPage(pageRef);
        try{
            Product2 productSO1 = new Product2();
            productSO1.Name = 'Product2';
            productSO1.Family = 'Products';
            productSO1.IsActive = true;
        
            

            productSO1.Zscaler_Product_Family__c = 'ZIA';
            
            productSO1.POC_Products__c = 'Popular';
            insert productSO1;
            FevaProductAdditionController controller = new FevaProductAdditionController();
            
            controller.addedProductList.add(productSO1);
            controller.isOpportunityVZENApproved=false;
            controller.addProduct();
            
            controller.removeProduct();
            controller.saveProduct();
            PageReference pageRef1 = new PageReference('/apex/FevaProductAddition?reqId='+pr.Id);
            Test.setCurrentPage(pageRef1);
            FevaProductAdditionController controller1 = new FevaProductAdditionController();
            
            controller1.productId = controller1.addedProductList[0].Id;
            controller1.removeProduct();
            controller1.productId = controller1.allProductList[0].Id;
            
            controller1.addProduct();
            controller1.saveProduct();
            
            
        }catch(Exception ex){}
        
        try{
            Product2 productSO1 = new Product2();
            productSO1.Name = 'Product2';
            productSO1.Family = 'Products';
            productSO1.IsActive = true;            
            productSO1.Zscaler_Product_Family__c = 'ZIA'; 
            productSO1.POC_Products__c = 'Regular';
            insert productSO1;
            FevaProductAdditionController controller = new FevaProductAdditionController();
            
            controller.addedProductList.add(productSO1);
            controller.isOpportunityVZENApproved=false;
            controller.addProduct();
            
            controller.removeProduct();
            controller.saveProduct();
            PageReference pageRef1 = new PageReference('/apex/FevaProductAddition?reqId='+pr.Id);
            Test.setCurrentPage(pageRef1);
            FevaProductAdditionController controller1 = new FevaProductAdditionController();
            
            controller1.productId = controller1.addedProductList[0].Id;
            controller1.removeProduct();
            controller1.productId = controller1.allProductList[0].Id;
            
            controller1.addProduct();
            controller1.saveProduct();
            
            
        }catch(Exception ex){}
        test.stoptest();
        
    }
}