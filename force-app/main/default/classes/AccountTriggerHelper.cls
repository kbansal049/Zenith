/**
 * @File Name          : AccountTriggerHelper.cls
 * @Description        : 
 * @Author             : pranjalsingh@zscaler.com
 * @Group              : 
 * @Last Modified By   : pranjalsingh@zscaler.com
 * @Last Modified On   : 14/7/2019, 12:40:28 PM
 * @Modification Log   : 
 *------------------------------------------------------------------------------
 * Ver         Date                     Author                    Modification
 *------------------------------------------------------------------------------
 * 1.0    22/5/2019, 6:26:03 PM   pranjalsingh@zscaler.com     Initial Version
 * 2.0    1/6/2020, 7:28:00 PM    pdoshi@zscaler.com           Remove SCI Dependencies, Include Event CR# 349
 * 3.0    9/6/2020, 3:53:00 PM    pdoshi@zscaler.com           Add logic to create Account Extension History CR# 473
 * 4.0    31/01/2022              Chandan Panigrahy            CR# 4040 - Added logic for Federal account type and recordType update and removed potential null pointer issues
 **/

@SuppressWarnings('PMD.CyclomaticComplexity,PMD.CognitiveComplexity')
public class AccountTriggerHelper {
    
    public static boolean isOppPresent; // Checks if Opp List is non-empty
    public static boolean isSCIPresent; // Checks if SCI List is non-empty
    public static Boolean validationEndStage08 = false;
    public static boolean validationEndStage17 = false;
    public static boolean openLatestSCIPresent = false;
    public static boolean validOppClose = false;
    public static set < String > closedOpps = new set < String > {
        label.Stage_7_Closed_Lost
        //'11 - Closed Lost',
        //'12 - Closed With No Decision'
    };
        
    public static set < String > openOpps = new set < String > {
        //'1 - Qualified and Budgeted',
        label.Stage_1_Alignment,
        //'2 - Technical Validation',
        label.Stage_2_Qualified_Budgeted,
        //'7 - Negotiation & Review',
        //'8 - Expecting Order',
        //'9 - Deal Stuck',
        label.Stage_4_Economic_Buyer_Signoff,
        //'10b - PO recd, pending finance approval'
        label.Stage_5_Contracts_Complete,
        label.Stage_5A_Opportunity,
        label.Stage_5B_Opportunity,
        label.Stage_5C_Opportunity
    };
    public static set < String > validation_stage_pipeline = new set < String > {
        '0 - Not Started',
        '8A - Not Required',
        '8B - Not Required - Preferred',
        ''
    };
    public static set < String > validation_stage_POC = new set < String > {
        '1 - Establishing Plan & success criteria',
        '2 - Configuration in Progress',
        '3 - Detailed validation in progress',
        '4 - Delivering validation findings report',
        '5 - Validation Stalled',
        '5b - Pending customer decision',
        '6 - Technical Win',
        '7 - Technical Loss'
    };

        
        //This piece of code is moved to AccountAsyncTriggerHelper
        
        
    /*public static void changeRelatedContactsOwner(list < Account > accountNewList, map < Id, Account > accountOldMap) {
        list < Contact > contactUpdateList = new list < Contact > ();
        map < Id, Id > accIdOwnerIdMap = new map < Id, Id > ();
        set < Id > activeUserIdSet = new set < Id > ();
        for (Account acc: accountNewList) {
            if (acc.ownerId != accountOldMap.get(acc.Id).ownerId) {
                accIdOwnerIdMap.put(acc.id, acc.OwnerId);
            }
        }

        if (!accIdOwnerIdMap.values().isEmpty()) {

            for (User usr: [select id from user where isActive =: true and ID IN: accIdOwnerIdMap.values()]) {
                activeUserIdSet.add(usr.Id);
            }

            for (Contact con: [Select Id, OwnerId, AccountId from Contact WHERE AccountId IN: accIdOwnerIdMap.keyset()]) {
                if (con.OwnerId != accIdOwnerIdMap.get(con.AccountId) && activeUserIdSet.contains(accIdOwnerIdMap.get(con.AccountId)))
                    contactUpdateList.add(new Contact(Id = con.Id, ownerId = accIdOwnerIdMap.get(con.AccountId)));
            }

            if (!contactUpdateList.isEmpty())
                Database.update(contactUpdateList, false);
        }
        TriggerUtility.accToContactOwnerExecuted();
    }*/

