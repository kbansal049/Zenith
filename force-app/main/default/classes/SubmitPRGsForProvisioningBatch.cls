/*****************************************************************************************
Name: SubmitPRGsForProvisioningBatch
Copyright © Zscaler
--------
Purpose:
--------
1. The batch job which will fetch the Subscription recordtype Provisioning Request Group records whose status is 'Waiting' and [Next-Start-Date is blank And Start-Date <= Current-Date] OR [Next-Start-Date is not blank And Next-Start-Date <= Current-Date and Changed its status from Waiting to Requested  
--------
--------
History
-------
VERSION        AUTHOR                  	DATE              	DETAIL
1.0            Prachi Dandriyal      	23-May-2022      	Initial Development
******************************************************************************************/

public class SubmitPRGsForProvisioningBatch implements Database.Batchable<SObject>, Database.Stateful, System.Schedulable {
	ZscalerBatchFramework zb = new ZscalerBatchFramework('SubmitPRGsForProvisioningBatch');
    public Static Id subsPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();//IBA-399
    List<Provisioning_Group__c> proGroupList = new List<Provisioning_Group__c>();
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    String WAITINGSTATUS = 'Waiting';
    String ARCHIVEDSTATUS = 'Archived';
    String PROVISIONTATUS = 'Provisioned';
    String REQUESTSTATUS = 'Requested';
    String ORDERCREATED = 'Order Created';
    String provisioningGroupFields = CreateSalesOrderExtensionCPQSalesLWCNew.getFieldNamesOfSObject('Provisioning_Group__c');

    public Database.QueryLocator start(Database.BatchableContext context) {
        this.zb.callStart();
        //String query = 'SELECT Id,Status__c, Opportunity__r.Stage_Date_Change__c,Name FROM Provisioning_Group__c WHERE RecordTypeId=subsPGRecordTypeId AND Status__c = WAITINGSTATUS AND ((Provisioning_Submission_Date__c = NULL AND Start_Date__c<=System.today()) OR (Provisioning_Submission_Date__c != NULL AND Provisioning_Submission_Date__c<=System.today()))';
        String query = 'SELECT ' +  provisioningGroupFields 
            + ', Opportunity__r.Account.Geo__c, Opportunity__r.Account.Region__c, Opportunity__r.Account.Area__c, Opportunity__r.Account.District__c  FROM Provisioning_Group__c' 
            + ' WHERE RecordTypeId = :subsPGRecordTypeId AND Status__c = :WAITINGSTATUS AND Sub_Status__c =: ORDERCREATED AND Product_Line__c != \'ZDX\' AND'
            + ' ((Provisioning_Submission_Date__c = NULL AND Start_Date__c <= TOMORROW) OR (Provisioning_Submission_Date__c != NULL AND Provisioning_Submission_Date__c <= TOMORROW))';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context,List<Provisioning_Group__c> provGroupList) {
        this.zb.callExecute(provGroupList[0]?.Id, provGroupList.size());
        List<Provisioning_Group__c> pgUpdateList = new List<Provisioning_Group__c>();
        Set<Id> originalPRGIds = new Set<Id>();
        for(Provisioning_Group__c provGroup : provGroupList) {
            System.debug('provGroup Startdate: '+provGroup.Start_Date__c);
            System.debug('provGroup Geo: '+provGroup.Opportunity__r.Account.Geo__c);
            if(((provGroup.Opportunity__r.Account.Geo__c == 'Americas') 
                || provGroup.Opportunity__r.Account.Geo__c == 'Public Sector' 
                || (provGroup.Opportunity__r.Account.Geo__c == 'WW Commercial' 
                    && provGroup.Opportunity__r.Account.Region__c == 'AMS Commercial'))
              	&& provGroup.Start_Date__c <= System.today()){
                provGroup.Status__c = REQUESTSTATUS;
                pgUpdateList.add(provGroup);    
            }
            
            if(((provGroup.Opportunity__r.Account.Geo__c == 'APJ') 
                || (provGroup.Opportunity__r.Account.Geo__c == 'WW Commercial' 
                    && provGroup.Opportunity__r.Account.Region__c == 'International commercial' 
                    && provGroup.Opportunity__r.Account.Area__c == 'APJ Comm'))  
               	&& provGroup.Start_Date__c <= System.today()+1){
				provGroup.Status__c = REQUESTSTATUS;
                pgUpdateList.add(provGroup);    
            }
            
            if(((provGroup.Opportunity__r.Account.Geo__c == 'EMEA') 
                || (provGroup.Opportunity__r.Account.Geo__c == 'WW Commercial' 
                    && provGroup.Opportunity__r.Account.Region__c == 'International commercial' 
                    && provGroup.Opportunity__r.Account.Area__c.contains('EMEA Comm'))) 
               && provGroup.Start_Date__c <= System.today()+1){
                provGroup.Status__c = REQUESTSTATUS;
                pgUpdateList.add(provGroup);    
            }
            
            //Commented below line.
            //Provisioning_Group__c origPG = new Provisioning_Group__c();
			
            if(provGroup.Original_Provisioning_Group__c != null) {
                originalPRGIds.add(provGroup.Original_Provisioning_Group__c);
            }
        }
        
        if(!originalPRGIds.isEmpty()) {
            for(Provisioning_Group__c pg : [SELECT Id FROM Provisioning_Group__c 
                                            WHERE RecordTypeId=:subsPGRecordTypeId 
                                            AND Original_Provisioning_Group__c IN :originalPRGIds 
                                            AND Status__c = :PROVISIONTATUS]) {
                pg.Status__c = ARCHIVEDSTATUS;
                pgUpdateList.add(pg);
            }
        }
        
        try{
            if(!pgUpdateList.isEmpty()){
                Database.SaveResult[] srList = Database.update(pgUpdateList, false);
                for(Database.SaveResult sr : srList){
                    if(sr.isSuccess()){
                        // Operation was successful, so get the ID of the record that was processed
                        successlst.add(sr.getId());
                    }else{
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()){
                            errorlst.add(sr.getId() + ' - ' + err.getMessage());
                        }
                    }
                }
            }
        }catch(Exception ex){
            errorlst.add('Error: ' + ex);
            ZscalerErrorLogsUtility.insertlogsForAsync('SubmitPRGsForProvisioningBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
        }
    }
    
    public void finish(Database.BatchableContext context) {
		this.zb.callFinish(context);
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sfdcsupport@zscaler.com'];
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if (!owea.isEmpty()) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Entitlement Creation Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){
                msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }
        if(!successlst.isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Provision Group for Subscription Creation Batch Success result ');
            mail.setPlainTextBody('Provision Group for Subscription Creation Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
    public void execute(SchedulableContext sc) {
         Database.executeBatch(new SubmitPRGsForProvisioningBatch());
    }
}