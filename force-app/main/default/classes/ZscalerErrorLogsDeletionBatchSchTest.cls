/**
 * @description       : Apex test class for ZscalerErrorLogsDeletionBatchSchedule
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-29-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ZscalerErrorLogsDeletionBatchSchTest {
    @isTest
    static void testZscalerErrorLogsDeletionBatchSchedule(){
        Test.StartTest();
            String cronJob = '0 0 21 ? * SAT';	//Class runs Every Saturday at 9 PM.
            String jobID = System.schedule('ZscalerErrorLogsDeletionBatch - Custom Schedule', cronJob, new ZscalerErrorLogsDeletionBatchSchedule());
        	System.assert(jobID != null, 'After ZscalerErrorLogsDeletionBatch Schedule - Pass');
        Test.stopTest();
    }
}