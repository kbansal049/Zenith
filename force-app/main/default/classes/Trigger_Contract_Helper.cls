public class Trigger_Contract_Helper{
    
    public static boolean blnRunOnce = false;
 // public static boolean blnExecuteOnce = false;
    
    public static void createCustomRenewals(List<Contract> listNewContract, Map<Id,Contract> mapOldContract){
        Set<Id> setOriginalContract = new Set<Id>();
        Set<Id> setContract = new Set<Id>();
        system.debug('in createCustomRenewals...');
        
        for(Contract objContract: listNewContract){
            if(objContract.Migrated_Contract__c == FALSE && objContract.Has_Non_Co_Termed_Lines__c){// && objContract.Has_Non_Co_Termed_Lines__c!= mapOldContract.get(objContract.id).Has_Non_Co_Termed_Lines__c )
                setOriginalContract.add(objContract.id);
            }
        }
        if(!setOriginalContract.isempty()){
            for(SBQQ__Subscription__c objSub: [SELECT Id,SBQQ__Contract__c FROM SBQQ__Subscription__C WHERE Non_Co_Term_Line__c = TRUE AND Custom_Renewal_Opportunity__c = NULL AND SBQQ__contract__c in : setOriginalContract AND SBQQ__TerminatedDate__c=NULL]){
                setContract.add(objSub.SBQQ__Contract__c);
            }
        }
        system.debug('setContract..'+setContract);
        if(!setContract.isEmpty() && !System.isFuture() && !System.isBatch() && !blnRunOnce && !Test.isRunningTest()){
            blnRunOnce = true;
            createCustomRenewalsFuture(setContract);
        }else if(!setContract.isEmpty() && (System.isFuture() || System.isBatch()) && !blnRunOnce){
            blnRunOnce = true;
            createCustomRenewalsMain(setContract);
        }
    }
    
    @future
    public static void createCustomRenewalsFuture(Set<Id> setContractIds){
        createCustomRenewalsMain(setContractIds);
    }
    
    public static void createCustomRenewalsMain(Set<Id> setContractIds){
        Map<Date,Opportunity> mapSubscriptionEndDateToOppty = new Map<Date, Opportunity>();
        Map<Id,Opportunity> mapOpportunityRecords = new Map<Id, Opportunity>();

        for(SBQQ__Subscription__c objSub : [SELECT Id,SBQQ__EndDate__c,SBQQ__Contract__c,SBQQ__Contract__r.AccountId FROM SBQQ__Subscription__C WHERE Non_Co_Term_Line__c = TRUE AND Custom_Renewal_Opportunity__c = NULL AND SBQQ__contract__c in : setContractIds AND SBQQ__TerminatedDate__c=NULL]){
            IF(!mapSubscriptionEndDateToOppty.containsKey(objSub.SBQQ__EndDate__c)){
                Opportunity objOppty = new Opportunity();
                objOppty.Closedate = objSub.SBQQ__EndDate__c;
                objOppty.Custom_Renewal__c = TRUE;
                objOppty.AccountId = objSub.SBQQ__Contract__r.AccountId;
                objOppty.Custom_Renewal_Date__c = objSub.SBQQ__EndDate__c;
                objOppty.SBQQ__RenewedContract__c = objSub.SBQQ__Contract__c;
                mapSubscriptionEndDateToOppty.put(objSub.SBQQ__EndDate__c,objOppty);
            }
        }
        if(!mapSubscriptionEndDateToOppty.isempty()){
            insert mapSubscriptionEndDateToOppty.values();
        
            Map<Date,Id> mapCRDateToOppty = new Map<Date,Id>();
            for(Opportunity objOpp : mapSubscriptionEndDateToOppty.values()){
                mapCRDateToOppty.put(objOpp.Custom_Renewal_Date__c,objOpp.Id);
                mapOpportunityRecords.put(objOpp.Id,objOpp);
            }
        
            // Create Shell Quote......
            SBQQ.TriggerControl.disable();
            
            Map<Date,SBQQ__Quote__c> mapQuoteStartDateToQuote = new Map<Date,SBQQ__Quote__c>();
            Map<Id,SBQQ__Quote__c> mapQuoteRecords = new Map<Id,SBQQ__Quote__c>();
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            
            for(Opportunity opp : [SELECT Id,Name,AccountId,Custom_Renewal_Date__c,SBQQ__RenewedContract__r.SBQQ__ExpirationDate__c,Pricebook2Id FROM Opportunity WHERE Id IN: mapOpportunityRecords.keySet()]){
                SBQQ__Quote__c objQuote = new SBQQ__Quote__c();
                objQuote.SBQQ__Opportunity2__c = opp.Id;
                objQuote.SBQQ__Account__c = opp.AccountId;
                objQuote.SBQQ__StartDate__c = opp.Custom_Renewal_Date__c.addDays(1);
                objQuote.SBQQ__EndDate__c = opp.SBQQ__RenewedContract__r.SBQQ__ExpirationDate__c;
                objQuote.SBQQ__PriceBook__c = opp.Pricebook2Id;
                objQuote.SBQQ__PricebookId__c = opp.Pricebook2Id;  
                objQuote.SBQQ__Type__c = 'Renewal';
                quoteList.add(objQuote);
                
            }
            
            if(!quoteList.isEmpty()){
                INSERT quoteList;
            }
            
            Map<Date,Id> mapStartDateToQuote = new Map<Date,Id>();
            
            for(SBQQ__Quote__c objQuote : quoteList){    
                mapStartDateToQuote.put(objQuote.SBQQ__StartDate__c.addDays(-1),objQuote.Id);
                mapQuoteRecords.put(objQuote.Id,objQuote);
            }

            // Create Quote Lines....
            List<SBQQ__QuoteLine__c> qlinesList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__Subscription__c objSub : [SELECT Id,SBQQ__Product__c,Product_Code__c, SBQQ__EndDate__c,SBQQ__Contract__c,SBQQ__Quantity__c,SBQQ__QuoteLine__c,
                                                SBQQ__QuoteLine__r.SBQQ__PricebookEntryId__c,SBQQ__PricingMethod__c,SBQQ__Number__c,SBQQ__Contract__r.EndDate,
                                                SBQQ__BillingFrequency__c,SBQQ__BillingType__c,Pricing_Meter__c,SBQQ__SubscriptionPricing__c,
                                                Subscription_Term__c,SBQQ__SubscriptionType__c,Finance_MRR__c,SBQQ__ListPrice__c
                                                FROM SBQQ__Subscription__c 
                                                WHERE Non_Co_Term_Line__c = TRUE AND Custom_Renewal_Opportunity__c = NULL
                                                AND SBQQ__contract__c IN: setContractIds AND SBQQ__TerminatedDate__c=NULL]){
              
                if(mapStartDateToQuote.containsKey(objSub.SBQQ__EndDate__c)){
                
                    Id quoteId = mapStartDateToQuote.get(objSub.SBQQ__EndDate__c);
                    SBQQ__QuoteLine__c objQline = new SBQQ__QuoteLine__c();
                    objQline.SBQQ__Quote__c = quoteId;
                    objQline.SBQQ__PricebookEntryId__c = objSub.SBQQ__QuoteLine__c != null ? objSub.SBQQ__QuoteLine__r.SBQQ__PricebookEntryId__c :null;
                    objQline.SBQQ__Product__c = objSub.SBQQ__Product__c;
                    objQline.SBQQ__Quantity__c = objSub.SBQQ__Quantity__c;
                    objQline.SBQQ__Number__c = objSub.SBQQ__Number__c;
                    objQline.SBQQ__PricingMethod__c = objSub.SBQQ__PricingMethod__c;
                    objQline.SBQQ__RenewedSubscription__c = objSub.Id;
                    objQline.SBQQ__StartDate__c = objSub.SBQQ__EndDate__c.addDays(1);
                    objQline.SBQQ__EndDate__c = objSub.SBQQ__Contract__r.EndDate;
                    objQline.SBQQ__ListPrice__c = objSub.SBQQ__ListPrice__c;  
                    objQline.SBQQ__BillingFrequency__c = objSub.SBQQ__BillingFrequency__c;
                    objQline.SBQQ__BillingType__c = objSub.SBQQ__BillingType__c;
                    objQline.Pricing_Meter__c = objSub.Pricing_Meter__c;
                    objQline.SBQQ__SubscriptionPricing__c = objSub.SBQQ__SubscriptionPricing__c;
                    objQline.SBQQ__ProductSubscriptionType__c = objSub.SBQQ__SubscriptionType__c;
                    objQline.SBQQ__SubscriptionType__c = objSub.SBQQ__SubscriptionType__c;
                    objQline.SBQQ__SubscriptionTerm__c = objSub.Subscription_Term__c;
                    
                    qlinesList.add(objQline);        
                    
                 }
            }
            if(!qlinesList.isEmpty()){
                INSERT qlinesList;
            }

            List<OpportunityLineItem> listOLIToInsert = new List<OpportunityLineItem>();
            List<SBQQ__Subscription__c> listSubsToUpdate = new List<SBQQ__Subscription__c>();

            for(SBQQ__Subscription__c objSub : [SELECT Id,SBQQ__Product__c,Product_Code__c, SBQQ__EndDate__c,SBQQ__Contract__c,SBQQ__Quantity__c,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__PricebookEntryId__c,SBQQ__Contract__r.EndDate,SBQQ__StartDate__c,Finance_MRR__c,Net_Total__c FROM SBQQ__Subscription__C WHERE Non_Co_Term_Line__c = TRUE AND Custom_Renewal_Opportunity__c=NULL AND SBQQ__TerminatedDate__c=NULL]){
                if(mapCRDateToOppty.containsKey(objSub.SBQQ__EndDate__c)){
                    Id idCROppty = mapCRDateToOppty.get(objSub.SBQQ__EndDate__c);
                /*  OpportunityLineItem objOLI = new OpportunityLineItem();
                    objOLI.OpportunityId = idCROppty;
                    objOLI.PricebookEntryId = objSub.SBQQ__QuoteLine__c !=null ? objSub.SBQQ__QuoteLine__r.SBQQ__PricebookEntryId__c :null;
                    objOLI.Product_Code__c = objSub.Product_Code__c;
                    objOLI.Product2Id = objSub.SBQQ__Product__c;
                    objOLI.Quantity = objSub.SBQQ__Quantity__c;
                    Decimal decPerDay = objSub.Net_Total__c /  (objSub.SBQQ__StartDate__c.daysBetween(objSub.SBQQ__EndDate__c));
                    Decimal dectotal = decPerDay * ((objSub.SBQQ__EndDate__c.addDays(1)).daysBetween(objSub.SBQQ__Contract__r.EndDate));
                    objOLI.TotalPrice = objSub.Finance_MRR__c * 12;
                    objOLI.ACV_New__c = objSub.Finance_MRR__c * 12;
                    listOLIToInsert.add(objOLI);        
                */
                    objSub.Custom_Renewal_Opportunity__c = idCROppty;
                    listSubsToUpdate.add(objSub);
                }
            }

            if(!listSubsToUpdate.isEmpty()){
                update listSubsToUpdate;
            }
            
            Decimal Quote_MRR = 0;
            for(SBQQ__QuoteLine__c objQLine : qlinesList){
                Date compareDate = objQLine.SBQQ__StartDate__c.addDays(-1);
                if(mapCRDateToOppty.containsKey(compareDate)){
                    Id idCROppty = mapCRDateToOppty.get(compareDate);
                    OpportunityLineItem objOLI = new OpportunityLineItem();
                    objOLI.OpportunityId = idCROppty;
                    objOLI.PricebookEntryId = objQLine.SBQQ__PricebookEntryId__c;
                    objOLI.Product_Code__c = objQLine.SBQQ__ProductCode__c;
                    objOLI.Product2Id = objQLine.SBQQ__Product__c;
                    objOLI.Quantity = objQLine.SBQQ__Quantity__c;
                    objOLI.SBQQ__QuoteLine__c = objQLine.Id;
                   // objOLI.TotalPrice = objQLine.MRR_New__c * 12;
                   // objOLI.ACV_New__c = objQLine.MRR_New__c * 12;
                   // Quote_MRR = Quote_MRR + objQLine.MRR_New__c;
                    listOLIToInsert.add(objOLI);        
                }
            }
            
            if(!listOLIToInsert.isEmpty()){
                insert listOLIToInsert;
            }
            SBQQ.TriggerControl.enable();
            
            // Update Quote Header Fields
            List<SBQQ__Quote__c> listQuoteToUpdate = new List<SBQQ__Quote__c>();
            
            for(SBQQ__Quote__c objQuote: [SELECT Id,Current_Quote_MRR__c FROM SBQQ__Quote__c WHERE Id IN :mapQuoteRecords.keySet()]){
               // objQuote.Current_Quote_MRR__c = Quote_MRR;
                objQuote.Shell_Quote__c = true;
                listQuoteToUpdate.add(objQuote);
                system.debug('quoteList 2# '+objQuote);
            }
            
            if(!listQuoteToUpdate.isEmpty()){
                UPDATE listQuoteToUpdate;
            }
        }

     }
    
   /*
     public static void createContractOnSplit(List<Contract> listNewContract){
        Set<Id> setContracts = new Set<Id>();
        
        for(Contract objContract: listNewContract){
            if(objContract.Split_Contract__c == True){
                setContracts.add(objContract.Id);
            }
        }
        system.debug('setContracts..'+setContracts);
         
        if(!setContracts.isEmpty() && !System.isFuture() && !System.isBatch() && !blnExecuteOnce){
            blnExecuteOnce = true;
            createContractOnSplitFuture(setContracts);
        }else if(!setContracts.isEmpty() && (System.isFuture() || System.isBatch()) && !blnExecuteOnce){
            blnExecuteOnce = true;
            createContractOnSplitMain(setContracts);
        }
    }
    
    
    @future
    public static void createContractOnSplitFuture(Set<Id> setContractIds){
        system.debug('inside future');
        createContractOnSplitMain(setContractIds);
    }
    
    
    public static void createContractOnSplitMain(Set<Id> setContractIds){
        system.debug('inside main split'); 
        system.debug('setContractIds '+setContractIds); 
        List<Contract> listContractToInsert = new List<Contract>();
        List<Contract> listContractToUpdate = new List<Contract>();
        Map<Id, Contract> mapOldContractwithNewCon = new Map<Id, Contract>();
        List<SBQQ__Subscription__C> listSubscriptionsToUpdate = new List<SBQQ__Subscription__C>();
        Set<Id> phantomIds = new Set<Id>();
        
        for(Contract objCon : [SELECT Id,Name,AccountId,Bill_to__c,Billing_Frequency__c,Price_List__c,SBQQ__Opportunity__c,
                               Split_Contract__c,Created_via_contract_split__c
                               FROM Contract WHERE Id IN: setContractIds]){ 
                                
            Contract objConCopy = objCon.clone(false,false,false,false);
            objConCopy.Split_Contract__c = false;
            objConCopy.Created_via_contract_split__c = true;                       
            listContractToInsert.add(objConCopy);  
            mapOldContractwithNewCon.put(objCon.Id,objConCopy);                            
        }

            Contract con = new Contract();
            con.AccountId  = objCon.AccountId;
            con.Bill_to__c = objCon.Bill_to__c;
            con.Billing_Frequency__c = objCon.Billing_Frequency__c;
            con.Price_List__c = objCon.Price_List__c;
            con.SBQQ__Opportunity__c = objCon.SBQQ__Opportunity__c;
            con.Split_Contract__c = false;
            listContractToInsert.add(con); 
        
        System.debug('listContractToInsert..'+listContractToInsert);
        
        if(!listContractToInsert.isEmpty()){
            INSERT listContractToInsert;
        }
        
        for(SBQQ__Subscription__c objSub : [SELECT Id,SBQQ__EndDate__c,SBQQ__Contract__c,SBQQ__Contract__r.AccountId 
                                           FROM SBQQ__Subscription__c 
                                           WHERE Phantom_to_Split__c = true AND SBQQ__contract__c IN: setContractIds]){
                
            if(mapOldContractwithNewCon.containsKey(objSub.SBQQ__Contract__c)){
                System.debug('new conId '+mapOldContractwithNewCon.get(objSub.SBQQ__Contract__c).Id);
                phantomIds.add(objSub.Id);
                objSub.SBQQ__Contract__c = mapOldContractwithNewCon.get(objSub.SBQQ__Contract__c).Id;
                listSubscriptionsToUpdate.add(objSub);              
            }
        }
        
        system.debug('phantomIds '+phantomIds);
        
        for(SBQQ__Subscription__c objSub : [SELECT Id,SBQQ__EndDate__c,SBQQ__Contract__c,SBQQ__Contract__r.AccountId 
                                            FROM SBQQ__Subscription__c
                                            WHERE SBQQ__RequiredById__c IN: phantomIds AND SBQQ__contract__c IN: setContractIds]){
                                                
             if(mapOldContractwithNewCon.containsKey(objSub.SBQQ__Contract__c)){
                 objSub.SBQQ__Contract__c = mapOldContractwithNewCon.get(objSub.SBQQ__Contract__c).Id;
                 listSubscriptionsToUpdate.add(objSub);                                  
             }                                  
        }
        system.debug('listSubscriptionsToUpdate 1 '+listSubscriptionsToUpdate);
        
        if(!listSubscriptionsToUpdate.isEmpty()){
            UPDATE listSubscriptionsToUpdate;
        }
        
        System.debug('listSubscriptionsToUpdate 2..'+listSubscriptionsToUpdate);
        
        for(Contract objCon : [SELECT Id,Name,AccountId,Bill_to__c,Billing_Frequency__c,Price_List__c,SBQQ__Opportunity__c,
                               Split_Contract__c
                               FROM Contract WHERE Id IN: setContractIds]){
            objCon.Split_Contract__c = false;
            listContractToUpdate.add(objCon);
        }
        
        if(!listContractToUpdate.isEmpty()){
            UPDATE listContractToUpdate;
        }

    }
    
    */
    
}