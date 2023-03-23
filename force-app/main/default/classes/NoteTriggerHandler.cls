public class NoteTriggerHandler {
    public static void UpdateRFPRequest(List<Note> NewNoteList){
        String RFPobjectprefixid=ZscalerCustomSetting__c.getInstance('RFPobjectprefix')!=null && ZscalerCustomSetting__c.getInstance('RFPobjectprefix').Value__c!=null ? ZscalerCustomSetting__c.getInstance('RFPobjectprefix').Value__c:'';
        List<RFP_Request__c> RFPrequestlist= new List<RFP_Request__c>();
        Set<id> RFPid= new Set<id>();
        for(Note nt : NewNoteList){
            system.debug('nt  '+nt);
            String parentrcrdIdPrefix = String.valueOf(nt.ParentId).substring(0,3);
            system.debug('parentrcrdIdPrefix  '+parentrcrdIdPrefix);
            if(RFPobjectprefixid.equals(parentrcrdIdPrefix)){
                system.debug('inside if  ');
                RFPid.add(nt.ParentId);
            }
        }
        system.debug('RFPid '+RFPid);
        if(RFPid.size()>0){
        
            Map<id,RFP_Request__c> RFPrequestidMap= new Map<id,RFP_Request__c>([Select id,name,Last_upload_Document_Submitter__c,Last_upload_Document_Title__c,Email_for_Attachment_Sent__c from  RFP_Request__c where Request_Status__c='Completed' and id IN:RFPid]);
            for(Note nt : NewNoteList){
                if(RFPrequestidMap.containskey(nt.ParentId)){
                    RFP_Request__c RFPrqst= new RFP_Request__c(id=nt.ParentId,Last_upload_Document_Submitter__c=nt.OwnerId,Last_upload_Document_Title__c=nt.Title,Email_for_Attachment_Sent__c=true);
                    RFPrequestlist.add(RFPrqst);
                }
            }
        system.debug('RFPrequestlist '+RFPrequestlist);
        }
        if(RFPrequestlist.size()>0){
            update RFPrequestlist;
        }
    }
}