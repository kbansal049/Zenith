/*****************************************************************************************
Name: CTM, SCI, Opportunity Rollup info onto Account
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. CTM, SCI, Opportunity Rollup info onto Account

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           29-Apr-2019      Initial Development
3.0            Parth Doshi          11-Jun-2020      Remove SCI Dependencies, Include Event CR# 349
4.0            Akash Thakur         07-July-2022       CR# 5023 Added Batch Job Monitoring Code
******************************************************************************************/

public class Rollup_Key_Fields_To_Account implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('Rollup_Key_Fields_To_Account');
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        String query = '';
        if(Test.isRunningTest()){
             query= 'Select Id, Number_of_Ramped_Users__c, Link_to_Value_Output__c, Last_SCI_Date__c, Service_Owner_Present__c, Head_of_IT__c, Head_of_Networking__c, Head_of_Security__c from Account';
        }else{
             query = 'Select Id, Number_of_Ramped_Users__c, Link_to_Value_Output__c, Last_SCI_Date__c, Service_Owner_Present__c, Head_of_IT__c, Head_of_Networking__c, Head_of_Security__c from Account where Type = \'Customer\' ';
        }
        return Database.getQueryLocator(query);
        
    }
    
    public void execute (Database.BatchableContext context, List<Account> acclst){
	this.zb.callExecute(acclst[0]?.Id, acclst.size());
        Account acc = acclst[0];
        Set<String> setSKUCodes = new Set<String> {
                                        APTS_CONSTANTS.PROD_SKU_SIP,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_SIP,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_PRO_EDITION,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_BUS_EDITION,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_TRANS_EDITION,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_ELA_EDITION
                                    };
        Decimal oldrampedusers = acc.Number_of_Ramped_Users__c;
        Boolean oldhs = acc.Head_of_Security__c;
        Boolean oldhn = acc.Head_of_Networking__c;
        Boolean oldit = acc.Head_of_IT__c;
        Boolean oldserviceowner = acc.Service_Owner_Present__c;
        DateTime oldlastsci = acc.Last_SCI_Date__c;
        
        String oldlinktovalueoutput = acc.Link_to_Value_Output__c;
        
        try{
        
            Date today = date.today();
            List<AggregateResult> totalusers = [SELECT SUM(Quantity__c) a FROM Contract_Detail__c WHERE (Contract_Detail_Status__c = 'Active' OR Contract_Detail_Status__c = 'Renewed') and Start_Date__c <= :today and End_Date__c >= :today and Product_SKU__c in :setSKUCodes and Account_Name__c = :acc.Id];
            acc.Number_of_Ramped_Users__c = totalusers[0].get('a') == null ? 0 : (Decimal)totalusers[0].get('a');
        
            List<AggregateResult>  hslst = [select count(Id) q from Contact where AccountId=:acc.Id and Head_of_Security__c = true and Contacts_that_matter__c = true and (Key_Contact_Status__c = 'Sales Accepted' or Key_Contact_Status__c = 'CSM Accepted')];
            if(hslst.size() > 0)
            {
                acc.Head_of_Security__c = (Decimal)hslst[0].get('q') > 0 ? true : false;
            }
            
            List<AggregateResult>  hnlst = [select count(Id) q from Contact where AccountId=:acc.Id and Head_of_Networking__c = true and Contacts_that_matter__c = true and (Key_Contact_Status__c = 'Sales Accepted' or Key_Contact_Status__c = 'CSM Accepted')];
            if(hnlst.size() > 0)
            {
                acc.Head_of_Networking__c = (Decimal)hnlst[0].get('q') > 0 ? true : false;
            }
            
            List<AggregateResult>  hilst = [select count(Id) q from Contact where AccountId=:acc.Id and Head_of_IT__c = true and Contacts_that_matter__c = true and (Key_Contact_Status__c = 'Sales Accepted' or Key_Contact_Status__c = 'CSM Accepted')];
            if(hilst.size() > 0)
            {
                acc.Head_of_IT__c = (Decimal)hilst[0].get('q') > 0 ? true : false;
            }
            
            List<AggregateResult>  solst = [select count(Id) q from Contact where AccountId=:acc.Id and Service_Owner__c = true and Contacts_that_matter__c = true and (Key_Contact_Status__c = 'Sales Accepted' or Key_Contact_Status__c = 'CSM Accepted')];
            if(solst.size() > 0)
            {
                acc.Service_Owner_Present__c = (Decimal)solst[0].get('q') > 0 ? true : false;
            }
            
            //CR#349 : Remove SCI Dependencies - by Parth Doshi
            DateTime currentTimeStamp = System.Now();
            List<Event>  eventlst = [Select Id,CreatedDate, StartDateTime from Event where accountId =: acc.Id and Type not in (:System.Label.Other_Marketing_CXO_Event)
                                     and StartDateTime < :currentTimeStamp and ActivityDate=LAST_N_DAYS:90 and peopleai__MeetingStatus__c != 'Canceled' 
                                     order by StartDateTime DESC Limit 1];
            if(eventlst.size() > 0)
            {
                acc.Last_SCI_Date__c = eventlst[0].StartDateTime;
            }else{
                acc.Last_SCI_Date__c = null;
            }
            //Adding Customer Sentiment Logic to avoid impact of Account Trigger Bypass - IBA-6521-Start
            // CR # 5201 START
            Date lastMeetingDateWithTime = acc.Last_SCI_Date__c != null ? Date.valueOf(acc.Last_SCI_Date__c) : null; 
            Date lastMeetingDateWithoutTime = lastMeetingDateWithTime != null ? Date.newInstance(lastMeetingDateWithTime.year(), lastMeetingDateWithTime.month(), lastMeetingDateWithTime.day()) : null;
            if (lastMeetingDateWithoutTime == null || lastMeetingDateWithoutTime.daysBetween(Date.today()) > 90) {
                acc.Customer_Sentiment__c = 'No Engagement';
            } else if (lastMeetingDateWithoutTime.daysBetween(Date.today()) >= 0 && lastMeetingDateWithoutTime.daysBetween(Date.today()) <= 90 && 'No Engagement'.equalsIgnoreCase(acc.Customer_Sentiment__c)) {
                acc.Customer_Sentiment__c = 'Unknown'; 
            }               
            // CR# 5201 END
            // IBA-6521-End
            
            String Stage1 = label.Stage_7_Closed_Lost;
            List<String> StageList = new List<String>(); 
            StageList.add(Stage1);
            
            //Changes Added by Gurjinder : CR# 620 : Start
            List<Value_Creation_Engagements__c>  VCElst = [select Id, Link_to_Value_Output__c from Value_Creation_Engagements__c where Link_to_Account__c=:acc.Id order by createddate DESC];
            if(VCElst.size() > 0){
                for(Value_Creation_Engagements__c VCE:VCElst){
                    if(VCE.Link_to_Value_Output__c!=null && VCE.Link_to_Value_Output__c!=oldlinktovalueoutput)
                    {
                        acc.Link_to_Value_Output__c = VCE.Link_to_Value_Output__c;
                        break;
                    }else if (VCE.Link_to_Value_Output__c!=null && VCE.Link_to_Value_Output__c==oldlinktovalueoutput){
                        break;
                    }
                }
            }
            //Changes Added by Gurjinder : CR# 620 : End
            
            TriggerUtility.accTerritoryPatchExecuted();
            TriggerUtility.accSalesTeamExecuted();
            if(oldrampedusers != acc.Number_of_Ramped_Users__c 
                || oldhs != acc.Head_of_Security__c 
                || oldhn != acc.Head_of_Networking__c 
                || oldit != acc.Head_of_IT__c 
                || oldserviceowner != acc.Service_Owner_Present__c 
                || oldlastsci != acc.Last_SCI_Date__c 
                || oldlinktovalueoutput != acc.Link_to_Value_Output__c){
                    //IBA-6521-Start
                    TriggerHandler.bypass('AccountTriggerHandler');
                    update acc;  
                    TriggerHandler.clearBypass('AccountTriggerHandler');
                    //IBA-6521-End
                    successlst.add(acc.Id);
                }
        }catch(Exception e){
            errorlst.add('Exception on acc:' + acc.Id + '. Exception is ' + e);
            //updated by Akash 1: CR# 5023 start
            ZscalerErrorLogsUtility.insertlogsForAsync('Rollup_Key_Fields_To_Account', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud',  e.getStackTraceString(), e.getMessage(), e.getTypeName());
            //updated by Akash 1: CR# 5023 end
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
            mail1.setSubject('Account CSM fields Rollup Failure result');
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
            mail.setSubject('Account CSM fields Rollup Success result ');
            mail.setPlainTextBody('Account CSM fields Rollup has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        if(!Test.isRunningTest()){
            Messaging.sendEmail(messageList);
        }
    }
    
}