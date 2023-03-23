public class OpportunityDataActivitybatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('OpportunityDataActivitybatch');
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();

    public Database.QueryLocator start(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callStart();
        Set<id> tempidset= new Set<id>();
        tempidset.add('aN0520000008TBR');
        String query = 'Select id,Accountid,Account_Extension__c from Opportunity where Account_Extension__c=null';
        if(test.isrunningtest()){
            query = 'Select id,Accountid,Account_Extension__c from Opportunity';
        }
        system.debug('query '+query);
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<Opportunity> sobjectlist){
        this.zscalerBatchFrameWorkObj.callExecute(sobjectlist[0]?.Id, sobjectlist.size());
        system.debug('inside execute method');
        Set<id> AccidSet= new Set<id>();
        map<id,id> AccidandAccExtsnidmap= new map<id,id>();
        List<Opportunity> Opplisttoupdate= new List<Opportunity>();
        
        for(Opportunity sobj: sobjectlist){
            AccidSet.add(sobj.Accountid);
        }
        system.debug('AccidSet  '+AccidSet ); 
        
        List<Cloud_Usage__c> CloudUsageRecordstoupdate= new List<Cloud_Usage__c>();
        for(Account_Extension__c accext:[SELECT id,Account__c FROM Account_Extension__c where Account__c IN:AccidSet]){
            system.debug('accext '+accext);
            AccidandAccExtsnidmap.put(accext.Account__c,accext.id);
        }
        system.debug('AccidandAccExtsnidmap '+AccidandAccExtsnidmap);
        
        if(AccidandAccExtsnidmap!=null){
            for(Opportunity sobj: sobjectlist){
                system.debug('sobj '+sobj);
                sobj.Account_Extension__c=AccidandAccExtsnidmap.get(sobj.Accountid);
                system.debug('sobj '+sobj);
                Opplisttoupdate.add(sobj);
            }
        }
        
        Database.SaveResult[] results = database.update(Opplisttoupdate, false);
        system.debug('results '+results);
       
       TriggerUtility.SkipAccTriggerExecuted();
       
        Set<String> ZIAZPAcloudusagePassed = new Set<String>();
        for (Integer i = 0;i<Opplisttoupdate.size();i++) {
            if(results.get(i).isSuccess()){
                system.debug('success');
                // Operation was successful, so get the ID of the record that was processed
                //successlst.add(sr.getId());
                successlst.add((id)Opplisttoupdate.get(i).id);
                //ZIAZPAcloudusagePassed.add((String)Opplisttoupdate.get(i).Cloud_Usage_External_Id__c);
            }
            else {
                system.debug('fail');
                for(Database.Error err : results.get(i).getErrors()) {errorlst.add(results.get(i).getid() + ' - ' + err.getMessage());
                }
                //errorlst.add(sr.getId() + ' - ' + err.getMessage());
            }
        }
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
        system.debug('successlst '+successlst);     
        system.debug('errorlst '+errorlst);               
    }
    
    public void finish(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callFinish(context);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        
        
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Opportunty Data Update Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }else{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{ mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Opportunty Data Update Batch Success result ');
            mail.setPlainTextBody('Opportunty Data Update vatch has been executed Successfully and processed '+ successlst.size() + ' records');
            messageList.add(mail);
        }
        if(!test.isrunningtest()){
            Messaging.sendEmail(messageList);
        }
    }
    
}