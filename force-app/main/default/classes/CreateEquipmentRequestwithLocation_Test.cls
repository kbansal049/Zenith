@isTest
public class CreateEquipmentRequestwithLocation_Test{
    
    static testmethod void test1(){
        Id serviceedgePZENRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('ZIA_Service_Edge_PZEN').getRecordTypeId();       
        String rectypeDC = 'Partner Datacenter';
        Test.startTest();
       
        insert new Requested_Hardware_Model_Values__c(name='ZIA_Service_Edge_PZEN', Values__c = 'HW1');
        Account account = new Account(Name = 'Test Account');
        insert account;
        Id accountId = account.Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true, RecordTypeId = serviceedgePZENRecordTypeId);
        
        insert EquiReq;
        PageReference pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('RecordType', String.valueOf(serviceedgePZENRecordTypeId));
        pageRef.getParameters().put('CF00N70000002s1R1_lkid', String.valueOf(Opportunity.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(EquiReq);
        CreateEquipmentRequestwithLocation  ctrl = new CreateEquipmentRequestwithLocation(sc);
        ctrl.pageLoad();
        ctrl.addLocation();
        ctrl.onSave();
        
        
        sc = new ApexPages.StandardController(EquiReq);
        ctrl = new CreateEquipmentRequestwithLocation(sc);
        
        pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('id', String.valueOf(EquiReq.Id));
        Test.setCurrentPage(pageRef);
        EquiReq.Approval_Status__c='Approved';
        update EquiReq;
        
        
        sc = new ApexPages.StandardController(EquiReq);
        ctrl = new CreateEquipmentRequestwithLocation(sc);
        
        pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('id', String.valueOf(EquiReq.Id));
        Test.setCurrentPage(pageRef);
        ctrl.pageLoad();
        ctrl.addLocation();
        ctrl.indextoRemove = '1';
        ctrl.RemoveLocation();
        ctrl.onCancel();
        ctrl.onSave();
        Test.stopTest();
    }
    
    @isTest
    public static void Private_ZEN_with_LB_EquipmentTest(){
        Id pZenwithLBRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Private_ZEN_with_LB').getRecordTypeId();
        String rectypeDC = 'Partner Datacenter';
        Test.startTest();
       
        insert new Requested_Hardware_Model_Values__c(name='Private_ZEN_with_LB', Values__c = 'HW1');
        Account account = new Account(Name = 'Test Account Private_ZEN_with_LB');
        insert account;
        Id accountId = account.Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity Private_ZEN_with_LB', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true, RecordTypeId = pZenwithLBRecordTypeId);
        
        insert EquiReq;
        
        Datacenter__c dataCenterRecord = new Datacenter__c(Equipment_Request__c=EquiReq.Id,name='Private_ZEN_with_LB DataCenter',Facility_Country__c='United States',
                                                          Facility_City__c = 'Lafayette',                                                             
                                                           Quantity_Requested__c = 12, 
                                                           Number_of_Users_at_location__c = 21, 
                                                           Available_Bandwidth_MBPS__c = 2.3, 
                                                           Download_throughput_ServiceEdge_Gbps__c=3.4, 
                                                           Reason_for_Pitching_PZEN__c = 'Latency>300 ms');
        insert dataCenterRecord;
        
        PageReference pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('RecordType', String.valueOf(pZenwithLBRecordTypeId));
        pageRef.getParameters().put('CF00N70000002s1R1_lkid', String.valueOf(Opportunity.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(EquiReq);
        CreateEquipmentRequestwithLocation  ctrl = new CreateEquipmentRequestwithLocation(sc);
        ctrl.pageLoad();        
        ctrl.addLocation();
        ctrl.getReqHWmodel();
        ctrl.onSave();
        
        
        sc = new ApexPages.StandardController(EquiReq);
        ctrl = new CreateEquipmentRequestwithLocation(sc);
        
        pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('id', String.valueOf(EquiReq.Id));
        Test.setCurrentPage(pageRef);
        EquiReq.Approval_Status__c='Approved';
        update EquiReq;
        
        
        sc = new ApexPages.StandardController(EquiReq);
        ctrl = new CreateEquipmentRequestwithLocation(sc);
        
        pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('id', String.valueOf(EquiReq.Id));
        Test.setCurrentPage(pageRef);
        ctrl.pageLoad();
        ctrl.addLocation();
        ctrl.indextoRemove = '1';
        ctrl.RemoveLocation();
        ctrl.onCancel();
        ctrl.onSave();
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void PZEN_EquipmentTest(){
        Id pZenRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('PZEN').getRecordTypeId();
        Id datacenterrectypeId = Schema.SObjectType.Datacenter__c.getRecordTypeInfosByName().get('Customer Datacenter').getRecordTypeId();
        String rectypeDC = 'Partner Datacenter';
        Test.startTest();
       
        insert new Requested_Hardware_Model_Values__c(name='PZEN', Values__c = 'HW1');
        Account account = new Account(Name = 'Test Account PZEN');
        insert account;
        Id accountId = account.Id;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity PZEN', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true, RecordTypeId = pZenRecordTypeId);        
        insert EquiReq;
                
        PageReference pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('RecordType', String.valueOf(pZenRecordTypeId));
        pageRef.getParameters().put('CF00N70000002s1R1_lkid', String.valueOf(Opportunity.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(EquiReq);
        CreateEquipmentRequestwithLocation  ctrl = new CreateEquipmentRequestwithLocation(sc);
        ctrl.pageLoad();
        ctrl.getOpportunity();
        ctrl.addLocation();
        ctrl.onSave();
        
        
        sc = new ApexPages.StandardController(EquiReq);
        ctrl = new CreateEquipmentRequestwithLocation(sc);
        
        pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('id', String.valueOf(EquiReq.Id));
        Test.setCurrentPage(pageRef);
        EquiReq.Approval_Status__c='Approved';
        update EquiReq;
        
        
        sc = new ApexPages.StandardController(EquiReq);
        ctrl = new CreateEquipmentRequestwithLocation(sc);
        
        pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('id', String.valueOf(EquiReq.Id));
        Test.setCurrentPage(pageRef);
        ctrl.pageLoad();
        ctrl.addLocation();
        ctrl.indextoRemove = '1';
        ctrl.RemoveLocation();
        ctrl.onCancel();
        ctrl.onSave();
        
        
        Datacenter__c dataCenterRecord = new Datacenter__c(Equipment_Request__c=EquiReq.Id,name='PZEN DataCenter',Facility_Country__c='United States',
                                                          Facility_City__c = 'Lafayette',                                                             
                                                           Quantity_Requested__c = 12, 
                                                           Number_of_Users_at_location__c = 21, 
                                                           Available_Bandwidth_MBPS__c = 2.3, 
                                                           Download_throughput_ServiceEdge_Gbps__c=3.4, 
                                                           Reason_for_Pitching_PZEN__c = 'Latency>300 ms',
                                                           Requested_Hardware_Model__c = 'ZIA Service Edge-5 + LB (>5Gbps only)',
                                                           Quantity_Requested_for_LB__c = 1);
        insert dataCenterRecord;
        
        pageRef = Page.Equipment_Request_Creation;
        pageRef.getParameters().put('id', String.valueOf(EquiReq.Id));
        Test.setCurrentPage(pageRef);        
        ctrl.pageLoad();
        ctrl.addLocation();
        ctrl.getReqHWmodel();
        ctrl.getNumberOfUsersAtLocation();
        ctrl.getQuantityRequested();
        ctrl.getQuantityRequestedForLB();
        ctrl.indextoRemove = '1';
        ctrl.RemoveLocation();
        ctrl.onCancel();
        ctrl.onSave();
        
        Test.stopTest();
        
        
    }
}