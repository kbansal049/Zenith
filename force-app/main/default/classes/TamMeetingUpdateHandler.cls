public class TamMeetingUpdateHandler {

    @InvocableMethod(label='TAM Meeting Completed Update')
    public static void updateTAMMeetingStatus() {
        Database.executeBatch(new TamMeetingCompletedUpdateBatch(), 10);
    }
}