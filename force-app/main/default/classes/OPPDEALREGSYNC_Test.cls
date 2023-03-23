@isTest
public class OPPDEALREGSYNC_Test{
    static testMethod void getlstofleads() {
        Account acc = new Account(Name = 'accname');
        insert acc;
        Account acc1 = new Account(Name = 'accname');
        insert acc1;
        Opportunity opp = new Opportunity(name='opp1', stagename = Label.Stage_1_Alignment, closedate = date.today(),accountId = acc.Id, Is_Federal_Opportunity_Sync__c = true);
        insert opp;
        
        List<Partner> oppartlst = new List<Partner>();
        Partner pt = new partner();
        pt.OpportunityId=opp.id;
        pt.Role = 'Deal Reg';
        pt.AccountToId=acc1.Id;
        oppartlst.add(pt);
        insert oppartlst;
        
        String startdate = date.today().year() + '-' + date.today().month() + '-' + date.today().day() + ' 00:00:00';
        String enddate = date.today().year() + '-' + date.today().month() + '-' + date.today().day() + ' 23:59:59';
        RestRequest req = new RestRequest();
        req.params.put('type', EncodingUtil.urlEncode('get_leads','UTF-8'));
        req.params.put('Start_Date', EncodingUtil.urlEncode(startdate,'UTF-8'));
        req.params.put('End_Date', EncodingUtil.urlEncode(enddate,'UTF-8'));
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        List<Opportunity> opptylst = new List<Opportunity>();
        opptylst.add(opp);
        oppartlst.add(pt);
        Test.startTest();
        OPPDEALREGSYNC.doPost(opptylst,oppartlst);


        Test.stopTest();

    }

}