/*****************************************************************************************
Name: Extension_Expiry_Notification_Batch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Notify Finance and rep on Renewal due on a daily basis

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           29-Apr-2019      Initial Development
1.1            Rajesh Singh         29-Oct-2020      CR# 1035 & 1036
2.0            Harish Gowda N       23-Dec-2022      Added Changes for Batch Monitoring Frame Work.
******************************************************************************************/

public class Extension_Expiry_Notification_Batch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('Extension_Expiry_Notification_Batch');
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    public string query;
    public Integer days = 0;
    public Date day;
    public List<String> StrList;
    
    public Extension_Expiry_Notification_Batch(){
        days = 0;
        StrList = new List<String>(); 
        StrList.add(label.Stage_4_Economic_Buyer_Signoff);
        StrList.add(label.Stage_5_Contracts_Complete);
        StrList.add(label.Stage_5A_Opportunity);
        StrList.add(label.Stage_5B_Opportunity);
        StrList.add(label.Stage_5C_Opportunity);
        StrList.add(label.Stage_6_Closed_Won);
        StrList.add(label.Stage_7_Closed_Lost);
        query = 'Select Id, Owner.GEO__c, Name, AccountId, Owner.Email, Partner_Account_Contact_Email__c, Contract_End_Date_New__c, Amount, CloseDate, StageName, Owner.Name, Renewal_Notification_Status_Formula__c,  Past_Due_Notification_Status_Formula__c, Renewable_ACV__c, Next_Renewal_Notification_Date__c, Extension_Approval_Status__c, New_Extended_Contract_Date__c, Number_of_Extension_Requests__c, OwnerId, Geo_Account__c, Patch__r.PatchTeam__r.GEO_VP__c, Patch__r.PatchTeam__r.Renewal_Director__c from Opportunity where Recordtype.name = \'Renewal Opportunity\' and Extension_Expiry_Notification_Date__c = Today and StageName NOT IN: StrList';/*\'10 - Closed Won\', \'10b - PO recd, pending finance approval\',\'11 - Closed Lost\', \'12 - Closed With No Decision\', \'13 - Closed & Approved By Finance\', \'14 - Closed: Delete Duplicate\')*/
    }
    
    public Extension_Expiry_Notification_Batch(String query, Integer days){
        // Added by Rajesh : CR# 1208 : Start
        String str1 = label.Stage_6_Closed_Won;
        String str2 = label.Stage_7_Closed_Lost;
        StrList = new List<String>(); 
        StrList.add(str1);
        StrList.add(str2);
        // Added by Rajesh : CR# 1208 : End
        this.query = query;
        this.days = days;
        day = System.Today().addDays(days);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }

    
    public void execute (Database.BatchableContext context, List<Opportunity> opplist){
        this.zb.callExecute(opplist[0]?.Id, opplist.size());
        switch on days{
            when 0 {
                existingNotification(opplist);
            }
            
            when 180 {
                notificationFor180thDay(opplist);
            }
        }
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
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
            mail1.setSubject('Renewal Notification Batch Failure result');
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
            mail.setSubject('Renewal Notification Batch Success result ');
            mail.setPlainTextBody('Renewal Notification Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        if(!Test.isRunningTest()){
            Messaging.sendEmail(messageList);
        }
    }
    
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    private static Boolean canSendEmail(Integer count) {
       Boolean canSend;

       try {
           Messaging.reserveSingleEmailCapacity(count);
           canSend = true;
       } catch (Exception ex) {
           System.debug(ex.getMessage());
           canSend = false;
       }

       return canSend;
   }
    
    //Moved existing functionality from execute to this method -- CR 1035/1036 -- Rajesh 
    private void existingNotification(List<Opportunity> opplist){
        /*if(Test.isRunningTest()){
            booster();
        }*/
        
        Opportunity opp = opplist[0];
        String orderops = label.Order_Ops_Email_Id;
        String emailtempname = '';
        if(opp.New_Extended_Contract_Date__c != null && opp.New_Extended_Contract_Date__c == Date.today()){
            emailtempname = 'Extension Expiry Notification Alert';
        }else if(opp.New_Extended_Contract_Date__c != null && opp.New_Extended_Contract_Date__c < Date.today()){
            emailtempname = 'Extension Expiry Termination Alert';
        }
        
        EmailTemplate et = [Select Id,Name from EmailTemplate where Name = :emailtempname];
        List<string> emailIdList = new List<string>();
        list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
        
            if(runningInASandbox()){
                
                emailIdList.clear();
                
                /*emailIdList.add('snag@zscaler.com');
                emailIdList.add('uraju@zscaler.com');*/
                
                
                for(String s: Renewal_Notification_Emails__c.getAll().keyset()){
                    emailIdList.add(s);
                }
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, Userinfo.getUserId(), opp.Id);
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'zbilling@zscaler.com'];
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                if(!emailIdList.isEmpty()){
                    mail.setToAddresses(emailIdList);
                }
                mail.setsaveAsActivity(false);
                emailList.add(mail);
            }else{
                emailIdList.clear();
                
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, opp.OwnerId, opp.Id);
                emailIdList.add(orderops);
                
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'zbilling@zscaler.com'];
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                if(!emailIdList.isEmpty()){
                    mail.setToAddresses(emailIdList);
                }
                
                mail.setsaveAsActivity(false);
                emailList.add(mail);
            }
            String sentemailsto = '';
            try{
                for(String s: emailIdList){
                    sentemailsto += s + ';';
                }
                if(canSendEmail(emailIdList.size())){
                    Messaging.sendEmail(emailList);
                    
                    Task actHistory = new Task(Subject='Extension Expiry Reminder Notification Email sent on ' + Date.Today(), WhatId=opp.Id, Status='Completed', ActivityDate=Date.today(), Description='Extension Expiry Reminder Notification sent to below addresses: \n ' + sentemailsto + '\n Template Used: ' + emailtempname, OwnerId = opp.OwnerId ,Priority='Normal', type='Other');
                    actHistory.WhoId = null;
                    insert actHistory;
                    successlst.add(opp.Id);
                }
            }catch(Exception e){
                errorlst.add('Exception on opp:' + opp.Id + '. Exception is ' + e);
            }
    }
     
    //Added by Rajesh - CR 1035/1036 --  - Start
    private void notificationFor180thDay(List<Opportunity> opplist){
        Opportunity opp = opplist[0];
        EmailTemplate et = [Select Id,Name, HtmlValue from EmailTemplate where Name = 'Upcoming Renewal Notification Internal 180 Day Notification'];
        String body =et.HtmlValue;
        list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, Userinfo.getUserId(), opp.Id);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'z-cs-ops@zscaler.com'];
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }else{
            mail.setsenderDisplayName('Renewal Operations');
        }
        List<String> toEmails = new List<String>();
        // Pending clarification for Channel Account Manager, Technical Account Manager, RSM
        //updated by Ayush Kangar: CR# 2757 Start
        if(opp.Owner.Email != null){
            toEmails.add(opp.Owner.Email);// Renewal Manager
        }
        //updated by Ayush Kangar: CR# 2757 End
        if(opp.Account.Sales_Engineer__r.Email != null){
            toEmails.add(opp.Account.Sales_Engineer__r.Email); 
        }
        if(opp.Account.CSM_Name_New__c != null){
            toEmails.add(opp.Account.CSM_Name_New__r.Email);
        }
        if(opp.Account.Solution_Architect__c != null){
            toEmails.add(opp.Account.Solution_Architect__r.Email);
        }
        if(opp.Account.Account_Manager__c != null){
            toEmails.add(opp.Account.Account_Manager__r.Email);
        }
        if(opp.Account.TAM_Name_New__c != null){
            toEmails.add(opp.Account.TAM_Name_New__r.Email);
        }else if(opp.Account.Secondary_TAM_Name__c != null){
            toEmails.add(opp.Account.Secondary_TAM_Name__r.Email);
        }
        if(opp.Account.Channel_Manager__c != null){
            toEmails.add(opp.Account.Channel_Manager__r.Email);
        }
        
        // Set body content as parent child is not supported by standard template
        
        
        if(opp.Account.Name != null){
            body = body.replace('{!Opportunity.Account}',  '<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Account.Id+'">'+opp.Account.Name+'</a>');
        }else{
            body = body.replace('{!Opportunity.Account}', '');
        }
        
        if(opp.Name != null){
            body = body.replace('{!Opportunity.Name}', '<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id+'">'+opp.Name+'</a>');
        }else{
            body = body.replace('{!Opportunity.Name}', '');
        }
        
        
        if(opp.Contract_End_Date_New__c != null){
            body = body.replace('{!Opportunity.Contract_End_Date_New__c}', String.valueOf(opp.Contract_End_Date_New__c));
        }else{
            body = body.replace('{!Opportunity.Contract_End_Date_New__c}', '');
        }
        
        if(opp.CloseDate != null){
            body = body.replace('{!Opportunity.CloseDate}', String.valueOf(opp.CloseDate));
        }else{
            body = body.replace('{!Opportunity.CloseDate}', '');
        }
        
        if(opp.Renewable_ACV__c != null){
            body = body.replace('{!Opportunity.Renewable_ACV__c}', String.valueOf(opp.Renewable_ACV__c));
        }else{
            body = body.replace('{!Opportunity.Renewable_ACV__c}', '');
        }
        //updated by Ayush Kangar: CR# 2757 Start
        if(opp.Owner.Name != null){
            body = body.replace('{!Opportunity.OwnerFullName}', opp.Owner.Name);
        }else{
            body = body.replace('{!Opportunity.OwnerFullName}', '');
        }
        //updated by Ayush Kangar: CR# 2757 End
        if(opp.Account.Owner.Name != null){
            body = body.replace('{!Account.OwnerFullName}', opp.Account.Owner.Name); // clarify this one
        }else{
            body = body.replace('{!Account.OwnerFullName}', ''); 
        }
        if(opp.Account.Sales_Engineer__r.Name != null){
            body = body.replace('{!Account.Sales_Engineer__c}', opp.Account.Sales_Engineer__r.Name);
        }else{
            body = body.replace('{!Account.Sales_Engineer__c}', '');
        }
        if(opp.Account.Channel_Manager__r.Name != null){
            body = body.replace('{!Account.Channel_Manager__c}', opp.Account.Channel_Manager__r.Name);
        }else{
            body = body.replace('{!Account.Channel_Manager__c}', '');
        }
        if(opp.Account.CSM_NAMEOverlay__c != null){
            body = body.replace('{!Account.CSM_NAMEOverlay__c}', opp.Account.CSM_NAMEOverlay__c);
        }else{
            body = body.replace('{!Account.CSM_NAMEOverlay__c}', '');
        }
        if(opp.Account.TAM_Name_New__r.Name != null){
            body = body.replace('{!Account.TAM_Name_New__c}', opp.Account.TAM_Name_New__r.Name);
        }else{
            body = body.replace('{!Account.TAM_Name_New__c}', '');
        }
        if(opp.Account.Solution_Architect_Name__c != null){
            body = body.replace('{!Account.Solution_Architect_Name__c}', opp.Account.Solution_Architect_Name__c);
        }else{
            body = body.replace('{!Account.Solution_Architect_Name__c}', '');
        }
        
        body = body.replace('</p>]]></td>', '</p></td>');
        
        mail.setHtmlBody(body);
        mail.setSubject('Action: ' + opp.Account.Name + ' is set to renew within 180 days');
        mail.setsaveAsActivity(false);
        mail.setToAddresses(toEmails);
        emailList.add(mail);
        Messaging.sendEmail(emailList);
    }
     //Added by Rajesh - CR 1035/1036  - End
}