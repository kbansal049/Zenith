/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-08-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class extendLinesController {
    @AuraEnabled
    public static QuoteLineWrapper getAllProducts(String QuoteId){
        try {
            Boolean showAllRamps = false;
            /*String phantomId;
            List<SBQQ__Subscription__c> subLineList = new List<SBQQ__Subscription__c>();
            List<SBQQ__QuoteLine__c> rampedList = new List<SBQQ__QuoteLine__c>();
            List<SBQQ__QuoteLine__c> finalGetProducts = new List<SBQQ__QuoteLine__c>();*/
            List<SBQQ__QuoteLine__c> qliList =[SELECT Id,Source_for_Custom_Renewal__c,is_Extended__c,SBQQ__DynamicOptionId__c,Is_Ramped__c,SBQQ__Product__r.Id,SBQQ__ProductName__c,SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__Product__r.ProductCode, SBQQ__Product__r.Product_Family__c,
                                                SBQQ__Product__r.SBQQ__DefaultQuantity__c,Edition_Quantity__c,SBQQ__Quote__r.Name, SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c,
                                                SBQQ__NetPrice__c, Ramp_Label__c,SBQQ__ListPrice__c,SBQQ__Quantity__c,SBQQ__StartDate__c,SBQQ__Existing__c, SBQQ__EndDate__c,SBQQ__SubscriptionTerm__c, SBQQ__RequiredBy__c,SBQQ__ProductSubscriptionType__c,
                                                (SELECT Id,is_Extended__c,Source_for_Custom_Renewal__c,Ramp_Label__c,SBQQ__Product__r.Id,SBQQ__ProductName__c,SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__Product__r.ProductCode, SBQQ__Product__r.Product_Family__c,SBQQ__Product__r.SBQQ__DefaultQuantity__c,
                                                SBQQ__Quote__r.Name,SBQQ__Existing__c, SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c,SBQQ__NetPrice__c, SBQQ__ListPrice__c,SBQQ__Quantity__c,Edition_Quantity__c,SBQQ__StartDate__c, 
                                                SBQQ__EndDate__c,SBQQ__SubscriptionTerm__c, SBQQ__RequiredBy__c,SBQQ__DynamicOptionId__c,Is_Ramped__c,Show_Ramp__c from SBQQ__Quote_Lines__r WHERE Show_Ramp__c=false and Source_for_Custom_Renewal__c=true ORDER BY SBQQ__Number__c ASC) 
                                                FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:QuoteId and SBQQ__RequiredBy__c = null and SBQQ__ProductSubscriptionType__c='Renewable' and SBQQ__Existing__c = true WITH SECURITY_ENFORCED];   
            SBQQ__Quote__c quoteObj =[SELECT Id,Name,SBQQ__StartDate__c,SBQQ__EndDate__c FROM SBQQ__Quote__c WHERE Id=:QuoteId WITH SECURITY_ENFORCED];
            /*for(SBQQ__QuoteLine__c phantomLine : [SELECT id, Is_Ramped__c,SBQQ__RequiredBy__c,SBQQ__ProductCode__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c =null AND SBQQ__Quote__c=:QuoteId AND SBQQ__ProductCode__c='' WITH SECURITY_ENFORCED]){
                if(phantomLine.Is_Ramped__c == false){
                    showAllRamps = true;
                }
                phantomId = phantomLine.Id;
            }
            if(showAllRamps == false){
                for(SBQQ__QuoteLine__c childLine : [SELECT id,SBQQ__Number__c,SBQQ__Quantity__c,Re_Ramped__c,SBQQ__StartDate__c, SBQQ__EndDate__c, Is_Ramped__c,SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c !=null AND SBQQ__Quote__c=:QuoteId ORDER BY SBQQ__Number__c ASC]){
                    if(childLine.Re_Ramped__c == true){
                        showAllRamps = true;
                    }
                }
            }
            String qliName = '';
            if(showAllRamps == false){
                for(SBQQ__QuoteLine__c childLine : [SELECT id,Ramp_Label__c,SBQQ__Number__c,SBQQ__ProductName__c,SBQQ__ProductCode__c,SBQQ__Quantity__c,Re_Ramped__c,SBQQ__StartDate__c, SBQQ__EndDate__c, Is_Ramped__c,SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c=:phantomId AND SBQQ__Quote__c=:QuoteId ORDER BY Ramp_Label__c ASC]){
                    if(String.isBlank(qliName)){
                        qliName = childLine.SBQQ__ProductName__c;
                    }
                    if(childLine.SBQQ__ProductName__c == qliName){
                        rampedList.add(childLine);
                    }
                }
            }*/
            QuoteLineWrapper qliWrap = new QuoteLineWrapper(quoteObj, qliList, new List < SBQQ__Subscription__c > (), new List < SBQQ__QuoteLine__c > (), showAllRamps);
            return qliWrap;
        } catch (Exception e) {
            system.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static QuoteLineWrapper getAllActiveSubscriptions(String quoteId){
        List<SBQQ__Subscription__c> subLineList = new List<SBQQ__Subscription__c>();
        List<SBQQ__QuoteLine__c> qliList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> rampedList = new List<SBQQ__QuoteLine__c>();
        Boolean showAllRamps = false;
        SBQQ__Quote__c quoteObj;
        try {
            //if(String.isNotBlank(quoteId)){
                quoteObj = [Select id,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.AccountId,SBQQ__StartDate__c,SBQQ__EndDate__c,Name from SBQQ__Quote__c where Id=:quoteId WITH SECURITY_ENFORCED];
                subLineList =[SELECT Id,SBQQ__ProductSubscriptionType__c,SBQQ__Contract__c,Required_By_Lookup__c,SBQQ__Contract__r.ContractNumber,SBQQ__ContractNumber__c,SBQQ__Contract__r.AccountId,SBQQ__Contract__r.Status,SBQQ__RenewalQuantity__c,SBQQ__TerminatedDate__c,Product_Code__c,SBQQ__ProductName__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Number__c,
                                                (SELECT Id,SBQQ__ProductSubscriptionType__c,SBQQ__Contract__c,Required_By_Lookup__c,SBQQ__Contract__r.ContractNumber,SBQQ__ContractNumber__c,SBQQ__Contract__r.AccountId,SBQQ__Contract__r.Status,SBQQ__RenewalQuantity__c,SBQQ__TerminatedDate__c,Product_Code__c,SBQQ__ProductName__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Number__c from ChildSubscriptions__r WHERE SBQQ__RenewalQuantity__c > 0 and SBQQ__TerminatedDate__c = null AND SBQQ__ProductSubscriptionType__c = 'Renewable' and Product_code__c !='ZCES-SUP-PREM-SP' ORDER BY SBQQ__Number__c ASC) from SBQQ__Subscription__c WHERE SBQQ__Contract__r.AccountId=:quoteObj.SBQQ__Opportunity2__r.AccountId AND Required_By_Lookup__c = null AND SBQQ__Contract__r.Status='Activated' AND SBQQ__RenewalQuantity__c > 0 and SBQQ__TerminatedDate__c = null AND SBQQ__ProductSubscriptionType__c = 'Renewable' AND Product_Code__c != 'ZCES-SUP-PREM' WITH SECURITY_ENFORCED ORDER BY SBQQ__Contract__r.ContractNumber,SBQQ__Number__c ASC];
                                                /*FROM Contract WHERE AccountId =:currQuote.SBQQ__Opportunity2__r.AccountId and /*SBQQ__Opportunity__c =: currQuote.SBQQ__Opportunity2__c and Status='Activated' ORDER BY ContractNumber ASC]; */                                                
            //} 
            QuoteLineWrapper qliWrap = new QuoteLineWrapper(quoteObj,qliList,subLineList,rampedList,showAllRamps);                                                                  
            return qliWrap;      
        } catch (Exception e) {
            system.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getExtendedLinesForAddOn(String quoteId,String selectedAddOn){
        List<SBQQ__QuoteLine__c> qliList = new List<SBQQ__QuoteLine__c>();
        try {
            //if(String.isNotBlank(quoteId)){
                system.debug('selectedAddOn'+selectedAddOn);
                SBQQ__QuoteLine__c currentQuoteLine = [Select id,SBQQ__RequiredBy__c,Source_for_Custom_Renewal__c,is_Extended__c,SBQQ__Product__c,SBQQ__ProductName__c,SBQQ__ProductCode__c FROM SBQQ__QuoteLine__c WHERE Id =:selectedAddOn WITH SECURITY_ENFORCED];
                qliList =[SELECT Id,Source_for_Custom_Renewal__c,is_Extended__c,Is_Platform_SKU__c,SBQQ__DynamicOptionId__c,Is_Ramped__c,SBQQ__Product__r.Id,SBQQ__ProductName__c,SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__Product__r.ProductCode, SBQQ__Product__r.Product_Family__c,
                                                SBQQ__Product__r.SBQQ__DefaultQuantity__c,Edition_Quantity__c,SBQQ__Quote__r.Name, SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c,
                                                SBQQ__NetPrice__c, Ramp_Label__c,SBQQ__ListPrice__c,SBQQ__Quantity__c,SBQQ__StartDate__c,SBQQ__Existing__c, SBQQ__EndDate__c,SBQQ__SubscriptionTerm__c, SBQQ__RequiredBy__c,SBQQ__ProductSubscriptionType__c
                                                FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quoteId and SBQQ__RequiredBy__c =: currentQuoteLine.SBQQ__RequiredBy__c and (SBQQ__ProductCode__c=:currentQuoteLine.SBQQ__ProductCode__c or Is_Platform_SKU__c = true) WITH SECURITY_ENFORCED ];
                                                /*FROM Contract WHERE AccountId =:currQuote.SBQQ__Opportunity2__r.AccountId and /*SBQQ__Opportunity__c =: currQuote.SBQQ__Opportunity2__c and Status='Activated' ORDER BY ContractNumber ASC]; */                                                
            //} 
            //QuoteLineWrapper qliWrap = new QuoteLineWrapper(quoteObj,qliList,subLineList,rampedList,showAllRamps);                                                                  
            return qliList;      
        } catch (Exception e) {
            system.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String createQuoteLinesFromSubscription(String QuoteId, List<SBQQ__Subscription__c> subscriptionLineList){
        String strMsg = 'success';
        map<String,set<Id>> contractIdVsPhantomLineMap = new map<String,set<Id>>();
        map<String,Boolean> contractIdVsIsPremiumSupportMap = new map<String,Boolean>();
        map<Id,SBQQ__QuoteLine__c> subsLineVsQuoteLineMap = new map<Id,SBQQ__QuoteLine__c>();
        set<Id> phantomSet = new set<Id>();
        Integer counter=0;
        List<SBQQ__QuoteLine__c> linesToCreate = new List<SBQQ__QuoteLine__c>();
        try{
            SBQQ__Quote__c currQuote = [Select id,SBQQ__StartDate__c,SBQQ__EndDate__c from SBQQ__Quote__c where id =: QuoteId WITH SECURITY_ENFORCED];
            for(SBQQ__Subscription__c sub : subscriptionLineList){
                String phantomId = sub.Required_By_Lookup__c != null ? sub.Required_By_Lookup__c : sub.Id;
                if(contractIdVsPhantomLineMap.containsKey(sub.SBQQ__ContractNumber__c)){
                    contractIdVsPhantomLineMap.get(sub.SBQQ__ContractNumber__c).add(phantomId);
                }else{
                    contractIdVsPhantomLineMap.put(sub.SBQQ__ContractNumber__c,new set<Id>{phantomId});
                }
                phantomSet.add(phantomId);
            }
            if(!contractIdVsPhantomLineMap.isEmpty()){
                for(SBQQ__Subscription__c sub : [Select id,Product_Code__c,SBQQ__Contract__c,SBQQ__ContractNumber__c from SBQQ__Subscription__c where SBQQ__ContractNumber__c IN :contractIdVsPhantomLineMap.keyset() and Product_Code__c ='ZCES-SUP-PREM' WITH SECURITY_ENFORCED]){
                    contractIdVsIsPremiumSupportMap.put(sub.SBQQ__ContractNumber__c,true);
                }
                for(SBQQ__QuoteLine__c quoteLine : [Select id,Is_Platform_SKU__c,SBQQ__Number__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:currQuote.Id WITH SECURITY_ENFORCED order by SBQQ__Number__c DESC LIMIT 1]){
                    counter=Integer.valueOf(quoteLine.SBQQ__Number__c);
                }
                for(SBQQ__Subscription__c sub : [Select id,SBQQ__StartDate__c,TAM_Coverage__c, Support_Type__c, Country_Language__c,SBQQ__EndDate__c,Product_Code__c,SBQQ__Contract__c,SBQQ__ContractNumber__c,SBQQ__Bundle__c,SBQQ__DynamicOptionId__c,SBQQ__OptionLevel__c,SBQQ__OptionType__c,SBQQ__PricingMethod__c,SBQQ__ProductOption__c,SBQQ__ProductSubscriptionType__c,SBQQ__Product__c,SBQQ__Quantity__c,Platform_Subscription__c,Child_Platform_SKU_Number__c,Minimum_Support_Type_ACV__c from SBQQ__Subscription__c where Id IN :phantomSet /*or Required_By_Lookup__c IN :contractIdVsPhantomLineMap.values()*/ or (Product_Code__c ='ZCES-SUP-PREM' and SBQQ__ContractNumber__c IN: contractIdVsIsPremiumSupportMap.keySet() AND SBQQ__RenewalQuantity__c > 0) WITH SECURITY_ENFORCED]){
                    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                    //IBA 7337 
                    quoteLine.TAM_Coverage__c = sub.TAM_Coverage__c;
                    quoteLine.Support_Type__c = sub.Support_Type__c;
                    quoteLine.Minimum_Support_Type_ACV__c = sub.Minimum_Support_Type_ACV__c;
                    quoteLine.Country_Language__c = sub.Country_Language__c; //IBA 7337
                    quoteLine.SBQQ__Bundle__c = sub.SBQQ__Bundle__c;
                    quoteLine.SBQQ__DynamicOptionId__c = sub.SBQQ__DynamicOptionId__c;
                    quoteLine.SBQQ__EndDate__c = currQuote.SBQQ__EndDate__c;
                    quoteLine.SBQQ__Number__c=counter+1;
                    quoteLine.SBQQ__OptionLevel__c = sub.SBQQ__OptionLevel__c;
                    quoteLine.SBQQ__OptionType__c = sub.SBQQ__OptionType__c;
                    quoteLine.SBQQ__PricingMethod__c = sub.SBQQ__PricingMethod__c;
                    quoteLine.SBQQ__ProductOption__c = sub.SBQQ__ProductOption__c;
                    quoteLine.SBQQ__ProductSubscriptionType__c = sub.SBQQ__ProductSubscriptionType__c;
                    quoteLine.SBQQ__Product__c = sub.SBQQ__Product__c;
                    quoteLine.SBQQ__Quantity__c = sub.SBQQ__Quantity__c;
                    quoteLine.SBQQ__Quote__c = currQuote.Id;
                    quoteLine.SBQQ__RenewedSubscription__c = sub.Id;
                    quoteLine.SBQQ__RequiredBy__c = null;
                    Date dt = sub.SBQQ__EndDate__c.addDays(1);
                    quoteLine.SBQQ__StartDate__c = dt;
                    quoteLine.SBQQ__SubscriptionType__c = sub.SBQQ__ProductSubscriptionType__c;
                    quoteLine.Platform_Subscription__c = sub.Platform_Subscription__c;
                    quoteLine.Child_Platform_SKU_Number__c = sub.Child_Platform_SKU_Number__c;
                    
                    linesToCreate.add(quoteLine);
                    counter=counter+1;
                }
                if(!linesToCreate.isEmpty()){
                    insert linesToCreate;
                }
                for(SBQQ__QuoteLine__c quoteLine : [Select id,SBQQ__Number__c,SBQQ__Product__c,SBQQ__Product__r.ProductCode,SBQQ__RenewedSubscription__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:currQuote.Id and SBQQ__RenewedSubscription__c != null and SBQQ__Product__r.ProductCode !='ZCES-SUP-PREM' and SBQQ__RenewedSubscription__c IN : phantomSet WITH SECURITY_ENFORCED]){
                    subsLineVsQuoteLineMap.put(quoteLine.SBQQ__RenewedSubscription__c,quoteLine);
                }
                system.debug('subsLineVsQuoteLineIdMap'+subsLineVsQuoteLineMap);
                if(!subsLineVsQuoteLineMap.isEmpty()){
                    linesToCreate = new List<SBQQ__QuoteLine__c>();
                    system.debug('Inside the sub');
                    for(SBQQ__Subscription__c sub : [Select id,SBQQ__StartDate__c,SBQQ__EndDate__c,Required_By_Lookup__c,Product_Code__c,SBQQ__Contract__c,SBQQ__Bundle__c,SBQQ__DynamicOptionId__c,SBQQ__OptionLevel__c,SBQQ__OptionType__c,SBQQ__PricingMethod__c,SBQQ__ProductOption__c,SBQQ__ProductSubscriptionType__c,SBQQ__Product__c,SBQQ__Quantity__c,Upgraded_Quantity__c,SBQQ__RenewalProductOptionId__c,SBQQ__RenewalProductId__c from SBQQ__Subscription__c where Required_By_Lookup__c IN :subsLineVsQuoteLineMap.keySet() AND SBQQ__RevisedSubscription__c=NULL and SBQQ__RenewalQuantity__c > 0 WITH SECURITY_ENFORCED]){
                        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                        quoteLine.SBQQ__Bundle__c = sub.SBQQ__Bundle__c;
                        quoteLine.SBQQ__DynamicOptionId__c = sub.SBQQ__DynamicOptionId__c;
                        quoteLine.SBQQ__EndDate__c = currQuote.SBQQ__EndDate__c;
                        system.debug( subsLineVsQuoteLineMap.get(sub.Required_By_Lookup__c).SBQQ__Number__c);
                        quoteLine.SBQQ__Number__c = subsLineVsQuoteLineMap.get(sub.Required_By_Lookup__c).SBQQ__Number__c;
                        quoteLine.SBQQ__OptionLevel__c = sub.SBQQ__OptionLevel__c;
                        quoteLine.SBQQ__OptionType__c = sub.SBQQ__OptionType__c;
                        quoteLine.SBQQ__PricingMethod__c = sub.SBQQ__PricingMethod__c;
                        quoteLine.SBQQ__ProductOption__c = sub.SBQQ__ProductOption__c;
                        quoteLine.SBQQ__ProductSubscriptionType__c = sub.SBQQ__ProductSubscriptionType__c;
                        quoteLine.SBQQ__Product__c = sub.SBQQ__Product__c;
                        quoteLine.SBQQ__Quantity__c = sub.SBQQ__Quantity__c;
                        if(sub.Upgraded_Quantity__c!=null){
                            quoteLine.SBQQ__Quantity__c += sub.Upgraded_Quantity__c;
                        }
                        quoteLine.SBQQ__Quote__c = currQuote.Id;
                        quoteLine.SBQQ__RenewedSubscription__c = sub.Id;
                        quoteLine.SBQQ__RequiredBy__c = subsLineVsQuoteLineMap.get(sub.Required_By_Lookup__c).Id;
                        quoteLine.Required_By_Lookup__c = sub.Required_By_Lookup__c;
                        Date dt = sub.SBQQ__EndDate__c.addDays(1);
                        quoteLine.SBQQ__StartDate__c = dt;
                        quoteLine.SBQQ__SubscriptionType__c = sub.SBQQ__ProductSubscriptionType__c;
                        if(sub.SBQQ__Product__c != sub.SBQQ__RenewalProductId__c){
                            quoteLine.SBQQ__DynamicOptionId__c = null;
                            quoteLine.SBQQ__ProductOption__c =sub.SBQQ__RenewalProductOptionId__c;
                            quoteline.SBQQ__RequiredBy__c =sub.SBQQ__RenewalProductOptionId__c!=null?quoteLine.SBQQ__RequiredBy__c:null;
                            quoteline.SBQQ__Product__c = sub.SBQQ__RenewalProductId__c;
                        }
                        linesToCreate.add(quoteLine);
                    }
                    if(!linesToCreate.isEmpty()){
                        insert linesToCreate;
                    }
                }
                return strMsg;
            }
        }catch(Exception ex){
            system.debug('error - failed'+ex.getMessage());
            strMsg = ex.getMessage();
            return strMsg;
        }
        return strMsg;
    }
    @AuraEnabled
    public static String createQuoteLines(String QuoteId, List<String> QuoteLineIds,String segments,String uniqueRampKey,Boolean isOriginPhantom, Boolean isFromRampAll,String selectedAddOn){
        String strMsg = 'success';
        try {
            List<SegmentWrapper> wrapperLines = (List<SegmentWrapper>)JSON.deserialize(segments, List<SegmentWrapper>.class);
            system.debug('Check Values'+wrapperLines+'uniqueRampKey'+uniqueRampKey+'QuoteLineIds'+QuoteLineIds+'segments'+segments+'blank'+String.isBlank(uniqueRampKey)+'blank segment'+ String.isBlank(segments));
            /*Map<Id,List<SBQQ__QuoteLine__c>> subQLIMap =  new Map<Id,List<SBQQ__QuoteLine__c>>();
            Map<Id,SBQQ__QuoteLine__c> mainQLIMap =  new Map<Id,SBQQ__QuoteLine__c>();
            
            Map<Id,SBQQ__QuoteLine__c> getAllQuoteLines = new Map<Id,SBQQ__QuoteLine__c>();
            if(String.isNotBlank(uniqueRampKey) && !isOriginPhantom){
                getAllQuoteLines = new Map<Id,SBQQ__QuoteLine__c>([Select Id,SBQQ__Product__r.Id,Edition_Quantity__c,SBQQ__Product__r.Name,SBQQ__RequiredBy__c,Is_Ramped__c,Show_Ramp__c,Ramp_Label__c,SBQQ__Number__c,SBQQ__Quote__c,SBQQ__ProductName__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: QuoteId AND (Id IN:QuoteLineIds OR Ramp_UniqueKey__c=:uniqueRampKey )]);
            }
            else {
                getAllQuoteLines = new Map<Id,SBQQ__QuoteLine__c>([Select Id,SBQQ__Product__r.Id,Edition_Quantity__c,SBQQ__Product__r.Name,SBQQ__RequiredBy__c,Is_Ramped__c,Show_Ramp__c,Ramp_Label__c,SBQQ__Number__c,SBQQ__Quote__c,SBQQ__ProductName__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: QuoteId AND (Id=:QuoteLineIds OR SBQQ__RequiredBy__c=:QuoteLineIds )]);
            }
            system.debug(' getAllQuoteLines.values()::'+ getAllQuoteLines.values());
            List<SBQQ__QuoteLine__c> finalQuoteLines = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c qli : getAllQuoteLines.values()){
                if(qli.SBQQ__RequiredBy__c != null){
                    if(subQLIMap.containsKey(qli.SBQQ__RequiredBy__c)){
                        subQLIMap.get(qli.SBQQ__RequiredBy__c).add(qli);
                    }
                    else{
                        subQLIMap.put(qli.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c> {qli});
                    }
                    if(String.isNotBlank(uniqueRampKey) && !isOriginPhantom){
                        finalQuoteLines.add(qli);
                    }
                    system.debug('subQLIMap::'+subQLIMap);
                }
                else{
                if(!mainQLIMap.containsKey(qli.Id)){
                        mainQLIMap.put(qli.Id,qli);
                }
                system.debug('mainQLIMap::'+mainQLIMap);
                }
            }
            if(isOriginPhantom){
                for(Id qlis : mainQLIMap.keyset()){
                    if(subQLIMap.containsKey(qlis)){
                        List<SBQQ__QuoteLine__c> allQl= subQLIMap.get(qlis);
                        finalQuoteLines.addAll(subQLIMap.get(qlis));
                    }
                    else{
                        finalQuoteLines.add(mainQLIMap.get(qlis));
                    }
                }
            }
            set<Id> allQLIIds =  new set<Id>();
            Set<String> uniqueKeySet = new Set<String>();
            for(SBQQ__QuoteLine__c qliss : finalQuoteLines){
                system.debug('QuoteLineId '+qliss.Id +' '+ qliss.SBQQ__Product__r.Name + ' Required By '+ qliss.SBQQ__RequiredBy__c);      
                allQLIIds.add(qliss.Id);
            }
            system.debug('allQLIIds::'+allQLIIds);*/

            List<SBQQ__QuoteLine__c> toCreate = new List<SBQQ__QuoteLine__c>();

            //SBQQ__QuoteLine__c currentQuoteLine = [Select id,SBQQ__RequiredBy__c,Source_for_Custom_Renewal__c,is_Extended__c,SBQQ__Product__c,SBQQ__ProductName__c,SBQQ__ProductCode__c FROM SBQQ__QuoteLine__c WHERE Id =:selectedAddOn];
            Map<Id,SBQQ__QuoteLine__c> qliMap = new Map<Id,SBQQ__QuoteLine__c>();
            
            //for(SBQQ__QuoteLine__c q : qliList){ 
                String soql = extendLinesController.cloneRecordQuery('SBQQ__QuoteLine__c');
                soql+=':selectedAddOn';
            system.debug('Query' + soql);
            SBQQ__QuoteLine__c currentQuoteLine = Database.query(soql);
            qliMap=new Map<Id,SBQQ__QuoteLine__c>([SELECT Id,Source_for_Custom_Renewal__c,is_Extended__c,SBQQ__DynamicOptionId__c,Is_Ramped__c,SBQQ__Product__r.Id,SBQQ__ProductName__c,SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__Product__r.ProductCode, SBQQ__Product__r.Product_Family__c,
                                                SBQQ__Product__r.SBQQ__DefaultQuantity__c,Edition_Quantity__c,SBQQ__Quote__r.Name, SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__Quote__r.SBQQ__EndDate__c,
                                                SBQQ__NetPrice__c, Ramp_Label__c,SBQQ__ListPrice__c,SBQQ__Quantity__c,SBQQ__StartDate__c,SBQQ__Existing__c, SBQQ__EndDate__c,SBQQ__SubscriptionTerm__c, SBQQ__RequiredBy__c,SBQQ__ProductSubscriptionType__c
                                                FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:QuoteId and SBQQ__RequiredBy__c =: currentQuoteLine.SBQQ__RequiredBy__c and SBQQ__ProductCode__c=:currentQuoteLine.SBQQ__ProductCode__c WITH SECURITY_ENFORCED]);
            system.debug('qliMap'+qliMap);
                for(SegmentWrapper sw : wrapperLines){
                    system.debug('sw.sfdcId'+sw.sfdcId);
                    SBQQ__QuoteLine__c q1 = new SBQQ__QuoteLine__c();
                    if(sw.sfdcId != null && sw.sfdcId != ''){
                        q1.Id = sw.sfdcId;
                        q1.SBQQ__StartDate__c = date.valueOf(sw.StartDate);
                        q1.SBQQ__EndDate__c = date.valueOf(sw.EndDate);
                        q1.SBQQ__Quantity__c = Integer.valueOf(sw.Qty);
                        if(wrapperLines.size()>1){
                            q1.is_Extended__c = true;
                        }else{
                            q1.is_Extended__c = false;
                        }
                        toCreate.add(q1);
                    }else{
                        
                            system.debug('fresh ramp::');
                            q1 = currentQuoteLine.clone(false, true);
                            /*if(firstRamp==false){
                                q1.Id = currentQuoteLine.Id;
                                firstRamp= true;
                            }*/
                            // Commenting - 15 July
                           // q1.Ramp_Label__c = sw.Segment;
                            q1.SBQQ__Number__c=currentQuoteLine.SBQQ__Number__c;
                            system.debug('q1.SBQQ__Number__c::'+q1.SBQQ__Number__c);
                            q1.SBQQ__RequiredBy__c = currentQuoteLine.SBQQ__RequiredBy__c;
                           // q1.Is_Ramped__c=true;
                                                    
                            system.debug('q1::::::'+q1);
                            /*if(q1.Id!= null){
                                q1.Show_Ramp__c = false;
                                q1.is_Extended__c = true;
                            }else{*/
                                q1.is_Extended__c = true;
                                q1.SBQQ__SubscriptionTerm__c = null;
                                q1.SBQQ__RenewedSubscription__c = currentQuoteLine.SBQQ__UpgradedSubscription__c;
                                q1.SBQQ__UpgradedSubscription__c = null;
                                q1.SBQQ__Existing__c = false;
                           // }
                            system.debug('q.SBQQ__RequiredBy__c::'+currentQuoteLine.SBQQ__RequiredBy__c);
                            q1.SBQQ__StartDate__c = date.valueOf(sw.StartDate);
                            q1.SBQQ__EndDate__c = date.valueOf(sw.EndDate);
                            q1.SBQQ__Quantity__c = Integer.valueOf(sw.Qty);
                            q1.Edition_Quantity__c = currentQuoteLine.Edition_Quantity__c;
                            q1.SBQQ__OptionLevel__c = 1;
                            system.debug('q1 from first time click::'+q1);
                            toCreate.add(q1);
                        
                    }
                }
    
            if(!qliMap.isEmpty()){
                DELETE qliMap.values();
            }
            if(!toCreate.isEmpty()){

                UPSERT toCreate;
                return strMsg;  
            }
        } catch (Exception e) {
            strMsg = e.getMessage();
            return strMsg;
        }
        return strMsg;
    }

    public static string cloneRecordQuery(String objectName){
        String selects = '';
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable() || fd.getName() == 'SBQQ__ProductCode__c'){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
        }
        system.debug('SEL : '+selects + ' Object Name  : '+objectName);
        return 'SELECT Id,' + selects + ' FROM ' + objectName + ' Where Id = ';
    }

    public class SegmentWrapper{
        @AuraEnabled public String Segment;
        @AuraEnabled public String StartDate;
        @AuraEnabled public String EndDate;
        @AuraEnabled public String Qty;
        @AuraEnabled public Boolean Ramped;
        @AuraEnabled public String pCode;
        @AuraEnabled public String reqBy;
        @AuraEnabled public Boolean isPhantom;
        @AuraEnabled public String sfdcId;
        public SegmentWrapper(String Segment,String StartDate,String EndDate,String Qty,Boolean Ramped,String pCode,String reqBy,Boolean isPhantom,String sfdcId){
            this.Segment = Segment;
            this.StartDate = StartDate;
            this.EndDate = EndDate;
            this.Qty = Qty;
            this.Ramped = Ramped;
            this.pCode = pCode;
            this.reqBy = reqBy;
            this.isPhantom = isPhantom;
            this.sfdcId = sfdcId;
        }
    }

    public class QuoteLineWrapper{
        @AuraEnabled public SBQQ__Quote__c quoteObj;
        @AuraEnabled public List<SBQQ__QuoteLine__c> qliList;
        @AuraEnabled public List<SBQQ__Subscription__c> subLineList;
        @AuraEnabled public List<SBQQ__QuoteLine__c> rampedList;
        @AuraEnabled public Boolean showAllRamps;
        public QuoteLineWrapper(SBQQ__Quote__c quoteObj,List<SBQQ__QuoteLine__c> qliList,List<SBQQ__Subscription__c> subLineList,List<SBQQ__QuoteLine__c> rampedList,Boolean showAllRamps){
            this.quoteObj = quoteObj;
            this.qliList=qliList;
            this.subLineList=subLineList;
            this.rampedList=rampedList;
            this.showAllRamps=showAllRamps;
        }
    }
}