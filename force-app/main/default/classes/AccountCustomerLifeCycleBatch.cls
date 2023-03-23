//Reverting the code changes of IBA-2067 from PROD
public class AccountCustomerLifeCycleBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('AccountCustomerLifeCycleBatch');
    
    public string query;
    
    public AccountCustomerLifeCycleBatch(String query){
        this.query = query;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    
    public void execute (Database.BatchableContext context, List<Account> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        Map<Id,Account_Extension__c> accExt = new Map<Id,Account_Extension__c>([SELECT ID, Account__c, Latest_ZIA_Contract_Date__c,
                                                                                        Latest_ZIA_Contract_25_Attained__c, Latest_ZPA_Contract_Date__c, 
                                                                                        Latest_ZPA_Contract_25_Attained__c, Customer_Lifecycle__c , Not_Slow_Deployment__c,
                                                                                        Exclude_ZIA_from_Lifecycle__c,Exclude_ZPA_from_Lifecycle__c
                                                                                        FROM Account_Extension__c 
                                                                                        WHERE Account__c IN:scope ]);
        Map<Id,Id> accVsAccExt = new Map<Id,Id>();
        for(Id acEx: accExt.keySet()){
            accVsAccExt.put(accExt.get(acEx).Account__c, acEx);
        }
        
        List<Customer_Score_Card__c> lstCSC = [SELECT Id, Account__c, Qualified_SSL_Inspected_Bytes__c 
                                                    FROM Customer_Score_Card__c
                                                    WHERE Account__c IN: scope];
        List<Opportunity> lstOpp = [SELECT Id, Type,StageName,AccountID,Contract_End_Date_New__c,(Select id, ProductCode From OpportunityLineItems) 
                                   FROM Opportunity WHERE AccountID IN: scope AND Type='Existing Customer (Renewal)'];
        
        Map<Id,Opportunity> accVsOpp = new Map<Id,Opportunity>();
        Map<Id,List<String>> accVsOppZIAMap = new Map<Id,List<String>>();
        Map<Id,List<String>> accVsOppZPAMap = new Map<Id,List<String>>();
        Set<String> setZIASKUCodes = new Set<String>();
        Set<String> setZPASKUCodes = new Set<String>();
        setZIASKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Opportunity_Product_ZIA_SKU').SKU_Codes__c.split(';'));
        setZIASKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Opportunity_Product_ZIA_SKU_1').SKU_Codes__c.split(';'));
        setZPASKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('Opportunity_Product_ZPA_SKU').SKU_Codes__c.split(';'));
        for(Opportunity opp : lstOpp){
            if(Opp.StageName!=Label.Stage_7_Closed_Lost && Opp.StageName!=Label.Stage_6_Closed_Won && Opp.Contract_End_Date_New__c < System.Today())
            	accVsOpp.put(Opp.AccountID,opp);
            if(Opp.StageName==Label.Stage_7_Closed_Lost){
                for(OpportunityLineItem OppLineItem : Opp.OpportunityLineItems){
                    if(setZIASKUCodes.contains(OppLineItem.ProductCode)){
                        if(!accVsOppZIAMap.containsKey(Opp.AccountID)){
                        	accVsOppZIAMap.put(Opp.AccountID, new List<String>());
                    	}
                        accVsOppZIAMap.get(Opp.AccountID).add(OppLineItem.ProductCode);
                    }
                    if(setZPASKUCodes.contains(OppLineItem.ProductCode)){
                        if(!accVsOppZPAMap.containsKey(Opp.AccountID)){
                        	accVsOppZPAMap.put(Opp.AccountID, new List<String>());
                    	}
                        accVsOppZPAMap.get(Opp.AccountID).add(OppLineItem.ProductCode);
                    }
                }
            }        
        }
        Map<Id,Customer_Score_Card__c> accVsCsc = new Map<Id,Customer_Score_Card__c>();
        for(Customer_Score_Card__c csc : lstCSC){
            accVsCsc.put(csc.Account__c,csc);
        }

        List<Account> accToUpdate = new List<Account>(); //Added by Swathi: CR 2707
        for(Account acc : scope){
            
            string customerLifeCycleValue = '';
            Customer_Score_Card__c csc = accVsCsc.get(acc.Id);
            Account_Extension__c ext = new Account_Extension__c();
            ext = accExt.get(accVsAccExt.get(acc.Id));
            Integer ZPAContractDate180Day = Null;
            Integer ZIAContractDate180Day = Null;
            Integer FirstZIAContractDate180Day = Null;//added by Swathi CR:1566
            Integer FirstZPAContractDate180Day = Null;//added by Swathi CR:1566
            Boolean NewCustomer = False;//added by Swathi CR:1566
            
            if(ext!=Null && ext.Latest_ZIA_Contract_Date__c != null){
                ZIAContractDate180Day = ext.Latest_ZIA_Contract_Date__c.daysBetween(System.Today());
            }
            if(ext!=Null && ext.Latest_ZPA_Contract_Date__c != null){
                ZPAContractDate180Day = ext.Latest_ZPA_Contract_Date__c.daysBetween(System.Today());
            }
            If(acc.First_Contract_Date__c != null){
                FirstZIAContractDate180Day = acc.First_Contract_Date__c.daysBetween(System.Today());
            }
            If(acc.First_ZPA_Contract_Date__c != null){
                FirstZPAContractDate180Day = acc.First_ZPA_Contract_Date__c.daysBetween(System.Today());
            }
            
            if(ext!=Null){
            	if(((!accVsOppZIAMap.containsKey(acc.id) || acc.No_of_Platform_Seats__c > 0) && acc.First_Contract_Date__c != null && acc.First_Contract_Date__c > System.today() && (acc.First_ZPA_Contract_Date__c == null || acc.Users_ZPA_Platform__c==0 || ext.Exclude_ZPA_from_Lifecycle__c) && !ext.Exclude_ZIA_from_Lifecycle__c) || 
                   ((!accVsOppZPAMap.containsKey(acc.id) || acc.Users_ZPA_Platform__c > 0) && (acc.First_Contract_Date__c==Null || acc.No_of_Platform_Seats__c==0 || ext.Exclude_ZIA_from_Lifecycle__c) && acc.First_ZPA_Contract_Date__c != null && acc.First_ZPA_Contract_Date__c > System.today() && !ext.Exclude_ZPA_from_Lifecycle__c) || 
                   ((!accVsOppZPAMap.containsKey(acc.id) || acc.Users_ZPA_Platform__c > 0) && (!accVsOppZIAMap.containsKey(acc.id) || acc.No_of_Platform_Seats__c > 0) && acc.First_Contract_Date__c!=Null && acc.First_ZPA_Contract_Date__c != null && acc.First_ZPA_Contract_Date__c > System.today() && acc.First_Contract_Date__c > System.today() && !ext.Exclude_ZPA_from_Lifecycle__c && !ext.Exclude_ZIA_from_Lifecycle__c)){
               		customerLifeCycleValue = 'New Customer';
            	}
            	else if(((!accVsOppZIAMap.containsKey(acc.id) || acc.No_of_Platform_Seats__c > 0) && (ext.Latest_ZIA_Contract_Date__c != null && ZIAContractDate180Day < 180) && (acc.First_Contract_Date__c!=Null && FirstZIAContractDate180Day < 180 && acc.No_of_Platform_Seats__c >0) && (acc.Avg_Estimated_Users_L31D_Vs_Purchase__c!=Null && acc.Avg_Estimated_Users_L31D_Vs_Purchase__c < 25  ) && !ext.Latest_ZIA_Contract_25_Attained__c && !ext.Exclude_ZIA_from_Lifecycle__c) || 
                        (((!accVsOppZIAMap.containsKey(acc.id) || acc.No_of_Platform_Seats__c > 0) && ext.Latest_ZIA_Contract_Date__c != null && ZIAContractDate180Day < 180) && acc.Date_when_traffic_consumed_is_25__c!=Null && (acc.Avg_Estimated_Users_L31D_Vs_Purchase__c!=Null && acc.Avg_Estimated_Users_L31D_Vs_Purchase__c < 25) && !ext.Latest_ZIA_Contract_25_Attained__c && !ext.Exclude_ZIA_from_Lifecycle__c) ||
                        (((!accVsOppZPAMap.containsKey(acc.id) || acc.Users_ZPA_Platform__c > 0) && ext.Latest_ZPA_Contract_Date__c!=Null && ZPAContractDate180Day < 180) && (acc.First_ZPA_Contract_Date__c != null && FirstZPAContractDate180Day < 180 && acc.Users_ZPA_Platform__c >0 ) && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c !=0.0 && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c < 25 && !ext.Latest_ZPA_Contract_25_Attained__c && !ext.Exclude_ZPA_from_Lifecycle__c) || 
                        (((!accVsOppZPAMap.containsKey(acc.id) || acc.Users_ZPA_Platform__c > 0) && ext.Latest_ZPA_Contract_Date__c!=Null && ZPAContractDate180Day < 180) && acc.X25_ZPA_Traffic_attained_date__c!=Null && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c !=0.0 && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c < 25 && !ext.Latest_ZPA_Contract_25_Attained__c && !ext.Exclude_ZPA_from_Lifecycle__c)){
                	customerLifeCycleValue = 'Deployment';
            	}
                 //Slow Deployment Conditions modified for CR# 2890 - Varun 
                 //CR# 4564 - considering null, 0 values for slow deployment - Arsh
         		else if(((!accVsOppZIAMap.containsKey(acc.id) || acc.No_of_Platform_Seats__c > 0) && ext.Latest_ZIA_Contract_Date__c != null && ZIAContractDate180Day >= 180 && (acc.Avg_Estimated_Users_L31D_Vs_Purchase__c==Null || acc.Avg_Estimated_Users_L31D_Vs_Purchase__c < 25) && !ext.Latest_ZIA_Contract_25_Attained__c && !ext.Not_Slow_Deployment__c && !ext.Exclude_ZIA_from_Lifecycle__c) ||
                        ((!accVsOppZIAMap.containsKey(acc.id) || acc.No_of_Platform_Seats__c > 0) && ext.Latest_ZIA_Contract_Date__c != null && ZIAContractDate180Day >= 180 && (acc.Avg_Estimated_Users_L31D_Vs_Purchase__c==Null || acc.Avg_Estimated_Users_L31D_Vs_Purchase__c < 25) && !ext.Latest_ZIA_Contract_25_Attained__c && acc.Date_when_traffic_consumed_is_25__c==Null && !ext.Not_Slow_Deployment__c && !ext.Exclude_ZIA_from_Lifecycle__c) ||
                        ((!accVsOppZIAMap.containsKey(acc.id) || acc.No_of_Platform_Seats__c > 0) && acc.First_Contract_Date__c != null && FirstZIAContractDate180Day >= 180 && acc.No_of_Platform_Seats__c >0 && (acc.Avg_Estimated_Users_L31D_Vs_Purchase__c ==Null || acc.Avg_Estimated_Users_L31D_Vs_Purchase__c < 25) && !ext.Latest_ZIA_Contract_25_Attained__c && acc.Date_when_traffic_consumed_is_25__c==Null && !ext.Not_Slow_Deployment__c && !ext.Exclude_ZIA_from_Lifecycle__c) ||
                        ((!accVsOppZPAMap.containsKey(acc.id) || acc.Users_ZPA_Platform__c > 0) && ext.Latest_ZPA_Contract_Date__c != null && ZPAContractDate180Day >= 180 && (acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c ==Null || acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c < 25) && !ext.Latest_ZPA_Contract_25_Attained__c && !ext.Not_Slow_Deployment__c && !ext.Exclude_ZPA_from_Lifecycle__c) ||
                        ((!accVsOppZPAMap.containsKey(acc.id) || acc.Users_ZPA_Platform__c > 0) && ext.Latest_ZPA_Contract_Date__c != null && ZPAContractDate180Day >= 180 && (acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c ==Null || acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c < 25) && !ext.Latest_ZPA_Contract_25_Attained__c && acc.X25_ZPA_Traffic_attained_date__c==Null && !ext.Not_Slow_Deployment__c && !ext.Exclude_ZPA_from_Lifecycle__c) ||
                        ((!accVsOppZPAMap.containsKey(acc.id) || acc.Users_ZPA_Platform__c > 0) && acc.First_ZPA_Contract_Date__c != null && acc.Users_ZPA_Platform__c >0 && FirstZPAContractDate180Day >= 180 && (acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c ==Null || acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c < 25) && !ext.Latest_ZPA_Contract_25_Attained__c && acc.X25_ZPA_Traffic_attained_date__c==Null && !ext.Not_Slow_Deployment__c && !ext.Exclude_ZPA_from_Lifecycle__c)){
                	customerLifeCycleValue = 'Slow Deployment';                    
                }
            	else if(((!accVsOppZIAMap.containsKey(acc.id) || acc.No_of_Platform_Seats__c > 0) && (!accVsOppZPAMap.containsKey(acc.id) || acc.Users_ZPA_Platform__c > 0) && acc.First_Contract_Date__c!=null && acc.First_ZPA_Contract_Date__c!=null && (acc.Avg_Estimated_Users_L31D_Vs_Purchase__c!=Null && acc.Avg_Estimated_Users_L31D_Vs_Purchase__c >= 100) && acc.Users_with_ZApp__c  >=70 && (csc.Qualified_SSL_Inspected_Bytes__c!=Null && csc.Qualified_SSL_Inspected_Bytes__c >=50) && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c >= 70 && !ext.Exclude_ZPA_from_Lifecycle__c && !ext.Exclude_ZIA_from_Lifecycle__c) ||
                        ((!accVsOppZIAMap.containsKey(acc.id) || acc.No_of_Platform_Seats__c > 0 ) && acc.First_Contract_Date__c!=Null && (acc.First_ZPA_Contract_Date__c==null || acc.Users_ZPA_Platform__c==0 || ext.Exclude_ZPA_from_Lifecycle__c) && (acc.Avg_Estimated_Users_L31D_Vs_Purchase__c!=Null && acc.Avg_Estimated_Users_L31D_Vs_Purchase__c >= 100) && acc.Users_with_ZApp__c  >=70 && (csc.Qualified_SSL_Inspected_Bytes__c!=null && csc.Qualified_SSL_Inspected_Bytes__c >=50) && !ext.Exclude_ZIA_from_Lifecycle__c) ||
                        ((!accVsOppZPAMap.containsKey(acc.id) || acc.Users_ZPA_Platform__c > 0) && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c >= 70 && acc.First_ZPA_Contract_Date__c!=Null && (acc.First_Contract_Date__c==Null || acc.No_of_Platform_Seats__c==0 || ext.Exclude_ZIA_from_Lifecycle__c) && !ext.Exclude_ZPA_from_Lifecycle__c)){
                	customerLifeCycleValue = 'Transformed';
            	}
            	else if(((!accVsOppZIAMap.containsKey(acc.id) || acc.No_of_Platform_Seats__c > 0) && (!accVsOppZPAMap.containsKey(acc.id) || acc.Users_ZPA_Platform__c > 0) && acc.First_Contract_Date__c!=null && acc.First_ZPA_Contract_Date__c!=null && (acc.Avg_Estimated_Users_L31D_Vs_Purchase__c!=Null && acc.Avg_Estimated_Users_L31D_Vs_Purchase__c >= 25) && acc.Users_with_ZApp__c  >=25  && (csc.Qualified_SSL_Inspected_Bytes__c!=Null && csc.Qualified_SSL_Inspected_Bytes__c >= 6)  && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c >= 25 && !ext.Exclude_ZPA_from_Lifecycle__c && !ext.Exclude_ZIA_from_Lifecycle__c) ||
                        ((!accVsOppZIAMap.containsKey(acc.id) || acc.No_of_Platform_Seats__c > 0 ) && (acc.Avg_Estimated_Users_L31D_Vs_Purchase__c!=Null && acc.Avg_Estimated_Users_L31D_Vs_Purchase__c >= 25) && acc.Users_with_ZApp__c  >=25  && (csc.Qualified_SSL_Inspected_Bytes__c!=Null && csc.Qualified_SSL_Inspected_Bytes__c >= 6) && acc.First_Contract_Date__c!=Null && (acc.First_ZPA_Contract_Date__c==null || acc.Users_ZPA_Platform__c==0 || ext.Exclude_ZPA_from_Lifecycle__c) && !ext.Exclude_ZIA_from_Lifecycle__c) || 
                        ((!accVsOppZPAMap.containsKey(acc.id) || acc.Users_ZPA_Platform__c > 0) && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c >= 25 && acc.First_ZPA_Contract_Date__c!=Null && (acc.First_Contract_Date__c==Null || acc.No_of_Platform_Seats__c==0 || ext.Exclude_ZIA_from_Lifecycle__c) && !ext.Exclude_ZPA_from_Lifecycle__c)){
                	customerLifeCycleValue = 'Deployed';
            	}
            	//Modified by Swathi CR:1566 end
            	else{
                	customerLifeCycleValue = 'Laggard';
            	}
                //Modified by Swathi: CR 2707 Start
            	if(acc.Customer_Lifecycle__c != customerLifeCycleValue && !accVsOpp.containsKey(acc.id)){
                	acc.Customer_Lifecycle__c = customerLifeCycleValue;
                	accToUpdate.add(acc);
            	}
        	}
        }
        
        if(!accToUpdate.IsEmpty() && accToUpdate.size() > 0){
			TriggerHandler.bypass('AccountTriggerHandler');
            update accToUpdate;
            TriggerHandler.ClearBypass('AccountTriggerHandler');
        }
        //Modified by Swathi: CR 2707 End
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
    }

}