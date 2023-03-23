@istest
public class ContractDetail_Subscription_Sch_Test{
    static testmethod void test1(){
        ContractDetail_Subscription_Sch css = new ContractDetail_Subscription_Sch();
        String sch = '0 36 1 * * ?';
        String jobID = system.schedule('test contract asset batch',sch,css);
    }
}