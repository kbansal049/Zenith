/*****************************************************************************************
Name: CreateAccExtension
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to create Account Exxtension for Accounts
2. Batch class to update Account Exxtension for Accounts

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Gurjinder          16Dec-2019      Initial Development
******************************************************************************************/

public class CreateAccExtension implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CreateAccExtension');
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        
        String query = 'Select id,Account__c,Date_of_Last_CS_Management_Notes__c,CS_Management_Notes__c,Account__r.CS_Management_Notes__c,Account__r.Date_of_Last_CS_Management_Notes__c,Date_of_Last_Customer_business_objective__c,Customer_s_Business_Objectives__c,Account__r.Summarize_the_Value_to_the_Customer__c,Account__r.Date_of_Last_Customer_business_objective__c,Date_of_Last_Customer_History_Next_Steps__c,Customer_Next_Steps__c,Account__r.Customer_Next_Steps__c,Account__r.Date_of_Last_Customer_History_Next_Steps__c,Date_of_Architecture_Workshop_Link__c,Architecture_Workshop_Link__c,Account__r.Architecture_Workshop_Link__c,Account__r.Last_Architecture_Workshop_Date__c,Date_of_QBR_Link__c,QBR_Link__c,Account__r.Last_QBR_Date__c,Account__r.ZSR_Link__c from Account_Extension__c';
        return Database.getQueryLocator(query);
    }
    
    public void execute (Database.BatchableContext context, List<Account_Extension__c> AccExtList){
        try{
            this.zb.callExecute(AccExtList[0]?.Id, AccExtList.size());
            if(AccExtList.size()>0){
                for(Account_Extension__c AccExt:AccExtList){
                    AccExt.Date_of_Architecture_Workshop_Link__c=AccExt.Account__r.Last_Architecture_Workshop_Date__c;
                    AccExt.Architecture_Workshop_Link__c=AccExt.Account__r.Architecture_Workshop_Link__c;
                    
                    AccExt.Date_of_Last_CS_Management_Notes__c=AccExt.Account__r.Date_of_Last_CS_Management_Notes__c;
                    AccExt.CS_Management_Notes__c=AccExt.Account__r.CS_Management_Notes__c;
                    
                    AccExt.Date_of_Last_Customer_business_objective__c=AccExt.Account__r.Date_of_Last_Customer_business_objective__c;
                    AccExt.Customer_s_Business_Objectives__c=AccExt.Account__r.Summarize_the_Value_to_the_Customer__c;
                    
                    AccExt.Date_of_Last_Customer_History_Next_Steps__c=AccExt.Account__r.Date_of_Last_Customer_History_Next_Steps__c;
                    AccExt.Customer_Next_Steps__c=AccExt.Account__r.Customer_Next_Steps__c;
                    
                    //AccExt.Date_of_Architecture_next_step__c=Date.valueOf(System.now());
                    //AccExt.Architecture_next_step__c=AccExt.Account__r.Architecture_next_step__c;
                    
                    AccExt.Date_of_QBR_Link__c=AccExt.Account__r.Last_QBR_Date__c;
                    AccExt.QBR_Link__c=AccExt.Account__r.ZSR_Link__c;
                }
            }
            
            if(!AccExtlist.isempty() && AccExtlist.size()>0){
                update AccExtlist;
            }
        }catch(Exception e){
            
        }
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
    } 
    
}