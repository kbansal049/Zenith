/**
 * Class Name : CAPRequestInProgressScheduler
 * Added by : Ankit Bhatnagar
 * Description : Schedules the CAPRequestInProgressBatch
 */
global class CAPRequestInProgressScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        CAPRequestInProgressBatch b = new CAPRequestInProgressBatch(); 
        database.executebatch(b);
    }
 }