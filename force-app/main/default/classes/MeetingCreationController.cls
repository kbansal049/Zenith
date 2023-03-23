public class MeetingCreationController {
    @AuraEnabled(cacheable=true)
    public static MeetingWrapper getInfo(Id recId){
        MeetingWrapper ctrl = new MeetingWrapper();
        List<Meeting__c> mlst = [Select Id from meeting__c where Calendar_Id__c = :recId];
        ctrl.countofMeeting = mlst.size();
        if(!mlst.isEmpty()){
            ctrl.meetingId = mlst[0].Id;
        }else{
            for(Event evt: [Select Id, AccountId, peopleai__Participants__c, DurationInMinutes, StartDateTime from Event where Id = :recId]){
                ctrl.evt = evt;
                ctrl.accId = evt.AccountId;
                
            }
        }
        return ctrl;
        
    }
    public class MeetingWrapper{
        @AuraEnabled 
        public Integer countofMeeting;
        @AuraEnabled 
        public string meetingId;
        @AuraEnabled 
        public string accId;
        @AuraEnabled 
        public Event evt;
    }
}