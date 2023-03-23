/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ManageProvisioningControllerTest {
    
    @isTest
    private static void testManageProvisioningController(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User u = new user();
        u.LastName = 'Test Code Welcome';
        u.Email = 'Test.gsfcd@test.com';
        u.Alias = 'Tcode';
        u.Username = 'Test.gsfcd@test.com';
        u.ManagerId = '0054u0000075Jn0AAE';
        u.CommunityNickname = 'test1211';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileID = p.id;
        insert u;
        
        Id trialPGRecordtypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        Id subscriptionPGRecordtypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();
        
        Account acc = new Account();
        acc.name = 'Zscaler Internal Employee Tenant Requests';
        insert acc;
		String accID = acc.Id;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Domain__c ='Test';
        quote.Line_Item_SKU_Approval__c ='ZIA Approval';
        insert quote;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test';
        opp.StageName = '3 - Sponsorship';
        opp.CloseDate = system.today();
        opp.Netsuite_Sales_Order_No__c='353200';
        opp.Netsuite_Sales_Order_Internal_ID__c='234234';
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        opp.AccountId = accID;
        insert opp;
        String oppId = opp.Id;
        
        PO_Detail__c poDet = new PO_Detail__c();
        poDet.PO_Number__c = 'XYZZ';
        poDet.Source__c='EDI';
        poDet.Proposal_Quote_Number__c = quote.Id;
        poDet.Opportunity__c = oppId;
        TriggerHandler.bypass('PODetailTriggerHandler');
        insert poDet;
        
        Provisioning_Request__c provreq = new Provisioning_Request__c();
        provreq.Approval_Submission_Date__c =Date.newInstance(2022, 10, 10);
        insert provreq;

        Product2 prod = new Product2();
        prod.Name='Test88';
        prod.ProductCode='testproduct';
        insert prod;

        List<Zscaler_Cloud_ID__c> zscsList = new List<Zscaler_Cloud_ID__c>();
        Zscaler_Cloud_ID__c zscal = new Zscaler_Cloud_ID__c();
        zscal.Account__c=accID;
        zscal.Org_Name__c='TestOrg-1';
        zscal.Name='Test88';
        zscal.Status__c='Trial';
        zscsList.add(zscal);
        
        Zscaler_Cloud_ID__c zscal2 = new Zscaler_Cloud_ID__c();
        zscal2.Account__c=accID;
        zscal2.Org_Name__c='TestOrg-2';
        zscal2.Name='Test99';
        zscal2.Status__c='Subscription';
        zscsList.add(zscal2);
        insert zscsList;
        
        List<Provisioning_Group__c> prgsList = new List<Provisioning_Group__c>();
        Provisioning_Group__c pgroup = new Provisioning_Group__c();
        pgroup.Comments__c='Test3';
        pgroup.Product_Line__c='ZIA';
        pgroup.Provisioning_Process__c='New Tenant';
        pgroup.Organization_Domain__c='uoflhealthcare.org';
        pgroup.Status__c='Initiated';
        pgroup.Approval_Status__c='Submitted';
        pgroup.Sub_Status__c='';
        pgroup.PG_Request_Type__c='Create';
        pgroup.Provisioning_Type__c='Auto';
        pgroup.Preferred_Cloud__c='Zscaler.net';
        pgroup.Start_Date__c = System.today();
        pgroup.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup.Account__c = accID;
        pgroup.Opportunity__c = oppId;
        pgroup.Provisioning_Request__c = provreq.Id;
        pgroup.Zscaler_Cloud_ID__c = zscal.Id;
        pgroup.Associated_ZIA_Zscaler_Cloud__c = zscal.Id;
        pgroup.RecordTypeId = trialPGRecordtypeId;
        prgsList.add(pgroup);
        
        Provisioning_Group__c pgroup2 = new Provisioning_Group__c();
        pgroup2.Comments__c='Test5';
        pgroup2.Product_Line__c='ZIA';
        pgroup2.Provisioning_Process__c='New Tenant';
        pgroup2.Organization_Domain__c='uoflhealthcare.org';
        pgroup2.Status__c='Provisioning in Progress';
        pgroup2.Approval_Status__c='Submitted';
        pgroup2.Sub_Status__c='';
        pgroup2.PG_Request_Type__c='Create';
        pgroup2.Provisioning_Type__c='Auto';
        pgroup2.Preferred_Cloud__c='Zscaler.net';
        pgroup2.Start_Date__c = System.today();
        pgroup2.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup2.Account__c = accID;
        pgroup2.Opportunity__c = oppId;
        pgroup2.Consumer_User__c = u.Id;
        pgroup2.Provisioning_Request__c = provreq.Id;
        pgroup2.Zscaler_Cloud_ID__c = zscal.Id;
        pgroup2.Associated_ZIA_Zscaler_Cloud__c = zscal.Id;
        pgroup2.RecordTypeId = trialPGRecordtypeId;
        prgsList.add(pgroup2);
        
        Provisioning_Group__c pgroup3 = new Provisioning_Group__c();
        pgroup3.Comments__c='Test4';
        pgroup3.Product_Line__c='ZDX';
        pgroup3.Provisioning_Process__c='New Tenant';
        pgroup3.Organization_Domain__c='uoflhealthcare.org';
        pgroup3.Status__c='Provisioned';
        pgroup3.Approval_Status__c='Submitted';
        pgroup3.Sub_Status__c='';
        pgroup3.PG_Request_Type__c='Create';
        pgroup3.Provisioning_Type__c='Auto';
        pgroup3.Preferred_Cloud__c='Zscaler.net';
        pgroup3.Start_Date__c = System.today();
        pgroup3.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup3.Account__c = accID;
        pgroup3.Opportunity__c = oppId;
        pgroup3.Provisioning_Request__c = provreq.Id;
        pgroup3.Zscaler_Cloud_ID__c = zscal2.Id;
        pgroup3.Associated_ZIA_Zscaler_Cloud__c = zscal2.Id;
        pgroup3.RecordTypeId = subscriptionPGRecordtypeId;
        prgsList.add(pgroup3);
        
        Provisioning_Group__c pgroup4 = new Provisioning_Group__c();
        pgroup4.Comments__c='Test5';
        pgroup4.Product_Line__c='ZIA';
        pgroup4.Provisioning_Process__c='New Tenant';
        pgroup4.Organization_Domain__c='uoflhealthcare.org';
        pgroup4.Status__c='Provisioned';
        pgroup4.Approval_Status__c='Submitted';
        pgroup4.Sub_Status__c='';
        pgroup4.PG_Request_Type__c='Create';
        pgroup4.Provisioning_Type__c='Auto';
        pgroup4.Preferred_Cloud__c='Zscaler.net';
        pgroup4.Start_Date__c = System.today();
        pgroup4.End_Date__c=Date.newInstance(2022, 12, 12);
        pgroup4.Account__c = accID;
        pgroup4.Opportunity__c = oppId;
        pgroup4.Consumer_User__c = u.Id;
        pgroup4.Provisioning_Request__c = provreq.Id;
        pgroup4.Zscaler_Cloud_ID__c = zscal2.Id;
        pgroup4.Associated_ZIA_Zscaler_Cloud__c = zscal2.Id;
        pgroup4.RecordTypeId = subscriptionPGRecordtypeId;
        prgsList.add(pgroup4);
        insert prgsList;

        List<Provisioning_Product__c> provProdsList = new List<Provisioning_Product__c>();
        Provisioning_Product__c provprod = new Provisioning_Product__c();
        provprod.Name = 'Test101';
        provprod.Product__c = prod.id;
        provprod.Quantity__c = 5;
        provprod.Provisioning_Group__c = pgroup.id;
        provprod.Start_Date__c = System.today();
        provprod.End_Date__c = System.today() + 360;
        provProdsList.add(provprod);

        Provisioning_Product__c provprod1 = new Provisioning_Product__c();
        provprod1.Name = 'Test201';
        provprod1.Product__c = prod.id;
        provprod1.Quantity__c = 5;
        provprod1.Provisioning_Group__c = pgroup2.id;
        provprod1.Start_Date__c = System.today();
        provprod1.End_Date__c = System.today() + 360;
        provProdsList.add(provprod1);

        Provisioning_Product__c provprod2 = new Provisioning_Product__c();
        provprod2.Name = 'Test301';
        provprod2.Product__c = prod.id;
        provprod2.Quantity__c = 5;
        provprod2.Provisioning_Group__c = pgroup3.id;
        provprod2.Start_Date__c = System.today();
        provprod2.End_Date__c = System.today() + 360;
        provProdsList.add(provprod2);
        insert provProdsList;

        Provisioning_Contact__c pcon = new Provisioning_Contact__c();
        pcon.Provisioning_Group__c = pgroup.Id;
        pcon.Zscaler_Cloud_ID__c = zscal.Id;
        insert pcon;

        String pgId = pgroup.Id;
        List<Provisioning_Group__c> pgList = new List<Provisioning_Group__c>();
        List<Provisioning_Group__c> pgList2 = new List<Provisioning_Group__c>();
        List<ManageProvisioningController.ZscalerTenantWrapper> zscalList = new List<ManageProvisioningController.ZscalerTenantWrapper>();
        List<ManageProvisioningController.ZscalerTenantWrapper> zscalList2 = new List<ManageProvisioningController.ZscalerTenantWrapper>();
        ManageProvisioningController.ProvisioningWrapper provwrap = new ManageProvisioningController.ProvisioningWrapper();
        ManageProvisioningController.ProvisioningWrapper provwrap2 = new ManageProvisioningController.ProvisioningWrapper();
        
        String draftpgstatus;
        Boolean check;
        Boolean check2;
        Date checkdate;

        Test.startTest();
            provwrap = ManageProvisioningController.retriveProvisioningDataFromOpp(oppId);
            pgList = ManageProvisioningController.retrivePGRecord(oppId);
            provwrap2 = ManageProvisioningController.retriveProvisioningDataFromAcc(accID);
            zscalList = ManageProvisioningController.retreiveTenantRecFromAcc(accID);
            zscalList2 = ManageProvisioningController.retreiveTenantRecFromOpp(oppId, accID, 'random');
            check = ManageProvisioningController.extendPGMethod(pgId, 'test');
            pgList2 = ManageProvisioningController.fetchDraftPG(oppId);
            check2 = ManageProvisioningController.decomissionPGMethod(pgId);
            draftpgstatus = ManageProvisioningController.updateDraftPGStatus(pgId);
        	ManageProvisioningController.retriveProvisioningDataIntProv(accID, u.Id);
        	ManageProvisioningController.fetchInterZscalerAccountid();
        	ManageProvisioningController.retreiveTenantRecFromAccINT(accID, (string)u.id);
        	ManageProvisioningController.getEndDateAndApprovalStatusForPG(pgId);
        	ManageProvisioningController.checkZIAProvisioned(pgroup3.id);
        	ManageProvisioningController.getDataforInfoMessage(oppId);
        Test.stopTest();

        System.assert(pgList.size() > 0, 'Pass');
        System.assert(zscalList.size() > 0, 'Pass');
        System.assert(zscalList2.size() > 0, 'Pass');
        System.assert(check, 'Pass');
        System.assert(check2, 'Pass');
        System.assert(draftpgstatus != null, 'Pass');
        System.assert(provwrap != null, 'Pass');
        System.assert(provwrap2 != null, 'Pass');
     }
}