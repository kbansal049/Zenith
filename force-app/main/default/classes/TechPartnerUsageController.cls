public class TechPartnerUsageController {
    
    @AuraEnabled
    public static List<Technology_Partner_Usage__c> getTechnologyPartnerUsageRecords(String recordIdOfCustomerAccount) {
        return [SELECT Id,
                Name,
                Account_Type__c, 
                Cloud_Name__c, 
                Company_Id__c, 
                Company_Name__c, 
                Customer_Account__c,
                Technology_Partner_Id__r.Name,
                Segment__c,
                Technology_Partner__c,
                Technology_Partner_Id__c,
                Usage_Type__c,
                Org_ID__c,
                Org_ID__r.Name,
                Is_Primary__c,
                External_Id__c,
                ExcludeFromIntegrationUpdate__c,
                Notes__c                
                FROM Technology_Partner_Usage__c
                WHERE Customer_Account__c = : recordIdOfCustomerAccount
                Order By Technology_Partner_Id__r.Name, CreatedDate
                LIMIT 50000];
    }
    
    @AuraEnabled
    public static List<OrgIdComboBoxWrapper> getZSCloudDetails(String accountRecordId) {
        List<OrgIdComboBoxWrapper> orgIdComboBoxWrapperList = new List<OrgIdComboBoxWrapper>();
        List<Zscaler_Cloud_ID__c> zscloudIdList = [SELECT Id,
                                                   Name,
                                                   Account__c
                                                   FROM Zscaler_Cloud_ID__c
                                                   WHERE Account__c = : accountRecordId
                                                   Order By CreatedDate
                                                   LIMIT 50000];
        for(Zscaler_Cloud_ID__c zsCloudId : zscloudIdList){
            OrgIdComboBoxWrapper orgIdComboBoxWrapperObj = new OrgIdComboBoxWrapper();
            orgIdComboBoxWrapperObj.label = zsCloudId.Name;
            orgIdComboBoxWrapperObj.value = zsCloudId.Id;
            
            orgIdComboBoxWrapperList.add(orgIdComboBoxWrapperObj);
        }
        return orgIdComboBoxWrapperList;
    }
    
    @AuraEnabled
    public static List<ColumnsWrapper> getColumnDetails(String fieldSetName){
        List<ColumnsWrapper> columnsWrapperList = new List<ColumnsWrapper>();
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet(fieldSetName,'Technology_Partner_Usage__c');
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            system.debug('fieldSetMemberObj : ' + fieldSetMemberObj);
            system.debug('API Name : ' + fieldSetMemberObj.getFieldPath()); //api name
            system.debug('Label : ' + fieldSetMemberObj.getLabel());
            system.debug('Required : ' + fieldSetMemberObj.getRequired());
            system.debug('DbRequired : ' + fieldSetMemberObj.getDbRequired());
            system.debug('Type : ' + fieldSetMemberObj.getType());   //type - STRING,PICKLIST
            ColumnsWrapper columnsWrapperObj = new ColumnsWrapper();
            columnsWrapperObj.label = fieldSetMemberObj.getLabel();
            columnsWrapperObj.fieldName = fieldSetMemberObj.getFieldPath();
            columnsWrapperObj.type = String.valueOf(fieldSetMemberObj.getType());
            columnsWrapperList.add(columnsWrapperObj);
        }
        return columnsWrapperList;
    }
    
    @AuraEnabled
    public static List<Technology_Partner_Usage__c> getTechPartnerRecordsToDelete(String techPartnerUsageRecordString){
        System.debug('techPartnerUsageRecordString : ' + techPartnerUsageRecordString);
        Technology_Partner_Usage__c selectedTechPartnerUsageRecord = (Technology_Partner_Usage__c) 
            JSON.deserialize(techPartnerUsageRecordString, Technology_Partner_Usage__c.Class);
        System.debug('selectedTechPartnerUsageRecord : ' + selectedTechPartnerUsageRecord);
        List<Technology_Partner_Usage__c> techPartnerRecordsToDelete = new List<Technology_Partner_Usage__c>();
        techPartnerRecordsToDelete = [SELECT Id,
                                      Name,
                                      Account_Type__c, 
                                      Cloud_Name__c, 
                                      Company_Id__c, 
                                      Company_Name__c, 
                                      Customer_Account__c,
                                      Technology_Partner_Id__r.Name,
                                      Segment__c,
                                      Technology_Partner__c,
                                      Technology_Partner_Id__c,
                                      Usage_Type__c,
                                      Org_ID__c,
                                      Org_ID__r.Name,
                                      Is_Primary__c,
                                      External_Id__c,
                                      ExcludeFromIntegrationUpdate__c,
                                      Notes__c
                                      FROM Technology_Partner_Usage__c
                                      WHERE 
                                      Customer_Account__c = : selectedTechPartnerUsageRecord.Customer_Account__c AND
                                      Technology_Partner_Id__c = : selectedTechPartnerUsageRecord.Technology_Partner_Id__c  AND
                                      Usage_Type__c != 'Integration'
                                      Order By Technology_Partner_Id__r.Name, CreatedDate
                                      LIMIT 50000];
        System.debug('techPartnerRecordsToDelete : ' + techPartnerRecordsToDelete);
        return techPartnerRecordsToDelete;        
    }
    
    @AuraEnabled
    public static ErrorWrapper deleteTechPartnerUsageRecords(String techPartnerUsageRecords){
        System.debug('techPartnerUsageRecords : ' + techPartnerUsageRecords);
        String errorMsg = '';
        List<Technology_Partner_Usage__c> techPartnerUsageRecordsList = (List<Technology_Partner_Usage__c>) 
            JSON.deserialize(techPartnerUsageRecords, List<Technology_Partner_Usage__c>.Class); 
        System.debug('techPartnerUsageRecordsList : ' + techPartnerUsageRecordsList);
        ErrorWrapper errorWrapperObj = new ErrorWrapper();
        Database.DeleteResult[] drList = Database.delete(techPartnerUsageRecordsList, false);
        
        for(Database.DeleteResult dr : drList) {
            if (dr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted Technology_Partner_Usage__c with ID: ' + dr.getId());
                errorWrapperObj.status = 'Success';
                errorWrapperObj.message = 'Record deleted successfully';
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : dr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Technology_Partner_Usage__c fields that affected this error: ' + err.getFields());
                    errorMsg += err.getMessage() +  '\n' ;
                }
                errorWrapperObj.status = 'Error';
                errorWrapperObj.message = errorMsg;
            }
        }
        
        return errorWrapperObj;
    }
    
    @AuraEnabled
    public static string updateTechPartnerUsageRecords( Object data ) {
        
        List <Technology_Partner_Usage__c> techPartnerUsageForUpdate = (List <Technology_Partner_Usage__c>) JSON.deserialize(
            JSON.serialize(data),
            List <Technology_Partner_Usage__c>.class
        );
        try {
            update techPartnerUsageForUpdate;
            return 'Success: TechPartnerUsage(s) updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }

    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }

    public class ColumnsWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String type;
    }
    
    public class OrgIdComboBoxWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
    
    public class ErrorWrapper{
        @AuraEnabled public String status;
        @AuraEnabled public String message;
    }
}