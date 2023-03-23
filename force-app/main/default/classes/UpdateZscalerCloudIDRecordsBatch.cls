public class UpdateZscalerCloudIDRecordsBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateZscalerCloudIDRecordsBatch');
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();

    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        String query = 'Select ID,Zscaler_Cloud_ID__c from ZDX_Cloud_Usage__c where CreatedDate =TODAY';
        system.debug('query '+query);
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<ZDX_Cloud_Usage__c> sobjectlist){
        this.zb.callExecute(sobjectlist[0]?.Id, sobjectlist.size());
        system.debug('inside UpdateZscalerCloudIDRecordsBatch execute method');
        Map<Id,Id> zscalerCloudIdvsZDXId = new Map<Id,Id>();
        List<Zscaler_Cloud_ID__c> zscalerCloudIds = new List<Zscaler_Cloud_ID__c>();
        for(ZDX_Cloud_Usage__c cloudUse:sobjectlist){
            if(String.isNotBlank(cloudUse.Zscaler_Cloud_ID__c)){
                zscalerCloudIdvsZDXId.put(cloudUse.Zscaler_Cloud_ID__c, cloudUse.Id);
            }
        }
        if(!(zscalerCloudIdvsZDXId.keySet()).isEmpty()){
            for(Id zsc:zscalerCloudIdvsZDXId.keySet()){
                Zscaler_Cloud_ID__c zscid = new Zscaler_Cloud_ID__c();
                zscid.id = zsc;
                zscid.Latest_ZDX_Cloud_Usage__c = zscalerCloudIdvsZDXId.get(zsc);
                zscalerCloudIds.add(zscid);
            }
        }
        if(!zscalerCloudIds.isEmpty()){
            TriggerUtility2.UpdateZscalerCloudIdTriggerExecuted();
            System.debug('zscalerCloudIds '+zscalerCloudIds);
            Database.SaveResult[] updateResult = Database.update(zscalerCloudIds, false);
            system.debug('results '+updateResult);
            for (Integer i = 0;i<zscalerCloudIds.size();i++) {
                if(updateResult.get(i).isSuccess()){
                	system.debug('success');
                	successlst.add((id)zscalerCloudIds.get(i).id);
                }
                else{
                    system.debug('Error');
                	errorlst.add((id)zscalerCloudIds.get(i).id);
                }
            }
            TriggerUtility2.UpdateZscalerCloudIdTriggerReset();
        }
        
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
            mail1.setSubject('Update Zscaler Cloud ID Records Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }else{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Update Zscaler Cloud ID Records Batch Success result ');
            mail.setPlainTextBody('UpdateZscalerCloudIDRecordsBatch has been executed Successfully and processed '+ successlst.size() + ' records');
            messageList.add(mail);
        }
        if(!test.isrunningtest()){ Messaging.sendEmail(messageList);
        }
    }
    
}