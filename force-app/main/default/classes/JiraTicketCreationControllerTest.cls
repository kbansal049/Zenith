@istest
public class JiraTicketCreationControllerTest {

    static testmethod void test1(){
        Id serviceedgePZENRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('ZIA_Service_Edge_PZEN').getRecordTypeId();
       
        //Admin Entries
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        
        //Skip Triggers
        TriggerUtility.skipOpportunityTrigger();
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment, Type = 'New Business');
        insert opportunity;
        
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true, RecordTypeId = serviceedgePZENRecordTypeId);
        insert EquiReq;
        
        String datacenterJSON = '{"Facility_Address__c":"123, Testing","Facility_City__c":"San Jose",'
            + '"Facility_Country__c":"US","Facility_State__c":"ca","Facility_ZIP_Code__c":"95134",'
            + '"Legacy_Entry__c":false,"Name":"Testing encoding","Override_Geolocation__c":false,'
            + '"Project_Manager_Name__c":"Vijay","Project_Manager_Phone_No__c":"98765456789",'
            + '"Projet_Manager_Email_Address__c":"vprakash@zscaler.com","RecordTypeId":"01270000000Q8LuAAK",'
            + '"Shipment_Receiving_contact_Email__c":"vprakash@zscaler.com","Shipment_Receiving_Contact_Name__c":"Prakash"'
            + ',"Shipment_Receiving_Contact_Ph_No__c":"98765434567","Shipping_Address__c":"110 Rose Orchard Way","Status__c":"Submitted"}';
        Datacenter__c dc = (Datacenter__c)JSON.deserialize(datacenterJSON, Type.forName('Datacenter__c'));
        insert dc;
        System.debug(dc);
        
        
        Node_Configuration__c nc = new Node_Configuration__c();
        nc.Equipment_Request__c = EquiReq.id;
        nc.Datacenter__c = dc.id;
        nc.Primary_DNS_Recursor__c = '192.168.1.1';
        nc.Secondary_DNS_Recursor__c = '192.168.1.1';
        nc.VPN_Public_IP__c = '192.168.1.1';
        nc.NC2_VPN_Public_IP__c = '192.168.1.1';
        nc.Load_Balance_Public_IP__c = '192.168.1.1';
        nc.SI_Public_Service_IP__c = '192.168.1.1';
        nc.Public_Service_IP_2__c = '192.168.1.1';
        nc.NC2_Public_Service_IP_1__c = '192.168.1.1';
        nc.NC2_Public_Service_IP_2__c = '192.168.1.1';
        nc.Service_CIDR_Netmask__c = '/26 (255.255.255.192)';
        nc.NC2_Service_CIDR_Netmask__c = '/26 (255.255.255.192)';
        nc.NC2_Public_Management_IP__c = '192.168.1.1';
        nc.LBC1_Public_Management_IP__c = '192.168.1.1';
        nc.Organization_ID__c = '1234';
        insert nc;
        
        NC_JIRA_Ticket__c jc = new NC_JIRA_Ticket__c();
        jc.Node_Configuration__c =nc.id;
        jc.DNS_Servers__c =  '192.168.1.1';
        jc.Hostname__c =  'test';
        jc.Issue_Type__c =  'test';
        insert jc;
        
        JiraTicketCreationController.JiraWrapper jw =  JiraTicketCreationController.getJiraDetails(jc.id);
        System.debug('---jw---'+jw);
        JiraTicketCreationController.getJiraDetails(nc.id);
        
        JiraTicketCreationController.NodeConfigWrapper ncWrap =  JiraTicketCreationController.getNodeConfigDetails(nc.id);
        System.debug('---ncWrap---'+ncWrap);
        JiraTicketCreationController.getNodeConfigDetails(jc.id);
        JiraTicketCreationController.getNodeConfigDetails(null);
        
        JiraTicketCreationController.DataCenterWrapper jdcWrap = JiraTicketCreationController.getDataCenterDetails(dc.id);
        System.debug('---jdcWrap---'+jdcWrap);
        JiraTicketCreationController.getDataCenterDetails(nc.id);
        
        JiraTicketCreationController.generateJiraPlatFormEvent(jc.id,nc.id);
        JiraTicketCreationController.generateJiraPlatFormEvent(null,nc.id);
        
        
        JiraTicketCreationController.updateNodeConfigJiraStatus(nc.id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(jc);
        ApexPages.currentPage().getParameters().put('ncid',nc.id);
        
        JiraTicketCreationController controller = new JiraTicketCreationController(stdController);
        controller.validateAndRedirect();
        controller.doRedirectNodeConfig();    
    }
    
    static testmethod void test2(){
        Id serviceedgePZENRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('ZIA_Service_Edge_PZEN').getRecordTypeId();
        
        //Admin Entries
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        
        //Skip Triggers
        TriggerUtility.skipOpportunityTrigger();
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment, Type = 'New Business');
        insert opportunity;
        
        Equipment_Request__c EquiReq=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true, RecordTypeId = serviceedgePZENRecordTypeId);
        insert EquiReq;
        
        String datacenterJSON = '{"Facility_Address__c":"123, Testing","Facility_City__c":"San Jose",'
            + '"Facility_Country__c":"US","Facility_State__c":"ca","Facility_ZIP_Code__c":"95134",'
            + '"Legacy_Entry__c":false,"Name":"Testing encoding","Override_Geolocation__c":false,'
            + '"Project_Manager_Name__c":"Vijay","Project_Manager_Phone_No__c":"98765456789",'
            + '"Projet_Manager_Email_Address__c":"vprakash@zscaler.com","RecordTypeId":"01270000000Q8LuAAK",'
            + '"Shipment_Receiving_contact_Email__c":"vprakash@zscaler.com","Shipment_Receiving_Contact_Name__c":"Prakash"'
            + ',"Shipment_Receiving_Contact_Ph_No__c":"98765434567","Shipping_Address__c":"110 Rose Orchard Way","Status__c":"Submitted"}';
        Datacenter__c dc = (Datacenter__c)JSON.deserialize(datacenterJSON, Type.forName('Datacenter__c'));
        insert dc;
        System.debug(dc);
        
        
        Node_Configuration__c nc = new Node_Configuration__c();
        nc.Equipment_Request__c = EquiReq.id;
        nc.Datacenter__c = dc.id;
        nc.Primary_DNS_Recursor__c = '192.168.1.1';
        nc.Secondary_DNS_Recursor__c = '192.168.1.1';
        nc.VPN_Public_IP__c = '192.168.1.1';
        nc.NC2_VPN_Public_IP__c = '192.168.1.1';
        nc.Load_Balance_Public_IP__c = '192.168.1.1';
        nc.SI_Public_Service_IP__c = '192.168.1.1';
        nc.Public_Service_IP_2__c = '192.168.1.1';
        nc.NC2_Public_Service_IP_1__c = '192.168.1.1';
        nc.NC2_Public_Service_IP_2__c = '192.168.1.1';
        nc.Service_CIDR_Netmask__c = '/26 (255.255.255.192)';
        nc.NC2_Service_CIDR_Netmask__c = '/26 (255.255.255.192)';
        nc.NC2_Public_Management_IP__c = '192.168.1.1';
        nc.LBC1_Public_Management_IP__c = '192.168.1.1';
        nc.Organization_ID__c = '1234';
        insert nc;
        
        NC_JIRA_Ticket__c jc = new NC_JIRA_Ticket__c();
        jc.Node_Configuration__c =nc.id;
        jc.DNS_Servers__c =  '192.168.1.1';
        jc.Hostname__c =  'test';
        jc.Issue_Type__c =  'test';
        insert jc;
        
        
        
        
        JiraTicketCreationController.JiraWrapper jw =  JiraTicketCreationController.getJiraDetails(jc.id);
        System.debug('---jw---'+jw);
        
        JiraTicketCreationController.throwCustomException = true;
        JiraTicketCreationController.getJiraDetails(nc.id);
        JiraTicketCreationController.throwCustomException = false;
        
        JiraTicketCreationController.NodeConfigWrapper ncWrap =  JiraTicketCreationController.getNodeConfigDetails(nc.id);
        System.debug('---ncWrap---'+ncWrap);
        
        JiraTicketCreationController.getNodeConfigDetails(null);
        
        JiraTicketCreationController.throwCustomException = true;
        JiraTicketCreationController.getNodeConfigDetails(jc.id);
        JiraTicketCreationController.throwCustomException = false;
        
        JiraTicketCreationController.getNodeConfigDetails(jc.id);
        
        JiraTicketCreationController.DataCenterWrapper jdcWrap = JiraTicketCreationController.getDataCenterDetails(dc.id);
        System.debug('---jdcWrap---'+jdcWrap);
        JiraTicketCreationController.getDataCenterDetails(nc.id);
        
        JiraTicketCreationController.generateJiraPlatFormEvent(jc.id,nc.id);
        JiraTicketCreationController.generateJiraPlatFormEvent(null,nc.id);
        
        
        JiraTicketCreationController.updateNodeConfigJiraStatus(nc.id);
        
        JiraTicketCreationController.throwCustomException = true;
        JiraTicketCreationController.generateJiraPlatFormEvent(jc.id,nc.id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(jc);
        ApexPages.currentPage().getParameters().put('ncid',nc.id);
        
        JiraTicketCreationController controller = new JiraTicketCreationController(stdController);
        controller.validateAndRedirect();
        controller.doRedirectNodeConfig();    
    }
    
}