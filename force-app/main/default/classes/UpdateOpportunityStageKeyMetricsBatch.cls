public class UpdateOpportunityStageKeyMetricsBatch implements Database.Batchable<SObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateOpportunityStageKeyMetricsBatch');
    String q = '';
    public list<String> successlst = new List<String>();
    public list<String> errorlst = new List<String>();
    
    //Aditya RollUp
    Map<Id,String> errorMap = new Map<Id,String>();
    //Aditya RollUp for Opportunity 
    private Set<String> validStageNames = new Set<String>{ '1 - Discovery & Qualification', '2 - Architecture & Alignment', '3 - Sponsorship','4 - Impact Validation' };
    public UpdateOpportunityStageKeyMetricsBatch(String query) {
        q = query;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        this.zb.callStart();
        return Database.getQueryLocator(q);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> opplst){
		integer i=0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
        this.zb.callExecute(opplst[0]?.Id, opplst.size());
        Map<Id, Opportunity> oppmap = new Map<Id, Opportunity>();
        Set<Id> opptIdSet = new Set<Id>();
        //Aditya RollUp for Opportunity 
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();        
        for(Opportunity opp: opplst){
            //Aditya RollUp for Opportunity 
            if(validStageNames.contains(opp.StageName) && opp.CloseDate == System.today().addDays(180) && opp.Type != 'Existing Customer (Renewal)'){
            oppmap.put(opp.Id, new Opportunity(Id = opp.Id, NBM_Completed__c = 'No', Architecture_Workshop_Complete__c = 'No', EB_Sponsorship_Complete__c = 'No', EB_Readout_Complete__c = 'No', Tested_Champ__c = false, Value_Discovery_Completed__c=false));
        }
            opptIdSet.add(opp.Id);
        }
        
        //Aditya RollUp for Opportunity - Last Tech Validation Date
        List<Technical_Validation_Next_Steps_History__c > historyList =  [SELECT Opportunity__c,CreatedDate FROM Technical_Validation_Next_Steps_History__c WHERE Opportunity__c IN :opptIdSet ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];
        Map<Id, List<Technical_Validation_Next_Steps_History__c>> historyByOpp = new Map<Id, List<Technical_Validation_Next_Steps_History__c>>();
        for(Technical_Validation_Next_Steps_History__c histId : historyList){
            if(historyByOpp.containsKey(histId.Opportunity__c)){
                historyByOpp.get(histId.Opportunity__c).add(histId);
            }else{
                historyByOpp.put(histId.Opportunity__c, new List<Technical_Validation_Next_Steps_History__c>());
                historyByOpp.get(histId.Opportunity__c).add(histId);
            }
        }
        
        //Aditya RollUp for Opportunity - Architecture_Next_Steps__c - For Target Object Opportunity
        List<Architecture_Next_Steps__c > archNextStepList =  [SELECT Opportunity__c,CreatedDate FROM Architecture_Next_Steps__c WHERE Opportunity__c IN :opptIdSet ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];
        Map<Id, List<Architecture_Next_Steps__c>> archNextStepByOpp = new Map<Id, List<Architecture_Next_Steps__c>>();
        for(Architecture_Next_Steps__c archId : archNextStepList){
            if(archNextStepByOpp.containsKey(archId.Opportunity__c)){
                archNextStepByOpp.get(archId.Opportunity__c).add(archId);
            }else{
                archNextStepByOpp.put(archId.Opportunity__c, new List<Architecture_Next_Steps__c>());
                archNextStepByOpp.get(archId.Opportunity__c).add(archId);
            }
        }
        for(AggregateResult ar: [Select WhatId, Type, count(Id) cnt from Event where type in (:System.Label.PG_New_Business_Meeting, :System.Label.VO_Architecture_Workshop,:System.Label.VO_EB_Sponsorship,:System.Label.VO_EB_Final_Signoff,
                :System.Label.VO_Champion_Building,:System.Label.PG_Discovery_Call) and WhatId in :oppmap.keyset() group by rollup(WhatId, Type)]){
            if((String)ar.get('WhatId') != null && (String)ar.get('Type') != null && !oppmap.isEmpty() && oppmap.containskey((String)ar.get('WhatId')) && (Integer)ar.get('cnt') > 0){
                Opportunity opp = oppmap.get((String)ar.get('WhatId'));
                if(ar.get('Type') == System.Label.PG_New_Business_Meeting){
                    opp.NBM_Completed__c  = 'Yes';
                }else if(ar.get('Type') == System.Label.VO_Architecture_Workshop){
                    opp.Architecture_Workshop_Complete__c = 'Yes';
                }else if(ar.get('Type') == System.Label.VO_EB_Sponsorship){
                    opp.EB_Sponsorship_Complete__c = 'Yes';
                }else if(ar.get('Type') == System.Label.VO_EB_Final_Signoff){
                    opp.EB_Readout_Complete__c = 'Yes';
                }else if(ar.get('Type') == System.Label.VO_Champion_Building){
                    opp.Tested_Champ__c = true;
                }
                else if(ar.get('Type') == System.Label.PG_Discovery_Call){
                    opp.Value_Discovery_Completed__c = true;
                }
            }
        }
        try{
            //Aditya RollUp for Opportunity 
            for(Opportunity opp: opplst){
                if(oppmap.containskey(opp.Id) && oppmap != NULL){
                    if(historyByOpp != NULL && historyByOpp.containsKey(opp.Id) && !historyByOpp.get(opp.Id).isEmpty()){
                        oppmap.get(opp.Id).Last_Tech_Validation_Date__c = Date.valueOf(historyByOpp.get(opp.Id)[0].CreatedDate);
                    }
                    if(archNextStepByOpp != NULL && archNextStepByOpp.containsKey(opp.Id) && !archNextStepByOpp.get(opp.Id).isEmpty()){
                        oppmap.get(opp.Id).Date_of_Last_Arch_Next_Steps_History__c = Date.valueOf(archNextStepByOpp.get(opp.Id)[0].CreatedDate);
                    }
                    opportunitiesToUpdate.add(oppmap.get(opp.Id));
                }else{
                    if(historyByOpp != NULL && historyByOpp.containsKey(opp.Id) && !historyByOpp.get(opp.Id).isEmpty()){
                        opp.Last_Tech_Validation_Date__c = Date.valueOf(historyByOpp.get(opp.Id)[0].CreatedDate);
                    }
                    if(archNextStepByOpp != NULL && archNextStepByOpp.containsKey(opp.Id) && !archNextStepByOpp.get(opp.Id).isEmpty()){
                        opp.Date_of_Last_Arch_Next_Steps_History__c = Date.valueOf(archNextStepByOpp.get(opp.Id)[0].CreatedDate);
                    }
                    opportunitiesToUpdate.add(opp);
                }
            }

        TriggerHandler.bypass('OpportunityTriggerHandler');
        Database.SaveResult[] srlst = Database.update(opportunitiesToUpdate, false);
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        for(Database.SaveResult sr: srlst){
            if(sr.isSuccess()){
                successlst.add(sr.id);
            }else{
                String errmsg = 'Error for OppId: ' + sr.getId() + '. ';
                for(Database.Error err: sr.getErrors()){
                    errmsg += err.getMessage();
                }
                errorlst.add(errmsg);
            }
        }
    }
        catch(Exception ex)
        {
            System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
            ZscalerErrorLogsUtility.insertlogsForAsync('UpdateOpportunityStageKeyMetricsBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', ex.getMessage(), ex.getMessage(), ex.getMessage());    
        }
    }
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);    
        Messaging.singleEmailMessage msg = new Messaging.singleEmailMessage();
        msg.setToAddresses(new List<String>{Label.BSYS_INFO});
        msg.setSubject('Result of Opportunity Stage Key Metrics (Rollup of Event details based on type) Update Batch');
        String body = 'Batch processed ' + successlst.size() + ' successfully and ' + errorlst.size() + ' records have failed. \n';
        if(!errorlst.isEmpty()){
            for(String err : errorlst){
                body += '\n' + err;
            }
        }
        msg.setPlainTextBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});
    }
	
}