    public static void getAccSalesTeam(list < Account > accountNewList, map < Id, Account > accountOldMap) {
        system.debug('in getAccSalesTeam method');
        if(TriggerUtility.accSalesTeamMethodExecution<2){
            set < id > salesTerritoryIdSet = new set < id > ();
            for (Account acc: accountNewList) {
                if(acc.Sales_Territory__c!= null/*  && acc.Sales_Territory__c != accountOldMap.get(acc.Id).Sales_Territory__c */) {
                    salesTerritoryIdSet.add(acc.Sales_Territory__c);
                }
            }
            system.debug('salesTerritoryIdSet   '+salesTerritoryIdSet);
            Map < String, Id > territorySalesUserIdMap = new Map < String, Id > ();
            if (!salesTerritoryIdSet.isEmpty()) {
                for (PatchTeam__c territory: [Select id, Lead_Development__c, (Select Id, Role__c, PatchTeam__c, User__c from PatchTeamMembers__r) from PatchTeam__c where ID IN: salesTerritoryIdSet]) {
                    
                    for (PatchTeamMember__c salesTeam: territory.PatchTeamMembers__r) {
                        if (salesTeam.Role__c == 'Account Manager')
                            territorySalesUserIdMap.put('' + territory.id + 'AccountManager', salesTeam.User__c);
                        if (salesTeam.Role__c == 'Area Director')
                            territorySalesUserIdMap.put('' + territory.id + 'AreaDirector', salesTeam.User__c);
                        if (salesTeam.Role__c == 'Channel Manager')
                            territorySalesUserIdMap.put('' + territory.id + 'ChannelManager', salesTeam.User__c);
                        if (salesTeam.Role__c == 'Customer Advocate')
                            territorySalesUserIdMap.put('' + territory.id + 'CustomerAdvocate', salesTeam.User__c);
                        if (salesTeam.Role__c == 'Sales Engineer')
                            territorySalesUserIdMap.put('' + territory.id + 'SalesEngineer', salesTeam.User__c);
                        if (salesTeam.Role__c == 'ZPA Manager')
                            territorySalesUserIdMap.put('' + territory.id + 'ZPAManager', salesTeam.User__c);
                        if (salesTeam.Role__c == 'ZPA SE')
                            territorySalesUserIdMap.put('' + territory.id + 'ZPASE', salesTeam.User__c);
                        if (salesTeam.Role__c == 'Lead Development')
                            territorySalesUserIdMap.put('' + territory.id + 'LeadDevelopment', salesTeam.User__c);
                    }
                }
                system.debug('territorySalesUserIdMap   '+territorySalesUserIdMap);
                for (Account acc: accountNewList) {
                    if(acc.Sales_Territory__c != null /*&& acc.Sales_Territory__c != accountOldMap.get(acc.Id).Sales_Territory__c */){
                        acc.Area_Director__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'AreaDirector');
                        acc.Account_Manager__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'AccountManager');
                        acc.Channel_Manager__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'ChannelManager');
                        acc.Customer_Advocate__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'CustomerAdvocate');
                        acc.Sales_Engineer__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'SalesEngineer');
                        //acc.ZPA_Manager__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'ZPAManager');
                        //acc.ZPA_SE__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'ZPASE');
                        acc.lead_development2__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'LeadDevelopment');
                    } else {
                        if(OnOffSwitch__c.getInstance('updateSalesTeamBlankifSTnotchng')!=null && OnOffSwitch__c.getInstance('updateSalesTeamBlankifSTnotchng').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('updateSalesTeamBlankifSTnotchng').Deactivate_Component__c==False){
                            acc.Area_Director__c = null;
                            acc.Account_Manager__c = null;
                            acc.Channel_Manager__c = null;
                            acc.Customer_Advocate__c = null;
                            acc.Sales_Engineer__c = null;
                            //acc.ZPA_Manager__c = null;
                            //acc.ZPA_SE__c = null;
                            acc.lead_development2__c=null;
                        }
                    }
                }
                //TriggerUtility.accSalesTeamExecuted(); //Commented as Patch has been changed,Sales team was not getting updated,Sales Team was getting updated if Account has been triggered twice 
                TriggerUtility.accSalesTeamMethodExecution=TriggerUtility.accSalesTeamMethodExecution+1;
            }
        }

    }

    //Changed by Viral : CR# 318: AmberRoad Fixes : Start
    public static void screenAccountsWithAmberRoad(List <Account> accountsToBeScreenedList,Map<id,Account> triggerOldMap) {
        System.debug('AccountTriggerHelper screenAccountsWithAmberRoad triggerOldMap : ' + triggerOldMap);
        System.debug('AccountTriggerHelper screenAccountsWithAmberRoad accountsToBeScreenedList : ' + accountsToBeScreenedList);    
        List<Amber_Road_Screen_Account__e> amberRoadAccountScreenEvents = new List<Amber_Road_Screen_Account__e>();   
        
        for (Account newAccount: accountsToBeScreenedList) {
            if(
                (
                    newAccount.Type == 'Prospect'|| newAccount.Type == 'Customer' || newAccount.Type == 'Partner'
                )  && 
                
                newAccount.Geo__c != 'Public Sector' && 
                
               (newAccount.BillingStreet!=triggerOldMap.get(newAccount.id).BillingStreet ||
                newAccount.BillingCity!=triggerOldMap.get(newAccount.id).BillingCity ||
                newAccount.BillingState!=triggerOldMap.get(newAccount.id).BillingState ||
                newAccount.BillingCountry!=triggerOldMap.get(newAccount.id).BillingCountry ||
                newAccount.BillingPostalCode!=triggerOldMap.get(newAccount.id).BillingPostalCode ||
                newAccount.Fax!=triggerOldMap.get(newAccount.id).Fax ||
                newAccount.Phone!=triggerOldMap.get(newAccount.id).Phone
               )){ 
                //create and publish platform events for each account, each event contains a serialized acct and will initiate an acct screening from amber road
                amberRoadAccountScreenEvents.add(new Amber_Road_Screen_Account__e(Account__c = JSON.serialize(newAccount)));            
            }
        }
        if(amberRoadAccountScreenEvents.size()>0){
            System.debug('AccountTriggerHelper screenAccountsWithAmberRoad amberRoadAccountScreenEvents : ' + amberRoadAccountScreenEvents);
            List<Database.SaveResult> amberRoadAccountScreenResults = EventBus.publish(amberRoadAccountScreenEvents); 
            //debug results of amber road screening
            for(Database.SaveResult screenResult : amberRoadAccountScreenResults){
                if(screenResult.isSuccess()){
                    System.debug('--Successfully published AmberRoad account screening event--');
                }else{
                    List<Zscaler_Error_Logs__c> zsErrorLogsList = new List<Zscaler_Error_Logs__c>();
                    for(Database.Error err : screenResult.getErrors()) {
                        System.debug('AmberRoad Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                        Zscaler_Error_Logs__c logObj = new Zscaler_Error_Logs__c(
                            Class_Name__c = 'AccountTriggerHelper',
                            Method_Name__c = 'screenAccountsWithAmberRoad',
                            Error_in__c = 'Apex',
                            User__c  = UserInfo.getUserId(),
                            Biz_Area__c  = 'Sales Cloud',
                            Stack_Trace_String__c = 'Error in publishing AmberRoad account screening event, '  + err.getStatusCode() + 
                                      ' - ' + err.getMessage() + ', field names - ' + err.getFields(), 
                            Exception_info__c = 'Error in publishing AmberRoad account screening event, '  + err.getStatusCode() + 
                                      ' - ' + err.getMessage() + ', field names - ' + err.getFields()
                        );
                        zsErrorLogsList.add(logObj);
                    }
                    if(!zsErrorLogsList.isEmpty()){
                        Database.SaveResult[] zsErrorLogsSaveResList = Database.insert(zsErrorLogsList,false);
                        for(Database.SaveResult sr : zsErrorLogsSaveResList) {
                            if (!sr.isSuccess()) {
                                system.debug('INSERT_FAILED : ' + sr.getErrors());
                            }
                        }
                    }
                }
            }
        }
        TriggerUtility.ScreenAccountsWithAmberRoadExecutedsettrue();
        
    }
    //Changed by Viral : CR# 318: AmberRoad Fixes : End

    //CR# 318 AmberRoad : Starts : For Prospect Account
    public static void screenAccountsWithAmberRoad(List<Account> accountsToBeScreenedList) {
        System.debug('---screenAccountsWithAmberRoad--called---');
        System.debug('AccountTriggerHelper screenAccountsWithAmberRoad accountsToBeScreenedList : ' + accountsToBeScreenedList);
        List<Amber_Road_Screen_Account__e> amberRoadAccountScreenEvents = new List<Amber_Road_Screen_Account__e>();        
        for (Account accountToBeScreened : accountsToBeScreenedList) {
            if((accountToBeScreened.type=='Prospect'|| accountToBeScreened.Type == 'Customer' || accountToBeScreened.Type == 'Partner') && accountToBeScreened.Geo__c != 'Public Sector'){          // Updated by Ayush As part of CR#4824
                //create and publish platform events for each account, each event contains a serialized acct and will initiate an acct screening from amber road
                amberRoadAccountScreenEvents.add(new Amber_Road_Screen_Account__e(Account__c = JSON.serialize(accountToBeScreened)));            
            }
        }
        if(amberRoadAccountScreenEvents.size()>0){
            System.debug('AccountTriggerHelper screenAccountsWithAmberRoad amberRoadAccountScreenEvents : ' + amberRoadAccountScreenEvents);
            List<Database.SaveResult> amberRoadAccountScreenResults = EventBus.publish(amberRoadAccountScreenEvents); 
            //debug results of amber road screening
            for(Database.SaveResult screenResult : amberRoadAccountScreenResults){
                if(screenResult.isSuccess()){
                    System.debug('--Successfully published AmberRoad account screening event--');
                }else{
                    List<Zscaler_Error_Logs__c> zsErrorLogsList = new List<Zscaler_Error_Logs__c>();
                    for(Database.Error err : screenResult.getErrors()) {
                        System.debug('AmberRoad Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                        Zscaler_Error_Logs__c logObj = new Zscaler_Error_Logs__c(
                            Class_Name__c = 'AccountTriggerHelper',
                            Method_Name__c = 'screenAccountsWithAmberRoad',
                            Error_in__c = 'Apex',
                            User__c  = UserInfo.getUserId(),
                            Biz_Area__c  = 'Sales Cloud',
                            Stack_Trace_String__c = 'Error in publishing AmberRoad account screening event, '  + err.getStatusCode() + 
                                      ' - ' + err.getMessage() + ', field names - ' + err.getFields(), 
                            Exception_info__c = 'Error in publishing AmberRoad account screening event, '  + err.getStatusCode() + 
                                      ' - ' + err.getMessage() + ', field names - ' + err.getFields()
                        );
                        zsErrorLogsList.add(logObj);
                    }
                    if(!zsErrorLogsList.isEmpty()){
                        Database.SaveResult[] zsErrorLogsSaveResList = Database.insert(zsErrorLogsList,false);
                        for(Database.SaveResult sr : zsErrorLogsSaveResList) {
                            if (!sr.isSuccess()) {
                                system.debug('INSERT_FAILED : ' + sr.getErrors());
                            }
                        }
                    }
                }
            }
        }
        TriggerUtility.ScreenAccountsWithAmberRoadExecutedsettrue();
    }
    //CR# 318 AmberRoad : Ends
    
    //Method for populating country code and state code on account (IBA - 1690):START
    public static void setCountryStateCodeOnAccount(List<Account> accList )
    {
        for (Account accountToBeScreened : accList) {
            if(accountToBeScreened.BillingCountry != NULL)
            {
                if(accountToBeScreened.Country_Code__c != NULL && API_Country_Mapping__c.getInstance(accountToBeScreened.BillingCountry.toLowerCase()) == NULL){
                    accountToBeScreened.Country_Code__c = NULL;
                }
                else if(API_Country_Mapping__c.getInstance(accountToBeScreened.BillingCountry.toLowerCase()) != NULL){ 
                accountToBeScreened.Country_Code__c = API_Country_Mapping__c.getInstance(accountToBeScreened.BillingCountry.toLowerCase()).Amber_Road_Country_Code__c;
            }
            }else{accountToBeScreened.Country_Code__c = NULL;}
            if(accountToBeScreened.BillingState != NULL)
            {
                if(accountToBeScreened.State_Code__c != NULL && API_States_Mapping__c.getInstance(accountToBeScreened.BillingState.toLowerCase()) == NULL){
                    accountToBeScreened.State_Code__c = NULL;
                }
                else if(API_States_Mapping__c.getInstance(accountToBeScreened.BillingState.toLowerCase()) != NULL){
                accountToBeScreened.State_Code__c = API_States_Mapping__c.getInstance(accountToBeScreened.BillingState.toLowerCase()).Amber_Road_State_Code__c;
            }
            }else{accountToBeScreened.State_Code__c = NULL;}
        }
    }
	
    public static void insertLogForCountryStateCode(List<Account> accList)
    {
        List<Zscaler_Error_Logs__c> zsErrorLogsList = new List<Zscaler_Error_Logs__c>();
        for (Account acc : accList)
        {
            if(acc.Country_Code__c == NULL || acc.State_Code__c == NULL)
            {
                Zscaler_Error_Logs__c logObj = new Zscaler_Error_Logs__c(
                    Class_Name__c = 'AccountTriggerHelper',
                    Method_Name__c = 'setCountryStateCodeOnAccount',
                    Error_in__c = 'Apex',
                    User__c  = UserInfo.getUserId(),
                    Biz_Area__c  = 'Sales Cloud',
                    Stack_Trace_String__c = 'Billing Country/Billing State not present in Custom Setting values, '  + ' - ' + 'Account Id -' + acc.id + 'Account Name -' + acc.Name
                    + ' Billing Country -' +  acc.BillingCountry + ' Billing State -' + acc.BillingState +' Country Code -' + acc.Country_Code__c +' State Code -' + acc.State_Code__c,
                    Exception_info__c = 'Billing Country/Billing State not present in Custom Setting values, '  + ' - ' + 'Account Id -' + acc.id + 'Account Name -' + acc.Name
                    + ' Billing Country -' +  acc.BillingCountry + ' Billing State -' + acc.BillingState +' Country Code -' + acc.Country_Code__c +' State Code -' + acc.State_Code__c
                    );
                zsErrorLogsList.add(logObj);
            }
            
        }
        if(!zsErrorLogsList.isEmpty()){
            Database.SaveResult[] zsErrorLogsSaveResList = Database.insert(zsErrorLogsList,false);
            for(Database.SaveResult sr : zsErrorLogsSaveResList) {
                if (!sr.isSuccess()) {
                    system.debug('INSERT_FAILED : ' + sr.getErrors());
                }
            }
        }
       
    }
 
    //IBA - 1690 : END
    

    public static void captureCustomerNextStepsHistory(List < Account > newAccounts, Map < Id, Account > oldAccounts) {
        List < Customer_Next_Steps_History__c > lstCNSHistoryToInsert = new List < Customer_Next_Steps_History__c > ();

        for (Account account: newAccounts) {
            if (oldAccounts != null &&
                oldAccounts.containsKey(account.Id) &&
                oldAccounts.get(account.Id).Customer_Next_Steps__c != null && oldAccounts.get(account.Id).Customer_Next_Steps__c != account.Customer_Next_Steps__c) {
                lstCNSHistoryToInsert.add(new Customer_Next_Steps_History__c(Account__c = account.Id, Next_Steps__c = oldAccounts.get(account.Id).Customer_Next_Steps__c));
            }
        }

        try {
            Database.insert(lstCNSHistoryToInsert, false);
            TriggerUtility.captureCustomerNextStepsHistoryExecuted();
        } catch (Exception ex) {
            System.debug('Error occurred while creating Customer Next Steps History records: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
    

    // Vijay - 03/26/2018: Commenting this out as the logic will be handled by contact trigger
    // public static void updateContactWhitespaceRole(list<Account> newAccList, map<id, Account> oldAccMap){
    //
    //     TriggerUtility.conWhiteSpaceUpdateExecuted();
    //
    //     map<Id, Contact> conUpdateMap = new map<Id, Contact>();
    //
    //     Contact tempCon = new Contact();
    //
    //     for(Account acc : newAccList){
    //
    //         if(acc.HeadofIT__c != null && acc.HeadofIT__c != oldAccMap.get(acc.id).HeadofIT__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.HeadofIT__c))
    //                 tempCon = conUpdateMap.get(acc.HeadofIT__c);
    //             else
    //                 tempCon.Id = acc.HeadOfIt__c;
    //             tempCon.Head_Of_It__c = true;
    //             conUpdateMap.put(acc.HeadOfIt__c, tempCon);
    //             if(oldAccMap.get(acc.id).HeadofIT__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).HeadofIT__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).HeadofIT__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).HeadofIT__c;
    //                 tempCon.Head_Of_It__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).HeadofIT__c, tempCon);
    //             }
    //         }else if(acc.HeadofIT__c == null && acc.HeadofIT__c != oldAccMap.get(acc.id).HeadofIT__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).HeadofIT__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).HeadofIT__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).HeadofIT__c;
    //             tempCon.Head_Of_It__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).HeadofIT__c, tempCon);
    //         }
    //         if(acc.HeadofNetworking__c != null && acc.HeadofNetworking__c != oldAccMap.get(acc.id).HeadofNetworking__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.HeadofNetworking__c))
    //                 tempCon = conUpdateMap.get(acc.HeadofNetworking__c);
    //             else
    //                 tempCon.Id = acc.HeadofNetworking__c;
    //             tempCon.Head_of_Networking__c = true;
    //             conUpdateMap.put(acc.HeadofNetworking__c, tempCon);
    //
    //             if(oldAccMap.get(acc.id).HeadofNetworking__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).HeadofNetworking__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).HeadofNetworking__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).HeadofNetworking__c;
    //                 tempCon.Head_of_Networking__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).HeadofNetworking__c, tempCon);
    //             }
    //
    //
    //         }else if(acc.HeadofNetworking__c == null && acc.HeadofNetworking__c != oldAccMap.get(acc.id).HeadofNetworking__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).HeadofNetworking__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).HeadofNetworking__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).HeadofNetworking__c;
    //             tempCon.Head_of_Networking__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).HeadofNetworking__c, tempCon);
    //         }
    //
    //         if(acc.BudgetAuthority__c != null && acc.BudgetAuthority__c != oldAccMap.get(acc.id).BudgetAuthority__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.BudgetAuthority__c))
    //                 tempCon = conUpdateMap.get(acc.BudgetAuthority__c);
    //             else
    //                 tempCon.Id = acc.BudgetAuthority__c;
    //             tempCon.Budget_Authority__c = true;
    //             conUpdateMap.put(acc.BudgetAuthority__c, tempCon);
    //             if(oldAccMap.get(acc.id).BudgetAuthority__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).BudgetAuthority__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).BudgetAuthority__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).BudgetAuthority__c;
    //                 tempCon.Budget_Authority__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).BudgetAuthority__c, tempCon);
    //             }
    //         }else if(acc.BudgetAuthority__c == null && acc.BudgetAuthority__c != oldAccMap.get(acc.id).BudgetAuthority__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).BudgetAuthority__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).BudgetAuthority__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).BudgetAuthority__c;
    //             tempCon.Budget_Authority__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).BudgetAuthority__c, tempCon);
    //         }
    //
    //
    //         if(acc.HeadofSecurity__c != null && acc.HeadofSecurity__c != oldAccMap.get(acc.id).HeadofSecurity__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.HeadofSecurity__c))
    //                 tempCon = conUpdateMap.get(acc.HeadofSecurity__c);
    //             else
    //                 tempCon.Id = acc.HeadofSecurity__c;
    //             tempCon.Head_of_Security__c = true;
    //             conUpdateMap.put(acc.HeadofSecurity__c, tempCon);
    //             if(oldAccMap.get(acc.id).HeadofSecurity__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).HeadofSecurity__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).HeadofSecurity__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).HeadofSecurity__c;
    //                 tempCon.Head_of_Security__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).HeadofSecurity__c, tempCon);
    //             }
    //
    //
    //         }else if(acc.HeadofSecurity__c == null && acc.HeadofSecurity__c != oldAccMap.get(acc.id).HeadofSecurity__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).HeadofSecurity__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).HeadofSecurity__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).HeadofSecurity__c;
    //             tempCon.Head_of_Security__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).HeadofSecurity__c, tempCon);
    //        }
    //
    //         if(acc.ProcurementContact__c != null && acc.ProcurementContact__c != oldAccMap.get(acc.id).ProcurementContact__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.ProcurementContact__c))
    //                 tempCon = conUpdateMap.get(acc.ProcurementContact__c);
    //             else
    //                 tempCon.Id = acc.ProcurementContact__c;
    //             tempCon.Procurement_Contact__c = true;
    //             conUpdateMap.put(acc.ProcurementContact__c, tempCon);
    //             if(oldAccMap.get(acc.id).ProcurementContact__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).ProcurementContact__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).ProcurementContact__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).ProcurementContact__c;
    //                 tempCon.Procurement_Contact__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).ProcurementContact__c, tempCon);
    //             }
    //
    //         }else if(acc.ProcurementContact__c == null && acc.ProcurementContact__c != oldAccMap.get(acc.id).ProcurementContact__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).ProcurementContact__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).ProcurementContact__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).ProcurementContact__c;
    //             tempCon.Procurement_Contact__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).ProcurementContact__c, tempCon);
    //        }
    //
    //        if(acc.Service_Owner__c != null && acc.Service_Owner__c != oldAccMap.get(acc.id).Service_Owner__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.Service_Owner__c))
    //                 tempCon = conUpdateMap.get(acc.Service_Owner__c);
    //             else
    //                 tempCon.Id = acc.Service_Owner__c;
    //             tempCon.Service_Owner__c = true;
    //             conUpdateMap.put(acc.Service_Owner__c, tempCon);
    //             if(oldAccMap.get(acc.id).Service_Owner__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).Service_Owner__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).Service_Owner__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).Service_Owner__c;
    //                 tempCon.Service_Owner__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).Service_Owner__c, tempCon);
    //             }
    //
    //         }else if(acc.Service_Owner__c == null && acc.Service_Owner__c != oldAccMap.get(acc.id).Service_Owner__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).Service_Owner__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).Service_Owner__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).Service_Owner__c;
    //             tempCon.Service_Owner__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).Service_Owner__c, tempCon);
    //        }
    //
    //        if(acc.CloudArchitect__c != null && acc.CloudArchitect__c != oldAccMap.get(acc.id).CloudArchitect__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.CloudArchitect__c))
    //                 tempCon = conUpdateMap.get(acc.CloudArchitect__c);
    //             else
    //                 tempCon.Id = acc.CloudArchitect__c;
    //             tempCon.Cloud_Architect__c = true;
    //             conUpdateMap.put(acc.CloudArchitect__c, tempCon);
    //             if(oldAccMap.get(acc.id).CloudArchitect__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).CloudArchitect__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).CloudArchitect__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).CloudArchitect__c;
    //                 tempCon.Cloud_Architect__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).CloudArchitect__c, tempCon);
    //             }
    //
    //         }else if(acc.CloudArchitect__c == null && acc.CloudArchitect__c != oldAccMap.get(acc.id).CloudArchitect__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).CloudArchitect__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).CloudArchitect__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).CloudArchitect__c;
    //             tempCon.Cloud_Architect__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).CloudArchitect__c, tempCon);
    //        }
    //     }
    //
    //     if(conUpdateMap != null && !conUpdateMap.values().isEmpty())
    //         database.update(conUpdateMap.Values(), false);
    //
    //     TriggerUtility.accContactWhiteSpaceUpdateExecuted();
    //
    // }

    public static void updateSENamesInOpportunity(List < Account > newAccList, Map < Id, Account > oldAccMap) {
        Map < Id, Account > mapAccountSENames = new Map < Id, Account > ();
        List < Opportunity > lstOpportunitiesToUpdate = new List < Opportunity > ();

        for (Account acct: newAccList) {
            
            if ((null != acct.Sales_Engineer__c ||
                    null != acct.Sales_Territory__c ||
                    null != acct.Account_Manager__c ||
                    null != acct.Area_Director__c ||
                    null != acct.Customer_Advocate__c ||
                    null != acct.Channel_Manager__c /**||
                    null != acct.ZPA_Manager__c ||
                    null != acct.ZPA_SE__c**/) && 
                ((null != oldAccMap && //Updated the logic to remove the potential null pointer issue
                    null != oldAccMap.get(acct.Id)) &&
                    (acct.Sales_Engineer__c != oldAccMap.get(acct.Id).Sales_Engineer__c ||  //Commented by Gurjinder : CR# 315
                    acct.Channel_Manager__c != oldAccMap.get(acct.Id).Channel_Manager__c ||
                    acct.Customer_Advocate__c != oldAccMap.get(acct.Id).Customer_Advocate__c ||
                    acct.Area_Director__c != oldAccMap.get(acct.Id).Area_Director__c ||
                    acct.Account_Manager__c != oldAccMap.get(acct.Id).Account_Manager__c ||
                    /**acct.ZPA_Manager__c != oldAccMap.get(acct.Id).ZPA_Manager__c ||
                    acct.ZPA_SE__c != oldAccMap.get(acct.Id).ZPA_SE__c ||**/
                    acct.Sales_Territory__c != oldAccMap.get(acct.Id).Sales_Territory__c))) {
                mapAccountSENames.put(acct.Id, acct);
            }
        }
        System.debug('mapAccountSENames '+mapAccountSENames);
        
        String Closed_Won = label.Stage_6_Closed_Won;
        if(mapAccountSENames!=null){
            for (Opportunity oppty: [SELECT Id, AccountId, SE_Name__c FROM Opportunity
                    WHERE AccountId IN: mapAccountSENames.keySet()
                    AND IsClosed <> true
                    AND StageName !=: Closed_Won
                ]) {
                //if (oppty.SE_Name__c != mapAccountSENames.get(oppty.AccountId)) {
                Opportunity opp= new Opportunity(Id = oppty.Id,
                    Opportunity_Sales_Engineer__c = mapAccountSENames.get(oppty.AccountId).Sales_Engineer__c,
                    Opportunity_Sales_Territory__c = mapAccountSENames.get(oppty.AccountId).Sales_Territory__c,
                    Opportunity_Channel_Manager__c = mapAccountSENames.get(oppty.AccountId).Channel_Manager__c,
                    Opportunity_Customer_Advocate__c = mapAccountSENames.get(oppty.AccountId).Customer_Advocate__c,
                    Opportunity_Area_Director__c = mapAccountSENames.get(oppty.AccountId).Area_Director__c,
                    Opportunity_Account_Manager__c = mapAccountSENames.get(oppty.AccountId).Account_Manager__c);
                
                lstOpportunitiesToUpdate.add(opp);
                //}
            }
        }
        try {
            if(lstOpportunitiesToUpdate.size()>0){
                system.debug('inside if of try to update opportunities ');
                update lstOpportunitiesToUpdate;
                TriggerUtility.updateSENameFromAccountExecuted();
            }
            
        } catch (Exception ex) {
            System.debug('Exception occurred while updating opportunitys\' SE Name field: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }

        
    }

    public static void updateContractEndDateInOpportunity(List < Account > lstNewAccounts, Map < Id, Account > mapOldAccounts) {
        List < Id > lstAccountIds = new List < Id > ();

        for (Account acc: lstNewAccounts) {
            if (mapOldAccounts.get(acc.Id).Platform_Renewal_Date__c != acc.Platform_Renewal_Date__c) {
                lstAccountIds.add(acc.Id);
            }
        }
        System.debug('*** lstAccountIds: ' + lstAccountIds);
        if (lstAccountIds.size() > 0) {
            OppotunityTriggerHelper.updateContractEndDate(lstAccountIds);
        }

        TriggerUtility.updateContractEndDateExecuted();
    }

    public static void updateTerritoryonActivities(List < Account > lstNewAccounts, Map < Id, Account > mapOldAccounts) {
        Set < Id > lstAccountIds = new Set < Id > ();

        for (Account acc: lstNewAccounts) {
            
            if (mapOldAccounts.get(acc.Id).Sales_Territory__c != acc.Sales_Territory__c) {
                lstAccountIds.add(acc.Id);
            }
        }
        if (lstAccountIds.size() > 0) {
            List < Event > eventlst = [Select Id, WhoId, accountId, Account.Sales_Territory__r.Name, Account.Sales_Territory__r.Area__c, Account.Sales_Territory__r.Theater__c, Account.Territory_Type__c, Sales_Territory__c, Territory_Area__c, Territory_Geo__c, Territory_Type__c from Event where AccountId in: lstAccountIds and IsChild = false and isrecurrence = false];
            for (Event t: eventlst) {
                t.Sales_Territory__c = t.Account.Sales_Territory__r.Name;
                t.Territory_Area__c = t.Account.Sales_Territory__r.Area__c;
                t.Territory_Geo__c = t.Account.Sales_Territory__r.Theater__c;
                t.Territory_Type__c = t.Account.Territory_Type__c;
            }
            TriggerUtility.AcctoActivityTerritoryExecuted();
            update eventlst;
        }
    }

    //Added by Gurjinder to update the Customer Success Stage
    public static void UpdateCustomerSuccessStage(list < Account > NewAccountList, map < Id, Account > accountOldMap) {
     // Logic for Success_Stage__c has been removed as a part of CR#1438 by Swathi
      //  Set < id > AccountidSet = new Set < id > ();
       // Map < id, Cloud_Usage__c > AccountsCloudusagemap = new Map < id, Cloud_Usage__c > ();
       // Map < id, BWC_Data__c > AccountsMonthlyCloudusagemap = new Map < id, BWC_Data__c > ();
        //Map < id, Account_Extension__c > AccandAccExtmap = new Map < id, Account_Extension__c > ();
        //Map < id, id > AccountsandZscalerCloudid = new Map < id, id > ();
        //String CSStage1datecriteria= ZscalerCustomSetting__c.getInstance('CSStage1datecriteria')!=null && ZscalerCustomSetting__c.getInstance('CSStage1datecriteria').Value__c!=null ? ZscalerCustomSetting__c.getInstance('CSStage1datecriteria').Value__c:'2019-12-12';
    //    if (trigger.isupdate) {
    //        for (Account acc: NewAccountList) {
                
                /**if(acc.Summarize_the_Value_to_the_Customer__c!=accountOldMap.get(acc.id).Summarize_the_Value_to_the_Customer__c){
                    system.debug('field value has been changed');
                }else{
                    system.debug('field value has not  been changed');
                }**/
                
    //            if (!acc.Override_Customer_Success_Stage__c) {
    //                AccountidSet.add(acc.id);
    //            }
    //        }
    //    }
    //    if (!AccountidSet.isempty() && AccountidSet.size() > 0) {
    //
    //        for (Account acc: [Select id, (Select id, createddate, total_ssl_inspected_transactions__c, Zscaler_Cloud_ID__c, total_ssl_transactions__c from Cloud_Usage_Object__r order by createddate desc limit 1) from account where id IN: AccountidSet]) {
    //            if (!acc.Cloud_Usage_Object__r.isempty() && acc.Cloud_Usage_Object__r.size() > 0 && /* acc.Cloud_Usage_Object__r[0]!=null && */ !AccountsCloudusagemap.containsKey(acc.id)) {
    //                AccountsCloudusagemap.put(acc.id, acc.Cloud_Usage_Object__r[0]);
    //                AccountsandZscalerCloudid.put(acc.id, acc.Cloud_Usage_Object__r[0].Zscaler_Cloud_ID__c);
    //            }
                /**if (!acc.Account_Extensions__r.isempty() && acc.Account_Extensions__r.size() > 0) {
                    system.debug('Acc extension is present');
                    AccandAccExtmap.put(acc.id,acc.Account_Extensions__r[0]);
                }**/
    //        }
    //        if (!AccountsandZscalerCloudid.isempty() && AccountsandZscalerCloudid.size() > 0) {
    //            for (Zscaler_Cloud_ID__c ZCloudid: [Select id, (Select id, Name, CFW_Enabled__c, CFW_Disabled__c from BWC_Data__r order by createddate desc limit 1) from Zscaler_Cloud_ID__c where id IN: AccountsandZscalerCloudid.values()]) {
    //                if (!ZCloudid.BWC_Data__r.isempty() && ZCloudid.BWC_Data__r.size() > 0 /* && ZCloudid.BWC_Data__r[0]!=null */ ) {
    //                    AccountsMonthlyCloudusagemap.put(ZCloudid.id, ZCloudid.BWC_Data__r[0]);
    //                }
    //
    //            }
    //
    //        }
    //    }
        //system.debug('AccandAccExtmap  '+AccandAccExtmap);
        for (Account acc: NewAccountList) {
            String Customersentiment = '';
            if (trigger.isupdate) {
                system.debug('trigger.isupdate ');
                if(accountOldMap.get(acc.id).Customer_Sentiment__c!=null) {
                    Customersentiment = accountOldMap.get(acc.id).Customer_Sentiment__c;
                }
            }
            system.debug('Customersentiment '+Customersentiment);
        //    if (!acc.Override_Customer_Success_Stage__c) {
        //        Boolean stage1 = false;
        //        Boolean stage2 = false;
        //        Boolean stage3 = false;
        //        Boolean stage4 = false;
        //        Boolean skipstage0and1 = false;
    //
        //        if (acc.Current_ARR__c != null && acc.Current_ARR__c < 25000) {
        //            skipstage0and1 = true;
        //        }
        //        if (!skipstage0and1 && acc.Last_QBR_Date__c == null) {
                    //acc.Success_Stage__c = '0 - Not Started';
         //       } else {
                    //if (acc.Last_QBR_Date__c != null || skipstage0and1) {

          //              if (skipstage0and1) {
          //                if (acc.Type == 'Customer' /* && stage1 */ && ((acc.DAS_Stage__c != null && acc.DAS_Stage__c != '' && acc.DAS_Stage__c.equalsignorecase('stage_d2_design_completed')) || (acc.X10_Traffic_attained_date__c == null))) {
          //                    //acc.Success_Stage__c = '2 - Design Complete (0-10% Deployed)';
          //                      stage2 = true;
          //                  }
          //                  if (acc.Type == 'Customer' /* && stage2 */ && acc.X10_ZPA_Traffic_attained_date__c != null) {
          //                      //acc.Success_Stage__c = '3 - Secure & Simplify (10-25% Deployed)';
          //                      stage3 = true;
          //                 }
          //                  if (acc.Type == 'Customer' /* && stage2  */ && ((acc.No_of_Platform_Seats__c > 0 && acc.X10_Traffic_attained_date__c != null) || (acc.Users_ZPA_Platform__c > 0 && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c >= 10))) {
          //                      //acc.Success_Stage__c = '3 - Secure & Simplify (10-25% Deployed)';
          //                      stage3 = true;
          //                  }
          //                  if (acc.Type == 'Customer' /* && stage3 */ && acc.X25_ZPA_Traffic_attained_date__c != null) {
          //                      //acc.Success_Stage__c = '4 – Transformation in Progress (25%+ Deployed)';
          //                      stage4 = true;
          //                  }
          //                  if (acc.Type == 'Customer' /* && stage3 */ && ((acc.No_of_Platform_Seats__c > 0 && acc.Date_when_traffic_consumed_is_25__c != null) || (acc.Users_ZPA_Platform__c > 0 && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c >= 25))) {
          //                      //acc.Success_Stage__c = '4 – Transformation in Progress (25%+ Deployed)';
          //                      stage4 = true;
          //                  }
          //                  /*if (!stage2 && !stage3 && !stage4) {
          //                      acc.Success_Stage__c = '0 - Not Started';
          //                  }*/
          //              } else{ //Changed by Nathan : CR# 196: AmberRoad Fixes
          //                  //Logic for date criteria:Start
          //                  Date datetocheck;
          //                  if(acc.First_Contract_Date__c!=null && acc.First_ZPA_Contract_Date__c!=null){
          //                      system.debug('both dates are not null');
          //                      if(acc.First_Contract_Date__c>=acc.First_ZPA_Contract_Date__c){
          //                          system.debug('ZIA date is older');
          //                          datetocheck=acc.First_Contract_Date__c;
          //                      }else{
          //                          system.debug('ZPA date is older');
          //                          datetocheck=acc.First_ZPA_Contract_Date__c;
          //                      }
          //                  }else{
          //                      system.debug('In else part');
          //                      if(acc.First_Contract_Date__c!=null){
          //                          system.debug('ZIA date is not null');
          //                          datetocheck=acc.First_Contract_Date__c;
          //                      }
          //                      if(acc.First_ZPA_Contract_Date__c!=null){
          //                          system.debug('ZPA date is not null');
          //                          datetocheck=acc.First_ZPA_Contract_Date__c;
          //                      }
          //                      
          //                  }
          //                  system.debug('datetocheck  '+datetocheck);
          //                  //Logic for date criteria:End
          //                  if ((trigger.isinsert || (trigger.isupdate && datetocheck!=null && datetocheck>=date.valueof(CSStage1datecriteria)) ) && acc.Current_ARR__c != null && acc.Current_ARR__c > 25000 && acc.Milestone_Pilot_Date__c!=null && acc.Milestone_Production_Date__c!=null && acc.Last_QBR_Date__c != null) {
          //                      //acc.Success_Stage__c = '1 - Kick-off Complete (QBR 0)';
          //                      system.debug('Stage 1 part1 ');
          //                      stage1 = true;
          //                  }else if(trigger.isupdate && datetocheck!=null && datetocheck<date.valueof(CSStage1datecriteria) && acc.Current_ARR__c != null && acc.Current_ARR__c > 25000 && acc.Last_QBR_Date__c != null){
          //                      //acc.Success_Stage__c = '1 - Kick-off Complete (QBR 0)';
          //                      system.debug('Stage 1 part2 ');
          //                      stage1 = true;
          //                  }
          //                  //Added conditions :requested by Jay Yeater: BY Gurjinder   
          //                  //
          //                  if (acc.Type == 'Customer' /* && stage1  */ && (trigger.isinsert || (trigger.isupdate && datetocheck!=null && datetocheck>=date.valueof(CSStage1datecriteria))) && acc.Milestone_Pilot_Date__c!=null && acc.Milestone_Production_Date__c!=null && (acc.DAS_Stage__c != null && acc.DAS_Stage__c != '' && acc.DAS_Stage__c.equalsignorecase('stage_d2_design_completed') ||  ((acc.X10_Traffic_attained_date__c == null || acc.X10_ZPA_Traffic_attained_date__c==null) && (acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>0 || acc.Avg_Estimated_Users_L31D_Vs_Purchase__c>0)))) {
          //                      //acc.Success_Stage__c = '2 - Design Complete (0-10% Deployed)';
          //                      system.debug('Stage 2 part1 ');
          //                      stage2 = true;  
          //                  }else if(acc.Type == 'Customer' && trigger.isupdate && datetocheck!=null && datetocheck<date.valueof(CSStage1datecriteria) && (acc.DAS_Stage__c != null && acc.DAS_Stage__c != '' && acc.DAS_Stage__c.equalsignorecase('stage_d2_design_completed') ||  ((acc.X10_Traffic_attained_date__c == null || acc.X10_ZPA_Traffic_attained_date__c==null) && (acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>0 || acc.Avg_Estimated_Users_L31D_Vs_Purchase__c>0)))){
          //                      //acc.Success_Stage__c = '2 - Design Complete (0-10% Deployed)';
          //                      system.debug('Stage 2 part2 ');
          //                      stage2 = true;
          //                  }
          //                  
          //                 system.debug('acc.X10_ZPA_Traffic_attained_date__c  '+acc.X10_ZPA_Traffic_attained_date__c);
          //                  if (acc.Type == 'Customer' /* && stage2 */ && ((acc.No_of_Platform_Seats__c > 0 && acc.X10_Traffic_attained_date__c != null) || (acc.X10_ZPA_Traffic_attained_date__c!=null && acc.Users_ZPA_Platform__c> 0 && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>= 10))) {
          //                      //acc.Success_Stage__c = '3 - Secure & Simplify (10-25% Deployed)';
          //                      system.debug('Stage 3 ');
          //                      stage3 = true;
          //                  }
          //                  system.debug('--acc.Type--'+acc.Type+'--acc.X25_ZPA_Traffic_attained_date__c--'+acc.X25_ZPA_Traffic_attained_date__c);
          //                  if (acc.Type == 'Customer' /* && stage3 */ && (acc.No_of_Platform_Seats__c > 0 && acc.Date_when_traffic_consumed_is_25__c != null) || (acc.X25_ZPA_Traffic_attained_date__c!=null && acc.Users_ZPA_Platform__c> 0 && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>= 25)) {
          //                      //acc.Success_Stage__c = '4 - Transformation in Progress (25%+ Deployed)';
          //                      system.debug('Stage 4 ');
          //                      stage4 = true;
          //                  }
          //                  /* if(!stage1 && !stage2 && !stage3 && !stage4){
          //                      acc.Success_Stage__c='1 - Kick-off Complete (QBR 0)';
          //                  } */
      //
          //              }
                            //
                   // }

          //      }
                //for stage 5 logic starts
          //      if ( /* accountOldMap.get(acc.id).Success_Stage__c.equalsignorecase('4 – Transformation in Progress (25%+)')*/ stage4 && trigger.isupdate) {
          //          Integer SSLTrafficInspected = 0;
          //          Integer MobileUsersZAPP = 0;
          //          Integer AllPortsandProtocolsFWEnabled = 0;
          //          Integer BrokenOut = 0;
          //          Integer O365Transactions = 0;
          //          Boolean DeployZPA65 = false;
      //  
          //          if (!AccountsCloudusagemap.isempty() && AccountsCloudusagemap.size() > 0 && AccountsCloudusagemap.get(acc.id) != null) {
          //              Cloud_Usage__c CU = AccountsCloudusagemap.get(acc.id);
          //              if (CU.total_ssl_inspected_transactions__c != null && integer.valueof(CU.total_ssl_inspected_transactions__c) > 0 && CU.total_ssl_transactions__c != null && integer.valueof(CU.total_ssl_transactions__c) > 0) {
          //                  SSLTrafficInspected = integer.valueof((CU.total_ssl_inspected_transactions__c / CU.total_ssl_transactions__c) * 100);
          //              }
          //          }
      //
          //          id AccZCloudid;
          //          if (!AccountsandZscalerCloudid.isempty() && AccountsandZscalerCloudid.size() > 0 && AccountsandZscalerCloudid.get(acc.id) != null) {
          //              AccZCloudid = AccountsandZscalerCloudid.get(acc.id);
          //          }
          //          if (!AccountsMonthlyCloudusagemap.isempty() && AccountsMonthlyCloudusagemap.size() > 0 && AccZCloudid != null && AccountsMonthlyCloudusagemap.get(AccZCloudid) != null) {
          //              BWC_Data__c MCU = AccountsMonthlyCloudusagemap.get(AccZCloudid);
          //              if (MCU.CFW_Enabled__c != null && MCU.CFW_Disabled__c != null && integer.valueof(MCU.CFW_Enabled__c) > 0 && integer.valueof(MCU.CFW_Disabled__c) > 0) {
          //                  AllPortsandProtocolsFWEnabled = integer.valueof((MCU.CFW_Enabled__c / (MCU.CFW_Enabled__c + MCU.CFW_Disabled__c)) * 100);
          //              }
          //          }
      //
          //          if (acc.ZApp_Registered_Devices__c != null && acc.ZApp_Registered_Devices__c > 0 && integer.valueof(acc.No_of_Platform_Seats__c) > 0) {
          //              MobileUsersZAPP = integer.valueof((acc.ZApp_Registered_Devices__c / acc.No_of_Platform_Seats__c) * 100);
          //          }
          //          if (acc.Egress_LOcation_Count__c != null && acc.Egress_LOcation_Count__c > 0 && integer.valueof(acc.No_of_Platform_Seats__c) > 0) {
          //              BrokenOut = Integer.valueof((acc.Egress_LOcation_Count__c / acc.No_of_Platform_Seats__c) * 500);
          //          }
          //          if (acc.O365_Traffic_L90D__c != null && integer.valueof(acc.O365_Traffic_L90D__c) > 0) {
          //              O365Transactions = Integer.valueof(acc.O365_Traffic_L90D__c);
          //          }
          //          if (acc.X65_ZPA_Traffic_attained_date__c != null) {
          //              DeployZPA65 = true;
          //          }
      //
          //          Integer ValidconditionsCount = 0;
          //          if (SSLTrafficInspected >= 65) {
          //              ValidconditionsCount++;
          //          }
          //          if (MobileUsersZAPP >= 65) {
          //              ValidconditionsCount++;
          //         }
          //          if (AllPortsandProtocolsFWEnabled >= 65) {
          //              ValidconditionsCount++;
          //          }
          //          if (BrokenOut >= 65) {
          //              ValidconditionsCount++;
          //          }
          //          if (O365Transactions > 15) {
          //              ValidconditionsCount++;
          //          }
          //          if (DeployZPA65) {
          //              ValidconditionsCount++;
          //          }
          //          if (ValidconditionsCount >= 3) {
          //              //acc.Success_Stage__c = '5 – Transformed';
          //              if (!acc.Override_Customer_Sentiment__c) {
          //                  if (acc.Last_SCI_Date__c == null && CustomerSentiment != 'Lost' && CustomerSentiment != 'Churn Risk') {
          //                      acc.Customer_Sentiment__c = 'No Engagement'; //Changed by Nathan : CR# 196: AmberRoad Fixes
          //                  }
          //              }
          //         }
          //      }
          //      //for stage 5 logic ends
          //  }
          //  //Logic for Customer sentiment field :Gurjinder :Start

            // CR# 4608 Added isInsert check so it allows to update Customer_Sentiment__c when Type is 'Ex-Customer'
            if (Trigger.isInsert && acc.type == 'Ex-Customer') {
                acc.Customer_Sentiment__c = 'Lost';
            }
            if (acc.type == 'Ex-Customer' && accountOldMap.get(acc.id).type == 'Customer') {
                //acc.Success_Stage__c = '5 – Transformed';
                acc.Customer_Sentiment__c = 'Lost';
            }
            if (!acc.Override_Customer_Sentiment__c) {
                if (acc.type == 'Customer' && acc.Last_SCI_Date__c == null && CustomerSentiment != 'Lost' && CustomerSentiment != 'Churn Risk') {
                    acc.Customer_Sentiment__c = 'No Engagement';
                }
                // CR# 4608 START
                //Commenting below code as no automation is required to update Customer_Sentiment__c to 'Trending negative'.
                /*
                if(acc.Last_SCI_Date__c != null && acc.Customer_Sentiment__c== 'No Engagement'){
                    acc.Customer_Sentiment__c = 'Trending negative';            // Added by Ayush Kangar as part of CR# 2902
                }
        */
                // CR# 4608 END
            }
            //Logic for Customer sentiment field :Gurjinder :End

            if (trigger.isupdate && acc.CSM_Name_New__c != null /* && accountOldMap.get(acc.id).CSM_Name_New__c!=null */ && acc.CSM_Name_New__c != accountOldMap.get(acc.id).CSM_Name_New__c) {
                acc.CSM_Assignment_Date__c = system.today();
            }

        }

        TriggerUtility.CustomerSuccessUpdatemethodsettrue();
    }
    
    //Method Added as apart of RBAC
    //Description
    public static void AAUCreateAccountTeamMember(list<Account> newAccounts, Map<Id, Account> oldAccountsMap){
        List<AccountTeamMember> result = new List<AccountTeamMember>();
        for(account accountRecord : newAccounts){
            //decimal numberofminutes = (accountRecord.LastModifiedDate-accountRecord.CreatedDate)*24*60;
            decimal decMinutes = ((accountRecord.LastModifiedDate.getTime())/1000/60) - ((accountRecord.CreatedDate.getTime())/1000/60);
            if(accountRecord.OwnerId != oldAccountsMap.get(accountRecord.Id).OwnerId && decMinutes <= 2){
                AccountTeamMember member  = new AccountTeamMember();
                member.AccountId = accountRecord.Id;
                member.UserId = oldAccountsMap.get(accountRecord.Id).OwnerId;
                //member.UserId=UserInfo.getUserId();
                member.TeamMemberRole = 'Account Owner';
                member.AccountAccessLevel = 'Edit';
                member.OpportunityAccessLevel = 'Edit';
                member.CaseAccessLevel = 'Edit';
                member.ContactAccessLevel = 'Edit';
                result.add(member);
            }
        }
        if(result.size()>0){
            Database.SaveResult[] srList = Database.insert(result, false);
        }
    }
    

    /*  Method updates various stages of Prospect Type picklist field on Account depending on the related SCI 
     *  dates as well as Open or lost Opportunities. Runs on Insert and Update.
     */
    public void updateProspectTypeOnAccount(List < Account > lstNewAccounts) {
        system.debug('CALLED');
        List < Opportunity > closedOpps = new List < Opportunity > ();
        //added by Raghu                                                              
        Map < Id, Date > lastestAccOppCloseDate = new Map < Id, Date > ();
        Map < Id, Date > lastestAccSCIDate = new Map < Id, Date > ();
        Map < Id, List < Opportunity >> acc_OppMap = new Map < Id, List < Opportunity >> ();
        Map < Id, boolean > openOppMap = new Map < Id, boolean > ();
        Map < Id, boolean > openLatestSCIMap = new Map < Id, boolean > ();
        Map < Id, boolean > openValidationStagePipelineMap = new Map < Id, boolean > ();
        Map < Id, boolean > openValidationStagePOCMap = new Map < Id, boolean > ();
        //CR# 349
        //Map < Id, List < Significant_Customer_Interaction__c >> acc_SCIMap = new Map < Id, List < Significant_Customer_Interaction__c >> ();
        Map < Id, List <Event>> acc_SCIMap = new Map < Id, List <Event>> ();
        DateTime currentTimeStamp = System.Now();

        for (Opportunity opp: [SELECT Validation_Stage__c, isClosed, closeDate, Stagename, AccountId, Account.Last_F2F_Meeting__c,
                Account.Open_Opportunities__c, Account.Count_of_SCIs__c
                FROM Opportunity
                WHERE AccountId =: lstNewAccounts AND AccountId != ''
                ORDER BY CloseDate desc NULLS LAST
            ]) {
                system.debug('testclass'+opp);
            if (String.isNotBlank(opp.AccountId)) {

                if (lastestAccOppCloseDate.get(opp.AccountId) == null && !(opp.isClosed)) {
                    lastestAccOppCloseDate.put(opp.AccountId, opp.CloseDate);
                } else if (opp.closeDate > lastestAccOppCloseDate.get(opp.AccountId) && !(opp.isClosed)) {
                    lastestAccOppCloseDate.put(opp.AccountId, opp.CloseDate);
                }

                if (!acc_OppMap.containsKey(opp.AccountId)) {
                    acc_OppMap.put(opp.AccountId, new List < Opportunity > ());
                }
                acc_OppMap.get(opp.AccountId).add(opp);
                if (openOpps.contains(opp.Stagename) == true && opp.Account.Open_Opportunities__c != 0) {
                 //   system.debug('First:' + validation_stage_POC.contains(opp.Validation_Stage__c));
                 //   system.debug('Second:' + opp.Validation_Stage__c);
                    if (validation_stage_POC.contains(opp.Validation_Stage__c) && opp.Validation_Stage__c != null) {
                        openValidationStagePOCMap.put(opp.AccountId, true);
                 //       system.debug('CALL Open:POC');
                    }
                    if (validation_stage_pipeline.contains(opp.Validation_Stage__c) || opp.Validation_Stage__c == null) {
                        openValidationStagePipelineMap.put(opp.AccountId, true);
                 //       system.debug('CALL Open:PIPE');
                    }
                  //  system.debug('pipeline:' + openValidationStagePipelineMap);
                  //  system.debug('POC:' + openValidationStagePOCMap);
                    openOppMap.put(opp.AccountId, true);
                    openLatestSCIMap.put(opp.AccountId, true);

                  //  system.debug('CALL Open: ' + validation_stage_pipeline.contains(opp.Validation_Stage__c));
                }
                if (openOpps.contains(opp.Stagename) != true && opp.Account.Open_Opportunities__c == 0) {
                    if (openOppMap.get(opp.AccountId) == null) {
                        openOppMap.put(opp.AccountId, false);
                        closedOpps.add(opp);
                    }

                }

                //system.debug('CALL: ');
                //NEED TO CHECK - If unrelated Open Opp and SCI are there, would it re-engage -- opp.Account.Count_of_SCIs__c != 0 && 
                //no open opportunities
                if (openOppMap.get(opp.AccountId) == false) {
                   // system.debug('CALL 1: ' + opp.CloseDate);
                   // system.debug('CALL 1: ' + opp.Account.Last_F2F_Meeting__c);
                    if (lastestAccOppCloseDate.get(opp.AccountId) < opp.Account.Last_F2F_Meeting__c) {
                      //  system.debug('TRUE');
                        openLatestSCIMap.put(opp.AccountId, true);
                      //  system.debug('TRUE 1:' + openLatestSCIMap.get(opp.AccountId));
                        break;
                    } else {
                        openLatestSCIMap.put(opp.AccountId, false);
                      //  system.debug('ELSE FALSE');
                    }
                }

            }
        }
        // CR# 349
        /*for (Significant_Customer_Interaction__c sciObj: [SELECT Id, Date__c, Account_Name__c,Account_Name__r.LastRegularSCIdate__c,Account_Name__r.Last_F2F_Meeting__c,
                Opportunity_Name__r.CloseDate, Opportunity_Name__r.StageName
                FROM Significant_Customer_Interaction__c
                WHERE Account_Name__c IN: lstNewAccounts
                AND RecordType.Name in
                ('Regular Meeting', 'Architecture Session', 'QBR')
                ORDER BY Date__c desc
            ]) {*/
        for(Event sciObj: [Select Id, CreatedDate, StartDateTime, Method_of_Interaction__c, accountId, ActivityDate, EndDateTime, Type from Event
                WHERE accountId IN: lstNewAccounts
                AND Type in
                ('Regular Meeting', 'Architecture Workshop', 'QBR') and StartDateTime < :currentTimeStamp and peopleai__MeetingStatus__c != 'Canceled'
                ORDER BY StartDateTime desc
            ]) {
            if(String.isNotBlank(sciObj.accountId)) {
                if(lastestAccSCIDate.get(sciObj.accountId) == null){
                    lastestAccSCIDate.put(sciObj.accountId, sciObj.ActivityDate);
                }

                if(!acc_SCIMap.containsKey(sciObj.accountId)){
                    acc_SCIMap.put(sciObj.accountId, new List<Event>());
                }

                acc_SCIMap.get(sciObj.accountId).add(sciObj);
                if(lastestAccSCIDate.get(sciObj.accountId) > lastestAccOppCloseDate.get(sciObj.accountId)){
                    system.debug('Entered Test 1');
                    openLatestSCIMap.put(sciObj.accountId, true);
                } else if(lastestAccOppCloseDate.get(sciObj.accountId) == null) {
                    system.debug('Entered Test 2');
                    openLatestSCIMap.put(sciObj.accountId, true);
                }

                //system.debug('Entered 1:' + openLatestSCIMap.get(sciObj.Account_Name__c));
            }
        }

        for (Account accObj: lstNewAccounts) {
            if (accObj.type != null) {
                if (accObj.type.equals(TriggerUtility.PROSPECT)) {
                    system.debug('CALLED: ' + acc_OppMap.values());
                    //No Opps, No SCIs makes it Not touched.#Non-regular SCI ?
                    if ((accObj.Count_of_SCIs__c == null || accObj.Count_of_SCIs__c == 0) &&
                        acc_OppMap.get(accObj.Id) == null && acc_SCIMap.get(accObj.Id) == null) {
                        accObj.Prospect_Type__c = TriggerUtility.NOT_TOUCHED;
                        system.debug('Reached here' + accObj.Open_Opportunities__c);
                    }

                    system.debug('OPP LOST:' + acc_OppMap.isEmpty());
                    system.debug('OPP LOST:' + openLatestSCIMap.get(accObj.Id));
                    system.debug('CALLED: OpenOPP:' + openOppMap.get(accObj.Id));
                    if (acc_OppMap.get(accObj.Id) == null) {
                        if (acc_SCIMap.get(accObj.Id) != null && openLatestSCIMap.get(accObj.Id) == true) {
                            if (accObj.LastRegularSCIdate__c != null) {
                                if (Date.Today().monthsbetween(accObj.LastRegularSCIdate__c  ) > -6) {
                                    accObj.Prospect_Type__c = TriggerUtility.ENGAGED;
                                    system.debug('Engaged');
                                }
                                if (Date.Today().monthsbetween(accObj.LastRegularSCIdate__c  ) < -6) {
                                    accObj.Prospect_Type__c = TriggerUtility.NO_RECENT_ENGAGEMENT;
                                    system.debug('No recent engagement');
                                }
                            }
                            //This code may be removed once data is fixed - by Raghu
                            else {
                                accObj.Prospect_Type__c = TriggerUtility.NO_RECENT_ENGAGEMENT;
                                system.debug('Default : No recent engagement');
                            }
                        }
                    }
                    if (acc_OppMap.get(accObj.Id) != null) {
                        if (acc_SCIMap.get(accObj.Id) != null && openLatestSCIMap.get(accObj.Id) == true) {
                            if (accObj.LastRegularSCIdate__c != null) {
                                if (Date.Today().monthsbetween(accObj.LastRegularSCIdate__c) > -6) {
                                    accObj.Prospect_Type__c = TriggerUtility.ENGAGED;
                                    system.debug('Here one');
                                }
                                if (Date.Today().monthsbetween(accObj.LastRegularSCIdate__c) < -6) {
                                    accObj.Prospect_Type__c = TriggerUtility.NO_RECENT_ENGAGEMENT;
                                }
                            }
                        }
                        if (accObj.Open_Opportunities__c == 0) {
                            if (openLatestSCIMap.get(accObj.Id) == false) {
                                accObj.Prospect_Type__c = TriggerUtility.OPPLOST;
                            }
                        }

                        if (accObj.Open_Opportunities__c != 0) {
                            if (openValidationStagePipelineMap.get(accObj.Id) == true) {
                                accObj.Prospect_Type__c = TriggerUtility.PIPELINE;
                            }
                            if (openValidationStagePOCMap.get(accObj.Id) == true) {
                                accObj.Prospect_Type__c = TriggerUtility.POC;
                            }
                        }
                    }

                } else {
                    accObj.Prospect_Type__c = TriggerUtility.BLANK;
                }
            }
        }
        TriggerUtility.prospectTypeUpdExecuted();
    }


    /**
     *  Method updates the Customer Support Segment field on Account whenever 
     *  ARR is populated on Accounts.
     */
    public void updateCustomerSupportStage(List < Account > lstNewAccounts) {
        for (Account accobj: lstNewAccounts) {
            if (accObj.Override_Customer_Support_Segment__c == false && (accObj.Type == 'Customer' || accObj.Type == 'Ex-Customer')) {
                system.debug('accObj.Current_ARR__c '+accObj.Current_ARR__c);
                system.debug('accObj.Account_Renewable_ACV__c '+accObj.Account_Renewable_ACV__c);
                if (accObj.Current_ARR__c != null && accObj.Current_ARR__c>0) {
                    system.debug('inside Current ARR');
                    if (accObj.Current_ARR__c > 1000000 ) {
                        accObj.Customer_Support_Segment__c = 'Top100';
                    } else if (accObj.Current_ARR__c <= 1000000 && accObj.Current_ARR__c > 300000) {
                        accObj.Customer_Support_Segment__c = 'Platinum';
                    } else if (accObj.Current_ARR__c <= 300000 && accObj.Current_ARR__c > 100000) {
                        accObj.Customer_Support_Segment__c = 'Gold';
                    } else if (accObj.Current_ARR__c <= 100000 && accObj.Current_ARR__c > 25000) {
                        accObj.Customer_Support_Segment__c = 'Silver';
                    } else if (accObj.Current_ARR__c <= 25000) {
                        accObj.Customer_Support_Segment__c = 'Bronze';
                    }/*  else {
                        accObj.Customer_Support_Segment__c = 'Bronze';
                    } */
                }
                else if(accObj.Account_Renewable_ACV__c!= null && accObj.Account_Renewable_ACV__c>0 && (accObj.Current_ARR__c == null || accObj.Current_ARR__c == 0)){
                    system.debug('inside Account_Renewable_ACV__c ');
                    if (accObj.Account_Renewable_ACV__c > 1000000) {
                        accObj.Customer_Support_Segment__c = 'Top100';
                    } else if (accObj.Account_Renewable_ACV__c <= 1000000 && accObj.Account_Renewable_ACV__c > 300000) {
                        accObj.Customer_Support_Segment__c = 'Platinum';
                    } else if (accObj.Account_Renewable_ACV__c <= 300000 && accObj.Account_Renewable_ACV__c > 100000) {
                        accObj.Customer_Support_Segment__c = 'Gold';
                    } else if (accObj.Account_Renewable_ACV__c <= 100000 && accObj.Account_Renewable_ACV__c > 25000) {
                        accObj.Customer_Support_Segment__c = 'Silver';
                    } else if (accObj.Account_Renewable_ACV__c <= 25000) {
                        accObj.Customer_Support_Segment__c = 'Bronze';
                    } else {
                        accObj.Customer_Support_Segment__c = 'Bronze';
                    }
                }else if(accobj.Account_Renewable_ACV__c==null || accobj.Account_Renewable_ACV__c==0){
                    accObj.Customer_Support_Segment__c = 'Bronze';
                }
            }
            if (accObj.Type != 'Customer' && accObj.Type != 'Ex-Customer') {
                accObj.Customer_Support_Segment__c = '';
            }
        }
    }
    
    
    //Added by Gurjinder to update the field on Account Extension obj
    public static void UpdateAccountExtensionmethod(list < Account > NewAccountList, map < Id, Account > accountOldMap) {
        Set<id> AccountIdSet= new Set<id>();
        Set<id> AccountIdSet2= new Set<id>();
        Set<id> AccountIdSet3= new Set<id>();
        Set<id> AccountIdSet4= new Set<id>();
        Set<id> AccountIdSet5= new Set<id>();
        Set<id> AccountIdSet6= new Set<id>();
        Set<id> AccountIdSet7= new Set<id>();
        //Added by Abhijit : CR866 : Start
        Set<id> AccountIdSet8= new Set<id>();
        Set<id> AccountIdSet9= new Set<id>();
        Set<id> AccountIdSet10= new Set<id>();
        Set<id> AccountIdSet11= new Set<id>();
        
        Set<id> AccountIdSetExecContacts= new Set<id>();  
        Set<id> ContactIdSetArch = new Set<id>();              
        Set<id> ContactIdSetSec = new Set<id>();
        Set<id> ContactIdSetIt = new Set<id>();
        Set<id> ContactIdSetNet = new Set<id>();
        Set<id> ContactIdSetAll = new Set<id>();    
        Map<Id, Contact> unCheckExecContacts = new Map<Id, Contact>();            
        
        //Added by Abhijit : CR866 : End 
        
        //Added by Swathi : CR1116 Starts
        Set<id> AccountIdSet12 = new Set<id>();
        Set<id> AccountIdSet13 = new Set<id>();
        Set<id> AccountIdSet14 = new Set<id>();
        Set<id> AccountIdSet15 = new Set<id>();
        //Added by Swathi : CR1116 Starts
        
        
        //IF Accounty Type Changes Update Sync To JIRA Value
        Set<id> AccountIdSet16 = new Set<id>();
        
        Set<id> AccountIdSet17 = new Set<id>();//Added by Swathi : CR1142
        
        Map<id,Account_Extension__c> AccountExtension2Update= new Map<id,Account_Extension__c>();
        for (Account acc: NewAccountList) {
           // system.debug('acc.Summarize_the_Value_to_the_Customer__c  '+acc.Summarize_the_Value_to_the_Customer__c);
           // system.debug('acc.Summarize_the_Value_to_the_Customer__c  '+accountOldMap.get(acc.id).Summarize_the_Value_to_the_Customer__c);
            if(acc.Summarize_the_Value_to_the_Customer__c!=accountOldMap.get(acc.id).Summarize_the_Value_to_the_Customer__c){
                system.debug('field value has been changed');
                AccountIdSet.add(acc.id);
                AccountIdSet2.add(acc.id);
            }
            if(acc.CS_Management_Notes__c!=accountOldMap.get(acc.id).CS_Management_Notes__c){
                system.debug('field value has been changed');
                AccountIdSet.add(acc.id);
                AccountIdSet3.add(acc.id);
            }
            if(acc.Customer_Next_Steps__c!=accountOldMap.get(acc.id).Customer_Next_Steps__c){
                system.debug('field value has been changed');
                AccountIdSet.add(acc.id);
                AccountIdSet4.add(acc.id);
            }
            if(acc.Architecture_Workshop_Link__c!=accountOldMap.get(acc.id).Architecture_Workshop_Link__c){
                system.debug('field value has been changed');
                AccountIdSet.add(acc.id);
                AccountIdSet5.add(acc.id);
            }
      //Added by Gurjinder : CR# 51 : End
            if(acc.Arch_workshop_next_steps__c!=accountOldMap.get(acc.id).Arch_workshop_next_steps__c){
                system.debug('field value has been changed');
                AccountIdSet.add(acc.id);
                AccountIdSet6.add(acc.id);
            }
            if(acc.ZSR_Link__c!=accountOldMap.get(acc.id).ZSR_Link__c){
                system.debug('field value has been changed');
                AccountIdSet.add(acc.id);
                AccountIdSet7.add(acc.id);
            }
      //Added by Gurjinder : CR# 51 : End
            //Added by Abhijit : CR866 : Start
            if(acc.HeadOfIT__c != accountOldMap.get(acc.Id).HeadOfIT__c){
                system.debug('HeadOfIT__c field value has been changed');
                AccountIdSet.add(acc.id);
                AccountIdSet8.add(acc.id);
                ContactIdSetIt.add(acc.HeadOfIT__c);
                ContactIdSetAll.add(acc.HeadOfIT__c);     
                AccountIdSetExecContacts.add(acc.ParentId);           
                AccountIdSetExecContacts.add(acc.Ultimate_Parent_Account__c);  

                if(accountOldMap.get(acc.Id).HeadOfIT__c != null){
                    if(unCheckExecContacts.get(accountOldMap.get(acc.Id).HeadOfIT__c) != null){
                        unCheckExecContacts.get(accountOldMap.get(acc.Id).HeadOfIT__c).Head_of_IT__c = false;
                    }else{
                        unCheckExecContacts.put(accountOldMap.get(acc.Id).HeadOfIT__c, new Contact(Id = accountOldMap.get(acc.Id).HeadOfIT__c, Head_of_IT__c = false));                                     
                    }
                    
                }                

            }
            if(acc.HeadOfSecurity__c != accountOldMap.get(acc.Id).HeadOfSecurity__c){
                system.debug('HeadOfSecurity__c field value has been changed');
                AccountIdSet.add(acc.id);
                AccountIdSet9.add(acc.id);
                ContactIdSetSec.add(acc.HeadOfSecurity__c);  
                ContactIdSetAll.add(acc.HeadOfSecurity__c);                     
                AccountIdSetExecContacts.add(acc.ParentId);           
                AccountIdSetExecContacts.add(acc.Ultimate_Parent_Account__c);

                if(accountOldMap.get(acc.Id).HeadOfSecurity__c != null){
                    if(unCheckExecContacts.get(accountOldMap.get(acc.Id).HeadOfSecurity__c) != null){
                        unCheckExecContacts.get(accountOldMap.get(acc.Id).HeadOfSecurity__c).Head_of_Security__c = false;
                    }else{
                        unCheckExecContacts.put(accountOldMap.get(acc.Id).HeadOfSecurity__c, new Contact(Id = accountOldMap.get(acc.Id).HeadOfSecurity__c, Head_of_Security__c = false));
                    }
                }
                
            }
            if(acc.HeadOfNetworking__c != accountOldMap.get(acc.Id).HeadOfNetworking__c){
                system.debug('HeadOfNetworking__c field value has been changed');
                AccountIdSet.add(acc.id);
                AccountIdSet10.add(acc.id);
                ContactIdSetNet.add(acc.HeadOfNetworking__c); 
                ContactIdSetAll.add(acc.HeadOfNetworking__c);                     
                AccountIdSetExecContacts.add(acc.ParentId);           
                AccountIdSetExecContacts.add(acc.Ultimate_Parent_Account__c); 

                if(accountOldMap.get(acc.Id).HeadOfNetworking__c != null){
                    if(unCheckExecContacts.get(accountOldMap.get(acc.Id).HeadOfNetworking__c) != null){
                        unCheckExecContacts.get(accountOldMap.get(acc.Id).HeadOfNetworking__c).Head_of_Networking__c = false;
                    }else{
                        unCheckExecContacts.put(accountOldMap.get(acc.Id).HeadOfNetworking__c, new Contact(Id = accountOldMap.get(acc.Id).HeadOfNetworking__c, Head_of_Networking__c = false));                                     
                    }
                }
                
            }
            if(acc.Head_of_Architecture__c != accountOldMap.get(acc.Id).Head_of_Architecture__c){
                system.debug('Head_of_Architecture__c field value has been changed');
                AccountIdSet.add(acc.id);
                AccountIdSet11.add(acc.id);
                ContactIdSetArch.add(acc.Head_of_Architecture__c); 
                ContactIdSetAll.add(acc.Head_of_Architecture__c);                      
                AccountIdSetExecContacts.add(acc.ParentId);           
                AccountIdSetExecContacts.add(acc.Ultimate_Parent_Account__c); 

                if(accountOldMap.get(acc.Id).Head_of_Architecture__c != null){
                    if(unCheckExecContacts.get(accountOldMap.get(acc.Id).Head_of_Architecture__c) != null){
                        unCheckExecContacts.get(accountOldMap.get(acc.Id).Head_of_Architecture__c).Architecture__c = false;
                    }else{
                        unCheckExecContacts.put(accountOldMap.get(acc.Id).Head_of_Architecture__c, new Contact(Id = accountOldMap.get(acc.Id).Head_of_Architecture__c, Architecture__c = false));                                     
                    }
                    
                }                
                
            }
            //Added by Abhijit : CR866 : End   
            
            //Added by Swathi: CR1116 Starts
            if(acc.accountBuyingStage6sense_ZIA__c == 'Purchase' && acc.accountBuyingStage6sense_ZIA__c != accountOldMap.get(acc.Id).accountBuyingStage6sense_ZIA__c){
                AccountIdSet.add(acc.id);
                AccountIdSet12.add(acc.id);
            }
            if(acc.accountBuyingStage6sense_ZPA__c == 'Purchase' && acc.accountBuyingStage6sense_ZPA__c != accountOldMap.get(acc.Id).accountBuyingStage6sense_ZPA__c){
                
                AccountIdSet.add(acc.id);
                AccountIdSet13.add(acc.id);
            }
            if(accountOldMap.get(acc.Id).accountBuyingStage6sense_ZIA__c == 'Purchase' && acc.accountBuyingStage6sense_ZIA__c != accountOldMap.get(acc.Id).accountBuyingStage6sense_ZIA__c){
                
                AccountIdSet.add(acc.id);
                AccountIdSet14.add(acc.id);
            }
            if(accountOldMap.get(acc.Id).accountBuyingStage6sense_ZPA__c == 'Purchase' && acc.accountBuyingStage6sense_ZPA__c != accountOldMap.get(acc.Id).accountBuyingStage6sense_ZPA__c){
                
                AccountIdSet.add(acc.id);
                AccountIdSet15.add(acc.id);
            }
            //Added by Swathi: CR1116 ends
            
            //Added By viral starts
            if(acc.type!=accountOldMap.get(acc.id).type && (acc.Type== 'Ex-Customer' || acc.type=='Customer' || (acc.type=='Prospect' && (acc.Prospect_Type__c == 'Pipeline' || acc.Prospect_Type__c == 'POC'))))
            {
                AccountIdSet.add(acc.id);
                AccountIdSet16.add(acc.id);
            }
           
            if(acc.type=='Prospect' && acc.Prospect_Type__c != accountOldMap.get(acc.id).Prospect_Type__c && (acc.Prospect_Type__c == 'Pipeline' || acc.Prospect_Type__c == 'POC'))
            {
                AccountIdSet.add(acc.id);
                AccountIdSet16.add(acc.id);
            }
            //Added By viral ends
            //Added by Swathi : CR1142 starts
            if(acc.Account_Manager__c != accountOldMap.get(acc.Id).Account_Manager__c || acc.OwnerId != accountOldMap.get(acc.Id).OwnerId){ 
                AccountIdSet.add(acc.id);
                AccountIdSet17.add(acc.id);
            }
            //Added by Swathi : CR1142 ends
        }
        system.debug('AccountidSet  '+AccountidSet);
        system.debug('AccountIdSet16  '+AccountIdSet16);
        if(AccountidSet.size()>0){
            for(Account_Extension__c AccExt:[Select id,Account__c,Date_of_Last_CS_Management_Notes__c,CS_Management_Notes__c,Account__r.CS_Management_Notes__c,
Date_of_Last_Customer_business_objective__c,Customer_s_Business_Objectives__c,
Account__r.Summarize_the_Value_to_the_Customer__c,Date_of_Last_Customer_History_Next_Steps__c,Customer_Next_Steps__c,
Account__r.Customer_Next_Steps__c,Date_of_Architecture_Workshop_Link__c,Account__r.Architecture_Workshop_Link__c,
Architecture_next_step__c,Date_of_Architecture_next_step__c,Account__r.Arch_workshop_next_steps__c,QBR_Link__c,
Date_of_QBR_Link__c,Account__r.ZSR_Link__c,Sync_To_JIRA__c,Account_Manager_Time_tracker__c,Account_Manager_tracker__c from Account_Extension__c where Account__c IN:AccountidSet]){
                system.debug('AccExt  '+AccExt);
                if(AccountIdSet2!=null && AccountIdSet2.contains(AccExt.Account__c)){
                    AccExt.Date_of_Last_Customer_business_objective__c=Date.valueOf(System.now());
                    AccExt.Customer_s_Business_Objectives__c=AccExt.Account__r.Summarize_the_Value_to_the_Customer__c;
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                if(AccountIdSet3!=null && AccountIdSet3.contains(AccExt.Account__c)){
                    AccExt.Date_of_Last_CS_Management_Notes__c=Date.valueOf(System.now());
                    AccExt.CS_Management_Notes__c=AccExt.Account__r.CS_Management_Notes__c;
                    //AccountExtension2Update.add(AccExt);
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                if(AccountIdSet4!=null && AccountIdSet4.contains(AccExt.Account__c)){
                    AccExt.Date_of_Last_Customer_History_Next_Steps__c=Date.valueOf(System.now());
                    AccExt.Customer_Next_Steps__c=AccExt.Account__r.Customer_Next_Steps__c;
                    //AccountExtension2Update.add(AccExt);
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                if(AccountIdSet5!=null && AccountIdSet5.contains(AccExt.Account__c)){
                    AccExt.Date_of_Architecture_Workshop_Link__c=Date.valueOf(System.now());
                    AccExt.Architecture_Workshop_Link__c=AccExt.Account__r.Architecture_Workshop_Link__c;
                    //AccountExtension2Update.add(AccExt);
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                //Added by Gurjinder : CR# 51 : Start
                if(AccountIdSet6!=null && AccountIdSet6.contains(AccExt.Account__c)){
                    AccExt.Date_of_Architecture_next_step__c=Date.valueOf(System.now());
                    AccExt.Architecture_next_step__c=AccExt.Account__r.Arch_workshop_next_steps__c;
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                
                if(AccountIdSet7!=null && AccountIdSet7.contains(AccExt.Account__c)){
                    AccExt.Date_of_QBR_Link__c=Date.valueOf(System.now());
                    AccExt.QBR_Link__c=AccExt.Account__r.ZSR_Link__c;
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                //Added by Gurjinder : CR# 51 : End
                //Added by Abhijit : CR866 : Start
                if(AccountIdSet8!=null && AccountIdSet8.contains(AccExt.Account__c)){
                    system.debug('cccccccccc');
                    AccExt.Head_of_IT_CIO_Update_Date__c = System.Today();
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
        
                if(AccountIdSet9!=null && AccountIdSet9.contains(AccExt.Account__c)){
                    AccExt.Head_of_Security_Update_Date__c = System.Today();
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                
                if(AccountIdSet10!=null && AccountIdSet10.contains(AccExt.Account__c)){
                    AccExt.Head_of_Networking_CTO_Update_Date__c = System.Today();
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                
                if(AccountIdSet11!=null && AccountIdSet11.contains(AccExt.Account__c)){
                    AccExt.Head_of_Architecture_Update_Date__c = System.Today();
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                
                //Added by Abhijit : CR866 : End                
        
                //Added by swathi: CR1116 : Starts
                if(AccountIdSet12!=null && AccountIdSet12.contains(AccExt.Account__c)){
                    AccExt.ZIA_Purchase_Stage_Start_Date__c = System.Today();
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                if(AccountIdSet13!=null && AccountIdSet13.contains(AccExt.Account__c)){
                    AccExt.ZPA_Purchase_Stage_Start_Date__c = System.Today();
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                if(AccountIdSet14!=null && AccountIdSet14.contains(AccExt.Account__c)){
                    AccExt.ZIA_Purchase_Stage_End_Date__c = System.Today();
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                if(AccountIdSet15!=null && AccountIdSet15.contains(AccExt.Account__c)){
                    AccExt.ZPA_Purchase_Stage_End_Date__c = System.Today();
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                //Added by swathi: CR1116 Ends
                
                if(AccountIdSet16!=null && AccountIdSet16.contains(AccExt.Account__c)){
                    if(AccExt.Sync_To_JIRA__c != 'Sync SFDC Account to JIRA' && AccExt.Sync_To_JIRA__c != 'Sync to JIRA Completed'){
                        AccExt.Sync_To_JIRA__c = 'Sync SFDC Account to JIRA';
                        AccountExtension2Update.put(AccExt.id,AccExt);
                    }
                }
                
                //Added by Swathi: CR1142 Starts
                 if(AccountIdSet17!=null && AccountIdSet17.contains(AccExt.Account__c)){
                    AccExt.Account_Manager_Time_tracker__c = System.Now();
                    AccExt.Account_Manager_tracker__c = True;
                    AccountExtension2Update.put(AccExt.id,AccExt);
                }
                //Added by Swathi : CR1142 Ends
            }
            if(AccountExtension2Update!=null){
                update AccountExtension2Update.values();
            }

            //Added by Abhijit : CR866 : Start
            system.debug('AccountIdSetExecContacts - ' + AccountIdSetExecContacts);
            List<Contact> execContacts = new List<Contact>();  
            Map<Id,Contact> contactsToUpdate = new Map<Id, Contact>();                  
            if(!ContactIdSetAll.isEmpty()){
                execContacts = [select id from Contact where Id in: ContactIdSetAll and AccountId in: AccountIdSetExecContacts];
                
                if(!ContactIdSetIt.isEmpty()){
                    for(Contact cont: execContacts){
                        if(ContactIdSetIt.contains(cont.Id)){
                            if(contactsToUpdate.get(cont.Id) != null){
                                contactsToUpdate.get(cont.Id).Head_of_IT__c = true;
                            }else{
                                cont.Head_of_IT__c = true;
                                contactsToUpdate.put(cont.Id, cont);                            
                            }
                        }
                    }
                }
    
                if(!ContactIdSetArch.isEmpty()){
                    for(Contact cont: execContacts){
                        if(ContactIdSetArch.contains(cont.Id)){
                            if(contactsToUpdate.get(cont.Id) != null){
                                contactsToUpdate.get(cont.Id).Architecture__c = true;
                            }else{
                                cont.Architecture__c = true;
                                contactsToUpdate.put(cont.Id, cont);                            
                            }
                        }
                    }
                }
    
                if(!ContactIdSetSec.isEmpty()){
                    for(Contact cont: execContacts){
                        if(ContactIdSetSec.contains(cont.Id)){
                            if(contactsToUpdate.get(cont.Id) != null){
                                contactsToUpdate.get(cont.Id).Head_of_Security__c = true;
                            }else{
                                cont.Head_of_Security__c = true;
                                contactsToUpdate.put(cont.Id, cont);                            
                            }
                        }
                    }
                }
    
                if(!ContactIdSetNet.isEmpty()){
                    for(Contact cont: execContacts){
                        if(ContactIdSetNet.contains(cont.Id)){
                            if(contactsToUpdate.get(cont.Id) != null){
                                contactsToUpdate.get(cont.Id).Head_of_Networking__c = true;
                            }else{
                                cont.Head_of_Networking__c = true;
                                contactsToUpdate.put(cont.Id, cont);                            
                            }
                        }
                    }
                }
                                
            }
            
            if(!contactsToUpdate.isEmpty()){
                TriggerHandler.bypass('ContactTriggerHandler');
                update contactsToUpdate.values();
            }

            if(!unCheckExecContacts.isEmpty()){
                TriggerHandler.bypass('ContactTriggerHandler');
                update unCheckExecContacts.values();
            }
            
            //Added by Abhijit : CR866 : End            
            
        }
        TriggerUtility.UpdateAccountExtensionmethodsettrue();
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to update the RecordType and Type of the Federal accounts
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    fedAccountList    List of Federal Accounts (List<Account>)
    * @return   void    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    *
    * @author           Chandan Panigrahy
    * @created          2022-01-31
    * 
    * ──────────────────────────────────────────────────────────────────────────────────────────────────
    * @changes
    * vX.X            Developer Name
    * YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
    *                 each line should be indented till left aligned with the previous description text.
    *
    * ─────────────────────────────────────────────────────────────────────────────────────────────────┘
    **/
    
    public static void updateFedAccountCustomerType(List<Account> fedAccountList) {
        Set<String> AccountTypeSet= new Set<String>();
        String AccountTypeSetexceptProspectandCust=ZscalerCustomSetting__c.getInstance('AccountTypeSetexceptProspectandCust')!=null && ZscalerCustomSetting__c.getInstance('AccountTypeSetexceptProspectandCust').Value__c!=null ? ZscalerCustomSetting__c.getInstance('AccountTypeSetexceptProspectandCust').Value__c:'Partner,Ex - Partner,Competitor,Other,Vendor,Press,Industry Analyst,Business Development,Technology Partner,Partner Prospect,Partner Prospect Denied';
        AccountTypeSet.addall(AccountTypeSetexceptProspectandCust.split(','));
        for (Account acc : fedAccountList) {
            if(acc.Active_Contracts__c > 0 && !AccountTypeSet.contains(acc.Type)){
                acc.Type = 'Customer';
                acc.RecordTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User - Customer DS Reviewed').getRecordTypeId();
            }
        }
    }
    
    
    public static void AccountWorkflowOptimizationmethod(list< Account > NewAccountList, map < Id, Account > accountOldMap,boolean IsInsert,boolean isUpdate){
        
        Set<id> CSMidSet= new Set<id>();
        Set<id> TAMidSet= new Set<id>();
        Set<id> USERidSet= new Set<id>();
        Map<id,String> CSMManagerEmail= new Map<id,String>(); 
        Map<id,User> UserMap= new Map<id,User>();
        Set<String> AccountTypeSet= new Set<String>();
        String AccountTypeSetexceptProspectandCust=ZscalerCustomSetting__c.getInstance('AccountTypeSetexceptProspectandCust')!=null && ZscalerCustomSetting__c.getInstance('AccountTypeSetexceptProspectandCust').Value__c!=null ? ZscalerCustomSetting__c.getInstance('AccountTypeSetexceptProspectandCust').Value__c:'Partner,Ex - Partner,Competitor,Other,Vendor,Press,Industry Analyst,Business Development,Technology Partner,Partner Prospect,Partner Prospect Denied,Unsellable';  //Added Unsellable byAyush kangar as part of CR#5138
        AccountTypeSet.addall(AccountTypeSetexceptProspectandCust.split(','));
        
        String EndUserProspectDSReviewedRecordTypeid=ZscalerCustomSetting__c.getInstance('EndUserProspectDSReviewedRecordTypeid')!=null && ZscalerCustomSetting__c.getInstance('EndUserProspectDSReviewedRecordTypeid').Value__c!=null ? ZscalerCustomSetting__c.getInstance('EndUserProspectDSReviewedRecordTypeid').Value__c:'01270000000EAFnAAO';
        
        String EndUserCustDSReviewedRecordTypeid=ZscalerCustomSetting__c.getInstance('EndUserCustDSReviewedRecordTypeid')!=null && ZscalerCustomSetting__c.getInstance('EndUserCustDSReviewedRecordTypeid').Value__c!=null ? ZscalerCustomSetting__c.getInstance('EndUserCustDSReviewedRecordTypeid').Value__c:'01270000000EAFsAAO';
        
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Account').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofCaseRecordTypeNameandId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapofCaseRecordTypeNameandId.put(info.getDeveloperName(),info.getRecordTypeId());
        }
    
        //Added by Varun - CR 1068 - Start
        Set<Id>accountWithSKUCodes = new  Set<Id>();
        if(accountOldMap!=null){
            
            List<Contract_Detail__c> contractDetails = [Select id,Product_SKU__c,Account_Name__c from
                                                        Contract_Detail__c where  Product_SKU__c in ('ZIA-ELA-BUNDLE','ZCES-SUP-TAMT') 
                                                        and 
                                                        Account_Name__c =:accountOldMap.keySet()];   
            for(Contract_Detail__c cd:contractDetails){
                accountWithSKUCodes.add(cd.Account_Name__c);
            }
        }
        //Added by Varun - CR 1068 - End
        
        for(Account acc:NewAccountList){
        //1. Capture date when traffic consumption hits 50% :start
            if(acc.Avg_Estimated_Users_L31D_Vs_Purchase__c>=50 && acc.X50_Traffic_attained_date__c==null){
                acc.X50_Traffic_attained_date__c=Date.valueOf(System.now());
            }       
        //1. Capture date when traffic consumption hits 50% :End
        
        //2. Capture date when traffic consumption hits 75% :start
            if(acc.Avg_Estimated_Users_L31D_Vs_Purchase__c>=75 && acc.X75_Traffic_attained_date__c==null){
                acc.X75_Traffic_attained_date__c=Date.valueOf(System.now());
            }       
        //2. Capture date when traffic consumption hits 75% :End
        
        //3. Capture date when traffic consumption hits 100%    :start
            if(acc.Avg_Estimated_Users_L31D_Vs_Purchase__c>=100 && acc.X100_Traffic_attained_date__c==null){
                acc.X100_Traffic_attained_date__c=Date.valueOf(System.now());
            }       
        //3. Capture date when traffic consumption hits 100%    :End
        
        //4.Reset Deployment Phase Risk - Design Over Due:Start
            if((acc.Design_Completed_Date__c!=null) && (acc.Deployment_Phase_Risk__c != null && acc.Deployment_Phase_Risk__c.equalsignorecase('Design Complete Over Due'))){
                acc.Deployment_Phase_Risk__c='None';
            }
        //4.Reset Deployment Phase Risk - Design Over Due:End
        
        //5.Reset Deployment Phase Risk - Kick-Off Over Due :Start
            if(acc.Kick_Off_Call_Date__c!=null && (acc.Deployment_Phase_Risk__c != null && acc.Deployment_Phase_Risk__c.equalsignorecase('Kick Off Over Due'))){
                acc.Deployment_Phase_Risk__c='None';
            }
        //5.Reset Deployment Phase Risk - Kick-Off Over Due :End
        
        //6. Reset Traffic Risk :Start
            if(acc.Date_when_traffic_consumed_is_25__c!=null){
                acc.Deployment_Phase_Risk__c='None';
                acc.Traffic_Risk__c='None';
            }
        //6. Reset Traffic Risk :End
        
        //7. Capture date when ZPA enrolled users hit 10% :Start
            if(acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>=10 && acc.X10_ZPA_Traffic_attained_date__c==null){
                acc.X10_ZPA_Traffic_attained_date__c=Date.valueOf(System.now());
            }
        //7. Capture date when ZPA enrolled users hit 10% :End
        
        //8. Capture date when ZPA enrolled users hits 65% :Start
            if(acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>=65 && acc.X65_ZPA_Traffic_attained_date__c==null){
                acc.X65_ZPA_Traffic_attained_date__c=Date.valueOf(System.now());
            }
        //8. Capture date when ZPA enrolled users hits 65% :End
            if(acc.CSM_Name_New__c!=null){
                CSMidSet.add(acc.CSM_Name_New__c);
                USERidSet.add(acc.CSM_Name_New__c);
            }
            
            /********************PHASE 2 Start ******************/
            //Added by Gurjinder : CR# 58  : Start  
            //9. Update Customer Business Objective Last modified date:Start
            if(isUpdate && acc.Summarize_the_Value_to_the_Customer__c!=accountOldMap.get(acc.id).Summarize_the_Value_to_the_Customer__c){
                acc.Date_of_Last_Customer_business_objective__c=Date.valueOf(System.now());
            }else{
            }           
            //9. Update Customer Business Objective Last modified date:End
            
            //10. Rule to update the old TAM name:Start
            if(acc.TAM_Name_New__c!=null){
                TAMidSet.add(acc.TAM_Name_New__c);
                USERidSet.add(acc.TAM_Name_New__c);
            }
            //10. Rule to update the old TAM name:End
            
            //11. Exclude from Fuel Lines for Major Accounts:Start
            if(acc.Territory_Type__c=='Major'){
                acc.Exclude_from_Fuel_Lines__c=true;
            }
            //11. Exclude from Fuel Lines for Major Accounts:End
            
            //12. Capture date when ZPA enrolled users hits 25%:Start
            if(acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>=25 && acc.X25_ZPA_Traffic_attained_date__c==null){
                acc.X25_ZPA_Traffic_attained_date__c=Date.valueOf(System.now());
            }
            //12. Capture date when ZPA enrolled users hits 25%:End
            
            //13. Capture date when ZPA enrolled users hits 50%:Start
            if(acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>=50 && acc.X50_ZPA_Traffic_attained_date__c==null){
                acc.X50_ZPA_Traffic_attained_date__c=Date.valueOf(System.now());
            }
            //13. Capture date when ZPA enrolled users hits 50%:End 
            
            //14. Capture date when ZPA enrolled users hits 75%:Start
            if(acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>=75 && acc.X75_ZPA_Traffic_attained_date__c==null){
                acc.X75_ZPA_Traffic_attained_date__c=Date.valueOf(System.now());
            }
            //14. Capture date when ZPA enrolled users hits 75%:End
            
            //15. Capture date when ZPA enrolled users hits over 100%:Start
            if(acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>=100 && acc.X100_ZPA_Traffic_attained_date__c==null){
                acc.X100_ZPA_Traffic_attained_date__c=Date.valueOf(System.now());
            }
            //15. Capture date when ZPA enrolled users hits over 100%:End
            
            //16. Default to Net 30 and Annual  :Start
            if(acc.Type=='Partner' && (acc.Billing_Frequency__c=='' || acc.Billing_Frequency__c==null) && (acc.Payment_Terms__c=='' || acc.Payment_Terms__c==null)){
                acc.Billing_Frequency__c='Annual';
                acc.Payment_Terms__c='Net 30';
            }
            //16. Default to Net 30 and Annual  :End
            
            //17. Populate the Customer Success Win Field : Start
            if(acc.Success_Stage__c!=Null && acc.Success_Stage__c=='4 - Transformation in Progress (25%+ Deployed)' && acc.Success_Stage__c!=accountOldMap.get(acc.id).Success_Stage__c){
                acc.Customer_Success_Win_Date__c=Date.valueOf(System.now());
            }
            //17. Populate the Customer Success Win Field : End
            
            //18. Capture date when traffic consumption hits 10%: Start
            if(acc.Avg_Estimated_Users_L31D_Vs_Purchase__c>=10 && acc.X10_Traffic_attained_date__c==null){
                acc.X10_Traffic_attained_date__c=Date.valueOf(System.now());
            }
            //18. Capture date when traffic consumption hits 10%: End
            
            //19. ABM Request Profiling is Completed: Start
            //if(isupdate && acc.ABM_Profiling_Status__c =='Completed' && acc.ABM_Profiling_Status__c !=accountOldMap.get(acc.id).ABM_Profiling_Status__c ){
           //     acc.ABM_Profiled_Date__c=Date.valueOf(System.now());
           // }
                
            //19. ABM Request Profiling is Completed: End
            
            //20. ABM Request Profiling is Submitted: Start
          //  if(isupdate && acc.ABM_Status__c=='Submitted' && acc.ABM_Status__c!=accountOldMap.get(acc.id).ABM_Status__c){
          //      acc.ABM_Request_Date__c=Date.valueOf(System.now());
         //  }
            //20. ABM Request Profiling is Submitted: End
            //21. Setting the Type as Prospect DS: Start
            if(acc.DS_Review_Status__c=='Complete' && acc.Active_Contracts__c==0 && acc.Contracts__c==0 && !AccountTypeSet.contains(acc.Type)){
                acc.Type='Prospect';
                acc.RecordTypeid=mapofCaseRecordTypeNameandId.get('End_User_Prospect_DS_Reviewed');
            }
            //21. Setting the Type as Prospect DS: End
            
            //22. Set Account for Pending DS Review : Start
            if(acc.DS_Review_Status__c==null || acc.DS_Review_Status__c==''){
                acc.DS_Review_Status__c='Pending';
            }
            //22. Set Account for Pending DS Review : End
            
            //23. Account: Setting the Type as Customer : Start
            
            if(acc.Active_Contracts__c > 0 && !AccountTypeSet.contains(acc.Type)){
                acc.Type='Customer';
                acc.RecordTypeid=mapofCaseRecordTypeNameandId.get('End_User_Customer_DS_Reviewed');
            }
            //23. Account: Setting the Type as Customer : End
            
            //24. Account: Setting the Type as Ex - Customer: Start
            if(acc.Active_Contracts__c<1 && acc.Contracts__c>0 && !AccountTypeSet.contains(acc.Type)){
                acc.Type='Ex-Customer';
                acc.RecordTypeid=mapofCaseRecordTypeNameandId.get('End_User_Customer_DS_Reviewed');
            }
            //24. Account: Setting the Type as Ex - Customer: End
            
            //25. Account: Setting the Type as Prospect : Start
            if(acc.DS_Review_Status__c=='Pending' && acc.Active_Contracts__c<1 && acc.Contracts__c<1 && !AccountTypeSet.contains(acc.Type)){
                acc.Type='Prospect';
                acc.RecordTypeid=mapofCaseRecordTypeNameandId.get('End_User');
            }
            //25. Account: Setting the Type as Prospect : End
            //Anup - Commenting below code in order to prevent override - Start
            /*//26. Account: Setting Support Type: Premium Sup when PS ACV is <25000: Start
            if(acc.Support_Type_Exception__c==false && acc.Premium_Support_ACV__c>0 && acc.Premium_Support_ACV__c<25000 ){
                acc.Support_Type__c='Premium Support';
            }
            //26. Account: Setting Support Type: Premium Sup when PS ACV is <25000: End
            
            //27. Account: Setting Support Type: Premium Plus Sup when PS ACV is >=25000: Start
            if(acc.Id!=null && ((acc.Premium_Support_ACV__c >= 25000|| accountWithSKUCodes.contains(acc.Id)) && acc.Support_Type_Exception__c==false )){//Modified if Condition by Varun - CR 1069
                acc.Support_Type__c='Premium Plus Support';
            }
            //27. Account: Setting Support Type: Premium Plus Sup when PS ACV is >=25000: End
            
            //28. Account: Setting Support Type to Null when PS ACV is 0: Start
             if(acc.Id!=null && !accountWithSKUCodes.contains(acc.Id) && acc.Support_Type_Exception__c==false && acc.Premium_Support_ACV__c ==0){
                acc.Support_Type__c='';
            } 
            //28. Account: Setting Support Type to Null when PS ACV is 0: End*/
            
            //IBA-3554 : Added by Anup - Start
            String revenueForDefaultPPSupport = Label.Account_Threshold_Revenue_For_Default_Support_Type;
            Integer thresholdRevenue = Integer.valueOf(revenueForDefaultPPSupport);
            if((IsInsert || acc.Type!=accountOldMap.get(acc.Id).Type) && acc.Type=='Partner'){
                acc.Support_Type__c = Label.Default_Support_Type_For_Partner_Type_Account;
            }
            else if((IsInsert || (acc.Type!=accountOldMap.get(acc.Id).Type) || acc.Premium_Support_ACV__c != accountOldMap.get(acc.Id).Premium_Support_ACV__c) && acc.Type=='Customer' && acc.Premium_Support_ACV__c==0){
                acc.Support_Type__c = Label.Default_Support_Type_For_Customer_With_ACV_0;
            }
            else if((IsInsert || acc.Premium_Support_ACV__c != accountOldMap.get(acc.Id).Premium_Support_ACV__c) && acc.Premium_Support_ACV__c>thresholdRevenue){
                acc.Support_Type__c = Label.Account_Default_Support_Type_Threshold_ACV;
            }
            else if((IsInsert || acc.Type!=accountOldMap.get(acc.Id).Type || acc.Prospect_Type__c!=accountOldMap.get(acc.Id).Prospect_Type__c) && acc.Type=='Prospect' && acc.Prospect_Type__c=='POC') {
                acc.Support_Type__c = Label.Default_Support_Type_For_Prospect_and_POC;
            }
            //IBA-3554 : Added by Anup - End
            
            //29. Capture date when traffic consumption hits 25%:Start
            if(acc.Avg_Estimated_Users_L31D_Vs_Purchase__c>=25 && acc.Date_when_traffic_consumed_is_25__c==null){
                acc.Date_when_traffic_consumed_is_25__c=Date.valueOf(System.now());
            }
            //29. Capture date when traffic consumption hits 25%:End 
            //Added by Gurjinder : CR# 58  : Start 
            /********************PHASE 2 End ******************/
            
            // Added by Ayush Kangar as part of CR# 5107 - Start
            if(acc.Active_Users_L30D_Vs_Purchased_Users__c>=10 && acc.X10_ZDX_Traffic_attained_date__c==null){
                acc.X10_ZDX_Traffic_attained_date__c=Date.valueOf(System.now());
            }
            if(acc.Active_Users_L30D_Vs_Purchased_Users__c>=25 && acc.X25_ZDX_Traffic_attained_date__c==null){
                acc.X25_ZDX_Traffic_attained_date__c=Date.valueOf(System.now());
            }
            if(acc.Active_Users_L30D_Vs_Purchased_Users__c>=50 && acc.X50_ZDX_Traffic_attained_date__c==null){
                acc.X50_ZDX_Traffic_attained_date__c=Date.valueOf(System.now());
            }
            if(acc.Active_Users_L30D_Vs_Purchased_Users__c>=75 && acc.X75_ZDX_Traffic_attained_date__c==null){
                acc.X75_ZDX_Traffic_attained_date__c=Date.valueOf(System.now());
            }
            if(acc.Active_Users_L30D_Vs_Purchased_Users__c>=100 && acc.X100_ZDX_Traffic_attained_date__c==null){
                acc.X100_ZDX_Traffic_attained_date__c=Date.valueOf(System.now());
            }
            // Added by Ayush Kangar as part of CR# 5107 - End

            
        }
        if(isUpdate && !TriggerUtility.IsCSMmanagerEmailCodeexecuted()){
            for(User usr:[select id,Name,Email,Managerid,manager.email from user where ID IN:USERidSet ]){
                //CSMManagerEmail.put(usr.id,usr.manager.email);
                UserMap.put(usr.id,usr);
            }
            System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            for(Account acc:NewAccountList){
                if(acc.CSM_Name_New__c!=null && UserMap!=null && UserMap.containskey(acc.CSM_Name_New__c)){
                    acc.CSM_Manager_Email__c=UserMap.get(acc.CSM_Name_New__c).manager.email;
                }              
                if(acc.TAM_Name_New__c!=null && UserMap!=null && UserMap.containskey(acc.TAM_Name_New__c)){
                    acc.TAM_Name__c=UserMap.get(acc.TAM_Name_New__c).Name;
                    acc.TAM_Email__c=UserMap.get(acc.TAM_Name_New__c).Email;
                }               
            }
            TriggerUtility.IsCSMmanagerEmailCodeexecutedsettrue();
        }
        
    }

    // IBA-1931 START
    public static void updateAssociatedStudentRecords(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap) {
        Set<Id> filteredAccountIdSet = new Set<Id>();
        for (Account currentAccount : newAccountMap.values()) {
            if (!currentAccount.Is_Federal_Account_Sync__c && currentAccount.Type != oldAccountMap.get(currentAccount.Id).Type) {
                filteredAccountIdSet.add(currentAccount.Id);
            }
        }

        List<skilljar__Student__c> studentList = getAssociatedStudents(filteredAccountIdSet);
        List<skilljar__Student__c> studentToUpdateList = new List<skilljar__Student__c>();
        for (skilljar__Student__c currentStudent : studentList) {
            Account currentAccount = newAccountMap.get(currentStudent.Account__c);
            Account oldAccount = oldAccountMap.get(currentStudent.Account__c);

            Boolean isStudentUpdated = false;

            if ('Prospect'.equalsIgnoreCase(oldAccount.Type) && 'Customer'.equalsIgnoreCase(currentAccount.Type)) {
                currentStudent.Account_Type__c = currentAccount.Type;
                isStudentUpdated = true;
            } else if ('Customer'.equalsIgnoreCase(oldAccount.Type) && 'Ex-Customer'.equalsIgnoreCase(currentAccount.Type)) {
                currentStudent.Account_Type__c = 'Guest';
                isStudentUpdated = true;
            }

            if (isStudentUpdated) {
                studentToUpdateList.add(currentStudent);
            }
        }

        if (!studentToUpdateList.isEmpty()) {
            update studentToUpdateList;
        }
    }

    private static List<skilljar__Student__c> getAssociatedStudents(Set<Id> accountIdSet) {
        if (accountIdSet == null) {
            throw new IllegalArgumentException('Parameter accountIdSet should not be null.');
        }
        // IBA-2245 START
        return accountIdSet.isEmpty() ? new List<skilljar__Student__c>() : [SELECT Id, Account_Type__c, Account__c FROM skilljar__Student__c WHERE Account__c IN :accountIdSet];
        // IBA-2245 END
    }
    // IBA-1931 END

    public static void entitlementCreationforProspect(List<Account> acclst){
        Map<Id, String> accmap = new Map<Id, String>();
        for(Account acc: acclst){
            if(acc.type == 'Prospect'){
                accmap.put(acc.Id, 'Premium Plus');
            }
        }
        if(accmap != null && !accmap.isEmpty()){
            EntitlementManagement.createEntitleMent(accmap);
            TriggerUtility.ProspectEntitlementExecuted();
        }
    }

    public static void updateEntitlement(List<Account> acclst, Map<id, account> oldmap){
        Map<Id, String> accmap = new Map<Id, String>();
        Map<String, String> mapofSupportTypeEntitlement = new Map<String, String>();
        for(Support_Type_To_Entitlement__mdt suppData : [Select Support_Type__c,Entitlement__c from Support_Type_To_Entitlement__mdt]){
            mapofSupportTypeEntitlement.put(suppData.Support_Type__c, suppData.Entitlement__c);
        }
        for(Account acc: acclst){
            if((acc.type == 'Customer' || acc.type == 'Prospect' || acc.type == 'Partner') && (acc.type != oldmap.get(acc.Id).type || acc.Support_Type__c != oldmap.get(acc.Id).Support_Type__c)){
                if(acc.type == 'Prospect'){
                    accmap.put(acc.Id, 'Premium Plus');
                }/*else if(acc.Support_Type__c == 'Premium Support'){
                    accmap.put(acc.Id, 'Premium');
                }else if(acc.Support_Type__c == 'Premium Plus Support'){
                    accmap.put(acc.Id, 'Premium Plus');
                }*/
                else if(mapofSupportTypeEntitlement!=null && mapofSupportTypeEntitlement.containsKey(acc.Support_Type__c) && mapofSupportTypeEntitlement.get(acc.Support_Type__c)!=null){
                    accmap.put(acc.Id, mapofSupportTypeEntitlement.get(acc.Support_Type__c));
                }else{
                    accmap.put(acc.Id, 'Standard');
                }
            }
        }
        if(accmap != null && !accmap.isEmpty()){
            EntitlementManagement.updateExistingEntitlement(accmap);
            EntitlementManagement.createEntitleMent(accmap);
            //TriggerUtility.EntitlementUpdateExecuted();
        }
        
    }
    /*public static void accountPatchHelper(List<Account> newAccounts){
        
    }
    
    //public static void accountUpdatePatchHelper(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts){
        
    //}
    
   
    /*@future
    public static void retainOldTeamMemberOnOwnerChange(String str){
        List<AccountTeamMember> newlistAcc = (List<AccountTeamMember>) JSON.deserialize(str,List<AccountTeamMember>.class);
        for(AccountTeamMember objAccTeamMember : newlistAcc){
            objAccTeamMember.Id= null;
        }
        system.debug('Account records to insert'+(JSON.serialize(newlistAcc)));
        Upsert newlistAcc;
    }*/
    
    public static void UpdateDateRange(List<Account> acclst,Map<Id, Account> oldAccounts){
        
        for(Account acc: acclst){
            if(acc.Legal_Certification_Date__c != null && oldAccounts.get(acc.Id).Legal_Certification_Date__c != acc.Legal_Certification_Date__c){
                string StartDate = '1/17/' + acc.Legal_Certification_Date__c.year();
                Integer StartYear = acc.Legal_Certification_Date__c.year();
                system.debug('--legal date--' + acc.Legal_Certification_Date__c + '--added date--' + Date.parse(StartDate));
                if(acc.Legal_Certification_Date__c > Date.parse(StartDate)){
                    string EndDate = '1/16/'+ (StartYear+1);
                    acc.Signed_Legal_Certification_Date__c = Date.parse(EndDate);
                }
                else{
                    string EndDate = '1/16/'+ (StartYear);
                    acc.Signed_Legal_Certification_Date__c = Date.parse(EndDate);
                }
                
                if(acc.Signed_Legal_Certification_Date__c > system.today()){
                 	//Mahesh T Commented below as part of IBA-4370
                    //  acc.Type = 'Partner';
                }
            }
            
            if(acc.Legal_Questionaire_Date__c != null && oldAccounts.get(acc.Id).Legal_Questionaire_Date__c != acc.Legal_Questionaire_Date__c){
                string StartDate = '1/17/'+ acc.Legal_Questionaire_Date__c.year();
                Integer StartYear = acc.Legal_Questionaire_Date__c.year();
                system.debug('--legal date--' + acc.Legal_Questionaire_Date__c + '--added date--' + Date.parse(StartDate));
                if(acc.Legal_Questionaire_Date__c > Date.parse(StartDate)){
                    string EndDate = '1/16/'+ (StartYear+3);
                    acc.Signed_Legal_Questionaire_Date__c = Date.parse(EndDate);
                }
                else{
                    string EndDate = '1/16/'+ (StartYear+2);
                    acc.Signed_Legal_Questionaire_Date__c = Date.parse(EndDate);
                }
                
                if(acc.Signed_Legal_Certification_Date__c > system.today()){
                    //Mahesh T Commented below as part of IBA-4370
                    // acc.Type = 'Partner';
                }
            }
        }
    }
    
    public static void UpdateDateRange(List<Account> acclst){
        
        for(Account acc: acclst){
            if(acc.Legal_Certification_Date__c != null){
                string StartDate = '1/17/'+ acc.Legal_Certification_Date__c.year();
                Integer StartYear = acc.Legal_Certification_Date__c.year();
                system.debug('--legal date--'+acc.Legal_Certification_Date__c+'--added date--'+Date.parse(StartDate));
                if(acc.Legal_Certification_Date__c > Date.parse(StartDate)){
                    string EndDate = '1/16/'+ (StartYear+1);
                    acc.Signed_Legal_Certification_Date__c = Date.parse(EndDate);
                }else{
                    string EndDate = '1/16/'+ (StartYear);
                    acc.Signed_Legal_Certification_Date__c = Date.parse(EndDate);
                }
            }
            
            if(acc.Legal_Questionaire_Date__c != null){
                string StartDate = '1/17/'+ acc.Legal_Questionaire_Date__c.year();
                Integer StartYear = acc.Legal_Questionaire_Date__c.year();
                system.debug('--legal date--'+acc.Legal_Questionaire_Date__c+'--added date--'+Date.parse(StartDate));
                if(acc.Legal_Questionaire_Date__c > Date.parse(StartDate)){
                    string EndDate = '1/16/'+ (StartYear+3);
                    acc.Signed_Legal_Questionaire_Date__c = Date.parse(EndDate);
                }else{
                    string EndDate = '1/16/'+ (StartYear+2);
                    acc.Signed_Legal_Questionaire_Date__c = Date.parse(EndDate);
                }
            }
        }
    }
    
  //add by : tirth patel
    //CR#996 : if account has csm_name__c != null-then update customer_success_engment on account_extension__c
    
    public static void CreateAccExtensionrecord(List<Account> acclst){
        List<Account_Extension__c> AccExtlist = new List<Account_Extension__c>();
        for(Account acc: acclst){
            Account_Extension__c accext= new Account_Extension__c(Account__c=acc.id);
            if(acc.Type== 'Ex-Customer' || 
               acc.type=='Customer' || 
               (acc.type=='Prospect' && (acc.Prospect_Type__c == 'Pipeline' || acc.Prospect_Type__c == 'POC')) )
            {
                accext.Sync_To_JIRA__c = 'Sync SFDC Account to JIRA';
            }else{
                accext.Sync_To_JIRA__c = 'Not Applicable';
            }
            if(acc.Type == 'Customer'){
                accext.Converted_To_Customer_On__c = System.Today();
                if(acc.CSM_Name_New__c != null || acc.CSM_Name_2__c != null){
                    accext.Customer_Success_Engagement__c = 'High';
                }
            }
            AccExtlist.add(accext);
        }
        if(!AccExtlist.isempty() && AccExtlist.size()>0){  
            insert AccExtlist;
        }
        
        TriggerUtility.CreateAccExtensionExecuted();
    }
   

    public static void UpdateCSMAccountExtenssionMethod(Set<Id> accIdSet) {
        List<Account_Extension__c> accountExtensionUpdateList = [Select id,Account__c,Account__r.CSM_Name_New__c,Account__r.CSM_Name_2__c, Account__r.Type,Account__r.Account_Renewable_ACV__c, Customer_Success_Engagement__c, Converted_To_Customer_On__c,Override_CS_Engagement__c from Account_Extension__c where Account__c IN :accIdSet  AND Account__r.Type = 'Customer'];
        for (Account_Extension__c accExt : accountExtensionUpdateList) {
            if(accExt.Override_CS_Engagement__c==false && accExt.Account__r.Account_Renewable_ACV__c != null && accExt.Account__r.Account_Renewable_ACV__c>=50000){
                accExt.Customer_Success_Engagement__c = 'high';
            } else if(accExt.Override_CS_Engagement__c==false && accExt.Account__r.Account_Renewable_ACV__c != null && accExt.Account__r.Account_Renewable_ACV__c<50000){
                accExt.Customer_Success_Engagement__c = 'tech';
            }            
            
        }
        
        UPDATE accountExtensionUpdateList;
        
        
        TriggerUtility.UpdateCSMAccountExtenssionMethodsettrue();
    }
    
    @future
    public static void UpdateCSMAccountExtenssionMethodAsync(Set<Id> accIdSet) {
        List<Account_Extension__c> accountExtensionUpdateList = [Select id,Account__c,Account__r.CSM_Name_New__c,Account__r.CSM_Name_2__c, Account__r.Type,Account__r.Account_Renewable_ACV__c, Customer_Success_Engagement__c, Converted_To_Customer_On__c,Override_CS_Engagement__c from Account_Extension__c where Account__c IN :accIdSet  AND Account__r.Type = 'Customer'];
        for (Account_Extension__c accExt : accountExtensionUpdateList) {
            if(accExt.Override_CS_Engagement__c == false && accExt.Account__r.Account_Renewable_ACV__c != null && accExt.Account__r.Account_Renewable_ACV__c>=200000 && !accExt.Override_CS_Engagement__c){
                accExt.Customer_Success_Engagement__c = 'high';
            } else if(accExt.Override_CS_Engagement__c==false && accExt.Account__r.Account_Renewable_ACV__c != null && accExt.Account__r.Account_Renewable_ACV__c<200000 && !accExt.Override_CS_Engagement__c){
                accExt.Customer_Success_Engagement__c = 'tech';
            }            
            
        }
        
        UPDATE accountExtensionUpdateList;
        
        TriggerUtility.UpdateCSMAccountExtenssionMethodsettrue();
    }
   /**
   public static void UpdateCSMAccountExtenssionMethod(list<Account> NewAccountList,map < Id, Account > accountOldMap){
        
        List<Account_Extension__c> AccountExtensionUpdateList = [Select id,Account__c,Account__r.CSM_Name_New__c,Account__r.CSM_Name_2__c, Account__r.Type, Customer_Success_Engagement__c, Converted_To_Customer_On__c from Account_Extension__c where Account__c IN:NewAccountList and (Customer_Success_Engagement__c = null OR Customer_Success_Engagement__c = '') AND Account__r.Type = 'Customer'];
        
        if(AccountExtensionUpdateList.size()>0){
            
            for(Account_Extension__c AccExt: AccountExtensionUpdateList){
                if(AccExt.Converted_To_Customer_On__c != null){
                    if(AccExt.Converted_To_Customer_On__c.daysBetween(System.Today()) <= 30){
                        if(AccExt.Account__r.CSM_Name_New__c != null || AccExt.Account__r.CSM_Name_2__c != null){
                            AccExt.Customer_Success_Engagement__c = 'High';
                        }
                    }
                }else if(AccExt.Converted_To_Customer_On__c == null){
                    AccExt.Converted_To_Customer_On__c = System.Today();
                    if(AccExt.Account__r.CSM_Name_New__c != null || AccExt.Account__r.CSM_Name_2__c != null){
                        AccExt.Customer_Success_Engagement__c = 'High';
                    }
                }
            }
            
            update AccountExtensionUpdateList;
        }
        
        TriggerUtility.UpdateCSMAccountExtenssionMethodsettrue();
    }*/
    // CR:996 : end
    
  
    //Removed by Nathan : CR# 55: CTM Changes : Start
    //From Prod
    //Added by Gurjinder : CR# 154: CTM update : Start
    /*public static void UpdateContactHeadfields(list< Account > NewAccountList, map < Id, Account > accountOldMap,boolean IsInsert,boolean isUpdate){
        system.debug('inside UpdateContactHeadfields fields');
        Set<id> AccidSet= new Set<id>();
        Set<id> ContactidSet= new Set<id>();
      Map<id,Contact> ContactMap= new Map<id,Contact>();
        if(trigger.isupdate){
            for(Account acc: NewAccountList){
                if(acc.HeadOfIT__c!=accountOldMap.get(acc.id).HeadOfIT__c){
                    AccidSet.add(acc.id);
                    if(acc.HeadOfIT__c!=null){
                        Contact con= new Contact(id=acc.HeadOfIT__c,Head_of_IT__c=true);
                        ContactMap.put(con.id,con);
                    }
                    if(accountOldMap.get(acc.id).HeadOfIT__c!=null){
                        Contact con= new Contact(id=accountOldMap.get(acc.id).HeadOfIT__c,Head_of_IT__c=false);
                        ContactMap.put(con.id,con);
                    }
                    system.debug('ContactMap '+ContactMap);
                }
                if(acc.HeadOfSecurity__c!=accountOldMap.get(acc.id).HeadOfSecurity__c){
                    AccidSet.add(acc.id);
                    if(acc.HeadOfSecurity__c!=null){
                        if(ContactMap!=null && ContactMap.containskey(acc.HeadOfSecurity__c)){
                            ContactMap.get(acc.HeadOfSecurity__c).Head_of_Security__c=true;
                        }else{
                            Contact con= new Contact(id=acc.HeadOfSecurity__c,Head_of_Security__c=true);
                            ContactMap.put(con.id,con);
                        }
                        
                    }
                    if(accountOldMap.get(acc.id).HeadOfSecurity__c!=null){
                        if(ContactMap!=null && ContactMap.containskey(accountOldMap.get(acc.id).HeadOfSecurity__c)){
                            ContactMap.get(acc.HeadOfSecurity__c).Head_of_Security__c=false;
                        }else{
                            Contact con= new Contact(id=accountOldMap.get(acc.id).HeadOfSecurity__c,Head_of_Security__c=false);
                            ContactMap.put(con.id,con);
                        }
                    }
                    system.debug('ContactMap '+ContactMap);
                }
                if(acc.HeadOfNetworking__c!=accountOldMap.get(acc.id).HeadOfNetworking__c){
                    AccidSet.add(acc.id);
                    if(acc.HeadOfNetworking__c!=null){
                        if(ContactMap!=null && ContactMap.containskey(acc.HeadOfNetworking__c)){
                            ContactMap.get(acc.HeadOfNetworking__c).Head_of_Networking__c=true;
                        }else{
                            Contact con= new Contact(id=acc.HeadOfNetworking__c,Head_of_Networking__c=true);
                            ContactMap.put(con.id,con);
                        }
                        
                    }
                    if(accountOldMap.get(acc.id).HeadOfNetworking__c!=null){
                        if(ContactMap!=null && ContactMap.containskey(accountOldMap.get(acc.id).HeadOfNetworking__c)){
                            ContactMap.get(accountOldMap.get(acc.id).HeadOfNetworking__c).Head_of_Networking__c=false;
                        }else{
                            Contact con= new Contact(id=accountOldMap.get(acc.id).HeadOfNetworking__c,Head_of_Networking__c=false);
                            ContactMap.put(con.id,con);
                        }
                    }
                }
            }
        }
        system.debug('ContactMap.values '+ContactMap.values());
        if(ContactMap!=null){
            try{
                Database.update(ContactMap.values(), true);
            }
            catch(Exception ex) {
                Zscaler_Error_Logs__c EL1= new Zscaler_Error_Logs__c();
                EL1.Class_Name__c='AccountTriggerHelper';
                EL1.Method_Name__c='UpdateContactHeadfields';
                EL1.User__c=userinfo.getuserid();
                EL1.Exception_info__c=ex.getMessage();
                EL1.Operation__c='Update-Contacts head fields';
                EL1.Multiple_records_info__c=String.valueof(AccidSet);
                insert EL1;
            }
        }
        TriggerUtility.UpdateContactHeadfieldsExecuted();
    }*/
    //Added by Gurjinder : CR# 154: CTM update : End
    //Removed by Nathan : CR# 55: CTM Changes : End
        
    //Added by Pankaj  : CR# 61 : Architecture Next Steps : Start
        //Architecture Next Steps
    public static void updateArchitectureNextStepsHistory(map<id, Account> AccOldMap, list<Account> AccNewList)
    {
        Map<Id, String> archNextStepsHistoryMap = new Map<Id, String>();
        for (Account Acc : AccNewList)
        {
          if (Acc.Arch_workshop_next_steps__c  != null && !(String.isBlank(Acc.Arch_workshop_next_steps__c)) && !(String.isBlank(AccOldMap.get(Acc.Id).Arch_workshop_next_steps__c))
                && Acc.Arch_workshop_next_steps__c  != AccOldMap.get(Acc.Id).Arch_workshop_next_steps__c )
            {
                String newHistory = ((AccOldMap.get(Acc.Id).Arch_workshop_next_steps__c  != null) ? AccOldMap.get(Acc.Id).Arch_workshop_next_steps__c  : '');
                archNextStepsHistoryMap.put(Acc.Id,newHistory);
            }
        }

        if (!System.isFuture() && !System.isBatch() && archNextStepsHistoryMap.size() > 0) {
            updateAccountTechNextStepsInDb(JSON.serialize(archNextStepsHistoryMap),'Architecture Next Steps');
        }
    }

   
    public static void updateAccountTechNextStepsInDb(String mapOpptyNextStepHistoryJSON,String objectName) {

        
        //Architecture_Next_Steps__c
         if(objectName != null && objectName == 'Architecture Next Steps')
        {
            System.debug('Creating Architecture Next Step History record');
            Map<Id,String> mapAccNextStepHistory = (Map<Id,String>)JSON.deserialize(mapOpptyNextStepHistoryJSON, Type.forName('Map<Id,String>'));
            List<Architecture_Next_Steps__c> lsttechValidationInsert= new List<Architecture_Next_Steps__c>();
            for(Id AccId: mapAccNextStepHistory.keySet())
            {
                lsttechValidationInsert.add(new Architecture_Next_Steps__c(Account__c = AccId, Arch_workshop_next_steps__c = mapAccNextStepHistory.get(AccId)));
            }
            //Database.insert(lsttechValidationInsert,false);
            insert lsttechValidationInsert;
        }
    }

    //Account Extension History CR# 473 - Parth Doshi : START
    public static void createAccountExtensionHistory(Map<Id, Account> AccOldMap, List<Account> AccNewList, Boolean insertEvent){
        List<Schema.FieldSetMember> fieldSetMemberList =  FieldSetQuery.readFieldSet('Field_Track_History','Account');
        List<String> fieldsToTrack = new List<String>();
        Map<String,String> fieldsAPIVsLabel = new Map<String,String>();
        List<Account_Extension_History__c> fieldTrackToInsert = new List<Account_Extension_History__c>();
        try{
            if(!fieldSetMemberList.isEmpty()){
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
                    fieldsToTrack.add(fieldSetMemberObj.getFieldPath()); 
                    fieldsAPIVsLabel.put(fieldSetMemberObj.getFieldPath(),fieldSetMemberObj.getLabel());
                }
                if(insertEvent){
                    for(Account acc : AccNewList){
                        for(String eachFieldToTrack : fieldsToTrack){
                            if(acc.get(eachFieldToTrack) != null && acc.get(eachFieldToTrack) != ''){
                                Account_Extension_History__c newTrack = new Account_Extension_History__c();
                                newTrack.Account__c = acc.Id;
                                newTrack.Modified_By__c = UserInfo.getUserId();
                                newTrack.New_Value__c = String.valueOf(acc.get(eachFieldToTrack));
                                newTrack.Field_Name__c = fieldsAPIVsLabel.get(eachFieldToTrack);
                                newTrack.Date__c = System.Now();
                                fieldTrackToInsert.add(newTrack);
                            }
                        }
                    }
                }else{
                    for(Account acc : AccNewList){
                        for(String eachFieldToTrack : fieldsToTrack){
                            if(Trigger.oldMap.get(acc.Id).get(eachFieldToTrack) != acc.get(eachFieldToTrack)){
                                Account_Extension_History__c newTrack = new Account_Extension_History__c();
                                newTrack.Account__c = acc.Id;
                                newTrack.Modified_By__c = UserInfo.getUserId();
                                newTrack.New_Value__c = String.valueOf(acc.get(eachFieldToTrack));
                                newTrack.Previous_Value__c = String.valueOf(Trigger.oldMap.get(acc.Id).get(eachFieldToTrack));
                                newTrack.Field_Name__c = fieldsAPIVsLabel.get(eachFieldToTrack);
                                newTrack.Date__c = System.Now();
                                fieldTrackToInsert.add(newTrack);
                            }
                        }
                    }
                }
                if(!System.isFuture() && !System.isBatch() && !fieldTrackToInsert.isEmpty()){
                    Database.Insert(fieldTrackToInsert);
                }
            }
            TriggerUtility.updateAccountExtensionHistoryExecuted();
        }catch(Exception e){
            system.debug('### Exceptin occured in Extension History Insertion operation.'+e);
        }
    }
    //Account Extension History CR# 473 - Parth Doshi : END
    
    //Added by Gurjinder: Updating Market Segment :Start
    public static void UpdateMarketSegment(list< Account > NewAccountList,Map<id,Account> Oldmap, boolean isinsert, boolean isupdate)
    {   
        system.debug('inside UpdateMarketSegment '+isinsert);
        system.debug('inside UpdateMarketSegment '+isupdate);
        if(NewAccountList.size()>0){
            for(Account acc:NewAccountList){    
                
                boolean needtoexecute2=false;
                boolean needtoexecute3=false;
                if(IsInsert){
                    if(acc.NumberOfEmployees != null){
                        needtoexecute2=true;
                    }
                    if(acc.NumberOfEmployees == null && acc.No_of_Employees_Users__c != null){
                        needtoexecute3=true;
                    }
                }
                if(isupdate){
                    Account oldAccount;
                    oldAccount = oldMap.get(acc.Id);
                    
                    if(!acc.Override_Market_Segment__c && (acc.TriggerPatchAssignment__c || (acc.NumberOfEmployees!= null && acc.NumberOfEmployees != oldAccount.NumberOfEmployees) || (acc.No_of_Employees_Users__c != oldAccount.No_of_Employees_Users__c && acc.NumberOfEmployees!=null))){
                        needtoexecute2=true;
                    }
                    if(!acc.Override_Market_Segment__c && (acc.TriggerPatchAssignment__c || (acc.No_of_Employees_Users__c != oldAccount.No_of_Employees_Users__c && acc.NumberOfEmployees==null))){
                        needtoexecute3=true;
                    }
                }
            system.debug('inside first if condition'+acc.Override_Market_Segment__c);
            system.debug('needtoexecute2  '+needtoexecute2);
            system.debug('needtoexecute3  '+needtoexecute3);
            if((IsInsert && !acc.Override_Market_Segment__c) || needtoexecute2 || needtoexecute3){
                system.debug('inside if condition');
                if(acc.NumberOfEmployees == null && acc.No_of_Employees_Users__c == null ){
                    system.debug('inside first if condition');
                    acc.Market_Segment__c='SMB';
                    acc.No_of_Employees_Users__c='0 - 99';
                }
                else if (needtoexecute2 /* || (acc.NumberOfEmployees != null && acc.No_of_Employees_Users__c != null ) */){
                    system.debug('inside second if condition');
                    for(Market_Segmentation_Setting__c setting : Market_Segmentation_Setting__c.getall().values() ) {
                        if(acc.NumberOfEmployees >= setting.Start_Range__c && acc.NumberOfEmployees <=setting.End_Range__c) {
                        system.debug('setting  '+setting);          //setting.Is_EMEA_Region__c ==  isEMEARegion  // for future use
                            acc.Market_Segment__c = setting.Market_Segmentation__c;

                            if(acc.NumberOfEmployees>=40000){
                                acc.No_of_Employees_Users__c='40000+';
                            }else if(acc.NumberOfEmployees>=20000){
                                acc.No_of_Employees_Users__c='20000 - 39999';
                            }else if(acc.NumberOfEmployees>=5500){
                                acc.No_of_Employees_Users__c='5500 - 19999';
                            }else if(acc.NumberOfEmployees>=1250){
                                acc.No_of_Employees_Users__c='1250 - 5499';
                            }else if(acc.NumberOfEmployees>=1000){
                                acc.No_of_Employees_Users__c='1000 - 1249';
                            }else if(acc.NumberOfEmployees>=500){
                                acc.No_of_Employees_Users__c='500 - 999';
                            }else if(acc.NumberOfEmployees>=250){
                                acc.No_of_Employees_Users__c='250 - 499';
                            }else if(acc.NumberOfEmployees>=100){
                                acc.No_of_Employees_Users__c='100 - 249';
                            }else if(acc.NumberOfEmployees>=0){
                                acc.No_of_Employees_Users__c='0 - 99';
                            }                           
                            break;
                        }
                    }
                }
                else if (needtoexecute3){
                    system.debug('inside third if condition');                  
                    Integer startRange = 0, endRange = 0;
                    if(acc.No_of_Employees_Users__c.contains(' - ')){
                        startRange =Integer.valueOf( acc.No_of_Employees_Users__c.split(' - ')[0].trim() );
                        endRange = Integer.valueOf( acc.No_of_Employees_Users__c.split(' - ')[1].trim() );
                    }else if(acc.No_of_Employees_Users__c.contains('+')){
                        startRange =Integer.valueOf( acc.No_of_Employees_Users__c.substringBefore('+').trim() );
                    }
                    system.debug('startRange  '+startRange);
                    system.debug('endRange  '+endRange);
                    for(Market_Segmentation_Setting__c setting : Market_Segmentation_Setting__c.getall().values() ) {
                        if(acc.No_of_Employees_Users__c.contains(' - ') && setting.Start_Range__c <= startRange && setting.End_Range__c >= endRange) { //setting.Is_EMEA_Region__c ==  isEMEARegion  // for future use
                            system.debug('setting  '+setting);  
                            acc.Market_Segment__c  = setting.Market_Segmentation__c;
                            system.debug('acc.Market_Segment__c  '+acc.Market_Segment__c);
                            break;
                        } else if(acc.No_of_Employees_Users__c.contains('+') && setting.Start_Range__c == startRange ) {
                            system.debug('setting  '+setting);
                            acc.Market_Segment__c  = setting.Market_Segmentation__c;
                            system.debug('acc.Market_Segment__c  '+acc.Market_Segment__c);
                            break;
                        }
                    
                    }
                
                }
            }
        
            }
            
        }
        TriggerUtility.UpdatingMarketsegmentforEMEAsettrue();
        //Commented the EMEA logic as this is not required as of now but kept as it may be used in future
                /* ZscalerSetting__c setting = ZscalerSetting__c.getInstance('EMEACountriesPatchRuleName');
                List<String> lstPatchCriteriaRuleNames = new List<String>();
                if (setting != null && setting.Value__c != null) {
                    lstPatchCriteriaRuleNames.addAll(setting.Value__c.split(','));
                }
                System.debug('*** lstPatchCriteriaRuleNames: ' + lstPatchCriteriaRuleNames);
                Set<String> setEMEACountries = new Set<String>();
                for (PatchMatchList__c countryName : [SELECT Name FROM PatchMatchList__c WHERE PatchCriteriaRule__r.Name = :lstPatchCriteriaRuleNames]) {
                    setEMEACountries.add(countryName.Name.toLowerCase());
                }
                boolean isEMEAregion=false;
                system.debug('setEMEACountries '+setEMEACountries); */
                
    }
    //Added by Gurjinder: Updating Market Segment :End
    
    //Added by Gurjinder: CR# 758 :Start
    public static void CreateCustomerScoreCardrecord(List<Account> acclst){
        List<Customer_Score_Card__c> CSClist = new List<Customer_Score_Card__c>();
        List<Account> accToUpdate = new List<Account>();
        Map<Id,Id> accntVsCSMap = new Map<Id,Id>();
        for(Account acc: acclst){
            Customer_Score_Card__c csc= new Customer_Score_Card__c(Account__c=acc.id);
            CSClist.add(csc);
        }
        if(!CSClist.isempty() && CSClist.size()>0){  
            insert CSClist;
        }
        
        //Added for CR# 3190 - Start
        for(Customer_Score_Card__c cs:CSClist)
        {
            accntVsCSMap.put(cs.Account__c,cs.Id);
        } 
        
        for(Account acc:acclst)
        {
            Account account  = new Account(Id = acc.Id);
            account.Customer_ScoreCard__c=accntVsCSMap.get(acc.Id);
            accToUpdate.add(account);
        }        
        // IBA-2245 START
        TriggerHandler.bypass('AccountTriggerHandler');
        update accToUpdate;
        TriggerHandler.clearBypass('AccountTriggerHandler');
        // IBA-2245 END

        //Added for CR# 3190 - End
        
        TriggerUtility.CreateCustomerScoreCardExecuted();
    }
  // Dummy Counter method removed by Abhijit for CR840  
  
    public static void updatePartnerDiscounts(List<Account> NewAccountList, Map<Id, Account> accountOldMap){
        List<Partner_Program_and_Prt_Tier_Discount__mdt> discountMetaData =[SELECT Label,Architectural_Workshop_Discount__c, Deal_Reg_Discount_Sourced__c,
                                                                            Deal_Reg_Discount_Teaming__c,Fulfilment_Discount__c, New_Logo_Discount__c, POV_Discount__c, Renewal_Deal_Reg_Discount__c 
                                                                            FROM Partner_Program_and_Prt_Tier_Discount__mdt];
                                                                            
        Map<String, Partner_Program_and_Prt_Tier_Discount__mdt> discountMetaDataMap = new Map<String, Partner_Program_and_Prt_Tier_Discount__mdt>();
        if(discountMetaData != null && !discountMetaData.IsEmpty()){
            for(Partner_Program_and_Prt_Tier_Discount__mdt mdt : discountMetaData){
                discountMetaDataMap.put(mdt.Label,mdt);
            }
        }
        
        List<String> partnerTypes = Label.Partner_Account_Types.split(',');
        
        for(Account acc: NewAccountList){
            if(partnerTypes.contains(acc.Type)){
                boolean evaluateDiscounts = false;
                if(accountOldMap == null && acc.Model_Type_Partner__c != null && acc.Partner_Tier__c != null){
                    evaluateDiscounts = true;
                }else if(acc.Model_Type_Partner__c != null && acc.Partner_Tier__c != null){
                    if(acc.Model_Type_Partner__c != accountOldMap.get(acc.Id).Model_Type_Partner__c || acc.Partner_Tier__c != accountOldMap.get(acc.Id).Partner_Tier__c){
                        evaluateDiscounts = true;
                    }
                }
            
                if(evaluateDiscounts){
                    string key='';
                    Boolean keySet = false;
                    if(Orange_Partner_Exception_Accounts__c.getValues(acc.Id)!=null && Orange_Partner_Exception_Accounts__c.getValues(acc.Id).France__c)
                    {
                        key = acc.Model_Type_Partner__c + '#' + Label.Orange_WPS_France;
                        keySet = true;
                    }
                    
                    if(Orange_Partner_Exception_Accounts__c.getValues(acc.Id)!=null && Orange_Partner_Exception_Accounts__c.getValues(acc.Id).RoW_Ex_France__c )
                    {
                        key = acc.Model_Type_Partner__c + '#' + Label.Orange_RoW_Ex_France;
                        keySet=true;
                    }
                    if(!keySet)
                        key = acc.Model_Type_Partner__c + '#' + acc.Partner_Tier__c;
                    
                    system.debug('key '+key);
                    if(discountMetaDataMap.containsKey(key)){
                        Partner_Program_and_Prt_Tier_Discount__mdt discountDetails = discountMetaDataMap.get(key);
                        system.debug('discountDetails '+discountDetails);
                        acc.AW_Margin__c = discountDetails.Architectural_Workshop_Discount__c;
                        acc.Partner_Summit_Deg_Reg_Margin__c= discountDetails.Deal_Reg_Discount_Sourced__c;
                        acc.Deal_Reg_Margin_Teaming__c = discountDetails.Deal_Reg_Discount_Teaming__c;
                        acc.Fulfilment_Margin__c = discountDetails.Fulfilment_Discount__c; 
                        acc.New_Logo_Discount__c = discountDetails.New_Logo_Discount__c; 
                        acc.POV_Margin__c = discountDetails.POV_Discount__c;
                        acc.Deal_Reg_Discount__c = discountDetails.Renewal_Deal_Reg_Discount__c;
                    }
                }
            }
        }
    }
    
    //Added for CR 1807 by Varun - Start
    public static void updateAccountExtensionCheckBox(Map<id,Account> newMapAcclist,Map<id,Account>  oldMapAccList){
        List<Account_Extension__c> lstAccntExtension= new List<Account_Extension__c> ();
        List<Id> lstAccountIds = new List<Id>();
        List<Id> lstEstimatedCheckboxChangesList = new List<Id>();
        List<Id> lstEnrolledUserCheckboxList = new List<Id>();
       for(Account acc: newMapAcclist.values()){
           if(newMapAcclist.get(acc.Id).Avg_Estimated_Users_L31D_Vs_Purchase__c!=oldMapAccList.get(acc.Id).Avg_Estimated_Users_L31D_Vs_Purchase__c 
              && acc.Avg_Estimated_Users_L31D_Vs_Purchase__c > 25 ){
               lstAccountIds.add(acc.id);
                  lstEstimatedCheckboxChangesList.add(acc.id);
           }
           if(newMapAcclist.get(acc.Id).ZPA_Enrolled_users_L31D_Vs_Purchase__c!=oldMapAccList.get(acc.Id).ZPA_Enrolled_users_L31D_Vs_Purchase__c  
              &&   acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c > 25){
               lstAccountIds.add(acc.id);
                    lstEnrolledUserCheckboxList.add(acc.id);
           }
            //Avg_Estimated_Users_L31D_Vs_Purchase__c 
            //ZPA_Enrolled_users_L31D_Vs_Purchase__c  
        }
       lstAccntExtension= [Select id,Latest_ZIA_Contract_25_Attained__c,Latest_ZPA_Contract_25_Attained__c,Account__r.Avg_Estimated_Users_L31D_Vs_Purchase__c,Account__r.ZPA_Enrolled_users_L31D_Vs_Purchase__c from Account_Extension__c where Account__c in:lstAccountIds ];
        for(Account_Extension__c accExtension: lstAccntExtension){
            if(lstEstimatedCheckboxChangesList.contains(accExtension.Account__c) && accExtension.Latest_ZIA_Contract_25_Attained__c==false){
                accExtension.Latest_ZIA_Contract_25_Attained__c =true;
            }
            if(lstEnrolledUserCheckboxList.contains(accExtension.Account__c)  && accExtension.Latest_ZPA_Contract_25_Attained__c==false){
                accExtension.Latest_ZPA_Contract_25_Attained__c =true;
            }
        }
        
        Database.update(lstAccntExtension,false);
        TriggerUtility.UpdateAccountExtensionCheckBoxExecuted();
    }
    //Added for CR 1807 by Varun - End

    //Cr # 3178 - Start
    public static void updateCSBusinessAlignment(List<Account> newMapAcclist, Map<Id, Account> oldMapAccList){
        
        Map <Id,Id> accIdCSBusinessAllignmentIdMap = new Map<Id,Id>();
        List<AccountTeamMember> atmList = [Select  id,AccountId, UserId, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel from AccountTeamMember
                                                      WHERE AccountId IN: newMapAcclist and TeamMemberRole ='Customer Success Manager'];
        
        List<AccountTeamMember> acountMembertoUpdateList= new List<AccountTeamMember>();
        List<AccountTeamMember> acountMembertoDeleteList = new List<AccountTeamMember>();
        
        for (Account acc: newMapAcclist) {          
            accIdCSBusinessAllignmentIdMap.put(acc.id, acc.CS_Business_Alignment__c);
            
        }
        
        Map<Id, Id> userAccountTeamMap = new Map<Id, Id> ();
        Map<Id, Set<Id>> accTeamMemberMap = new Map<Id, Set<Id>> ();
        for (AccountTeamMember atm : atmList) {
            
            Set<Id> teamMemberIdSet = accTeamMemberMap.containsKey(atm.AccountId) ? accTeamMemberMap.get(atm.AccountId) : new Set<Id> ();
            teamMemberIdSet.add(atm.UserId);
            accTeamMemberMap.put(atm.AccountId, teamMemberIdSet);
            
            userAccountTeamMap.put(atm.UserId, atm.Id);
            
        }
        
        for (Account acc: newMapAcclist) {          
            if(accTeamMemberMap.containsKey(acc.Id) && acc.CS_Business_Alignment__c != null && !accTeamMemberMap.get(acc.Id).contains(acc.CS_Business_Alignment__c) &&
              !accTeamMemberMap.get(acc.Id).contains(oldMapAccList.get(acc.Id).CS_Business_Alignment__c)) {
                 acountMembertoUpdateList.add(new AccountTeamMember(userId = accIdCSBusinessAllignmentIdMap.get(acc.Id), 
                                                                           TeamMemberRole = 'Customer Success Manager',
                                                                           AccountAccessLevel='edit',
                                                                           OpportunityAccessLevel='edit',
                                                                           CaseAccessLevel='edit',
                                                                           ContactAccessLevel='edit',
                                                                           AccountId = acc.id
                                                                          ));
            
            }
            
            if(atmList.isEmpty()){
                acountMembertoUpdateList.add(new AccountTeamMember(userId = accIdCSBusinessAllignmentIdMap.get(acc.Id), 
                                                                           TeamMemberRole = 'Customer Success Manager',
                                                                           AccountAccessLevel='edit',
                                                                           OpportunityAccessLevel='edit',
                                                                           CaseAccessLevel='edit',
                                                                           ContactAccessLevel='edit',
                                                                           AccountId = acc.id
                                                                          ));
            
            }
            
            if(accTeamMemberMap != null && accTeamMemberMap.get(acc.Id) != null && accTeamMemberMap.get(acc.Id).contains(oldMapAccList.get(acc.Id).CS_Business_Alignment__c) && acc.CS_Business_Alignment__c == null ){
                acountMembertoDeleteList.add(new AccountTeamMember(Id = userAccountTeamMap.get(oldMapAccList.get(acc.Id).CS_Business_Alignment__c )));
            }
        
        }
        
        if (!acountMembertoUpdateList.isEmpty()){
             Database.insert(acountMembertoUpdateList, false);
        }
        if (!acountMembertoDeleteList.isEmpty()){
            delete acountMembertoDeleteList;
        }
    
    }
    //Cr # 3178 - End
    //Added for CR 2258 by Chetan-Start
    public static void updateSkipTAMReassignmentOnChildCases(map<id, Account> AccOldMap, list<Account> AccNewList){
        System.debug('Update child Cases');
        set<Id> accIds=new set<Id>();
        list<Case> casesToUpdate=new list<Case>();
        for(Account acc:AccNewList)
        {
            if((AccOldMap!= null && (AccOldMap.get(acc.Id).Skip_TAM_Reassignments__c != acc.Skip_TAM_Reassignments__c) && acc.Skip_TAM_Reassignments__c && acc.Is_Federal_Account_Sync__c==false) || Test.isRunningTest())
            {
                accIds.add(acc.id);                
            }
        }
        System.debug(accIds);
        if(!accIds.isEmpty())
        {
            for(Case cs:[select id,TAM_Reassignment__c,Is_TAM_Account__c,Status from Case where Status!='Closed' and TAM_Reassignment__c=false and Is_TAM_Account__c=true and RecordType.Name='Support' and AccountId in :accIds])
            {
                cs.TAM_Reassignment__c=true;
                casesToUpdate.add(cs);
            }   
        }
        System.debug(casesToUpdate);
        if(!casesToUpdate.isEmpty())
        {
            update casesToUpdate;
        }
        TriggerUtility.updateSkipTAMReassignmentOnChildCasesTrue();
    }
    //Added for CR 2258 by Chetan-End
    
     //Added Ayush Kangar as part of IBA-2489 - Start
    public static void createOverageOpportunity(map<id, Account> AccOldMap, list<Account> AccNewList){
        Boolean isOverageOppOlderThen1Day = true;
        Set<Account> accSet=new Set<Account>();
        //Added by Ayush as part of IBA-5253 - START
        List<String> stageLabelList = new List<String>();
        stageLabelList.add(label.Stage_6_Closed_Won);
        stageLabelList.add(label.Stage_7_Closed_Lost); 
        //Added by Ayush as part of IBA-5253 - END
        for(Account acc:AccNewList)
        {
            if((AccOldMap!= null && (AccOldMap.get(acc.Id).Account_Overage__c != acc.Account_Overage__c) && acc.Account_Overage__c == 'Create Opportunity'))
            {
                accSet.add(acc);                
            }
        }
        map<id, Opportunity> AccIdOppMap =  new map<id, Opportunity>();
        List<opportunity> lastOppList = [SELECT Id,Flexible_Identifier__c,AccountId,CreatedDate,Customer_Success_Notes__c,Proposed_Number_of_Users__c,StageName
                                         FROM Opportunity WHERE AccountId IN: accSet
                                         AND Flexible_Identifier__c includes('Customer Over-Usage')
                                         AND StageName NOT IN: stageLabelList
                                         ORDER BY CreatedDate desc LIMIT 1];			//Updated by Ayush as part of IBA-5253
        for(opportunity lastOpp : lastOppList){
            AccIdOppMap.put(lastOpp.AccountId,lastOpp);
        }     
        List<opportunity> oppList = new List<Opportunity>();
        List<Account> accList = new List<Account>();
        Id OppRecordTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Upsell Opportunity').getRecordTypeId();
        //Added by Ayush Kangar as part of IBA-6326 - Start
        if(!lastOppList.isEmpty()){
            // -24 is used to check if any Overage Opp is created in last 24 hours.
            isOverageOppOlderThen1Day = System.now().addHours(-24)>lastOppList[0].CreatedDate;
        }
        if(!accSet.isEmpty() && isOverageOppOlderThen1Day)			//Added by Ayush Kangar as part of IBA-6326 - End
        {
            for(account acc: accSet){  
                DateTime dt = system.now();
                Integer year = dt.Year(); //get year
                String month = dt.format('MMMM');
                String newOppName = 'True Forward' + ' - ' + month + ' ' + year + ' - ' + acc.Name ;
                Opportunity opp = new Opportunity();
                opp.Flexible_Identifier__c = 'Customer Over-Usage';
                opp.StageName = '1 - Discovery & Qualification';
                opp.RecordTypeId = OppRecordTypeid;
                opp.OwnerId  = acc.OwnerId;
                Opp.Name = newOppName;
                Opportunity oppOld = new Opportunity();
                if(AccIdOppMap != null){
                    oppOld  = AccIdOppMap.get(acc.Id);
                }
                if(AccIdOppMap.get(acc.Id) ==null){
                    opp.Proposed_Number_of_Users__c = acc.Proposed_Number_of_Users__c;
                    opp.Customer_Success_Notes__c = acc.True_Forward_opportunity_Notes__c;
                }
                else if(AccIdOppMap.get(acc.Id) !=null ){
                    if(oppOld != null && (oppOld.Proposed_Number_of_Users__c != acc.Proposed_Number_of_Users__c) && ( acc.Proposed_Number_of_Users__c != null &&  acc.Proposed_Number_of_Users__c != 0)){
                        opp.Proposed_Number_of_Users__c = acc.Proposed_Number_of_Users__c;
                    }else {
                        if(acc.Proposed_Number_of_Users__c == 0){
                            opp.Proposed_Number_of_Users__c = 0;
                        }else{
                            opp.Proposed_Number_of_Users__c = null;
                        }
                    }
                    if(oppOld != null && (oppOld.Customer_Success_Notes__c != acc.True_Forward_opportunity_Notes__c) && ( acc.True_Forward_opportunity_Notes__c != null)){
                        opp.Customer_Success_Notes__c = acc.True_Forward_opportunity_Notes__c;
                    }else {
                        opp.Customer_Success_Notes__c = null;
                    }
                }    
                opp.AccountId = acc.Id;
                opp.CloseDate = System.today()+90;
                oppList.add(opp);
                Account accNew = new Account(Id = acc.id);
                accNew.Account_Overage__c = 'Opportunity In Progress';
                accList.add(accNew);
            }
        }
        if(!oppList.isEmpty())
        {
            insert oppList;
        }
        if(!accList.isEmpty())
        {
            TriggerHandler.bypass('AccountTriggerHandler');
            update accList;
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }
    public static void updateOverageOpportunities(map<id, Account> AccOldMap, map<id, Account> AccNewMap){
        Set<Account> accSet=new Set<Account>();
        //Added by Ayush as part of IBA-5253 - START
        List<String> stageLabelList = new List<String>();
        stageLabelList.add(label.Stage_6_Closed_Won);
        stageLabelList.add(label.Stage_7_Closed_Lost);
        //Added by Ayush as part of IBA-5253 - END
        for(Account acc:AccNewMap.values())
        {
            if((AccOldMap!= null && (AccOldMap.get(acc.Id).Proposed_Number_of_Users__c != acc.Proposed_Number_of_Users__c) || (AccOldMap.get(acc.Id).True_Forward_opportunity_Notes__c != acc.True_Forward_opportunity_Notes__c) ))
            {
                accSet.add(acc);                
            }
        }
        List<opportunity> OverageOppList = [SELECT Id,Flexible_Identifier__c,AccountId,CreatedDate, Customer_Success_Notes__c,Proposed_Number_of_Users__c,StageName
                                            FROM Opportunity WHERE AccountId IN: accSet 
                                            AND Flexible_Identifier__c includes('Customer Over-Usage')
                                            AND StageName NOT IN: stageLabelList
                                            ORDER BY CreatedDate desc LIMIT 1];		//Updated by Ayush as part of IBA-5253
        List<opportunity> oppToUpdateList = new List<Opportunity>();
        map<id, Opportunity> AccIdOppMap =  new map<id, Opportunity>();
        for(opportunity overageOpp : OverageOppList){
            AccIdOppMap.put(overageOpp.AccountId,overageOpp);
        }  
        for(Account acc : accSet){
            if(AccIdOppMap.get(acc.id) != null){
                Opportunity lastOpp = AccIdOppMap.get(acc.id);          
                if((lastOpp.Proposed_Number_of_Users__c != AccNewMap.get(acc.id).Proposed_Number_of_Users__c) && (lastOpp.Proposed_Number_of_Users__c ==0 || lastOpp.Proposed_Number_of_Users__c==null)){
                    lastOpp.Proposed_Number_of_Users__c = AccNewMap.get(lastOpp.AccountId).Proposed_Number_of_Users__c;                          
                }
                if((lastOpp.Customer_Success_Notes__c != AccNewMap.get(acc.id).True_Forward_opportunity_Notes__c) && (lastOpp.Customer_Success_Notes__c ==null)){
                    lastOpp.Customer_Success_Notes__c = AccNewMap.get(lastOpp.AccountId).True_Forward_opportunity_Notes__c;
                }
                oppToUpdateList.add(lastOpp);
            }
        }
        if(!oppToUpdateList.isEmpty())
        {	
            TriggerHandler.bypass('OpportunityTriggerHandler');
            update oppToUpdateList;
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
        }
    }
    
    public static void createAccountExtensionHistory(map<id, Account> AccOldMap, map<id, Account> AccNewMap){
        List<Account_Extension_History__c> TrackingList = new List<Account_Extension_History__c>();
        set<Account> accSetforNumberOfUsers=new set<Account>();
        set<Account> accSetforTrueForwardNotes=new set<Account>();
        for(Account acc:AccNewMap.values())
        {
            if(AccOldMap.get(acc.Id).Proposed_Number_of_Users__c != acc.Proposed_Number_of_Users__c)
            {
                accSetforNumberOfUsers.add(acc);                
            }
            if(AccOldMap.get(acc.Id).True_Forward_opportunity_Notes__c != acc.True_Forward_opportunity_Notes__c)
            {
                accSetforTrueForwardNotes.add(acc);                
            }
        }
        for(Account acc : accSetforNumberOfUsers){
        Account_Extension_History__c newTrack = new Account_Extension_History__c();
                                newTrack.Account__c = acc.Id;
                                newTrack.Modified_By__c = UserInfo.getUserId();
            					if(AccNewMap.get(acc.id).Proposed_Number_of_Users__c!=null){
                                	newTrack.New_Value__c = String.valueOf(AccNewMap.get(acc.id).Proposed_Number_of_Users__c.format());
            					}
                   				if(AccOldMap.get(acc.id).Proposed_Number_of_Users__c!=null){
                                	newTrack.Previous_Value__c = String.valueOf(AccOldMap.get(acc.id).Proposed_Number_of_Users__c.format());
                                }
            				    newTrack.Field_Name__c = 'Number of users';
                                newTrack.Date__c = System.Now();
                                TrackingList.add(newTrack); 
        }
        for(Account acc : accSetforTrueForwardNotes){
        Account_Extension_History__c newTrack = new Account_Extension_History__c();
                                newTrack.Account__c = acc.Id;
                                newTrack.Modified_By__c = UserInfo.getUserId();
            					if(AccNewMap.get(acc.id).True_Forward_opportunity_Notes__c!=null){
                                	newTrack.New_Value__c = String.valueOf(AccNewMap.get(acc.id).True_Forward_opportunity_Notes__c);
            					}
                   				if(AccOldMap.get(acc.id).True_Forward_opportunity_Notes__c!=null){
                                	newTrack.Previous_Value__c = String.valueOf(AccOldMap.get(acc.id).True_Forward_opportunity_Notes__c);                         
                                }
                                newTrack.Field_Name__c = 'True Forward opportunity Notes';
                                newTrack.Date__c = System.Now();
                                TrackingList.add(newTrack); 
        }
        if(!TrackingList.isEmpty())
        {
            insert TrackingList;
        } 
    }
    //Added Ayush Kangar as part of IBA-2489 - End
    
    // IBA-3258 START	
    @InvocableMethod(label = 'Update Authenticated Consumption Fields On Account Extension' description = 'To Update the Authenticated Consumption Fields On Account Extension') 	
    public static void updateAuthenticatedConsumptionFieldsOnAccountExtensionInvocableMethod(List<List<Account>> listOfNewAccountList) {	
        if (listOfNewAccountList != null && !listOfNewAccountList.isEmpty()) {	
            updateAuthenticatedConsumptionFieldsOnAccountExtension(listOfNewAccountList[0]);	
        }	
    }	
    	
    public static void updateAuthenticatedConsumptionFieldsOnAccountExtension(List<Account> newAccountList) {	
        try {	
            if (newAccountList != null && !newAccountList.isEmpty()) {	
                List<Account_Extension__c> accountExtensionList = [SELECT Id, Account__c, X25_Authenticated_Traffic_Attained_Date__c, 	
                    X50_Authenticated_Traffic_Attained_Date__c, X75_Authenticated_Traffic_Attained_Date__c FROM Account_Extension__c WHERE Account__c IN :newAccountList];	
    	
                Map<Id, Account_Extension__c> accountIdToAccountExtensionMap = new Map<Id, Account_Extension__c>();	
                for (Account_Extension__c currentAccountExtension : accountExtensionList) {	
                    if (!accountIdToAccountExtensionMap.containsKey(currentAccountExtension.Account__c)) {	
                        accountIdToAccountExtensionMap.put(currentAccountExtension.Account__c, currentAccountExtension);	
                    }	
                }	
                List<Account_Extension__c> accountExtensionListToUpdate = new List<Account_Extension__c>();	
                for (Account newAccount : newAccountList) {	
                    Account_Extension__c associatedAccountExtension = accountIdToAccountExtensionMap.get(newAccount.Id);	
    	
                    if (associatedAccountExtension != null) {	
                        Boolean isAccountExtensionUpdated = false;	
    	
                        // Capture date when authenticated traffic consumption hits 25% START	
                        if(newAccount.Avg_Estimated_Users_L90D_Vs_Purchase__c >= 25 && associatedAccountExtension.X25_Authenticated_Traffic_Attained_Date__c == null) {	
                            associatedAccountExtension.X25_Authenticated_Traffic_Attained_Date__c = Date.valueOf(System.now());	
                            isAccountExtensionUpdated = true;	
                        }	
                        // Capture date when authenticated traffic consumption hits 50% START	
                        if(newAccount.Avg_Estimated_Users_L90D_Vs_Purchase__c >= 50 && associatedAccountExtension.X50_Authenticated_Traffic_Attained_Date__c == null) {	
                            associatedAccountExtension.X50_Authenticated_Traffic_Attained_Date__c = Date.valueOf(System.now());	
                            isAccountExtensionUpdated = true;	
                        }	
                        // Capture date when authenticated traffic consumption hits 75% START	
                        if(newAccount.Avg_Estimated_Users_L90D_Vs_Purchase__c >= 75 && associatedAccountExtension.X75_Authenticated_Traffic_Attained_Date__c == null) {	
                            associatedAccountExtension.X75_Authenticated_Traffic_Attained_Date__c = Date.valueOf(System.now());	
                            isAccountExtensionUpdated = true;	
                        }	
    	
                        if (isAccountExtensionUpdated) {	
                            accountExtensionListToUpdate.add(associatedAccountExtension);	
                        }	
                    }	
                }	
    	
                if (!accountExtensionListToUpdate.isEmpty()) {	
                    update accountExtensionListToUpdate;	
                }	
            }	
        } catch (Exception ex) {	
            ZscalerErrorLogsUtility.insertLogs('AccountTriggerHelper', 'updateAuthenticatedConsumptionFieldsOnAccountExtension', 'Apex', 	
                UserInfo.getUserId(), 'Sales Cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());	
        }	
    }	
    // IBA-3258 END	
    //Added as part of IBA-6326- START
    public static void overageOpportunityBeforeUpdate(map<Id, Account> AccOldMap, list<Account> AccNewList){
        Boolean isOverageOppIn1Day = false;
        Set<Account> accSet=new Set<Account>();
        List<String> stageLabelList = new List<String>();
        stageLabelList.add(label.Stage_6_Closed_Won);
        stageLabelList.add(label.Stage_7_Closed_Lost);
        for(Account acc:AccNewList){
            if((AccOldMap!= null && (AccOldMap.get(acc.Id).Account_Overage__c != acc.Account_Overage__c) && acc.Account_Overage__c == 'Create Opportunity' && AccOldMap.get(acc.Id).Account_Overage__c =='Opportunity In Progress'))
            {
                accSet.add(acc);                
            }
        }
        List<opportunity> lastOppList = [SELECT Id,Flexible_Identifier__c,AccountId,CreatedDate,Customer_Success_Notes__c,Proposed_Number_of_Users__c,StageName
                                         FROM Opportunity WHERE AccountId IN: accSet
                                         AND Flexible_Identifier__c includes('Customer Over-Usage')
                                         AND StageName NOT IN: stageLabelList
                                         ORDER BY CreatedDate desc LIMIT 1];  
        if(!lastOppList.isEmpty()){
            //-24 is used to check if an Overage Opp already created in last 24 hours
            isOverageOppIn1Day = System.now().addHours(-24)<lastOppList[0].CreatedDate;
        }
        if(!accSet.isEmpty() && isOverageOppIn1Day)
        {
            for(account acc: accSet){  
                if((AccOldMap!= null && (AccOldMap.get(acc.Id).Account_Overage__c != acc.Account_Overage__c) && acc.Account_Overage__c == 'Create Opportunity' && AccOldMap.get(acc.Id).Account_Overage__c == 'Opportunity In Progress'))
                {
                    acc.Account_Overage__c = 'Opportunity In Progress';               
                }
            }
        }
    }
    //Added as part of IBA-6326- END
    
}