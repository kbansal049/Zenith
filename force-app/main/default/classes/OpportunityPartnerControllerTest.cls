/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 03-25-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class OpportunityPartnerControllerTest {
    
    @testSetup static void setup() {
        TriggerHandler.bypass('OpportunityTriggerHandler');
        TriggerHandler.bypass('AccountTriggerHandler');
        
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.SkipContactTriggerExecuted(); 
        TriggerUtility.SkipOppTriggerExecuted();
        leadTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();
        Show_Actions_on_Manage_Partner__c proftoskip = Show_Actions_on_Manage_Partner__c.getInstance(Userinfo.getProfileId());
        insert proftoskip;
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        
        Account acc1 = new Account(Name = 'Test Account1', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc1;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30);
        insert opp;
        
        List<Opportunity_Partner__c> oppPartnerList = new List<Opportunity_Partner__c>();
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = opp.Id,Partner_Type__c = 'Reseller',Account__c = acc.Id);
        oppPartnerList.add(OppPartner);
        Opportunity_Partner__c OppPartner1 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'POV',Account__c = acc.Id);
        oppPartnerList.add(OppPartner1);
        Opportunity_Partner__c OppPartner2 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Architecture Workshop',Account__c = acc.Id);
        oppPartnerList.add(OppPartner2);
        Opportunity_Partner__c OppPartner3 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'System Integrator',Account__c = acc.Id);
        oppPartnerList.add(OppPartner3);
        Opportunity_Partner__c OppPartner4 = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = opp.Id,Partner_Type__c = 'Distributor',Account__c = acc.Id);
        oppPartnerList.add(OppPartner4);
        Opportunity_Partner__c OppPartner5 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Deal Reg',Account__c = acc.Id);
        oppPartnerList.add(OppPartner5);
        Opportunity_Partner__c OppPartner7 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Tech Partner',Account__c = acc.Id);
        oppPartnerList.add(OppPartner7);
        Opportunity_Partner__c OppPartner8 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'AW/POV',Account__c = acc.Id);
        oppPartnerList.add(OppPartner8);
        Opportunity_Partner__c OppPartner9 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Professional Services',Account__c = acc.Id);
        oppPartnerList.add(OppPartner9);
        Opportunity_Partner__c OppPartner10 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Impact Partner',Account__c = acc.Id,Approval_Status__c='New');
        oppPartnerList.add(OppPartner10);
        Opportunity_Partner__c OppPartner11 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Federal System Integrator',Account__c = acc.Id);
        oppPartnerList.add(OppPartner11);
        Opportunity_Partner__c OppPartner12 = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = opp.Id,Partner_Type__c = 'Distributor',Account__c = acc1.Id);
        oppPartnerList.add(OppPartner12);
        insert oppPartnerList;
        
        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = system.today() + 30;
        camp.IsActive = true;
        insert camp;
        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
        
        List<Deal_Reg__c> deallist = new List<Deal_Reg__c>();
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
        deal.Expected_Close_Date__c = system.today() + 30;
        deal.Market_Segment__c = 'SMB';
        deal.Number_of_Users__c = 1234567;
        deal.Partner_Company_Name__c = 'Test partner';
        deal.Partner_Contact_Email__c = 'Test@partner.com';
        deal.Partner_Contact_Name__c = 'Test';
        deal.Partner_Contact_Last_Name__c  = 'Partner';
        deal.Partner_Country__c  = 'US';
        deal.Partner_Domain__c  = 'partner.com';
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Approved';
        deallist.add(deal);
        
        
        
        Deal_Reg__c deal1 = new Deal_Reg__c();
        deal1.End_Customer_Contact_Name__c = 'Test1';
        deal1.End_Customer_Contact_Last_Name__c= 'Test';
        deal1.End_Customer_Country__c = 'US';
        deal1.End_Customer_Domain__c = 'abc.com';
        deal1.End_Customer_Email__c  = 'Test@abc.com';
        deal1.End_Customer_Name__c = 'ABC Inc';
        deal1.End_Customer_Phone__c = '123456789';
        deal1.End_Customer_State__c = 'US';
        deal1.DS_Review_Status__c = 'Pending Review';
        deal1.Estimated_Amount__c = 1234567;
        deal1.Expected_Close_Date__c = system.today() + 30;
        deal1.Market_Segment__c = 'SMB';
        deal1.Number_of_Users__c = 1234567;
        deal1.Partner_Company_Name__c = 'Test partner';
        deal1.Partner_Contact_Email__c = 'Test@partner.com';
        deal1.Partner_Contact_Name__c = 'Test';
        deal1.Partner_Contact_Last_Name__c  = 'Partner';
        deal1.Partner_Country__c  = 'US';
        deal1.Partner_Domain__c  = 'partner.com';
        deal1.Source__c = 'deal Reg';
        deal1.Status__c = 'Approved';
        deallist.add(deal1);
        insert deallist;
        
        OppPartner1.Deal_Registration__c = deallist[0].Id;
        update OppPartner1;
    }
    
    @isTest static void testOpportunityPartner(){
        
        Deal_Reg__c dlReg = [Select Id, Status__c from Deal_Reg__c where End_Customer_Contact_Name__c = 'Test' LIMIT 1];
        Deal_Reg__c dlReg1 = [Select Id, Status__c from Deal_Reg__c where End_Customer_Contact_Name__c = 'Test1' LIMIT 1];
        Opportunity Opp = [select Id,Name,AccountId from Opportunity limit 1];
        Account Acc = [select Id,Name from Account where Name = 'Test Account' limit 1];
        Account Acc1 = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Reseller' limit 1];
        Opportunity_Partner__c OppPartner101 = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Account__c =: Acc.Id limit 1];
        Show_Actions_on_Manage_Partner__c proftoskip = [Select Id from Show_Actions_on_Manage_Partner__c LIMIT 1];
        
        
        OpportunityPartnerController.WrapperClass Wrp = new OpportunityPartnerController.WrapperClass();
        Wrp.SelectedRecord = Acc;
        Wrp.IsRadioChecked = true;
        Wrp.PartnerRole = 'testRole';
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        system.debug('---string---'+JsonString);
        
        Test.startTest();
        
        OpportunityPartnerController.checkAddDealPermission();
        OpportunityPartnerController.GetOppPartnersDetais(Opp.Id);
        OpportunityPartnerController.GetOpportunity(Opp.Id);  
        
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Tech Partner');
        OpportunityPartnerController.SavePartnerRec(OppPartner101.Opportunity__c,JsonString,'FederalReseller');        
        OpportunityPartnerController.UpdatePrimaryPartner(OppPartner.Id,'Reseller',Opp.Id);
        
        OpportunityPartnerController.UuncheckPrimaryPartner(OppPartner.Id, 'Reseller',Opp.Id );
        OpportunityPartnerController.SaveDealRec(Opp.Id, dlReg.Id);
        OpportunityPartnerController.SaveDealRec(Opp.Id, dlReg1.Id);
        Test.stopTest();
        
    }
    
    
    @isTest static void testOpportunityPartnerDeletePartner(){
        
        Deal_Reg__c dlReg = [Select Id, Status__c from Deal_Reg__c where End_Customer_Contact_Name__c = 'Test' LIMIT 1];
        Deal_Reg__c dlReg1 = [Select Id, Status__c from Deal_Reg__c where End_Customer_Contact_Name__c = 'Test1' LIMIT 1];
        Opportunity Opp = [select Id,Name,AccountId from Opportunity limit 1];
        Account Acc = [select Id,Name from Account where Name = 'Test Account' limit 1];
        Account Acc1 = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Reseller' limit 1];
        Opportunity_Partner__c OppPartner101 = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Account__c =: Acc.Id limit 1];
        Show_Actions_on_Manage_Partner__c proftoskip = [Select Id from Show_Actions_on_Manage_Partner__c LIMIT 1];
        
        
        OpportunityPartnerController.WrapperClass Wrp = new OpportunityPartnerController.WrapperClass();
        Wrp.SelectedRecord = Acc;
        Wrp.IsRadioChecked = true;
        Wrp.PartnerRole = 'testRole';
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        system.debug('---string---'+JsonString);
        OpportunityPartnerController.checkAddDealPermission();
        OpportunityPartnerController.GetOppPartnersDetais(Opp.Id);
        OpportunityPartnerController.GetOpportunity(Opp.Id);  
        
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Tech Partner');
        OpportunityPartnerController.SavePartnerRec(OppPartner101.Opportunity__c,JsonString,'FederalReseller');        
        
        
        Test.startTest();
        
        OpportunityPartnerController.DeletePartnerRec(OppPartner.Id);
        TriggerHandler.bypass('OpportunityPartnerTriggerHandler');
        Opportunity_Partner__c OppPartner1 = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Architecture Workshop' limit 1];
        OpportunityPartnerController.DeletePartnerRec(OppPartner1.Id);
        Opportunity_Partner__c OppPartner2 = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'POV' limit 1];
        
        OpportunityPartnerController.DeletePartnerRec(OppPartner2.Id);
        Test.stopTest();
        
        
    }
    
    
    
    @isTest static void testOpportunityPartner1(){
        Opportunity Opp = [select Id,Name,AccountId from Opportunity limit 1];
        Account Acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c != 'Reseller' limit 1];
        
        Test.startTest();
        
        OpportunityPartnerController.WrapperClass Wrp = new OpportunityPartnerController.WrapperClass();
        Wrp.SelectedRecord = Acc;
        Wrp.IsRadioChecked = true;
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        system.debug('---string---'+JsonString);
        
        OpportunityPartnerController.GetOppPartnersDetais(Opp.Id);
        OpportunityPartnerController.GetOpportunity(Opp.Id);
        
        /*
String Id1=OppPartner.Id;
String Id2=Opp.Id; 
String Program=Label.Partner_Program_Partner_Summit;
OpportunityPartnerController.updatePartnerProgram(OppPartner.Id, Label.Partner_Program_Partner_Summit,Opp.Id );

*/
        String Id1=OppPartner.Id;
        String Id2=Opp.Id; 
        String Program=Label.Partner_Program_Partner_Summit;
        //    OpportunityPartnerController.updatePartnerProgram(Id1,Program,Id2);
        
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'POV');
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Architecture Workshop');
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Deal Reg');
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'AW/POV');
        OpportunityPartnerController.UpdatePrimaryPartner(OppPartner.Id,'POV',Opp.Id);
        
        OpportunityPartnerController.UuncheckPrimaryPartner(OppPartner.Id, 'POV',Opp.Id );
        
        OpportunityPartnerController.DeletePartnerRec(OppPartner.Id);
        Test.stopTest();
    }
    
    @isTest static void testOpportunityPartner2(){
        Opportunity opp = [select Id,Name,AccountId from Opportunity limit 1];
        Account acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Reseller' limit 1];
        
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,acc.Id,true,system.today()+60,system.today()-30,'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,acc.Id,true,system.today()+120,system.today()-30,'Summit - Discount','MSP'))[1]);
        insert piList;
        
        Test.startTest();
        
        OpportunityPartnerController.loadPartnerIncentiveData(acc.Id,opp.Id,true);
        OpportunityPartnerController.WrapperClass Wrp = new OpportunityPartnerController.WrapperClass();
        Wrp.SelectedRecord = acc;
        Wrp.IsRadioChecked = true;
        Wrp.PartnerIncentiveId = piList[0].Id;
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
        
        OpportunityPartnerController.updatePartnerProgram(OppPartner.Id,'Summit - Discount',opp.Id,piList[1].Id);
        Test.stopTest();
    }
    
    @isTest static void testOpportunityPartner3(){
        
        TriggerUtility.isskipentireproposaltriggerExecuted();
        
        Opportunity opp = [select Id,Name,AccountId from Opportunity limit 1];
        Account acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Reseller' limit 1];
        OppPartner.Is_Primary__c = true;
        update OppPartner;
        
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,acc.Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,acc.Id,true,system.today(),system.today(),'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        insert piList;
        
      /*  String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        SBQQ__Quote__c quoteRec = (SB_TestCPQDataUtility.createQuote(1, opp.Id, acc.Id, acc.id, acc.id,quoteNewBusiness))[0];
        quoteRec.SBQQ__Status__c='Approved';
        insert quoteRec; */      
        
        
        OpportunityPartnerController.loadPartnerIncentiveData(acc.Id,opp.Id,true);
        OpportunityPartnerController.updatePartnerProgram(OppPartner.Id,'Summit - Discount',opp.Id,piList[1].Id);
        OpportunityPartnerController.WrapperClass Wrp = new OpportunityPartnerController.WrapperClass();
        Wrp.SelectedRecord = acc;
        Wrp.IsRadioChecked = true;
        Wrp.PartnerIncentiveId = piList[0].Id;
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        
        
        Test.startTest();
        
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
        //delete quoteRec;
        //OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
        
        Test.stopTest();
    }
    
    
    
    @isTest static void testOpportunityPartner3Sub(){
        
        TriggerUtility.isskipentireproposaltriggerExecuted();
        
        Opportunity opp = [select Id,Name,AccountId from Opportunity limit 1];
        Account acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Reseller' limit 1];
        OppPartner.Is_Primary__c = true;
        update OppPartner;
        
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,acc.Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,acc.Id,true,system.today(),system.today(),'Summit - Discount','MSP'))[1]);
        piList[1].Default__c=true;
        insert piList;
        
      /*  String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        SBQQ__Quote__c quoteRec = (SB_TestCPQDataUtility.createQuote(1, opp.Id, acc.Id, acc.id, acc.id,quoteNewBusiness))[0];
        quoteRec.SBQQ__Status__c='Approved';
        insert quoteRec;       
        */
        
        OpportunityPartnerController.loadPartnerIncentiveData(acc.Id,opp.Id,true);
        OpportunityPartnerController.updatePartnerProgram(OppPartner.Id,'Summit - Discount',opp.Id,piList[1].Id);
        OpportunityPartnerController.WrapperClass Wrp = new OpportunityPartnerController.WrapperClass();
        Wrp.SelectedRecord = acc;
        Wrp.IsRadioChecked = true;
        Wrp.PartnerIncentiveId = piList[0].Id;
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        
        
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
      //  delete quoteRec;
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
        
        
        OpportunityPartnerController.WrapperClass Wrp1 = new OpportunityPartnerController.WrapperClass();
        Wrp1.SelectedRecord = acc;
        Wrp1.IsRadioChecked = true;
        Wrp1.PartnerIncentiveId = piList[0].Id;
        String JsonString1  = '['+JSON.serialize(Wrp1)+']';
        Test.startTest();
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString1,'Reseller');
        
        Test.stopTest();
    }
    
    @isTest static void testSummitDistribution(){
        
        Opportunity opp = [select Id,Name,AccountId from Opportunity limit 1];
        Account acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        acc.SummitDistribution__c = true;
        acc.Model_Type_Partner__c ='Traditional';
        Update acc;
        RecordType rt = [SELECT Id FROM RecordType where Name='Partner' and SobjectType='Account'];
        
        Account distributor = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Partner');
        distributor.Program_Type__c ='Distribution';
        distributor.RecordTypeId =rt.Id;
        distributor.Partner_Type__c = 'Partner-Distributor';
        insert distributor;
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Reseller' limit 1];
        
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,acc.Id,true,system.today()+60,system.today()-30,'Traditional','MSP'))[0]);
        piList[0].Transacting_Entity__c = distributor.Id;
        insert piList;
        
        Test.startTest();
        
        OpportunityPartnerController.loadPartnerIncentiveData(acc.Id,opp.Id,true);
        OpportunityPartnerController.WrapperClass Wrp = new OpportunityPartnerController.WrapperClass();
        Wrp.SelectedRecord = acc;
        Wrp.IsRadioChecked = true;
        Wrp.PartnerIncentiveId = piList[0].Id;
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
        
        Test.stopTest();
    }
    @isTest static void testSummitDistributionNOPI(){
        
        Opportunity opp = [select Id,Name,AccountId,CloseDate from Opportunity limit 1];
        Account acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        acc.SummitDistribution__c = true;
        Update acc;
        RecordType rt = [SELECT Id FROM RecordType where Name='Partner' and SobjectType='Account'];
        Account distributor = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Partner');
        distributor.Program_Type__c ='Distribution';
        distributor.RecordTypeId =rt.Id;
        insert distributor;
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Partner_Program__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Reseller' limit 1];
        
        Test.startTest();
        
        try{ 
            OpportunityPartnerController.loadPartnerIncentiveData(acc.Id,opp.Id,true);
        }catch(exception ex){
            system.assertNotEquals(ex,null);
        }
        QuotePartnerIncentiveController.flowInput flowInput = new QuotePartnerIncentiveController.flowInput();
        flowInput.partnerId =acc.Id;
        flowInput.isSummitDistribution =true;
        flowInput.billingCountry= 'null';
        flowInput.partnerProgram= OppPartner.Partner_Program__c;
        flowInput.oppCloseDate= System.today();
        flowInput.oppAccountName= 'TestAccount';
        flowInput.regionAccount= 'SLED';
        try{ 
            QuotePartnerIncentiveController.getPartnerIncentive(new List<QuotePartnerIncentiveController.flowInput>{flowInput} );
        }catch(exception ex){
            system.assertNotEquals(ex,null);
        }
        Test.stopTest();
    }  
    
    @isTest static void testSummitDistributionExistingDistributor(){
        
        Opportunity opp = [select Id,Name,AccountId,Account.BillingCountry from Opportunity limit 1];
        Account acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        acc.SummitDistribution__c = true;
        Update acc;
        RecordType rt = [SELECT Id FROM RecordType where Name='Partner' and SobjectType='Account'];
        Account distributor = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Partner');
        distributor.Program_Type__c ='Distribution';
        distributor.Partner_Type__c = 'Partner-Distributor';
        distributor.RecordTypeId =rt.Id;
        insert distributor;
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Reseller' limit 1];
        Opportunity_Partner__c OppPartnerDist = new Opportunity_Partner__c();
        OppPartnerDist.Account__c = distributor.Id;
        OppPartnerDist.Partner_Type__c = 'Distributor';
        OppPartnerDist.Opportunity__c = opp.Id;
        Insert OppPartnerDist;
        
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,acc.Id,true,system.today(),system.today(),'Traditional','MSP'))[0]);
        piList[0].Transacting_Entity__c=distributor.Id;
        piList[0].Transacting_Location__c = opp.Account.BillingCountry;
        insert piList;
        
        Test.startTest();
        
        OpportunityPartnerController.WrapperClass Wrp = new OpportunityPartnerController.WrapperClass();
        Wrp.SelectedRecord = acc;
        Wrp.IsRadioChecked = true;
        Wrp.PartnerIncentiveId = piList[0].Id;
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        
        OpportunityPartnerController.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
        
        Test.stopTest();
    }
    @isTest static void testInvocableMethod(){
        
        Opportunity opp = [select Id,Name,AccountId,Account.BillingCountry from Opportunity limit 1];
        Account acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        acc.SummitDistribution__c = false;
        acc.BillingCountry='United States';
        acc.Model_Type_Partner__c = 'Traditional';
        Update acc;
        RecordType rt = [SELECT Id FROM RecordType where Name='Partner' and SobjectType='Account'];
        Account distributor = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Partner');
        distributor.Program_Type__c ='Distribution';
        distributor.RecordTypeId =rt.Id;
        distributor.Partner_Type__c = 'Partner-Distributor';
        insert distributor;
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Reseller' limit 1];
        Opportunity_Partner__c OppPartnerDist = new Opportunity_Partner__c();
        OppPartnerDist.Account__c = distributor.Id;
        OppPartnerDist.Partner_Type__c = 'Distributor';
        OppPartnerDist.Opportunity__c = opp.Id;
        Insert OppPartnerDist;
        
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,acc.Id,true,system.today(),system.today(),'Traditional','Reseller'))[0]);
        piList[0].Transacting_Entity__c=distributor.Id;
        piList[0].Transacting_Location__c = 'United States';
        insert piList;
        
        Test.startTest();
        
        QuotePartnerIncentiveController.flowInput flowInput = new QuotePartnerIncentiveController.flowInput();
        flowInput.partnerId =acc.Id;
        flowInput.isSummitDistribution =false;
        flowInput.billingCountry= 'United States';
        flowInput.partnerProgram= 'Traditional';
        flowInput.oppCloseDate= System.today();
        flowInput.oppAccountName= 'TestAccount';
        flowInput.regionAccount= 'SLED'; 
        flowInput.programType= 'Reseller';
        
        QuotePartnerIncentiveController.getPartnerIncentive(new List<QuotePartnerIncentiveController.flowInput>{flowInput} );
        
        
        Test.stopTest();
    }
    
    
    
}