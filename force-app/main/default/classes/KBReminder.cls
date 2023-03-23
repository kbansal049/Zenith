public class KBReminder {
@InvocableMethod(label='callKBReminderBatch')
public static void callKBReminderBatch(){
    KBRemindersBatch batch=new KBRemindersBatch('SELECT id,validationStatus,PublishStatus,CreatedDate,ready_for_Tech_review_Timestamp__c,CreatedBy.Email,Owner_s_Manager__c,Owner_s_Manager_Email__c,Owner.Email,Reassigned_To_Manager__c FROM KB__kav WHERE validationStatus IN (\'Draft\',\'Ready for Tech Review\')');
    Database.executeBatch(batch);
}
}