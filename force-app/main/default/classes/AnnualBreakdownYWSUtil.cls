/**
 * @description       : CR# 4269, Class to generate Annual Breakdown and YearWise Split
 * @author            : Ritesh kumar
 * @group             : 
 * @TestClass         : AnnualBreakdownYWSUtilTest 
 * @last modified on  : 25-May-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc 
**/
public class AnnualBreakdownYWSUtil {

    public static void generateAnnualBreakdownYWS(Set<Id> quoteIDs) {        
        System.debug('Inside generateAnnualBreakdownYWS');

        List<SBQQ__Quote__c> quoteList = [SELECT Id,Name,Is_Year_Wise_Split_Data_Incorrect__c,SBQQ__StartDate__c,SBQQ__EndDate__c,
                                            Year_1_Year_Value__c,Year_2_Year_Value__c,Year_3_Year_Value__c,Year_4_Year_Value__c,
                                            Year_5_Year_Value__c,Year_6_Year_Value__c,Year_7_Year_Value__c,Year_1_Subtotal__c, 
                                            Year_2_Subtotal__c,Year_3_Subtotal__c,Year_4_Subtotal__c,Year_5_Subtotal__c,Year_6_Subtotal__c, 
                                            Year_7_Subtotal__c,Year_Wise_Split_Total__c,SBQQ__Opportunity2__c,SBQQ__Account__c,Document_Type__c, 
                                            SBQQ__Partner__c,Bill_to__c,SBQQ__Distributor__c,SBQQ__SubscriptionTerm__c,Annual_Breakdown_Error__c
                                            FROM SBQQ__Quote__c WHERE Id IN :quoteIDs];

        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
        Map<Id, SBQQ__Quote__c> errorQuoteMap = new Map<Id, SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote: quoteList){
            if (quote.SBQQ__SubscriptionTerm__c != null) {
                quoteMap.put(quote.Id, quote);
            }
        }
        
        //Get Quote Extensions and reset its fields 
        Map<Id, Quote_Extension__c> quoteToExtensionMap = new Map<Id, Quote_Extension__c>();
        for (Quote_Extension__c quoteExtension : [SELECT Id,SBQQ_Quote__c FROM Quote_Extension__c WHERE SBQQ_Quote__c IN :quoteMap.keyset()]) {
            for (Integer i = 1; i <= 7; i++) {                       
                quoteExtension.put('Invoice_'+i+'_Total__c',0);                         
                quoteExtension.put('Year'+i+'_Start_Date__c',null);                         
                quoteExtension.put('Year'+i+'_End_Date__c',null);
            }
            quoteExtension.List_Price_Total__c = 0;
            quoteExtension.Net_Price_Total__c = 0;
            quoteToExtensionMap.put(quoteExtension.SBQQ_Quote__c, quoteExtension);
        }
        
        //Reset Quote fields 
        for (Id quoteId : quoteMap.keyset()) {
            SBQQ__Quote__c currentQuote = quoteMap.get(quoteId);
            for (Integer i = 1; i <= 7; i++) {                       
                currentQuote.put('Year_'+i+'_Subtotal__c',0);                         
                currentQuote.put('Year_'+i+'_List_Price_Subtotal__c',0);                         
                currentQuote.put('Year_'+i+'_Year_Value__c',null);
            }
            quoteMap.put(quoteId, currentQuote);
        }

