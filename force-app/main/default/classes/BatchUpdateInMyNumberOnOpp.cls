global class BatchUpdateInMyNumberOnOpp implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
    
    ZscalerBatchFramework zb = new ZscalerBatchFramework('BatchUpdateInMyNumberOnOpp');
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        String query;
        
        if(Test.isRunningTest()){
            query ='SELECT ID,CloseDate,Type,Forecast_Category__c,Renewal_Rep_Forecast_Category__c,RD_In_my_Number__c,RVP_In_my_Number__c,AVP_In_my_Number__c,Geo_VP_In_my_Number__c,Renewal_RD_In_my_Number__c ,Renewal_RVP_In_my_Number__c,Renewal_VP_In_my_Number__c FROM Opportunity  LIMIT 100';
                }
        else{
            query ='SELECT ID,CloseDate,Type,Forecast_Category__c,Renewal_Rep_Forecast_Category__c,RD_In_my_Number__c,RVP_In_my_Number__c,AVP_In_my_Number__c,Geo_VP_In_my_Number__c,Renewal_RD_In_my_Number__c ,Renewal_RVP_In_my_Number__c,Renewal_VP_In_my_Number__c FROM Opportunity where (Forecast_Category__c=\'Commit\' OR Renewal_Rep_Forecast_Category__c=\'Commit\') AND CloseDate =THIS_FISCAL_QUARTER  ANd Type IN (\'New Business\' ,\'Existing Customer (Renewal)\',\'Existing Customer (Add On)\') ';
                }
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> records){
        
        this.zb.callExecute(records[0]?.Id, records.size());
        
        // Commented as a part of CR# 376:  Gurjinder: Start
        /* List<Opportunity> UpdateOpportunityList = New list<Opportunity>();
		boolean Ischanged = false;
        for(opportunity opp :records){
			
			if((opp.type=='New Business' || opp.type=='Existing Customer (Renewal)' || opp.type=='Existing Customer (Add On)' ) && opp.Forecast_Category__c=='Commit')
			{
				    opp.RD_In_my_Number__c = true;
                    opp.RVP_In_my_Number__c = true;
                   
                    opp.AVP_In_my_Number__c = true;
                    opp.Geo_VP_In_my_Number__c = true;
					Ischanged=true;
					//UpdateOpportunityList.add(opp);
			}
			
			if(opp.type =='Existing Customer (Renewal)' && opp.Renewal_Rep_Forecast_Category__c=='Commit')
			{
                    opp.Renewal_RD_In_my_Number__c = true;
                    opp.Renewal_RVP_In_my_Number__c = true;
                    opp.Renewal_VP_In_my_Number__c = true;
					Ischanged=true;
					//UpdateOpportunityList.add(opp);
			}
			
			if(ischanged)
			{
			UpdateOpportunityList.add(opp);
			}
			
		}
        
               
       
        if(!UpdateOpportunityList.isempty()){
            update UpdateOpportunityList;
         //   database.update(UpdateOpportunityList, false);
		}  */
		// Commented as a part of CR# 376:  Gurjinder: Start
        
    }    
    
    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        
    }  
    global void execute(SchedulableContext sc) {
        /* BatchUpdateInMyNumberOnOpp b = new BatchUpdateInMyNumberOnOpp(); 
        database.executebatch(b,200); */
    }
}