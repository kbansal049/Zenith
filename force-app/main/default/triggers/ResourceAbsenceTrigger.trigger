trigger ResourceAbsenceTrigger on ResourceAbsence (before insert, after insert, before update, after update,before delete,after delete) {
    new ResourceAbsenceTriggerHandler().run();
}