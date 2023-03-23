/*****************************************************************************************
Name: UpdateRollupDetailsonCampaigns
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to update rollup information on Campaigns

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Gurjinder         	 18Dec-2019       Initial Development
2.0            Akash Thakur          09July-2022      CR# 5023 Added Batch Job Monitoring Code
******************************************************************************************/

public class UpdateRollupDetailsonCampaigns implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateRollupDetailsonCampaigns');
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    String rt_Marketing = L2O_Constants.CampaignObject.RT_MARKETING;
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        String query = 'Select Id,Count_of_MCI_s__c from Campaign Where RecordType.DeveloperName =:rt_Marketing';
        return Database.getQueryLocator(query);
    }
    
    public void execute (Database.BatchableContext context, List<Campaign> CmpgnList){
        this.zb.callExecute(CmpgnList[0]?.Id, CmpgnList.size());
        
        Campaign Cmpgn = CmpgnList[0];
        decimal MCICount = [Select count() from CampaignMember Where Campaignid=:Cmpgn.id AND HasResponded=true];
        try{
            if(cmpgn.Count_of_MCI_s__c!=MCICount){
                Cmpgn.Count_of_MCI_s__c = MCICount;
                TriggerHandler.bypass('CampaignTriggerHandler');
                update cmpgn;
                TriggerHandler.clearBypass('CampaignTriggerHandler');
                successlst.add(cmpgn.Id);
            }
        }catch(Exception e){
            errorlst.add('Exception on Cmpgn:' + cmpgn.Id + '. Exception is ' + e);
            ZscalerErrorLogsUtility.insertlogsForAsync('UpdateRollupDetailsonCampaigns', 'execute', 'Async Apex',userInfo.getUserId(), 'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());

        }
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);     
    }
    
}