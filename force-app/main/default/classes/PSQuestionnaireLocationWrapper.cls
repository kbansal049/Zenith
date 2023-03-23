global without sharing class PSQuestionnaireLocationWrapper extends OneDoc.BaseTemplateDataProvider {
    public override Object provide(Map<String, String> params) { 
        List<LocationWrapper> locationLst = new List<LocationWrapper>();
        List<PS_Questionnaire__c> psqList = [select id, Location_Name_1__c, Location_City_State_Country_1__c, Approx_Peak_Bandwidth_Seen_1__c, Traffic_Routing_1__c, Available_Infrastructure_1__c,Location_Name_2__c, Location_City_State_Country_2__c, Approx_Peak_Bandwidth_Seen_2__c, Traffic_Routing_2__c, Available_Infrastructure_2__c, Location_Name_3__c,Location_City_State_Country_3__c, Approx_Peak_Bandwidth_Seen_3__c, Traffic_Routing_3__c, Available_Infrastructure_3__c,Location_Name_4__c,Location_City_State_Country_4__c, Approx_Peak_Bandwidth_Seen_4__c, Traffic_Routing_4__c, Available_Infrastructure_4__c,Location_Name_5__c, Location_City_State_Country_5__c, Approx_Peak_Bandwidth_Seen_5__c, Traffic_Routing_5__c, Available_Infrastructure_5__c from PS_Questionnaire__c where Id=:params.get('Id')];
        if(!psqList.isEmpty()){
            if(!String.isBlank(psqList[0].Location_Name_1__c) && !String.isBlank(psqList[0].Location_City_State_Country_1__c)){
                 locationLst.add(new LocationWrapper(psqList[0].Location_Name_1__c, psqList[0].Location_City_State_Country_1__c, psqList[0].Approx_Peak_Bandwidth_Seen_1__c, psqList[0].Available_Infrastructure_1__c, psqList[0].Traffic_Routing_1__c));   
            }
            if(!String.isBlank(psqList[0].Location_Name_2__c) && !String.isBlank(psqList[0].Location_City_State_Country_2__c)){
                 locationLst.add(new LocationWrapper(psqList[0].Location_Name_2__c, psqList[0].Location_City_State_Country_2__c, psqList[0].Approx_Peak_Bandwidth_Seen_2__c, psqList[0].Available_Infrastructure_2__c, psqList[0].Traffic_Routing_2__c));   
            }
            if(!String.isBlank(psqList[0].Location_Name_3__c) && !String.isBlank(psqList[0].Location_City_State_Country_3__c)){
                 locationLst.add(new LocationWrapper(psqList[0].Location_Name_3__c, psqList[0].Location_City_State_Country_3__c, psqList[0].Approx_Peak_Bandwidth_Seen_3__c, psqList[0].Available_Infrastructure_3__c, psqList[0].Traffic_Routing_3__c));   
            }
            if(!String.isBlank(psqList[0].Location_Name_4__c) && !String.isBlank(psqList[0].Location_City_State_Country_4__c)){
                 locationLst.add(new LocationWrapper(psqList[0].Location_Name_4__c, psqList[0].Location_City_State_Country_4__c, psqList[0].Approx_Peak_Bandwidth_Seen_4__c, psqList[0].Available_Infrastructure_4__c, psqList[0].Traffic_Routing_4__c));   
            }
            if(!String.isBlank(psqList[0].Location_Name_5__c) && !String.isBlank(psqList[0].Location_City_State_Country_5__c)){
                 locationLst.add(new LocationWrapper(psqList[0].Location_Name_5__c, psqList[0].Location_City_State_Country_5__c, psqList[0].Approx_Peak_Bandwidth_Seen_5__c, psqList[0].Available_Infrastructure_5__c, psqList[0].Traffic_Routing_5__c));   
            }
        }
        return JSON.serialize(locationLst);
    }
    global class LocationWrapper{
        global String locationname;
        global String locationcity;
        global String bandwidth;
        global String availableinfra;
        global String topology;
        global LocationWrapper(string locationName, string locationCity, string bandwidth, string availableInfra, string topology){
            this.locationname = locationName;
            this.locationcity = locationCity;
            this.bandwidth = bandwidth;
            this.availableinfra = availableInfra;
            this.topology = topology;
        }
    }
}