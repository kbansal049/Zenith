/*
TestClass AccountCustomerLifeCycleBatchTest
*/

global class AccountCustomerLifeCycleBatchSch implements Schedulable
{
    global AccountCustomerLifeCycleBatchSch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        Integer batchSize = Integer.valueOf(Label.Contract_Dates);
        //Added First_Contract_Date__c, First_ZPA_Contract_Date__c,Date_when_traffic_consumed_is_25__c,X25_ZPA_Traffic_attained_date__c to Query by Swathi CR:1566
        if(!Test.isRunningTest()){
            Database.executeBatch(new AccountCustomerLifeCycleBatch('SELECT Id, Type, CSM_Name_New__c, Last_QBR_Date__c, Avg_Estimated_Users_L31D_Vs_Purchase__c, ZPA_Enrolled_users_L31D_Vs_Purchase__c, Users_with_ZApp__c, Users_ZPA_Platform__c, First_Contract_Date__c, First_ZPA_Contract_Date__c,Date_when_traffic_consumed_is_25__c,X25_ZPA_Traffic_attained_date__c,No_of_Platform_Seats__c,Customer_Lifecycle__c FROM ACCOUNT WHERE Type = \'Customer\''),batchSize);
        }
     }
 }