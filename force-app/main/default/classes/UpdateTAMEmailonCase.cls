/*****************************************************************************************
Name: UpdateTAMEmailonCase
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to update TAM Emails on Case from related Account

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Gurjinder          16Dec-2019      Initial Development
******************************************************************************************/

public class UpdateTAMEmailonCase implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateTAMEmailonCase');
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    String query='';
    String rectype='';
    
    public UpdateTAMEmailonCase(String batchquery,String Caserectype){
        query=batchquery;
        rectype=Caserectype;
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        //recordtype.Name="Support" and
        //id caseid='5000g00001o9ick';
        //String query = 'Select Id,Accountid,Account.X3rd_TAM_Name__r.email,Account.TAM_Name_New__r.email,Account.Secondary_TAM_Name__r.email,Primary_TAM_Email__c,X3rd_TAM_Email__c,Secondary_TAM_Email__c from Case where id=:caseid';
        String finalquery=query +' where recordtype.developerName=:rectype';
        system.debug('finalquery  '+finalquery);
        return Database.getQueryLocator(finalquery);
    }

    public void execute (Database.BatchableContext context, List<Case> CaseList){
        this.zb.callExecute(CaseList[0]?.Id, CaseList.size());
        if(CaseList.size()>0){
            for(Case cs:CaseList){
                if(cs.Account.X3rd_TAM_Name__c!=null){
                    cs.X3rd_TAM_Email__c=cs.Account.X3rd_TAM_Name__r.email;
                }
                if(cs.Account.TAM_Name_New__c!=null){
                    cs.Primary_TAM_Email__c=cs.Account.TAM_Name_New__r.email;
                }
                if(cs.Account.Secondary_TAM_Name__c!=null){
                    cs.Secondary_TAM_Email__c=cs.Account.Secondary_TAM_Name__r.email;
                }
            }
        }
        try{
          if(CaseList.size()>0){
                    TriggerUtility.CaseBeforeUpdateExecuted();
                    TriggerUtility.CaseAfterUpdateExecuted();
                    update CaseList;
                    //successlst.add(cmpgn.Id);
                }
        }catch(Exception e){
            
        }
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);  
    } 
    
}