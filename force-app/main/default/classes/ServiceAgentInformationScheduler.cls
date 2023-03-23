/**
 * TAM Routing Implementation
 * Added by : Ankit Bhatnagar
 * Description : Schedules the ServiceAgentInformationBatch
 */
global class ServiceAgentInformationScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ServiceAgentInformationBatch b = new ServiceAgentInformationBatch(); 
        database.executebatch(b);
    }
 }