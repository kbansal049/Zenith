//Added by Ayush Kangar as part of IBA-5065 - START
public without sharing class PSQuestionnaireQuickActionController{

    //This method is used in psQuestionnaireQuickActionComponent to check th record type
    //of PS Questionnaire.
    @AuraEnabled
    public static string getRecordTypeId(String recordId){
        List<PS_Questionnaire__c> psqList = [SELECT Id, RecordtypeId, RecordType.DeveloperName
                                            FROM PS_Questionnaire__c 
                                            WHERE Id =: recordId 
                                            AND RecordType.DeveloperName =:Label.PS_Onboarding];
        if(!psqList.isEmpty()){
            return psqList[0].RecordtypeId;
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static Id getPSOnboardingRecordTypeId(){
        Id PsOnboardingRecordTypeId = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(Label.PS_Onboarding).getRecordTypeId();
        return PsOnboardingRecordTypeId;
    }
}
//Added by Ayush Kangar as part of IBA-5065 - END