@isTest
public class SCIExternalAttendeeTriggerHelperTest {
    
    @isTest
    static void updateContactSCICountTest() {
        List<Triggers_Switch__c> trlist = new List<Triggers_Switch__c>();
        trlist.add(new Triggers_Switch__c(name = 'Execute_UpdateContactSCICount', Execute__c = true));
        insert trlist;
        List<Contact> conList = new List<Contact>();
        Contact con2 = new Contact(FirstName = 'Test2',LastName = 'Test2',Contact_Lead_Status__c = 'Actively Engaged',Involved_in_Active_Oppty__c = false,Remarks__c = 'Replied: Not Interested'); 
        Contact con3 = new Contact(FirstName = 'Test3',LastName = 'Test3',Contact_Lead_Status__c = 'Actively Engaged',Involved_in_Active_Oppty__c = false );
        Contact con4 = new Contact(FirstName = 'Test4',LastName = 'Test4',Contact_Lead_Status__c = 'Actively Engaged',Involved_in_Active_Oppty__c = true,Remarks__c = 'Replied: Not Interested');
   		conlist.add(con2);   
		conlist.add(con3);
        conlist.add(con4);
        insert conlist;
        
        Test.startTest();
        Significant_Customer_Interaction__c sgi = new Significant_Customer_Interaction__c();
        insert sgi;
        
        List<SCI_External_Attendee__c> sciList = new List<SCI_External_Attendee__c>();
        SCI_External_Attendee__c sci = new SCI_External_Attendee__c(Attendee_Name__c = con2.Id,Significant_Customer_Interaction__c = sgi.Id);
        sciList.add(sci);
        SCI_External_Attendee__c sci1 = new SCI_External_Attendee__c(Attendee_Name__c = con3.Id,Significant_Customer_Interaction__c = sgi.Id);
		sciList.add(sci1);
        SCI_External_Attendee__c sci2 = new SCI_External_Attendee__c(Attendee_Name__c = con4.Id,Significant_Customer_Interaction__c = sgi.Id);
		sciList.add(sci2);
        insert sciList;
        Test.stopTest();
        Contact con = [Select SCI_Count__c,Contact_Lead_Status__c,Involved_in_Active_Oppty__c,Remarks__c,No_of_Cases__c From Contact WHERE id =: con3.Id];
        System.assertEquals(con.SCI_Count__c, 1);
    }
}