        if(!quoteMap.isEmpty()){

            Map<Id,List<Date>> quoteToStartEndDateMap = new Map<Id,List<Date>>();
            Map<Id,Map<Date,Integer>> quoteStartDateToYearMap = new Map<Id,Map<Date,Integer>>();
            Map<Id,Map<Integer,Date>> quoteYearToStartDateMap = new Map<Id,Map<Integer,Date>>();
            Map<String, Year_Wise_Split__c> productToYWSMap = new Map<String, Year_Wise_Split__c>();
            Map<Id, Decimal> quoteToNetTotalMap = new Map<Id, Decimal>();
            Map<Id, Decimal> quoteToYearWiseSplitTotalMap = new Map<Id, Decimal>();
            Map<Id, Decimal> quoteToAnnualBreakdownTotalMap = new Map<Id, Decimal>();
            Map<Id, SBQQ__Quote__c> ywsTotalTCVMismatchQuotesMap = new Map<Id, SBQQ__Quote__c>();
            Integer maximumYear = 1;

            //Get the minimum start Date and Maximum end from quote
            for (AggregateResult result : [  SELECT SBQQ__Quote__c, MIN(SBQQ__StartDate__c) minStartDate, MAX(SBQQ__EndDate__c) maxEndDate 
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE SBQQ__Quote__c IN :quoteMap.keySet() AND SBQQ__Product__r.ProductCode != null 
                                                AND (SBQQ__NetTotal__c != 0 OR SBQQ__EffectiveQuantity__c != 0) GROUP BY SBQQ__Quote__c]) {
                quoteToStartEndDateMap.put((Id) result.get('SBQQ__Quote__c'), new List<Date>{ (Date) result.get('minStartDate'), (Date) result.get('maxEndDate')});
            }

            //Loop to create start date and year Map
            for (Id quoteId : quoteToStartEndDateMap.keySet()) {
                Date startDate = quoteToStartEndDateMap.get(quoteId)[0];
                Date endDate = quoteToStartEndDateMap.get(quoteId)[1];
                Integer year = 1;
                Map<Date,Integer> startDateToYearMap = new Map<Date,Integer>();
                Map<Integer,Date> yearTostartDateMap = new Map<Integer,Date>();
                while (startDate <= endDate) {
                    maximumYear = year;
                    startDateToYearMap.put(startDate,year);
                    yearTostartDateMap.put(year,startDate);
                    year++;
                    startDate = startDate.addYears(1);
                }
                quoteStartDateToYearMap.put(quoteId, startDateToYearMap);
                quoteYearToStartDateMap.put(quoteId, yearTostartDateMap);
            }

            Map<String, Date> productToStartDateMap = new Map<String, Date>();
            Map<String, Date> productToEndDateMap = new Map<String, Date>();
            Map<String, Integer> productToStartYearMap = new Map<String, Integer>();
            Map<String, Integer> productToEndYearMap = new Map<String, Integer>();
            Map<String, Integer> productToNoOfYearMap = new Map<String, Integer>();
            Map<String, Decimal> productYearWiseTermMap = new Map<String, Decimal>();
            Map<String, Decimal> productTotalTermMap = new Map<String, Decimal>();
            Map<String, Date> rampStartDateMap = new Map<String, Date>();
            Map<String, Decimal> rampTermMap = new Map<String, Decimal>();
            Map<String, Integer> lastRampMap = new Map<String, Integer>();
            for(SBQQ__QuoteLine__c quoteLine : [SELECT SBQQ__Quote__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c, Finance_Term__c,
                                                SBQQ__EffectiveQuantity__c,SBQQ__NetTotal__c,SBQQ__Product__c, Base_Extended_Price__c, Ramp_UniqueKey__c,
                                                Is_Ramped__c,Ramp_Label__c,SBQQ__ProductCode__c,SBQQ__SubscriptionType__c,SBQQ__Number__c,Last_Ramp_Quantity__c                                                
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE SBQQ__Quote__c IN :quoteMap.keySet() AND SBQQ__Product__r.ProductCode != null ORDER BY SBQQ__Number__c]){

                Date startDate = Date.valueOf(quoteLine.SBQQ__StartDate__c);
                Date endDate = Date.valueOf(quoteLine.SBQQ__EndDate__c);        
                
                startDate = startDate == null? Date.valueOf(quoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__StartDate__c) : startDate;
                endDate = endDate == null? Date.valueOf(quoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__EndDate__c) : endDate;

                String mapKey = quoteLine.SBQQ__Quote__c + quoteLine.SBQQ__ProductCode__c;
                System.debug('mapKey>> '+mapKey);

                if(quoteLine.SBQQ__ProductCode__c == SB_CONSTANTS.PROD_SKU_ULIFTY4){
                    startDate = Date.valueOf(quoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__StartDate__c).addYears(4);
                    endDate = startDate.addYears(1).addDays(-1);
                }else if(quoteLine.SBQQ__ProductCode__c == SB_CONSTANTS.PROD_SKU_ULIFTY5){
                    startDate = Date.valueOf(quoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__StartDate__c).addYears(5);
                    endDate = startDate.addYears(1).addDays(-1);
                }

                if(startDate != null){ 
                    if(productToStartDateMap.containsKey(mapKey)){
                        Date mapStartDate = productToStartDateMap.get(mapKey);
                        System.debug('mapStartDate>> ' + mapStartDate);
                        if(startDate < mapStartDate){productToStartDateMap.put(mapKey,startDate);}
                    } else {
                        productToStartDateMap.put(mapKey,startDate);
                    }
                }
                if(endDate != null){ 
                    if(productToEndDateMap.containsKey(mapKey)){
                        Date mapEndDate = productToEndDateMap.get(mapKey);
                        System.debug('mapEndDate>> ' + mapEndDate);
                        if(endDate > mapEndDate){productToEndDateMap.put(mapKey,endDate);}
                    } else {
                        productToEndDateMap.put(mapKey,endDate);
                    }
                }

                Date productStartDate = productToStartDateMap.get(mapKey);
                Date productEndDate = productToEndDateMap.get(mapKey);
                Boolean productEndDateLeapYear = false;
                if(productStartDate != null && productEndDate != null){
                    if(productEndDate.Month() > 2 && Date.isLeapYear(productEndDate.year()) && (productStartDate.Month() <= 2 || productStartDate.year() != productEndDate.year())){
                        productEndDateLeapYear = true;
                    }
                }

                Decimal productTotalTerm = calculateActualSubscriptionTerm(productToStartDateMap.get(mapKey), productToEndDateMap.get(mapKey), productEndDateLeapYear);

                productTotalTermMap.put(mapKey,productTotalTerm);
                
                Integer noOfYears = 0;
                if(startDate != null){
                    Integer productStartYear = 0;
                    Integer productEndYear = 0;
                    for (Date yearStartDate : quoteStartDateToYearMap.get(quoteLine.SBQQ__Quote__c).keySet()) {
                        Date yearEndDate = yearStartDate.addYears(1).addDays(-1);
                        if (startDate >= yearStartDate && startDate <= yearEndDate) {
                            productStartYear = quoteStartDateToYearMap.get(quoteLine.SBQQ__Quote__c)?.get(yearStartDate);
                            if (productToStartYearMap.containsKey(mapKey)) {
                                Integer mapYear = productToStartYearMap.get(mapKey);
                                productStartYear = mapYear <= productStartYear ? mapYear : productStartYear;
                            }
                            productToStartYearMap.put(mapKey, productStartYear);                                
                        }
                        if (endDate >= yearStartDate && endDate <= yearEndDate) {
                            productEndYear = quoteStartDateToYearMap.get(quoteLine.SBQQ__Quote__c)?.get(yearStartDate);
                            if (productToEndYearMap.containsKey(mapKey)) {
                                Integer mapYear = productToEndYearMap.get(mapKey);
                                productEndYear = mapYear >= productEndYear ? mapYear : productEndYear;
                            }
                            productToEndYearMap.put(mapKey, productStartYear);                                
                        }
                    }
                    if(productEndYear != productStartYear && productStartYear != 0){
                        noOfYears = productStartYear != 0 ? (productEndYear - productStartYear) + 1 : productEndYear;
                    } else {
                        noOfYears = 1;
                    }
                    productToNoOfYearMap.put(mapKey, noOfYears);
                    System.debug('Product >> ' + quoteLine.SBQQ__ProductCode__c+ ': Total Years >>' + noOfYears);
                }

                if(quoteLine.Is_Ramped__c){
                    Integer rampNumber = Integer.valueOf(quoteLine.Ramp_Label__c.split(' ')[1]);

                    if (lastRampMap.containsKey(quoteLine.Ramp_UniqueKey__c)) {
                        Integer mapRampNumber = lastRampMap.get(quoteLine.Ramp_UniqueKey__c);
                        if(rampNumber > mapRampNumber){lastRampMap.put(quoteLine.Ramp_UniqueKey__c,rampNumber);}
                    } else {
                        lastRampMap.put(quoteLine.Ramp_UniqueKey__c,rampNumber);
                    }

                    if(rampNumber == 1){
                        rampStartDateMap.put(quoteLine.Ramp_UniqueKey__c, quoteLine.SBQQ__StartDate__c);
                    }
                    Date rampStartDate = rampStartDateMap.get(quoteLine.Ramp_UniqueKey__c) == null? productToStartDateMap.get(mapKey) : rampStartDateMap.get(quoteLine.Ramp_UniqueKey__c);
                    Decimal rampSubscriptionTerm = calculateActualSubscriptionTerm(rampStartDate, endDate, productEndDateLeapYear);
                    rampTermMap.put(quoteLine.Ramp_UniqueKey__c, rampSubscriptionTerm);
                }

                Integer productStartYear = productToStartYearMap.containsKey(mapKey)?productToStartYearMap.get(mapKey) : 1;
                for(Integer i = 0; i < noOfYears; i++){
                    Integer yearIndex = productStartYear + i;
                    String productYearStr = mapKey + yearIndex;
                    if(quoteLine.SBQQ__EffectiveQuantity__c < 0){
                        productYearStr = '-ve'+ mapKey + yearIndex;
                    }
                    Date yearStartDate = quoteYearToStartDateMap.get(quoteLine.SBQQ__Quote__c)?.get(yearIndex);
                    Date yearEndDate = yearStartDate.addYears(1).addDays(-1);
                    System.debug('product start Date>>' + productToStartDateMap.get(mapKey));
                    System.debug('product end Date>>' + productToEndDateMap.get(mapKey));
                    Date productYearStartDate = productStartDate > yearStartDate ? productStartDate : yearStartDate;
                    Date productYearEndDate = productEndDate < yearEndDate ? productEndDate : yearEndDate;
                    Decimal productYearTerm = calculateActualSubscriptionTerm(productYearStartDate, productYearEndDate,productEndDateLeapYear);
                    productYearWiseTermMap.put(productYearStr,productYearTerm);
                }

            }
            System.debug('productToStartDateMap >> ' + productToStartDateMap);    
            System.debug('productToEndDateMap >> ' + productToEndDateMap);    
            System.debug('productToNoOfYearMap >> ' + productToNoOfYearMap);    
            System.debug('productToStartYearMap >> ' + productToStartYearMap);    
            System.debug('productTotalTermMap >> ' + productTotalTermMap);
            System.debug('productYearWiseTermMap >> ' + productYearWiseTermMap);
            Map<String, Integer> productToYearMap = new Map<String, Integer>();
            Map<Id,SBQQ__Quote__c> quoteToUpdateMap = new Map<Id,SBQQ__Quote__c>();
            List<Annual_Breakdown__c> annualBreakdownToInsert = new List<Annual_Breakdown__c>();
            List<Year_Wise_Split__c> yearWiseSplitToInsert = new List<Year_Wise_Split__c>();
            Map<String, Decimal> remapEvaluatedTermMap = new Map<String, Decimal>();
            Map<String, Decimal> productYearwsieEvaluatedTermMap = new Map<String, Decimal>();
            Map<String, Decimal> cancelledProductYearwsieEvaluatedTermMap = new Map<String, Decimal>();
            
            for(SBQQ__QuoteLine__c quoteLine : [SELECT SBQQ__Quote__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__SubscriptionTerm__c, Finance_Term__c,
                                                SBQQ__EffectiveQuantity__c,SBQQ__NetTotal__c,SBQQ__Product__c, Base_Extended_Price__c, Ramp_UniqueKey__c,
                                                Is_Ramped__c,Ramp_Label__c,SBQQ__ProductCode__c,SBQQ__SubscriptionType__c,SBQQ__Number__c,Last_Ramp_Quantity__c                                                
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE SBQQ__Quote__c IN :quoteMap.keySet() AND SBQQ__Product__r.ProductCode != null ORDER BY SBQQ__Number__c]){

                if((quoteLine.SBQQ__NetTotal__c != 0 || quoteLine.SBQQ__EffectiveQuantity__c != 0) && !errorQuoteMap.containsKey(quoteLine.SBQQ__Quote__c)){
                    System.debug('Product Code >> ' + quoteLine.SBQQ__ProductCode__c);
                    
                    Decimal subscriptionTerm = quoteLine.Finance_Term__c;//quoteLine.SBQQ__SubscriptionTerm__c;
                    Date startDate = Date.valueOf(quoteLine.SBQQ__StartDate__c);
                    Date endDate = Date.valueOf(quoteLine.SBQQ__EndDate__c);
                    
                    startDate = startDate == null? Date.valueOf(quoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__StartDate__c) : startDate;
                    endDate = endDate == null? Date.valueOf(quoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__EndDate__c) : endDate;

                    String mapKey = quoteLine.SBQQ__Quote__c + quoteLine.SBQQ__ProductCode__c;
                    System.debug('mapKey>> '+mapKey);

                    String productCode = ','+quoteLine.SBQQ__ProductCode__c+',';
                    String deploymnetCustomLabel = ','+Label.ABD_DeploymentSKUs+',';//ABD_DeploymentSKUs //ABD_PromoSKUs
                    String promoCustomLabel = ','+Label.ABD_PromoSKUs+',';//ABD_DeploymentSKUs //ABD_PromoSKUs
                    Boolean deploymentSKU = false;
                    Boolean promoSKU = false;
                                        
                    Decimal existingNetTotal = quoteToNetTotalMap.containsKey(quoteLine.SBQQ__Quote__c) ? quoteToNetTotalMap.get(quoteLine.SBQQ__Quote__c) : 0;
                    Decimal quoteLineNetTotal = quoteLine.SBQQ__NetTotal__c != null ? quoteLine.SBQQ__NetTotal__c : 0;
                    quoteToNetTotalMap.put(quoteLine.SBQQ__Quote__c,(existingNetTotal + quoteLineNetTotal));
                    Boolean productEndDateLeapYear = false;
                    if(productToEndDateMap.containsKey(mapKey)){
                        Date productStartDate = productToStartDateMap.get(mapKey);
                        Date productEndDate = productToEndDateMap.get(mapKey);
                        if(productEndDate.Month() > 2 && Date.isLeapYear(productEndDate.year()) && (productStartDate.Month() <= 2 || productStartDate.year() != productEndDate.year())){
                            productEndDateLeapYear = true;
                        }
                    }
                    
                    //Check for One-Time product
                    if(quoteLine.SBQQ__SubscriptionType__c == SB_CONSTANTS.PROD_SUBSTYPE_ONETIME){
                        subscriptionTerm = quoteLine.SBQQ__SubscriptionTerm__c != null? subscriptionTerm : 12;
                        //For 4-year and 5-Year uplift set year to (4 - 1) and (5 - 1) respectively.
                        if(quoteLine.SBQQ__ProductCode__c == SB_CONSTANTS.PROD_SKU_ULIFTY4){
                            productToYearMap.put(mapKey, 3);
                            startDate = Date.valueOf(quoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__StartDate__c).addYears(3);
                            endDate = startDate.addYears(1).addDays(-1);
                        }else if(quoteLine.SBQQ__ProductCode__c == SB_CONSTANTS.PROD_SKU_ULIFTY5){
                            productToYearMap.put(mapKey, 4);
                            startDate = Date.valueOf(quoteMap.get(quoteLine.SBQQ__Quote__c).SBQQ__StartDate__c).addYears(4);
                            endDate = startDate.addYears(1).addDays(-1);
                        }
                        
                        //Check for Deployment Skus
                        if(deploymnetCustomLabel.containsIgnoreCase(productCode)){
                            productToYearMap.put(mapKey, 0);
                            deploymentSKU = true;
                        }
                        
                        //Check for buyback Skus
                        if(promoCustomLabel.containsIgnoreCase(productCode)){
                            promoSKU = true;
                        }
                    } else {
                        subscriptionTerm = calculateActualSubscriptionTerm(quoteLine.SBQQ__StartDate__c,quoteLine.SBQQ__EndDate__c, productEndDateLeapYear);
                        //subscriptionTerm = quoteLine.Finance_Term__c;
                    }
                    
                    Integer noOfYears = (Integer)subscriptionTerm/12;
                    if(startDate != null){
                        Integer productStartYear = 0;
                        Integer productEndYear = 0;
                        for (Date yearStartDate : quoteStartDateToYearMap.get(quoteLine.SBQQ__Quote__c).keySet()) {
                            Date yearEndDate = yearStartDate.addYears(1).addDays(-1);
                            if (startDate >= yearStartDate && startDate <= yearEndDate) {
                                productStartYear = quoteStartDateToYearMap.get(quoteLine.SBQQ__Quote__c)?.get(yearStartDate);
                                productToYearMap.put(mapKey, (productStartYear - 1));                                
                            }
                            if (endDate >= yearStartDate && endDate <= yearEndDate) {
                                productEndYear = quoteStartDateToYearMap.get(quoteLine.SBQQ__Quote__c)?.get(yearStartDate);
                            }
                        }
                        if(productEndYear != productStartYear && productStartYear != 0){
                            noOfYears = productStartYear != 0 ? (productEndYear - productStartYear) + 1 : productEndYear;
                        } else {
                            noOfYears = 1;
                        }
                        System.debug('Product >> ' + quoteLine.SBQQ__ProductCode__c+ ': Total Years >>' + noOfYears);
                    }                  

                    if(quoteLine.Is_Ramped__c){
                        Integer rampNumber = Integer.valueOf(quoteLine.Ramp_Label__c.split(' ')[1]);
                        
                        Boolean isLastRamp  = false;
                        if (lastRampMap.containsKey(quoteLine.Ramp_UniqueKey__c)) {
                            isLastRamp = lastRampMap.get(quoteLine.Ramp_UniqueKey__c) == rampNumber ? true : false;
                        }
                        
                        if (isLastRamp) {
                            Decimal evaluatedTerm = remapEvaluatedTermMap.containsKey(quoteLine.Ramp_UniqueKey__c)?remapEvaluatedTermMap.get(quoteLine.Ramp_UniqueKey__c) : 0;
                            Decimal subscriptionTermLastLine = rampTermMap.get(quoteLine.Ramp_UniqueKey__c) - evaluatedTerm;
                            subscriptionTerm = subscriptionTermLastLine;
                            System.debug('Last Ramp subscriptionTerm >>' + subscriptionTerm);
                        }                        
                    }

                    System.debug('-=- subscriptionTerm -=- '+subscriptionTerm);

                    if(subscriptionTerm != null && subscriptionTerm != 0){  

                        Decimal years = subscriptionTerm/12;
                        Integer yearsInt = (Integer) years;
                        Decimal months = subscriptionTerm - (yearsInt * 12);//24.80 - (24)
                        Decimal netTotal = quoteLine.SBQQ__NetTotal__c != null? quoteLine.SBQQ__NetTotal__c : 0;
                        Decimal monthlyNetPrice = netTotal/subscriptionTerm;
                        Decimal listPrice = quoteLine.Base_Extended_Price__c > 0 ? quoteLine.Base_Extended_Price__c : netTotal;
                        Decimal monthlyListPrice = listPrice/subscriptionTerm;
                        Year_Wise_Split__c yearWiseSplit;
                        
                        Quote_Extension__c currentQuoteExtn = quoteToExtensionMap.get(quoteLine.SBQQ__Quote__c);
                        if(quoteMap.get(quoteLine.SBQQ__Quote__c).Annual_Breakdown_Error__c){
                            quoteMap.get(quoteLine.SBQQ__Quote__c).Annual_Breakdown_Error__c = false;
                            quoteToUpdateMap.put(quoteLine.SBQQ__Quote__c,quoteMap.get(quoteLine.SBQQ__Quote__c));
                        }
                        
                        if(productToYWSMap.containsKey(mapKey)){
                            yearWiseSplit = productToYWSMap.get(mapKey);
                            yearWiseSplit.Quote_Line__c = quoteLine.Id;
                            List<FormulaRecalcResult> results = Formula.recalculateFormulas(new List<Year_Wise_Split__c>{yearWiseSplit});
                            yearWiseSplit.Quantity__c = quoteLine.SBQQ__EffectiveQuantity__c;
                            if(quoteLine.Is_Ramped__c){
                                Integer rampNumber = Integer.valueOf(quoteLine.Ramp_Label__c.split(' ')[1]);
                                if(yearWiseSplit.Ramp_Number__c < rampNumber){
                                    yearWiseSplit.Quote_Line__c = quoteLine.Id;
                                    yearWiseSplit.Quantity__c = quoteLine.SBQQ__EffectiveQuantity__c;
                                }
                            }
                        } else {
                            yearWiseSplit = new Year_Wise_Split__c(Quote__c = quoteLine.SBQQ__Quote__c, Quote_Line__c = quoteLine.Id, Quantity__c = quoteLine.SBQQ__EffectiveQuantity__c,APTS_Ext_ID__c=quoteLine.Id);
                        }

                        SBQQ__Quote__c currentQuote = quoteMap.get(quoteLine.SBQQ__Quote__c);
                        Decimal termEvaluted = 0;
                        Date loopStartDate = startDate;
                        Date loopEndDate = loopStartDate.addYears(1).addDays(-1);
                        yearsInt = noOfYears;
                        for (Integer i = 1; i <= yearsInt; i++) {
                            
                            Boolean isLastLoopYear = ((yearsInt - i) == 0);
                            
                            Decimal term = 12;
                            Integer yearIndex = i;
                                                        
                            //Store the year for which annual breakdown is added for the product 
                            if(productToYearMap.containsKey(mapKey)){
                                yearIndex = productToYearMap.get(mapKey) + 1;
                            }
                            
                            yearIndex = yearIndex == null? i: yearIndex;
                            System.debug('yearIndex>> ' + yearIndex);
                            
                            productToYearMap.put(mapKey, yearIndex);
                            
                            loopStartDate = loopStartDate;
                            loopEndDate = loopStartDate.addYears(1).addDays(-1);
                            
                            //Compare year start and end date with quoteline start and end date
                            Date yearStartDate = quoteYearToStartDateMap.get(quoteLine.SBQQ__Quote__c)?.get(yearIndex);
                            yearStartDate = yearStartDate != null ? yearStartDate : loopStartDate;
                            Date yearEndDate = yearStartDate.addYears(1).addDays(-1);
                            loopStartDate = loopStartDate > yearStartDate ? loopStartDate : yearStartDate;
                            loopEndDate = loopEndDate > yearEndDate ? yearEndDate : loopEndDate;
                            
                            term = calculateActualSubscriptionTerm(loopStartDate,loopEndDate,productEndDateLeapYear);
                            
                            if (deploymentSKU) {
                                loopEndDate = Date.valueOf(quoteLine.SBQQ__EndDate__c);
                                term = quoteLine.SBQQ__SubscriptionTerm__c != null ? quoteLine.SBQQ__SubscriptionTerm__c : term;
                            }
                            
                            //This condition is for partial month check
                            if (isLastLoopYear) {
                                loopEndDate = quoteLine.SBQQ__EndDate__c != null ? quoteLine.SBQQ__EndDate__c : loopEndDate;
                                if (loopEndDate > yearEndDate) {
                                    yearsInt = yearsInt + 1;
                                    loopEndDate = yearEndDate;
                                }
                                term = calculateActualSubscriptionTerm(loopStartDate,loopEndDate,productEndDateLeapYear);
                                //determine the remaining term by subtracting evaluted term from full term.
                                System.debug('subscription term>>' + subscriptionTerm);
                                System.debug('termEvaluted>>' + termEvaluted);
                                Decimal tempTerm = (subscriptionTerm - termEvaluted) > 12 ? 12 : subscriptionTerm - termEvaluted;
                                term = termEvaluted > 0 ? tempTerm : term;
                                if(loopStartDate == quoteLine.SBQQ__StartDate__c && loopEndDate == quoteLine.SBQQ__EndDate__c){
                                    term = subscriptionTerm;
                                }
                                System.debug('term>>' + term);
                            }
                            
                            String productyear = mapKey + yearIndex;
                            if(quoteLine.SBQQ__EffectiveQuantity__c < 0){
                                productyear = '-ve'+ mapKey + yearIndex;
                            }
                            if(productYearwsieEvaluatedTermMap.containsKey(productyear)){
                                Decimal evaluatedTerm = productYearwsieEvaluatedTermMap.get(productyear);
                                //Decimal cancelledEvaluatedTerm = cancelledProductYearwsieEvaluatedTermMap.get(productyear);
                                if (loopEndDate == yearEndDate && loopStartDate > yearStartDate) {
                                    //if((term + evaluatedTerm) > 12){ term = 12 - evaluatedTerm; }
                                    Date productStartDate = productToStartDateMap.get(mapKey);
                                    Date productEndDate = productToEndDateMap.get(mapKey);
                                    Date quoteStartDate = quoteToStartEndDateMap.get(quoteLine.SBQQ__Quote__c)[0];
                                    if(productStartDate.day() == quoteStartDate.day() && productStartDate.Month() == quoteStartDate.Month()){
                                        term = 12 - evaluatedTerm;
                                    } else {
                                        Decimal productyearTerm = productYearWiseTermMap.get(productyear);//productYearWiseTermMap
                                        Decimal tempTerm = productyearTerm - evaluatedTerm;
                                        term = (evaluatedTerm+tempTerm) > 12 ? term : tempTerm;
                                    }
                                }
                                productYearwsieEvaluatedTermMap.put(productyear,(evaluatedTerm+term));
                            } else {
                                productYearwsieEvaluatedTermMap.put(productyear,term);
                            }
                            
                            if(yearsInt == 1){
                                monthlyNetPrice = netTotal/term;
                                monthlyListPrice = listPrice/term;
                            }                                      

                            System.debug('Current term>>' + term);
                            termEvaluted = termEvaluted + term;
                            System.debug('Evaluted term>>' + termEvaluted);
                            if (currentQuoteExtn.get('Year'+yearIndex+'_Start_Date__c') != null) {
                                Date qeYearStartDate = (Date)currentQuoteExtn.get('Year'+yearIndex+'_Start_Date__c');
                                qeYearStartDate = qeYearStartDate > yearStartDate ? yearStartDate : qeYearStartDate;
                                currentQuoteExtn.put('Year'+yearIndex+'_Start_Date__c',qeYearStartDate);                            
                            } else{
                                currentQuoteExtn.put('Year'+yearIndex+'_Start_Date__c',yearStartDate);                            
                            }
                            if (currentQuoteExtn.get('Year'+yearIndex+'_End_Date__c') != null) {
                                Date qeYearEndDate = (Date)currentQuoteExtn.get('Year'+yearIndex+'_End_Date__c');
                                qeYearEndDate = qeYearEndDate < loopEndDate ? loopEndDate : qeYearEndDate;
                                currentQuoteExtn.put('Year'+yearIndex+'_End_Date__c',qeYearEndDate);                            
                            } else{
                                currentQuoteExtn.put('Year'+yearIndex+'_End_Date__c',loopEndDate);                            
                            }
                            
                            if(quoteLine.Is_Ramped__c){
                                Decimal rampEvaluatedTerm = 0;
                                Integer rampNumber = Integer.valueOf(quoteLine.Ramp_Label__c.split(' ')[1]);
                                rampEvaluatedTerm = remapEvaluatedTermMap.containsKey(quoteLine.Ramp_UniqueKey__c)?remapEvaluatedTermMap.get(quoteLine.Ramp_UniqueKey__c) : 0;
                                System.debug('rampEvaluatedTerm >>' + rampEvaluatedTerm);
                                remapEvaluatedTermMap.put(quoteLine.Ramp_UniqueKey__c, rampEvaluatedTerm + term);
                                System.debug('remapEvaluatedTermMap >>' + remapEvaluatedTermMap.get(quoteLine.Ramp_UniqueKey__c));
                            }

                            Annual_Breakdown__c annualBreakdown = setAnnualBreakDownValues(quoteLine,term,monthlyListPrice,monthlyNetPrice,yearIndex,loopStartDate,loopEndDate);
                            annualBreakdownToInsert.add(annualBreakdown);

                            yearWiseSplit = setYWSValues(yearWiseSplit,term,monthlyListPrice,monthlyNetPrice,yearIndex);
                            
                            currentQuoteExtn = setQuoteExtnValues(currentQuoteExtn, yearIndex, annualBreakdown);
                            quoteToExtensionMap.put(quoteLine.SBQQ__Quote__c,currentQuoteExtn);
                            
                            loopStartDate = loopEndDate.addDays(1);
                            loopEndDate = loopStartDate.addYears(1).addDays(-1);
                        }
                        productToYWSMap.put(mapKey, yearWiseSplit);
                    } else {
                        quoteToUpdateMap.remove(quoteLine.SBQQ__Quote__c);
                        quoteToExtensionMap.remove(quoteLine.SBQQ__Quote__c);
                        errorQuoteMap.put(quoteLine.SBQQ__Quote__c, quoteMap.get(quoteLine.SBQQ__Quote__c));
                        continue;
                    }
                }
            }

            //update values on Quote
            if (!productToYWSMap.isEmpty()) {
                List<FormulaRecalcResult> results = Formula.recalculateFormulas(productToYWSMap.values());
                System.debug('productToYWSMap.values()>>'+productToYWSMap.values());
                for (Year_Wise_Split__c yws : productToYWSMap.values()) {                 
                    System.debug('yws>>' + yws);   
                    quoteMap.put(yws.Quote__c, setQuoteValues(quoteMap.get(yws.Quote__c),yws,quoteToStartEndDateMap.get(yws.Quote__c)));
                    quoteToUpdateMap.put(yws.Quote__c,quoteMap.get(yws.Quote__c));
                    Decimal ywsTotal = quoteToYearWiseSplitTotalMap.containsKey(yws.Quote__c) ? quoteToYearWiseSplitTotalMap.get(yws.Quote__c) : 0;
                    quoteToYearWiseSplitTotalMap.put(yws.Quote__c, (yws.Subtotal__c + ywsTotal));
                }
            }

            //Check if Quote TCV matchs with YWS and ABD total
            Decimal differenceAllowed = Decimal.valueOf(Label.ABD_TCVMissmatchThreshold.trim());
            for (Id quoteId : quoteToNetTotalMap.keySet()) {
                Decimal ywsTotal = quoteToYearWiseSplitTotalMap.containsKey(quoteId) ? quoteToYearWiseSplitTotalMap.get(quoteId) : 0;
                Decimal abdTotal = quoteToExtensionMap.containsKey(quoteId) ? quoteToExtensionMap.get(quoteId).Net_Price_Total__c : 0;
                Decimal quoteTotal = quoteToNetTotalMap.containsKey(quoteId) ? quoteToNetTotalMap.get(quoteId) : 0;

                if(Math.abs(quoteTotal - ywsTotal) > differenceAllowed || Math.abs(quoteTotal - abdTotal) > differenceAllowed){
                    SBQQ__Quote__c currentQuote =  quoteToUpdateMap.get(quoteId);
                    currentQuote.Is_Year_Wise_Split_Data_Incorrect__c = true;
                    quoteToUpdateMap.put(quoteId, currentQuote);
                    ywsTotalTCVMismatchQuotesMap.put(quoteId, currentQuote);
                } else {
                    SBQQ__Quote__c currentQuote =  quoteToUpdateMap.get(quoteId);
                    currentQuote.Is_Year_Wise_Split_Data_Incorrect__c = false;
                    quoteToUpdateMap.put(quoteId, currentQuote);                    
                }
            }
            
            deleteAnnualBreakdown(quoteMap.keySet());
            deleteYearWiseSplit(quoteMap.keySet());
            System.debug('ABD to insert>> '+ annualBreakdownToInsert);
            System.debug('YWS to insert>> '+ productToYWSMap.values());

            try {                
                insert annualBreakdownToInsert;
                insert productToYWSMap.values();
                update quoteToExtensionMap.values();
                
                TriggerUtility.skipentireproposaltriggerExecuted();
                SBQQ.TriggerControl.disable();
                update quoteToUpdateMap.values();
            } catch (Exception exp) {
                System.debug(exp.getMessage());
            } finally {                
                SBQQ.TriggerControl.enable();
                TriggerUtility.skipentireproposaltriggerReset();
            }

            //Create Support case incase mismatch
            if (!ywsTotalTCVMismatchQuotesMap.isEmpty()) {
                createCases(ywsTotalTCVMismatchQuotesMap);
            }
        }
        
