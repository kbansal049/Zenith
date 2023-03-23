/*****************************************************************************************
Name: NewUserSRandSkillCreationBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Create Service Resource and Skill for new Users

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           18-Dec-2019      Initial Development
2.0            Harish Gowda N       23-Dec-2022      Added Changes for Batch Monitoring Frame Work.
******************************************************************************************/

public class NewUserSRandSkillCreationBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zscalerBatchFrameWorkObj = new ZscalerBatchFramework('NewUserSRandSkillCreationBatch');
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    String query;
    String que = 'Select Id, Firstname, lastname, service_level__c, Skills__c, UserPermissionsSupportUser from User where Skills__c != null and UserPermissionsSupportUser = true and Id not in (Select RelatedRecordId from ServiceResource where isactive = true)';
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zscalerBatchFrameWorkObj.callStart();
        return Database.getQueryLocator(query);
    }
    
    public NewUserSRandSkillCreationBatch(String q){
        if(q != null && q != ''){
            query = q;
        }else{
            query = que;
        }
    }

    public void execute(Database.BatchableContext context, List<User> newList){
        this.zscalerBatchFrameWorkObj.callExecute(newList[0]?.Id, newList.size());
        //try{
            Map<Id, User> serviceUsers = new Map<Id, User>();
            Map<String, ServiceResource> srmap = new Map<String, ServiceResource>();
            for(User u: newList){
                if(u.Skills__c != null && u.UserPermissionsSupportUser == true){
                    serviceUsers.put(u.Id, u);
                }
            }

            if(!serviceUsers.isEmpty()){
                srmap = UserTriggerUtility.ServicecreateServiceResources(serviceUsers);
                if(srmap != null && !srmap.isEmpty()){
                    UserTriggerUtility.createserviceResourceSkill(serviceUsers, srmap);
                }
            }
            for(User u: newList){
                successlst.add(u.Id);
            }
        //}catch(Exception ex){
        //    errorlst.add('Error: ' + ex);
        //}
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
            mail1.setSubject('User Skill Creation Failure result');
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
            mail.setSubject('User Skill Creation Batch Success result ');
            mail.setPlainTextBody('User Skill Creation Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
}