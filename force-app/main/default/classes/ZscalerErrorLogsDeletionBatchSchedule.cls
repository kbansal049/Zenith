/**
 * @description       : This Apex batch scheduler is used to schedule ZscalerErrorLogsDeletionBatch to run every Saturday at 9 PM.
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global class ZscalerErrorLogsDeletionBatchSchedule implements Schedulable {
	global void execute(SchedulableContext sc){
        /*String cronJob = '0 0 21 ? * SAT';	//Class runs Every Saturday at 9 PM.
        String jobID = System.schedule('ZscalerErrorLogsDeletionBatch - Custom Schedule', cronJob, new ZscalerErrorLogsDeletionBatchSchedule());*/
        Database.executeBatch(new ZscalerErrorLogsDeletionBatch(''));	    
    }
}