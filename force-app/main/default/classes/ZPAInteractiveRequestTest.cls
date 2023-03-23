@isTest
public class ZPAInteractiveRequestTest{
    static testmethod void test1(){
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test1';
        con1.LastName = 'Test1';
        con1.AccountId = account.Id;
        insert con1;
        
        lead l= new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Lead Company', Status = 'Marketing Qualified: Sales Untouched');
        insert l;
        List <String> leadRecordIds = new List <String>();
        leadRecordIds.add(l.Id);
        List <String> contactRecordIds = new List <String>();
        contactRecordIds.add(con1.Id);
        
        System.enqueueJob(new ZPAInteractiveRequest('Lead',leadRecordIds));
        System.enqueueJob(new ZPAInteractiveRequest('Contact',contactRecordIds));
    }
}