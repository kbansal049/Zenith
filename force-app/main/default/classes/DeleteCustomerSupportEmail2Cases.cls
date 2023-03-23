/*****************************************************************************************
Name: DeleteCustomerSupportEmail2Cases
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Delete Customer Support Cases created via Email2Case

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           04-Dec-2019      Initial Development
2.0            Harish Gowda N       23-Dec-2022      Added Changes for Batch Monitoring Frame Work.
******************************************************************************************/

public class DeleteCustomerSupportEmail2Cases implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('DeleteCustomerSupportEmail2Cases');
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callStart();
        String query = 'Select Id from Case where RecordType.DeveloperName = \'Support_EmailToCase\' ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Case> cslst){
        this.zscalerBatchFrameWorkObj.callExecute(cslst[0]?.Id, cslst.size());
        try{
            Database.DeleteResult[] drList = Database.delete(cslst, false);

            // Iterate through each returned result
            for(Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(''+dr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : dr.getErrors()) {
                        errorlst.add(dr.getId() + ': ' + err.getMessage());
                    }
                }
            }
        }catch(Exception ex){
            errorlst.add('Error: ' + ex);
        }
    }
    
    public void finish(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callFinish(context);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Case Deletion - Email to Case Failure result');
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
            mail.setSubject('Case Deletion - Email to Case Success result ');
            mail.setPlainTextBody('Case Deletion - Email to Case has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
}