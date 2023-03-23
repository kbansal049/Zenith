@isTest
public class DatacenterTriggerHandlerTest {
    @isTest static void testMethod1() {
        Id CaviumRecordTypeIDId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('New_Cavium_Card').getRecordTypeId();
        Test.startTest();
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;
        Equipment_Request__c caviumCard=new Equipment_Request__c(Opportunity__c=Opportunity.Id, Localized_content__c=true, RecordTypeId = CaviumRecordTypeIDId);  
        insert caviumCard;
        String datacenterJSON = '{"Facility_Address__c":"123, Testing","Facility_City__c":"AuthError",'
                              + '"Facility_Country__c":"US","Facility_State__c":"ca","Facility_ZIP_Code__c":"95134",'
                              + '"Legacy_Entry__c":false,"Name":"Testing encoding","Override_Geolocation__c":false,'
                              + '"Project_Manager_Name__c":"Vijay","Project_Manager_Phone_No__c":"98765456789",'
                              + '"Projet_Manager_Email_Address__c":"vprakash@zscaler.com","RecordTypeId":"01270000000Q8LuAAK",'
                              + '"Shipment_Receiving_contact_Email__c":"vprakash@zscaler.com","Shipment_Receiving_Contact_Name__c":"Prakash"'
                              + ',"Shipment_Receiving_Contact_Ph_No__c":"98765434567","Shipping_Address__c":"110 Rose Orchard Way","Status__c":"Submitted"}';
        Datacenter__c dc = (Datacenter__c)JSON.deserialize(datacenterJSON, Type.forName('Datacenter__c'));
        dc.equipment_request__c = caviumCard.id;
        insert dc;
    }
}