/*********************************************************************************
** Class Name: SubscriptionTriggerHelper
** Description: This class contains methods which are getting invoked
        from Subscription Trigger.
*********************************************************************************/
public Class SubscriptionTriggerHelper{
    
    public static Map<Id,Contract> mapContracts = new Map<Id,Contract>();
    public static Boolean blnIsInsertEvent = false;
    
    //Description: This method is responsible for collectively showing all active subscriptions for one contract record.
    public static void updateParentContract(List<SBQQ__Subscription__c> newList, Map<id, SBQQ__Subscription__c> subsMap){
        system.debug('Test 01');
        List<SBQQ__Subscription__c> lstSubscriptions = new List<SBQQ__Subscription__c>();
        Set<ID> conIDs = new Set<ID>();
        Map<Id, List<SBQQ__Subscription__c>> mapSubs = new Map<Id, List<SBQQ__Subscription__c>>();
        List<contract> lstContract = new List<contract>();
        List<contract> lstContractUpdate = new List<contract>();
        Date TodayDate = Date.valueOf(SYSTEM.TODAY());
        Map<Id,Boolean> mapContractHasActivePS = new Map<Id,Boolean>();
        Set<Id> setContractsWithTerminatedLines = new Set<Id>();
        Set<Id> setContractIDToSplit = new Set<Id>();
        Map<id,Date> mapRequiredByToEndDate= new Map<Id,Date>();
        set<Id> setContractWithNonCotermAddOns = new set<Id>();
        List<SBQQ__Subscription__c> lstSubscriptionsUpdate = new List<SBQQ__Subscription__c>();        
        Map<Id,Date> mapContractIdToSubEndDate = new Map<Id,Date>();
        Map<Id,Date> mapContractIdToSubStartDate = new Map<Id,Date>();
        
        try{
            for(SBQQ__Subscription__c req: newList){
                conIDs.add(req.SBQQ__Contract__c);
                if(req.SBQQ__TerminatedDate__c !=null){
                    setContractsWithTerminatedLines.add(req.SBQQ__Contract__c);        
                }
            }
            if(!conIDs.isEmpty()){
                lstSubscriptions  = [SELECT id, name,SBQQ__Contract__c,SBQQ__RequiredById__c,SBQQ__contract__r.EndDate,SBQQ__contract__r.StartDate, SBQQ__contract__r.Has_Active_Premium_Support__C, SBQQ__ContractNumber__c,
                                     SBQQ__Product__r.ProductCode, SBQQ__ProductName__c,SBQQ__StartDate__c, SBQQ__EndDate__c,SBQQ__Quantity__c,SBQQ__TerminatedDate__c,SBQQ__SubscriptionEndDate__c,
                                     SBQQ__ProductOption__c,SBQQ__ProductOption__r.Feature_Category__c,SBQQ__SubscriptionType__c,
                                     Subscription_Line_Status__c, SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Early_Renewal__c,
                                     Created_via_Early_Renewal__c,Phantom_to_Split__c,SBQQ__Contract__r.Created_via_contract_split__c
                                     FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c in :conIDs AND SBQQ__TerminatedDate__c = NULL];//SBQQ__StartDate__c <= TODAY AND SBQQ__EndDate__c >= TODAY AND 
                system.debug('lstSubscriptions is:'+lstSubscriptions);
                for(SBQQ__Subscription__c objSub: lstSubscriptions){
                   if(mapSubs.containsKey(objSub.SBQQ__Contract__c) && mapSubs.get(objSub.SBQQ__Contract__c) != null) {
                        List<SBQQ__Subscription__c> lst_RE = mapSubs.get(objSub.SBQQ__Contract__c);
                        lst_RE.add(objSub);
                        mapSubs.put(objSub.SBQQ__Contract__c ,lst_RE); 
                    }else{
                        mapSubs.put(objSub.SBQQ__Contract__c , new List<SBQQ__Subscription__c> {objSub});
                    }
                    if(objSub.SBQQ__product__r.productcode=='ZCES-SUP-PREM' || objSub.SBQQ__product__r.productcode=='ZCES-SUP-PREM-FED' || objSub.SBQQ__product__r.productcode=='ZCES-SUP-PREM-SP'){
                        mapContractHasActivePS.put(objSub.SBQQ__Contract__c,true);
                    } 
                    System.debug('mapContractHasActivePS..'+mapContractHasActivePS);
                    system.debug('objSub.SBQQ__product__r.productcode...'+objSub.SBQQ__product__r.productcode);
                    system.debug('objSub.SBQQ__SubscriptionEndDate__c'+objSub.SBQQ__SubscriptionEndDate__c);
                    system.debug('objSub.SBQQ__Contract__r.EndDate'+objSub.SBQQ__Contract__r.EndDate);
                    if(objSub.SBQQ__product__r.productcode == null || objSub.SBQQ__product__r.productcode == ''){
                        if(objSub.SBQQ__SubscriptionEndDate__c!= objSub.SBQQ__Contract__r.EndDate && objSub.Created_via_Early_Renewal__c == false){
                        }else{
                            mapRequiredByToEndDate.put(objSub.id,objSub.SBQQ__subscriptionEndDate__c); 
                        }
                    }                   
                    if(objSub.SBQQ__RequiredById__c!=null && mapRequiredByToEndDate!=null && mapRequiredByToEndDate.containsKey(objSub.SBQQ__RequiredById__c) && mapRequiredByToEndDate.get(objSub.SBQQ__RequiredById__c) != objSub.SBQQ__subscriptionEnddate__c){
                        setContractWithNonCotermAddOns.add(objSub.SBQQ__Contract__c);
                    }
                    // populating dates if Contract Extended...
                     system.debug('before if 1');
                    if(objSub.SBQQ__QuoteLine__c!=null && (objSub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Early_Renewal__c == TRUE || objSub.SBQQ__Contract__r.Created_via_contract_split__c == TRUE) && objSub.SBQQ__SubscriptionType__c =='Renewable' && objSub.Subscription_Line_Status__c == 'New' ){
                        system.debug('inside if 1');
                        Date dtStartDate = objSub.SBQQ__StartDate__c;
                        Date dtEndDate = objSub.SBQQ__EndDate__c;
                        if(!mapContractIdToSubEndDate.containsKey(objSub.SBQQ__Contract__c) || (mapContractIdToSubEndDate.containsKey(objSub.SBQQ__Contract__c) && mapContractIdToSubEndDate.get(objSub.SBQQ__Contract__c) < dtEndDate)){
                            mapContractIdToSubEndDate.put(objSub.SBQQ__Contract__c,dtEndDate);
                        }
                        if(!mapContractIdToSubStartDate.containsKey(objSub.SBQQ__Contract__c) || (mapContractIdToSubStartDate.containsKey(objSub.SBQQ__Contract__c) && mapContractIdToSubStartDate.get(objSub.SBQQ__Contract__c) < dtStartDate)){
                            mapContractIdToSubStartDate.put(objSub.SBQQ__Contract__c,dtStartDate);
                        }                       
                        
                    }
                    
                }
                if(conIDs!=null && !conIDs.isEmpty() && (mapContracts==null || mapContracts.isEmpty())){
                    mapContracts = new Map<Id,Contract>([SELECT Id,Has_Active_Premium_Support__C,SBQQ__RenewalOpportunity__c,SBQQ__RenewalQuoted__c,SBQQ__RenewalOpportunity__r.stagename,SBQQ__RenewalOpportunity__r.isClosed,
                                                         Contract_Extended__c,StartDate,EndDate,SBQQ__RenewalForecast__c,Split_Contract__c
                                                         FROM Contract WHERE Id IN: conIDs ]);        
                }
                for(Id idContract: mapSubs.keySet()){
                    system.debug('idContract..'+idContract);
                    String totalRE = getTableForSubs(mapSubs.get(idContract));
                    //Contract us = new Contract(id=idContract, Active_Subscription_Products__c = totalRE);
                    Contract objContract = mapContracts!=null && mapContracts.containsKey(idContract) ? mapContracts.get(idContract) : new Contract(id=idContract);
                    objContract.Active_Subscription_Products__c = totalRE;
                    objContract.Has_Active_Premium_Support__C = mapContractHasActivePS!=null && mapContractHasActivePS.containsKey(idContract) ? true : false;
                    system.debug('in contract loop..'+objContract.Has_Active_Premium_Support__C);
                    if(((setContractsWithTerminatedLines!=null && setContractsWithTerminatedLines.contains(idContract)) || (conIDs!=null && conIDs.contains(idContract)) )&& objContract.SBQQ__RenewalOpportunity__c!=null && objContract.sbqq__renewalQuoted__c==true && objContract.SBQQ__RenewalOpportunity__r.isClosed== false ){
                        objContract.SBQQ__RenewalQuoted__c=false;
                    }                  
                    
                    if(setContractWithNonCotermAddOns!=null && setContractWithNonCotermAddOns.contains(idContract)){
                        objContract.Has_Non_Co_Termed_Lines__c=true;
                    }
                    
                    // Added logic if Contract Extended...
                    if(mapContractIdToSubEndDate!=null && mapContractIdToSubEndDate.containsKey(objContract.id) && mapContractIdToSubEndDate.get(objContract.id) != null /* && objContract.EndDate < mapContractIdToSubEndDate.get(objContract.id) */ ){
                    
                        system.debug('inside if 2');
                        
                        objContract.Contract_Extended__c = true; 
                        objContract.StartDate = mapContractIdToSubStartDate.get(objContract.Id);
                        objContract.EndDate = mapContractIdToSubEndDate.get(objContract.id);
                        
                        // Reset Renewal oppty on contract...
                        objContract.SBQQ__RenewalForecast__c = false;
                        objContract.SBQQ__RenewalQuoted__c = false;
                        objContract.SBQQ__RenewalOpportunity__c = null;
                    }
                      
                    lstContractUpdate.add(objContract);   
                }
                system.debug('lstContractUpdate is:'+lstContractUpdate);
                if(!lstContractUpdate.isEmpty()){
                    update lstContractUpdate;
                } 
            }
        }Catch(Exception e){
            system.debug('Exception Occurred:' +e.getStackTraceString());
            system.debug('Exception Occurred:' +e.getMessage());
        }
    }
    
    //This method is responsible generating a HTML table and adding subscription data into it.
    public static string getTableForSubs(List<SBQQ__Subscription__c> subsList){
        String htmlBody = '';
        //open table..
        try{
            htmlBody = '<table border="1" style="border-collapse: collapse"><tr><th>Product Name</th><th>SKU Code</th><th>Start Date</th><th>End Date</th><th>Quantity</th></tr>';//<th>Contract#</th><th>Subscription#</th>
            //iterate over list and output columns/data into table rows...
            for(SBQQ__Subscription__c subs : subsList){
                String prodName = subs.SBQQ__ProductName__c; if(subs.SBQQ__ProductName__c == null){prodName = '';}
                String skuCode = subs.SBQQ__Product__r.ProductCode; if(subs.SBQQ__Product__r.ProductCode == null){skuCode = '';}
                String dateFormatString = 'd MMM, yyyy';
                String startDate = subs.SBQQ__StartDate__c!=null ? (Datetime.newInstance(subs.SBQQ__StartDate__c.year(), subs.SBQQ__StartDate__c.month(),subs.SBQQ__StartDate__c.day())).format(dateFormatString) : ''; 
                if(String.valueOf(subs.SBQQ__StartDate__c) == null){startDate = '';}
                String endDate = subs.SBQQ__EndDate__c!=null ? (Datetime.newInstance(subs.SBQQ__EndDate__c.year(), subs.SBQQ__EndDate__c.month(),subs.SBQQ__EndDate__c.day())).format(dateFormatString) : ''; 
                if(String.valueOf(subs.SBQQ__EndDate__c) == null){endDate = '';}
                String qty = subs.SBQQ__Quantity__c!=null ? String.valueOf(Math.round(subs.SBQQ__Quantity__c)) : ''; if(String.valueOf(subs.SBQQ__Quantity__c) == null){qty = '';}
                htmlBody += '<tr><td>'+ prodName +'</td><td>'+ skuCode +'</td><td>'+ startDate +'</td><td>'+ endDate +'</td><td>'+ qty +'</td></tr>';
            }
            //close table...
            htmlBody += '</table>';
            system.debug('Email Body: ' + htmlBody);   
        }Catch(Exception e){
            htmlBody = '';
            system.debug('Exception Occurred:' +e.getStackTraceString());
        }
        return htmlBody;
    }

    public static void updatePlatformSKUOnPhantom(List<SBQQ__Subscription__c> newList, Map<Id,SBQQ__Subscription__c> newMap){
        Map<Id,Decimal> mapPhantomToPlatformSKU = new Map<Id,Decimal>();
        Map<Id,SBQQ__Subscription__c> mapPhantomToPlatformSub = new Map<Id,SBQQ__Subscription__c>();
        Map<Id,SBQQ__Subscription__c> mapRevisedSubscriptionToNew = new Map<Id,SBQQ__Subscription__c>();
        
        for(SBQQ__Subscription__c objSub : newList){
            if(objSub.Platform_SKU_Number__c!=null && objSub.Platform_SKU_Number__c!=0 && objSub.SBQQ__RequiredById__c!=null && objSub.SBQQ__TerminatedDate__c==null){
                mapPhantomToPlatformSKU.put(objSub.SBQQ__RequiredById__c,objSub.Platform_SKU_Number__c);
                mapPhantomToPlatformSub.put(objSub.SBQQ__RequiredById__c,objSub);
            }
            if(objSub.SBQQ__RevisedSubscription__c !=null && objSub.SBQQ__TerminatedDate__c ==null){
                mapRevisedSubscriptionToNew.put(objSub.SBQQ__RevisedSubscription__c,objSub);
            }
        }
        system.debug('mapPhantomToPlatformSKU..'+mapPhantomToPlatformSKU);
        if(!mapPhantomToPlatformSKU.isEmpty() || !mapRevisedSubscriptionToNew.isempty()){
            List<SBQQ__Subscription__c> listSubsToUpdate = new List<SBQQ__Subscription__c>();
            for(Id idPhantom: mapPhantomToPlatformSKU.keySet()){
                SBQQ__Subscription__c objPlatformSub = mapPhantomToPlatformSub.get(idPhantom);
                SBQQ__Subscription__c objSub =   new SBQQ__Subscription__c(id=idPhantom);
                objSub.Child_Platform_SKU_Number__c = objPlatformSub.Platform_SKU_Number__c ;
                objSub.Platform_Subscription__c = objPlatformSub.id;
                if(objPlatformSub.Created_via_Early_Renewal__c){
                    objSub.SBQQ__SubscriptionStartDate__c = objPlatformSub.SBQQ__SubscriptionStartDate__c;
                    objSub.SBQQ__SubscriptionEndDate__c = objPlatformSub.SBQQ__SubscriptionEndDate__c;
                }
                listSubsToUpdate.add(objSub);
            }
           
            Map<Id,SBQQ__Subscription__c>  mapRevisedSubs = new Map<Id,SBQQ__Subscription__C>([SELECT ID,SBQQ__RevisedSubscription__c,Updated_MRR__c,Upgraded_Quantity__c,Upgraded_ACV__c,SBQQ__RenewalQuantity__c,Finance_MRR__c,ACV_New__c FROM SBQQ__Subscription__c where SBQQ__RevisedSubscription__c IN: mapRevisedSubscriptionToNew.keyset() AND SBQQ__TerminatedDate__c = NULL]);
            Map<Id,SBQQ__Subscription__c> mapUpdatedSubs = new Map<id,SBQQ__Subscription__c>();
            
            for(SBQQ__Subscription__c objSub : mapRevisedSubs.values()){
                SBQQ__Subscription__c objRevisedSub = mapUpdatedSubs.containsKey(objSub.SBQQ__RevisedSubscription__c) ? mapUpdatedSubs.get(objSub.SBQQ__RevisedSubscription__c) : new SBQQ__Subscription__c(id = objSub.SBQQ__RevisedSubscription__c,Updated_MRR__c=0,Upgraded_Quantity__c=0,Upgraded_ACV__c=0); 
                
                objRevisedSub.Updated_MRR__c = objRevisedSub.Updated_MRR__c + (objSub.Finance_MRR__c!=null ? objSub.Finance_MRR__c : 0);
                objRevisedSub.Upgraded_Quantity__c = objRevisedSub.Upgraded_Quantity__c + (objSub.SBQQ__RenewalQuantity__c!=null ? objSub.SBQQ__RenewalQuantity__c : 0);
                objRevisedSub.Upgraded_ACV__c = objRevisedSub.Upgraded_ACV__c + (objSub.ACV_New__c	!=null ? objSub.ACV_New__c : 0); //IBA-3271
                mapUpdatedSubs.put(objRevisedSub.id,objRevisedSub);
            }
            system.debug('listSubsToUpdate..'+listSubsToUpdate);
            /*if(!mapUpdatedSubs.isEmpty()){
                update mapUpdatedSubs.values();
                system.debug('listSubsToUpdate udpated..'+listSubsToUpdate);
            }*/
            if(!listSubsToUpdate.isEmpty() || !mapUpdatedSubs.isEmpty()){
                List<SBQQ__Subscription__c> obj = new List<SBQQ__Subscription__c>();
                system.debug(mapUpdatedSubs.isEmpty());
                if(!mapUpdatedSubs.isEmpty()){
                    obj= mapUpdatedSubs.values();
                 }
                 obj.addAll(listSubsToUpdate);
                 update obj;
                system.debug('listSubsToUpdate udpated..'+listSubsToUpdate);
            }               
        }
    }
    
    public static void setRequiredByLookup(List<SBQQ__Subscription__c> newList){
        for(SBQQ__Subscription__c objSub: newList){
            if(objSub.SBQQ__RequiredById__c!=null && objSub.Required_By_Lookup__c==null){
                objSub.Required_By_Lookup__c = objSub.SBQQ__RequiredById__c;
            }
            //Logic to populate Subscription Line Status
            if(objSub.SBQQ__TerminatedDate__c!=null){
                objSub.Subscription_Line_Status__c= 'Cancelled';
            }else if(objSub.SBQQ__RenewedDate__c!=null){
                objSub.Subscription_Line_Status__c= 'Renewed';
            }else{
                objSub.Subscription_Line_Status__c= 'New';
            }
        }
    }
    public static void updateZPAEndDate(List<SBQQ__Subscription__c> newList, Map<Id,SBQQ__Subscription__c> oldMap, Boolean isInsert){
        Set<String> ZPASkuCodes = new Set<String>();
        Set<Id> accIds = new Set<Id>();
        List<Account> accUpdateList = new List<Account>();
        Map<Id,SBQQ__Subscription__C> accSubscriptionsMap = new Map<Id,SBQQ__Subscription__C>();
        ZPASkuCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZPA_Contract_Date').SKU_Codes__c.split(';'));
        Map<Id,Product2> productMap = new Map<Id,Product2>([SELECT Id FROM Product2 WHERE productcode IN : ZPASkuCodes]);
        try{
        for(SBQQ__Subscription__C sub : newList){
            if(productMap != NULL && productMap.containsKey(sub.SBQQ__Product__c) && isInsert){
                accIds.add(sub.SBQQ__Account__c);    
            }
            if(!isInsert && productMap != NULL && productMap.containsKey(sub.SBQQ__Product__c) && (sub.SBQQ__EndDate__c != oldMap.get(sub.Id).SBQQ__EndDate__c)){
                accIds.add(sub.SBQQ__Account__c);
            }
        }
        if(!accIds.isEmpty() && accIds != NULL){
                for(SBQQ__Subscription__c eachSub : [SELECT ID,SBQQ__EndDate__c,SBQQ__Account__c 
                                                    FROM SBQQ__Subscription__c 
                                                    WHERE SBQQ__Product__c IN : productMap.keySet() 
                                                    AND SBQQ__Account__c IN : accIds]){
                    if(!accSubscriptionsMap.containsKey(eachSub.SBQQ__Account__c)){
                        accSubscriptionsMap.put(eachSub.SBQQ__Account__c,eachSub);    
                    }
                    else if(eachSub.SBQQ__EndDate__c != NULL && accSubscriptionsMap.get(eachSub.SBQQ__Account__c).SBQQ__EndDate__c != NULL && 
                            accSubscriptionsMap.get(eachSub.SBQQ__Account__c).SBQQ__EndDate__c < eachSub.SBQQ__EndDate__c){
                        accSubscriptionsMap.put(eachSub.SBQQ__Account__c,eachSub);                       
                    }                                       
                }
            }
            if(!accSubscriptionsMap.isEmpty() && accSubscriptionsMap != NULL){
                for(Id accId : accSubscriptionsMap.keySet()){
                    Account acc = new Account(Id=accId);
                    if(accSubscriptionsMap.get(accId).SBQQ__EndDate__c != NULL){
                        acc.Platform_Subscription_End_Date_ZPA__c = accSubscriptionsMap.get(accId).SBQQ__EndDate__c;
                        accUpdateList.add(acc);
                    }
                }    
            }
            if(!accUpdateList.isempty() && accUpdateList != NULL){
                update accUpdateList;
            }
        }
        Catch(Exception exe){
            system.debug('***exe**');
        } 
    }   
    public static void updateZIAEndDate(List<SBQQ__Subscription__c> newList, Map<Id,SBQQ__Subscription__c> oldMap, Boolean isInsert){
        Set<String> ZIASkuCodes = new Set<String>();
        Set<Id> accIds = new Set<Id>();
        List<Account> accUpdateList = new List<Account>();
        Map<Id,SBQQ__Subscription__C> accSubscriptionsMap = new Map<Id,SBQQ__Subscription__C>();
        ZIASkuCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZIA_Contract_Date').SKU_Codes__c.split(';'));
        ZIASkuCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZIA_Contract_Date1').SKU_Codes__c.split(';'));
        Map<Id,Product2> productMap = new Map<Id,Product2>([SELECT Id FROM Product2 WHERE productcode IN : ZIASkuCodes]);
        try{
        for(SBQQ__Subscription__C sub : newList){
            if(productMap != NULL && productMap.containsKey(sub.SBQQ__Product__c) && isInsert){
                accIds.add(sub.SBQQ__Account__c);    
            }
            if(!isInsert && productMap != NULL && productMap.containsKey(sub.SBQQ__Product__c) && (sub.SBQQ__EndDate__c != oldMap.get(sub.Id).SBQQ__EndDate__c)){
                accIds.add(sub.SBQQ__Account__c);
            }
        }
        if(!accIds.isEmpty() && accIds != NULL){
                for(SBQQ__Subscription__c eachSub : [SELECT ID,SBQQ__EndDate__c,SBQQ__Account__c 
                                                    FROM SBQQ__Subscription__c 
                                                    WHERE SBQQ__Product__c IN : productMap.keySet() 
                                                    AND SBQQ__Account__c IN : accIds]){
                    if(!accSubscriptionsMap.containsKey(eachSub.SBQQ__Account__c)){
                        accSubscriptionsMap.put(eachSub.SBQQ__Account__c,eachSub);    
                    }
                    else if(eachSub.SBQQ__EndDate__c != NULL && accSubscriptionsMap.get(eachSub.SBQQ__Account__c).SBQQ__EndDate__c != NULL && 
                            accSubscriptionsMap.get(eachSub.SBQQ__Account__c).SBQQ__EndDate__c < eachSub.SBQQ__EndDate__c){
                        accSubscriptionsMap.put(eachSub.SBQQ__Account__c,eachSub);                       
                    }                                       
                }
            }
            if(!accSubscriptionsMap.isEmpty() && accSubscriptionsMap != NULL){
                for(Id accId : accSubscriptionsMap.keySet()){
                    Account acc = new Account(Id=accId);
                    if(accSubscriptionsMap.get(accId).SBQQ__EndDate__c != NULL){
                        acc.APTS_Platform_Subscription_End_Date__c = accSubscriptionsMap.get(accId).SBQQ__EndDate__c;
                        accUpdateList.add(acc);
                    }
                }    
            }
            if(!accUpdateList.isempty() && accUpdateList != NULL){
                update accUpdateList;
            }
        }
        Catch(Exception exe){
            system.debug('***exe**');
        }     
    }
    public static void updateNoOfSubscriptions(List<SBQQ__Subscription__c> newList, Map<Id,SBQQ__Subscription__c> oldMap, Boolean isInsert){
        set<Id> contractIds = new set<Id>();
        Map<Id,Integer> mapOfContract = new Map<Id, Integer>();
        List<Contract> conList = new List<Contract>();
        for(SBQQ__Subscription__c sub : newList){
        	if(isInsert){
            	contractIds.add(sub.SBQQ__Contract__c);
        	}
        	else if(sub.SBQQ__Contract__c != oldMap.get(sub.Id).SBQQ__Contract__c){
            	contractIds.add(sub.SBQQ__Contract__c);
                contractIds.add(oldMap.get(sub.Id).SBQQ__Contract__c);
        	}    
        }
        if(!contractIds.isEmpty() && contractIds != NULL){
        	List<SBQQ__Subscription__c> subList = [SELECT Id,SBQQ__Product__r.SBQQ__SubscriptionType__c,SBQQ__Contract__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN : contractIds AND SBQQ__Product__r.SBQQ__SubscriptionType__c = 'Renewable'];
            if(!subList.isEmpty() && subList != NULL){
           		for(SBQQ__Subscription__c sub : subList){
                    if(!mapOfContract.containsKey(sub.SBQQ__Contract__c)){
                    	mapOfContract.put(sub.SBQQ__Contract__c, 1);    
                    }
                    else{
                    	integer subNum = mapOfContract.get(sub.SBQQ__Contract__c);
                        mapOfContract.put(sub.SBQQ__Contract__c,subNum+1);
                    }
            	}    
            }
            if(!mapOfContract.keyset().isEmpty() && mapOfContract != NULL){
                for(id conId : mapOfContract.keyset()){
                	contract con = new contract(Id = conId);
                    con.Number_of_renewable_subscriptions__c = mapOfContract.get(conId);
                    conList.add(con);
                }
                if(!test.isRunningTest()){
                	update conList;    
                } 
            }    
        }
    } 
}