global without sharing class NextMeetingInfoOneDoc extends OneDoc.BaseTemplateDataProvider {
    global NextMeetingInfoOneDoc() {
    }
    public override Object provide(Map<String, String> params) {
        String dt = '';    
        List<Meeting__c> meetlst = [Select Id, Next_Meeting_Date__c from Meeting__c where Id = :params.get('Id')];
        if(!meetlst.isEmpty() && meetlst[0].Next_Meeting_Date__c != null){
            Integer d = meetlst[0].Next_Meeting_Date__c.day();
            Integer mo = meetlst[0].Next_Meeting_Date__c.month();
            Integer yr = meetlst[0].Next_Meeting_Date__c.year();
            DateTime dTime = DateTime.newInstance(yr, mo, d);
            
            dt = dTime.format('dd MMM, YYYY');
        }
        return JSON.serialize(dt);
    }
}