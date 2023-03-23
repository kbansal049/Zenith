@istest
public class AttachmentTriggerTest{
    static testmethod void test1(){
        test.startTest();
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        List<Opportunity> opplist = new List<Opportunity>();
        Opportunity o = new Opportunity();
        
        o.Name = 'New Record';
        o.StageName = Label.Stage_2_Qualified_Budgeted;
        o.CloseDate = Date.today()+30;
        o.Type = 'New Business';
        o.Description = 'Test Record';
        //insert o;
        opplist.add(o);
         
        Opportunity o1 = new Opportunity();
        
        o1.Name = 'New1 Record';
        o1.StageName = '6 - Closed Won';
        o.Sub_Stage__c ='Opportunity - Closed/Won';
        o1.CloseDate = Date.today();
        o1.Type = 'New Business';
        o1.Description = 'Testing';
        //insert o1;
        opplist.add(o1);
        insert opplist;
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        Attachment att = new attachment(Name='Test PO');
        att.body = blob.valueOf(json.serialize('test'));
        att.parentid = o.Id;
        insert att;
    }
}