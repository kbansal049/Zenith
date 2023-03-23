@isTest
public class CampaignMemberAccountUpdationTest {
    
    
    @testSetup static void setup() {
        List<ZscalerSetting__c> ZscalerSettinglist= new List<ZscalerSetting__c>();
        ZscalerSetting__c Zsc1= new ZscalerSetting__c(Name='CampaignExceptions1',Value__c='ABC');
        ZscalerSettinglist.add(Zsc1);
        ZscalerSetting__c Zsc2= new ZscalerSetting__c(Name='CampaignExceptions2',Value__c='DEF');
        ZscalerSettinglist.add(Zsc2);
        Insert ZscalerSettinglist;
        
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', First_Lead_Date__c = date.today(), Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0);
        insert lead;
        
        
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true);
        insert con;
        
        List<Campaign> CmpgnList= new List<Campaign>();
        Campaign cm = new Campaign();
        cm.name='ZPA Interactive';
        cm.Department__c = '5000-Corporate Marketing';
        cm.Geo__c = 'GLOBAL';
        cm.StartDate = Date.today();
        cm.EndDate = Date.today()+30;
        cm.Fiscal_Year__c = 'All Time';
        cm.Type = 'Default';
        cm.Campaign_Type__c = 'Assets';
        //cm.Activity_Details__c = 'ebook';
        
        CmpgnList.add(cm);
        
        insert CmpgnList;
        
        List<CampaignMember> CmpgnMemList= new List<CampaignMember>();
        CampaignMember CM2= new CampaignMember(Campaignid=cm.id,Leadid=lead.id,Status='Sent');
        CmpgnMemList.add(CM2);
        CampaignMember CM1= new CampaignMember(Campaignid=cm.id,Contactid=con.id,Status='Sent');
        CmpgnMemList.add(CM1);
        insert CmpgnMemList;
        
        //lead.LeanData__Reporting_Matched_Account__c = acctTest.id;
        //update lead;
        
        //Lead ld = [Select ID, LeanData__Reporting_Matched_Account__c from lead where id = :lead.id];
        //System.debug('-ld-'+ld);
        
    }
    
    
    public static testMethod void testUpdate(){
        Test.startTest();
        System.schedule('Test', '0 0 23 * * ?', new CampaignMemberAccountUpdation());
        Test.stopTest();   
    }
    
    public static testMethod void testUpdate2(){
        String query = 'Select Id from CampaignMember where leadId != null';
        Test.startTest();
        System.schedule('Test', '0 0 23 * * ?', new CampaignMemberAccountUpdation(query));
        Test.stopTest();
    }
    
    public static testMethod void testUpdate3(){
        Test.startTest();
        Database.executeBatch(new CampaignMemberAccountUpdation(),1);        
        Test.stopTest();
    }
    
    public static testMethod void testUpdate4(){
        String query = 'Select Id from CampaignMember where leadId != null';
        List<CampaignMember> cmList = [Select Id,Account__c,leadId from CampaignMember];
        System.debug('--testUpdate4--cmList--'+cmList);
        Test.startTest();
        Database.executeBatch(new CampaignMemberAccountUpdation(query),1);        
        Test.stopTest();
    }
    
}