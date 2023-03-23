/*****************************************************************************************
Name: CaptureAccountMetricsBatchScheduleTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Test class for CaptureAccountMetricsBatch & CaptureAccountMetricsBatchSchedule
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            21-Oct-2015    Initial Development
******************************************************************************************/ 

@isTest(SeeAllData=false)
private class CaptureAccountMetricsBatchScheduleTest {
    static testmethod void test() {
       ZscalerSetting__c zs = new ZscalerSetting__c(Name = 'AccountMetricsBatchSize', Value__c = '1');
       insert zs;
       Account acc = new Account(Name = 'Test Account',type = 'Customer');
       insert acc;
       Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
       insert prod;
       Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);
       cdtl.Contract_Detail_Status__c = 'Active';
       update cdtl;
       opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
       insert opp;
       List<Significant_Customer_Interaction__c> scilst = new List<Significant_Customer_Interaction__c>();

       
       string impConfRecTypeId =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Very Important Conf Call').RecordTypeId;
       string meetingRecTypeId =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Regular Meeting').RecordTypeId;
       string zsrrtid =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('QBR').RecordTypeId;
       string archsessionrtid =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Architecture Session').RecordTypeId;
       
       
       Significant_Customer_Interaction__c sci1 = new Significant_Customer_Interaction__c(); 
       sci1.Date__c = system.today()+1;
       sci1.Next_Steps__c = 'Test Data';
       sci1.Interaction_With__c = 'Customer';
       sci1.I_am_the__c = 'Attendee'; 
       sci1.RecordTypeId = meetingRecTypeId;
       sci1.Meeting_Notes__c = 'Test Data';
       sci1.Account_Name__c = acc.Id;
       sci1.Opportunity_Name__c = opp.Id;
       sci1.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci1.Method_Of_Interaction__c = 'F2F';
       insert sci1;
       
       Significant_Customer_Interaction__c sci2 = new Significant_Customer_Interaction__c(); 
       sci2.Date__c = system.today()+2;
       sci2.Next_Steps__c = 'Test Data';
       sci2.Interaction_With__c = 'Customer';
       sci2.I_am_the__c = 'Attendee'; 
       sci2.RecordTypeId = meetingRecTypeId;
       sci2.Meeting_Notes__c = 'Test Data';
       sci2.Account_Name__c = acc.Id;
       sci2.Opportunity_Name__c = opp.Id;
       sci2.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci2.Method_Of_Interaction__c = 'F2F';
       insert sci2;
       
       
       Significant_Customer_Interaction__c sci5 = new Significant_Customer_Interaction__c(); 
       sci5.Date__c = system.today()+1;
       sci5.Next_Steps__c = 'Test Data';
       sci5.Interaction_With__c = 'Customer';
       sci5.I_am_the__c = 'Attendee'; 
       sci5.RecordTypeId = meetingRecTypeId;
       sci5.Meeting_Notes__c = 'Test Data';
       sci5.Account_Name__c = acc.Id;
       sci5.Opportunity_Name__c = opp.Id;
       sci5.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci5.Method_Of_Interaction__c = 'Webex/Call';
       insert sci5;
       
       Significant_Customer_Interaction__c sci6 = new Significant_Customer_Interaction__c(); 
       sci6.Date__c = system.today()+1;
       sci6.Next_Steps__c = 'Test Data';
       sci6.Interaction_With__c = 'Customer';
       sci6.I_am_the__c = 'Attendee'; 
       sci6.RecordTypeId = meetingRecTypeId;
       sci6.Meeting_Notes__c = 'Test Data';
       sci6.Account_Name__c = acc.Id;
       sci6.Opportunity_Name__c = opp.Id;
       sci6.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci6.Method_Of_Interaction__c = 'Webex/Call';
       insert sci6;
       
