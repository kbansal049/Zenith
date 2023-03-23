/**
 * @description       : 
 * @author            : Madhusudan Desai
 * @modified by       : Rakshitha
 * @group             : 
 * @last modified on  : 02-10-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class premSupportLWCController {
    
    @AuraEnabled
    public static PremSupportWrapper getQuoteDetails(String QuoteId){
        List<String> pickListValuesList = new List<string>();
        try {
            Boolean federalSku = false;
            SBQQ__Quote__c quoteObj =[SELECT ID,Name,Price_List__c,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Approved_PRE_SKUs_ER__c,SBQQ__Opportunity2__r.Country_Language__c,Approved_SKUs__c,Support_Type__c,(SELECT ID,SBQQ__ProductCode__c,Remaining_Prem_Support_ACV__c,ACV_New__c,SBQQ__SpecialPrice__c,TAM_Coverage__c,SBQQ__UpgradedSubscription__c,SBQQ__UpgradedSubscription__r.TAM_Coverage__c,SBQQ__UpgradedSubscription__r.Support_Type_Product_Code__c,SBQQ__RenewedSubscription__c,SBQQ__RenewedSubscription__r.TAM_Coverage__c,SBQQ__RenewedSubscription__r.Support_Type_Product_Code__c FROM SBQQ__LineItems__r WHERE (SBQQ__ProductCode__c = 'ZCES-SUP-PREM' OR SBQQ__ProductCode__c ='ZCES-SUP-PREM-FED')) FROM SBQQ__Quote__c WHERE Id=:QuoteId WITH SECURITY_ENFORCED];
            if(quoteObj!=null && !quoteObj.SBQQ__LineItems__r.isEmpty() && quoteObj.SBQQ__LineItems__r[0].SBQQ__ProductCode__c == 'ZCES-SUP-PREM-FED'){
                federalSku = true;
            }
            List<Premium_support_range__c> premRangeList = [SELECT ID,Name,Support_Type__c,TAM_Coverage__c,Maximum_Price_Range__c,Minimum_Price_Range__c,Product_Code__c,Description__c FROM Premium_support_range__c WHERE IsFederalSKU__c=:federalSku AND Price_List__c Includes(:quoteObj.Price_List__c) WITH SECURITY_ENFORCED ORDER BY Product_Display_Order__c];
            List<Equipment_Request__c> equipList = [SELECT Id,Account_ID__c, Account_Name__c,Approval_Status__c,Product__r.name,Product__r.ProductCode from Equipment_Request__c where Opportunity__c =: quoteObj.SBQQ__Opportunity2__c and (Product__r.Name like '%Premium support plus%'  OR (Product__r.ProductCode='ZCES-SUP-PREM-IN-CTRY' OR Product__r.ProductCode='ZCES-SUP-PREM-TAM-ESS-PRE')) WITH SECURITY_ENFORCED order by LastModifiedDate asc ];
            List<Product2> prodList = [SELECT Id,name,ProductCode FROM Product2 WHERE name LIKE 'Premium support plus%' OR ProductCode='ZCES-SUP-PREM-IN-CTRY' OR ProductCode='ZCES-SUP-PREM-TAM-ESS-PRE' WITH SECURITY_ENFORCED];
            Map<String,Product2> prodMap = new Map<string,Product2>();
            if(!prodList.isEmpty() && prodList != NULL){
                for(Product2 prod : prodList){
                    prodMap.put(prod.productCode,prod);
                }
            }
            List<PremSupportSKUWrapper> premList = new List<PremSupportSKUWrapper>();
            String renewedTAMCoverage = '';
            String amendedTAMCoverage ='';
            system.debug('premium'+equipList);
            Map<String,String> equementRequestPrd = new Map<String,String>();

            for(Equipment_Request__c equ : equipList){
                equementRequestPrd.put(equ.Product__r.ProductCode,equ.Approval_Status__c);
            }

            if(!quoteObj.SBQQ__LineItems__r.isEmpty()){
                renewedTAMCoverage = quoteObj.SBQQ__LineItems__r[0].SBQQ__RenewedSubscription__c !=null ?quoteObj.SBQQ__LineItems__r[0].SBQQ__RenewedSubscription__r.TAM_Coverage__c:'';
                amendedTAMCoverage = quoteObj.SBQQ__LineItems__r[0].SBQQ__UpgradedSubscription__c !=null ?quoteObj.SBQQ__LineItems__r[0].SBQQ__UpgradedSubscription__r.TAM_Coverage__c:'';
            }
            
            for(Premium_support_range__c pr: premRangeList){
                PremSupportSKUWrapper eachWrapper = new PremSupportSKUWrapper(pr.Name,'Use this support type',TRUE,'Neutral',pr.Support_Type__c,pr.TAM_Coverage__c,pr.Minimum_Price_Range__c,pr.Description__c,pr.Product_Code__c,'Not Applicable',TRUE,'','',pickListValuesList);
                if(pr.TAM_Coverage__c == '8/5 TAM Coverage'){
                    eachWrapper.isDisabled = FALSE;
                    if(federalSku == false && (quoteObj.SBQQ__LineItems__r != NULL && !quoteObj.SBQQ__LineItems__r.isempty()) && (/*(quoteObj.SBQQ__LineItems__r[0].TAM_Coverage__c == '8/5 TAM Coverage' && (quoteObj.SBQQ__LineItems__r[0].SBQQ__SpecialPrice__c+quoteObj.SBQQ__LineItems__r[0].Remaining_Prem_Support_ACV__c) > 30000) ||*/
                                                                                                           (quoteObj.SBQQ__LineItems__r[0].TAM_Coverage__c == '16/5 TAM Coverage' && (quoteObj.SBQQ__LineItems__r[0].SBQQ__SpecialPrice__c+quoteObj.SBQQ__LineItems__r[0].Remaining_Prem_Support_ACV__c) > 45000)||
                                                                                                           (quoteObj.SBQQ__LineItems__r[0].TAM_Coverage__c == '24/5 TAM Coverage' && (quoteObj.SBQQ__LineItems__r[0].SBQQ__SpecialPrice__c+quoteObj.SBQQ__LineItems__r[0].Remaining_Prem_Support_ACV__c) > 60000)) && pr.Support_Type__c == 'Premium Support'){
                        eachWrapper.isDisabled = TRUE;
                    }
                   
                   /* if(federalSku && !quoteObj.SBQQ__LineItems__r.isempty() && (quoteObj.SBQQ__LineItems__r[0].SBQQ__SpecialPrice__c+quoteObj.SBQQ__LineItems__r[0].Remaining_Prem_Support_ACV__c) > 34500 && pr.Support_Type__c == 'Premium Support'){
                        eachWrapper.isDisabled = TRUE;
                    }*/
                   
                }
                if(pr.TAM_Coverage__c == '16/5 TAM Coverage' || pr.TAM_Coverage__c == '24/5 TAM Coverage' || pr.TAM_Coverage__c == '8/5 TAM Coverage -In country' || pr.TAM_Coverage__c == '8/5 TAM Coverage -TAM Essential'){
                    eachWrapper.buttonNamePS = 'Create Request';
                    eachWrapper.isDisabledPS = FALSE;
                    if(!prodMap.isEmpty() && prodMap.containsKey(pr.Product_Code__c)){
                        eachWrapper.productId = prodMap.get(pr.Product_Code__c).Id;
                    }
                   
                    if(equementRequestPrd.containsKey(pr.Product_Code__c)){
                        eachWrapper.buttonNamePS = equementRequestPrd.get(pr.Product_Code__c);
                        eachWrapper.isDisabledPS = TRUE;
                    }
                    if((quoteObj.SBQQ__Opportunity2__r.Approved_PRE_SKUs_ER__c!=null && quoteObj.SBQQ__Opportunity2__r.Approved_PRE_SKUs_ER__c.contains(pr.Product_Code__c)) || amendedTAMCoverage == pr.TAM_Coverage__c || renewedTAMCoverage == pr.TAM_Coverage__c){
                        eachWrapper.isDisabled = FALSE;
                        eachWrapper.buttonNamePS = 'Request Approved';
                        eachWrapper.isDisabledPS = TRUE;
                    }
                }
                if(pr.Name == quoteObj.Support_Type__c){
                    eachWrapper.cssClass = 'brand';
                    eachWrapper.buttonName = 'Applied support type';   
                }
                if(pr.Product_Code__c == 'ZCES-SUP-PREM-IN-CTRY' && quoteObj.SBQQ__Opportunity2__r.Country_Language__c!=null){
                   pickListValuesList = quoteObj.SBQQ__Opportunity2__r.Country_Language__c.split(';');
                    if(!pickListValuesList.isEmpty()){
                        eachWrapper.CountryLanguage = pickListValuesList[0];
                        eachWrapper.globalPicklistValue = pickListValuesList;
                    }
                   
                }
                premList.add(eachWrapper);
            }
            system.debug('premList : '+premList);
             //system.debug('EachWreapper : 'premList);
            PremSupportWrapper preWrap = new PremSupportWrapper(quoteObj,premList);             
            return preWrap;     
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class PremSupportWrapper{
        @AuraEnabled public SBQQ__Quote__c quoteObj;
        @AuraEnabled public List<PremSupportSKUWrapper> premRecords;
        public PremSupportWrapper(SBQQ__Quote__c quoteObj, List<PremSupportSKUWrapper> premRecords){
            this.quoteObj = quoteObj;
            this.premRecords = premRecords;
        }
    }
    public class PremSupportSKUWrapper{
        @AuraEnabled public string name;
        @AuraEnabled public string buttonName;
        @AuraEnabled public Boolean isDisabled;
        @AuraEnabled public string cssClass;
        @AuraEnabled public string supportType;
        @AuraEnabled public string tamCoverage;
        @AuraEnabled public decimal miniRange;
        @AuraEnabled public string description;
        @AuraEnabled public string CountryLanguage; //Adding Country/Language
        @AuraEnabled public string productCode;
        @AuraEnabled public string buttonNamePS;
        @AuraEnabled public Boolean isDisabledPS;
        @AuraEnabled public string productId;
        @AuraEnabled public List<string> globalPicklistValue;
       
        public PremSupportSKUWrapper(String name, String buttonName, Boolean isDisabled, String cssClass, string supportType, string tamCoverage, decimal miniRange, string description,String productCode,String buttonNamePS, Boolean isDisabledPS, String productId,string CountryLanguage,List<string> globalPicklistValue){
            this.name = name;
            this.buttonName = buttonName;
            this.isDisabled = isDisabled;
            this.cssClass = cssClass;
            this.supportType = supportType;
            this.tamCoverage = tamCoverage;
            this.miniRange = miniRange;
            this.description = description;
            this.productCode = productCode;
            this.buttonNamePS = buttonNamePS;
            this.isDisabledPS = isDisabledPS;
            this.productId = productId;
            this.CountryLanguage = CountryLanguage;
            this.globalPicklistValue = globalPicklistValue;
        }
    }
    @AuraEnabled
    public static void deleteYWS(String QuoteId){
        List<Year_Wise_Split__c> ywsRecord = [SELECT Id, Quote__c FROM Year_Wise_Split__c WHERE Quote__c =:QuoteId WITH SECURITY_ENFORCED];
        if(!ywsRecord.isEmpty() && Schema.sObjectType.Year_Wise_Split__c.isDeletable()){
            delete ywsRecord;
        }
    }
    @AuraEnabled
    public static void sendPSApproval(Id PsRecordId){
        try {
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments('P&S request was submitted from configure premium support page.');
            approvalRequest.setObjectId(PsRecordId);
            if(!test.isRunningTest()){
                //below line is commented part of the critical issue fix for IBA-4044
            	//Approval.ProcessResult approvalResult = 
                Approval.process(approvalRequest);    
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}