/*
*  Author : Raghu Manchiraju
*  This class is used to roll up cloud usage summary of Customer onto Account
* 
*/ 
global class CustomerSummaryBatch implements Database.Batchable<sObject>, Database.Stateful
{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('CustomerSummaryBatch');
    global final String query;
    global Map<Id,String> errorMap;
    global Account acct;
    private static CustomerSummaryBatchHelper customerSummaryBatchHelperInstance = new CustomerSummaryBatchHelper();
    
    global CustomerSummaryBatch(String q)
    {
        query = q;
        errorMap = new Map<Id,String>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    
    /* select Id,Usage_Pull_Date__c from Cloud_Usage__c 
* where Account__c ='0017000000jfWgR' and Usage_Pull_Date__c = Last_N_months:3
* #Users: ZIA Platform, Total Transactions,Total Security Blocks, L3M
* Generate this value statement only if ZIA Platform seats is greater than zero. 
*/
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        this.zb.callExecute(scope[0]?.Id, scope.size());
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
        
        //Commented by Gurjinder : CR# 715 :Start
        Decimal totalSSLbytes = 0; //Added by Gurjinder as part of CR# 596
        Decimal TotalOffice365 = 0; //Added by Gurjinder as part of CR# 596
        //Commented by Gurjinder : CR# 715 :End
        Customer_Score_Card__c  csc;
        Decimal  SSLinspectedBytes=0;
        Decimal QualifiedSSLInspectedbytes=0;
        Decimal PercentSSLInspectedbytes=0;
        Decimal PercentSSLInspectedTransactions=0;
        List<Account> accountList = new List<Account>();
        List<Customer_Score_Card__c> CSCList = new List<Customer_Score_Card__c>();
        try
        {
            // IBA-3197 START - Create one instance of new CustomerSummaryBatchHelper() and call everthing from that
            Date todaysDate = Date.today();
            String last3Months = customerSummaryBatchHelperInstance.last3Months(todaysDate.month());
            // IBA-3197 END
            for(sObject s : scope)
            {
                Account customer = (Account)s;
                acct = customer;
                //Added by Gurjinder :CR# 715: start
                csc= [Select id,SSL_Inspected_Bytes__c,Qualified_SSL_Inspected_Bytes__c,SSL_Inspected_Transactions__c from Customer_Score_Card__c where Account__c=:acct.id];
                //Added by Gurjinder :CR# 715: End
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
                boolean noDataflag = true;
                boolean nottoomuchData = true;
                
                // IBA-3197 START
                nottoomuchData = customerSummaryBatchHelperInstance.checkNotTooMuchData(customer.Id);
                Date thisMonth = todaysDate.toStartOfMonth();
                // IBA-3197 END
                date months18Ago = thisMonth.addMonths(-18);
                
                if (nottoomuchData) {
                    Map<String, Decimal> oldUsageVariableNameToValueMap = customerSummaryBatchHelperInstance.populateOldUsage(customer);
                    totalOldTransactions = oldUsageVariableNameToValueMap.containsKey('totalOldTransactions') ? oldUsageVariableNameToValueMap.get('totalOldTransactions') : 0;
                    totalOldBandwidth = oldUsageVariableNameToValueMap.containsKey('totalOldBandwidth') ? oldUsageVariableNameToValueMap.get('totalOldBandwidth') : 0;
                    
                    customerSummaryBatchHelperInstance.populateLastAndPreviousMonthUsage(customer);
                    customerSummaryBatchHelperInstance.populateLastAnd6MonthUsage(customer);
                    customerSummaryBatchHelperInstance.populateLastAnd12MonthUsage(customer);
                    
                    Map<String, Decimal> totalUsageVariableNameToValueMap = customerSummaryBatchHelperInstance.populateTotalUsage(customer);
                    totalEncryptedThreatsBlocks = totalUsageVariableNameToValueMap.containsKey('totalEncryptedThreatsBlocks') ? totalUsageVariableNameToValueMap.get('totalEncryptedThreatsBlocks') : 0 ;
                    totalEncryptedtransactions = totalUsageVariableNameToValueMap.containsKey('totalEncryptedtransactions') ? totalUsageVariableNameToValueMap.get('totalEncryptedtransactions') : 0 ;
                    totalEncryptedInspectedtransactions = totalUsageVariableNameToValueMap.containsKey('totalEncryptedInspectedtransactions') ? totalUsageVariableNameToValueMap.get('totalEncryptedInspectedtransactions') : 0 ;
                    totalOffice365Transactions = totalUsageVariableNameToValueMap.containsKey('totalOffice365Transactions') ? totalUsageVariableNameToValueMap.get('totalOffice365Transactions') : 0 ;
                    SSLinspectedBytes = totalUsageVariableNameToValueMap.containsKey('SSLinspectedBytes') ? totalUsageVariableNameToValueMap.get('SSLinspectedBytes') : 0 ;
                    totalSSLbytes = totalUsageVariableNameToValueMap.containsKey('totalSSLbytes') ? totalUsageVariableNameToValueMap.get('totalSSLbytes') : 0 ;
                    TotalOffice365 = totalUsageVariableNameToValueMap.containsKey('TotalOffice365') ? totalUsageVariableNameToValueMap.get('TotalOffice365') : 0 ;
                }
                
                // IBA-3197 END
                
                //Added by Gurjinder : CR# 715 :Start
                
                TotalOffice365=TotalOffice365*1024;
                
                QualifiedSSLInspectedbytes = customerSummaryBatchHelperInstance.calculateSimplePercentage(SSLinspectedBytes,(totalSSLbytes-TotalOffice365));
                PercentSSLInspectedbytes = customerSummaryBatchHelperInstance.calculateSimplePercentage(SSLinspectedBytes,totalSSLbytes);
                PercentSSLInspectedTransactions = customerSummaryBatchHelperInstance.calculateSimplePercentage(totalEncryptedInspectedtransactions,totalEncryptedtransactions);
                
                csc.Qualified_SSL_Inspected_Bytes__c = QualifiedSSLInspectedbytes;
                csc.SSL_Inspected_Bytes__c = PercentSSLInspectedbytes;
                csc.SSL_Inspected_Transactions__c = PercentSSLInspectedTransactions;
                
                //Added by Gurjinder : CR# 715 :End
                
                if(customer.No_of_Platform_Seats__c > 0 && last3Months != null && nottoomuchData)
                {
                    customer.Value_Summary_Months__c = last3Months;
                    customer.Zscaler_Customer_Summary__c = '<p style="font-size:14px"> Zscaler is protecting <strong>'+Integer.ValueOf(customer.No_of_Platform_Seats__c).format()+'</strong> users at <strong>'+customer.Name+'</strong>.<br/> '+
                        'Below is the snapshot of value delivered for '+customer.Name+' in the last 3 months ('+last3Months+'):<br/><ul style="font-size:14px">';
                    
                    if(customer.Total_Transactions__c != null && customer.Total_Transactions__c > 0.0)
                    {
                        noDataflag = false;
                        customer.Total_Transactions_Text__c = customerSummaryBatchHelperInstance.convertToMillions(String.valueOf(customer.Total_Transactions__c));
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ customerSummaryBatchHelperInstance.convertToMillions(String.valueOf(customer.Total_Transactions__c))+' transactions processed. </li>';
                    }
                    
                    if(customer.Total_Bandwidth__c != null && customer.Total_Bandwidth__c > 0.0)
                    {
                        noDataflag = false;
                        customer.Total_Bandwidth_Text__c = customerSummaryBatchHelperInstance.convertToTeraByte(customer.Total_Bandwidth__c)+' TB';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ customerSummaryBatchHelperInstance.convertToTeraByte(customer.Total_Bandwidth__c)+' TB traffic (bandwidth) processed. </li>';
                    }
                    
                    if(totalOldBandwidth > 0 && customer.Total_Bandwidth__c > totalOldBandwidth)
                    {
                        noDataflag = false;
                        Integer growth = customerSummaryBatchHelperInstance.calculatePercentage(customer.Total_Bandwidth__c,customer.Total_Bandwidth_Same_Time__c);
                        customer.Total_Bandwidth_Growth__c = growth;
                        if(growth >= 10 && growth <=1000)
                        {
                            customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> Total traffic from same time last year has grown by '+ customerSummaryBatchHelperInstance.calculatePercentage(customer.Total_Bandwidth__c,customer.Total_Bandwidth_Same_Time__c)+'% - from '+customerSummaryBatchHelperInstance.convertToTeraByte(customer.Total_Bandwidth_Same_Time__c)+' TB to '+customerSummaryBatchHelperInstance.convertToTeraByte(customer.Total_Bandwidth__c) +' TB.</li>';
                            
                        }
                        else if(growth >1000)
                        {
                            customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> Total traffic from same time last year has grown from '+customerSummaryBatchHelperInstance.convertToTeraByte(customer.Total_Bandwidth_Same_Time__c)+' TB to '+customerSummaryBatchHelperInstance.convertToTeraByte(customer.Total_Bandwidth__c) +' TB.</li>';
                        }
                        
                    }
                    
                    if(customer.Total_Policy_Blocks__c != null && customer.Total_Policy_Blocks__c > 0.0)
                    {
                        noDataflag = false;
                        customer.Total_Policy_Blocks_Text__c = customerSummaryBatchHelperInstance.convertToMillions(String.valueOf(customer.Total_Policy_Blocks__c));
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ customerSummaryBatchHelperInstance.convertToMillions(String.valueOf(customer.Total_Policy_Blocks__c))+' policy violations prevented. </li>';
                    }
                    
                    if(customer.Total_Security_Blocks__c!= null && customer.Total_Security_Blocks__c > 0.0)
                    {
                        noDataflag = false;
                        customer.Total_Security_Blocks_Text__c = customerSummaryBatchHelperInstance.convertToMillions(String.valueOf(customer.Total_Security_Blocks__c));
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li> '+ customerSummaryBatchHelperInstance.convertToMillions(String.valueOf(customer.Total_Security_Blocks__c)) + ' security threats blocked.';//, including <ul>
                        
                        if(customer.Total_Botnet_Calls__c != null && customer.Total_Botnet_Calls__c > 0.0)
                        {
                            customer.Total_Botnet_Calls_Text__c = customerSummaryBatchHelperInstance.convertToMillions(String.valueOf(customer.Total_Botnet_Calls__c));
                        }
                        if(customer.Total_Malware__c != null && customer.Total_Malware__c > 0.0)
                        {
                            customer.Total_Malware_Text__c = customerSummaryBatchHelperInstance.convertToMillions(String.valueOf(customer.Total_Malware__c));
                        }
                        if(customer.Total_Phishing_Attacks__c != null && customer.Total_Phishing_Attacks__c > 0.0)
                        {
                            customer.Total_Phishing_Attacks_Text__c = customerSummaryBatchHelperInstance.convertToMillions(String.valueOf(customer.Total_Phishing_Attacks__c));
                        }
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'</li>';//</ul>
                    }
                    
                    
                    
                    if(totalOldTransactions > 0 && customer.Total_Transactions__c > totalOldTransactions)
                    {
                        noDataflag = false;
                        customer.Total_Transaction_Growth__c =  customerSummaryBatchHelperInstance.calculatePercentage(customer.Total_Transactions__c,customer.Total_Transactions_Same_Time__c);
                    }
                    
                    customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'</ul></p>';
                    
                    if(customer.Total_Transactions__c != null && customer.Total_Transactions__c > 0.0)
                    {
                        percentageSSLTrafic = customerSummaryBatchHelperInstance.calculateSimplePercentage(totalEncryptedtransactions,customer.Total_Transactions__c);                        
                        percentageSSLInspected = customerSummaryBatchHelperInstance.calculateSimplePercentage(totalEncryptedInspectedtransactions,(totalEncryptedtransactions-totalOffice365Transactions));
                        //Commented by Gurjinder : CR# 715 :End
                        customer.Total_Encrypted_Transaction__c = totalEncryptedtransactions;
                        customer.Total_Encrypted_Inspected_Transaction__c = totalEncryptedInspectedtransactions;
                        customer.Traffic_Encrypted__c = String.valueOf(percentageSSLTrafic);
                        customer.Encrypted_Traffic_Inspected__c = String.valueOf(percentageSSLInspected);
                        customer.Encrypted_Threats_Blocked__c = customerSummaryBatchHelperInstance.convertToMillions(String.valueOf(totalEncryptedThreatsBlocks));
                    }
                    
                    customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<p style="font-size:14px">';
                    
                    if(percentageSSLInspected >= 40 && !(noDataflag) && nottoomuchData) 
                    {
                        Decimal threadPercentage = 0.00;
                        
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+' <strong>'+customer.Name+'</strong> is reducing its business risk by inspecting encrypted traffic.';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<ul style="font-size:14px"><li>In the last 3 months, <strong>'+percentageSSLTrafic+'%</strong> of <strong>'+customer.Name+'</strong> traffic was Encrypted.</li>';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li><strong>'+customerSummaryBatchHelperInstance.convertToMillions(String.valueOf(totalEncryptedThreatsBlocks))+ '</strong> threats hidden in encrypted traffic were detected and blocked.</li>';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'</ul>';
                    }
                    else if(percentageSSLInspected >= 20 && percentageSSLInspected <40 && !(noDataflag) && nottoomuchData) 
                        
                    {
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+' <strong>'+customer.Name+'</strong> could further reduce its business risk by increasing inspection of  encrypted traffic.';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<ul style="font-size:14px"><li>In the last 3 months, <strong>'+percentageSSLTrafic+'%</strong> of <strong>'+customer.Name+'</strong> traffic was Encrypted.</li>';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li><strong>'+customer.Name+'\'s</strong> Zscaler Deployment is configured to only inspect <strong>'+percentageSSLInspected+'%</strong> of the encrypted traffic. </li></ul>';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<p style="font-size:14px">Since the majority of threats are now hidden in encrypted traffic, <strong>'+customer.Name+'</strong> should consider configuring Zscaler to increase inspection of encrypted traffic.</p> ';
                    }
                    else if(percentageSSLInspected < 20 && !(noDataflag) && nottoomuchData)
                    {
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+' <strong>'+customer.Name+'</strong> could reduce its business risk by inspecting encrypted traffic.';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<ul style="font-size:14px"><li>In the last 3 months, <strong>'+percentageSSLTrafic+'%</strong> of <strong>'+customer.Name+'</strong> total traffic was Encrypted.</li>';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<li>Since the majority of threats are now hidden in encrypted traffic, <strong>'+customer.Name+'</strong> is likely not blocking a significant amount of threats.</li></ul>';
                        customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'<p style="font-size:14px"> Zscaler recommends inspecting encrypted traffic.</p';
                        
                    }
                    
                    customer.Zscaler_Customer_Summary__c = customer.Zscaler_Customer_Summary__c+'</p>';
                    
                    if(noDataflag)
                    {
                        customer.Zscaler_Customer_Summary__c = '<p style="font-size:14px"> Zscaler is protecting <strong>'+Integer.ValueOf(customer.No_of_Platform_Seats__c).format()+'</strong> users at <strong>'+customer.Name+'</strong>.<br/></p> ';
                    } 
                    
                }
                
                if(!nottoomuchData)
                {
                    customer.Zscaler_Customer_Summary__c = '<p style="font-size:14px"> Zscaler is protecting <strong>'+Integer.ValueOf(customer.No_of_Platform_Seats__c).format()+'</strong> users at <strong>'+customer.Name+'</strong>.<br/>'+
                        +'We have too much data to process cannot generate Zscaler Value Summary.</p> ';
                    
                }
                
                accountList.add(customer);
                cscList.add(csc);
            }
            //IBA-6427-Start
            TriggerHandler.bypass('AccountTriggerHandler');
            update accountList;  
            TriggerHandler.clearBypass('AccountTriggerHandler'); 
            //IBA-6427-End
            update cscList; 
            
        }
        catch(Exception ex)
        {
            System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
            errorMap.put(acct.Id,ex.getMessage() + ' at Line No. ' + ex.getLineNumber());
            //updated by Akash 1: CR# 5023 start
            ZscalerErrorLogsUtility.insertlogsForAsync('CustomerSummaryBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
            //updated by Akash 1: CR# 5023 end
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        this.zb.callFinish(BC);
        //updated by Akash 1: CR# 5023 start
        //updated by Akash 1: CR# 5023 end
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        if(!errorMap.Values().isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Customer Summary Batch Job Failed');
            String msgbody = 'Below are the Ids of ' + errorMap.Values().size() + ' account records that have failed: \n';
            for(Id s: errorMap.keySet()){
                msgbody += 'Id : '+s + ' Error Message : '+errorMap.get(s) +'\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }
        if(errorMap.Values().isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Customer Summary Batch Job Completed ');
            mail.setPlainTextBody('Customer Summary Batch Job Completed');
            messageList.add(mail);
        }
        if(!Test.isRunningTest()){
            Messaging.sendEmail(messageList);
        }
        
    }
}