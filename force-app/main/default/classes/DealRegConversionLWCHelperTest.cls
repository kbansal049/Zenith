/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-15-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class DealRegConversionLWCHelperTest{
    @testSetup
    static void createtestData(){
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
        
        Skip_Triggers_User_Based__c sk = new Skip_Triggers_User_Based__c();
        sk.SetupOwnerId = userInfo.getUserId();
        sk.Object_s_to_skip__c = 'Deal_Reg__c';
        insert sk;
        
        TriggerUtility.dealRegAfterUpdateExecuted();
        TriggerUtility.dealRegAfterInsertExecuted();
        TriggerUtility.dealRegBeforeInsertExecuted();
        TriggerUtility.contactPatchManagerExecuted();
        TriggerUtility.conWhiteSpaceUpdateExecuted();
        TriggerUtility.accToContactOwnerExecuted();
        TriggerUtility.contactOwnerShipExecuted();
        TriggerUtility.oppCaseCreationExecuted();
        TriggerUtility.requestDecommissionPrExecuted();
        TriggerUtility.oppSpliSalesTeamExecuted();
        TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        list<Account> accInsertList = new list<Account>();
        
        Id partnerAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        acc.Program_Type__c = 'Distribution';
        acc.recordTypeId = partnerAccRecordTypeId;
        acc.SummitDistribution__c = True;
        acc.Service_Authorizations__c = 'Support Services Authorized';
        acc.Type = 'Partner';
        acc.Partner_Type__c ='Partner-Distributor';
        accInsertList.add(acc);
        
        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner.com';
        acc1.Is_Federal_Account_Sync__c = TRUE;
        acc1.SummitDistribution__c = True;
        acc1.Program_Type__c = 'Reseller';
        acc1.recordTypeId = partnerAccRecordTypeId;
        acc1.Service_Authorizations__c = 'Support Services Authorized';
        accInsertList.add(acc1);
        insert accInsertList;

        Campaign camp = new Campaign();
        camp.Name = 'DealRegistration';
        camp.EndDate = System.today() + 30;
        camp.IsActive = true;
        insert camp;
        
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accInsertList[1].Id,true,System.today()+60,System.today()-30,'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,accInsertList[1].Id,true,System.today(),System.today(),'Summit - Federal','MSP'))[1]);
        piList[1].Default__c=true;
        piList[1].Active__c=true;
        insert piList;
        
        Contact con = new Contact();
        con.firstName = 'Jhon';
        con.LastName = 'Smith';
        con.email = 'jhon@abcd.com';
        con.AccountId = accInsertList[0].Id;
        insert con;
        
        Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test1234@abc.com';
        insert le;
        
        Deal_Reg__c deal = new Deal_Reg__c();
        deal.End_Customer_Contact_Name__c = 'Test';
        deal.End_Customer_Contact_Last_Name__c= 'Test';
        deal.End_Customer_Country__c = 'US';
        deal.End_Customer_Domain__c = 'abc.com';
        deal.End_Customer_Email__c  = 'Test@abc.com';
        deal.End_Customer_Name__c = 'ABC Inc';
        deal.End_Customer_Phone__c = '123456789';
        deal.End_Customer_State__c = 'US';
        deal.DS_Review_Status__c = 'Pending Review';
        deal.Estimated_Amount__c = 1234567;
        deal.Expected_Close_Date__c = System.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Partner_Account__c = accInsertList[0].Id;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Pending Conversion';
        deal.AW_Partner_Intent__c = 'Interested';
        deal.POV_Partner_Intent__c = 'Interested';
        deal.Delivery_Intent__c = 'Interested';
        deal.Distributor__c = acc.Id;
        insert deal;

        deal.OwnerId = userInfo.getuserId();
        deal.Account_Type__c ='Customer';
        update deal;
        System.debug('PArtnerType'+deal.Partner_Type__c);
    }
    
    static testmethod void test1(){
        Test.startTest();
            Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
            skipTriggers.Skip_Account_Triggers__c = true;
            skipTriggers.Skip_Opportunity_Triggers__c = true;
            skipTriggers.Name = 'SkipTriggers';
            insert skipTriggers;
            
            TriggerUtility.dealRegAfterUpdateExecuted();
            TriggerUtility.dealRegAfterInsertExecuted();
            TriggerUtility.dealRegBeforeInsertExecuted();
            TriggerUtility.contactPatchManagerExecuted();
            TriggerUtility.conWhiteSpaceUpdateExecuted();
            TriggerUtility.accToContactOwnerExecuted();
            TriggerUtility.contactOwnerShipExecuted();
            TriggerUtility.oppCaseCreationExecuted();
            TriggerUtility.requestDecommissionPrExecuted();
            TriggerUtility.oppSpliSalesTeamExecuted();
            TriggerUtility.caseCreationForLeadTerrirtoryExecuted();
            TriggerUtility.prospectTypeUpdExecuted();

            list<Account> accInsertList = new list<Account>();
            Account acc = new account();
            Acc.Name = 'Test2';
            acc.Domain__c = 'abcs.com';
            accInsertList.add(acc);
            
            Account acc1 = new account();
            Acc1.Name = 'Test1';
            acc1.Domain__c = 'partner1.com';
            accInsertList.add(acc1);
            insert accInsertList;
            
            Contact con = new Contact();
            con.firstName = 'dsd';
            con.LastName = 'sdsd';
            con.email = 'smscd@abc.com';
            con.AccountId = accInsertList[0].Id;
            insert con;
            
            Campaign camp = new Campaign();
            camp.Name = 'Deals';
            camp.EndDate = System.today() + 30;
            camp.IsActive = true;
            insert camp;

            ZscalerSetting__c zs = new ZscalerSetting__c();
            zs.Name = 'DealRegCamp';
            zs.Value__c = ''+camp.Id;
            insert zs;

            System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
            ZscalerSetting__c zs1 = new ZscalerSetting__c();
            zs1.Name = 'DealRegCaseReviewOwnerId';
            zs1.Value__c = ''+userInfo.getuserId();
            insert zs1;
            
            Lead le = new Lead();
            le.Company = 'tests deo';
            le.FirstName = 'Test34';
            le.LastName = 'Name23';
            le.Email = 'test122@test.com';
            insert le;
            
            Deal_Reg__c deal = new Deal_Reg__c();
            deal.End_Customer_Contact_Name__c = 'Test1';
            deal.End_Customer_Contact_Last_Name__c= 'Test1';
            deal.End_Customer_Country__c = 'IN';
            deal.End_Customer_Domain__c = 'abcd.com';
            deal.End_Customer_Email__c  = 'asa@abcd.com';
            deal.End_Customer_Name__c = 'ABC Inc';
            deal.End_Customer_Phone__c = '123456789';
            deal.End_Customer_State__c = 'US';
            deal.DS_Review_Status__c = 'Pending Review';
            deal.Estimated_Amount__c = 1234567;
            deal.Expected_Close_Date__c = System.today() + 30;
            deal.Market_Segment__c = 'SMB';
            deal.Number_of_Users__c = 1234567;
            deal.Partner_Company_Name__c = 'Test partner';
            deal.Partner_Contact_Email__c = 'Test@partner.com';
            deal.Partner_Contact_Name__c = 'Test';
            deal.Partner_Contact_Last_Name__c  = 'Partner';
            deal.Partner_Country__c  = 'US';
            deal.Partner_Domain__c  = 'partner.com';
            deal.Source__c = 'Deal Reg';
            deal.Status__c = 'Submitted';
            deal.Contact__c = con.id;
            deal.Account_Manager__c = userinfo.getUserId();
            insert deal;
            
            DealRegToConvert ctrl = new DealRegToConvert();
            System.debug(ctrl.dealregmap);
            ctrl.dealtoconvert = deal.Id;
            ctrl.checkconvert();
            
            Opportunity opp = new Opportunity();
            Opp.Name = 'Test Opp';
            Opp.CloseDate = System.Today() + 30;
            Opp.AccountId = accInsertList[0].Id;
            Opp.Amount = 123456;
            opp.StageName = Label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/;
            opp.Deal_Reg__c = deal.Id;
        	TriggerHandler.bypass('OpportunityTriggerHandler');
            insert Opp;
            
            DealRegConversionLWCHelper.init(deal.id);
            DealRegConversionLWCHelper.convertDRtoOpportunity(Opp.id, deal.id);
        test.stopTest();
    }
    
    @isTest
    static void test2() {
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.SkipOppTriggerExecuted();
        TriggerUtility.prospectTypeUpdExecuted();
        triggerUtility.contactPatchManagerExecuted();
        triggerUtility.accTerritoryPatchExecuted();
        triggerUtility.oppPatchManagerAfterInsertExecuted();
        triggerUtility.oppPatchManagerAfterUpdateExecuted();
        TriggerUtility.ProspectEntitlementExecuted();
        
		Deal_Reg__c deal = [SELECT ID, Partner_Category__c FROM Deal_Reg__c WHERE End_Customer_Email__c = 'Test@abc.com'] ;
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'PO Document';
        cv.PathOnClient = 'PO_Document.pdf';
        cv.VersionData = Blob.valueOf('ZINFI-Id-XYZ001 Test Content');
        cv.IsMajorVersion = true;
        cv.Source_fileupload__c = 'AVPApprovalonDR';
        insert cv;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document';
        cv1.PathOnClient = 'SOW_Document.pdf';
        cv1.VersionData = Blob.valueOf('ZINFI-Id-XYZ001 Test Content');
        cv1.IsMajorVersion = true;
        cv1.Source_fileupload__c = 'AVPApprovalonDR';
        insert cv1;
        
        //Get Content Documents
        Id poDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Get Content Documents
        Id sowDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = deal.Id;
        cdl.ContentDocumentId = poDocId;
        cdl.shareType = 'V';
        insert cdl;
        
        List<Map<String, Object>> files = new List<Map<String, Object>>();
        Map<string, object> filesMap = new Map<string, object>();
        filesMap.put('PathOnClient','po1.pdf');
        filesMap.put('Title','po1.pdf');
        filesMap.put('VersionData',cv1.VersionData );
        Map<string,object> filesMap1 = new Map<string,object>();
        filesMap1.put('PathOnClient','po1.pdf');
        filesMap1.put('Title','po1.pdf');
        filesMap1.put('VersionData',cv.VersionData );
        files.add(filesMap);
        
        test.starttest();
            DealRegConversionLWCHelper.uploadFiles(files, deal, 'AVPApprovalonDR', true);
        test.stoptest();
    }
}