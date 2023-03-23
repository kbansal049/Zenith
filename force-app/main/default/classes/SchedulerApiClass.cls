/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* SchedulerApiClass
* @description - This class works as Scheduler API invoker
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* @author         
* @modifiedBy     Anup Dhole
* @maintainedBy   Zscaler
* @version        1.0
* @created        
* @modified       2023-02-02
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* 
**/
public class SchedulerApiClass {
    @invocableMethod(label='Schedule to First Available' description='Schedule to whomever is next')
    public static List<String> scheduleIt(list<PayloadIn> payloadList ){
        if(payloadList == null || payloadList.size() <> 1) {
            return new List<String>();
        }else{
            PayloadIn pl = payloadList[0];
            lxscheduler.GetAppointmentCandidatesInput input = new lxscheduler.GetAppointmentCandidatesInputBuilder()
                .setWorkTypeGroupId(pl.workTypeGroupId)
                .setTerritoryIds(new List<String>{pl.serviceTerritoryId})
                .setStartTime(pl.startDateTime.format('yyyy-MM-dd\'T\'HH:mm:ssZ'))
                .setEndTime(pl.endDateTime.format('yyyy-MM-dd\'T\'HH:mm:ssZ'))
                .setSchedulingPolicyId(pl.schedulingPolicyId)
                .setApiVersion(Double.valueOf('56.0'))
                .build();

            //call the Apex Method - no REST API authentication or API user needed!!!
            String response = lxscheduler.SchedulerResources.getAppointmentCandidates(input);
            if(response == null && !Test.isRunningTest()) {
                return new List<String>();
            }else{
                SchedulerCandidatesData scData = new SchedulerCandidatesData();
                if(Test.isRunningTest()){
                    //Adding dummy response for test class
                	response = '[{"endTime": "2019-01-23T19:15:00.000+0000","resources": ["0HnB0000000D2DsKAK"],"startTime": "2019-01-23T16:15:00.000+0000","territoryId":"0HhB0000000TO9WKAW"}]';
                }
                List<SchedulerCandidatesData> allslots = scData.parse(response);
                system.debug('1111 AAA---> '+allslots);
                
                if(allslots != null) {
                    String str = GCSCommonConstants.EMPTY_STRING;
                    for(SchedulerCandidatesData sc : allslots){
                        str += String.join(sc.resources, GCSCommonConstants.COMMA_STRING) + GCSCommonConstants.COMMA_STRING;
                    }
                    str = str.removeEnd(GCSCommonConstants.COMMA_STRING);
                    return new list<String>{str};
                }
            }
        }
        
        //no slots found, return empty list
        return new List<String>();
    }

    public class PayloadIn{
        @invocableVariable(required=true)
        public string workTypeGroupId;

        @invocableVariable(required=true)
        public string serviceTerritoryId;

        @invocableVariable(required=true)
        public string schedulingPolicyId;

        @invocableVariable(required=true)
        public string accountId;

        @invocableVariable(required=true)
        public datetime startDateTime;

        @invocableVariable(required=true)
        public datetime endDateTime;
    }

    public class SchedulerCandidatesData {
        public Datetime startTime;
        public Datetime endTime;
        public String territoryId;
        public List<String> resources;
    
        public List<SchedulerCandidatesData> parse(String json) {
            return (List<SchedulerCandidatesData>) System.JSON.deserialize(json, List<SchedulerCandidatesData>.class);
        }
    }
}