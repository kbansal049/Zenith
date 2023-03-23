/*
*  Author : Ayush Kangar
*/
//Added by Ayush Kangar as part of IBA-4567 - Start
public class OpportunityPsOnboarding{
    @TestVisible
    private static Boolean throwTestError = false;
    public static void createPSOnboardingDoc(List<Opportunity> pSOnbordingOppSet){
        try{
            Map<Id,Id> OppIdPSQidMap = new Map<Id,Id>();
            Id PsOnboardingRecordTypeId = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(Label.PS_Onboarding).getRecordTypeId();
            List<PS_Questionnaire__c> PsqList = new List<PS_Questionnaire__c>();
            Map<Id, PS_Questionnaire__c> psqIdPsqMap = getPSQuestionnaireRecord(pSOnbordingOppSet,PsOnboardingRecordTypeId);
            for(PS_Questionnaire__c ps : psqIdPsqMap.values()){
                OppIdPSQidMap.put(ps.Opportunity__c,ps.Id);
            }
            for(Opportunity Opp : pSOnbordingOppSet){
                if(!OppIdPSQidMap.containsKey(Opp.Id)){
                    PS_Questionnaire__c psq = new PS_Questionnaire__c();
                    psq.account__c = opp.AccountId;
                    psq.Opportunity__c = opp.Id;
                    psq.Primary_Reseller_Partner__c = opp.Primary_Reseller_Partner__c;
                    psq.RecordTypeId = PsOnboardingRecordTypeId;    
                    PsqList.add(psq);
                }       		
            }
            if(!PsqList.isEmpty()){
                insert PsqList; 
            }
            if(throwTestError){		// Added for test class coverage of exception catch block
                throw new OpportunityPsOnboardingException('Test Exception');
            }
        }catch(Exception e){
            ZscalerErrorLogsUtility.insertlogs('OpportunityPsOnboarding', 'createPSOnboardingDoc', 'Apex', 
                                               UserInfo.getUserId(), 'Sales cloud', 
                                               e.getStackTraceString(),
                                               e.getMessage(), e.getTypeName());
        }
    }
    
    public static void updatePSOnboardingDoc(Map<Id,opportunity> oppIdOppMap){
        try{
            List<PS_Questionnaire__c> PsqListToUpdate = new List<PS_Questionnaire__c>();
            Id PsOnboardingRecordTypeId = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(Label.PS_Onboarding).getRecordTypeId();
            Map<Id, PS_Questionnaire__c> psqIdPsqMap = getPSQuestionnaireRecord(oppIdOppMap.values(),PsOnboardingRecordTypeId);
            for(PS_Questionnaire__c psq: psqIdPsqMap.values()){
                if(oppIdOppMap != null && psqIdPsqMap != null && psqIdPsqMap.get(psq.Id).opportunity__c!=null && oppIdOppMap.containsKey(psqIdPsqMap.get(psq.Id).opportunity__c)){
                    psq.Primary_Reseller_Partner__c = oppIdOppMap.get(psqIdPsqMap.get(psq.Id).opportunity__c).Primary_Reseller_Partner__c;
                    PsqListToUpdate.add(psq); 
                }                  
            }
            if(!PsqListToUpdate.isEmpty()){
                update PsqListToUpdate; 
            }
            if(throwTestError){		// Added for test class coverage of exception catch block
                throw new OpportunityPsOnboardingException('Test Exception');
            }
        }catch(Exception e){
            ZscalerErrorLogsUtility.insertlogs('OpportunityPsOnboarding', 'updatePSOnboardingDoc', 'Apex', 
                                               UserInfo.getUserId(), 'Sales cloud', 
                                               e.getStackTraceString(), 
                                               e.getMessage(), e.getTypeName());
        }
    }
    
    public static map<Id,PS_Questionnaire__c> getPSQuestionnaireRecord(List<opportunity> oppList,Id PsOnboardingRecordTypeId){
        Map<Id, PS_Questionnaire__c> psqIdPsqMap = new Map<Id,PS_Questionnaire__c>([select Id,Opportunity__c,account__c,Primary_Reseller_Partner__c from PS_Questionnaire__c where Opportunity__c in : oppList AND RecordTypeId =:PsOnboardingRecordTypeId]);
        return psqIdPsqMap;
    }
    
    public class OpportunityPsOnboardingException extends Exception {}
    //Added by Ayush Kangar as part of IBA-4567 - End
}