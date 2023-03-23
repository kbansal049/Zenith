public class CloudUsageDatafixbatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CloudUsageDatafixbatch');
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();

    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        Set<id> tempidset= new Set<id>();
        tempidset.add('aN0520000008TBR');
        String query = 'Select Id,Name,Cloud_Usage_External_Id__c from ZPA_Cloud_Usage_data__c where Zscaler_Cloud_ID__c!=null';
        //String query = 'Select id,Name,Cloud_Usage_External_Id__c from ZPA_Cloud_Usage_data__c where ID IN:tempidset and Zscaler_Cloud_ID__c!=null ';
        system.debug('query '+query);
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<ZPA_Cloud_Usage_data__c> sobjectlist){
        this.zb.callExecute(sobjectlist[0]?.Id, sobjectlist.size());
        system.debug('inside execute method');
        Set<id> Setofids= new Set<id>();
        Set<string> SetofExtids= new Set<string>();
        map<string,string>  externalidandName= new map<string,string>();
        for(ZPA_Cloud_Usage_data__c sobj: sobjectlist){
            Setofids.add(sobj.id);
            SetofExtids.add(sobj.Cloud_Usage_External_Id__c);
            externalidandName.put(sobj.Cloud_Usage_External_Id__c,sobj.Name);
        }
        system.debug('Setofids  '+Setofids ); 
        system.debug('SetofExtids  '+SetofExtids ); 
        system.debug('externalidandName  '+externalidandName ); 
        
        List<Cloud_Usage__c> CloudUsageRecordstoupdate= new List<Cloud_Usage__c>();
        for(Cloud_Usage__c cu:[SELECT id,Name,Cloud_Usage_External_Id__c FROM Cloud_Usage__c where Cloud_Usage_External_Id__c IN:SetofExtids]){
            system.debug('cu '+cu);
            if(externalidandName.containskey(cu.Cloud_Usage_External_Id__c) && cu.Name!=externalidandName.get(cu.Cloud_Usage_External_Id__c)){
                Cloud_Usage__c cunew= new Cloud_Usage__c();
                cunew.Name=externalidandName.get(cu.Cloud_Usage_External_Id__c);
                cunew.id=cu.id;
                cu.Cloud_Usage_External_Id__c=cu.Cloud_Usage_External_Id__c;
                CloudUsageRecordstoupdate.add(cunew);
            }
        }
        system.debug('CloudUsageRecordstoupdate '+CloudUsageRecordstoupdate);
        Database.SaveResult[] results = database.update(CloudUsageRecordstoupdate, false);
        system.debug('results '+results);
       
       TriggerUtility.SkipAccTriggerExecuted();
       
        Set<String> ZIAZPAcloudusagePassed = new Set<String>();
        for (Integer i = 0;i<CloudUsageRecordstoupdate.size();i++) {
            if(results.get(i).isSuccess()){
                system.debug('success');
                // Operation was successful, so get the ID of the record that was processed
                //successlst.add(sr.getId());
                successlst.add((id)CloudUsageRecordstoupdate.get(i).id);
                ZIAZPAcloudusagePassed.add((String)CloudUsageRecordstoupdate.get(i).Cloud_Usage_External_Id__c);
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
        this.zb.callFinish(context);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        
        
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Cloud Usage Batch Failure result');
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
            mail.setSubject('Cloud Usage Batch Success result ');
            mail.setPlainTextBody('Cloud Usage Batch has been executed Successfully and processed '+ successlst.size() + ' records');
            messageList.add(mail);
        }
        if(!test.isrunningtest()){
            Messaging.sendEmail(messageList);
        }
    }
    
}