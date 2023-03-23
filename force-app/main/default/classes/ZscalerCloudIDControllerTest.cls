@isTest
public class ZscalerCloudIDControllerTest {
	@testSetup
    static void testSetup(){
        Account acc = new account();
        acc.Name = 'Test Account';
        acc.Type='Customer';
        acc.Prospect_Type__c='Pipeline';
        insert acc;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Domain__c ='Test';
        insert quote;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.StageName = '3 - Sponsorship';
        opp.CloseDate = system.today()+100;
        opp.SE_Manager__c = 'jwatkins@zscaler.com.invalid';
        opp.SBQQ__PrimaryQuote__c=quote.id;
        insert opp;

        Product2 ziaBusEditionProduct = new Product2(Name='ZIA Business Edition', product_line__c='ZIA', poc_products__c='Popular', IsActive=True,
                                      SKU_Type__c='GA', Provisioning_Product_Family__c='Bundles', Is_Applicable_for_POC__c=true,
                                      ProductCode='ZIA-BUS-EDITION', isBundle__c=true, provisioning_Contact_Type__c='BUSINESS_PRIMARY;ZDX_CONTACT');
        insert ziaBusEditionProduct;
        
        Zscaler_cloud_Id__c trailZCI1 = new Zscaler_cloud_Id__c(name='zscaler.net-769606', Zscaler_Cloud_Domain__c='allweiler.trail.de', account__c=acc.Id, status__c='Provisioned');
        insert trailZCI1;
        
        Zscaler_cloud_Id__c trailZCI2 = new Zscaler_cloud_Id__c(name='zscalerone.net-769606', Zscaler_Cloud_Domain__c='allweiler.trail.de', account__c=acc.Id, status__c='Provisioned');
        insert trailZCI2;
        
        Zscaler_cloud_Id__c subscriptionZCI1 = new Zscaler_cloud_Id__c(name='zscalertwo.net-769606', Zscaler_Cloud_Domain__c='allweiler.subscription.de', account__c=acc.Id, status__c='Provisioned');
        insert subscriptionZCI1;
        
        Zscaler_cloud_Id__c subscriptionZCI2 = new Zscaler_cloud_Id__c(name='zscalerthree.net-769606', Zscaler_Cloud_Domain__c='allweiler.subscription.de', account__c=acc.Id, status__c='Provisioned');
        insert subscriptionZCI2;
        
        Id trailPRGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        Provisioning_Group__c trailPRG1 = new Provisioning_Group__c();
        trailPRG1.Comments__c ='Test3';
        trailPRG1.Product_Line__c='ZIA';
        trailPRG1.Provisioning_Process__c='New Tenant';
        trailPRG1.Organization_Domain__c ='uoflhealthcare.org';
        trailPRG1.Status__c='Waiting';
        trailPRG1.Approval_Status__c='Submitted';
        trailPRG1.Sub_Status__c='';
        trailPRG1.PG_Request_Type__c='Create';
        trailPRG1.Provisioning_Type__c='Auto';
        trailPRG1.Preferred_Cloud__c='Zscaler.net';
        trailPRG1.Start_Date__c = System.today();
        trailPRG1.End_Date__c=Date.newInstance(2022, 12, 12);
        trailPRG1.Number_of_Extensions__c = 6;
        trailPRG1.RecordTypeId = trailPRGRecordTypeId;
        trailPRG1.Provisioning_Process__c = 'Decommission';
        trailPRG1.Zscaler_Cloud_ID__c = trailZCI1.id;
        trailPRG1.opportunity__c = opp.id;
        insert trailPRG1;
        
        Provisioning_Product__c trailPRGProduct1 = new Provisioning_Product__c();
        trailPRGProduct1.Name = 'Test2';
        trailPRGProduct1.Product__c = ziaBusEditionProduct.id;
        trailPRGProduct1.Quantity__c = 5;
        trailPRGProduct1.Provisioning_Group__c = trailPRG1.id;
        trailPRGProduct1.Start_Date__c = System.today();
        trailPRGProduct1.End_Date__c = System.today() + 360;
        insert trailPRGProduct1;        
        
        Provisioning_Contact__c trailPRGContact1 = new Provisioning_Contact__c();
        trailPRGContact1.Type__c = 'SALES_ENGINEER';
        trailPRGContact1.Provisioning_Group__c = trailPRG1.Id;
        insert trailPRGContact1;
        
        trailPRG1.Status__c='Initiated';
        update trailPRG1;
        
        List<ProcessInstance> trailPIList = [SELECT Id, TargetObjectId, LastActor.Name, Status, CreatedDate, CompletedDate, 
                          (SELECT Id, CreatedDate, ActorId, Actor.Name, OriginalActorId, OriginalActor.Name, StepNodeId, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC),  
                          (SELECT Id, CreatedDate, ProcessNodeName FROM Nodes ORDER BY CreatedDate DESC) 
                          FROM ProcessInstance
                          WHERE TargetObjectId = :trailPRG1.Id 
                          ORDER BY TargetObject.Name DESC];
        System.debug('111 ==>>> trailPIList val is: '+trailPIList);
        
        Id subscriptionPRGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        Provisioning_Group__c subscriptionPRG1 = new Provisioning_Group__c();
        subscriptionPRG1.Comments__c ='Test3';
        subscriptionPRG1.Product_Line__c='ZIA';
        subscriptionPRG1.Provisioning_Process__c='New Tenant';
        subscriptionPRG1.Organization_Domain__c ='uoflhealthcare.org';
        subscriptionPRG1.Status__c='Waiting ';
        subscriptionPRG1.Approval_Status__c='Submitted';
        subscriptionPRG1.Sub_Status__c='';
        subscriptionPRG1.PG_Request_Type__c='Create';
        subscriptionPRG1.Provisioning_Type__c='Auto';
        subscriptionPRG1.Preferred_Cloud__c='Zscaler.net';
        subscriptionPRG1.Start_Date__c = System.today();
        subscriptionPRG1.End_Date__c=Date.newInstance(2022, 12, 12);
        subscriptionPRG1.Number_of_Extensions__c = 6;
        subscriptionPRG1.RecordTypeId = subscriptionPRGRecordTypeId;
        subscriptionPRG1.Provisioning_Process__c = 'Decommission';
        subscriptionPRG1.Zscaler_Cloud_ID__c = subscriptionZCI1.id;
        subscriptionPRG1.opportunity__c = opp.id;
        insert subscriptionPRG1;
        
        Provisioning_Product__c subscriptionPRGProduct1 = new Provisioning_Product__c();
        subscriptionPRGProduct1.Name = 'ZIA Business Edition';
        subscriptionPRGProduct1.Product__c = ziaBusEditionProduct.id;
        subscriptionPRGProduct1.Quantity__c = 5;
        subscriptionPRGProduct1.Provisioning_Group__c = subscriptionPRG1.id;
        subscriptionPRGProduct1.Start_Date__c = System.today();
        subscriptionPRGProduct1.End_Date__c = System.today() + 360;
        insert subscriptionPRGProduct1;        
        
        Provisioning_Contact__c subscriptionPRGContact1 = new Provisioning_Contact__c();
        subscriptionPRGContact1.Type__c = 'SALES_ENGINEER';
        subscriptionPRGContact1.Provisioning_Group__c = subscriptionPRG1.Id;
        insert subscriptionPRGContact1;
        
        subscriptionPRG1.Status__c='Initiated';
        update subscriptionPRG1;
        
        List<ProcessInstance> subscriptionPIList = [SELECT Id, TargetObjectId, LastActor.Name, Status, CreatedDate, CompletedDate, 
                          (SELECT Id, CreatedDate, ActorId, Actor.Name, OriginalActorId, OriginalActor.Name, StepNodeId, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC),  
                          (SELECT Id, CreatedDate, ProcessNodeName FROM Nodes ORDER BY CreatedDate DESC) 
                          FROM ProcessInstance
                          WHERE TargetObjectId = :subscriptionPRG1.Id 
                          ORDER BY TargetObject.Name DESC];
        System.debug('222 ==>>> subscriptionPIList val is: '+subscriptionPIList);
    }
    
