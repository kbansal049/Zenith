@istest
public class UpdateOpportunityStageKMBatch_Sch_Test{
    static testmethod void test1(){
        UpdateOpportunityStageKMBatch_Sch m = new UpdateOpportunityStageKMBatch_Sch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test poc notification', sch, m);
    }
}