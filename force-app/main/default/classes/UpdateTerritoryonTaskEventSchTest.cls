@istest
public class UpdateTerritoryonTaskEventSchTest{
    /* static testmethod void test1(){
        UpdateTerritoryonTasks_Schedulable m = new UpdateTerritoryonTasks_Schedulable(date.today(),date.today());
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test update ter  tasks 2', sch, m);
    } */
    
    static testmethod void test1(){
        Date sd;
        Date ed;
        UpdateTerritoryonTaskEventSch m = new UpdateTerritoryonTaskEventSch(sd, ed);
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test update ter  tasks 1', sch, m);
    }
}