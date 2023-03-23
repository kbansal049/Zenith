@isTest
public class leadTriggerHelperTest {
    
    static testMethod void test1(){
        
        Catch_All_Territory_List__c leadCatcher = new Catch_All_Territory_List__c();
        leadCatcher.Name = 'Catch All - APAC';
        leadCatcher.Record_Id__c = 'a3470000000UE2XAAW';
        insert leadCatcher;
        
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        le.NumberOfEmployees = 20;
        insert le;
        
        List<Lead> lstLds = new List<Lead>();
        
        lead le1 = new lead();
        le1.Company = 'test1 Company';
        le1.FirstName = 'Test';
        le1.LastName = 'Name';
        le1.Email = 'test@def.com';
        le1.NumberOfEmployees = 2020;
        lstLds.add(le1);
        
        lead le2 = new lead();
        le2.Company = 'test2 Company';
        le2.FirstName = 'Test';
        le2.LastName = 'Name';
        le2.Email = 'test@defd.com';
        le2.NumberOfEmployees = 6020;
        lstLds.add(le2);
        
        lead le3 = new lead();
        le3.Company = 'test3 Company';
        le3.FirstName = 'Test';
        le3.LastName = 'Name';
        le3.Email = 'test@xyz.com';
        le3.NumberOfEmployees = 42020;
        lstLds.add(le3);
        
        insert lstLds;
        
        List<Market_Segmentation_Setting__c> lstMKs = new List<Market_Segmentation_Setting__c>();
        
        Market_Segmentation_Setting__c mks = new Market_Segmentation_Setting__c();
        mks.Name = '1';
        mks.Start_Range__c = 0;
        mks.End_Range__c = 1999;
        mks.Market_Segmentation__c = 'Commercial';
        lstMKs.add(mks);
        
        Market_Segmentation_Setting__c mks1 = new Market_Segmentation_Setting__c();
        mks1.Name = '2';
        mks1.Start_Range__c = 2000;
        mks1.End_Range__c = 5999;
        mks1.Market_Segmentation__c = 'Enterprise';
        lstMKs.add(mks1);
        
        Market_Segmentation_Setting__c mks2 = new Market_Segmentation_Setting__c();
        mks2.Name = '3';
        mks2.Start_Range__c = 6000;
        mks2.End_Range__c = 39999;
        mks2.Market_Segmentation__c = 'Large Enterprise';
        lstMKs.add(mks2);
        
        Market_Segmentation_Setting__c mks3 = new Market_Segmentation_Setting__c();
        mks3.Name = '4';
        mks3.Start_Range__c = 40000;
        mks3.End_Range__c = 10000000;
        mks3.Market_Segmentation__c = 'Major';
        lstMKs.add(mks3);
        insert lstMKs;
        
        
        List<Lead> leadList = new List<Lead>();
        leadList.add(le);
        
        Map<id, lead> oldLeadMap = new Map<id, lead>();
        oldLeadMap.put(le.Id,le);
        
        leadTriggerHelper.caseCreationForDefaultTerrirtory(leadList, oldLeadMap);
        leadTriggerHelper.createCase(le);
        leadTriggerHelper.dealRegValidation(oldLeadMap);
        leadTriggerHelper.updateDealRegAfterLeadConversion(oldLeadMap,oldLeadMap);
        leadTriggerHelper.updateSalesTeamEmailFields(oldLeadMap,oldLeadMap);
        Map<id, id> leadAccManagerMap = new Map<id, id>();
        leadAccManagerMap.put(le.Id,UserInfo.getUserId());
        leadTriggerHelper.changeLeadOwnership(leadAccManagerMap);
        
        
        Map<id,Lead> Oldmap = new Map<id,Lead>();
        List<Lead> leadList2 = new List<Lead>();
        Lead le4 = new Lead();
        le4.Override_Market_Segment__c = false;
        le4 = le.clone(true,true,true, true);
        leadList2.add(le);
        le4.No_Employees_Users__c = '2000 - 5999';
        le4.NumberOfEmployees = null;
        Oldmap.put(le4.Id,le4);
        leadTriggerHelper.UpdateMarketSegment(leadList2,Oldmap, false, true);
    }
    
