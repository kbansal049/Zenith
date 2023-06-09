@isTest
public class Contract_Extension_Controller_Test{
    static testmethod void test1(){
        Account account = new Account(Name = 'Test Account', CSM_Name_New__c = userinfo.getuserId(), Account_Manager__c = userinfo.getuserId(),Sales_Engineer__c = userinfo.getuserId(),Channel_Manager__c = userinfo.getuserId());
        //account.Needs_to_be_Migrated__c = true;
        //insert account;
        TriggerUtility.SkipAccTriggerExecuted();
        Patch__c pat = new Patch__c(PatchName__c = 'Test Patch' );
        insert pat;
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='Americas';
        pateam.Region__c ='US West';
        pateam.Area__c ='US South West';
        pateam.Territory_Type__c ='Channel';
        insert pateam;
        pat.PatchTeam__c=pateam.Id;
        account.Sales_Territory__c = pateam.Id;
        account.Patch__c = pat.Id;
        insert account;
        
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test1';
        con1.LastName = 'Test1';
        con1.AccountId = account.Id;

        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Test2';
        con2.Renewal_Notification_Recipient__c = true;
        con2.AccountId = account.Id;
        
        insert new List<Contact> { con1, con2 };
        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        opportunity opp = new opportunity(RecordtypeId = meRecordTypeId, Name = 'Test opportunity', AccountId = account.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true,Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), contract_end_date_new__c = date.today().adddays(65));
        insert opp;
        
        opp.Contract_End_Date_New__c = date.today().adddays(60);
        update opp;
        
        Contract_Extension_Request__c cer = new Contract_Extension_Request__c();
        cer.Opportunity__c = opp.Id;
        cer.Approval_Status__c = 'Pending Approval';
        cer.Contract_Extension_Date__c = date.today().adddays(30);
        cer.Extension_Request_Date__c = date.today().adddays(20);
        cer.Detailed_Reason_for_Contract_Extension__c = 'Test Details';
        insert cer;
        
        cer.Approval_Status__c = 'Approved';
        cer.Extension_Request_No__c=1;
        update cer;
        
        Contract_Extension_Controller ctrl = new Contract_Extension_Controller();
        ctrl.contractextensionId = cer.Id;
        ctrl.isapprovalrequested  = true;
        ctrl.isapproved = true;
        ctrl.isrejected = true;
        system.debug(ctrl.yearVal);
        system.debug(ctrl.url);
        system.debug(ctrl.opp);
        system.debug(ctrl.ContractExtensionreq );
        
    }

}