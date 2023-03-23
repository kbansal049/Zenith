global class BatchAutoCloseLead implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('BatchAutoCloseLead');

    global Id LeadId;
    global Map<Id,String> errorMap = new Map<Id,String>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
     this.zb.callStart();
        
          String query = 'SELECT ID, Status, Remarks__c,Outreach_Status__c,Age_Since_Last_Open__c,Days_since_last_activity__c FROM LEAD WHERE (Status=\'SAL: Sales Pursuing Lead\' AND Days_since_last_activity__c >30) OR (Status=\'SAL: Sales Connected Lead\' AND Days_since_last_activity__c >30) OR (STATUS =\'Marketing Qualified: Sales Untouched\' AND Age_Since_Last_Open__c>10)'; // updated status condition as part of CR# 2731 :Gurjinder
    if(test.isRunningTest())
        {
            query='SELECT ID, Status, Remarks__c,Outreach_Status__c,Age_Since_Last_Open__c,Days_since_last_activity__c FROM LEAD WHERE Status=\'Marketing Qualified: Sales Accepted\' OR  STATUS =\'Marketing Qualified: Sales Untouched\' LIMIT 10';

        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Lead> records){
        this.zb.callExecute(records[0]?.Id, records.size());
        List<Lead> UpdateLeadStatusList = new List<Lead>();
        Try{
        for (Lead ar : records)  {
            LeadId = ar.id;
            if(ar.status=='Marketing Qualified: Sales Untouched'){
                ar.status='Recycled to Marketing';  
                ar.Remarks__c='Lead Not Worked';
                //ar.Outreach_Status__c='Closed'; Removed by Rajesh : CR# 1170
                UpdateLeadStatusList.add(ar);


            }
            if(ar.status=='SAL: Sales Pursuing Lead' || ar.status=='SAL: Sales Connected Lead' ){ // updated status condition as part of CR# 2731 :Gurjinder
                ar.status='Recycled to Marketing';  
                ar.Remarks__c='No Response';
                //ar.Outreach_Status__c='Closed'; Removed by Rajesh : CR# 1170
                UpdateLeadStatusList.add(ar);


            }
            
            
        }
    //Added by swathi : CR 1398 start
        
        if(!UpdateLeadStatusList.isempty()){
          TriggerHandler.bypass('LeadTriggerHandler');
          database.update(UpdateLeadStatusList, false);
          TriggerHandler.ClearBypass('LeadTriggerHandler');
        }
        }catch(Exception ex){
            System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
            errorMap.put(LeadId,ex.getMessage() + ' at Line No. ' + ex.getLineNumber());  
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        this.zb.callFinish(BC);
        System.debug('--errorMap--'+errorMap);
        //Schedule a batch job for Contacts: Start 
            AutoCloseLeadBatch M = new AutoCloseLeadBatch();
            Database.executeBatch(M,50);
        //Schedule a batch job for Contacts: End 
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        if(!errorMap.Values().isEmpty() || Test.isRunningTest()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Auto close contact Batch Job Failed');
            String msgbody = 'Below are the Ids of ' + errorMap.Values().size() + ' Auto close contact Batch Job failed: \n';
            for(Id s: errorMap.keySet()){
                msgbody += 'Id : '+s + ' Error Message : '+errorMap.get(s) +'\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }
        if(errorMap.Values().isEmpty() || Test.isRunningTest()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Auto close Lead Batch Job Completed  ');
            mail.setPlainTextBody('Auto close Lead Batch Job Completed ');
            messageList.add(mail);
        }
        if(!Test.isRunningTest()){
            Messaging.sendEmail(messageList);
        }
        
    }
    //Added by swathi : CR 1398 End
    
    global void execute(SchedulableContext sc) {
        BatchAutoCloseLead b = new BatchAutoCloseLead(); 
        database.executebatch(b,200);
    }
}