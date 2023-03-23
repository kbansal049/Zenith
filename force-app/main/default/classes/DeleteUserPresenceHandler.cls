public class DeleteUserPresenceHandler {

    @InvocableMethod(label='Delete User Presences')
    public static void deleteUserPresenceRecords() {
        Database.executeBatch(new DeleteUserPresenceBatch());
    }
}