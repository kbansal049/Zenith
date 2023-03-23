public class CustomerSummaryScorecardSchedule implements Schedulable{
    public void execute(SchedulableContext ctx)
    {
        String query = 'select Id, Account__r.Name,account__r.No_of_Platform_Seats__c, Total_Transactions__c, Total_Policy_Blocks__c,'+
            'Total_Botnet_Calls__c, Total_Malware__c,Total_Bandwidth__c,Total_Transactions_Same_Time__c,'+
            'Total_Bandwidth_Same_Time__c,Total_Phishing_Attacks__c,Total_Security_Blocks__c,Problem_tickets_per_b_transactions__c, '+
            'Auth_ZIA_users_deployed_LM_Vs_LM_1__c,Auth_ZIA_users_deployed_LM_Vs_LM_12__c,Auth_ZIA_users_deployed_LM_Vs_LM_6__c, '+
            'Qualified_SSL_inspected_bytes_LM_1__c,Qualified_SSL_inspected_bytes_LM_12__c,Qualified_SSL_inspected_bytes_LM_6__c, '+
            'ZPA_Active_Users_LM_Vs_LM_1__c,ZPA_Active_Users_LM_Vs_LM_12__c,ZPA_Active_Users_LM_Vs_LM_6__c, '+
            'Client_connector_users_LM_Vs_LM_1__c,Client_connector_users_LM_Vs_LM_12__c,Client_connector_users_LM_Vs_LM_6__c, '+
            'Problem_ticket_per_b_trans_LM_Vs_LM_12__c,Problem_tickets_per_b_trans_LM_Vs_LM_1__c,Problem_tickets_per_b_trans_LM_Vs_LM_6__c, '+
            'Value_Summary_Months__c,Total_Bandwidth_Growth__c,Total_Transaction_Growth__c,Account__r.Id,Account__c,Account_Auth_Bytes_31D__c,Account_Auth_Bytes_90D__c, '+
            'Total_Bytes_31D__c,Total_Bytes_90D__c,Unique_Authenticated_Users_31D__c,Unique_Authenticated_Users_90D__c from Customer_Score_card__c where Account__r.No_of_Platform_Seats__c > 0 and Account__r.Type=\'Customer\' and Account__r.Skip_Value_Summary_Generation__c = false';
		
		CustomerSummaryScorecardBatch cus = new CustomerSummaryScorecardBatch(query);
		
        Database.executeBatch(cus,1);
    }
}