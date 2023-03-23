@isTest(SeeAllData=false)
public class CaptureAccountMetricsBatchTest {
    //@TestSetup
    static testmethod void setupData(){
        ZscalerSetting__c zs = new ZscalerSetting__c(Name = 'AccountMetricsBatchSize', Value__c = '1');
        insert zs;
        List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c> skuList = new List<SKUs_Referred_in_Renewal_Upsell_NS_Calc__c>();
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c sku = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(Name ='ZPA_Contract_Date', SKU_Codes__c = 'ZPA-BBA;ZPA-BUS;ZPA-ENT;ZPA-PRO;ZPA-PRO-LU;ZPA-BUS-LU;ZPA-BUS-EDITION;ZPA-PRO-EDITION;ZPA-BUS-EDITION-LU;ZIA-PRO-EDITION-LU;ZPA-TRANS-EDITION;ZPA-Remote-PRE;ZS-WFA-BUS-EDITION;ZPA-FED-BUNDLE;ZPA-ZFED-MODERATE');
        skuList.add(sku);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c sku1 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(Name ='ZIA_Contract_Date', SKU_Codes__c = 'ZSC-SIP;ZIA-PRO-BUNDLE;ZIA-BUS-BUNDLE;ZIA-TRANS-BUNDLE;ZIA-ELA-BUNDLE;ZIA-PRO-BUNDLE-LU;ZIA-BUS-BUNDLE-LU;ZIA-TRANS-BUNDLE-LU;ZIA-ELA-BUNDLE-LU;ZSC-SIP-LOC;ZIA-SIP;ZIA-PRO-EDITION;ZIA-BUS-EDITION;ZIA-TRANS-EDITION;ZIA-ELA-EDITION;ZIA-PRO-EDITION-LU');
        skuList.add(sku1);
        SKUs_Referred_in_Renewal_Upsell_NS_Calc__c sku2 = new SKUs_Referred_in_Renewal_Upsell_NS_Calc__c(Name ='ZIA_Contract_Date1', SKU_Codes__c = 'ZIA-BUS-EDITION-LU;ZIA-TRANS-EDITION-LU;ZIA-ELA-EDITION-LU;ZSC-RET-KIOSK;Z-O365-PRE;ZS-WFA-BUS-EDITION;EDU-ZIA-SVC-EDGE-BUS;ZIA-FED-BUNDLE;ZIA-ZFED-MODERATE;ZIA-PROF-EDITION');
        skuList.add(sku2); 
        insert skuList;
        TriggerHandler.bypass('AccountTriggerHandler');
        Account acc = TestDatafactory_Zscaler.insertAccount('Test Account1', null, 'Customer', null, null, null);
        
        Contact cntct = new Contact(FirstName = 'Test',LastName = 'Contact');
        insert cntct;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = '1 - Discovery & Qualification', CloseDate = system.Today()+30, amount = 10000,Type = 'Existing Customer (Renewal)');
        insert opp;
        
        
 	    
        List<Task> taskList = new List<Task>();
        task ts = new task(OwnerId = userinfo.getUserId(),Subject = 'Test Subject',whatId = acc.Id);
        task ts1 = new task(OwnerId = userinfo.getUserId(),Subject = 'Test Subject 1',whatId = acc.Id);
        taskList.add(ts);
        taskList.add(ts1);
        insert taskList;
        
        ZDX_Cloud_Usage__c zdx = new ZDX_Cloud_Usage__c(Account__c = acc.Id,External_ID__c = '12345678');
        insert zdx;
        
