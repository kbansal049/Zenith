/**
 * Name : OperationalContactsTableCtrl
 * Description : Controller class for OperationalContactsTableLWC
 * Test Class : OperationalContactsTableCtrlTest
 * Initial Author : Ankit Bhatnagar
 */

public with sharing class OperationalContactsTableCtrl {
    public OperationalContactsTableCtrl() {}

    @AuraEnabled
    public static List<Contact> getOperationalContacts(Id recordId) {
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            String accId = '';
            if(sObjName == 'Account') {
                accId = recordId;
            }
            else if(sObjName == 'TAM_Engagement__c') {
                TAM_Engagement__c engagement = [SELECT id,Account__c FROM TAM_Engagement__c WHERE Id=:recordId];
                accId = engagement.Account__c;
            }
            return [SELECT Id,Name,email FROM Contact WHERE AccountId=:accId AND Operational_Contact__c = TRUE Order by Name ];
        }
        else return new List<Contact>();
    }

    @AuraEnabled
    public static String verifyContactParentAccount(Id recordId, String contactId) {
        if(String.isNotBlank(recordId)) {
            String sObjName = recordId.getSObjectType().getDescribe().getName();  
            String accId = '';
            if(sObjName == 'Account') {
                accId = recordId;
            }
            else if(sObjName == 'TAM_Engagement__c') {
                TAM_Engagement__c engagement = [SELECT id,Account__c FROM TAM_Engagement__c WHERE Id=:recordId];
                accId = engagement.Account__c;
            }
            List<Contact> contact = new List<Contact>([SELECT Id,Name,email,operational_Contact__c FROM Contact WHERE AccountId=:accId AND id=:contactId]);
            if(!contact.isEmpty()) {
                if(contact.get(0).Operational_Contact__c) {
                    return 'This contact is already an Operational Contact!';
                }
                else {
                    return 'Success';
                }
            }
            else {
                return 'This contact is not related to the Parent Account. Please select a different Contact.';
            }
        }
        else return 'Record ID is empty';
    }
    
    @AuraEnabled
    public static String markUnmarkContactAsOperational(String contactId, Boolean operationType) {
        try {
            if(String.isNotBlank(contactId)) {
                Contact c = new Contact(Id = contactId, Operational_Contact__c = operationType);
                update c;
                return 'Success';
            }
            else return 'Contact Id is empty';
        }
        catch(Exception e) {
            return e.getMessage();
        }   
    }
}