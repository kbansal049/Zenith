//Helper Class for checking public domain emails for Partner Owned Deployment record type survey
 
public class PublicDomainCheckHelper {
	private static final Id partnerOwnedDPRecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('Partner_Owned_Deployment_Project').getRecordTypeId();
    private static List<String> domainsToExcludeList = CaseTriggerUtility.fetchDomainsToExclude();
   
    public static void publicDomainCheck(List<Survey__c> newSurveysList)
    {
        for(Survey__c surveyRecord : newSurveysList)
        {
            if(surveyRecord.recordTypeId == partnerOwnedDPRecordTypeId && surveyRecord.Customer_Email__c != NULL){
                 setSurveyStatusForPublicDomain(surveyRecord,surveyRecord.Customer_Email__c,domainsToExcludeList);
            }
         }
    }
    
    //Method overload for beforeupdate context
    public static void publicDomainCheck(List<Survey__c> newSurveysList, Map<Id,Survey__c> mapOldSurveys)
    {	
        for(Survey__c surveyRecord : newSurveysList)
        {
            if(surveyRecord.Customer_Email__c != mapOldSurveys.get(surveyRecord.Id).Customer_Email__c){
               if(surveyRecord.recordTypeId == partnerOwnedDPRecordTypeId && surveyRecord.Customer_Email__c != NULL){
                 setSurveyStatusForPublicDomain(surveyRecord,surveyRecord.Customer_Email__c,domainsToExcludeList);
            	} 
            }
            
         }
    }
    
    //Setting checkbox and survey status field for public domain emails
    public static void setSurveyStatusForPublicDomain(Survey__c surveyRecord, String currEmail, List<String> domainsToExcludeList)
    {
        if(CaseTriggerUtility.checkEmailDomainsExclude(currEmail, domainsToExcludeList)){
               surveyRecord.Contact_Email_Includes_Public_Domain__c = true;
               surveyRecord.Survey_Status__c='Survey not Sent due to Public Domain';
           }
    }
}