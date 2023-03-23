global class CaseRollUpBatch implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
    //Aditya Rollup
	ZscalerBatchFramework zb = new ZscalerBatchFramework('CaseRollUpBatch');
    Map<Id,String> errorMap = new Map<Id,String>();
    private id caseId;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Aditya Rollup
		this.zb.callStart();
        String query;
        query ='SELECT Id FROM Case';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case> caseList){
        //Aditya Rollup
        this.zb.callExecute(caseList[0]?.Id, caseList.size());
        List<Case> caseUpdateList = new List<Case>();                                            
        Set<Id> caseIdSet = new Set<Id>();                                
        for(Case cs : caseList){
            caseIdSet.add(cs.Id);
        }

        //Aditya RollUp for Case - CountofLegacyCaseComments - For Target Object Case
        List<Legacy_Case_Comment__c> legacyCaseList =  [SELECT Cases__c,isDeleted FROM Legacy_Case_Comment__c WHERE Cases__c IN :caseIdSet And isDeleted = False ];
        Map<Id, List<Legacy_Case_Comment__c>> legacyByCase = new Map<Id, List<Legacy_Case_Comment__c>>();
        for(Legacy_Case_Comment__c legacyId : legacyCaseList){
            if(legacyByCase.containsKey(legacyId.Cases__c)){
                legacyByCase.get(legacyId.Cases__c).add(legacyId);
            }else{
                legacyByCase.put(legacyId.Cases__c, new List<Legacy_Case_Comment__c>());
                legacyByCase.get(legacyId.Cases__c).add(legacyId);
            }
        }
        //Aditya RollUp for Case - Survey__c  - For Target Object Case
        List<Survey__c> surveyList =  [SELECT Case__c,Promoter_Count__c,CES_Score_Numeric__c,CSAT_Score_Numeric__c,Detractor_Count__c,isDeleted,survey_response_received__c,case__r.recordtype.name,case__r.origin FROM Survey__c WHERE Case__c IN :caseIdSet And isDeleted = False];
        Map<Id, List<Survey__c>> surveyByCase = new Map<Id, List<Survey__c>>();
        for(Survey__c surveyId : surveyList){
            if(surveyByCase.containsKey(surveyId.Case__c)){     
                surveyByCase.get(surveyId.Case__c).add(surveyId);
            }else{
                surveyByCase.put(surveyId.Case__c, new List<Survey__c>());
                surveyByCase.get(surveyId.Case__c).add(surveyId);
            }
        }
        
        //Aditya Rollup
        try{
            for(id caseId: caseIdSet){
                Case cs = new Case();
                cs.Id = caseId;
                //Aditya RollUp for Case - CountofLegacyCaseComments
                if(legacyByCase != NULL && legacyByCase.containsKey(caseId)){
                    cs.Number_of_comment__c = (legacyByCase.get(caseId)).size();
                }else{
                    cs.Number_of_comment__c = 0;
                }
                
                Double npsDetractorCount = 0;
                Double npsPromoterCount = 0;
                Double cesScore = 0;
                Double csatScore = 0;
                if(surveyByCase != NULL && surveyByCase.containsKey(caseId)){
                    for(Survey__c surv : surveyByCase.get(caseId)){
                        //Aditya RollUp for Case - Survey__c Survey_Sent_Count__c , Survey__c Survey_Filled_Count__c
                        cs.Survey_Sent_Count__c = (surveyByCase.get(caseId)).size();
                        if(surv.survey_response_received__c = TRUE && surv.case__r.recordtype.name == 'Support' && surv.case__r.origin != 'Legacy'){
                            cs.Survey_Filled_Count__c = (surveyByCase.get(caseId)).size();
                            
                            //Aditya RollUp for Case - Survey__c Survey_NPS_Detractor_Count__c
                            if(surv.Detractor_Count__c != NULL){
                                npsDetractorCount = npsDetractorCount + surv.Detractor_Count__c;    
                            }
                            
                            //Aditya RollUp for Case - Survey__c Survey_NPS_Promoter_Count__c
                            if(surv.Promoter_Count__c != NULL){
                                npsPromoterCount = npsPromoterCount + surv.Promoter_Count__c;    
                            }
                            
                            //Aditya RollUp for Case - Survey__c Survey_CES_Score__c
                            if(surv.CES_Score_Numeric__c != NULL){
                                cesScore = cesScore + surv.CES_Score_Numeric__c;
                            }
                            
                            //Aditya RollUp for Case - Survey__c Survey_CSAT_Score__c
                            if(surv.CSAT_Score_Numeric__c != NULL){
                                csatScore = csatScore + surv.CSAT_Score_Numeric__c;
                            }   
                        } 
                    }
                }  
                cs.Survey_NPS_Detractor_Count__c = npsDetractorCount;
                cs.Survey_NPS_Promoter_Count__c = npsPromoterCount;
                if(surveyByCase.containsKey(caseId)){
                    cs.Survey_CES_Score__c = cesScore/(surveyByCase.get(caseId)).size();
                    cs.Survey_CSAT_Score__c = csatScore/(surveyByCase.get(caseId)).size();
                }
                caseUpdateList.add(cs);
            }
            if(!caseUpdateList.isEmpty()){
                Database.update(caseUpdateList);
            }
        }
        catch(Exception ex)
        {
            System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
            errorMap.put(caseId,ex.getMessage() + ' at Line No. ' + ex.getLineNumber());     
            if(!Test.isRunningTest()){
				ZscalerErrorLogsUtility.insertlogsForAsync('caseRollUpBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', ex.getMessage(), ex.getMessage(), ex.getMessage());    
            }
        }
    }    
    
    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
    }  
    global void execute(SchedulableContext sc) {
        CaseRollUpBatch b = new CaseRollUpBatch (); 
        Database.executebatch(b,200);
    }
}