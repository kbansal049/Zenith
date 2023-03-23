@isTest
public class ProvisioningSHIFTPOCControllerTest {
    
    
    
    @isTest
    public static void testMethod1(){
        
        //Insert Custom Settings
        ZscalerCustomSetting__c setting = new ZscalerCustomSetting__c();
        setting.Name = 'DefaultPRDecommisionContact';
        setting.Value__c = '0034u00002UusGqAAJ';
        insert setting;
        
        ZscalerShiftLogin__c zsl = new ZscalerShiftLogin__c();
        zsl.Name = 'Sandbox';
        zsl.Password__c = '345345';
        zsl.Endpoint__c = 'https://test.com';
        zsl.Username__c = 'testUser';
        insert zsl;
        
        ZscalerShiftLogin__c zslProd = new ZscalerShiftLogin__c();
        zslProd.Name = 'Production';
        zslProd.Password__c = '345345';
        zslProd.Endpoint__c = 'https://test.com';
        zslProd.Username__c = 'testUser';
        insert zslProd;
        
        TriggerUtility.SkipAccTriggerExecuted();
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
        update pat;
        
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        acc.Sales_Territory__c = pateam.Id;
        acc.Patch__c = pat.Id;
        insert acc;
        
        
        Opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Shift').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        insert pr;
        
        
        Test.startTest();
        
        PageReference ref = new PageReference('/apex/ProvisioningFevaRequest?id=' +pr.Id);
        Test.setCurrentPage(ref);
        ProvisioningSHIFTPOCController con = new ProvisioningSHIFTPOCController();
        con.initProvisionRequest();
        con.createCompany();
        con.createUser();
        con.sendUserEmailNotification();
        con.goback();
        
        ProvisioningSHIFTPOCHelper.createPOCtraffic('234435',System.now(),System.now());
        
        Test.stopTest();
    }

	@isTest
    public static void testMethod1_1(){
        
        //Insert Custom Settings
        ZscalerCustomSetting__c setting = new ZscalerCustomSetting__c();
        setting.Name = 'DefaultPRDecommisionContact';
        setting.Value__c = '0034u00002UusGqAAJ';
        insert setting;
        
        ZscalerShiftLogin__c zsl = new ZscalerShiftLogin__c();
        zsl.Name = 'Sandbox';
        zsl.Password__c = '345345';
        zsl.Endpoint__c = 'https://test.com';
        zsl.Username__c = 'testUser';
        insert zsl;
        
        ZscalerShiftLogin__c zslProd = new ZscalerShiftLogin__c();
        zslProd.Name = 'Production';
        zslProd.Password__c = '345345';
        zslProd.Endpoint__c = 'https://test.com';
        zslProd.Username__c = 'testUser';
        insert zslProd;
        
        TriggerUtility.SkipAccTriggerExecuted();
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
        update pat;
        
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        acc.Sales_Territory__c = pateam.Id;
        acc.Patch__c = pat.Id;
        insert acc;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Shift').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        insert pr;
        
        
        Test.startTest();
        
        PageReference ref = new PageReference('/apex/ProvisioningFevaRequest?id=' +pr.Id);
        Test.setCurrentPage(ref);
        ProvisioningSHIFTPOCController con = new ProvisioningSHIFTPOCController();
        con.initProvisionRequest();
        con.createCompany();
        con.createUser();
        con.sendUserEmailNotification();
        con.goback();
        
        ProvisioningSHIFTPOCHelper.createPOCtraffic('234435',System.now(),System.now());
        
        Test.stopTest();
    }

    
    @isTest
    public static void testMethod2(){
        
        //Insert Custom Settings
        ZscalerCustomSetting__c setting = new ZscalerCustomSetting__c();
        setting.Name = 'DefaultPRDecommisionContact';
        setting.Value__c = '0034u00002UusGqAAJ';
        insert setting;
        
        ZscalerShiftLogin__c zsl = new ZscalerShiftLogin__c();
        zsl.Name = 'Sandbox';
        zsl.Password__c = '345345';
        zsl.Endpoint__c = 'https://test.com';
        zsl.Username__c = 'testUser';
        insert zsl;
        
        ZscalerShiftLogin__c zslProd = new ZscalerShiftLogin__c();
        zslProd.Name = 'Production';
        zslProd.Password__c = '345345';
        zslProd.Endpoint__c = 'https://test.com';
        zslProd.Username__c = 'testUser';
        insert zslProd;
        
        TriggerUtility.SkipAccTriggerExecuted();
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
        update pat;
        
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        acc.Sales_Territory__c = pateam.Id;
        acc.Patch__c = pat.Id;
        insert acc;
        
        
        Opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Shift').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        pr.Organization_Domain__c = 'test';
        insert pr;
        
        
        Provisioning_Request__c pr1 = new Provisioning_Request__c();
        pr1.RecordTypeId = prRecordTypeId;
        pr1.Account__c = acc.Id;
        pr1.Send_Initial_l__c = 'SE';
        pr1.SE__c = userinfo.getuserId();
        pr1.Provisioning_Status__c = 'In Progress';
        pr1.Organization_Domain__c = 'test';
        pr1.Org_ID_with_cloud__c = '234';
        insert pr1;
        
        Test.startTest();
        
        PageReference ref = new PageReference('/apex/ProvisioningFevaRequest?id=' +pr.Id);
        Test.setCurrentPage(ref);
        ProvisioningSHIFTPOCController con = new ProvisioningSHIFTPOCController();
        con.initProvisionRequest();
        con.createCompany();
        con.createUser();
        con.sendUserEmailNotification();
        con.goback();
        
        Test.stopTest();
    }
    
    
     @isTest
    public static void testMethod3(){
        
        //Insert Custom Settings
        ZscalerCustomSetting__c setting = new ZscalerCustomSetting__c();
        setting.Name = 'DefaultPRDecommisionContact';
        setting.Value__c = '0034u00002UusGqAAJ';
        insert setting;
        
        ZscalerShiftLogin__c zsl = new ZscalerShiftLogin__c();
        zsl.Name = 'Sandbox';
        zsl.Password__c = '345345';
        zsl.Endpoint__c = 'https://test.com';
        zsl.Username__c = 'testUser';
        insert zsl;
        
        ZscalerShiftLogin__c zslProd = new ZscalerShiftLogin__c();
        zslProd.Name = 'Production';
        zslProd.Password__c = '345345';
        zslProd.Endpoint__c = 'https://test.com';
        zslProd.Username__c = 'testUser';
        insert zslProd;
        
        TriggerUtility.SkipAccTriggerExecuted();
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
        update pat;
        
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        acc.Sales_Territory__c = pateam.Id;
        acc.Patch__c = pat.Id;
        insert acc;
        
        
        Opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, CloseDate = system.Today()+30);
        insert opp;
        
        Id prRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
        Provisioning_Request__c pr = new Provisioning_Request__c();
        pr.RecordTypeId = prRecordTypeId;
        pr.Account__c = acc.Id;
        pr.Send_Initial_l__c = 'SE';
        pr.SE__c = userinfo.getuserId();
        pr.Provisioning_Status__c = 'In Progress';
        insert pr;
       
        Test.startTest();
        
        PageReference ref = new PageReference('/apex/ProvisioningFevaRequest?id=' +pr.Id);
        Test.setCurrentPage(ref);
        ProvisioningSHIFTPOCController con = new ProvisioningSHIFTPOCController();
        con.initProvisionRequest();
        
        
        Test.stopTest();
    }
    
}