public class CaseTAMReassignmentDateResetHandler {

    @InvocableMethod(label='Reset TAM Reassignment Date')
    public static void resetTAMReassignmentDate() {
        Database.executeBatch(new CaseTAMReassignmentDateResetBatch());
    }
}