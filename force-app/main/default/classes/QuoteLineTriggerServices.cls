/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-20-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class QuoteLineTriggerServices {
    Map<Id, SBQQ__QuoteLine__c> newMap;
    Map<Id, SBQQ__QuoteLine__c> oldMap;
    List<SBQQ__QuoteLine__c> quoteLineNewList;
    //List<SBQQ__QuoteLine__c> oldQuoteLineList;


    // constructor
    public QuoteLineTriggerServices (List<sObject> quoteLineNewList,Map<Id, sObject> newMap,Map<Id, sObject> oldMap) {
        this.quoteLineNewList = (List<SBQQ__QuoteLine__c>) quoteLineNewList;
        //this.oldQuoteLineList= (List<SBQQ__QuoteLine__c>)oldQuoteLineList;
        this.newMap= (Map<Id, SBQQ__QuoteLine__c>)newMap;
        this.oldMap= (Map<Id, SBQQ__QuoteLine__c>)oldMap;
       
    }
    //added by rakshitha: for ps auto attach for new business to update the correct subscription type. It is not possible to update value from price action or qcp
    public void updateSubscriptionType(List<SBQQ__QuoteLine__c> quoteLineNewList){
     set<Id> product2Id = new Set<Id>();
      for(SBQQ__QuoteLine__c quoteLines: quoteLineNewList){
         product2Id.add(quoteLines.SBQQ__Product__c);
      
      }
      Map<Id,Product2> product2Map= new Map<Id,Product2>( [SELECT Id,SBQQ__SubscriptionType__c From Product2 where id In :product2Id With SECURITY_ENFORCED]);
      String subscriptionType=null;
      for(SBQQ__QuoteLine__c quoteLines: quoteLineNewList){
         subscriptionType = product2Map.get(quoteLines.SBQQ__Product__c).SBQQ__SubscriptionType__c;
        if(quoteLines.SBQQ__ProductSubscriptionType__c !=  subscriptionType){
             quoteLines.SBQQ__ProductSubscriptionType__c = subscriptionType;
             quotelines.SBQQ__SubscriptionType__c = subscriptionType;
         }
      }
     }
    /* public void createYWSLines(List<SBQQ__QuoteLine__c> quoteLineNewList){
        system.debug('inside createYWSLines'+quoteLineNewList+!TriggerUtility.isGenerateYearWiseSplitExecuted());
        if(!quoteLineNewList.isEmpty() && !TriggerUtility.isGenerateYearWiseSplitExecuted()&& !System.isBatch() && !System.isQueueable()){
            Set<Id> quoteIDs = new Set<Id>();
            for(SBQQ__QuoteLine__c qli : quoteLineNewList){
                if(qli.SBQQ__Quote__c!= null){
                    quoteIDs.add(qli.SBQQ__Quote__c);
                }
            }
            
            if(!quoteIDs.isEmpty()){
                List<SBQQ__Quote__c> quotes= new List<SBQQ__Quote__c>();
                quotes= [SELECT Id, Name, Generate_Year_Wise_Split__c, Is_Year_Wise_Split_Data_Incorrect__c,
                                SBQQ__StartDate__c, SBQQ__EndDate__c, 
                                Number_Of_Year_Wise_Split_Years__c,
                                Year_1_Year_Value__c , Year_2_Year_Value__c , Year_3_Year_Value__c , Year_4_Year_Value__c , 
                                Year_5_Year_Value__c , 
                                Year_6_Year_Value__c , Year_7_Year_Value__c , Year_1_Subtotal__c, 
                                Year_2_Subtotal__c, Year_3_Subtotal__c, Year_4_Subtotal__c, Year_5_Subtotal__c, Year_6_Subtotal__c, 
                                Year_7_Subtotal__c, Year_Wise_Split_Total__c, SBQQ__Opportunity2__c, 
                                SBQQ__Account__c,SBQQ__Partner__c,Bill_to__c,SBQQ__Distributor__c
                                FROM SBQQ__Quote__c WHERE Id IN :quoteIDs];
                system.debug('inside createYWSLines'+quotes);
                //if(!System.isBatch() && !System.isQueueable()){
                   system.enqueuejob(new SB_YearWiseSplitUtilQueueable(quotes));
                    TriggerUtility.generateYearWiseSplitExecuted();
                //}                                
            }
        }
    }
    
    public void deleteYWSLines(List<SBQQ__QuoteLine__c> oldQuoteLineList){
        system.debug('inside deleteYWSLines'+oldQuoteLineList);
        if(!oldQuoteLineList.isEmpty() && !System.isBatch() && !System.isQueueable()){
            Set<Id> quoteIDs = new Set<Id>();
            for(SBQQ__QuoteLine__c qli : oldQuoteLineList){
                if(qli.SBQQ__Quote__c!= null){
                    quoteIDs.add(qli.SBQQ__Quote__c);
                }
            }
            
            // Fetch YearWiseSplit Lines to delete
            List<Year_Wise_Split__c> YWSLinesToDelete = new List<Year_Wise_Split__c>();
            YWSLinesToDelete = [SELECT Id, Quote__c FROM Year_Wise_Split__c 
                                    WHERE Quote__c IN : quoteIDs];
            if(!YWSLinesToDelete.isEmpty() && !TriggerUtility.isGenerateYearWiseSplitExecuted()){
                delete YWSLinesToDelete;
                createYWSLines(oldQuoteLineList);
            }
        }
    } */
    
    //CR# 3519 - Start
    /* public void createAnnualBreakdownLines(List<SBQQ__QuoteLine__c> quoteLineNewList){
        system.debug('inside createAnnualBreakdownLines');
        if(!quoteLineNewList.isEmpty() && !TriggerUtility.iscreateAnnualBreakdownLinesExecuted() && !System.isBatch() && !System.isQueueable()){
            Set<Id> quoteIDs = new Set<Id>();
            for(SBQQ__QuoteLine__c qli : quoteLineNewList){
                if(qli.SBQQ__Quote__c!= null){
                    quoteIDs.add(qli.SBQQ__Quote__c);
                }
            }
            
            if(!quoteIDs.isEmpty()){
                system.debug('Quote IDs >>'+quoteIDs);
                system.enqueuejob(new AnnualBreakdownUtilQueueable(quoteIDs));
                TriggerUtility.createAnnualBreakdownLinesExecuted();
            }
        }
    }

    public void deleteAnnualBreakdownLines(List<SBQQ__QuoteLine__c> oldQuoteLineList){
        system.debug('inside deleteYWSLines'+oldQuoteLineList);
        //if(!oldQuoteLineList.isEmpty() && !System.isBatch() && !System.isQueueable()){
            Set<Id> quoteIDs = new Set<Id>();
            for(SBQQ__QuoteLine__c qli : oldQuoteLineList){
                if(qli.SBQQ__Quote__c!= null){
                    quoteIDs.add(qli.SBQQ__Quote__c);
                }
            }
            
            // Fetch Annual Breakdown Lines to delete
            List<Annual_Breakdown__c> ABDLinesToDelete = new List<Annual_Breakdown__c>();
            ABDLinesToDelete = [SELECT Id, Quote__c FROM Annual_Breakdown__c WHERE Quote__c IN : quoteIDs];
            delete ABDLinesToDelete;
        //}
    } */
    
    //CR# 3519 - End

    /* public void checkUpdatedValues(List<SBQQ__QuoteLine__c> quoteLineNewList,Map<Id,SBQQ__QuoteLine__c> oldMap){
        List<SBQQ__QuoteLine__c> qliToProcess = new List<SBQQ__QuoteLine__c>();
        Map<String,Boolean> quoteVsYWS = new Map<String,Boolean>();
        if(!System.isBatch() && !System.isQueueable()){
        for(SBQQ__QuoteLine__c qli : quoteLineNewList){
            if(qli.SBQQ__Quote__c!= null){
                quoteVsYWS.put(qli.SBQQ__Quote__c,false);
            }
        }
        if(!quoteVsYWS.isEmpty()){
            for(Year_Wise_Split__c ywsRecord : [SELECT Id, Quote__c FROM Year_Wise_Split__c WHERE Quote__c IN : quoteVsYWS.keySet()]){
                quoteVsYWS.put(ywsRecord.Quote__c,true);
            }
        }
        system.debug('quoteVsYWS'+quoteVsYWS);
        for(SBQQ__QuoteLine__c qli : quoteLineNewList){
            Boolean ywsPresent = quoteVsYWS.get(qli.SBQQ__Quote__c);
            if(qli.SBQQ__StartDate__c != oldMap.get(qli.Id).SBQQ__StartDate__c || qli.SBQQ__EndDate__c != oldMap.get(qli.Id).SBQQ__EndDate__c || qli.SBQQ__Quantity__c != oldMap.get(qli.Id).SBQQ__Quantity__c || qli.SBQQ__NetTotal__c != oldMap.get(qli.Id).SBQQ__NetTotal__c || ywsPresent== false){
                qliToProcess.add(qli);
            }
        }
        
        // Fetch YearWiseSplit Lines to delete
        if(!qliToProcess.isEmpty() && !TriggerUtility.isGenerateYearWiseSplitExecuted()){
            deleteYWSLines(qliToProcess);
            createYWSLines(qliToProcess);
        }
      }
    } */

    public void createAnnualBreakdownYWSLines(List<SBQQ__QuoteLine__c> quoteLineNewList){
        system.debug('inside createAnnualBreakdownLines');
        // IBA-5540 TriggerUtility.quoteTriggerforAnnualBreakDown==False added to condition
        if(!quoteLineNewList.isEmpty() && !TriggerUtility.iscreateAnnualBreakdownLinesExecuted() && !System.isBatch() && !System.isQueueable() && TriggerUtility.quoteTriggerforAnnualBreakDown==False){
        //if(!quoteLineNewList.isEmpty() && !TriggerUtility.iscreateAnnualBreakdownLinesExecuted()){
            Set<Id> quoteIDs = new Set<Id>();
            for(SBQQ__QuoteLine__c qli : quoteLineNewList){
                if(qli.SBQQ__Quote__c!= null){
                    quoteIDs.add(qli.SBQQ__Quote__c);
                }
            }
            
            if(!quoteIDs.isEmpty() ){
                system.debug('Quote IDs >>'+quoteIDs);
                system.enqueuejob(new AnnualBreakdownYWSUtilQueueable(quoteIDs));
                TriggerUtility.createAnnualBreakdownLinesExecuted();
            }
        }
    }

    public void deleteAnnualBreakdownYWSLines(List<SBQQ__QuoteLine__c> oldQuoteLineList){
        system.debug('inside deleteAnnualBreakdownYWSLines'+oldQuoteLineList);
        Set<Id> quoteIDs = new Set<Id>();
        for(SBQQ__QuoteLine__c qli : oldQuoteLineList){
            if(qli.SBQQ__Quote__c!= null){
                quoteIDs.add(qli.SBQQ__Quote__c);
            }
        }
        
        // Fetch Annual Breakdown and YWS Lines to delete
        List<Annual_Breakdown__c> ABDLinesToDelete = [SELECT Id, Quote__c FROM Annual_Breakdown__c WHERE Quote__c IN : quoteIDs];
        List<Year_Wise_Split__c> YWSLinesToDelete = [SELECT Id, Quote__c FROM Year_Wise_Split__c WHERE Quote__c IN : quoteIDs];
        delete ABDLinesToDelete;
        delete YWSLinesToDelete;
    }
    
   /*public void setFinanceTerm(List<SBQQ__QuoteLine__c> listNewQLs){
        for(SBQQ__QuoteLine__c objQL: listNewQLs ){
            objQL.Finance_Term__c = objQL.Finance_Term1__c;
        }
    }*/
    //This Method is created for Data Migration
    public void setSortOrder(List<SBQQ__QuoteLine__c> quoteLineNewList){
        Set<Id> QLIds = new Set<Id>();
        for(SBQQ__QuoteLine__c objQL: quoteLineNewList){
            QLIds.add(objQL.Id);
        }
        List<SBQQ__QuoteLine__c> QLList = [SELECT Id, SBQQ__UpgradedSubscription__c, SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__c, SBQQ__RenewedSubscription__c, SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c, SBQQ__UpgradedSubscription__r.SBQQ__Number__c, SBQQ__RenewedSubscription__r.SBQQ__Number__c FROM SBQQ__QuoteLine__c WHERE Id IN : QLIds];
        for(SBQQ__QuoteLine__c QL : QLList){
            if(QL.SBQQ__UpgradedSubscription__c != NULL && QL.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__c == NULL){
                QL.Sort_Order__c =  String.valueof(QL.SBQQ__UpgradedSubscription__r.SBQQ__Number__c);
            }
            if(QL.SBQQ__RenewedSubscription__c != NULL && QL.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c == NULL){
                QL.Sort_Order__c =  String.valueof(QL.SBQQ__RenewedSubscription__r.SBQQ__Number__c);
            }
        }  
    } 
    //End
    
    public void resetAdditionalDiscountAmountForRenewals(List<SBQQ__QuoteLine__c> quoteLineNewList){
        if(TriggerUtility.blnQLInsert ){
            
            for(SBQQ__QuoteLine__c objQL: quoteLineNewList){
                if(objQL.SBQQ__RenewedSubscription__c!=null  && objQL.SBQQ__AdditionalDiscountAmount__c!=null){
                    objQL.SBQQ__AdditionalDiscountAmount__c = null;   
                }
            }
        }
    }
    
    public void resetRampFieldsOnRenewal(List<SBQQ__QuoteLine__c> quoteLineNewList){
        system.debug('inside method');
       if(TriggerUtility.blnQLInsert ){
       Map<Id,Boolean> earlyRenewalQuoteMap = new Map<Id,Boolean>();
        for(SBQQ__QuoteLine__c objQuoteLine: quoteLineNewList){
            earlyRenewalQuoteMap.put(objQuoteLine.SBQQ__Quote__c,false);
        }
           
        for(SBQQ__Quote__c quoteRec : [SELECT Id,Early_Renewal__c From SBQQ__Quote__c where Id In :earlyRenewalQuoteMap.keySet()]){
            earlyRenewalQuoteMap.put(quoteRec.Id,quoteRec.Early_Renewal__c);
        }
           for(SBQQ__QuoteLine__c objQuoteLine: quoteLineNewList){
               system.debug('SBQQ__RenewedSubscription__c '+objQuoteLine.SBQQ__RenewedSubscription__c);               
               if((objQuoteLine.SBQQ__RenewedSubscription__c!=null && objQuoteLine.Ramp_UniqueKey__c ==null) ||earlyRenewalQuoteMap.get(objQuoteLine.SBQQ__Quote__c) && objQuoteLine.Ramp_Origin__c == null ){
                  objQuoteLine.Is_Ramped__c = false;
                  objQuoteLine.Show_Ramp__c = false;
                  objQuoteLine.Ramp_Label__c = null;  
               }
           }
       }
    }  
    /* created by Rakshitha
    JIRA-IBA-1279 - To upgrade the products based on the records from the custom object */
    public void upgradeProducts(List<SBQQ__QuoteLine__c> quoteLineNewList){
        Set<Id> quoteIDs = new Set<Id>();
        //Map<String,String> prodRequiredMap = new Map<String,String>();
        Set<Id> productIds = new Set<Id>();
        
        //get the quote Id and product Ids
        for(SBQQ__QuoteLine__c  qli: quoteLineNewList){
            if(qli.SBQQ__Quote__c!= null){
                quoteIDs.add(qli.SBQQ__Quote__c);
            }
            if(qli.SBQQ__ProductCode__c !=null && qli.SBQQ__ProductOption__c !=null){
                productIds.add(qli.SBQQ__Product__c);
            }
        }
        List<String> priceList = new List<String>();
        Map<String,String> quotePriceListMap = new Map<String,String>();
        //create a map of quote Id and priceList
        for(SBQQ__Quote__c quoteRec : [SELECT ID,Price_List__c,SBQQ__Opportunity2__r.RecordType.Name FROM SBQQ__Quote__c WHERE Id In :quoteIDs and SBQQ__Opportunity2__r.RecordType.Name ='Renewal Opportunity' WITH SECURITY_ENFORCED]){
            priceList.add(quoteRec.Price_List__c);
            quotePriceListMap.put(quoteRec.Id,quoteRec.Price_List__c);
        }
        upgradeFunctionProcess(priceList,quotePriceListMap,productIds,quoteLineNewList);
      }
 public static List<CPQ_Generic_Object__c> getCPQGenricObject(List<String> priceList, Set<Id> productIds,String recordTypeId){
    return [SELECT Original_SKU__c,Upgrade_SKU__c,Upgrade_SKU_Code__c,Price_List__c FROM CPQ_Generic_Object__c WHERE Price_List__c In: priceList and Original_SKU__c In:productIds and RecordTypeId=:recordTypeId WITH SECURITY_ENFORCED];
 } 
 
 public static List<SBQQ__ProductOption__c> getProductOption(Set<Id> upgradeSku){
    return [SELECT Id,SBQQ__OptionalSKU__c,SBQQ__ConfiguredSKU__c FROM SBQQ__ProductOption__c where SBQQ__OptionalSKU__c IN:upgradeSku WITH SECURITY_ENFORCED];
 }

 public static List<SBQQ__QuoteLine__c> upgradeFunctionProcess(List<String> priceList, Map<String,String> quotePriceListMap,Set<Id> productIds,List<SBQQ__QuoteLine__c> quoteLineNewList){
   
    Map<String,CPQ_Generic_Object__c> upgradePrdMap = new Map<String,CPQ_Generic_Object__c>();
    
    set<Id> upgradeSku = new Set<Id>();
    List<SBQQ__QuoteLine__c> quoteLineUpdateList = new List<SBQQ__QuoteLine__c>();
    String key=null;
         
        if(!priceList.isEmpty()){
            //query generic object and create a map
            String recordTypeId = Schema.SObjectType.CPQ_Generic_Object__c.getRecordTypeInfosByDeveloperName().get('Product_Upgrade').getRecordTypeId();
            for(CPQ_Generic_Object__c cpqObjectRec:getCPQGenricObject(priceList,productIds,recordTypeId)){
                upgradePrdMap.put(cpqObjectRec.Original_SKU__c+';'+cpqObjectRec.Price_List__c,cpqObjectRec);
                upgradeSku.add(cpqObjectRec.Upgrade_SKU__c);
                upgradeSku.add(cpqObjectRec.Original_SKU__c);
            }
            if(!upgradeSku.isEmpty()){
          
                Map<String,Map<String,String>>newOptionMap = new Map<String,Map<String,String>>();
                Map<String,String> optionAndParent = new Map<String,String>();
                for(SBQQ__ProductOption__c option:getProductOption(upgradeSku)){
                    if(!newOptionMap.containsKey(option.SBQQ__ConfiguredSKU__c)){
                        newOptionMap.put(option.SBQQ__ConfiguredSKU__c,new Map<String,String>());
                    }
                    newOptionMap.get(option.SBQQ__ConfiguredSKU__c).put(option.SBQQ__OptionalSKU__c,option.Id);
                    optionAndParent.put(option.Id,option.SBQQ__ConfiguredSKU__c);
                }
                Map<String,String> temp= new Map<String,String>();
                string upgradePrd=null;
                
                for(SBQQ__QuoteLine__c  qli: quoteLineNewList){
                    //create a key product Id +';'+ quote price list and update the product with upgraded sku from the custom object
                    key = qli.SBQQ__Product__c+';'+quotePriceListMap.get(qli.SBQQ__Quote__c);
                    if(qli.SBQQ__Quote__c!= null && upgradePrdMap.containsKey(key)){
                        upgradePrd=upgradePrdMap.get(key).Upgrade_SKU__c;
                        if(optionAndParent.containsKey(qli.SBQQ__ProductOption__c)){
                            temp=newOptionMap.get(optionAndParent.get(qli.SBQQ__ProductOption__c));
                            qli.SBQQ__ProductOption__c = temp.get(upgradePrd);
                        }
                        qli.SBQQ__Product__C = upgradePrd;
                        qli.Auto_upgraded__c = true;
                        quoteLineUpdateList.add(qli);
                    }
                }
            }   
        }  
        return quoteLineUpdateList; 
}
 
}