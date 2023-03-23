global without sharing class Zenith_LikesCounterSchedulable implements Schedulable{

    global void execute(SchedulableContext sc){
        Id jobId = Database.executeBatch(new Zenith_LikesCounterBatch());
    }
}