       test.startTest();
       Significant_Customer_Interaction__c sci7 = new Significant_Customer_Interaction__c(); 
       sci7.Date__c = system.today()+2;
       sci7.Next_Steps__c = 'Test Data';
       sci7.Interaction_With__c = 'Customer';
       sci7.I_am_the__c = 'Attendee'; 
       sci7.RecordTypeId = zsrrtid;
       sci7.Meeting_Notes__c = 'Test Data';
       sci7.Account_Name__c = acc.Id;
       sci7.Opportunity_Name__c = opp.Id;
       sci7.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci7.Method_Of_Interaction__c = 'F2F';
       insert sci7;
       
       Significant_Customer_Interaction__c sci8 = new Significant_Customer_Interaction__c(); 
       sci8.Date__c = system.today()+2;
       sci8.Next_Steps__c = 'Test Data';
       sci8.Interaction_With__c = 'Customer';
       sci8.I_am_the__c = 'Attendee'; 
       sci8.RecordTypeId = archsessionrtid;
       sci8.Meeting_Notes__c = 'Test Data';
       sci8.Account_Name__c = acc.Id;
       sci8.Opportunity_Name__c = opp.Id;
       sci8.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci8.Method_Of_Interaction__c = 'F2F';
       insert sci8;
       
       
       Significant_Customer_Interaction__c sci9 = new Significant_Customer_Interaction__c(); 
       sci9.Next_Steps__c = 'Test Data';
       sci9.Interaction_With__c = 'Customer';
       sci9.I_am_the__c = 'Attendee'; 
       sci9.RecordTypeId = archsessionrtid;
       sci9.Meeting_Notes__c = 'Test Data';
       sci9.Opportunity_Name__c = opp.Id;
       sci9.Account_Name__c = acc.Id;
       sci9.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci9.Method_Of_Interaction__c = 'F2F';
       insert sci9;
       
       Significant_Customer_Interaction__c sci10 = new Significant_Customer_Interaction__c(); 
       sci10.Next_Steps__c = 'Test Data';
       sci10.Interaction_With__c = 'Customer';
       sci10.I_am_the__c = 'Attendee'; 
       sci10.RecordTypeId = zsrrtid;
       sci10.Meeting_Notes__c = 'Test Data';
       sci10.Opportunity_Name__c = opp.Id;
       sci10.Account_Name__c = acc.Id;
       sci10.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci10.Method_Of_Interaction__c = 'F2F';
       insert sci10;
       
       Significant_Customer_Interaction__c sci13 = new Significant_Customer_Interaction__c(); 
       sci13.Next_Steps__c = 'Test Data';
       sci13.Interaction_With__c = 'Customer';
       sci13.I_am_the__c = 'Attendee'; 
       sci13.RecordTypeId = meetingRecTypeId;
       sci13.Meeting_Notes__c = 'Test Data';
       sci13.Opportunity_Name__c = opp.Id;
       sci13.Account_Name__c = acc.Id;
       sci13.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci13.Method_Of_Interaction__c = 'Webex/Call';
       insert sci13;
       
       Significant_Customer_Interaction__c sci14 = new Significant_Customer_Interaction__c(); 
       sci14.Next_Steps__c = 'Test Data';
       sci14.Interaction_With__c = 'Customer';
       sci14.I_am_the__c = 'Attendee'; 
       sci14.RecordTypeId = meetingRecTypeId;
       sci14.Meeting_Notes__c = 'Test Data';
       sci14.Account_Name__c = acc.Id;
       sci14.Opportunity_Name__c = opp.Id;
       sci14.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci14.Method_Of_Interaction__c = 'Webex/Call';
       insert sci14;
       
       
       
       task ts = new task();
       ts.OwnerId = userinfo.getUserId();
       ts.Subject = 'Test Subject';
       ts.whatId = acc.Id;
       insert ts;
       
       task ts1 = new task();
       ts1.OwnerId = userinfo.getUserId();
       ts1.Subject = 'Test Subject';
       ts1.whatId = acc.Id;
       insert ts1;
       
