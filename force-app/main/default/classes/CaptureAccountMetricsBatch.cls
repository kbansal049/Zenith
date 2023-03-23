/*****************************************************************************************
Name: CaptureAccountMetricsBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to compute below metrics on account.
#F2F Meetings
Last F2F Meeting
Last QBR Date
Active POC
Other Touches
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            21-Oct-2015    Initial Development
2.0            Parth Doshi          29-May-2020    Remove SCI Dependencies for Links CR# 362
3.0            Parth Doshi          11-Jun-2020    Remove SCI Dependencies, Include Event CR# 349 
******************************************************************************************/


global class CaptureAccountMetricsBatch implements Database.Batchable<sObject>, Database.Stateful{
    //updated by Akash 1: CR# 5023 start
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CaptureAccountMetricsBatch');
    
    //updated by Akash 1: CR# 5023 end
    global Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator('SELECT Id FROM Account WHERE type in ( \''+L2O_Constants.AccountType.ACCOUNT_TYPE_CUSTOMER+'\','+'\''+L2O_Constants.AccountType.ACCOUNT_TYPE_EX_CUSTOMER+'\','+'\''+L2O_Constants.AccountType.ACCOUNT_TYPE_PROSPECT+'\')');
    }
    
    global void execute (Database.BatchableContext context, List<sObject> accountList){
        Set<Id> accIdSet = new set<Id>();
        map<Id, set<id>> accIdSCIIdSetMap = new map<id, Set<Id>>();
        map<Id, set<id>> accIdDemoSCIIdSetMap = new map<id, Set<Id>>();
        map<Id, set<id>> accIdTaskIdSetMap = new map<id, Set<Id>>();
        map<id, date> accLastF2FSCIDateMap = new map<id, date>();
        map<id, date> accLastSCIDateMap = new map<id, date>();
        map<id, date> accLastQBRDateMap = new map<id, date>();
        map<id, Event> acclatestzsrmap = new map<id, Event>();
        map<id, Event> acclatestarchsessionmap = new map<id, Event>();
        map<id, date> accLastDemoDateMap = new map<id, date>();
        map<Id, decimal> accIdOpenPipelineMap = new map<Id, Decimal>();
        map<Id, decimal> scislast6months = new map<Id, Decimal>();
        map<Id, decimal> scislast12months = new map<Id, Decimal>();
        map<Id, decimal> allscis = new map<Id, Decimal>();
        map<Id, decimal> f2flast6months = new map<Id, Decimal>();
        map<Id, decimal> f2flast12months = new map<Id, Decimal>();
        map<Id, decimal> allf2fs = new map<Id, Decimal>();
        map<Id, decimal> MCICountmap = new map<Id, Decimal>(); //Added by Gurjinder to count Active MCI
        map<Id, decimal> MCIlast6monthsCount = new map<Id, Decimal>(); //Added by Gurjinder to count last 6 months MCI
        
        this.zb.callExecute(accountList[0]?.Id, accountList.size());
        
        //CR# 349
        DateTime currentTimeStamp = System.Now();
        
        //CR#190 Viral
        Date PFQ_StartDate = [Select StartDate,EndDate From Period Where type = 'Quarter' and StartDate = LAST_FISCAL_QUARTER].StartDate;
        
        list<Account> accUpdateList = new list<Account>();
        for(sObject acc : accountList ){
            accIdSet.add((Id)acc.get('Id'));
        }
       
        try{
            
            for(Opportunity opp : [Select Id, AccountId, Amount, CloseDate from Opportunity Where CloseDate != null AND CloseDate > Today AND AccountId IN: accIdSet AND IsClosed =: false AND StageName != '0 - Initial Prospecting']){
                decimal tempAmnt = 0;
                if(opp.Amount != null)
                    tempAmnt += opp.Amount;
                if(accIdOpenPipelineMap.containsKey(Opp.AccountId)){
                    tempAmnt += accIdOpenPipelineMap.get(Opp.AccountId);
                }
                accIdOpenPipelineMap.put(Opp.AccountId, tempAmnt);
            }
            
            
            
            for(Event sci: [Select Id, CreatedDate, Method_of_Interaction__c, accountId, ActivityDate, EndDateTime, StartDateTime, Type from Event where accountId IN: accIdSet and StartDateTime < :currentTimeStamp and peopleai__MeetingStatus__c != 'Canceled']){
                if(sci.accountId != null && allscis.containsKey(sci.accountId)){
                    allscis.put(sci.accountId, allscis.get(sci.accountId) + 1);
                }else if(sci.accountId != null){
                    allscis.put(sci.accountId, 1);
                }
                if(sci.ActivityDate != null && sci.ActivityDate >= date.today().addmonths(-6)){
                    if(sci.accountId != null && scislast6months.containsKey(sci.accountId)){
                        scislast6months.put(sci.accountId, scislast6months.get(sci.accountId) + 1);
                    }else if(sci.accountId != null){
                        scislast6months.put(sci.accountId, 1);
                    }
                }
                if(sci.ActivityDate != null && sci.ActivityDate >= date.today().addmonths(-12)){
                    if(sci.accountId != null && scislast12months.containsKey(sci.accountId)){
                        scislast12months.put(sci.accountId, scislast12months.get(sci.accountId) + 1);
                    }else if(sci.accountId != null){
                        scislast12months.put(sci.accountId, 1);
                    }
                }
                
                if(sci.Method_of_Interaction__c == 'Face to Face' && sci.Type != System.Label.Other_Marketing_CXO_Event){
                    if(sci.accountId != null && allf2fs.containsKey(sci.accountId)){
                        allf2fs.put(sci.accountId, allf2fs.get(sci.accountId) + 1);
                    }else if(sci.accountId != null){
                        allf2fs.put(sci.accountId, 1);
                    }
                    if(sci.ActivityDate != null && sci.ActivityDate >= date.today().addmonths(-6)){
                        if(sci.accountId != null && f2flast6months.containsKey(sci.accountId)){
                            f2flast6months.put(sci.accountId, f2flast6months.get(sci.accountId) + 1);
                        }else if(sci.accountId != null){
                            f2flast6months.put(sci.accountId, 1);
                        }
                    }
                    if(sci.ActivityDate != null && sci.ActivityDate >= date.today().addmonths(-12)){
                        if(sci.accountId != null && f2flast12months.containsKey(sci.accountId)){
                            f2flast12months.put(sci.accountId, f2flast12months.get(sci.accountId) + 1);
                        }else if(sci.accountId != null){
                            f2flast12months.put(sci.accountId, 1);
                        }
                    }
                }
            }
            
            set<Id> tempIdSet = new set<Id>();
            
            for(Event sci: [Select Id,CreatedDate, Method_of_Interaction__c, accountId, ActivityDate, EndDateTime, StartDateTime, Type from Event where accountId IN: accIdSet and ActivityDate = LAST_N_DAYS:90 and StartDateTime < :currentTimeStamp and peopleai__MeetingStatus__c != 'Canceled' order by ActivityDate DESC]){
                if(sci.Type ==  System.Label.Other_Regular_Meeting && sci.Method_of_Interaction__c == 'Face to Face'){
                    tempIdSet = new set<Id>();
                    if(accIdSCIIdSetMap.containsKey(sci.accountId)){
                        tempIdSet = accIdSCIIdSetMap.get(sci.accountId);
                        tempIdSet.add(sci.Id);
                        accIdSCIIdSetMap.put(sci.accountId,tempIdSet);
                    }else{
                        tempIdSet.add(sci.Id);
                        accIdSCIIdSetMap.put(sci.accountId,tempIdSet);
                    }
                }else if(sci.Type == System.Label.Other_Regular_Meeting && sci.Method_of_Interaction__c == 'Remote'){
                    tempIdSet = new set<Id>();
                    if(accIdDemoSCIIdSetMap.containsKey(sci.accountId)){
                        tempIdSet = accIdDemoSCIIdSetMap.get(sci.accountId);
                        tempIdSet.add(sci.Id);
                        accIdDemoSCIIdSetMap.put(sci.accountId,tempIdSet);
                    }else{
                        tempIdSet.add(sci.Id);
                        accIdDemoSCIIdSetMap.put(sci.accountId,tempIdSet);
                    }
                }  
            }
            
            for(Event sci: [Select Id,CreatedDate, Method_of_Interaction__c, accountId, ActivityDate, EndDateTime, StartDateTime, Type from Event where accountId IN: accIdSet AND (Type = :System.Label.Other_Regular_Meeting or Type = :System.Label.Post_Sale_Operational_Review or Type = :System.Label.Post_Sale_Executive_Review ) AND Method_of_Interaction__c = 'Face to Face' and StartDateTime < :currentTimeStamp and peopleai__MeetingStatus__c != 'Canceled' order by ActivityDate DESC NULLS LAST]){
                if(sci.ActivityDate != null){
                    if(!accLastF2FSCIDateMap.containsKey(sci.accountId)){
                        accLastF2FSCIDateMap.put(sci.accountId, sci.ActivityDate);
                    }
                }
            }
            
            for(Event sci: [Select Id,CreatedDate, Method_of_Interaction__c, accountId, ActivityDate, EndDateTime, StartDateTime, Type from Event where accountId IN: accIdSet AND (Type = :System.Label.Other_Regular_Meeting) and StartDateTime < :currentTimeStamp and peopleai__MeetingStatus__c != 'Canceled' order by ActivityDate DESC NULLS LAST]){
                if(sci.ActivityDate != null){
                    if(!accLastSCIDateMap.containsKey(sci.accountId)){
                        accLastSCIDateMap.put(sci.accountId, sci.ActivityDate);
                    }
                }
            }
            
            
            // Added by Mahesh T --Post Sale - CSM Kick Off Meeting for CR# 2471,2605
            for(Event sci: [Select Id,CreatedDate, Method_of_Interaction__c, accountId, ActivityDate, EndDateTime, StartDateTime, Type,peopleai__MeetingStatus__c from Event where accountId IN: accIdSet AND (Type = :System.Label.Post_Sale_Operational_Review or Type = :System.Label.Post_Sale_Executive_Review or Type = :System.Label.VO_Architecture_Workshop or Type = :System.Label.Post_Sale_CSM_Kick_Off_Meeting) and StartDateTime < :currentTimeStamp and peopleai__MeetingStatus__c != 'Canceled' order by ActivityDate DESC NULLS LAST]){
                if(( sci.Type == System.Label.Post_Sale_Operational_Review || sci.Type == System.Label.Post_Sale_Executive_Review|| sci.Type == System.Label.Post_Sale_CSM_Kick_Off_Meeting)&& (sci.peopleai__MeetingStatus__c == 'Completed')){	//Updated by Ayush Kangar as part of CR#4806
                    if(sci.ActivityDate != null){
                        if(!accLastQBRDateMap.containsKey(sci.accountId)){
                            accLastQBRDateMap.put(sci.accountId, sci.ActivityDate);
                        }
                    }
                      
                    if(!acclatestzsrmap.containsKey(sci.accountId)){
                        acclatestzsrmap.put(sci.accountId, sci);
                    }else{
                        if(sci.ActivityDate > acclatestzsrmap.get(sci.accountId).ActivityDate)
                            acclatestzsrmap.put(sci.accountId, sci);
                    }
                }else{
                    if(!acclatestarchsessionmap.containsKey(sci.accountId)){
                        acclatestarchsessionmap.put(sci.accountId, sci);
                    }else{
                        if(sci.ActivityDate > acclatestarchsessionmap.get(sci.accountId).ActivityDate)
                            acclatestarchsessionmap.put(sci.accountId, sci);
                    }
                }
            }
            
            // Commented by Parth Doshi on 5/30/2020 CR# 349
            
            for(Event sci: [Select Id,CreatedDate, Method_of_Interaction__c, accountId, ActivityDate, EndDateTime, StartDateTime, Type from Event where accountId IN: accIdSet AND Type =: 'Regular Meeting' And Method_of_Interaction__c =: 'Remote' and StartDateTime < :currentTimeStamp and peopleai__MeetingStatus__c != 'Canceled' order by ActivityDate DESC NULLS LAST]){
                if(sci.ActivityDate != null){
                    if(!accLastDemoDateMap.containsKey(sci.accountId)){
                        accLastDemoDateMap.put(sci.accountId, sci.ActivityDate);
                    }
                }
            }
            
            for(Task ts : [Select WhatId, Id from Task Where WhatId IN: accIdSet AND CreatedDate = LAST_N_DAYS:90]){
                
                tempIdSet = new set<Id>();
                if(accIdTaskIdSetMap.containsKey(ts.WhatId)){
                    tempIdSet = accIdTaskIdSetMap.get(ts.WhatId);
                    tempIdSet.add(ts.Id);
                    accIdTaskIdSetMap.put(ts.WhatId,tempIdSet);
                }else{
                    tempIdSet.add(ts.Id);
                    accIdTaskIdSetMap.put(ts.WhatId,tempIdSet);
                }
            }
            
            
            
            
            
            //Update the Count of Active MCI(Campaign Member) :Added by Gurjinder:Start
            
            for(CampaignMember CmpgnMem : [Select Id,Account__c,createddate,First_Associate_Date__c 
                                           from CampaignMember Where Account__c IN:accIdSet AND IsDeleted=false])
            {
                decimal MCIcount=0;
                if(MCICountmap.containskey(CmpgnMem.Account__c)){
                    MCIcount=MCICountmap.get(CmpgnMem.Account__c);
                    MCIcount++;
                    MCICountmap.put(CmpgnMem.Account__c,MCIcount);
                }else{
                    MCIcount++;
                    MCICountmap.put(CmpgnMem.Account__c,MCIcount);
                }
                
                //CR#190 Viral check :: Last_FQ + Today
                //Update the Count of Last 6 months MCI(Campaign Member):Start
                if(CmpgnMem.First_Associate_Date__c != null && CmpgnMem.First_Associate_Date__c >= PFQ_StartDate ){
                    if(CmpgnMem.Account__c != null && MCIlast6monthsCount.containsKey(CmpgnMem.Account__c)){
                        MCIlast6monthsCount.put(CmpgnMem.Account__c, MCIlast6monthsCount.get(CmpgnMem.Account__c) + 1);
                    }else if(CmpgnMem.Account__c != null ){
                        MCIlast6monthsCount.put(CmpgnMem.Account__c, 1);
                    }
                }
                //Update the Count of Last 6 months MCI(Campaign Member):End
                
            }
            //Aditya RollUp for zscalerCloudList
            List<Zscaler_Cloud_ID__c > zScalerCloudList =  [SELECT Account__c,RecordType.Name,DLP_Blocked_L30D__c,Transactions_L90D__c,Avg_Estimated_Users_L31D__c, Total_SSL_Inspected_Transactions__c,Total_number_of_IPSec_tunnels__c,Number_of_GRE_tunnels__c,O365_Transactions_L90D__c,cloud_type__c FROM Zscaler_Cloud_ID__c WHERE Account__c IN :accIdSet AND isDeleted = False];
            Map<Id, List<Zscaler_Cloud_ID__c>> zScalerCloudByAccountId = new Map<Id, List<Zscaler_Cloud_ID__c>>();
            
            for(Zscaler_Cloud_ID__c cloudId : zScalerCloudList){
                if(zScalerCloudByAccountId.containsKey(cloudId.Account__c)){
                    zScalerCloudByAccountId.get(cloudId.Account__c).add(cloudId);
                }else{
                    zScalerCloudByAccountId.put(cloudId.Account__c, new List<Zscaler_Cloud_ID__c>());
                    zScalerCloudByAccountId.get(cloudId.Account__c).add(cloudId);
                }
            }
            
            
            //Aditya RollUp for Opportunity
            List<Opportunity> opportunityList =  [SELECT AccountId,Total_ZPA_ACV__c,Renewable_ACV__c,stagename,type FROM Opportunity WHERE AccountId IN :accIdSet];
            Map<Id, List<Opportunity>> opportunityByAccountId = new Map<Id, List<Opportunity>>();
            
            for(Opportunity opp : opportunityList){
                if(opportunityByAccountId.containsKey(opp.AccountId)){   
                    opportunityByAccountId.get(opp.AccountId).add(opp);
                }else{
                    opportunityByAccountId.put(opp.AccountId, new List<Opportunity>());
                    opportunityByAccountId.get(opp.AccountId).add(opp);
                }
            }
            
            //Aditya RollUp Contract_Detail__c
            List<Contract_Detail__c> contractDetailList =  [SELECT Account_Name__c, Quantity__c,product_sku__c,contract_detail_status__c,do_not_aggregate__c FROM Contract_Detail__c WHERE Account_Name__c IN :accIdSet];
            Map<Id, List<Contract_Detail__c>> contractDetailByAccountName = new Map<Id, List<Contract_Detail__c>>();
            
            for(Contract_Detail__c conDetail : contractDetailList){
                if(contractDetailByAccountName.containsKey(conDetail.Account_Name__c)){
                    contractDetailByAccountName.get(conDetail.Account_Name__c).add(conDetail);
                }else{
                    contractDetailByAccountName.put(conDetail.Account_Name__c, new List<Contract_Detail__c>());
                    contractDetailByAccountName.get(conDetail.Account_Name__c).add(conDetail);
                }
            }
            
            //Aditya RollUp Customer_Next_Steps_History__c
            List<Customer_Next_Steps_History__c> custNextStepsHistoryList =  [SELECT Account__c, CreatedDate FROM Customer_Next_Steps_History__c WHERE Account__c IN :accIdSet ORDER BY CreatedDate DESC NULLS LAST LIMIT 1];
            Map<Id, List<Customer_Next_Steps_History__c>> customerHistoryByAccount = new Map<Id, List<Customer_Next_Steps_History__c>>();
            
            for(Customer_Next_Steps_History__c custHistory : custNextStepsHistoryList){
                if(!customerHistoryByAccount.containsKey(custHistory.Account__c)){
                    customerHistoryByAccount.put(custHistory.Account__c, new List<Customer_Next_Steps_History__c>());
                    customerHistoryByAccount.get(custHistory.Account__c).add(custHistory);
                }
            }
            
            
            
            //Aditya RollUp Egress_Location__c
            List<Egress_Location__c> egressLocList =  [SELECT Account__c, isDeleted FROM Egress_Location__c WHERE Account__c IN :accIdSet];
            Map<Id, List<Egress_Location__c>> egressLocByAccount = new Map<Id, List<Egress_Location__c>>();
            
            for(Egress_Location__c egressLocation : egressLocList){
                if(egressLocByAccount.containsKey(egressLocation.Account__c)){
                    egressLocByAccount.get(egressLocation.Account__c).add(egressLocation);
                }else{
                    egressLocByAccount.put(egressLocation.Account__c, new List<Egress_Location__c>());
                    egressLocByAccount.get(egressLocation.Account__c).add(egressLocation);
                }
            }
            //Update the Count of Active MCI(Campaign Member) :Added by Gurjinder:End
            for(id accId: accIdSet){
                Account acc = new Account ();
                acc.Id = accId;
               
                if(accIdSCIIdSetMap.containsKey(accId)){
                    acc.F2F_Meetings__c = (accIdSCIIdSetMap.get(accId)).size();
                }else{
                    acc.F2F_Meetings__c = 0;
                }
                if(accIdDemoSCIIdSetMap.containsKey(accId)){
                    acc.WebEx_Presentations_L12W__c = (accIdDemoSCIIdSetMap.get(accId)).size();
                }else{
                    acc.WebEx_Presentations_L12W__c = 0;
                }
                
                if(accLastF2FSCIDateMap.containsKey(accId)){
                    acc.Last_F2F_Meeting__c = accLastF2FSCIDateMap.get(accId);
                }else{
                    acc.Last_F2F_Meeting__c = null;
                }
                
                if(accLastSCIDateMap.containsKey(accId)){
                    acc.LastRegularSCIdate__c= accLastSCIDateMap.get(accId);
                }else{
                    acc.LastRegularSCIdate__c= null;
                }
                
                if(accLastQBRDateMap.containsKey(accId)){
                    acc.Last_QBR_Date__c = accLastQBRDateMap.get(accId);
                }else{
                    acc.Last_QBR_Date__c = null;
                } 
                if(accIdOpenPipelineMap.containsKey(accId)){
                    acc.Total_Open_Pipeline__c = accIdOpenPipelineMap.get(accId);
                }else{
                    acc.Total_Open_Pipeline__c = 0;
                }
                
                if(scislast6months.containsKey(accId)){
                    acc.SCI_s_in_the_last_6_Months__c = scislast6months.get(accId);
                }
                if(scislast12months.containsKey(accId)){
                    acc.SCI_s_in_the_last_12_Months__c  = scislast12months.get(accId);
                }
                if(allscis.containsKey(accId)){
                    acc.All_time_of_SCI__c = allscis.get(accId);
                }
                if(f2flast6months.containsKey(accId)){
                    acc.F2F_SCI_s_in_the_last_6_Months__c = f2flast6months.get(accId);
                }
                if(f2flast12months.containsKey(accId)){
                    acc.F2F_SCI_s_in_the_last_12_Months__c = f2flast12months.get(accId);
                }
                if(allf2fs.containsKey(accId)){
                    acc.All_time_F2F_of_SCI__c = allf2fs.get(accId);
                }
                
                //CR# 362 - Commended by Parth Doshi - End & CR# 349
                
                if(acclatestarchsessionmap.containsKey(accId)){
                    if(acclatestarchsessionmap.get(accId).ActivityDate != null){
                        acc.Last_Architecture_Workshop_Date__c = acclatestarchsessionmap.get(accId).ActivityDate;
                    }
                   
                }else{
                    acc.Last_Architecture_Workshop_Date__c = null;
                }
                if(MCICountmap.containskey(accId)){
                    acc.Count_of_MCI__c=MCICountmap.get(accId);
                }
                
                if(MCIlast6monthsCount.containsKey(accId)){
                    acc.MCI_s_in_the_last_6_Months__c=MCIlast6monthsCount.get(accId);               
                }
                //Aditya RollUp for zscalerCloudList
                Double dlpBlocksL30D = 0;
                Double transactionsL90D = 0;
                Double estimatedUsersL31D = 0;
                Double sslInspectedTransactions = 0;
                Double ipsecTunnels = 0;
                Double greTunnels = 0;
                Double o365transactionsL90D = 0;
                if(zScalerCloudByAccountId != null && zScalerCloudByAccountId.containsKey(accId)){
                    for(Zscaler_Cloud_ID__c cloudId : zScalerCloudByAccountId.get(accId)){
                        if(cloudId.cloud_type__c == 'ZIA'){
                            if(cloudId.DLP_Blocked_L30D__c != null){
                                dlpBlocksL30D = dlpBlocksL30D + cloudId.DLP_Blocked_L30D__c;
                            }
                            if(cloudId.Transactions_L90D__c != null){
                                transactionsL90D = transactionsL90D + cloudId.Transactions_L90D__c;
                            }
                            if(cloudId.Avg_Estimated_Users_L31D__c != null && cloudId.RecordType.Name =='ZIA Cloud ID'){
                                estimatedUsersL31D = estimatedUsersL31D + cloudId.Avg_Estimated_Users_L31D__c;
                            }
                            if(cloudId.Total_SSL_Inspected_Transactions__c != null){
                                sslInspectedTransactions = sslInspectedTransactions + cloudId.Total_SSL_Inspected_Transactions__c;
                            }
                            if(cloudId.Total_number_of_IPSec_tunnels__c != null){
                                ipsecTunnels = ipsecTunnels + cloudId.Total_number_of_IPSec_tunnels__c;
                            }
                            
                            if(cloudId.O365_Transactions_L90D__c != null){
                                o365transactionsL90D = o365transactionsL90D + cloudId.O365_Transactions_L90D__c;
                            }  
                        } 
                        if(cloudId.Number_of_GRE_tunnels__c != null){
                            greTunnels = greTunnels + cloudId.Number_of_GRE_tunnels__c;
                        }
                    }
                    acc.DLP_Blocks_L30D__c = dlpBlocksL30D;
                    acc.Transactions_L90D__c = transactionsL90D;
                    acc.Avg_estimated_users_L31D__c = estimatedUsersL31D;
                    acc.Total_SSL_Inspected_Transactions__c = sslInspectedTransactions;
                    acc.Total_number_of_IPSec_tunnels__c = ipsecTunnels;
                    acc.Total_number_of_GRE_Tunnel__c = greTunnels;
                    acc.O365_Transactions_L90D__c = o365transactionsL90D;
                }
                
                //Aditya RollUp for Opportunity
                if(opportunityByAccountId != null && opportunityByAccountId.containsKey(accId)){
                    Double totalZPAACV = 0;
                    Double renewableACV = 0;
                    for(Opportunity opp : opportunityByAccountId.get(accId)){
                        if(opp.total_zpa_acv__c != null && opp.stagename != '14 - Closed: Delete Duplicate' && opp.stagename != '13 - Closed & Approved By Finance' && opp.stagename != '12 - Closed With No Decision' && opp.stagename != '11 - Closed Lost'){
                            totalZPAACV = totalZPAACV + opp.Total_ZPA_ACV__c;
                        }
                        if(opp.Renewable_ACV__c != null && opp.type == 'Existing Customer (Renewal)' && opp.stagename != '7 - Closed Lost' && opp.stagename != '6 - Closed Won'){
                            renewableACV = renewableACV + opp.Renewable_ACV__c;
                        }
                    }
                    acc.Open_ZPA_Pipeline_V2__c = totalZPAACV;
                    acc.Open_Renewals__c = renewableACV;
                }
                
                //Aditya RollUp for Contract_Detail__c
                if(contractDetailByAccountName != null && contractDetailByAccountName.containsKey(accId)){
                    Double quantityUsers = 0;
                    Double meQuantityUsers = 0;
                    for(Contract_Detail__c conDetail : contractDetailByAccountName.get(accId)){
                        if(conDetail.Quantity__c != null && conDetail.product_sku__c == 'ZEXT-BW-PREM' && (conDetail.contract_detail_status__c == 'Active' || conDetail.contract_detail_status__c == 'Pending Renewal') && conDetail.do_not_aggregate__c == FALSE){
                            quantityUsers = quantityUsers + conDetail.Quantity__c;   
                        }
                        if(conDetail.Quantity__c != null && conDetail.product_sku__c == 'ZEXT-BW-PREM-ME' && (conDetail.contract_detail_status__c == 'Active' || conDetail.contract_detail_status__c == 'Pending Renewal') && conDetail.do_not_aggregate__c == FALSE){
                            meQuantityUsers = meQuantityUsers + conDetail.Quantity__c;   
                        }
                    }
                    acc.Users_Bandwidth_Surcharge__c = quantityUsers;
                    acc.Users_ME_Band__c = meQuantityUsers;
                }                
                
                //Aditya RollUp Customer_Next_Steps_History__c
                if(customerHistoryByAccount != null && customerHistoryByAccount.containsKey(accId)){
                    acc.Date_of_Last_Customer_History_Next_Steps__c = Date.valueOf(customerHistoryByAccount.get(accId)[0].CreatedDate);
                }
                
                //Aditya RollUp Egress_Location__c
                if(egressLocByAccount != null && egressLocByAccount.containsKey(acc.Id)){
                    Double countEgressLocation;
                    countEgressLocation = (egressLocByAccount.get(accId)).size();
                    acc.Egress_LOcation_Count__c = countEgressLocation; 
                }
                
                accUpdateList.add(acc);
            }
           
            if(!accUpdateList.isEmpty()){
                TriggerHandler.bypass('AccountTriggerHandler');
                database.update(accUpdateList,false);
                TriggerHandler.clearBypass('AccountTriggerHandler');
            }
        }catch(exception e){
            ZscalerErrorLogsUtility.insertlogsForAsync('CaptureAccountMetricsBatch', 'execute', 'Async Apex',userInfo.getUserId(),
                                                       'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
        
    }
    
    
    global void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
    }
}