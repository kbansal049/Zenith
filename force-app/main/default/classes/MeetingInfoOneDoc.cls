global without sharing class MeetingInfoOneDoc extends OneDoc.BaseTemplateDataProvider{
    global MeetingInfoOneDoc() {
    }
    public override Object provide(Map<String, String> params) {
        String dt = '';    
        List<Meeting__c> meetlst = [Select Id, Date_of_meeting__c from Meeting__c where Id = :params.get('Id')];
        if(!meetlst.isEmpty() && meetlst[0].Date_of_meeting__c != null){
            dt = meetlst[0].Date_of_meeting__c.format('MMMM dd, YYYY');
        }
        return JSON.serialize(dt);
    }
    
}