        //Add breakdown generation error on Quote
        if(!errorQuoteMap.isEmpty()){
            for(SBQQ__Quote__c quote: errorQuoteMap.values()){
                quote.Annual_Breakdown_Error__c = true;
            }
            deleteAnnualBreakdown(errorQuoteMap.keySet());
            deleteYearWiseSplit(quoteMap.keySet());
            update quoteToExtensionMap.values();
            update errorQuoteMap.values();
        }
    }
    
    public static void deleteAnnualBreakdown(Set<Id> quoteIds) {
        List<Annual_Breakdown__c> annualBreakdownToDelete = [SELECT Id, Quote__c FROM Annual_Breakdown__c WHERE Quote__c IN : quoteIds];
        System.debug('ABD to delete>> '+ annualBreakdownToDelete);
        delete annualBreakdownToDelete;
    }

    public static void deleteYearWiseSplit(Set<Id> quoteIds) {
        List<Year_Wise_Split__c> yearWiseSplitToDelete = [SELECT Id FROM Year_Wise_Split__c WHERE Quote__c IN : quoteIds];
        System.debug('YWS to delete>> '+ yearWiseSplitToDelete);
        delete yearWiseSplitToDelete;
    }

    public static Annual_Breakdown__c setAnnualBreakDownValues(SBQQ__QuoteLine__c quoteLine,Decimal term, Decimal monthlyListPrice, Decimal monthlyNetPrice, Integer yearIndex, Date startDate, Date endDate) {
        Decimal calTerm = term;
        Decimal netPrice = monthlyNetPrice * calTerm; //netPrice*(term/QuoteLineTerm)
        Decimal currentInvoice = monthlyNetPrice * calTerm; 
        Decimal currentListPrice = monthlyListPrice * calTerm;
        System.debug('Net Price>> ' + netPrice);

        Annual_Breakdown__c annualBreakdown = new Annual_Breakdown__c();
        annualBreakdown.Quote__c = quoteLine.SBQQ__Quote__c;
        annualBreakdown.Quote_Line__c = quoteLine.Id;
        annualBreakdown.SKU__c = quoteLine.SBQQ__Product__c;
        annualBreakdown.Start_Date__c = startDate;
        annualBreakdown.End_Date__c = endDate;
        annualBreakdown.Year__c = yearIndex;
        annualBreakdown.Quantity__c = quoteLine.SBQQ__EffectiveQuantity__c;
        annualBreakdown.Term_Length__c = Math.ceil(term);
        annualBreakdown.Finance_term__c = term;
        annualBreakdown.Net_Price__c = netPrice;
        annualBreakdown.List_Price__c = currentListPrice;
        annualBreakdown.put('Invoice'+yearIndex+'__c', currentInvoice);
        annualBreakdown.put('PPU'+yearIndex+'__c',(currentInvoice/quoteLine.SBQQ__EffectiveQuantity__c));

        return annualBreakdown;
    }
    
    public static Quote_Extension__c setQuoteExtnValues(Quote_Extension__c currentQuoteExtn, Integer yearIndex, Annual_Breakdown__c annualBreakdown) {
        Decimal invoiceTotal = (Decimal)currentQuoteExtn.get('Invoice_'+yearIndex+'_Total__c');
        invoiceTotal = invoiceTotal + (Decimal)annualBreakdown.get('Invoice'+yearIndex+'__c');
        currentQuoteExtn.put('Invoice_'+yearIndex+'_Total__c', invoiceTotal);
        currentQuoteExtn.List_Price_Total__c = currentQuoteExtn.List_Price_Total__c +  annualBreakdown.List_Price__c;
        currentQuoteExtn.Net_Price_Total__c =  currentQuoteExtn.Net_Price_Total__c + annualBreakdown.Net_Price__c;

        return currentQuoteExtn;
    }

    public static Year_Wise_Split__c setYWSValues(Year_Wise_Split__c yearWiseSplit, Decimal term, Decimal monthlyListPrice, Decimal monthlyNetPrice, Integer yearIndex) {

        Decimal netPrice = monthlyNetPrice * term; 
        Decimal currentInvoice = monthlyNetPrice * term; 
        Decimal currentListPrice = monthlyListPrice * term;

        Decimal existingCost = yearWiseSplit.get('Year_'+yearIndex+'_Cost__c') != null ? (Decimal) yearWiseSplit.get('Year_'+yearIndex+'_Cost__c') : 0;
        YearWiseSplit.put('Year_'+yearIndex+'_Cost__c', (existingCost + currentInvoice));
        Decimal existingListPrice = yearWiseSplit.get('Year_'+yearIndex+'_List_Price_Cost__c') != null ? (Decimal) yearWiseSplit.get('Year_'+yearIndex+'_List_Price_Cost__c') : 0;
        YearWiseSplit.put('Year_'+yearIndex+'_List_Price_Cost__c', (existingListPrice + currentListPrice));

        return YearWiseSplit;
    }

    public static SBQQ__Quote__c setQuoteValues(SBQQ__Quote__c currentQuote, Year_Wise_Split__c yearWiseSplit, List<Date> startEndDateList) {
        
        Date startDate = startEndDateList[0];
        Date endDate = startDate.addYears(1).addDays(-1);
        Datetime quoteStartDate = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);
        Datetime quoteEndDate = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);
        
        for (Integer i = 1; i <= 7; i++) {                  
            
            Decimal ywsCost = yearWiseSplit.get('Year_'+i+'_Cost__c') != null ? (Decimal) yearWiseSplit.get('Year_'+i+'_Cost__c') : 0;
            Decimal quoteSubTotal = (Decimal) currentQuote.get('Year_'+i+'_Subtotal__c') + ywsCost;                   
            currentQuote.put('Year_'+i+'_Subtotal__c',quoteSubTotal);
            
            Decimal ywsListPrice = yearWiseSplit.get('Year_'+i+'_List_Price_Cost__c') != null ? (Decimal) yearWiseSplit.get('Year_'+i+'_List_Price_Cost__c') : 0;
            Decimal quoteListPriceSubTotal = (Decimal) currentQuote.get('Year_'+i+'_List_Price_Subtotal__c') + ywsListPrice;   
            currentQuote.put('Year_'+i+'_List_Price_Subtotal__c',quoteListPriceSubTotal);
            
            quoteEndDate = (Datetime)startEndDateList[1] < quoteEndDate ? (Datetime)startEndDateList[1] : quoteEndDate;
            String yearText = quoteStartDate.format('MMM-yy') + ' to ' + quoteEndDate.format('MMM-yy');
            currentQuote.put('Year_'+i+'_Year_Value__c',yearText);

            quoteStartDate = quoteEndDate.addDays(1);
            quoteEndDate = quoteStartDate.addYears(1).addDays(-1);
        }

        return currentQuote;
    }
    
    /**
     * @description Method to create support cases for quotes having incorrect YWS data
     * @param quotes - List of CPQ quotes
     **/
    @TestVisible private static void createCases(Map<Id, SBQQ__Quote__c> quotes) {
        List<Case> lstCasesToInsert = new List<Case>();
        Id caseOwnerId;
        if(Test.isRunningTest()){
            caseOwnerId = Userinfo.getUserId();
        }else{
            caseOwnerId = ZscalerSetting__c.getValues('SalesOperationQueueId').Value__c;
        }

        // Query the existing cases
        Map<Id, Id> mapExistingCaseIds = new Map<Id, Id>();
        for(Case existingCase : [SELECT Id, Subject, Quote__c FROM Case
                                   WHERE Case_Category__c = 'Quotes'
                                     AND Case_Sub_Category__c = 'Year Wise Splits Fix'
                                     AND IsClosed != true
                                     AND Quote__c IN :quotes.keySet()]){
             mapExistingCaseIds.put(existingCase.Quote__c, existingCase.Id);
        }

        for(SBQQ__Quote__c quote : quotes.values()){
            if(mapExistingCaseIds.containsKey(quote.Id)){
                continue;
            }

            lstCasesToInsert.add(new Case(
                                Subject = 'Year wise split data is incorrect : ' + quote.Name,
                                Opportunity_Name__c = quote.SBQQ__Opportunity2__c,
                                AccountId = quote.SBQQ__Account__c,
                                Case_Category__c = 'Quotes',
                                Case_Sub_Category__c = 'Year Wise Splits Fix',
                                Status = 'New',
                                OwnerId = caseOwnerId,
                                Priority = '3 - Medium',
                                Case_Source__c = 'Salesforce.com',
                                Description = 'The generated year wise split data does not match with the Net Price of the quote line item(s). Please verify and fix.',
                                Quote__c = quote.Id,
                                recordtypeid=label.CaseRT_SalesOperation
                            ));
        }

        Database.insert(lstCasesToInsert, true);
    }
    
    public static Decimal calculateActualSubscriptionTerm(Date startDate, Date endDate, Boolean leapYear) {

        Date actualEndDate = endDate;
        Decimal daysInActualEndMonth = Date.daysInMonth(actualEndDate.year(),actualEndDate.month());
        System.debug('daysInActualEndMonth>> '+daysInActualEndMonth);

        endDate = endDate.addDays(1);

        Integer monthDifference = startDate.monthsBetween(endDate);
        System.debug('monthDifference>> '+monthDifference);
        Decimal dayDifference = endDate.day() - startDate.day();
        System.debug('dayDifference>> '+dayDifference);
        
        if (dayDifference < 0  && monthDifference != 0) {
            monthDifference--;
            System.debug('monthDifference>> '+monthDifference);
        }
        
        Date properMonthEndDate = startDate.addMonths(monthDifference);
        System.debug( 'properMonthEndDate >> ' + properMonthEndDate );
        Date properMonthEndDatePusOne = properMonthEndDate.addDays(1);
        System.debug( 'properMonthEndDatePusOne >> ' + properMonthEndDate );
        Decimal remainingDays = properMonthEndDate.daysBetween(endDate);
        //if(properMonthEndDate == actualEndDate){ remainingDays = 0;}
        if(startDate.day() == 31){            
            if(actualEndDate.day() == daysInActualEndMonth && daysInActualEndMonth != 31){
                remainingDays = 0;
            }
        }
        System.debug('remainingDays>> '+remainingDays);
        
        Decimal subscriptionTerm = 0;
        //if(actualEndDate.Month() > 2 && Date.isLeapYear(actualEndDate.year()) && (startDate.Month() <= 2 || startDate.year() != actualEndDate.year())){
        if(leapYear){
            subscriptionTerm = monthDifference + ((remainingDays/ 366) * 12);
        } else {
            subscriptionTerm = monthDifference + ((remainingDays/ 365) * 12);
        }
        //subscriptionTerm = monthDifference + ((remainingDays/ 365) * 12);
        System.debug( 'Final subscriptionTerm>> ' + subscriptionTerm);
        
        return subscriptionTerm;
    }  

    /**
     * @description Method to generate the list of Year Wise Splits for a quote
     * @param quoteId CPQ Quote ID
     * @return YearWiseSplitWrapper A wrapper class containing the year wise split records
     **/
    public static YearWiseSplitWrapper getYearWiseSplitsList(Id quoteId){
        YearWiseSplitWrapper splitWrapper = new YearWiseSplitWrapper();
        SBQQ__Quote__c quote = [SELECT Id, Generate_Year_Wise_Split__c, Number_Of_Year_Wise_Split_Years__c, Year_1_Subtotal__c,
                                                    Year_2_Subtotal__c, Year_3_Subtotal__c, Year_4_Subtotal__c, Year_5_Subtotal__c, Year_6_Subtotal__c,
                                                    Year_7_Subtotal__c, Year_Wise_Split_Total__c, Year_1_Year_Value__c, Year_2_Year_Value__c,
                                                    Year_3_Year_Value__c, Year_4_Year_Value__c, Year_5_Year_Value__c, Year_6_Year_Value__c, Year_7_Year_Value__c,
                                                    (SELECT Id, Quote_Line__c, Product_Name__c, SKU_Code__c, Year_1_Cost__c,
                                                        Year_2_Cost__c, Year_3_Cost__c, Year_4_Cost__c, Year_5_Cost__c, Year_6_Cost__c, Year_7_Cost__c,
                                                        Subtotal__c, Quote_Line_Sequence__c, Effective_Quantity__c
                                                       FROM Year_Wise_Splits__r ORDER BY Quote_Line__r.SBQQ__Number__c)
                                                  FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];

        splitWrapper.quoteId = quote.Id;
        splitWrapper.numberOfYears = (Integer)quote.Number_Of_Year_Wise_Split_Years__c;
        splitWrapper.splitEntries = new List<YearWiseSplitEntry>();
        splitWrapper.year1YearValue = 'Year 1 Cost (' + quote.Year_1_Year_Value__c + ')';
        splitWrapper.year2YearValue = 'Year 2 Cost (' + quote.Year_2_Year_Value__c + ')';
        splitWrapper.year3YearValue = 'Year 3 Cost (' + quote.Year_3_Year_Value__c + ')';
        splitWrapper.year4YearValue = 'Year 4 Cost (' + quote.Year_4_Year_Value__c + ')';
        splitWrapper.year5YearValue = 'Year 5 Cost (' + quote.Year_5_Year_Value__c + ')';
        splitWrapper.year6YearValue = 'Year 6 Cost (' + quote.Year_6_Year_Value__c + ')';
        splitWrapper.year7YearValue = 'Year 7 Cost (' + quote.Year_7_Year_Value__c + ')';

        for(Year_Wise_Split__c split : quote.Year_Wise_Splits__r){
            splitWrapper.splitEntries.add(new YearWiseSplitEntry(
                                            split.Product_Name__c,
                                            split.SKU_Code__c,
                                            split.Year_1_Cost__c,
                                            split.Year_2_Cost__c,
                                            split.Year_3_Cost__c,
                                            split.Year_4_Cost__c,
                                            split.Year_5_Cost__c,
                                            split.Year_6_Cost__c,
                                            split.Year_7_Cost__c,
                                            split.Subtotal__c,
                                            String.valueOf(split.Quote_Line_Sequence__c),
                                            Integer.valueOf(split.Effective_Quantity__c)
                                        ));
        }

        splitWrapper.splitEntries.add(new YearWiseSplitEntry(
                            'Total',
                            '',
                            quote.Year_1_Subtotal__c,
                            quote.Year_2_Subtotal__c,
                            quote.Year_3_Subtotal__c,
                            quote.Year_4_Subtotal__c,
                            quote.Year_5_Subtotal__c,
                            quote.Year_6_Subtotal__c,
                            quote.Year_7_Subtotal__c,
                            quote.Year_Wise_Split_Total__c,
                            '',
                            null
                        ));

        return splitWrapper;
    }

    /**
     * YearWiseSplitWrapper - A custom wrapper to hold the list of year wise split records
     */
    public class YearWiseSplitWrapper{
        public Id quoteId { get; set; }
        public Integer numberOfYears { get; set; }
        public List<YearWiseSplitEntry> splitEntries { get; set; }
        public String year1YearValue { get; set; }
        public String year2YearValue { get; set; }
        public String year3YearValue { get; set; }
        public String year4YearValue { get; set; }
        public String year5YearValue { get; set; }
        public String year6YearValue { get; set; }
        public String year7YearValue { get; set; }

        public YearWiseSplitWrapper(){
            splitEntries = new List<YearWiseSplitEntry>();
        }
    }
    
    /**
     * YearWiseSplitWrapper - A custom wrapper to a year wise split entry
     */
    public class YearWiseSplitEntry{
        public String productName { get; set; }
        public String productCode { get; set; }
        public Integer quantity { get; set; }
        public Decimal year1Cost { get; set; }
        public Decimal year2Cost { get; set; }
        public Decimal year3Cost { get; set; }
        public Decimal year4Cost { get; set; }
        public Decimal year5Cost { get; set; }
        public Decimal year6Cost { get; set; }
        public Decimal year7Cost { get; set; }
        public Decimal total { get; set; }
        public String lineSequence { get; set; }

        public YearWiseSplitEntry(String productName, String productCode, Decimal year1Cost, Decimal year2Cost,
                                    Decimal year3Cost, Decimal year4Cost, Decimal year5Cost, Decimal year6Cost,
                                    Decimal year7Cost, Decimal total, String lineSequence, Integer quantity){
            this.productName = productName;
            this.productCode = productCode;
            this.year1Cost = year1Cost;
            this.year2Cost = year2Cost;
            this.year3Cost = year3Cost;
            this.year4Cost = year4Cost;
            this.year5Cost = year5Cost;
            this.year6Cost = year6Cost;
            this.year7Cost = year7Cost;
            this.total = total;
            this.lineSequence = lineSequence;
            this.quantity = quantity;
        }
    }
}