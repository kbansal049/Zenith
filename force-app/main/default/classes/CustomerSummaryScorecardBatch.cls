global class CustomerSummaryScorecardBatch implements Database.Batchable<sObject>, Database.Stateful{
    global final String query;
    global Account acct;
    global Id acctId;
    global Id csId;
    global Boolean updateAccount = false;
    
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CustomerSummaryScorecardBatch');//IBA-6519
    
    public CustomerSummaryScorecardBatch(String q) {
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        this.zb.callStart();
        
        String updateAcc = Label.Update_Account_Value_Summary_from_CS;
        if(!String.isBlank(updateAcc)){
            if(updateAcc == 'true'){
                updateAccount = true;
            }
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        this.zb.callExecute(scope[0]?.iD, scope.size());
        
        
        Decimal totalTransactions = 0;
        Decimal totalOldTransactions = 0;
        Decimal totalOldBandwidth = 0;
        Decimal totalPolicyViolations = 0;
        Decimal totalBotnet = 0;
        Decimal totalMalware = 0;
        Decimal totalPhishingAttacks = 0;
        Decimal totalEncryptedThreatsBlocks = 0;
        Decimal totalEncryptedtransactions=0;
        Decimal totalEncryptedInspectedtransactions=0;
        Decimal totalOffice365Transactions = 0;
        Integer percentageSSLTrafic = 0;
        Integer percentageSSLInspected = 0;
        Decimal totalLastTransactions = 0;
        Decimal totalLastBandwidth = 0; 
        Decimal totalPreviousTransactions =0;
        Decimal totalPreviousBandwidth = 0;
        Decimal total6MLastTransactions = 0;
        Decimal total6MLastBandwidth = 0;
        Decimal total6MPreviousTransactions = 0;
        Decimal total6MPreviousBandwidth = 0;
        Decimal total12MLastTransactions = 0;
        Decimal total12MLastBandwidth = 0;
        Decimal total12MPreviousTransactions = 0;
        Decimal total12MPreviousBandwidth = 0;
        Decimal totalSSLbytes = 0; 
        Decimal TotalOffice365 = 0; 
        Decimal  SSLinspectedBytes=0;
        Decimal QualifiedSSLInspectedbytes=0;
        Decimal PercentSSLInspectedbytes=0;
        Decimal PercentSSLInspectedTransactions=0;
        //Added by Swathi : 1408 start
        Decimal  totalLastSSLinspectedBytes=0;
        Decimal  total6MLastSSLinspectedBytes=0;
        Decimal  total12MLastSSLinspectedBytes=0;
        Decimal totalLasttotalSSLbytes = 0;
        Decimal total6MLasttotalSSLbytes = 0;
        Decimal total12MLasttotalSSLbytes = 0;
        Decimal totalLastTotalOffice365 = 0;
        Decimal total6MLastTotalOffice365 = 0;
        Decimal total12MLastTotalOffice365 = 0;
        Decimal totalLastQualifiedSSLInspectedbytes=0;
        Decimal total6MLastQualifiedSSLInspectedbytes=0;
        Decimal total12MLastQualifiedSSLInspectedbytes=0;
        Decimal totalLastZIAusers = 0; 
        Decimal totalPreviousZIAusers =0;
        Decimal total6MLastZIAusers = 0;
        Decimal total6MPreviousZIAusers = 0;
        Decimal total12MLastZIAusers = 0;
        Decimal total12MPreviousZIAusers = 0;
        Decimal totalLastZAppDevices = 0; 
        Decimal totalPreviousZAppDevices =0;
        Decimal total6MLastZAppDevices = 0;
        Decimal total6MPreviousZAppDevices = 0;
        Decimal total12MLastZAppDevices = 0;
        Decimal total12MPreviousZAppDevices = 0;
        Decimal totalLastMonthCases = 0;
        Decimal totalLast6MonthCases = 0;
        Decimal totalLast12MonthCases = 0;
        Decimal totalLastZPAusers = 0; 
        Decimal totalPreviousZPAusers =0;
        Decimal total6MLastZPAusers = 0;
        Decimal total6MPreviousZPAusers = 0;
        Decimal total12MLastZPAusers = 0;
        Decimal total12MPreviousZPAusers = 0;
        Decimal maxAuthUsers31D = 0;
        Decimal maxAuthUsers90D = 0;
        //Added by Swathi : 1408 End
        List<Account> accountList = new List<Account>();
        List<Customer_Score_Card__c> customerScorecardList = new List<Customer_Score_card__c>();
        try
        {
            
            TriggerHandler.bypass('AccountTriggerHandler');
            String last3Months = new CustomerSummaryBatchHelper().last3Months(Date.today().month());
            for(sObject s : scope)
            {
                Customer_Score_Card__c customer = (Customer_Score_Card__c)s;
                Account currentAccount = new Account();
                currentaccount.Id = customer.account__c;
                acctId = customer.Account__c;
                
                csId = customer.id;
                customer.Total_Transactions__c = 0.0;
                customer.Total_Policy_Blocks__c = 0.0;
                customer.Total_Botnet_Calls__c = 0.0;
                customer.Total_Malware__c = 0.0; 
                customer.Total_Phishing_Attacks__c = 0.0; 
                customer.Total_Security_Blocks__c = 0.0;
                customer.Total_Transactions_Same_Time__c = 0.0;
                customer.Total_Bandwidth__c = 0.0;
                customer.Total_Bandwidth_Same_Time__c = 0.0;
                customer.Value_Summary_Months__c = '';
                customer.Total_Bandwidth_Growth__c =0.0;
                customer.Total_Transaction_Growth__c = 0.0;
                customer.Traffic_Encrypted__c = '';
                customer.Encrypted_Traffic_Inspected__c = '';
                customer.Encrypted_Threats_Blocked__c = '';
                customer.Account_Auth_Bytes_31D__c = 0.0;//Added by Varun - CR# 2796 
                customer.Account_Auth_Bytes_90D__c = 0.0;
                customer.Total_Bytes_31D__c = 0.0;
                customer.Total_Bytes_90D__c = 0.0;
                customer.Unique_Authenticated_Users_31D__c = 0.0;
                customer.Unique_Authenticated_Users_90D__c = 0.0;//Added by Varun - CR# 2796 
                boolean noDataflag = true;
                boolean nottoomuchData = true;
                
                List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
                List<Cloud_Usage__c> usageListOld = new List<Cloud_Usage__c>();
                List<Cloud_Usage__c> lastAndPreviousMonthList = new List<Cloud_Usage__c>();
                List<Cloud_Usage__c> lastAnd6MonthList = new List<Cloud_Usage__c>();
                List<Cloud_Usage__c> lastAnd12MonthList = new List<Cloud_Usage__c>();
                List<Cloud_Usage__c> last31DaysUsage = new List<Cloud_Usage__c>();//Added by Varun - CR# 2796 
                List<Cloud_Usage__c> last90DaysUsage = new List<Cloud_Usage__c>();//Added by Varun - CR# 2796
                //Added by Swathi : 1408 start
                List<Zscaler_Cloud_ID__c> lastAndPreviousMonthcloudList = new List<Zscaler_Cloud_ID__c>();
                List<Zscaler_Cloud_ID__c> lastAnd6MonthCloudList = new List<Zscaler_Cloud_ID__c>();
                List<Zscaler_Cloud_ID__c> lastAnd12MonthCloudList = new List<Zscaler_Cloud_ID__c>();
                List<Case> lastAndPreviousCaselist = new List<Case>();
                List<Case> lastAnd6CaseList = new List<Case>();
                List<Case> lastAnd12CaseList = new List<Case>();
                //Added by Swathi : 1408 end
                
                nottoomuchData = new CustomerSummaryBatchHelper().checkNotTooMuchData(customer.Account__r.Id);
                Date dateToday = Date.today();
                Date thisMonth = dateToday.toStartOfMonth();
                date months18Ago = thisMonth.addMonths(-18);
                if(nottoomuchData)
                {
                    usageList = new CustomerSummaryBatchHelper().usage(currentAccount);
                    usageListOld = new CustomerSummaryBatchHelper().oldUsage(currentAccount);
                    lastAndPreviousMonthList = new CustomerSummaryBatchHelper().getLastAndPreviousMonthUsage(currentAccount);
                    lastAnd6MonthList = new CustomerSummaryBatchHelper().getLastAnd6MonthUsage(currentAccount);
                    lastAnd12MonthList = new CustomerSummaryBatchHelper().getLastAnd12MonthUsage(currentAccount);
                    last31DaysUsage = new CustomerSummaryBatchHelper().usage31Days(currentAccount);//Added by Varun - CR# 2796
                    last90DaysUsage = new CustomerSummaryBatchHelper().usage90Days(currentAccount);//Added by Varun - CR# 2796
                    //Added by Swathi : 1408 start
                    lastAndPreviousMonthcloudList = new CustomerSummaryBatchHelper().getLastAndPreviousMonthcloudUsage(currentAccount);
                    lastAnd6MonthCloudList = new CustomerSummaryBatchHelper().getLastAnd6MonthcloudUsage(currentAccount);
                    lastAnd12MonthCloudList = new CustomerSummaryBatchHelper().getLastAnd12MonthcloudUsage(currentAccount);
                    lastAndPreviousCaselist = new CustomerSummaryBatchHelper().getLastAndPreviousMonthCaseDetails(currentAccount);
                    lastAnd6CaseList = new CustomerSummaryBatchHelper().getLastAnd6CaseDetails(currentAccount);
                    lastAnd12CaseList = new CustomerSummaryBatchHelper().getLastAnd12MonthCaseDetail(currentAccount);
                    //Added by Swathi : 1408 start
                    
                }
                
                if(usageListOld.size() > 0)
                {
                    for(Cloud_Usage__c cloudUsageOld : usageListOld)
                    {
                        totalOldTransactions = (cloudUsageOld.Total_Transactions__c != null ? cloudUsageOld.Total_Transactions__c : 0) +totalOldTransactions;
                        totalOldBandwidth = totalOldBandwidth + cloudUsageOld.Total_Transactions_Bandwidth__c;
                    }
                    customer.Total_Transactions_Same_Time__c = totalOldTransactions;
                    customer.Total_Bandwidth_Same_Time__c = totalOldBandwidth;
                    customer.Total_Transactions_Same_Time_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Transactions_Same_Time__c));
                    customer.Total_Bandwidth_Same_Time_Text__c = new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth_Same_Time__c)+' TB';
                }
                
                Date today = Date.today();
                Date lastStartDate, lastEndDate, previousStartDate, previousEndDate;
                Map<String, List<Datetime>> mapLastAndPreviousMonthDateRange = CustomerSummaryBatchHelper.LastAndPreviousMonthRange(today.month(), today.year());
                lastStartDate = mapLastAndPreviousMonthDateRange.get('last')[0].date();
                lastEndDate = mapLastAndPreviousMonthDateRange.get('last')[1].date();
                previousStartDate = mapLastAndPreviousMonthDateRange.get('previous')[0].date();
                previousEndDate = mapLastAndPreviousMonthDateRange.get('previous')[1].date();
                
                
                
                for (Cloud_Usage__c usage : lastAndPreviousMonthList) {
                    if (lastStartDate <= usage.Usage_Pull_Date__c
                        && lastEndDate >= usage.Usage_Pull_Date__c)
                    {
                        //Added by Swathi : 1408 start
                        totalLastTransactions = (usage.Total_Transactions__c != null ? usage.Total_Transactions__c : 0) + totalLastTransactions;
                        totalLastBandwidth = (usage.Total_Transactions_Bandwidth__c != null ? usage.Total_Transactions_Bandwidth__c : 0) + totalLastBandwidth;
                        //Added by Swathi : 1408 End
                    } else if (previousStartDate <= usage.Usage_Pull_Date__c
                               && previousEndDate >= usage.Usage_Pull_Date__c) 
                    {
                        //Added by Swathi : 1408 start
                        totalPreviousTransactions = (usage.Total_Transactions__c != null ? usage.Total_Transactions__c : 0) + totalPreviousTransactions;
                        totalPreviousBandwidth = (usage.Total_Transactions_Bandwidth__c != null ? usage.Total_Transactions_Bandwidth__c : 0) + totalPreviousBandwidth;
                        totalLastSSLinspectedBytes = (usage.total_ssl_inspected_bytes__c != null ? usage.total_ssl_inspected_bytes__c : 0)  + totalLastSSLinspectedBytes;
                        totalLasttotalSSLbytes = (usage.total_ssl_bytes__c != null ? usage.total_ssl_bytes__c : 0)  + totalLasttotalSSLbytes;
                        totalLastTotalOffice365 = (usage.Total_Office_365_Kb__c != null ? usage.Total_Office_365_Kb__c : 0)  + totalLastTotalOffice365;
                        //Added by Swathi : 1408 end
                    }
                }
                //Added by Swathi : 1408 start
                totalLastTotalOffice365=totalLastTotalOffice365*1024;
                if(totalLastSSLinspectedBytes != Null && totalLastSSLinspectedBytes != 0 && ((totalLasttotalSSLbytes != Null && totalLasttotalSSLbytes != 0) || (totalLastTotalOffice365 != Null && totalLastTotalOffice365 != 0) )){
                    totalLastQualifiedSSLInspectedbytes = new CustomerSummaryBatchHelper().calculateSimplePercentage(totalLastSSLinspectedBytes,(totalLasttotalSSLbytes-totalLastTotalOffice365));
                    customer.Qualified_SSL_inspected_bytes_LM_1__c = totalLastQualifiedSSLInspectedbytes;
                }
                //Added by Swathi : 1408 End
                if (totalLastTransactions != null && totalPreviousTransactions != null && totalLastTransactions != 0 && totalPreviousTransactions != 0)
                    customer.Transactions_LM_vs_PM__c = new CustomerSummaryBatchHelper().calculatePercentage(totalLastTransactions, totalPreviousTransactions);
                
                if (totalLastBandwidth != null && totalPreviousBandwidth != null && totalLastBandwidth != 0 && totalPreviousBandwidth != 0)
                    customer.Bandwidth_LM_Vs_PM__c = new CustomerSummaryBatchHelper().calculatePercentage(totalLastBandwidth, totalPreviousBandwidth);
                //Added by Swathi : 1408 start
                Decimal numLastmonth = ((totalLastTransactions/1000000000).setscale(1)) ;
                Decimal numLastBefmonth = ((totalPreviousTransactions/1000000000).setscale(1)) ;
                
                for(case caselist: lastAndPreviousCaselist){
                    DateTime datecreated = caselist.CreatedDate;
                    if(lastStartDate <= datecreated.date()
                       && lastEndDate >= datecreated.date()){
                           totalLastMonthCases =  totalLastMonthCases + 1;
                       }
                }
                if (totalLastMonthCases != null && numLastmonth != null && totalLastMonthCases != 0 && numLastmonth != 0)
                    customer.Problem_tickets_per_b_transactions__c = (totalLastMonthCases/numLastmonth);
                if (totalLastMonthCases != null && numLastmonth != null && totalLastMonthCases != 0 && numLastmonth != 0 && numLastBefmonth != null && numLastBefmonth != 0)
                    customer.Problem_tickets_per_b_trans_LM_Vs_LM_1__c = ((totalLastMonthCases/numLastmonth)-(totalLastMonthCases/numLastBefmonth));
                
                for (Zscaler_Cloud_ID__c usage : lastAndPreviousMonthcloudList) {
                    for(BWC_Data__c bwc : usage.BWC_Data__r.isEMpty() ? new List<BWC_Data__c>() : usage.BWC_Data__r){
                        if (lastStartDate <= bwc.Monthly_Usage__c
                            && lastEndDate >= bwc.Monthly_Usage__c)
                        {
                            if(usage.Cloud_Type__c=='ZIA'){
                                totalLastZIAusers = (bwc.X90_Day_Trailing_Unique_Auth_Users__c != null ? bwc.X90_Day_Trailing_Unique_Auth_Users__c : 0 ) + totalLastZIAusers;
                                totalLastZAppDevices = (bwc.Total_Unique_Users__c != null ? bwc.Total_Unique_Users__c : 0 ) + totalLastZAppDevices;
                            }
                            else if(usage.Cloud_Type__c=='ZPA')
                                totalLastZPAusers = (bwc.ZPA_L31d__c!= null ? bwc.ZPA_L31d__c : 0 ) + totalLastZPAusers;
                        } else if (previousStartDate <= bwc.Monthly_Usage__c
                                   && previousEndDate >= bwc.Monthly_Usage__c) 
                        {
                            if(usage.Cloud_Type__c=='ZIA'){
                                totalPreviousZIAusers = (bwc.X90_Day_Trailing_Unique_Auth_Users__c != null ? bwc.X90_Day_Trailing_Unique_Auth_Users__c : 0) + totalPreviousZIAusers;
                                totalPreviousZAppDevices = (bwc.Total_Unique_Users__c != null ? bwc.Total_Unique_Users__c : 0) + totalPreviousZAppDevices;
                            }
                            else if(usage.Cloud_Type__c=='ZPA')
                                totalPreviousZPAusers = (bwc.ZPA_L31d__c != null ? bwc.ZPA_L31d__c : 0) + totalPreviousZPAusers;
                        }
                    }
                }
                
                if (totalLastZPAusers != null && totalPreviousZPAusers != null && totalLastZPAusers != 0 && totalPreviousZPAusers != 0)
                    customer.ZPA_Active_Users_LM_Vs_LM_1__c = Integer.ValueOf(totalLastZPAusers - totalPreviousZPAusers);
                
                if (totalLastZIAusers != null && totalPreviousZIAusers != null && totalLastZIAusers != 0 && totalPreviousZIAusers != 0)
                    customer.Auth_ZIA_users_deployed_LM_Vs_LM_1__c = Integer.ValueOf(totalLastZIAusers - totalPreviousZIAusers);
                
                if (totalLastZAppDevices != null && totalPreviousZAppDevices != null && totalLastZAppDevices != 0 && totalPreviousZAppDevices != 0)
                    customer.Client_connector_users_LM_Vs_LM_1__c = new CustomerSummaryBatchHelper().calculateSimplePercentage(totalLastZAppDevices, totalPreviousZAppDevices);
                //Added by Swathi : 1408 End
                
                Map<String, List<Datetime>> mapLastAnd6MonthDateRange = CustomerSummaryBatchHelper.LastAnd6MonthRange(today.month(), today.year());
                lastStartDate = mapLastAnd6MonthDateRange.get('last')[0].date();
                lastEndDate = mapLastAnd6MonthDateRange.get('last')[1].date();
                previousStartDate = mapLastAnd6MonthDateRange.get('previous')[0].date();
                previousEndDate = mapLastAnd6MonthDateRange.get('previous')[1].date();
                
                for (Cloud_Usage__c usage : lastAnd6MonthList) {
                    if (lastStartDate <= usage.Usage_Pull_Date__c
                        && lastEndDate >= usage.Usage_Pull_Date__c)
                    {
                        total6MLastTransactions = (usage.Total_Transactions__c != null ? usage.Total_Transactions__c : 0 ) + total6MLastTransactions;
                        total6MLastBandwidth = (usage.Total_Transactions_Bandwidth__c != null ? usage.Total_Transactions_Bandwidth__c : 0) + total6MLastBandwidth;
                    } else if (previousStartDate <= usage.Usage_Pull_Date__c
                               && previousEndDate >= usage.Usage_Pull_Date__c) 
                    {
                        total6MPreviousTransactions = (usage.Total_Transactions__c != null ? usage.Total_Transactions__c : 0) + total6MPreviousTransactions;
                        total6MPreviousBandwidth =  (usage.Total_Transactions_Bandwidth__c != null ? usage.Total_Transactions_Bandwidth__c : 0) + total6MPreviousBandwidth;
                        //Added by Swathi : 1408 start
                        total6MLastSSLinspectedBytes = (usage.total_ssl_inspected_bytes__c != null ? usage.total_ssl_inspected_bytes__c : 0)  + total6MLastSSLinspectedBytes;
                        total6MLasttotalSSLbytes = (usage.total_ssl_bytes__c != null ? usage.total_ssl_bytes__c : 0)  + total6MLasttotalSSLbytes;
                        total6MLastTotalOffice365 = (usage.Total_Office_365_Kb__c != null ? usage.Total_Office_365_Kb__c : 0)  + total6MLastTotalOffice365;
                        //Added by Swathi : 1408 end
                    }
                }
                //Added by Swathi : 1408 start
                total6MLastTotalOffice365=total6MLastTotalOffice365*1024;
                if(total6MLastSSLinspectedBytes != Null && total6MLastSSLinspectedBytes != 0 && ((total6MLasttotalSSLbytes != Null && total6MLasttotalSSLbytes != 0) || (total6MLastTotalOffice365 != Null && total6MLastTotalOffice365 != 0) )){
                    total6MLastQualifiedSSLInspectedbytes = new CustomerSummaryBatchHelper().calculateSimplePercentage(total6MLastSSLinspectedBytes,(total6MLasttotalSSLbytes-total6MLastTotalOffice365));
                    customer.Qualified_SSL_inspected_bytes_LM_6__c = total6MLastQualifiedSSLInspectedbytes;
                }
                //Added by Swathi : 1408 end
                if (total6MLastTransactions != null && total6MPreviousTransactions != null && total6MLastTransactions != 0 && total6MPreviousTransactions != 0)
                    customer.Transactions_LM_vs_6M_Ago__c = new CustomerSummaryBatchHelper().calculatePercentage(total6MLastTransactions, total6MPreviousTransactions);
                
                if (total6MLastBandwidth != null && total6MPreviousBandwidth != null && total6MLastBandwidth != 0 && total6MPreviousBandwidth != 0)
                    customer.Bandwidth_LM_Vs_6M_Ago__c = new CustomerSummaryBatchHelper().calculatePercentage(total6MLastBandwidth, total6MPreviousBandwidth);
                //Added by Swathi : 1408 start
                Decimal num6 = ((total6MLastTransactions/1000000000).setscale(1)) ;
                Decimal num6LastBefmonth = ((total6MPreviousTransactions/1000000000).setscale(1)) ;
                
                for(case caselist: lastAnd6CaseList){
                    DateTime datecreated = caselist.CreatedDate;
                    if(lastStartDate <= datecreated.date()
                       && lastEndDate >= datecreated.date()){
                           totalLast6MonthCases =  totalLast6MonthCases + 1;
                       }
                }
                if (totalLast6MonthCases != null && num6 != null && totalLast6MonthCases != 0 && num6 != 0 && num6LastBefmonth != null && num6LastBefmonth != 0)
                    customer.Problem_tickets_per_b_trans_LM_Vs_LM_6__c = ((totalLast6MonthCases/num6)-(totalLast6MonthCases/num6LastBefmonth));
                
                for (Zscaler_Cloud_ID__c usage : lastAnd6MonthCloudList) {
                    for(BWC_Data__c bwc : usage.BWC_Data__r.isEMpty() ? new List<BWC_Data__c>() : usage.BWC_Data__r){
                        if (lastStartDate <= bwc.Monthly_Usage__c
                            && lastEndDate >= bwc.Monthly_Usage__c)
                        {
                            if(usage.Cloud_Type__c=='ZIA'){
                                total6MLastZIAusers = (bwc.X90_Day_Trailing_Unique_Auth_Users__c != null ? bwc.X90_Day_Trailing_Unique_Auth_Users__c : 0 ) + total6MLastZIAusers;
                                total6MLastZAppDevices = (bwc.Total_Unique_Users__c != null ? bwc.Total_Unique_Users__c : 0 ) + total6MLastZAppDevices;
                            }
                            else if(usage.Cloud_Type__c=='ZPA')
                                total6MLastZPAusers = (bwc.ZPA_L31d__c != null ? bwc.ZPA_L31d__c : 0 ) + total6MLastZPAusers;
                        } else if (previousStartDate <= bwc.Monthly_Usage__c
                                   && previousEndDate >= bwc.Monthly_Usage__c) 
                        {
                            if(usage.Cloud_Type__c=='ZIA'){
                                total6MPreviousZIAusers = (bwc.X90_Day_Trailing_Unique_Auth_Users__c != null ? bwc.X90_Day_Trailing_Unique_Auth_Users__c : 0) + total6MPreviousZIAusers;
                                total6MPreviousZAppDevices = (bwc.Total_Unique_Users__c != null ? bwc.Total_Unique_Users__c : 0 ) + total6MPreviousZAppDevices;
                            }
                            else if(usage.Cloud_Type__c=='ZPA')
                                total6MPreviousZPAusers = (bwc.ZPA_L31d__c != null ? bwc.ZPA_L31d__c : 0) + total6MPreviousZPAusers;
                        }
                    }
                }
                
                if (total6MLastZPAusers != null && total6MPreviousZPAusers != null && total6MLastZPAusers != 0 && total6MPreviousZPAusers != 0)
                    customer.ZPA_Active_Users_LM_Vs_LM_6__c = Integer.ValueOf(total6MLastZPAusers - total6MPreviousZPAusers);
                
                if (total6MLastZIAusers != null && total6MPreviousZIAusers != null && total6MLastZIAusers != 0 && total6MPreviousZIAusers != 0)
                    customer.Auth_ZIA_users_deployed_LM_Vs_LM_6__c = Integer.ValueOf(total6MLastZIAusers - total6MPreviousZIAusers);
                
                if (total6MLastZAppDevices != null && total6MPreviousZAppDevices != null && total6MLastZAppDevices != 0 && total6MPreviousZAppDevices != 0)
                    customer.Client_connector_users_LM_Vs_LM_6__c = new CustomerSummaryBatchHelper().calculateSimplePercentage(total6MLastZAppDevices, total6MPreviousZAppDevices);
                //Added by Swathi : 1408 End
                
                
                Map<String, List<Datetime>> mapLastAnd12MonthDateRange = CustomerSummaryBatchHelper.LastAnd12MonthRange(today.month(), today.year());
                lastStartDate = mapLastAnd12MonthDateRange.get('last')[0].date();
                lastEndDate = mapLastAnd12MonthDateRange.get('last')[1].date();
                previousStartDate = mapLastAnd12MonthDateRange.get('previous')[0].date();
                previousEndDate = mapLastAnd12MonthDateRange.get('previous')[1].date();
                
                for (Cloud_Usage__c usage : lastAnd12MonthList) {
                    if (lastStartDate <= usage.Usage_Pull_Date__c
                        && lastEndDate >= usage.Usage_Pull_Date__c) 
                    {
                        total12MLastTransactions = (usage.Total_Transactions__c != null ? usage.Total_Transactions__c : 0) + total12MLastTransactions;
                        total12MLastBandwidth = (usage.Total_Transactions_Bandwidth__c != null ? usage.Total_Transactions_Bandwidth__c : 0) + total12MLastBandwidth;
                    } 
                    else if (previousStartDate <= usage.Usage_Pull_Date__c
                             && previousEndDate >= usage.Usage_Pull_Date__c) 
                    {
                        total12MPreviousTransactions = (usage.Total_Transactions__c != null ? usage.Total_Transactions__c : 0)+total12MPreviousTransactions;
                        total12MPreviousBandwidth = (usage.Total_Transactions_Bandwidth__c != null ? usage.Total_Transactions_Bandwidth__c : 0) + total12MPreviousBandwidth;
                        //Added by Swathi : 1408 start
                        total12MLastSSLinspectedBytes = (usage.total_ssl_inspected_bytes__c != null ? usage.total_ssl_inspected_bytes__c : 0)  + total12MLastSSLinspectedBytes;
                        total12MLasttotalSSLbytes = (usage.total_ssl_bytes__c != null ? usage.total_ssl_bytes__c : 0)  + total12MLasttotalSSLbytes;
                        total12MLastTotalOffice365 = (usage.Total_Office_365_Kb__c != null ? usage.Total_Office_365_Kb__c : 0)  + total12MLastTotalOffice365;
                    }
                }
                total12MLastTotalOffice365=total12MLastTotalOffice365*1024;
                if(total12MLastSSLinspectedBytes != Null && total12MLastSSLinspectedBytes != 0 && ((total12MLasttotalSSLbytes != Null && total12MLasttotalSSLbytes != 0) || (total12MLastTotalOffice365 != Null && total12MLastTotalOffice365 != 0) )){
                    total12MLastQualifiedSSLInspectedbytes = new CustomerSummaryBatchHelper().calculateSimplePercentage(total12MLastSSLinspectedBytes,(total12MLasttotalSSLbytes-total12MLastTotalOffice365));
                    customer.Qualified_SSL_inspected_bytes_LM_12__c = total12MLastQualifiedSSLInspectedbytes;
                }
                //Added by Swathi : 1408 End
                if (total12MLastTransactions != null && total12MPreviousTransactions != null && total12MLastTransactions != 0 && total12MPreviousTransactions != 0)
                    customer.Transactions_LM_vs_12M_Ago__c = new CustomerSummaryBatchHelper().calculatePercentage(total12MLastTransactions, total12MPreviousTransactions);
                
                if (total12MLastBandwidth != null && total12MPreviousBandwidth != null && total12MLastBandwidth != 0&& total12MPreviousBandwidth != 0)
                    customer.Bandwidth_LM_Vs_12M_Ago__c = new CustomerSummaryBatchHelper().calculatePercentage(total12MLastBandwidth, total12MPreviousBandwidth);
                //Added by Swathi : 1408 start
                Decimal num12 = ((total12MLastTransactions/1000000000).setscale(1)) ;
                Decimal num12LastBefmonth = ((total12MPreviousTransactions/1000000000).setscale(1)) ;
                
                for(case caselist: lastAnd12CaseList){
                    DateTime datecreated = caselist.CreatedDate;
                    if(lastStartDate <= datecreated.date()
                       && lastEndDate >= datecreated.date()){
                           totalLast12MonthCases =  totalLast12MonthCases + 1;
                       }
                }
                if (totalLast12MonthCases != null && num12 != null && totalLast12MonthCases != 0 && num12 != 0 && num12LastBefmonth != 0 && num12LastBefmonth !=Null)
                    customer.Problem_ticket_per_b_trans_LM_Vs_LM_12__c = ((totalLast12MonthCases/num12)-(totalLast12MonthCases/num12LastBefmonth));
                
                for (Zscaler_Cloud_ID__c usage : lastAnd12MonthCloudList) {
                    for(BWC_Data__c bwc : usage.BWC_Data__r.isEMpty() ? new List<BWC_Data__c>() : usage.BWC_Data__r){
                        if (lastStartDate <= bwc.Monthly_Usage__c
                            && lastEndDate >= bwc.Monthly_Usage__c)
                        {
                            if(usage.Cloud_Type__c=='ZIA'){
                                total12MLastZIAusers = (bwc.X90_Day_Trailing_Unique_Auth_Users__c != null ? bwc.X90_Day_Trailing_Unique_Auth_Users__c : 0 ) + total12MLastZIAusers;
                                total12MLastZAppDevices = (bwc.Total_Unique_Users__c != null ? bwc.Total_Unique_Users__c : 0 ) + total12MLastZAppDevices;
                            }
                            else if(usage.Cloud_Type__c=='ZPA')
                                total12MLastZPAusers = (bwc.ZPA_L31d__c!= null ? bwc.ZPA_L31d__c : 0 ) + total12MLastZPAusers;
                        } else if (previousStartDate <= bwc.Monthly_Usage__c
                                   && previousEndDate >= bwc.Monthly_Usage__c) 
                        {
                            if(usage.Cloud_Type__c=='ZIA'){
                                total12MPreviousZIAusers = (bwc.X90_Day_Trailing_Unique_Auth_Users__c != null ? bwc.X90_Day_Trailing_Unique_Auth_Users__c : 0) + total12MPreviousZIAusers;
                                total12MPreviousZAppDevices = (bwc.Total_Unique_Users__c != null ? bwc.Total_Unique_Users__c : 0 ) + total12MPreviousZAppDevices;
                            }
                            else if(usage.Cloud_Type__c=='ZPA')
                                total12MPreviousZPAusers = (bwc.ZPA_L31d__c != null ? bwc.ZPA_L31d__c : 0) + total12MPreviousZPAusers;
                        }
                    }
                }
                if (total12MLastZPAusers != null && total12MPreviousZPAusers != null && total12MLastZPAusers != 0 && total12MPreviousZPAusers != 0)
                    customer.ZPA_Active_Users_LM_Vs_LM_12__c = Integer.ValueOf(total12MLastZPAusers - total12MPreviousZPAusers);     
                
                if (total12MLastZIAusers != null && total12MPreviousZIAusers != null && total12MLastZIAusers != 0 && total12MPreviousZIAusers != 0)
                    customer.Auth_ZIA_users_deployed_LM_Vs_LM_12__c = Integer.ValueOf(total12MLastZIAusers - total12MPreviousZIAusers);
                
                if (total12MLastZAppDevices != null && total12MPreviousZAppDevices != null && total12MLastZAppDevices != 0 && total12MPreviousZAppDevices != 0)
                    customer.Client_connector_users_LM_Vs_LM_12__c = new CustomerSummaryBatchHelper().calculateSimplePercentage(total12MLastZAppDevices, total12MPreviousZAppDevices);
                //Added by Swathi : 1408 End
                
                for(Cloud_Usage__c cloudUsage : usageList)
                {  
                    if(cloudUsage.Total_Transactions__c != null)
                        customer.Total_Transactions__c = customer.Total_Transactions__c + cloudUsage.Total_Transactions__c;
                    if(cloudUsage.Total_Transactions_Bandwidth__c != null)
                        customer.Total_Bandwidth__c = customer.Total_Bandwidth__c + cloudUsage.Total_Transactions_Bandwidth__c;
                    if(cloudUsage.Total_Policy_Blocks__c != null)
                        customer.Total_Policy_Blocks__c = customer.Total_Policy_Blocks__c + cloudUsage.Total_Policy_Blocks__c;
                    if(cloudUsage.total_botnet_blocks__c != null)
                        customer.Total_Botnet_Calls__c = customer.Total_Botnet_Calls__c + cloudUsage.total_botnet_blocks__c;
                    if(cloudUsage.total_malware_site_blocks__c  != null)
                        customer.Total_Malware__c = customer.Total_Malware__c + cloudUsage.total_malware_site_blocks__c ;
                    if(cloudUsage.total_phishing_blocks__c  != null)
                        customer.Total_Phishing_Attacks__c = customer.Total_Phishing_Attacks__c  + cloudUsage.total_phishing_blocks__c ;
                    if(cloudUsage.total_security_blocks__c  != null)
                        customer.Total_Security_Blocks__c =  customer.Total_Security_Blocks__c  + cloudUsage.total_security_blocks__c ;
                    
                    totalEncryptedThreatsBlocks = (cloudUsage.Encrypted_Threats_Blocked__c != null ? cloudUsage.Encrypted_Threats_Blocked__c : 0) + totalEncryptedThreatsBlocks;
                    totalEncryptedtransactions = (cloudUsage.total_ssl_transactions__c != null ? cloudUsage.total_ssl_transactions__c : 0) + totalEncryptedtransactions;
                    totalEncryptedInspectedtransactions = (cloudUsage.total_ssl_inspected_transactions__c != null ? cloudUsage.total_ssl_inspected_transactions__c : 0) + totalEncryptedInspectedtransactions;
                    totalOffice365Transactions = (cloudUsage.Total_Office_365_Transactions__c != null ? cloudUsage.Total_Office_365_Transactions__c : 0)  + totalOffice365Transactions;
                    SSLinspectedBytes = (cloudUsage.total_ssl_inspected_bytes__c != null ? cloudUsage.total_ssl_inspected_bytes__c : 0)  + SSLinspectedBytes;
                    totalSSLbytes = (cloudUsage.total_ssl_bytes__c != null ? cloudUsage.total_ssl_bytes__c : 0)  + totalSSLbytes;
                    TotalOffice365 = (cloudUsage.Total_Office_365_Kb__c != null ? cloudUsage.Total_Office_365_Kb__c : 0)  + TotalOffice365;
                    
                }
                
                //Added by Varun -Start- CR# 2796 
                for(Cloud_Usage__c cloudUsage : last31DaysUsage)
                {
                    if(cloudUsage.Authenticated_Kilobytes_del_del__c  != null)
                        customer.Account_Auth_Bytes_31D__c =  customer.Account_Auth_Bytes_31D__c  + cloudUsage.Authenticated_Kilobytes_del_del__c ;
                    if(cloudUsage.Total_Transactions_Bandwidth__c  != null)
                        customer.Total_Bytes_31D__c =  customer.Total_Bytes_31D__c  + cloudUsage.Total_Transactions_Bandwidth__c ;
                    if(cloudUsage.User_Count__c  != null && cloudUsage.User_Count__c>maxAuthUsers31D)
                        maxAuthUsers31D=cloudUsage.User_Count__c;                        
                }
                customer.Unique_Authenticated_Users_31D__c = maxAuthUsers31D ;
                
                for(Cloud_Usage__c cloudUsage : last90DaysUsage)
                {
                    if(cloudUsage.Authenticated_Kilobytes_del_del__c  != null)
                        customer.Account_Auth_Bytes_90D__c =  customer.Account_Auth_Bytes_90D__c  + cloudUsage.Authenticated_Kilobytes_del_del__c ;
                    if(cloudUsage.Total_Transactions_Bandwidth__c  != null)
                        customer.Total_Bytes_90D__c =  customer.Total_Bytes_90D__c  + cloudUsage.Total_Transactions_Bandwidth__c ;
                    if(cloudUsage.User_Count__c  != null && cloudUsage.User_Count__c>maxAuthUsers90D)
                        maxAuthUsers90D = cloudUsage.User_Count__c ;
                }
                customer.Unique_Authenticated_Users_90D__c = maxAuthUsers90D ;
                //Added by Varun -End- CR# 2796 
                TotalOffice365=TotalOffice365*1024;
                
                QualifiedSSLInspectedbytes=new CustomerSummaryBatchHelper().calculateSimplePercentage(SSLinspectedBytes,(totalSSLbytes-TotalOffice365));
                PercentSSLInspectedbytes=new CustomerSummaryBatchHelper().calculateSimplePercentage(SSLinspectedBytes,totalSSLbytes);
                PercentSSLInspectedTransactions=new CustomerSummaryBatchHelper().calculateSimplePercentage(totalEncryptedInspectedtransactions,totalEncryptedtransactions);
                
                customer.Qualified_SSL_Inspected_Bytes__c=QualifiedSSLInspectedbytes;
                customer.SSL_Inspected_Bytes__c=PercentSSLInspectedbytes;
                customer.SSL_Inspected_Transactions__c=PercentSSLInspectedTransactions;
                
                if(Test.isRunningTest() || (customer.Account__r.No_of_Platform_Seats__c > 0 && last3Months != null && nottoomuchData))
                {
                    customer.Value_Summary_Months__c = last3Months;
                    customer.Zscaler_Customer_Summary__c = '<p style="font-size:14px"> Zscaler is protecting <strong>'+Integer.ValueOf(customer.Account__r.No_of_Platform_Seats__c).format()+'</strong> users at <strong>'+customer.Account__r.Name+'</strong>.<br/> '+
                        'Below is the snapshot of value delivered for '+customer.Account__r.Name+' in the last 3 months ('+last3Months+'):<br/><ul style="font-size:14px">';
                    
                    if(customer.Total_Transactions__c != null && customer.Total_Transactions__c > 0.0)
                    {
                        noDataflag = false;
                        customer.Total_Transactions_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Transactions__c));
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Transactions__c))+' transactions processed. </li>';
                    }
                    
                    if(customer.Total_Bandwidth__c != null && customer.Total_Bandwidth__c > 0.0)
                    {
                        noDataflag = false;
                        customer.Total_Bandwidth_Text__c = new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth__c)+' TB';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth__c)+' TB traffic (bandwidth) processed. </li>';
                    }
                    
                    if(totalOldBandwidth > 0 && customer.Total_Bandwidth__c > totalOldBandwidth)
                    {
                        noDataflag = false;
                        Integer growth = new CustomerSummaryBatchHelper().calculatePercentage(customer.Total_Bandwidth__c,customer.Total_Bandwidth_Same_Time__c);
                        customer.Total_Bandwidth_Growth__c = growth;
                        if(growth >= 10 && growth <=1000)
                        {
                            customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> Total traffic from same time last year has grown by '+ new CustomerSummaryBatchHelper().calculatePercentage(customer.Total_Bandwidth__c,customer.Total_Bandwidth_Same_Time__c)+'% - from '+new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth_Same_Time__c)+' TB to '+new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth__c) +' TB.</li>';
                            
                        }
                        else if(growth >1000)
                        {
                            customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> Total traffic from same time last year has grown from '+new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth_Same_Time__c)+' TB to '+new CustomerSummaryBatchHelper().convertToTeraByte(customer.Total_Bandwidth__c) +' TB.</li>';
                        }
                        
                    }
                    
                    if(customer.Total_Policy_Blocks__c != null && customer.Total_Policy_Blocks__c > 0.0)
                    {
                        noDataflag = false;
                        customer.Total_Policy_Blocks_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Policy_Blocks__c));
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Policy_Blocks__c))+' policy violations prevented. </li>';
                    }
                    
                    if(customer.Total_Security_Blocks__c!= null && customer.Total_Security_Blocks__c > 0.0)
                    {
                        noDataflag = false;
                        customer.Total_Security_Blocks_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Security_Blocks__c));
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Security_Blocks__c)) + ' security threats blocked.';//, including <ul>
                        
                        if(customer.Total_Botnet_Calls__c != null && customer.Total_Botnet_Calls__c > 0.0)
                        {
                            customer.Total_Botnet_Calls_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Botnet_Calls__c));
                        }
                        if(customer.Total_Malware__c != null && customer.Total_Malware__c > 0.0)
                        {
                            customer.Total_Malware_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Malware__c));
                        }
                        if(customer.Total_Phishing_Attacks__c != null && customer.Total_Phishing_Attacks__c > 0.0)
                        {
                            customer.Total_Phishing_Attacks_Text__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(customer.Total_Phishing_Attacks__c));
                        }
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'</li>';//</ul>
                    }
                    
                    
                    
                    if(totalOldTransactions > 0 && customer.Total_Transactions__c > totalOldTransactions)
                    {
                        noDataflag = false;
                        customer.Total_Transaction_Growth__c =  new CustomerSummaryBatchHelper().calculatePercentage(customer.Total_Transactions__c,customer.Total_Transactions_Same_Time__c);
                    }
                    
                    customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'</ul></p>';
                    
                    if(customer.Total_Transactions__c != null && customer.Total_Transactions__c > 0.0)
                    {
                        percentageSSLTrafic = new CustomerSummaryBatchHelper().calculateSimplePercentage(totalEncryptedtransactions,customer.Total_Transactions__c);
                        percentageSSLInspected = new CustomerSummaryBatchHelper().calculateSimplePercentage(totalEncryptedInspectedtransactions,(totalEncryptedtransactions-totalOffice365Transactions));
                        customer.Total_Encrypted_Transaction__c = totalEncryptedtransactions;
                        customer.Total_Encrypted_Inspected_Transaction__c = totalEncryptedInspectedtransactions;
                        customer.Traffic_Encrypted__c = String.valueOf(percentageSSLTrafic);
                        customer.Encrypted_Traffic_Inspected__c = String.valueOf(percentageSSLInspected);
                        customer.Encrypted_Threats_Blocked__c = new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(totalEncryptedThreatsBlocks));
                    }
                    
                    customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<p style="font-size:14px">';
                    
                    if(percentageSSLInspected >= 40 && !(noDataflag) && nottoomuchData) 
                    {
                        Decimal threadPercentage = 0.00;
                        
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+' <strong>'+customer.Account__r.Name+'</strong> is reducing its business risk by inspecting encrypted traffic.';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<ul style="font-size:14px"><li>In the last 3 months, <strong>'+percentageSSLTrafic+'%</strong> of <strong>'+customer.Account__r.Name+'</strong> traffic was Encrypted.</li>';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li><strong>'+new CustomerSummaryBatchHelper().convertToMillions(String.valueOf(totalEncryptedThreatsBlocks))+ '</strong> threats hidden in encrypted traffic were detected and blocked.</li>';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'</ul>';
                    }
                    else if(percentageSSLInspected >= 20 && percentageSSLInspected <40 && !(noDataflag) && nottoomuchData) 
                        
                    {
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+' <strong>'+customer.Account__r.Name+'</strong> could further reduce its business risk by increasing inspection of  encrypted traffic.';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<ul style="font-size:14px"><li>In the last 3 months, <strong>'+percentageSSLTrafic+'%</strong> of <strong>'+customer.Account__r.Name+'</strong> traffic was Encrypted.</li>';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li><strong>'+customer.Account__r.Name+'\'s</strong> Zscaler Deployment is configured to only inspect <strong>'+percentageSSLInspected+'%</strong> of the encrypted traffic. </li></ul>';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<p style="font-size:14px">Since the majority of threats are now hidden in encrypted traffic, <strong>'+customer.Account__r.Name+'</strong> should consider configuring Zscaler to increase inspection of encrypted traffic.</p> ';
                    }
                    else if(percentageSSLInspected < 20 && !(noDataflag) && nottoomuchData)
                    {
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+' <strong>'+customer.Account__r.Name+'</strong> could reduce its business risk by inspecting encrypted traffic.';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<ul style="font-size:14px"><li>In the last 3 months, <strong>'+percentageSSLTrafic+'%</strong> of <strong>'+customer.Account__r.Name+'</strong> total traffic was Encrypted.</li>';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li>Since the majority of threats are now hidden in encrypted traffic, <strong>'+customer.Account__r.Name+'</strong> is likely not blocking a significant amount of threats.</li></ul>';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<p style="font-size:14px"> Zscaler recommends inspecting encrypted traffic.</p';
                        
                    }
                    
                    customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'</p>';
                    
                    if(noDataflag)
                    {
                        customer.Zscaler_Customer_Summary__c = '<p style="font-size:14px"> Zscaler is protecting <strong>'+Integer.ValueOf(customer.Account__r.No_of_Platform_Seats__c).format()+'</strong> users at <strong>'+customer.Account__r.Name+'</strong>.<br/></p> ';
                    } 
                    
                }
                
                if(!nottoomuchData){
                    customer.Zscaler_Customer_Summary__c = '<p style="font-size:14px"> Zscaler is protecting <strong>'+Integer.ValueOf(customer.Account__r.No_of_Platform_Seats__c).format()+'</strong> users at <strong>'+customer.Account__r.Name+'</strong>.<br/>'+
                        +'We have too much data to process cannot generate Zscaler Value Summary.</p> ';
                }
                
                if(updateAccount){
                    currentAccount.Zscaler_Customer_Summary__c = customer.ZScaler_Customer_Summary__c;
                    accountList.add(currentAccount);
                }
                customerScorecardList.add(customer);
            }
            
            update customerScorecardList;
            
            if(!accountList.isEmpty()){
                //IBA-6519-Start
                TriggerHandler.bypass('AccountTriggerHandler');
                update accountList;  
                TriggerHandler.clearBypass('AccountTriggerHandler'); 
                //IBA-6519-End   
            }
        }
        catch(Exception e)
        {
            System.debug('CustomerSummaryScorecardBatch Error:'+e.getMessage() + ' ' + e.getStackTraceString());
            ZscalerErrorLogsUtility.insertlogsForAsync('CustomerSummaryScorecardBatch', 'execute', 
                                                       'Async Apex',userInfo.getUserId(),'Sales cloud',
                                                       e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        this.zb.callFinish(bc);
    }
}