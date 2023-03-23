@RestResource(urlMapping='/RENEWALSYNCED/*')
global with sharing class RENEWALSYNCED{

    @HttpGet
    global static Map<String, String> doGet() {
        RestRequest req = RestContext.request;
        Map<String, String> result = new map<String, String>();
        Map<String,String> parmap = new Map<String, String>();
                List<Opportunity> opplst = new List<Opportunity>();
                for(Opportunity opp: [Select Id, ownerId, Sub_Stage__c, Partner_Role__c ,Secondary_Partner__c , Secondary_Partner_Role__c ,Partner_Forecast_Category__c , Partner_Close_Date__c , CampaignId , Primary_Reseller_Partner__c , Deal_Reg_Teaming_Reseller__c  ,Deal_Reg_Margin__c , Primary_Partner_Program__c , Account.Name, RecordTypeId,Stagename, CloseDate, Name,  Forecast_Category__c, Amount, Proposed_Number_of_Users__c, Expected_Term_Months__c , Product_Type__c, type from Opportunity where  Is_Federal_Opportunity_Sync__c = true and type='Existing Customer (Renewal)' ]){
                    opplst.add(opp);
                }
                system.debug(opplst);
                if(!opplst.isEmpty()){
                    result.put('oppresults', JSON.serialize(opplst));
                }
        return result;
    }
}