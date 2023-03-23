/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* KeyContactsManagementController
* @description    This is the Key Contacts Management Controller class called synchronously 
                  from lwc component keyContactsManagement.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2023-02-20
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            Aman Jain
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2023-01-17      IBA-6638 Aman - Creation of the class for adding the aura enabled methods to fetch
                  key contact information and update it.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public with sharing class KeyContactsManagementController {
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6638 : to fetch all active contacts of a
      particular account
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : getContactWrapperMap.
    * @param    NAME : String recordId.
    * @return   TYPE : Map<Id, ContactWrapper>.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static Map<Id, ContactWrapper> getContactWrapperMap(String recordId) {
        Map<Id, ContactWrapper> contactWrapperMap = new Map<Id, ContactWrapper>();
        List<Contact> contactList = 
        [
            SELECT Id,
            Name, Title,
            IT_Executive__c,
            Head_of_Networking_CTO_Account__c, 
            Head_of_Security_Account__c, 
            Head_of_Architecture__c,
            Validation_date__c
            FROM Contact
            WHERE AccountId = :recordId
            AND Active__c = false
            ORDER BY IT_Executive__c DESC, 
            Head_of_Networking_CTO_Account__c DESC, 
            Head_of_Security_Account__c DESC, 
            Head_of_Architecture__c DESC, 
            Name ASC
            LIMIT 10000
        ];

        if (!contactList.isEmpty()) {
            for (Contact record :contactList) {
                ContactWrapper wrapper = getContactWrapper(record);
                contactWrapperMap.put(record.Id, wrapper);
            }
        }
        return contactWrapperMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6638 : to form ContactWrapper record
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : getContactWrapper.
    * @param    NAME : Contact record.
    * @return   TYPE : ContactWrapper.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static ContactWrapper getContactWrapper(Contact record) {
        ContactWrapper wrapper = new ContactWrapper();
        wrapper.contactId = record.Id;
        wrapper.contactName = record.Name;
        wrapper.contactUrl = '/'+ record.Id;
        wrapper.contactTitle = record.Title;
        wrapper.lastValidationDate = record.Validation_date__c;
        wrapper.isValidated = false;
        wrapper.headOfIT = record.IT_Executive__c;
        wrapper.headOfNetworking = record.Head_of_Networking_CTO_Account__c;
        wrapper.headOfSecurity = record.Head_of_Security_Account__c;
        wrapper.headOfArchitecture = record.Head_of_Architecture__c;
        return wrapper;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6638 : to update Key Contacts information on 
      account and contact.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : updateKeyContactsInformation.
    * @param    NAME : String accountId.
    * @param    NAME : String contactData.
    * @param    NAME : Boolean isAccountUpdated.
    * @return   TYPE : void.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static void updateKeyContactsInformation
    (
        String accountData, 
        String validatedContactIds, 
        Boolean isAccountUpdated
    ) {
        try {
            TriggerHandler.bypass('AccountTriggerHandler');
            TriggerHandler.bypass('ContactTriggerHandler');
            DMLOperation dmlObject = new DMLOperation();
            if (isAccountUpdated) {
                Account accountRecord = fetchAccountRecord(accountData);
                dmlObject.dmlUpdate(new List<Account>{accountRecord});
            }
            List<Contact> contactList = fetchContactRecords(validatedContactIds);
            if (!contactList.isEmpty()) {
                dmlObject.dmlUpdate(contactList);
            }
        }
        catch (Exception error) {
            throw new AuraHandledException(
                'The following exception has occurred: ' + error.getMessage()
            );
        } finally {
            TriggerHandler.clearBypass('AccountTriggerHandler');
            TriggerHandler.clearBypass('ContactTriggerHandler');
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6638 : Fetch the updated account data
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : fetchAccountRecord.
    * @param    NAME : String accountData.
    * @return   TYPE : Account.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Account fetchAccountRecord(String accountData) {
        Account accountRecord = new Account();
        if (String.isNotBlank(accountData)) {
            Map<String, Object> accountMap = (Map<String, Object>) JSON.deserializeUntyped(accountData);
            accountRecord.Id = String.valueOf(accountMap.get('recordId'));
            accountRecord.HeadOfIT__c = String.valueOf(accountMap.get('headOfIT'));
            accountRecord.HeadOfNetworking__c = String.valueOf(accountMap.get('headOfNetworking'));
            accountRecord.HeadOfSecurity__c = String.valueOf(accountMap.get('headOfSecurity'));
            accountRecord.Head_of_Architecture__c = String.valueOf(accountMap.get('headOfArchitecture'));
        }
        return accountRecord;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6638 : Fetch the contact records which needs 
    to be validated
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : fetchContactRecords.
    * @param    NAME : String validatedContactIds.
    * @return   TYPE : List<Contact>.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Contact> fetchContactRecords(String validatedContactIds) {
        List<Contact> contactList = new List<Contact>();
        if (String.isNotBlank(validatedContactIds)) {
            Set<String> contactIds = (Set<String>) JSON.deserialize
            (
                validatedContactIds,
                Set<String>.class
            );
            for (String contactId :contactIds) {
                Contact contactRecord = getGenericContact(Id.valueOf(contactId));
                contactList.add(contactRecord);
            }
        }
        return contactList;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-6638 : Fetch default contact record instance
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : getGenericContact.
    * @param    NAME : Id contactId.
    * @return   TYPE : Contact.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Contact getGenericContact(Id contactId) {
        Contact contactRecord = new Contact
        (
            Id = contactId, 
            Validation_date__c = System.Today()
        );
        return contactRecord;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
    * DMLOperation
    * @description:  This is for doing dml operations without sharing enforced.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────
    **/
    without sharing class DMLOperation {
        private void dmlUpdate(List<SObject> objList) {
            update objList;
        }
    }

    //ContactWrapper Class
    public class ContactWrapper {
        @AuraEnabled
        public String contactId{get; set;}
        @AuraEnabled
        public String contactUrl{get; set;}
        @AuraEnabled
        public String contactName{get; set;}
        @AuraEnabled
        public String contactTitle{get; set;}
        @AuraEnabled
        public Date lastValidationDate{get; set;}
        @AuraEnabled
        public Boolean isValidated{get; set;}
        @AuraEnabled
        public Boolean headOfIT{get; set;}
        @AuraEnabled
        public Boolean headOfNetworking{get; set;}
        @AuraEnabled
        public Boolean headOfSecurity{get; set;}
        @AuraEnabled
        public Boolean headOfArchitecture{get; set;} 
    }
}