	   Integer currentYear = System.Today().year();
       String CRON_EXP = '0 0 0 15 3 ? ' + currentYear;
       String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new CaptureAccountMetricsBatchSchedule());
       test.stopTest();
        
        Account acct = [SELECT id from Account LIMIT 1];
        system.assertNotEquals(NULL, acct.id);
        
    }
    
    static testmethod void test2() {
       ZscalerSetting__c zs = new ZscalerSetting__c(Name = 'AccountMetricsBatchSize', Value__c = '1');
       insert zs;
       Account acc = new Account(Name = 'Test Account',type = 'Customer');
       insert acc;
        
       Product2 prod = TestDatafactory_Zscaler.constructProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone', true, false, false);
       insert prod;
       Contract_Detail__c cdtl = TestDatafactory_Zscaler.insertContractDetail('test contract', acc.Id, prod.Id, system.today(),system.today() + 10, 10, 100, null, null, 100, null, false, false);
       cdtl.Contract_Detail_Status__c = 'Active';
       update cdtl;
       opportunity opp = new opportunity(Name = 'Test opportunity', AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
       insert opp;
       List<Significant_Customer_Interaction__c> scilst = new List<Significant_Customer_Interaction__c>();

       
       
       string impConfRecTypeId =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Very Important Conf Call').RecordTypeId;
       string meetingRecTypeId =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Regular Meeting').RecordTypeId;
       string zsrrtid =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('QBR').RecordTypeId;
       string archsessionrtid =  Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get('Architecture Session').RecordTypeId;
       
       Significant_Customer_Interaction__c sci1_1 = new Significant_Customer_Interaction__c(); 
       sci1_1.Date__c = system.today()+1;
       sci1_1.Next_Steps__c = 'Test Data';
       sci1_1.Interaction_With__c = 'Customer';
       sci1_1.I_am_the__c = 'Attendee'; 
       sci1_1.RecordTypeId = meetingRecTypeId;
       sci1_1.Meeting_Notes__c = 'Test Data';
       sci1_1.Opportunity_Name__c = opp.Id;
       sci1_1.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci1_1.Method_Of_Interaction__c = 'F2F';
       insert sci1_1;
       
       Significant_Customer_Interaction__c sci2_1 = new Significant_Customer_Interaction__c(); 
       sci2_1.Date__c = system.today()+2;
       sci2_1.Next_Steps__c = 'Test Data';
       sci2_1.Interaction_With__c = 'Customer';
       sci2_1.I_am_the__c = 'Attendee'; 
       sci2_1.RecordTypeId = meetingRecTypeId;
       sci2_1.Meeting_Notes__c = 'Test Data';
       sci2_1.Opportunity_Name__c = opp.Id;
       sci2_1.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci2_1.Method_Of_Interaction__c = 'F2F';
       insert sci2_1;
       
       
       Significant_Customer_Interaction__c sci5 = new Significant_Customer_Interaction__c(); 
       sci5.Date__c = system.today()+1;
       sci5.Next_Steps__c = 'Test Data';
       sci5.Interaction_With__c = 'Customer';
       sci5.I_am_the__c = 'Attendee'; 
       sci5.RecordTypeId = meetingRecTypeId;
       sci5.Meeting_Notes__c = 'Test Data';
       sci5.Opportunity_Name__c = opp.Id;
       sci5.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci5.Method_Of_Interaction__c = 'Webex/Call';
       insert sci5;
       
       Significant_Customer_Interaction__c sci6 = new Significant_Customer_Interaction__c(); 
       sci6.Date__c = system.today()+1;
       sci6.Next_Steps__c = 'Test Data';
       sci6.Interaction_With__c = 'Customer';
       sci6.I_am_the__c = 'Attendee'; 
       sci6.RecordTypeId = meetingRecTypeId;
       sci6.Meeting_Notes__c = 'Test Data';
       sci6.Opportunity_Name__c = opp.Id;
       sci6.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci6.Method_Of_Interaction__c = 'Webex/Call';
       insert sci6;
       
       test.startTest();
       Significant_Customer_Interaction__c sci7 = new Significant_Customer_Interaction__c(); 
       sci7.Date__c = system.today()+2;
       sci7.Next_Steps__c = 'Test Data';
       sci7.Interaction_With__c = 'Customer';
       sci7.I_am_the__c = 'Attendee'; 
       sci7.RecordTypeId = zsrrtid;
       sci7.Meeting_Notes__c = 'Test Data';
       sci7.Opportunity_Name__c = opp.Id;
       sci7.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci7.Method_Of_Interaction__c = 'F2F';
       insert sci7;
       
       Significant_Customer_Interaction__c sci8 = new Significant_Customer_Interaction__c(); 
       sci8.Date__c = system.today()+2;
       sci8.Next_Steps__c = 'Test Data';
       sci8.Interaction_With__c = 'Customer';
       sci8.I_am_the__c = 'Attendee'; 
       sci8.RecordTypeId = archsessionrtid;
       sci8.Meeting_Notes__c = 'Test Data';
       sci8.Opportunity_Name__c = opp.Id;
       sci8.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci8.Method_Of_Interaction__c = 'F2F';
       insert sci8;
       
       
       Significant_Customer_Interaction__c sci11 = new Significant_Customer_Interaction__c(); 
       sci11.Next_Steps__c = 'Test Data';
       sci11.Interaction_With__c = 'Customer';
       sci11.I_am_the__c = 'Attendee'; 
       sci11.RecordTypeId = archsessionrtid;
       sci11.Meeting_Notes__c = 'Test Data';
       sci11.Opportunity_Name__c = opp.Id;
       sci11.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci11.Method_Of_Interaction__c = 'F2F';
       insert sci11;
       
       Significant_Customer_Interaction__c sci12 = new Significant_Customer_Interaction__c(); 
       sci12.Next_Steps__c = 'Test Data';
       sci12.Interaction_With__c = 'Customer';
       sci12.I_am_the__c = 'Attendee'; 
       sci12.RecordTypeId = zsrrtid;
       sci12.Meeting_Notes__c = 'Test Data';
       sci12.Opportunity_Name__c = opp.Id;
       sci12.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci12.Method_Of_Interaction__c = 'F2F';
       insert sci12;
       
       Significant_Customer_Interaction__c sci13 = new Significant_Customer_Interaction__c(); 
       sci13.Next_Steps__c = 'Test Data';
       sci13.Interaction_With__c = 'Customer';
       sci13.I_am_the__c = 'Attendee'; 
       sci13.RecordTypeId = meetingRecTypeId;
       sci13.Meeting_Notes__c = 'Test Data';
       sci13.Opportunity_Name__c = opp.Id;
       sci13.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci13.Method_Of_Interaction__c = 'Webex/Call';
       insert sci13;
       
       Significant_Customer_Interaction__c sci14 = new Significant_Customer_Interaction__c(); 
       sci14.Next_Steps__c = 'Test Data';
       sci14.Interaction_With__c = 'Customer';
       sci14.I_am_the__c = 'Attendee'; 
       sci14.RecordTypeId = meetingRecTypeId;
       sci14.Meeting_Notes__c = 'Test Data';
       sci14.Opportunity_Name__c = opp.Id;
       sci14.Current_POC_Phase__c = '2-Documenting Detailed POC Plan';
       sci14.Method_Of_Interaction__c = 'Webex/Call';
       insert sci14;
       
       
       task ts = new task();
       ts.OwnerId = userinfo.getUserId();
       ts.Subject = 'Test Subject';
       ts.whatId = acc.Id;
       insert ts;
       
       task ts1 = new task();
       ts1.OwnerId = userinfo.getUserId();
       ts1.Subject = 'Test Subject';
       ts1.whatId = acc.Id;
       insert ts1;
        
        List<Event> events = new List<Event>();
        Event e1 = new Event(OwnerId = userinfo.getUserId(),Subject = 'Meeting',peopleai__MeetingStatus__c = 'Completed', ActivityDate = date.parse('05/11/2024'),StartDateTime = System.now()-1,EndDateTime = System.now() + 1,Method_of_Interaction__c = 'Face to Face',Type = System.Label.Post_Sale_Operational_Review,WhatId = acc.Id);
        Event e2 = new Event(OwnerId = userinfo.getUserId(),Subject = 'Meeting',peopleai__MeetingStatus__c = 'Scheduled',StartDateTime = System.now()-1,EndDateTime = System.now() + 1,Method_of_Interaction__c = 'Remote',Type = System.Label.VO_Architecture_Workshop,WhatId = acc.Id);
        Event e3 = new Event(OwnerId = userinfo.getUserId(),Subject = 'Meeting',peopleai__MeetingStatus__c = 'Scheduled',StartDateTime = System.now()-1,EndDateTime = System.now() + 1,Method_of_Interaction__c = 'Face to Face',Type=System.Label.Other_Regular_Meeting,WhatId = acc.Id);
        Event e4 = new Event(OwnerId = userinfo.getUserId(),Subject = 'Meeting',peopleai__MeetingStatus__c = 'Scheduled',StartDateTime = System.now()-1,EndDateTime = System.now() + 1,Method_of_Interaction__c = 'Remote',Type = System.Label.Other_Regular_Meeting,WhatId = acc.Id);
        Event e5 = new Event(OwnerId = userinfo.getUserId(),Subject = 'Meeting',peopleai__MeetingStatus__c = 'Scheduled',StartDateTime = System.now()-1,EndDateTime = System.now() + 1,Method_of_Interaction__c = 'Remote',Type = 'Regular Meeting',WhatId = acc.Id);
        events.add(e1);
        events.add(e2);
        events.add(e3);
        events.add(e4);
        events.add(e5);
        insert events;
        
        Contact cntct = new Contact(FirstName = 'Test',LastName = 'Contact');
        insert cntct;
        
        Campaign c = new Campaign(Name = 'Camp Test');
        insert c;
       	
        CampaignMember cm = new CampaignMember(Account__c = acc.Id,ContactId = cntct.Id,CampaignId = c.Id);
        TriggerHandler.bypass('CampaignMemberTriggerHandler');
        insert cm;
        TriggerHandler.clearbypass('CampaignMemberTriggerHandler');
        
        
        ZDX_Cloud_Usage__c zdx = new ZDX_Cloud_Usage__c(Account__c = acc.Id,External_ID__c = '12345678');
        insert zdx;
        
        Recordtype rc = [Select id,Name From RecordType where sObjectType='Zscaler_Cloud_ID__c' and isActive=true and name = 'ZIA Cloud ID' LIMIT 1];
        
        List<Zscaler_Cloud_ID__c> cloudList = new List<Zscaler_Cloud_ID__c>();
        Zscaler_Cloud_ID__c cloudId = new Zscaler_Cloud_ID__c(Name = '1441203345204183',Account__c = acc.Id,Status__c = 'Production',Cloud_Type__c = 'ZIA',RecordTypeId = rc.Id );
        Zscaler_Cloud_ID__c cloudId1 = new Zscaler_Cloud_ID__c(Name = '1441203345204182',Account__c = acc.Id,Cloud_Type__c = 'ZIA',Latest_ZDX_Cloud_Usage__c = zdx.Id,Total_SSL_Inspected_Transactions__c = 10,Total_number_of_IPSec_tunnels__c = 10,Number_of_GRE_tunnels__c = 10,RecordTypeId = rc.Id);
        cloudList.add(cloudId);
        cloudList.add(cloudId1);
        insert cloudList;
        
        Customer_Next_Steps_History__c cns = new Customer_Next_Steps_History__c(Account__c = acc.Id);
        insert cns;
        
        Egress_Location__c el = new Egress_Location__c(Account__c = acc.Id,Egress_Location__c = opp.id);
        insert el;
       
       Integer currentYear = System.Today().year();
       String CRON_EXP = '0 0 0 15 3 ? ' + currentYear;
       String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new CaptureAccountMetricsBatchSchedule());
       test.stopTest();
        
        Egress_Location__c cs = [Select Account__c From Egress_Location__c Limit 1];
        System.assert(cs.Account__c != NULL);
    }
}