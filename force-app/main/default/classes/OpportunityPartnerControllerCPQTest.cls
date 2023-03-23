@isTest
public class OpportunityPartnerControllerCPQTest {
    
    @testSetup static void setup() {
        
        TriggerUtility.SkipAccTriggerExecuted();
        TriggerUtility.SkipContactTriggerExecuted(); 
        TriggerUtility.SkipOppTriggerExecuted();
        leadTriggerHelper.skipTrigger = true;
        TriggerUtility.realignPatch();

        
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        
        Account acc1 = new Account(Name = 'Test Account1', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc1;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30);
        insert opp;
        
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c(Is_Primary__c = false,Opportunity__c = opp.Id,Partner_Type__c = 'Reseller',Account__c = acc.Id);
        insert OppPartner;
        
        Opportunity_Partner__c OppPartner1 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'POV',Account__c = acc.Id);
        insert OppPartner1;
        
        Opportunity_Partner__c OppPartner2 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Architecture Workshop',Account__c = acc.Id);
        insert OppPartner2;
        
        Opportunity_Partner__c OppPartner3 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'System Integrator',Account__c = acc.Id);
        insert OppPartner3;
        
        Opportunity_Partner__c OppPartner4 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Distributor',Account__c = acc.Id);
        insert OppPartner4;
        
        Opportunity_Partner__c OppPartner5 = new Opportunity_Partner__c(Is_Primary__c = true,Opportunity__c = opp.Id,Partner_Type__c = 'Deal Reg',Account__c = acc.Id);
        insert OppPartner5;
        
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
        insert deal;
        
        OppPartner1.Deal_Registration__c = deal.Id;
        update OppPartner1;
        
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
        insert deal1;
    }
    
    @isTest static void testOpportunityPartner(){
        
        Deal_Reg__c dlReg = [Select Id, Status__c from Deal_Reg__c where End_Customer_Contact_Name__c = 'Test' LIMIT 1];
        Deal_Reg__c dlReg1 = [Select Id, Status__c from Deal_Reg__c where End_Customer_Contact_Name__c = 'Test1' LIMIT 1];
        Opportunity Opp = [select Id,Name,AccountId from Opportunity limit 1];
        Account Acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Reseller' limit 1];
        
        OpportunityPartnerControllerCPQ.WrapperClass Wrp = new OpportunityPartnerControllerCPQ.WrapperClass();
        Wrp.SelectedRecord = Acc;
        Wrp.IsRadioChecked = true;
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        system.debug('---string---'+JsonString);
        
        Test.startTest();
        
        OpportunityPartnerControllerCPQ.checkAddDealPermission();
        OpportunityPartnerControllerCPQ.GetOppPartnersDetais(Opp.Id);
        OpportunityPartnerControllerCPQ.GetOpportunity(Opp.Id);  
        
        OpportunityPartnerControllerCPQ.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
        OpportunityPartnerControllerCPQ.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Tech Partner');
        OpportunityPartnerControllerCPQ.UpdatePrimaryPartner(OppPartner.Id,'Reseller',Opp.Id);
        
        OpportunityPartnerControllerCPQ.UuncheckPrimaryPartner(OppPartner.Id, 'Reseller',Opp.Id );
        OpportunityPartnerControllerCPQ.SaveDealRec(Opp.Id, dlReg.Id);
        OpportunityPartnerControllerCPQ.SaveDealRec(Opp.Id, dlReg1.Id);
        /*OpportunityPartnerControllerCPQ.DeletePartnerRec(OppPartner.Id);
        Opportunity_Partner__c OppPartner1 = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Architecture Workshop' limit 1];
        OpportunityPartnerControllerCPQ.DeletePartnerRec(OppPartner1.Id);
        Opportunity_Partner__c OppPartner2 = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'POV' limit 1];
        OpportunityPartnerControllerCPQ.DeletePartnerRec(OppPartner2.Id);*/
        
        Test.stopTest();
    }
    
    @isTest static void testOpportunityPartner1(){
        Test.startTest();
        Opportunity Opp = [select Id,Name,AccountId from Opportunity limit 1];
        Account Acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c != 'Reseller' limit 1];
        
        
        OpportunityPartnerControllerCPQ.WrapperClass Wrp = new OpportunityPartnerControllerCPQ.WrapperClass();
        Wrp.SelectedRecord = Acc;
        Wrp.IsRadioChecked = true;
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        system.debug('---string---'+JsonString);
        
        OpportunityPartnerControllerCPQ.GetOppPartnersDetais(Opp.Id);
        OpportunityPartnerControllerCPQ.GetOpportunity(Opp.Id);
        
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
        
        OpportunityPartnerControllerCPQ.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'POV');
        OpportunityPartnerControllerCPQ.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Architecture Workshop');
        OpportunityPartnerControllerCPQ.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Deal Reg');
        OpportunityPartnerControllerCPQ.UpdatePrimaryPartner(OppPartner.Id,'POV',Opp.Id);
         
        OpportunityPartnerControllerCPQ.UuncheckPrimaryPartner(OppPartner.Id, 'POV',Opp.Id );
       
        OpportunityPartnerControllerCPQ.DeletePartnerRec(OppPartner.Id);
        Test.stopTest();
    }
        
    @isTest static void testOpportunityPartner2(){
        Test.startTest();
        Opportunity opp = [select Id,Name,AccountId from Opportunity limit 1];
        Account acc = [select Id,Name from Account where Name = 'Test Account1' limit 1];
        Opportunity_Partner__c OppPartner = [select Id,Name,Opportunity__c,Partner_Type__c,Account__c from Opportunity_Partner__c where Partner_Type__c = 'Reseller' limit 1];
        
        List<Partner_Incentive__c> piList = new List<Partner_Incentive__c>();
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,acc.Id,true,system.today()+60,system.today()-30,'Traditional','MSP'))[0]);
        piList.add((SB_TestCPQDataUtility.createPartnerIncentive(1,acc.Id,true,system.today()+120,system.today()-30,'Summit - Discount','MSP'))[1]);
        insert piList;
        
        OpportunityPartnerControllerCPQ.loadPartnerIncentiveData(acc.Id,opp.Id,true);
        OpportunityPartnerControllerCPQ.WrapperClass Wrp = new OpportunityPartnerControllerCPQ.WrapperClass();
        Wrp.SelectedRecord = acc;
        Wrp.IsRadioChecked = true;
        Wrp.PartnerIncentiveId = piList[0].Id;
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        
        OpportunityPartnerControllerCPQ.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');

        OpportunityPartnerControllerCPQ.updatePartnerProgram(OppPartner.Id,'Summit - Discount',opp.Id,piList[1].Id);
        Test.stopTest();
    }
    
    @isTest static void testOpportunityPartner3(){
        Test.startTest();
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
        
        String quoteNewBusiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        SBQQ__Quote__c quoteRec = (SB_TestCPQDataUtility.createQuote(1, opp.Id, acc.Id, acc.id, acc.id,quoteNewBusiness))[0];
        quoteRec.SBQQ__Status__c='Approved';
        insert quoteRec;       
        
        OpportunityPartnerControllerCPQ.loadPartnerIncentiveData(acc.Id,opp.Id,true);
        OpportunityPartnerControllerCPQ.updatePartnerProgram(OppPartner.Id,'Summit - Discount',opp.Id,piList[1].Id);
        OpportunityPartnerControllerCPQ.WrapperClass Wrp = new OpportunityPartnerControllerCPQ.WrapperClass();
        Wrp.SelectedRecord = acc;
        Wrp.IsRadioChecked = true;
        Wrp.PartnerIncentiveId = piList[0].Id;
        String JsonString  = '['+JSON.serialize(Wrp)+']';
        
        OpportunityPartnerControllerCPQ.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
        delete quoteRec;
        OpportunityPartnerControllerCPQ.SavePartnerRec(OppPartner.Opportunity__c,JsonString,'Reseller');
        
        OpportunityPartnerControllerCPQ.WrapperClass Wrp1 = new OpportunityPartnerControllerCPQ.WrapperClass();
        Wrp1.SelectedRecord = acc;
        Wrp1.IsRadioChecked = true;
        Wrp1.PartnerIncentiveId = piList[0].Id;
        String JsonString1  = '['+JSON.serialize(Wrp1)+']';
        
        OpportunityPartnerControllerCPQ.SavePartnerRec(OppPartner.Opportunity__c,JsonString1,'Reseller');

        
        Test.stopTest();
    }
        
}