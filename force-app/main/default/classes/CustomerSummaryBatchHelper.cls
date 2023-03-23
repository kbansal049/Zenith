public class CustomerSummaryBatchHelper 
{
    public List<Cloud_Usage__c> usage(Account acct)
    {
        List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
        //Added total_ssl_bytes__c,Total_Office_365_Kb__c, fieldsw in query :Gurjinder :CR# 596
        //Added total_ssl_inspected_bytes__c fields in query :Gurjinder :CR# 715
            usageList = [select Id,total_ssl_inspected_bytes__c,total_ssl_bytes__c,Total_Office_365_Kb__c, Total_Policy_Blocks__c,Total_Transactions__c,total_security_blocks__c,Encrypted_Threats_Blocked__c,Total_Office_365_Transactions__c, 
                                          total_botnet_blocks__c,Total_Transactions_Bandwidth__c,total_malware_site_blocks__c ,total_ssl_inspected_transactions__c,
                                          total_ssl_transactions__c,total_phishing_blocks__c,Authenticated_Kilobytes_del_del__c,
                                          User_Count__c  from Cloud_Usage__c where Cloud_Usage_Type__c= 'ZIA' and Account__c = :acct.Id 
                                          and Usage_Pull_Date__c = Last_N_months:3];
        return usageList;
    }
     
    public List<Cloud_Usage__c> oldUsage(Account acct)
    {
        List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
        //and Usage_Pull_Date__c = Last_Year
        //Added total_ssl_bytes__c,Total_Office_365_Kb__c, fieldsw in query :Gurjinder :CR# 596
        //Added total_ssl_inspected_bytes__c fields in query :Gurjinder :CR# 715
            usageList = [select Id,total_ssl_inspected_bytes__c,total_ssl_bytes__c,Total_Office_365_Kb__c, Total_Policy_Blocks__c,Total_Transactions__c,total_security_blocks__c,Encrypted_Threats_Blocked__c,Total_Office_365_Transactions__c, 
                                          total_botnet_blocks__c,Total_Transactions_Bandwidth__c,total_malware_site_blocks__c,total_ssl_inspected_transactions__c,
                                          total_ssl_transactions__c,total_phishing_blocks__c  from Cloud_Usage__c where Cloud_Usage_Type__c= 'ZIA' and Account__c = :acct.Id 
                                           and Usage_Pull_Date__c = Last_N_months:15 and  Usage_Pull_Date__c <> Last_N_months:12];
        return usageList;
    }
    
    public List<Cloud_Usage__c> getLastAndPreviousMonthUsage(Account acct)
    {
        List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
        Date today = Date.today();
        Map<String, List<Datetime>> mapDateRange = LastAndPreviousMonthRange(today.month(), today.year());
        usageList = Database.query(getCloudUsageQuery(acct.Id, mapDateRange));
        return usageList;
    }
    
    public List<Cloud_Usage__c> getLastAnd6MonthUsage(Account acct)
    {
        List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
        Date today = Date.today();
        Map<String, List<Datetime>> mapDateRange = LastAnd6MonthRange(today.month(), today.year());
        usageList = Database.query(getCloudUsageQuery(acct.Id, mapDateRange));
        return usageList;
    }
    
    public List<Cloud_Usage__c> getLastAnd12MonthUsage(Account acct)
    {
        List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
        Date today = Date.today();
        Map<String, List<Datetime>> mapDateRange = LastAnd12MonthRange(today.month(), today.year());
        usageList = Database.query(getCloudUsageQuery(acct.Id, mapDateRange));
        return usageList;
    }

    public static String getCloudUsageQuery(Id accountId, Map<String, List<Datetime>> usageRange) {
        String query = 'SELECT Id, Account__c, Usage_Pull_Date__c,total_ssl_inspected_bytes__c,total_ssl_bytes__c,Total_Office_365_Kb__c,Total_Transactions__c,Total_Office_365_Transactions__c, Total_Transactions_Bandwidth__c,ZPA_Active_Users__c,Cloud_Usage_Type__c FROM Cloud_Usage__c WHERE Cloud_Usage_Type__c= \'ZIA\' and Account__c = \'' + accountId + '\' ';

        Map<String, List<Datetime>> mapMonthAndYear = usageRange;
        
        String criteria = ' AND (';
        for (String month : mapMonthAndYear.keySet()) {
            criteria += ' (Usage_Pull_Date__c >= ' + mapMonthAndYear.get(month)[0].format('yyyy-MM-dd') + ' AND Usage_Pull_Date__c <= ' + mapMonthAndYear.get(month)[1].format('yyyy-MM-dd') + ') OR ';
        }
        criteria = criteria.substring(1, criteria.length() - 3);
        criteria += ')';
        
        if (criteria.length() > 7) {
            System.debug(criteria);
            query += criteria;
        }
        
        return query;
    }

    public static String getCloudUsageCountQuery(Id accountId, Map<String, List<Datetime>> usageRange) {
        String query = 'SELECT COUNT(Id) CLOUD_USAGE_COUNT FROM Cloud_Usage__c WHERE Cloud_Usage_Type__c= \'ZIA\' and Account__c = \'' + accountId + '\' ';

        Map<String, List<Datetime>> mapMonthAndYear = usageRange;
        
        String criteria = ' AND (';
        for (String month : mapMonthAndYear.keySet()) {
            criteria += ' (Usage_Pull_Date__c >= ' + mapMonthAndYear.get(month)[0].format('yyyy-MM-dd') + ' AND Usage_Pull_Date__c <= ' + mapMonthAndYear.get(month)[1].format('yyyy-MM-dd') + ') OR ';
        }
        criteria = criteria.substring(1, criteria.length() - 3);
        criteria += ')';
        
        if (criteria.length() > 7) {
            System.debug(criteria);
            query += criteria;
        }
        
        return query;
    }
	
    public List<Zscaler_Cloud_ID__c> getLastAndPreviousMonthcloudUsage(Account acct)
    {
        List<Zscaler_Cloud_ID__c> usageList = new List<Zscaler_Cloud_ID__c>();
        Date today = Date.today();
        Map<String, List<Datetime>> mapDateRange = LastAndPreviousMonthRange(today.month(), today.year());
        usageList = Database.query(getMonthlyCloudUsageQuery(acct.Id, mapDateRange));
        return usageList;
    }
    
    public List<Zscaler_Cloud_ID__c> getLastAnd6MonthcloudUsage(Account acct)
    {
        List<Zscaler_Cloud_ID__c> usageList = new List<Zscaler_Cloud_ID__c>();
        Date today = Date.today();
        Map<String, List<Datetime>> mapDateRange = LastAnd6MonthRange(today.month(), today.year());
        usageList = Database.query(getMonthlyCloudUsageQuery(acct.Id, mapDateRange));
        return usageList;
    }
    
    public List<Zscaler_Cloud_ID__c> getLastAnd12MonthcloudUsage(Account acct)
    {
        List<Zscaler_Cloud_ID__c> usageList = new List<Zscaler_Cloud_ID__c>();
        List<Contract_Detail__c> contractList = new List<Contract_Detail__c>();
        Date today = Date.today();
        Map<String, List<Datetime>> mapDateRange = LastAnd12MonthRange(today.month(), today.year());
        usageList = Database.query(getMonthlyCloudUsageQuery(acct.Id, mapDateRange));
        return usageList;
    }
    
    
    public static String getMonthlyCloudUsageQuery(Id accountId, Map<String, List<Datetime>> usageRange) {
        String query = 'SELECT id,Account__c,Cloud_Type__c,(SELECT id, X90_Day_Trailing_Unique_Auth_Users__c,Cloud_ID__c,Monthly_Usage__c,Total_Unique_Users__c,ZPA_L31d__c FROM BWC_Data__r WHERE';

        Map<String, List<Datetime>> mapMonthAndYear = usageRange;
        
        String criteria = ' ';
        for (String month : mapMonthAndYear.keySet()) {
            criteria += '(Monthly_Usage__c >= ' + mapMonthAndYear.get(month)[0].format('yyyy-MM-dd') + ' AND Monthly_Usage__c <= ' + mapMonthAndYear.get(month)[1].format('yyyy-MM-dd') + ') OR ';
        }
        criteria = criteria.substring(1, criteria.length() - 3);
        criteria += ') FROM Zscaler_Cloud_ID__c WHERE (Cloud_Type__c= \'ZIA\' OR Cloud_Type__c=\'ZPA\') and Account__c = \'' + accountId + '\'';
        
        if (criteria.length() > 7) {
            System.debug(criteria);
            query += criteria;
        }
        System.debug('query '+query);
        return query;
    }
      
    public List<Case> getLastAndPreviousMonthCaseDetails(Account acct)
    {
        List<Case> caseList = new List<Case>();
        Date today = Date.today();
        Map<String, List<Datetime>> mapDateRange = LastAndPreviousMonthRange(today.month(), today.year());
        caseList = Database.query(getCaseDetailQuery(acct.Id, mapDateRange));
        return caseList;
    }
    public List<Case> getLastAnd6CaseDetails(Account acct)
    {
        List<Case> usageList = new List<Case>();
        Date today = Date.today();
        Map<String, List<Datetime>> mapDateRange = LastAnd6MonthRange(today.month(), today.year());
        usageList = Database.query(getCaseDetailQuery(acct.Id, mapDateRange));
        return usageList;
    }
    
    public List<Case> getLastAnd12MonthCaseDetail(Account acct)
    {
        List<Case> usageList = new List<Case>();
        //List<Contract_Detail__c> contractList = new List<Contract_Detail__c>();
        Date today = Date.today();
        Map<String, List<Datetime>> mapDateRange = LastAnd12MonthRange(today.month(), today.year());
        usageList = Database.query(getCaseDetailQuery(acct.Id, mapDateRange));
        return usageList;
    }
    
    public static String getCaseDetailQuery(Id accountId, Map<String, List<Datetime>> usageRange) {
        String query = 'Select id,Account_Name__c,Priority,Status,IsEscalated,CreatedDate FROM Case WHERE Case_Type__c = \'Problem\' AND AccountID = \'' + accountId + '\' ';
        Map<String, List<Datetime>> mapMonthAndYear = usageRange;
        String criteria = ' And (';
        for (String month : mapMonthAndYear.keySet()) {
            criteria += '(DAY_ONLY(convertTimezone(CreatedDate)) >= ' + mapMonthAndYear.get(month)[0].format('yyyy-MM-dd') + ' AND DAY_ONLY(convertTimezone(CreatedDate)) <= ' + mapMonthAndYear.get(month)[1].format('yyyy-MM-dd') + ') OR ';
        }
        criteria = criteria.substring(1, criteria.length() - 3);
        criteria += ' )';
        if (criteria.length() > 7) {
            System.debug(criteria);
            query += criteria;
        }
        System.debug('query '+query);
        return query;
    }
    
        
    public Boolean checkNotTooMuchData(String IdData)
    {
        Boolean flag = true;
        Integer counter = 0;
        Date today = Date.today();
        System.debug('>>>> AccountId: ' + IdData);
        List<AggregateResult> results = [select count(id) from Cloud_Usage__c where Cloud_Usage_Type__c= 'ZIA' and Account__c = :IdData and Usage_Pull_Date__c = Last_N_months:3]; 
        for(AggregateResult ar : results)
        {
            Integer data = (integer)ar.get('expr0');
            counter = data;
            if( data > 50000)
            {
                system.debug('Counter Info 1 : '+counter);
                flag = false;
            }
        }
        
        if(flag)
        {
            // IBA-3197 START
            Integer data = counter;
            // IBA-3197 END

            //Usage_Pull_Date__c = Last_Year and
            results = [select count(id) from Cloud_Usage__c where Cloud_Usage_Type__c= 'ZIA' and Account__c = :IdData and 
                        Usage_Pull_Date__c = Last_N_months:15 
                       and  Usage_Pull_Date__c <> Last_N_months:12]; 
            
            for(AggregateResult ar1 : results) {
                data = (integer)ar1.get('expr0') + data;
                system.debug('Counter Info 1 : '+data);
                if( data > 50000)
                {
                    flag = false;
                }
            }

            Map<String, List<Datetime>> lastAndPreviousMonthRange = LastAndPreviousMonthRange(today.month(), today.year());
            results = Database.query(getCloudUsageCountQuery(IdData, lastAndPreviousMonthRange));
            data = data + Integer.valueOf(results[0].get('CLOUD_USAGE_COUNT'));
            
            if (data > 50000) {
                return false;
            }

            Map<String, List<Datetime>> lastAnd6MonthRange = LastAnd6MonthRange(today.month(), today.year());
            results = Database.query(getCloudUsageCountQuery(IdData, lastAnd6MonthRange));
            data = data + Integer.valueOf(results[0].get('CLOUD_USAGE_COUNT'));
            
            if (data > 50000) {
                return false;
            }

            Map<String, List<Datetime>> lastAnd12MonthRange = LastAnd12MonthRange(today.month(), today.year());
            results = Database.query(getCloudUsageCountQuery(IdData, lastAnd12MonthRange));
            data = data + Integer.valueOf(results[0].get('CLOUD_USAGE_COUNT'));

            if (data > 50000) {
                flag = false;
            }
        }
        return flag;
    }
    
    public Integer calculatePercentage(Decimal currentValue,Decimal oldValue)
    {
        if(oldValue == null || oldValue == 0){
            return 0;
        }else{
            return Integer.ValueOf(((100*currentValue)/oldValue)-100);
        }
    }
    
    public Integer calculateSimplePercentage(Decimal currentValue,Decimal oldValue)
    {
        if(oldValue == null || oldValue == 0){
            return 0;
        }else{
            return Integer.ValueOf(((currentValue)/(oldValue))*100);
        }
    }
    

    public String convertToTeraByte(Decimal value)
    {
        Decimal output = (1*value)/(1000000000);
        return output.setScale(1, RoundingMode.HALF_UP).format();
    }
    public String convertToMillions(String value)
    {
        if(value != null )
        {
            system.debug('Input String :: '+value);
            String[] strSplit = value.split('\\.');
            
            if(strSplit[0] != null)
            {
                if(strSplit[0].length() > 9)
                {
                    Integer len = strSplit[0].length();
                    System.debug('Length 1:: '+len);
                    String s1 = strSplit[0].left(len - 9);
                    String s2 = '';
                    if(len == 12)
                    s2 = strSplit[0].substring(len - 9,4);
                    if(len == 11)
                    s2 = strSplit[0].substring(len - 9,3);
                    if(len == 10)
                    s2 = strSplit[0].substring(len - 9,2);
                    
                    return s1+'.'+s2+' Billion';
                    //return s1+' Billion';
                }
                else if(strSplit[0].length() > 6)
                {
                    Integer len = strSplit[0].length();
                    System.debug('Length 2:: '+len);
                    String s1 = strSplit[0].left(len - 6);
                    String s2 = '';
                    if(len == 9)
                    s2 = strSplit[0].substring(len - 6,4);
                    if(len == 8)
                    s2 = strSplit[0].substring(len - 6,3);
                    if(len == 7)
                    s2 = strSplit[0].substring(len - 6,2);
                    return s1+'.'+s2+' Million';
                    //return s1+' Million';
                }
                else
                {
                    Integer len = strSplit[0].length();
                    System.debug('Length 3:: '+len+' :: '+strSplit[0]);
                    if(len > 3)
                    {
                        String s1 = strSplit[0].left(len - 3);
                        String s2 = strSplit[0].substring(len - 3);
                        system.debug(s1+','+s2);
                        return s1+','+s2;
                    }
                    else
                    {
                        return strSplit[0];
                    }
                }
            }
        }
        
        return null;
    }
    
    public String last3Months(Integer month)
    {
        if(Test.isrunningtest()){
        //booster(); Added by Swathi - CR 1061
        }
        switch on month {
            when 1 {
                return 'October, November, December';
            }
            when 2 {
                return 'November, December, January';
            }
            when 3 {
                return 'December, January, February';
            }
            when 4 {
                return 'January, February, March';
            }
            when 5 {
                return 'February, March, April';
            }
            when 6 {
                return 'March, April, May';
            }
            when 7 {
                return 'April, May, June';
            }
            when 8 {
                return 'May, June, July';
            }
            when 9 {
                return 'June, July, August';
            }
            when 10 {
                return 'July, August, September';
            }
            when 11 {
                return 'August, September, October';
            }
            when 12 {
                return 'September, October, November';
            }
        }
        return null;
    }
    
    public static Map<String, List<Datetime>> LastAndPreviousMonthRange(Integer month, Integer year) {
        Map<String, Map<Integer, Integer>> monthAndYear = new Map<String, Map<Integer, Integer>>();
        Map<String, List<Datetime>> mapDateRange = new Map<String, List<Datetime>>();
        
        Integer lastMonth, lastYear, previousMonth, previousYear;        
        if (month == 1) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 12 => year - 1 });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 11 => year - 1 });
            lastMonth = 12;
            lastYear = year - 1;
            previousMonth = 11;
            previousYear = year - 1;
        } else if (month == 2) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 1 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 12 => year - 1 });
            lastMonth = 1;
            lastYear = year;
            previousMonth = 12;
            previousYear = year - 1;
        } else if (month == 3) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 2 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 1 => year });
            lastMonth = 2;
            lastYear = year;
            previousMonth = 1;
            previousYear = year;
        } else if (month == 4) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 3 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 2 => year });
            lastMonth = 3;
            lastYear = year;
            previousMonth = 2;
            previousYear = year;
        } else if (month == 5) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 4 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 3 => year });
            lastMonth = 4;
            lastYear = year;
            previousMonth = 3;
            previousYear = year;
        } else if (month == 6) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 5 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 4 => year });
            lastMonth = 5;
            lastYear = year;
            previousMonth = 4;
            previousYear = year;
        } else if (month == 7) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 6 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 5 => year });
            lastMonth = 6;
            lastYear = year;
            previousMonth = 5;
            previousYear = year;
        } else if (month == 8) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 7 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 6 => year });
            lastMonth = 7;
            lastYear = year;
            previousMonth = 6;
            previousYear = year;
        } else if (month == 9) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 8 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 7 => year });
            lastMonth = 8;
            lastYear = year;
            previousMonth = 7;
            previousYear = year;
        } else if (month == 10) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 9 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 8 => year });
            lastMonth = 9;
            lastYear = year;
            previousMonth = 8;
            previousYear = year;
        } else if (month == 11) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 10 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 9 => year });
            lastMonth = 10;
            lastYear = year;
            previousMonth = 9;
            previousYear = year;
        } else if (month == 12) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 11 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 10 => year });
            lastMonth = 11;
            lastYear = year;
            previousMonth = 10;
            previousYear = year;
        }
        
        Datetime lastStartDate, lastEndDate, previousStartDate, previousEndDate;
        lastStartDate = Datetime.newInstance(lastYear, lastMonth, 1, 0, 0, 0);
        lastEndDate = lastStartDate.addMonths(1).addDays(-1);
        previousStartDate = Datetime.newInstance(previousYear, previousMonth, 1, 0, 0, 0);
        previousEndDate = previousStartDate.addMonths(1).addDays(-1);
        mapDateRange.put('last', new List<Datetime> { lastStartDate, lastEndDate });
        mapDateRange.put('previous', new List<Datetime> { previousStartDate, previousEndDate });
        
        return mapDateRange;
    }
    
    public static Map<String, List<Datetime>> LastAnd6MonthRange(Integer month, Integer year) {
        Map<String, Map<Integer, Integer>> monthAndYear = new Map<String, Map<Integer, Integer>>();
        Map<String, List<Datetime>> mapDateRange = new Map<String, List<Datetime>>();
        
        Integer lastMonth, lastYear, previousMonth, previousYear;
        if (month == 1) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 12 => year - 1 });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 7 => year - 1 });
            lastMonth = 12;
            lastYear = year - 1;
            previousMonth = 7;
            previousYear = year - 1;
        } else if (month == 2) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 1 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 8 => year - 1 });
            lastMonth = 1;
            lastYear = year;
            previousMonth = 8;
            previousYear = year - 1;
        } else if (month == 3) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 2 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 9 => year - 1 });
            lastMonth = 2;
            lastYear = year;
            previousMonth = 9;
            previousYear = year - 1;
        } else if (month == 4) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 3 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 10 => year - 1 });
            lastMonth = 3;
            lastYear = year;
            previousMonth = 10;
            previousYear = year - 1;
        } else if (month == 5) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 4 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 11 => year - 1 });
            lastMonth = 4;
            lastYear = year;
            previousMonth = 11;
            previousYear = year - 1;
        } else if (month == 6) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 5 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 12 => year - 1 });
            lastMonth = 5;
            lastYear = year;
            previousMonth = 12;
            previousYear = year - 1;
        } else if (month == 7) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 6 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 1 => year });
            lastMonth = 6;
            lastYear = year;
            previousMonth = 1;
            previousYear = year;
        } else if (month == 8) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 7 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 2 => year });
            lastMonth = 7;
            lastYear = year;
            previousMonth = 2;
            previousYear = year;
        } else if (month == 9) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 8 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 3 => year });
            lastMonth = 8;
            lastYear = year;
            previousMonth = 3;
            previousYear = year;
        } else if (month == 10) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 9 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 4 => year });
            lastMonth = 9;
            lastYear = year;
            previousMonth = 4;
            previousYear = year;
        } else if (month == 11) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 10 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 5 => year });
            lastMonth = 10;
            lastYear = year;
            previousMonth = 5;
            previousYear = year;
        } else if (month == 12) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 11 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 6 => year });
            lastMonth = 11;
            lastYear = year;
            previousMonth = 6;
            previousYear = year;
        }
        
        Datetime lastStartDate, lastEndDate, previousStartDate, previousEndDate;
        lastStartDate = Datetime.newInstance(lastYear, lastMonth, 1, 0, 0, 0);
        lastEndDate = lastStartDate.addMonths(1).addDays(-1);
        previousStartDate = Datetime.newInstance(previousYear, previousMonth, 1, 0, 0, 0);
        previousEndDate = previousStartDate.addMonths(1).addDays(-1);
        mapDateRange.put('last', new List<Datetime> { lastStartDate, lastEndDate });
        mapDateRange.put('previous', new List<Datetime> { previousStartDate, previousEndDate });
        
        return mapDateRange;
    }
    
    public static Map<String, List<Datetime>> LastAnd12MonthRange(Integer month, Integer year) {
        Map<String, Map<Integer, Integer>> monthAndYear = new Map<String, Map<Integer, Integer>>();
        Map<String, List<Datetime>> mapDateRange = new Map<String, List<Datetime>>();
        
        Integer lastMonth, lastYear, previousMonth, previousYear;
        if (month == 1) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 12 => year - 1 });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 12 => year - 2 });
            lastMonth = 12;
            lastYear = year - 1;
            previousMonth = 12;
            previousYear = year - 2;
        } else if (month == 2) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 1 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 1 => year - 1 });
            lastMonth = 1;
            lastYear = year;
            previousMonth = 1;
            previousYear = year - 1;
        } else if (month == 3) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 2 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 2 => year - 1 });
            lastMonth = 2;
            lastYear = year;
            previousMonth = 2;
            previousYear = year - 1;
        } else if (month == 4) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 3 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 3 => year - 1 });
            lastMonth = 3;
            lastYear = year;
            previousMonth = 3;
            previousYear = year - 1;
        } else if (month == 5) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 4 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 4 => year - 1 });
            lastMonth = 4;
            lastYear = year;
            previousMonth = 4;
            previousYear = year - 1;
        } else if (month == 6) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 5 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 5 => year - 1 });
            lastMonth = 5;
            lastYear = year;
            previousMonth = 5;
            previousYear = year - 1;
        } else if (month == 7) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 6 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 6 => year - 1 });
            lastMonth = 6;
            lastYear = year;
            previousMonth = 6;
            previousYear = year - 1;
        } else if (month == 8) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 7 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 7 => year - 1 });
            lastMonth = 7;
            lastYear = year;
            previousMonth = 7;
            previousYear = year - 1;
        } else if (month == 9) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 8 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 8 => year - 1 });
            lastMonth = 8;
            lastYear = year;
            previousMonth = 8;
            previousYear = year - 1;
        } else if (month == 10) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 9 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 9 => year - 1 });
            lastMonth = 9;
            lastYear = year;
            previousMonth = 9;
            previousYear = year - 1;
        } else if (month == 11) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 10 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 10 => year - 1 });
            lastMonth = 10;
            lastYear = year;
            previousMonth = 10;
            previousYear = year - 1;
        } else if (month == 12) {
            //monthAndYear.put('last', new Map<Integer, Integer> { 11 => year });
            //monthAndYear.put('previous', new Map<Integer, Integer> { 11 => year - 1 });
            lastMonth = 11;
            lastYear = year;
            previousMonth = 11;
            previousYear = year - 1;
        }
        
        Datetime lastStartDate, lastEndDate, previousStartDate, previousEndDate;
        lastStartDate = Datetime.newInstance(lastYear, lastMonth, 1, 0, 0, 0);
        lastEndDate = lastStartDate.addMonths(1).addDays(-1);
        previousStartDate = Datetime.newInstance(previousYear, previousMonth, 1, 0, 0, 0);
        previousEndDate = previousStartDate.addMonths(1).addDays(-1);
        mapDateRange.put('last', new List<Datetime> { lastStartDate, lastEndDate });
        mapDateRange.put('previous', new List<Datetime> { previousStartDate, previousEndDate });
        
        return mapDateRange;
    }
    
    public List<Cloud_Usage__c> usage31Days(Account acct)
    {
        List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
        usageList = [select Id,Usage_Pull_Date__c,Usage_Pull_Week__c,Authenticated_Kilobytes_del_del__c,Total_Transactions_Bandwidth__c
                     ,User_Count__c from Cloud_Usage__c where Cloud_Usage_Type__c= 'ZIA' and Account__c = :acct.Id and Usage_Pull_Date__c = LAST_N_DAYS:35];

        return usageList;
        
    }
    
    public List<Cloud_Usage__c> usage90Days(Account acct)
    {
        List<Cloud_Usage__c> usageList = new List<Cloud_Usage__c>();
        usageList = [select Id,Usage_Pull_Date__c,Usage_Pull_Week__c,Authenticated_Kilobytes_del_del__c,Total_Transactions_Bandwidth__c
                     ,User_Count__c from Cloud_Usage__c where Cloud_Usage_Type__c= 'ZIA' and Account__c = :acct.Id and Usage_Pull_Date__c = LAST_N_DAYS:94]; 

        return usageList;
    }

    // IBA-3197 START
    public Map<String, Decimal> populateOldUsage(Account customer) {
        Decimal totalOldTransactions = 0;
        Decimal totalOldBandwidth = 0;
        
        List<Cloud_Usage__c> usageListOld = oldUsage(customer);
        if(!usageListOld.isEmpty()) {
            
            for(Cloud_Usage__c cloudUsageOld : usageListOld) {
                totalOldTransactions = totalOldTransactions + cloudUsageOld.Total_Transactions__c;
                totalOldBandwidth = totalOldBandwidth + cloudUsageOld.Total_Transactions_Bandwidth__c;
            }
            customer.Total_Transactions_Same_Time__c = totalOldTransactions;
            customer.Total_Bandwidth_Same_Time__c = totalOldBandwidth;
            customer.Total_Transactions_Same_Time_Text__c = convertToMillions(String.valueOf(customer.Total_Transactions_Same_Time__c));
            customer.Total_Bandwidth_Same_Time_Text__c = convertToTeraByte(customer.Total_Bandwidth_Same_Time__c)+' TB';
        }

        Map<String, Decimal> variableNameToValueMap = new Map<String, Decimal>();
        variableNameToValueMap.put('totalOldTransactions', totalOldTransactions);
        variableNameToValueMap.put('totalOldBandwidth', totalOldBandwidth);

        return variableNameToValueMap;
    }

    public void populateLastAndPreviousMonthUsage(Account customer) {
        Date todaysDate = Date.today();
        
        Decimal totalLastTransactions = 0;
        Decimal totalLastBandwidth = 0;
        Decimal totalPreviousTransactions =0;
        Decimal totalPreviousBandwidth = 0;

        //List<Cloud_Usage__c> lastAndPreviousMonthList = getLastAndPreviousMonthUsage(customer);

        Map<String, List<Datetime>> mapLastAndPreviousMonthDateRange = LastAndPreviousMonthRange(todaysDate.month(), todaysDate.year());

        Date lastStartDate = mapLastAndPreviousMonthDateRange.get('last')[0].date();
        Date lastEndDate = mapLastAndPreviousMonthDateRange.get('last')[1].date();
        Date previousStartDate = mapLastAndPreviousMonthDateRange.get('previous')[0].date();
        Date previousEndDate = mapLastAndPreviousMonthDateRange.get('previous')[1].date();
        
        String query = getCloudUsageQuery(customer.Id, mapLastAndPreviousMonthDateRange);
        
        //CR#458
        for (Cloud_Usage__c usage : Database.query(query)) {
            if (lastStartDate <= usage.Usage_Pull_Date__c && lastEndDate >= usage.Usage_Pull_Date__c) {

                totalLastTransactions = (usage.Total_Transactions__c != null ? usage.Total_Transactions__c : 0) + totalLastTransactions;
                totalLastBandwidth = (usage.Total_Transactions_Bandwidth__c != null ? usage.Total_Transactions_Bandwidth__c : 0) + totalLastBandwidth;
            } else if (previousStartDate <= usage.Usage_Pull_Date__c && previousEndDate >= usage.Usage_Pull_Date__c) {

                totalPreviousTransactions = (usage.Total_Transactions__c != null ? usage.Total_Transactions__c : 0) + totalPreviousTransactions;
                totalPreviousBandwidth = (usage.Total_Transactions_Bandwidth__c != null ? usage.Total_Transactions_Bandwidth__c : 0) + totalPreviousBandwidth;
            }
        }
        
        if (totalLastTransactions != null && totalPreviousTransactions != null && totalLastTransactions != 0 && totalPreviousTransactions != 0) {
            customer.Transactions_LM_vs_PM__c = calculatePercentage(totalLastTransactions, totalPreviousTransactions);
        }
        if (totalLastBandwidth != null && totalPreviousBandwidth != null && totalLastBandwidth != 0 && totalPreviousBandwidth != 0) {
            customer.Bandwidth_LM_Vs_PM__c = calculatePercentage(totalLastBandwidth, totalPreviousBandwidth);
        }
    }

    public void populateLastAnd6MonthUsage(Account customer) {
        Date todaysDate = Date.today();

        Decimal total6MLastTransactions = 0;
        Decimal total6MLastBandwidth = 0;
        Decimal total6MPreviousTransactions = 0;
        Decimal total6MPreviousBandwidth = 0;

        //List<Cloud_Usage__c> lastAnd6MonthList = getLastAnd6MonthUsage(customer);

        Map<String, List<Datetime>> mapLastAnd6MonthDateRange = LastAnd6MonthRange(todaysDate.month(), todaysDate.year());

        Date lastStartDate = mapLastAnd6MonthDateRange.get('last')[0].date();
        Date lastEndDate = mapLastAnd6MonthDateRange.get('last')[1].date();
        Date previousStartDate = mapLastAnd6MonthDateRange.get('previous')[0].date();
        Date previousEndDate = mapLastAnd6MonthDateRange.get('previous')[1].date();

        String query = getCloudUsageQuery(customer.Id, mapLastAnd6MonthDateRange);
        //CR#458
        for (Cloud_Usage__c usage : Database.query(query)) {
            if (lastStartDate <= usage.Usage_Pull_Date__c && lastEndDate >= usage.Usage_Pull_Date__c) {

                total6MLastTransactions = (usage.Total_Transactions__c != null ? usage.Total_Transactions__c : 0 ) + total6MLastTransactions;
                total6MLastBandwidth = (usage.Total_Transactions_Bandwidth__c != null ? usage.Total_Transactions_Bandwidth__c : 0) + total6MLastBandwidth;
            } else if (previousStartDate <= usage.Usage_Pull_Date__c && previousEndDate >= usage.Usage_Pull_Date__c) {

                total6MPreviousTransactions = (usage.Total_Transactions__c != null ? usage.Total_Transactions__c : 0) + total6MPreviousTransactions;
                total6MPreviousBandwidth =  (usage.Total_Transactions_Bandwidth__c != null ? usage.Total_Transactions_Bandwidth__c : 0) + total6MPreviousBandwidth;
            }
        }
        
        if (total6MLastTransactions != null && total6MPreviousTransactions != null && total6MLastTransactions != 0 && total6MPreviousTransactions != 0) {
            customer.Transactions_LM_vs_6M_Ago__c = calculatePercentage(total6MLastTransactions, total6MPreviousTransactions);
        }
        
        if (total6MLastBandwidth != null && total6MPreviousBandwidth != null && total6MLastBandwidth != 0 && total6MPreviousBandwidth != 0) {
            customer.Bandwidth_LM_Vs_6M_Ago__c = calculatePercentage(total6MLastBandwidth, total6MPreviousBandwidth);
        }
    }

    public void populateLastAnd12MonthUsage(Account customer) {
        Date todaysDate = Date.today();

        Decimal total12MLastTransactions = 0;
        Decimal total12MLastBandwidth = 0;
        Decimal total12MPreviousTransactions = 0;
        Decimal total12MPreviousBandwidth = 0;

        //List<Cloud_Usage__c> lastAnd12MonthList = getLastAnd12MonthUsage(customer);

        Map<String, List<Datetime>> mapLastAnd12MonthDateRange = LastAnd12MonthRange(todaysDate.month(), todaysDate.year());
        Date lastStartDate = mapLastAnd12MonthDateRange.get('last')[0].date();
        Date lastEndDate = mapLastAnd12MonthDateRange.get('last')[1].date();
        Date previousStartDate = mapLastAnd12MonthDateRange.get('previous')[0].date();
        Date previousEndDate = mapLastAnd12MonthDateRange.get('previous')[1].date();

        String query = getCloudUsageQuery(customer.Id, mapLastAnd12MonthDateRange);

        //CR#458
        for (Cloud_Usage__c usage : Database.query(query)) {
            if (lastStartDate <= usage.Usage_Pull_Date__c && lastEndDate >= usage.Usage_Pull_Date__c) {

                total12MLastTransactions = (usage.Total_Transactions__c != null ? usage.Total_Transactions__c : 0) + total12MLastTransactions;
                total12MLastBandwidth = (usage.Total_Transactions_Bandwidth__c != null ? usage.Total_Transactions_Bandwidth__c : 0) + total12MLastBandwidth;
            } else if (previousStartDate <= usage.Usage_Pull_Date__c && previousEndDate >= usage.Usage_Pull_Date__c) {

                total12MPreviousTransactions = usage.Total_Transactions__c+total12MPreviousTransactions;
                total12MPreviousBandwidth = (usage.Total_Transactions_Bandwidth__c != null ? usage.Total_Transactions_Bandwidth__c : 0) + total12MPreviousBandwidth;
            }
        }
        
        if (total12MLastTransactions != null && total12MPreviousTransactions != null && total12MLastTransactions != 0 && total12MPreviousTransactions != 0) {
            customer.Transactions_LM_vs_12M_Ago__c = calculatePercentage(total12MLastTransactions, total12MPreviousTransactions);
        }   
        
        if (total12MLastBandwidth != null && total12MPreviousBandwidth != null && total12MLastBandwidth != 0&& total12MPreviousBandwidth != 0) {
            customer.Bandwidth_LM_Vs_12M_Ago__c = calculatePercentage(total12MLastBandwidth, total12MPreviousBandwidth);
        }
    }

    public Map<String, Decimal> populateTotalUsage(Account customer) {
        Decimal totalEncryptedThreatsBlocks = 0;
        Decimal totalEncryptedtransactions=0;
        Decimal totalEncryptedInspectedtransactions=0;
        Decimal totalOffice365Transactions = 0;
        Decimal  SSLinspectedBytes=0;
        Decimal totalSSLbytes = 0;
        Decimal TotalOffice365 = 0;

        //List<Cloud_Usage__c> usageList = usage(customer);
        
        for(Cloud_Usage__c cloudUsage : [select Id,total_ssl_inspected_bytes__c,total_ssl_bytes__c,Total_Office_365_Kb__c, Total_Policy_Blocks__c,Total_Transactions__c,total_security_blocks__c,Encrypted_Threats_Blocked__c,Total_Office_365_Transactions__c, 
            total_botnet_blocks__c,Total_Transactions_Bandwidth__c,total_malware_site_blocks__c ,total_ssl_inspected_transactions__c,
            total_ssl_transactions__c,total_phishing_blocks__c,Authenticated_Kilobytes_del_del__c,
            User_Count__c  from Cloud_Usage__c where Cloud_Usage_Type__c= 'ZIA' and Account__c = :customer.Id 
            and Usage_Pull_Date__c = Last_N_months:3]) {
            //System.debug('---cloudUsage--'+cloudUsage);
            
            if(cloudUsage.Total_Transactions__c != null) {
                customer.Total_Transactions__c = customer.Total_Transactions__c + cloudUsage.Total_Transactions__c;
            }
            if(cloudUsage.Total_Transactions_Bandwidth__c != null) {
                customer.Total_Bandwidth__c = customer.Total_Bandwidth__c + cloudUsage.Total_Transactions_Bandwidth__c;
            }
            if(cloudUsage.Total_Policy_Blocks__c != null) {
                customer.Total_Policy_Blocks__c = customer.Total_Policy_Blocks__c + cloudUsage.Total_Policy_Blocks__c;
            }
            if(cloudUsage.total_botnet_blocks__c != null) {
                customer.Total_Botnet_Calls__c = customer.Total_Botnet_Calls__c + cloudUsage.total_botnet_blocks__c;
            }   
            if(cloudUsage.total_malware_site_blocks__c  != null) {
                customer.Total_Malware__c = customer.Total_Malware__c + cloudUsage.total_malware_site_blocks__c;
            }   
            if(cloudUsage.total_phishing_blocks__c  != null) {
                customer.Total_Phishing_Attacks__c = customer.Total_Phishing_Attacks__c  + cloudUsage.total_phishing_blocks__c;
            }   
            if(cloudUsage.total_security_blocks__c  != null) {
                customer.Total_Security_Blocks__c =  customer.Total_Security_Blocks__c  + cloudUsage.total_security_blocks__c;
            }
            
            totalEncryptedThreatsBlocks = (cloudUsage.Encrypted_Threats_Blocked__c != null ? cloudUsage.Encrypted_Threats_Blocked__c : 0) + totalEncryptedThreatsBlocks;
            totalEncryptedtransactions = (cloudUsage.total_ssl_transactions__c != null ? cloudUsage.total_ssl_transactions__c : 0) + totalEncryptedtransactions;
            totalEncryptedInspectedtransactions = (cloudUsage.total_ssl_inspected_transactions__c != null ? cloudUsage.total_ssl_inspected_transactions__c : 0) + totalEncryptedInspectedtransactions;
            totalOffice365Transactions = (cloudUsage.Total_Office_365_Transactions__c != null ? cloudUsage.Total_Office_365_Transactions__c : 0)  + totalOffice365Transactions;
            //Commented by Gurjinder : CR# 715 :Start
            //Added by Gurjinder:CR# 596 :Start 
            /* totalTransactions = (cloudUsage.Total_Transactions_Bandwidth__c != null ? cloudUsage.Total_Transactions_Bandwidth__c : 0)  + totalTransactions;
            system.debug('totalTransactions in kb '+totalTransactions);*/
            
            //Added by Gurjinder:CR# 596 :end 
            //Commented by Gurjinder : CR# 715 :End
            
            system.debug('cloudUsage.total_ssl_inspected_bytes__c '+cloudUsage.total_ssl_inspected_bytes__c);
            SSLinspectedBytes = (cloudUsage.total_ssl_inspected_bytes__c != null ? cloudUsage.total_ssl_inspected_bytes__c : 0)  + SSLinspectedBytes;
            totalSSLbytes = (cloudUsage.total_ssl_bytes__c != null ? cloudUsage.total_ssl_bytes__c : 0)  + totalSSLbytes;
            TotalOffice365 = (cloudUsage.Total_Office_365_Kb__c != null ? cloudUsage.Total_Office_365_Kb__c : 0)  + TotalOffice365;                     
        }

        Map<String, Decimal> variableNameToValueMap = new Map<String, Decimal>();
        variableNameToValueMap.put('totalEncryptedThreatsBlocks', totalEncryptedThreatsBlocks);
        variableNameToValueMap.put('totalEncryptedtransactions', totalEncryptedtransactions);
        variableNameToValueMap.put('totalEncryptedInspectedtransactions', totalEncryptedInspectedtransactions);
        variableNameToValueMap.put('totalOffice365Transactions', totalOffice365Transactions);
        variableNameToValueMap.put('SSLinspectedBytes', SSLinspectedBytes);
        variableNameToValueMap.put('totalSSLbytes', totalSSLbytes);
        variableNameToValueMap.put('TotalOffice365', TotalOffice365);

        return variableNameToValueMap;
    }

    // IBA-3197 END
}