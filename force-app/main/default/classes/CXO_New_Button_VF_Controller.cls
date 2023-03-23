public with sharing class CXO_New_Button_VF_Controller {
    Map<String,string> urlparams;
    public String accId{get; set;}
    public String recordTypeName{get; set;}
    public String recId{get; set;}
    public String recordTypeDeveloperName{get; set;}
    public CXO_New_Button_VF_Controller(ApexPages.StandardController controller) {
        urlparams = ApexPages.currentPage().getParameters();
        accId = urlparams.get('CF00N0g000003hyhv_lkid');
        recId = urlparams.get('RecordType');
        recordTypeName = Schema.SObjectType.CXO_Advisor_Request__c.getRecordTypeInfosById().get(recId).getName();
        recordTypeDeveloperName = Schema.SObjectType.CXO_Advisor_Request__c.getRecordTypeInfosById().get(recId).getDeveloperName();
        system.debug('accId'+accId);
        system.debug('recId'+recId);
        system.debug('recordTypeName'+recordTypeName);
        system.debug('recordTypeDeveloperName: '+recordTypeDeveloperName);
    }
}