    static testMethod void test2(){
        Map<Id, Lead> leadOldMap = null;
        Map<Id, Lead> leadNewMap = new Map<Id, Lead>();
        List<Lead> leadList = new List<Lead>();
        
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        le.NumberOfEmployees = 20;
        le.ZPA_Manager__c = UserInfo.getUserId();
        le.MQL_Date__c=System.today();
        le.Person_First_MQL_Date__c=System.now();
        insert le;
        leadList.add(le);
        leadNewMap.put(le.Id, le);
        leadTriggerHelper.updateSalesTeamEmailFields(leadOldMap, leadNewMap);
        
        Task tsk = new Task();
        tsk.SDR_Qualified__c = true;
        tsk.Type = 'PG - Discovery Call';
        tsk.Whoid = le.Id;
        insert tsk;
        
        List<Campaign> CmpgnList= new List<Campaign>();
        Campaign cm = new Campaign();
        cm.name='ZPA Interactive';
        cm.Department__c = '5000-Corporate Marketing';
        cm.Geo__c = 'GLOBAL';
        cm.StartDate = Date.today();
        cm.EndDate = Date.today()+30;
        cm.Fiscal_Year__c = 'All Time';
        cm.Type = 'Default';
        cm.Campaign_Type__c = 'Agency Services';
        cm.Activity_Details__c = 'Agency Services';
        
        CmpgnList.add(cm);
        insert CmpgnList;
        
        List<CampaignMember> CmpgnMemList= new List<CampaignMember>();
        CampaignMember CM2= new CampaignMember(Campaignid=cm.id,Leadid=le.id,Status='Sent');
        CmpgnMemList.add(CM2);
        insert CmpgnMemList;
        leadOldMap = new Map<Id, Lead>();
        leadOldMap.put(le.id,new Lead(Qualifying_SDR__c = UserInfo.getUserId()));
        leadTriggerHelper.UpdateTaskFields(leadList, leadOldMap);       
        leadTriggerHelper.updateCampaignMemberBasedLead(leadList, leadOldMap);
    }
    
    static testMethod void test3(){
        
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        le.NumberOfEmployees = null;
        le.No_Employees_Users__c = '6000 - 19999';
        le.ZPA_Manager__c = UserInfo.getUserId();
        insert le;
        
        Lead le1 = new Lead();
        le1.Company = 'test1 Company';
        le1.FirstName = 'Test';
        le1.LastName = 'Name';
        le1.Email = 'test@def.com';
        le1.NumberOfEmployees = null;
        le1.No_Employees_Users__c = '40000+';
        le1.ZPA_Manager__c = UserInfo.getUserId();
        insert le1;
        
        List<Market_Segmentation_Setting__c> lstMKs = new List<Market_Segmentation_Setting__c>();
        
        Market_Segmentation_Setting__c mks = new Market_Segmentation_Setting__c();
        mks.Name = '1';
        mks.Start_Range__c = 0;
        mks.End_Range__c = 1999;
        mks.Market_Segmentation__c = 'Commercial';
        lstMKs.add(mks);
        
        Market_Segmentation_Setting__c mks1 = new Market_Segmentation_Setting__c();
        mks1.Name = '2';
        mks1.Start_Range__c = 2000;
        mks1.End_Range__c = 5999;
        mks1.Market_Segmentation__c = 'Enterprise';
        lstMKs.add(mks1);
        
        Market_Segmentation_Setting__c mks2 = new Market_Segmentation_Setting__c();
        mks2.Name = '3';
        mks2.Start_Range__c = 6000;
        mks2.End_Range__c = 39999;
        mks2.Market_Segmentation__c = 'Large Enterprise';
        lstMKs.add(mks2);
        
        Market_Segmentation_Setting__c mks3 = new Market_Segmentation_Setting__c();
        mks3.Name = '4';
        mks3.Start_Range__c = 40000;
        mks3.End_Range__c = 10000000;
        mks3.Market_Segmentation__c = 'Major';
        lstMKs.add(mks3);
        insert lstMKs;
        
        
        list< Lead > NewLeadList = new list< Lead >();
        NewLeadList.add(le);
        NewLeadList.add(le1);
        Map<id,Lead> Oldmap = null;
        leadTriggerHelper.UpdateMarketSegment(NewLeadList, Oldmap, true, false);
    }
}