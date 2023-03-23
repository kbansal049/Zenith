public class TechPartnerUsageListViewController {
    
    @AuraEnabled
    public static ListViewWrapper getTechPartnerUsageRecordsForDataTable(Integer offSetCount, String techPartnerId) {
        
        ListViewWrapper listViewWrapperObj = new ListViewWrapper();
        listViewWrapperObj.totalRecords = [SELECT count() 
                                           FROM Technology_Partner_Usage__c 
                                           WHERE Technology_Partner_Id__c = : techPartnerId];
        listViewWrapperObj.totalSolutionRecords = [SELECT count() 
                                           FROM Technology_Partner_Usage__c 
                                           WHERE Technology_Partner_Id__c = : techPartnerId AND
                                                  Usage_Type__c = 'Solution'];
        listViewWrapperObj.totalIntegrationRecords = [SELECT count() 
                                           FROM Technology_Partner_Usage__c 
                                           WHERE Technology_Partner_Id__c = : techPartnerId AND
                                                     Usage_Type__c = 'Integration'];
        listViewWrapperObj.techPartnerUsageList =  [SELECT Id,
                                                    Name,
                                                    Account_Type__c, 
                                                    Cloud_Name__c, 
                                                    Company_Id__c, 
                                                    Company_Name__c, 
                                                    Customer_Account__c,
                                                    Customer_Account__r.Name,
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
                                                    WHERE Technology_Partner_Id__c = : techPartnerId
                                                    Order By Customer_Account__r.Name
                                                    LIMIT 20 
                                                    OFFSET :offSetCount];
        
        return listViewWrapperObj;
    }
    
    public class ListViewWrapper{
        @AuraEnabled
        public Integer totalRecords = 0;
        @AuraEnabled
        public Integer totalSolutionRecords = 0;
        @AuraEnabled
        public Integer totalIntegrationRecords = 0;
        @AuraEnabled
        public List<Technology_Partner_Usage__c> techPartnerUsageList = new List<Technology_Partner_Usage__c>();
    }
}