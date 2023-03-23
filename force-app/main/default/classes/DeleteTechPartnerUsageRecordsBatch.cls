public class DeleteTechPartnerUsageRecordsBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('DeleteTechPartnerUsageRecordsBatch');
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    String ObjectName='';
    
    public DeleteTechPartnerUsageRecordsBatch(string objname){
        ObjectName=objname;
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callStart();
        String query = '';
        if(ObjectName=='Technology_Partner_Usage__c'){
            query = 'Select Id from Technology_Partner_Usage__c where Do_Not_Override__c=false';
        }else if(ObjectName=='Tech_Partner_Usage_Placeholder__c'){
            date lastmonthdate=Date.today().adddays(-28);
            query = 'Select Id from Tech_Partner_Usage_Placeholder__c where lastmodifieddate<=:lastmonthdate';
            if(test.isrunningtest()){
            query = 'Select Id from Tech_Partner_Usage_Placeholder__c';
            }
        }
        system.debug('query '+query);
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<sobject> sobjectlist){
        this.zscalerBatchFrameWorkObj.callExecute(sobjectlist[0]?.Id, sobjectlist.size());
        system.debug('inside execute method');      
        system.debug('sobjectlist '+sobjectlist);
        Database.DeleteResult[] results = database.delete(sobjectlist, false);
        system.debug('results '+results);
       
        for (Integer i = 0;i<sobjectlist.size();i++) {
            if(results.get(i).isSuccess()){
                system.debug('success');
                // Operation was successful, so get the ID of the record that was processed
                //successlst.add(sr.getId());
                successlst.add((id)sobjectlist.get(i).id);
            }
            else {
                system.debug('fail');
                for(Database.Error err : results.get(i).getErrors()) {errorlst.add(results.get(i).getid() + ' - ' + err.getMessage());
                }
                //errorlst.add(sr.getId() + ' - ' + err.getMessage());
            }
        }
    
        system.debug('successlst '+successlst);     
        system.debug('errorlst '+errorlst); 
          
    }
    
    public void finish(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callFinish(context);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        
        String objectlabel='';
        if(ObjectName=='Technology_Partner_Usage__c'){
            objectlabel='Technology Partner Usage';
            system.debug('before calling deletion batch for Tech_Partner_Usage_Placeholder__c');
            DeleteTechPartnerUsageRecordsBatch btch= new DeleteTechPartnerUsageRecordsBatch('Tech_Partner_Usage_Placeholder__c');
            database.executeBatch(btch);
                    
        }else if(ObjectName=='Tech_Partner_Usage_Placeholder__c'){
            objectlabel='Tech Partner Usage Placeholder';
             system.debug('before calling tech partner usage creation batch');
             string str=System.Label.InvokeTechPartnercreationBatch;
             if(str=='Enable'){
                CreateTechPartnerRecordsBatch bt= new CreateTechPartnerRecordsBatch();
                database.executebatch(bt);
            }
        }
        
        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(!errorlst.isEmpty()){
            
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) { mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            
            mail1.setSubject(objectlabel+ ' Deletion Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }else{
            
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject(objectlabel+ ' Deletion Batch Success result ');
            mail.setPlainTextBody('Tech Partner USage Deletion batch has been executed Successfully and processed '+ successlst.size() + ' records');
            messageList.add(mail);
        }
        if(!test.isrunningtest()){ Messaging.sendEmail(messageList);
        }

    }
    
}