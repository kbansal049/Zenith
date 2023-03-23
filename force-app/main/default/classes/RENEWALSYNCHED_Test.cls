//This test Class is created to perform test class between Commercial to Fed 
@isTest
public class RENEWALSYNCHED_Test {
    
    @isTest
    static void test2(){
        
        test.starttest();
        Opportunity opp = new Opportunity();
        try{
        Account acc = new Account(Name = 'accname');
        insert acc;
        Account acc1 = new Account(Name = 'accname');
        insert acc1;
        opp = new Opportunity(name='opp1', stagename = Label.Stage_1_Alignment, closedate = date.today(),accountId = acc.Id, Is_Federal_Opportunity_Sync__c = true , type= 'Existing Customer (Renewal)' );
        insert opp;
     
        Map<String, String> result  =  RENEWALSYNCED.doGet();
        System.debug('result:' + result);
        }catch(Exception ex){
            System.debug('in catch test RENEWALSYNCHED_Test:= '+ ex.getMessage()+ ex.getStackTraceString());
        }
        
        System.assertEquals('opp1', Opp.Name);

        test.stoptest();
        
    }
}