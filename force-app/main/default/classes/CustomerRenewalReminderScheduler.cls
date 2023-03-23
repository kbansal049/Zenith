/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* CustomerRenewalReminderScheduler
* @description    This class is used to schedule the CustomerRenewalReminderBatch on a particular time
*				  which will initiate the renewal email.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-07-14
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public with sharing class CustomerRenewalReminderScheduler implements Schedulable{

    private static CustomerRenewalReminderScheduler instance;
    public static CustomerRenewalReminderScheduler getInstance() {
        if (instance == NULL) {
            instance = new CustomerRenewalReminderScheduler();
        }

        return instance;
    }

    public void execute(SchedulableContext SC) {

        System.Database.executeBatch(new CustomerRenewalReminderBatch());
    }
}