global class Renewal_Notification_Batch_180Sch implements Schedulable
{
    global Renewal_Notification_Batch_180Sch()
    {
    }
    
    global void execute(SchedulableContext SC)
    {
        Extension_Expiry_Notification_Batch batch;
        string query = 'Select Id, Owner.Name, Owner.Email, Contract_End_Date_New__c, Renewable_ACV__c, CloseDate, Renewal_Amount__c, Account.Sales_Engineer__r.Name, Account.Channel_Manager__r.Name,Account.Name, Account.CSM_NAMEOverlay__c, Account.TAM_Name_New__r.Name, Account.Solution_Architect_Name__c, Account.Customer_Advocate__c, Account.Customer_Advocate__r.Name, Account.Owner.Name, Account.Secondary_TAM_Name__r.Email, Account.Secondary_TAM_Name__c, Account.Channel_Manager__r.Email, Account.Channel_Manager__c, Account.TAM_Name_New__r.Email, Account.TAM_Name_New__c, Account.Account_Manager__r.Email, Account.Account_Manager__c, Account.Customer_Advocate__r.Email, Account.Sales_Engineer__r.Email, Account.CSM_Name_New__c, Account.CSM_Name_New__r.Email, Account.Solution_Architect__c, Account.Solution_Architect__r.Email, Account.Id, Name from Opportunity where Contract_End_Date_New__c =: day AND Recordtype.name = \'Renewal Opportunity\' and Type =\'Existing Customer (Renewal)\' AND StageName NOT IN: StrList';
        batch = new Extension_Expiry_Notification_Batch(query,180);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch,1);
        }
     }
 }