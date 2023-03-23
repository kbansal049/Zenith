public without sharing class reUsableMultiSelectLookupCtrl {
    @AuraEnabled
    public static List <Contact> fetchLookUpValues(String searchKeyWord, String ObjectName, List<Id> recordList) {
        String searchKey = '%' + searchKeyWord + '%';
        List <Contact> lstOfRecords = [SELECT Id, Name, Title 
                                       FROM Contact 
                                       WHERE
                                       		ID NOT IN :recordList AND
                                       		Name LIKE: searchKey
                                       ORDER BY NAME ASC
                                       LIMIT 25];
        return lstOfRecords;
    }
    
    @AuraEnabled
    public static String fetchAssignedContact(Id cisorequestId){
        String assignedContacts;
        try{
            Security_Requests__c  record = [SELECT Id, Contact_Attendee_Role__c 
                                        FROM Security_Requests__c 
                                        WHERE Id = :cisorequestId];
            assignedContacts = record.Contact_Attendee_Role__c;
        } catch (Exception exp){
        	throw new AuraHandledException(exp.getMessage());
        }
        return assignedContacts;
    }
    
    @AuraEnabled
    public static Boolean saveAssignedContacts(Security_Requests__c  record){
        try{
            upsert record;
        } catch (Exception exp){
        	throw new AuraHandledException(exp.getMessage());
        }
        return true;
    }
}