    @isTest
    static void testRetrivePGRecords(){
        Test.startTest();        
            Opportunity oppt = [SELECT Id, Name FROM Opportunity WHERE Name IN ('Test Opp')];
            List<Zscaler_cloud_Id__c> zciList = [SELECT Id, Name FROM Zscaler_cloud_Id__c WHERE Name LIKE '%-769606%'];
        	
	        ZscalerCloudIDController.retrivePGRecords(zciList[0].Id, oppt.Id);
            //ZscalerCloudWrapper traileZSCWrap = ZscalerCloudIDController.retrivePGRecords(zciList[0].Id, oppt.Id);
            
            ZscalerCloudIDController.retrivePGRecords(zciList[1].Id, oppt.Id);
        	//ZscalerCloudWrapper subscriptionZSCWrap = ZscalerCloudIDController.retrivePGRecords(zciList[1].Id, oppt.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetUpdatedProcessInstanceStepWrapperList(){
        Test.startTest();
            List<ProcessInstanceNode> pinList = new List<ProcessInstanceNode>();
            pinList.add(new ProcessInstanceNode());
            
            List<ProcessInstanceStep> pisList = new List<ProcessInstanceStep>();
            pisList.add(new ProcessInstanceStep());
            pisList.add(new ProcessInstanceStep());
            pisList.add(new ProcessInstanceStep());
            
            ZscalerCloudIDController.getUpdatedProcessInstanceStepWrapperList(pinList, pisList);
            //List<ProcessInstanceStepWrapper> pisWrapList = ZscalerCloudIDController.getUpdatedProcessInstanceStepWrapperList(pinList, pisList);
            
            pinList.add(new ProcessInstanceNode());
            pisList.add(new ProcessInstanceStep());
            
            ZscalerCloudIDController.getUpdatedProcessInstanceStepWrapperList(pinList, pisList);
            //List<ProcessInstanceStepWrapper> pisWrapList = ZscalerCloudIDController.getUpdatedProcessInstanceStepWrapperList(pinList, pisList);
        
        Test.stopTest();
    }
    
    @isTest
    static void testFirePlatformEvents(){
        List<Zscaler_cloud_Id__c> zciList = [SELECT Id, Name FROM Zscaler_cloud_Id__c WHERE Name LIKE '%-769606%'];
        Test.startTest();
	        ZscalerCloudIDController.firePlatformEvents(zciList[0].Id);
            ZscalerCloudIDController.firePlatformEvents(zciList[1].Id);
	        ZscalerCloudIDController.firePlatformEvents(zciList[2].Id);
            ZscalerCloudIDController.firePlatformEvents(zciList[3].Id);
		Test.stopTest();
    }    
}