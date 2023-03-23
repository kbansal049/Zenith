/**
 * @description       : 
 * @author            : Rakshitha
 * @group             : 
 * @last modified on  : 03-25-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Test class: OpportunityPartnerControllerTest
**/
public with sharing class QuotePartnerIncentiveController {
    public class CustomException extends Exception {}
    @InvocableMethod(label='getPartnerIncentive')
    public static List<String> getPartnerIncentive(List<flowInput> flowInput){
        List<String> partnerIncentiveId=new List<String>();
        List<Partner_Incentive__c> partnerIncentiveList = new List<Partner_Incentive__c>();
        Boolean isFederal =false;
        String partnerProgram = flowInput[0].regionAccount=='Federal'?'Summit - Federal':flowInput[0].partnerProgram;
        List<String> federalAccountList = System.Label.FederalAccount.split(';');
        for(String str:federalAccountList){
            if(flowInput[0].oppAccountName.startsWith(str)){
                isFederal= true;
                break;
            }
        }
        string dateField = system.label.PIDatecomparision;
        Date dateComparision = dateField=='System.today()'?(Date)System.today():(Date)flowInput[0].oppCloseDate;
        if(!flowInput[0].isSummitDistribution || isFederal || flowInput[0].regionAccount=='Federal' ){
            partnerIncentiveList = [SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c FROM Partner_Incentive__c WHERE Account__c=: flowInput[0].partnerId AND Active__c = true AND Effective_Start_Date__c <= :dateComparision AND Effective_End_Date__c >=: dateComparision AND Partner_Program__c=:partnerProgram AND Partner_Role__c =:flowInput[0].programType];
        }else{
            String billingCountry = flowInput[0].billingCountry;
            String nonStandardbillingCountry= '%'+billingCountry+'%';
             //if the billing country is not standardized then check from custom metadata
            List<CountryMappingSetting__mdt> countryList = [SELECT StandardCountryName__c,AlternativeCountryNames__c FROM CountryMappingSetting__mdt where AlternativeCountryNames__c Like :nonStandardbillingCountry];
            if(!countryList.isEmpty()){
                billingCountry=countryList[0].StandardCountryName__c;
            }
            partnerIncentiveList = [SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c,Transacting_Location__c,Transacting_Entity__c FROM Partner_Incentive__c WHERE Account__c=: flowInput[0].partnerId AND Active__c = true AND Effective_Start_Date__c <= :dateComparision AND Effective_End_Date__c >=: dateComparision AND Transacting_Location__c=:billingCountry AND Partner_Program__c =:flowInput[0].partnerProgram AND Partner_Role__c =:flowInput[0].programType];
        }
        if(!partnerIncentiveList.isEmpty()){
            
            partnerIncentiveId.add(partnerIncentiveList[0].Id);
        }else{
            throw createCustomException(System.Label.NoPIRecordFound);
        }
        return partnerIncentiveId;
    }
    static CustomException createCustomException(String message) {
        CustomException ex = new CustomException(message);
        ex.setMessage(message);
        return ex;
    }
    public class flowInput{
       @InvocableVariable 
       public String partnerId;
       @InvocableVariable 
       public Boolean isSummitDistribution;
       @InvocableVariable 
       public String billingCountry;
       @InvocableVariable 
       public String partnerProgram;
       @InvocableVariable
       public Date oppCloseDate;
       @InvocableVariable
       public String oppAccountName;
       @InvocableVariable
       public String regionAccount;
       @InvocableVariable
       public String programType;
    }
}