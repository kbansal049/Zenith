public with sharing class OppCompetitorFieldUpdateBatchController implements Database.Batchable<SObject>,  Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('OppCompetitorFieldUpdateBatchController');
    private String query;
    
    public OppCompetitorFieldUpdateBatchController(String query) {
        this.query = query;
    }

    //CR# 4783 START
    public Database.QueryLocator start(Database.BatchableContext bc) {
        this.zscalerBatchFrameWorkObj.callStart();
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> oppList) {
        this.zscalerBatchFrameWorkObj.callExecute(oppList[0]?.Id, oppList.size());
        try {
        	String TEXT_OTHER = 'Other';
            String TEXT_NONE = 'None';
            List<Opportunity> oppsToUpdateList = new List<Opportunity>();
            List<String> primaryCompetitorPicklistValuesList = getPicklistValuesUpperCase(Opportunity.Primary_Competitor__c);
            for (Opportunity currentOpp : oppList) {
                //Mutliple Selection in Competitor__c
                if (currentOpp.Competitor__c.contains(';')) {
                    currentOpp.Secondary_Competitors__c = 'Others';
                    String otherSecondaryCompetitors = currentOpp.Competitor__c.endsWith(TEXT_OTHER) ? 
                        currentOpp.Competitor__c.removeEnd(TEXT_OTHER) + currentOpp.Other_Competitors__c : currentOpp.Competitor__c;
                    //Relacing all the special characters with space " " except "," 
                    currentOpp.Other_Secondary_competitor__c = String.join(otherSecondaryCompetitors.split(';'), ',').replaceAll('([^\\w,]|[_])', ' ');
                    currentOpp.Primary_Competitor__c = TEXT_NONE;
                } else {
                    //Single Selection in Competitor__c
                    if (!TEXT_OTHER.equalsIgnoreCase(currentOpp.Competitor__c)) {
                        if (primaryCompetitorPicklistValuesList.contains(currentOpp.Competitor__c.toUpperCase())) {
                            currentOpp.Primary_Competitor__c = currentOpp.Competitor__c;
                            currentOpp.Other_Primary_competitor__c = currentOpp.Other_Competitors__c != null ? currentOpp.Other_Competitors__c.replaceAll('([^\\w]|[_])', ' ') : null;
                        } else {
                            currentOpp.Primary_Competitor__c = TEXT_OTHER;
                            // Replacing any special characters with space " "
                            currentOpp.Other_Primary_competitor__c = currentOpp.Competitor__c.replaceAll('([^\\w]|[_])', ' ');
                        }
                    } else {
                        currentOpp.Primary_Competitor__c = currentOpp.Competitor__c;
                        // Replacing any special characters with space " "
                        currentOpp.Other_Primary_Competitor__c = currentOpp.Other_Competitors__c.replaceAll('([^\\w]|[_])', ' ');
                    }
                    currentOpp.Secondary_Competitors__c = TEXT_NONE;
                }
                oppsToUpdateList.add(currentOpp);
            }
    		
            if (!oppsToUpdateList.isEmpty()) {
                TriggerHandler.bypass('OpportunityTriggerHandler');
                Database.SaveResult[] savedResulsList = Database.update(oppsToUpdateList, false);
                Id userId = UserInfo.getUserId();
                List<Zscaler_Error_Logs__c> zscalerErrorLogsList = new List<Zscaler_Error_Logs__c>();
                for (Database.SaveResult savedResult : savedResulsList) {
                    if (!savedResult.isSuccess()) {
                        for (Database.Error error : savedResult.getErrors()) {
                            zscalerErrorLogsList.add(prepareLogsForAsync('execute', userId, 'Stack Trace Not Available', error.getMessage(), 'Type Not available'));
                        }
                    }
                }
                if (!zscalerErrorLogsList.isEmpty()) {
					insert zscalerErrorLogsList;
                }
            }    
        } catch (Exception e) {
            ZscalerErrorLogsUtility.insertlogsForAsync('OppCompetitorFieldUpdateBatchController', 'execute', 'Async Apex', UserInfo.getUserId(),
                                                'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
            throw e;
        }
    }

    public void finish(Database.BatchableContext bc) {
       this.zscalerBatchFrameWorkObj.callFinish(bc);
    } 
    
    @TestVisible
    private Zscaler_Error_Logs__c prepareLogsForAsync(String methodName, String UserId, 
                                           	String stackTraceString, String info, String errorType){
        Zscaler_Error_Logs__c errorLog = new Zscaler_Error_Logs__c(
            Class_Name__c = 'OppCompetitorFieldUpdateBatchController',
            Method_Name__c = methodName, 
            Error_in__c = 'Async Apex', 
            User__c	= UserId,
            Biz_Area__c	= 'Sales cloud',
            Stack_Trace_String__c = stackTraceString,
            Exception_info__c = info,
            Error_Type__c = errorType
        );
        return errorLog;
    }

    private List<String> getPicklistValuesUpperCase(Schema.SObjectField field) {
        List<String> picklistValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = field.getDescribe();
		List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
		for(Schema.PicklistEntry picklistEntry : picklistEntries){
            if (picklistEntry.isActive()) {
                pickListValuesList.add(picklistEntry.getValue());
            }
		}
        for (Integer index = 0; index < picklistValuesList.size(); index++) {
            picklistValuesList[index] = picklistValuesList[index].toUpperCase();
        }
		return picklistValuesList; 
    }
    

    /*
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryString = 'Select ID,toLabel(Competitors__c),toLabel(ZPA_Competitor__c),Competitor__c from Opportunity where (Competitors__c!=Null OR ZPA_Competitor__c!=Null)';
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> OppList) {
        Set<String> Competitor = new Set<String>();
        Set<String> CompSet = new Set<String>();
        Set<String> OtherCompSet = new Set<String>();
        List<Opportunity> oppListToUpdate = New List<Opportunity>();
        Schema.DescribeFieldResult objFieldDescribe = Opportunity.Competitor__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            Competitor.add(objPickList.getLabel());
        }
        for(Opportunity Opp : OppList){
            opp.Competitor__c = '';
            //opp.Other_Competitors__c= '';
            if(opp.Competitors__c != Null){
                List<String> ZIAcompetitorList = new List<String>();
                ZIAcompetitorList = opp.Competitors__c.split(';');
                for(String compOpp : ZIAcompetitorList){
                    if(Competitor.contains(compOpp)){
                        CompSet.add(compOpp);
                    }
                    else{
                        CompSet.add('Other');
                        OtherCompSet.add(compOpp);
                    }  
                }
            }
            if(opp.ZPA_Competitor__c != Null){
                List<String> ZPAcompetitorList = new List<String>();
                ZPAcompetitorList = opp.ZPA_Competitor__c.split(';');
                for(String compOpp : ZPAcompetitorList){
                    if(Competitor.contains(compOpp)){
                        CompSet.add(compOpp);
                    }
                    else{
                        CompSet.add('Other');
                        OtherCompSet.add(compOpp);
                    }  
                }
            }
            opp.Competitor__c = String.join(new List<String>(CompSet), ';');
            //opp.Other_Competitors__c= String.join(new List<String>(OtherCompSet), ';');
            system.debug('### opp.Competitor__c :'+opp.Competitor__c);
            //system.debug('### opp.Other_Competitors__c :'+opp.Other_Competitors__c);
            oppListToUpdate.add(opp);
        }
        if(!oppListToUpdate.isEmpty()){
            update oppListToUpdate;
        }
        
    }
    
    public void finish(Database.BatchableContext bc) {}
    */
    //CR# 4783 END
}