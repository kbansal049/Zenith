@IsTest
public class SecurityPolicyDataMappingService_Test {
    
    @IsTest
    static void notApplicablePolicyMappingTest(){
        
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.X3rd_TAM_Name__c = UserInfo.getUserId();
        insert acct;
        
        String notApplicableJsonData = '{"protocol_inspection": {"grade": "NOT_APPLICABLE","details": [{"name": "ALLOW_FTP","current_policy": "DISABLED"},{"name": "ALLOW_FTP_OVER_HTTP","current_policy": "DISABLED"}]},'
            +'"sandbox": {"grade": "NOT_APPLICABLE","details": null},'
            +'"ssl_inspection": {"grade": "NOT_APPLICABLE","details": [{"name": "UNTRUSTED_SSL_SERVER_CERTS","current_policy": "ALLOW_PASS_THROUGH"}, {"name": "REVOKED_SERVER_CERTIFICATE","current_policy": "ALLOWED" }]},'
            +'"inbound_outbound_traffic": {"grade": "NOT_APPLICABLE","details": null},'
            +'"malware": {"grade": "NOT_APPLICABLE","details": [{"name": "MALWARE_PROTECTION_FOR_PASSWORD_PROTECTED_FILES","current_policy": "ALLOWED" }]},'
            +'"advanced_threats": {"grade": "NOT_APPLICABLE","details": null},'
            +'"browser_control": {"grade": "NOT_APPLICABLE","details": [{"name": "CHECKS_AND_USER_NOTIFICATION","current_policy": "DISABLED"}, {"name": "OLDER_BROWSER","current_policy": "ALLOWED"}]},'
            +'"ssl_exceptions": {"grade": "NOT_APPLICABLE","details": null},'
            +'"security_exceptions": {"grade": "NOT_APPLICABLE","details": null}}';
      
        Test.startTest();
        
        Zscaler_Cloud_ID__c ci = new Zscaler_Cloud_ID__c(Account__c = acct.id,Cloud_Type__c = 'ZIA');
        insert ci;
        BWC_Data__c mountlyCloudObj = new BWC_Data__c();        
        mountlyCloudObj.Cloud_ID__c= ci.Id;
        mountlyCloudObj.Total_Unique_Users__c = 101;
        mountlyCloudObj.Type__c = 'ZIA';
        mountlyCloudObj.Security_Policy_Data__c = notApplicableJsonData;
        mountlyCloudObj.Monthly_Usage__c = Date.today();
        insert mountlyCloudObj;
        
        
        SecurityPolicyDataMappingService batchClassObj = new SecurityPolicyDataMappingService();
        Database.executeBatch(batchClassObj);
     
        
        Test.stopTest();
    }
    @IsTest
    static void applicablePolicyMappingTest(){
        
        Account acct = new Account();
        acct.name = 'Test Account';
        acct.Type = 'Customer';
        acct.RecordTypeId = '01270000000EAFsAAO';
        acct.X3rd_TAM_Name__c = UserInfo.getUserId();
        insert acct;
      
        
        String applicableJsonData = '{"protocol_inspection": {"grade": "A","details": [{"name": "ALLOW_FTP","current_policy": "DISABLED"},{"name": "ALLOW_FTP_OVER_HTTP","current_policy": "DISABLED"}]},'
            +'"sandbox": {"grade": "B","details": null},'
            +'"ssl_inspection": {"grade": "C","details": [{"name": "UNTRUSTED_SSL_SERVER_CERTS","current_policy": "ALLOW_PASS_THROUGH"}, {"name": "REVOKED_SERVER_CERTIFICATE","current_policy": "ALLOWED" }]},'
            +'"inbound_outbound_traffic": {"grade": "A","details": null},'
            +'"malware": {"grade": "B","details": [{"name": "MALWARE_PROTECTION_FOR_PASSWORD_PROTECTED_FILES","current_policy": "ALLOWED" }]},'
            +'"advanced_threats": {"grade": "C","details": null},'
            +'"browser_control": {"grade": "A","details": [{"name": "CHECKS_AND_USER_NOTIFICATION","current_policy": "DISABLED"}, {"name": "OLDER_BROWSER","current_policy": "ALLOWED"}]},'
            +'"ssl_exceptions": {"grade": "B","details": null},'
            +'"security_exceptions": {"grade": "C","details": null}}';
        
        Test.startTest();
        Zscaler_Cloud_ID__c ci = new Zscaler_Cloud_ID__c(Account__c = acct.id,Cloud_Type__c = 'ZIA');
        insert ci;
        BWC_Data__c mountlyCloudObj = new BWC_Data__c();        
        mountlyCloudObj.Cloud_ID__c= ci.Id;
        mountlyCloudObj.Total_Unique_Users__c = 101;
        mountlyCloudObj.Type__c = 'ZIA';
        mountlyCloudObj.Security_Policy_Data__c = applicableJsonData;
        mountlyCloudObj.Monthly_Usage__c = Date.today();
        insert mountlyCloudObj;
        
        SecurityPolicyDataMappingService batchClassObj = new SecurityPolicyDataMappingService();
        Database.executeBatch(batchClassObj);
        
        Test.stopTest();
    }
    
    
}