public class AttachmentTriggerHelper {
    public static void afterInsert(list<Attachment> attlst){
       Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
       //Commneting as part of CR# 3916
       /*if(!TriggerUtility2.isOppPOUpdateExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Att_Opp_PO') && tsmap.get('Execute_Att_Opp_PO') != null && tsmap.get('Execute_Att_Opp_PO').Execute__c){
             AttachmentTriggerUtility.updateOpptyPO(attlst);
       }*/
       if(tsmap!=null && tsmap.containsKey('AttachmentUpdateRFPRequest') && tsmap.get('AttachmentUpdateRFPRequest') != null && tsmap.get('AttachmentUpdateRFPRequest').Execute__c  && !TriggerUtility.isupdateRFPRequest_classicExecuted()){ 
           AttachmentTriggerHandler.UpdateRFPRequest(trigger.new);
       }
    }
    public static void afterUpdate(list<Attachment> attlst, Map<Id, Attachment> oldmap){

       Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
       //Commneting as part of CR# 3916
      /* if(!TriggerUtility2.isOppPOUpdateExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Att_Opp_PO') && tsmap.get('Execute_Att_Opp_PO') != null && tsmap.get('Execute_Att_Opp_PO').Execute__c){
             AttachmentTriggerUtility.updateOpptyPO(attlst, oldmap);
       }*/
    }
}