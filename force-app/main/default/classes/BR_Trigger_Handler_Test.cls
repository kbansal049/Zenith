@isTest
public class BR_Trigger_Handler_Test{
    static testmethod void test1(){
        Event_Expenditure_Request__c er = new Event_Expenditure_Request__c(Name = 'BR1', 
                                                                           Does_this_contract_require_signature__c = 'No',
                                                                           Vendor_Technical_Contact_Email__c = 'abc@abc.com',
                                                                           Vendor_is_providing_consulting_services__c = 'Yes',
                                                                           Payment_terms_check__c = 'Yes',
                                                                           Vendors_access_to_Zscaler_employee_Data__c = 'Yes',
                                                                           Vendors_access_to_Zscaler_customer_Data__c = 'No',
                                                                           Cancellation_Terms_check__c = 'Yes',
                                                                           Foreign_Zscaler_Entity_Located__c = 'Yes',
                                                                           No_Auto_Renewal_Check__c = 'Yes',
                                                                           Confirmation_for_Zscaler_Vendor_Address__c = 'Yes',
                                                                           Contract_Language_Check__c = 'Yes',
                                                                           Confirmation_for_Event_Details__c = 'Yes'
                                                                          );
        insert er;
        er.Does_this_contract_require_signature__c = 'Yes';
        try{
            update er;
        }catch(Exception ex){
        }
        
    }

}