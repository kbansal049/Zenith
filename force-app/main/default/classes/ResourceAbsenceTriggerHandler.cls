/**
 * Name : ResourceAbsenceTriggerHandler
 * Description : Handler class for ResourceAbsenceTrigger
 * Test Class : 
 * Initial Author : Anup Dhole
 */
public class ResourceAbsenceTriggerHandler extends TriggerHandler{
    public override void beforeInsert(){

    }
    public override void afterInsert() {
        ResourceAbsenceTriggerHelper.updateOutOfOfficeOnServiceResource((List<ResourceAbsence>)Trigger.New);
        ResourceAbsenceTriggerHelper.sendEmailToInlineManager((List<ResourceAbsence>)Trigger.New,null);

    }
    public override void beforeUpdate(){

    }
    public override void afterUpdate() {
        ResourceAbsenceTriggerHelper.updateOutOfOfficeOnServiceResource((List<ResourceAbsence>)Trigger.New);
        ResourceAbsenceTriggerHelper.sendEmailToInlineManager((List<ResourceAbsence>)Trigger.New,(Map<Id, ResourceAbsence>) Trigger.oldMap);
    }

    public override void beforeDelete(){
        ResourceAbsenceTriggerHelper.sendEmailToInlineManager((List<ResourceAbsence>)Trigger.Old,null);
    }

    public override void afterDelete(){
        ResourceAbsenceTriggerHelper.UpdateOutOfOfficeOnDeletion((List<ResourceAbsence>)Trigger.Old);
    }
}