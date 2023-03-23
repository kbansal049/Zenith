public without sharing class DealRegConversionLWCHelperCPQ {
    @AuraEnabled
    public static DealRegConversionWrapper init(Id dealregtoconvert){
        DealRegConversionControllerCPQ.dealRegIdfromLWC = dealregtoconvert;
        DealRegConversionControllerCPQ ctrl = new DealRegConversionControllerCPQ();
        ctrl.convertDealReg();

        DealRegConversionWrapper wrp = new DealRegConversionWrapper();
        wrp.convertedOppId = ctrl.convertedOppId;
        wrp.oppList = ctrl.oppWrapperList;
        wrp.dealReg = ctrl.dealReg;
        Map<String, Deal_Reg_Conversion_Matrix_Allow_Cases__c> mapConditions = Deal_Reg_Conversion_Matrix_Allow_Cases__c.getAll();
        Set<String> conditionSet = new Set<String>();

        for(Deal_Reg_Conversion_Matrix_Allow_Cases__c rec: mapConditions.values()){
            conditionSet.add(rec.Current_DR_Type__c + rec.Current_DR_Partner_Type__c + rec.Opportunity_Sourced_Type__c
                                + rec.Opportunity_Sourced_Partner_Type__c + rec.Teaming_Reseller_Type__c + rec.Teaming_Reseller_Partner_Type__c + rec.Teaming_Tech_Type__c + rec.Teaming_Tech_Partner_Type__c);
        }
        wrp.conditionSet = conditionSet;
        return wrp;
    }

    @AuraEnabled
    public static DealRegConversionWrapper convertDRtoOpportunity(String selectedOppId, String drId){
        DealRegConversionWrapper wrp = new DealRegConversionWrapper();
        wrp.oppList = null;
        DealRegConversionControllerCPQ.dealRegIdfromLWC = drId;
        DealRegConversionControllerCPQ ctrl = new DealRegConversionControllerCPQ();
        ctrl.selectedOppId = selectedOppId;
        ctrl.associateDealToOpp();

        wrp.convertedOppId = ctrl.convertedOppId;

        return wrp;
    }



    public class DealRegConversionWrapper{
        @AuraEnabled
        public String convertedOppId{get; set;}
        @AuraEnabled
        public Deal_Reg__c dealReg{get; set;}
        @AuraEnabled
        public Set<String> conditionSet{get; set;}
        @AuraEnabled
        public List<DealRegConversionControllerCPQ.OpportunityListWrapper> oppList{get; set;}

    }
}