        Recordtype rc = [Select id,Name From RecordType where sObjectType='Zscaler_Cloud_ID__c' and isActive=true and name = 'ZIA Cloud ID' LIMIT 1];
        List<Zscaler_Cloud_ID__c> cloudList = new List<Zscaler_Cloud_ID__c>();
        Zscaler_Cloud_ID__c cloudId = new Zscaler_Cloud_ID__c(Name = '1441203345204183',Account__c = acc.Id,Status__c = 'Production',Cloud_Type__c = 'ZIA',RecordTypeId = rc.Id );
        Zscaler_Cloud_ID__c cloudId1 = new Zscaler_Cloud_ID__c(Name = '1441203345204182',Account__c = acc.Id,Cloud_Type__c = 'ZIA',Latest_ZDX_Cloud_Usage__c = zdx.Id,Total_SSL_Inspected_Transactions__c = 10,Total_number_of_IPSec_tunnels__c = 10,Number_of_GRE_tunnels__c = 10,RecordTypeId = rc.Id);
        cloudList.add(cloudId);
        cloudList.add(cloudId1);
        insert cloudList;
        
        
        List<Cloud_Usage__c> cloudUsageList = new List<Cloud_Usage__c>();
        Cloud_Usage__c cu = new Cloud_Usage__c(DLP_Blocked__c = 5,Total_Transactions__c = 10,Last_90_Days__c = True,Cloud_Usage_Type__c = 'ZIA',Zscaler_Cloud_ID__c = cloudId.Id);
        Cloud_Usage__c cu1 = new Cloud_Usage__c(Last_31_Days__c = True,Cloud_Usage_Type__c = 'ZIA',Zscaler_Cloud_ID__c = cloudId.Id);
		cloudUsageList.add(cu);
        cloudUsageList.add(cu1);
        insert cloudUsageList;
        
        Test.startTest();
        Product2 prod = new Product2(ProductCode = 'TestProduct', Name = 'Test Name', Family = 'ZIA',
                                     IsActive = true);
        insert prod;
        
        SBQQ__Quote__c sbqq = new SBQQ__Quote__c(SBQQ__Primary__c = True,Total_ZPA_ACV__c = 25);
        insert sbqq;

        Opportunity oppP = new Opportunity();
        oppP.Name = 'TestOpp';
        oppP.StageName = '1 - Discovery & Qualification';
        oppP.CloseDate = System.today() +10;
        oppP.AccountId = acc.Id;
        oppP.SBQQ__PrimaryQuote__c = sbqq.Id;
        insert oppP;        
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'TestOpp';
        opp1.StageName = '1 - Discovery & Qualification';
        opp1.CloseDate = System.today() +10;
        opp1.AccountId = acc.Id;
        opp1.SBQQ__PrimaryQuote__c = sbqq.Id;
        opp1.APTS_Primary_Proposal__c = oppP.Id;
        opp1.Type = 'Existing Customer (Renewal)';
        insert opp1;

        Contract_Detail__c cd = new Contract_Detail__c(Account_Name__c = acc.id,Quantity__c = 25,Product_sku__c ='ZEXT-BW-PREM',Contract_detail_status__c = 'Active', do_not_aggregate__c = FALSE);
        insert cd;
        
        Customer_Next_Steps_History__c cns = new Customer_Next_Steps_History__c(Account__c = acc.Id);
        insert cns;
        
        Egress_Location__c el = new Egress_Location__c(Account__c = acc.Id,Egress_Location__c = opp1.id);
        insert el;
        
        List<Event> events = new List<Event>();
        Event e1 = new Event(OwnerId = userinfo.getUserId(),Subject = 'Meeting',peopleai__MeetingStatus__c = 'Scheduled',StartDateTime = System.now()-1,EndDateTime = System.now() + 1,Method_of_Interaction__c = 'Face to Face',Type = System.Label.Post_Sale_Operational_Review,WhatId = acc.Id);
        Event e2 = new Event(OwnerId = userinfo.getUserId(),Subject = 'Meeting',peopleai__MeetingStatus__c = 'Scheduled',StartDateTime = System.now()-1,EndDateTime = System.now() + 1,Method_of_Interaction__c = 'Remote',Type = System.Label.VO_Architecture_Workshop,WhatId = acc.Id);
        Event e3 = new Event(OwnerId = userinfo.getUserId(),Subject = 'Meeting',peopleai__MeetingStatus__c = 'Scheduled',StartDateTime = System.now()-1,EndDateTime = System.now() + 1,Method_of_Interaction__c = 'Face to Face',Type=System.Label.Other_Regular_Meeting,WhatId = acc.Id);
        events.add(e1);
        events.add(e2);
        events.add(e3);
        insert events;
       	
        CaptureAccountMetricsBatchSchedule testsche = new CaptureAccountMetricsBatchSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check 1', sch, testsche);
        Test.stopTest();
        Egress_Location__c cs = [Select Account__c From Egress_Location__c Limit 1];
        System.assert(cs.Account__c != NULL);
    }
}