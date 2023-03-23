@RestResource(urlMapping='/EgressLocation/*')
global with sharing class EgressLocationRestService 
{
    @HttpGet
    global static void doGet() 
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Map<String, String> requestParams = req.params;
        String endpoint = req.requestURI;
        
        Map<Id, EgressLocationWrapper> EgressMap = new Map<Id, EgressLocationWrapper>();
        
            List<Egress_Location__c> openEgressRequests = [Select Id, Account__c,Account__r.Name,
                Internet_Egree_Location__c,Egress_Location_Country__c,Connectivity__c,Current_bandwidth_utilization__c,
                Level_of_Urgency__c,Nearest_Datacetner_Location_Proposed__c,Nearest_Zscaler_Datacenter__c,
                Egress_Location__r.Proposed_Number_of_Users__c,Egress_Location__r.Forecast_Category__c,Egress_Location__r.CloseDate,Egress_Location__r.Region_Account__c,
                Number_of_users__c, Egress_Location__c,Egress_Location__r.Name,Egress_Location__r.Amount,Egress_Location__r.StageName,Egress_Location__r.Opportunity_Sales_Engineer__r.Full_Name__c,
                Patch_GEO__c,Reasons_for_DC_Request__c,Request_New_Zscaler_Data_Center__c from Egress_Location__c where Egress_Location__r.isClosed=false];
            
                for (Egress_Location__c egressLocation : openEgressRequests) 
                {
                    EgressLocationWrapper wrapper = new EgressLocationWrapper();
                    wrapper.egressRequestId = egressLocation.Id;
                    wrapper.region = egressLocation.Egress_Location__r.Region_Account__c;
                    wrapper.accountId = egressLocation.Account__c;
                    wrapper.accountName = egressLocation.Account__r.Name;
                    wrapper.opportunityId = egressLocation.Egress_Location__c;
                    wrapper.opportunityName = egressLocation.Egress_Location__r.Name;
                    wrapper.amount = egressLocation.Egress_Location__r.Amount;
                    wrapper.closeDate = egressLocation.Egress_Location__r.CloseDate;
                    wrapper.salesEngineerName = egressLocation.Egress_Location__r.Opportunity_Sales_Engineer__r.Full_Name__c;
                    wrapper.numberOfUsers = egressLocation.Number_of_users__c;
                    wrapper.forecastCategory = egressLocation.Egress_Location__r.Forecast_Category__c;                 
                    wrapper.nearestZscalerDataCenter =  egressLocation.Nearest_Zscaler_Datacenter__c;
                    wrapper.egressLocationName = egressLocation.Internet_Egree_Location__c;
                    wrapper.egressLocationCountry = egressLocation.Egress_Location_Country__c;
                          
                    EgressMap.put(egressLocation.Id, wrapper);
                }

                res.responseBody = Blob.valueOf(JSON.serialize(EgressMap));
                res.statusCode = 200;
        

    }

    
    global class EgressLocationWrapper{
        public String egressRequestId;
        public String region;
        public String accountId;
        public String accountName;
        public String opportunityId;
        public String opportunityName;
        public Decimal amount;
        public Date closeDate;
        public String salesEngineerName;
        public Decimal numberOfUsers;
        public String forecastCategory;
        public String nearestZscalerDataCenter;
        public String egressLocationName;
        public String egressLocationCountry;

  
}

    public class EgressLocatioException extends Exception {

    }
}