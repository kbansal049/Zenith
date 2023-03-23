public class AttachmentTriggerUtility{
    public static void updateOpptyPO(List<Attachment> attlst){
        Map<Id, Opportunity> mapop = new map<id, opportunity>();
        for(Attachment att: attlst){
            if(/*att.name.containsignorecase(Label.Opportunity_PO_Attachment_Label) && */ att.ParentId.getSobjectType() == Opportunity.getSobjecttype()){
                mapop.put(att.parentId, new Opportunity(Id = att.parentId, PO_Attached__c  = true));
            }
        }
        if(!mapop.isEmpty()){
            Triggerutility.SkipOppTriggerExecuted();
            Triggerutility.skipOpportunityTrigger();
            update mapop.values();
        }
    }
    public static void updateOpptyPO(List<Attachment> attlst, Map<Id, Attachment> oldmap){
        List<Attachment> attlsttoprocess = new List<Attachment>();
        for(Attachment att: attlst){
            if(oldmap != null && att.name != oldmap.get(att.id).Name){
                attlsttoprocess.add(att);
            }
        }
        if(!attlsttoprocess.isEmpty()){
            updateOpptyPO(attlsttoprocess);
        }
    }
}