global without sharing class PSQuestionnaireTopLocationsWrapper extends OneDoc.BaseTemplateDataProvider {
    public override Object provide(Map<String, String> params) {
        String locationname1='N/A';
        String locationcity1='N/A';
        String bandwidth1='N/A';
        String availableinfra1='N/A';
        String topology1='N/A';
        String locationname2='N/A';
        String locationcity2='N/A';
        String bandwidth2='N/A';
        String availableinfra2='N/A';
        String topology2='N/A';
        String locationname3='N/A';
        String locationcity3='N/A';
        String bandwidth3='N/A';
        String availableinfra3='N/A';
        String topology3='N/A';
        String locationname4='N/A';
        String locationcity4='N/A';
        String bandwidth4='N/A';
        String availableinfra4='N/A';
        String topology4='N/A';
        String locationname5='N/A';
        String locationcity5='N/A';
        String bandwidth5='N/A';
        String availableinfra5='N/A';
        String topology5='N/A';
        List<PS_Questionnaire__c> psqList = [select id, Location_Name_1__c, Location_City_State_Country_1__c, Approx_Peak_Bandwidth_Seen_1__c, Traffic_Routing_1__c, Available_Infrastructure_1__c,Location_Name_2__c, Location_City_State_Country_2__c, Approx_Peak_Bandwidth_Seen_2__c, Traffic_Routing_2__c, Available_Infrastructure_2__c, Location_Name_3__c,Location_City_State_Country_3__c, Approx_Peak_Bandwidth_Seen_3__c, Traffic_Routing_3__c, Available_Infrastructure_3__c,Location_Name_4__c,Location_City_State_Country_4__c, Approx_Peak_Bandwidth_Seen_4__c, Traffic_Routing_4__c, Available_Infrastructure_4__c,Location_Name_5__c, Location_City_State_Country_5__c, Approx_Peak_Bandwidth_Seen_5__c, Traffic_Routing_5__c, Available_Infrastructure_5__c from PS_Questionnaire__c where Id=:params.get('Id')];
        if(!psqList.isEmpty()){
            if(!String.isBlank(psqList[0].Location_Name_1__c) && !String.isBlank(psqList[0].Location_City_State_Country_1__c)){
                locationname1=psqList[0].Location_Name_1__c;
                locationcity1=psqList[0].Location_City_State_Country_1__c;
                bandwidth1=psqList[0].Approx_Peak_Bandwidth_Seen_1__c;
                availableinfra1=psqList[0].Available_Infrastructure_1__c;
                topology1=psqList[0].Traffic_Routing_1__c;
            }
            if(!String.isBlank(psqList[0].Location_Name_2__c) && !String.isBlank(psqList[0].Location_City_State_Country_2__c)){
                locationname2=psqList[0].Location_Name_2__c;
                locationcity2=psqList[0].Location_City_State_Country_2__c;
                bandwidth2=psqList[0].Approx_Peak_Bandwidth_Seen_2__c;
                availableinfra2=psqList[0].Available_Infrastructure_2__c;
                topology2=psqList[0].Traffic_Routing_2__c;
            }
            if(!String.isBlank(psqList[0].Location_Name_3__c) && !String.isBlank(psqList[0].Location_City_State_Country_3__c)){
                locationname3=psqList[0].Location_Name_3__c;
                locationcity3=psqList[0].Location_City_State_Country_3__c;
                bandwidth3=psqList[0].Approx_Peak_Bandwidth_Seen_3__c;
                availableinfra3=psqList[0].Available_Infrastructure_3__c;
                topology3=psqList[0].Traffic_Routing_3__c;
            }
            if(!String.isBlank(psqList[0].Location_Name_4__c) && !String.isBlank(psqList[0].Location_City_State_Country_4__c)){
                locationname4=psqList[0].Location_Name_4__c;
                locationcity4=psqList[0].Location_City_State_Country_4__c;
                bandwidth4=psqList[0].Approx_Peak_Bandwidth_Seen_4__c;
                availableinfra4=psqList[0].Available_Infrastructure_4__c;
                topology4=psqList[0].Traffic_Routing_4__c;
            }
            if(!String.isBlank(psqList[0].Location_Name_5__c) && !String.isBlank(psqList[0].Location_City_State_Country_5__c)){
                locationname5=psqList[0].Location_Name_5__c;
                locationcity5=psqList[0].Location_City_State_Country_5__c;
                bandwidth5=psqList[0].Approx_Peak_Bandwidth_Seen_5__c;
                availableinfra5=psqList[0].Available_Infrastructure_5__c;
                topology5=psqList[0].Traffic_Routing_5__c;
            }
        }
        LocationWrapper result=new LocationWrapper(locationName1,locationCity1,bandwidth1,availableInfra1,topology1,
                                                   locationName2,locationCity2,bandwidth2,availableInfra2,topology2,
                                                   locationName3,locationCity3,bandwidth3,availableInfra3,topology3,
                                                   locationName4,locationCity4,bandwidth4,availableInfra4,topology4,
                                                   locationName5,locationCity5,bandwidth5,availableInfra5,topology5);
            return JSON.serialize(result);
        
    }
    global class LocationWrapper{
        global String locationname1;
        global String locationcity1;
        global String bandwidth1;
        global String availableinfra1;
        global String topology1;
        global String locationname2;
        global String locationcity2;
        global String bandwidth2;
        global String availableinfra2;
        global String topology2;
        global String locationname3;
        global String locationcity3;
        global String bandwidth3;
        global String availableinfra3;
        global String topology3;
        global String locationname4;
        global String locationcity4;
        global String bandwidth4;
        global String availableinfra4;
        global String topology4;
        global String locationname5;
        global String locationcity5;
        global String bandwidth5;
        global String availableinfra5;
        global String topology5;
        global LocationWrapper(string locationName1, string locationCity1, string bandwidth1, string availableInfra1, string topology1,
                               string locationName2, string locationCity2, string bandwidth2, string availableInfra2, string topology2,
                               string locationName3, string locationCity3, string bandwidth3, string availableInfra3, string topology3,
                               string locationName4, string locationCity4, string bandwidth4, string availableInfra4, string topology4,
                               string locationName5, string locationCity5, string bandwidth5, string availableInfra5, string topology5){
                                   this.locationname1 = locationName1;
                                   this.locationcity1 = locationCity1;
                                   this.bandwidth1 = bandwidth1;
                                   this.availableinfra1 = availableInfra1;
                                   this.topology1 = topology1;
                                   this.locationname2 = locationName2;
                                   this.locationcity2 = locationCity2;
                                   this.bandwidth2 = bandwidth2;
                                   this.availableinfra2 = availableInfra2;
                                   this.topology2 = topology2;
                                   this.locationname3 = locationName3;
                                   this.locationcity3 = locationCity3;
                                   this.bandwidth3 = bandwidth3;
                                   this.availableinfra3 = availableInfra3;
                                   this.topology3 = topology3;
                                   this.locationname4 = locationName4;
                                   this.locationcity4 = locationCity4;
                                   this.bandwidth4 = bandwidth4;
                                   this.availableinfra4 = availableInfra4;
                                   this.topology4 = topology5;
                                   this.locationname5 = locationName5;
                                   this.locationcity5 = locationCity5;
                                   this.bandwidth5 = bandwidth5;
                                   this.availableinfra5 = availableInfra5;
                                   this.topology5 = topology5;
                               }
    }
    
    
}