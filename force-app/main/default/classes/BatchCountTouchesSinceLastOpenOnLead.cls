global class BatchCountTouchesSinceLastOpenOnLead implements Database.Batchable<sObject>,Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('BatchCountTouchesSinceLastOpenOnLead');

    global Database.QueryLocator start(Database.BatchableContext bc) {
        this.zb.callStart();
        String query;
        
        if(Test.isRunningTest()){
            query ='SELECT ID,Status, last_opened_Date__c,Touches_Since_Last_Open__c FROM LEAD where Isconverted=False LIMIT 10';
        }
        else{
            query ='SELECT ID,Status, last_opened_Date__c,Touches_Since_Last_Open__c FROM LEAD where Last_Opened_Date__c!=null AND Isconverted=False';
        }
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Lead> records){
        this.zb.callExecute(records[0]?.Id, records.size());
        
        List<Lead> Leadlist = (list<lead>) records;
        Map<String,Date> MapLeadLastOpenedDate = new Map<String,Date>();
        Set<Id> lead_idlist = new Set<Id>();
        Map<String,Integer> LeadClosedTaskcntMap= new Map<string,Integer>();
        List<Lead> UpdateLeadStatusList = New list<Lead>();
        Map<String,Integer> LeadClosedEventcntMap= new Map<string,Integer>();
        
        
        for(Integer i=0;i<Leadlist.size();i++){
            lead_idlist.add(Leadlist[i].ID);
            
        }
        for(lead l: records){
            MapLeadLastOpenedDate.put(l.ID,l.last_opened_Date__c);
            
        }
        
        for(Task t : [SELECT ID,WHOID,Activitydate,LastModifiedDate FROM TASK  WHERE WHOID!='' AND whatID='' AND AccountID='' AND ISCLOSED=TRUE AND WHOID IN :lead_idlist]){// Modified for CR 1113 - Varun
            
            if(t.Activitydate>=MapLeadLastOpenedDate.get(t.WhoId)){// Modified for CR 1113 - Varun
                if(LeadClosedTaskcntMap.containsKey(t.whoID)){
                    LeadClosedTaskcntMap.put(t.whoid,LeadClosedTaskcntMap.get(t.whoID)+1);
                }
                else{
                    LeadClosedTaskcntMap.put(t.whoid,1);
                }
                
            }
        }
        
        for(Event e : [SELECT ID,WHOID,Activitydate,Activitydatetime,startdatetime,enddatetime FROM Event  WHERE WHOID!='' AND whatID=''  AND AccountID=''AND ActivityDATE!=null AND enddatetime!=null AND WHOID IN :lead_idlist ]){
            
            if(e.ActivityDate>=MapLeadLastOpenedDate.get(e.WhoId) && e.enddatetime<=System.now()){
                if(LeadClosedEventcntMap.containsKey(e.whoID) ){
                    LeadClosedEventcntMap.put(e.whoid,LeadClosedEventcntMap.get(e.whoID)+1);
                }
                else{
                    LeadClosedEventcntMap.put(e.whoid,1);
                }
            }
            
        }
        
        for (Lead ar : records)  {
            if(ar.last_opened_Date__c!=null && (LeadClosedTaskcntMap.containsKey(ar.id) || LeadClosedEventcntMap.containsKey(ar.id))){
                
                if(LeadClosedTaskcntMap.containsKey(ar.id) && LeadClosedEventcntMap.containsKey(ar.id) && ar.Touches_Since_Last_Open__c!=(LeadClosedTaskcntMap.get(ar.Id)+LeadClosedEventcntMap.get(ar.id)))
                {
                    ar.Touches_Since_Last_Open__c=LeadClosedTaskcntMap.get(ar.Id) + LeadClosedEventcntMap.get(ar.id);
                    
                    UpdateLeadStatusList.add(ar);
                }
                
            }
            
            if(ar.last_opened_Date__c!=null && LeadClosedTaskcntMap.containsKey(ar.id) && !LeadClosedEventcntMap.containsKey(ar.id) ){
                
                if(ar.Touches_Since_Last_Open__c!=LeadClosedTaskcntMap.get(ar.Id))
                {
                    ar.Touches_Since_Last_Open__c=LeadClosedTaskcntMap.get(ar.Id);
                    
                    UpdateLeadStatusList.add(ar);
                }
            }
            
            if(ar.last_opened_Date__c!=null && LeadClosedEventcntMap.containsKey(ar.id) && !LeadClosedTaskcntMap.containsKey(ar.id) ){
                
                if(ar.Touches_Since_Last_Open__c!=LeadClosedEventcntMap.get(ar.Id))
                {
                    ar.Touches_Since_Last_Open__c=LeadClosedEventcntMap.get(ar.Id);
                    
                    UpdateLeadStatusList.add(ar);
                }
            }
            
            if(ar.last_opened_Date__c!=null && !LeadClosedEventcntMap.containsKey(ar.id) && !LeadClosedTaskcntMap.containsKey(ar.id) && ar.Touches_Since_Last_Open__c!=null ){
                
                if(ar.Touches_Since_Last_Open__c!=0){
                    ar.Touches_Since_Last_Open__c=0;
                    
                    UpdateLeadStatusList.add(ar);
                }
            }
            
        }
        
        if(!UpdateLeadStatusList.isempty()) {
            TriggerHandler.bypass('LeadTriggerHandler');
            database.update(UpdateLeadStatusList, false);
            TriggerHandler.clearBypass('LeadTriggerHandler');
        }
    }    
    
    global void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        
    }  
}