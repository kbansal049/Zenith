/*****************************************************************************************
Name: ContractDetail_Subscription_update
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to map contract detail to Subscription and Vice Versa
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Madhusudan V            15-July-2021      Initial Development
******************************************************************************************/

public class ContractDetail_Subscription_update implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('ContractDetail_Subscription_update');
    public List<String> errorLst = new List<String>();
    public List<String> successLst = new List<String>();
    DateTime startDate;
    DateTime endDate;
    string sQuery;
    
    public ContractDetail_Subscription_update(String stdt, String eddt, string query){
        startDate = Datetime.valueOf(stdt);
        endDate = Datetime.valueOf(eddt);
        if(query == '')
        {
        	sQuery = 'Select Id from Account where Id in (Select Account_Name__c from Contract_Detail__c where LastmodifiedDate >= :startDate and LastmodifiedDate <= :endDate  AND Contract_Detail_Status__c IN (\'Active\',\'Pending Renewal\',\'Pending Activation\',\'Renewed\'))';	    
        } 
        else
        {
        	sQuery = query;    
        }  
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(sQuery);     
    }

    public void execute (Database.BatchableContext context, List<Account> scope){
        this.zb.callExecute('Account', scope.size());
        Boolean error = FALSE;
        Account acc = scope[0];
        Set<Id> subSet = new Set<Id>();
        Map<Id, SBQQ__Subscription__c> QlMap = new Map<Id, SBQQ__Subscription__c>();
        Map<String, List<Contract_Detail__c>> mapSOnumtocd = new Map<String, List<Contract_Detail__c>>();
        Map<String, Map<String, String>> mapSOnumtoassetrampCD = new Map<String, Map<String, String>>();
        Map<Id, String> mapQuoteIdtoSO = new Map<Id, String>();
        Map<Id, SBQQ__Subscription__c> subscriptionMap = new Map<Id, SBQQ__Subscription__c>();
        List<Contract_Detail__c> conDetailLst = new List<Contract_Detail__c>();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        for(Contract_Detail__c cd: [SELECT Id, Name, Account_Name__c, Sales_Order_Name__c, Product_SKU__c, Start_Date__c, End_Date__c, Quantity__c, Sales_Order__c, Contract_No__c, Amount_USD__c FROM Contract_Detail__c WHERE Contract_Detail_Status__c IN ('Active','Pending Renewal','Pending Activation','Renewed') AND Account_Name__c = :acc.Id]){
            if(cd.Sales_Order_Name__c != NULL){
                if(!mapSOnumtocd.containskey(cd.Sales_Order_Name__c))
                {
                    mapSOnumtocd.put(cd.Sales_Order_Name__c, new List<Contract_Detail__c>{cd});
                }
                else
                {
                    List<Contract_Detail__c> templst = mapSOnumtocd.get(cd.Sales_Order_Name__c);
                    templst.add(cd);
                    mapSOnumtocd.put(cd.Sales_Order_Name__c, templst);
                }    
            } 
        }        
        for(SBQQ__Quote__c quote: [SELECT Id, Sales_Order__c FROM SBQQ__Quote__c WHERE Sales_Order__c IN :mapSOnumtocd.keySet()]){
            mapQuoteIdtoSO.put(quote.Id, quote.Sales_Order__c);
        }
        for(SBQQ__Subscription__c sub: [SELECT Id, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Quote__c, 
                                        Product_Code__c, SBQQ__SubscriptionStartDate__c, SBQQ__SubscriptionEndDate__c,
                                        SBQQ__Quantity__c, Is_Ramped__c 
                                        FROM SBQQ__Subscription__c 
                                        WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c in :mapQuoteIdtoSO.keyset() and SBQQ__Account__c = :acc.Id]){
            String SOName = mapQuoteIdtoSO.get(sub.SBQQ__QuoteLine__r.SBQQ__Quote__c);
            for(Contract_Detail__c cd: mapSOnumtocd.get(SOName)){
                if(cd.Product_SKU__c == sub.Product_Code__c 
                && cd.Start_Date__c == sub.SBQQ__SubscriptionStartDate__c 
                && cd.End_Date__c == sub.SBQQ__SubscriptionEndDate__c 
                && cd.Quantity__c == sub.SBQQ__Quantity__c 
                && cd.Amount_USD__c > 0){ 
                    subSet.add(sub.Id);
                    sub.Contract_Detail__c = cd.Id;
                    sub.Contract_No__c = cd.Contract_No__c;
                    sub.Sales_Order__c = cd.Sales_Order__c;
                    subscriptionMap.put(sub.Id, sub);
                    if(sub.Is_Ramped__c && sub.Sales_Order__c != NULL){
                        if(!mapSOnumtoassetrampCD.containskey(sub.Sales_Order__c)){
                            mapSOnumtoassetrampCD.put(sub.Sales_Order__c, new Map<String,String>{sub.Product_Code__c => cd.Name});
                        }
                        else{
                            Map<String, String> mapprodtocd = mapSOnumtoassetrampCD.get(sub.Sales_Order__c);
                            if(!mapprodtocd.containskey(sub.Product_Code__c)){
                                mapprodtocd.put(sub.Product_Code__c, cd.Name);
                            }else{
                                String cdname = mapprodtocd.get(sub.Product_Code__c);
                                cdname += cd.Name;
                                mapprodtocd.put(sub.Product_Code__c, cdname);
                            }
                            mapSOnumtoassetrampCD.put(sub.Sales_Order__c, mapprodtocd);
                        }
                    }
                }
            }
        }
        
        for(SBQQ__Subscription__c sub: subscriptionMap.values()){
            String addcd = '';
            if(mapSOnumtoassetrampCD != null && mapSOnumtoassetrampCD.containskey(sub.Sales_Order__c)){
                Map<String, String> mapprodtocd = mapSOnumtoassetrampCD.get(sub.Sales_Order__c);
                if(mapprodtocd != null && mapprodtocd.containskey(sub.Product_Code__c)){
                    addcd = mapprodtocd.get(sub.Product_Code__c);
                }
            }
            sub.Additional_Contract_Details__c = addcd;
            if(sub.SBQQ__QuoteLine__c != NULL){
                QlMap.put(sub.SBQQ__QuoteLine__c,sub);    
            }
        }
        
        for(SBQQ__QuoteLine__c Qli: [SELECT Id, Contract_Detail_Name__c FROM SBQQ__QuoteLine__c WHERE Id IN : QlMap.keyset()]){
            Qli.Contract_Detail_Name__c = QlMap.get(Qli.Id).Contract_Detail__c;
            Qli.Contract_No__c = QlMap.get(Qli.Id).Contract_No__c;
            Qli.Additional_Contract_Details__c = QlMap.get(Qli.Id).Additional_Contract_Details__c;
            quoteLineList.add(Qli);
        }
        //TriggerUtility.generateYearWiseSplitExecuted();
        
        List<Database.SaveResult> srList1 = database.update(subscriptionMap.values(), false);
        for (Database.SaveResult sr : srList1) {
            if (!sr.isSuccess()) {  error = TRUE;
            }
        }
        
        List<Database.SaveResult> srList2 = database.update(quoteLineList, false);
        for (Database.SaveResult sr : srList2) {
            if (!sr.isSuccess()) { error = TRUE;
            }
        }
        if(error){ errorlst.add(acc.Id);
        }
        else{
            successlst.add(acc.Id);
        }

        for(SBQQ__Subscription__c sub : subscriptionMap.Values()){
            if(sub.Contract_Detail__c != NULL){
                Contract_Detail__c cd = new Contract_Detail__c(Id = sub.Contract_Detail__c);
                cd.subscription__c = sub.Id;
                conDetailLst.add(cd);    
            }      
        }
        if(!conDetailLst.isEmpty() && conDetailLst != NULL){
            update conDetailLst;        
        }
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ERROR});
            if(owea.size() > 0){ mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{ mail1.setsenderDisplayName('Sales Ops System Admin');
            } mail1.setSubject('Contract Detail Asset Line Item Sync Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' account records that have failed: \n';
            for(String s: errorlst){ msgbody += s + '\n';
            } mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }
        if(!successlst.isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if (owea.size() > 0) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }
            else{mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Contract Detail Asset Line Item Sync Update Success result ');
            mail.setPlainTextBody('Contract Detail Asset Line Item Sync Update has been executed Successfully and processed '+ successlst.size() + ' account records.');
            messageList.add(mail);
        }
        if(!Test.isRunningTest()){ Messaging.sendEmail(messageList);
        }
    }   
}