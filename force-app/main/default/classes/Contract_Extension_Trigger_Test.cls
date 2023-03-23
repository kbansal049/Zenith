@isTest
public class Contract_Extension_Trigger_Test{

    static testMethod void test1(){
        Test.startTest();
        Id userId = UserInfo.getUserId();

        ZscalerSetting__c newSetting = new ZscalerSetting__c(Name = 'SalesOperationQueueId', Value__c = userId);
        insert newSetting;
        Opportunity opp = new Opportunity(Name='acme', StageName= label.Stage_4_Economic_Buyer_Signoff /*'10 - Closed Won'*/, CloseDate=Date.today());
        insert opp;
        
        Contract_Extension_Request__c cer = new Contract_Extension_Request__c();
        cer.Opportunity__c = opp.Id;
        cer.Extension_Request_No__c = cer.Opportunity_Extension_Number__c;
        cer.Approval_Status__c = 'Approved';
        insert cer;
    	cer.Approval_Status__c = 'Recalled';
        update cer;
        Test.stopTest();
       
    }
    static testmethod void test3() {
        Id userId = UserInfo.getUserId();
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        
        TriggerUtility.SkipAccTriggerExecuted();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
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
        acc.Sales_Territory__c = pateam.Id;
        acc.Patch__c = pat.Id;
        acc.CSM_Name_New__c = userId;
     acc.TAM_Name_New__c = userId;
     acc.Sales_Engineer__c = userId;
     acc.Account_Manager__c = userId;
     acc.Channel_Manager__c = userId;
     acc.Customer_Advocate__c = userId;
     acc.Area_Director__c = userId;
        insert acc;    
        
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName =label.Stage_1_Alignment , SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Next_Steps__c  = 'fdsjsdk');
        insert opp;
        
        Test.startTest();
        Contract_Extension_Request__c cer = new Contract_Extension_Request__c();
        cer.Opportunity__c = opp.Id;
        cer.Approval_Status__c = 'Pending Approval';
        cer.Contract_Extension_Date__c=System.today();
        cer.Extension_Request_Date__c=System.today();
        insert cer;
        Test.stopTest();
        
    }
}