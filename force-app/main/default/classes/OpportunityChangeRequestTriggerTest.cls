@isTest
public class OpportunityChangeRequestTriggerTest {
    @isTest
    public static void setup() {
        Test.startTest();
        
        
        list<Opportunity> opplist = new list<Opportunity>();
        Map<id,Opportunity> oppmap = new Map<id,Opportunity>();
       
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@zscaler.com',Type='Partner');
        insert acc;
        
        Account acc1 = new Account(Name = 'Test Account1', TAM_Email__c = 'abc@zscaler.in',Type='Prospect');
        insert acc1;
        
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
        deal.Partner_Account__c = acc.Id;
        deal.Source__c = 'Deal Reg';
        deal.Status__c = 'Submitted';
        deal.AW_Partner_Intent__c = 'Interested';
        deal.POV_Partner_Intent__c = 'Interested';
        deal.Deal_Reg_Type__c = System.Label.Deal_Reg_Type_Teaming;
        insert deal;
        
        
        
        
        opportunity opp = new opportunity(Name = 'Test opportunity',Amount = 100, Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = '1 - Discovery & Qualification', CloseDate = system.Today()+30);
        
        opp.Deal_Reg_Partner_Teaming_Reseller__c = acc.Id;
        opp.Deal_Reg_Margin__c = acc.Id;
        opp.LDR_Name__c = System.UserInfo.getUserId();
        opp.Primary_Reseller_Partner__c = acc.Id;
        opp.Secondary_Partner__c = acc.Id;
        opp.Secondary_Partner_Role__c = 'Influencer';
        opp.Partner_Margin_Adjustment__c = FALSE;
        opp.Channel_Sentiment__c = 'Red';
        opp.Primary_Partner_Program__c = 'Test';
        opp.Deal_Reg__c = deal.Id;
        opp.Deal_Reg_Teaming_Reseller__c = deal.Id;
        opp.Opportunity_Channel_Manager__c = System.UserInfo.getUserId();
        opp.Applied_Price_List_Name__c = 'FY 21 Single Tier Pricelist';
        opp.Channel_Notes__c = 'Test';
        
        insert opp;
        
        
        
        //oppmap.put(opp.id,opp);
        Opportunity opp1 = [select id,Name,Deal_Reg_Type__c,
                            Opp_Price_List__c,Applied_Price_List_Name__c,Has_New_Price_List_on_Primary_Quote__c, 
                            Amount,StageName,CloseDate,Primary_Quote_Exception__c,DAS_Start_Date__c,LDR_Name__c,
                            Qualified_Date__c,Service_Start_Date__c,Deal_Reg_Partner_Teaming_Reseller__c,Deal_Reg_Margin__c,
                            Primary_Reseller_Partner__c,Secondary_Partner__c,
                            Secondary_Partner_Role__c,Partner_Margin_Adjustment__c,Channel_Sentiment__c,Primary_Partner_Program__c,
                            Deal_Reg__c,Deal_Reg_Teaming_Reseller__c,Opportunity_Channel_Manager__c,
                            Channel_Notes__c,CampaignId,TriggerPatchAssignment__c from Opportunity where id=:opp.id limit 1];
        opp1.Amount = 200;
        opp1.Deal_Reg_Partner_Teaming_Reseller__c = acc.Id;
        opp1.Deal_Reg_Margin__c = acc.Id;
        opp1.LDR_Name__c = System.UserInfo.getUserId();
        opp1.Qualified_Date__c=System.today();
        opp1.Primary_Reseller_Partner__c = acc.Id;
        opp1.Secondary_Partner__c = acc.Id;
        opp1.Secondary_Partner_Role__c = 'Influencer';
        opp1.Partner_Margin_Adjustment__c = FALSE;
        opp1.Channel_Sentiment__c = 'Red';
        opp1.Primary_Partner_Program__c = 'Test';
        opp1.Deal_Reg__c = deal.Id;
        opp1.Deal_Reg_Teaming_Reseller__c = deal.Id;
        opp1.opportunity_Channel_Manager__c = System.UserInfo.getUserId();
        opp1.Channel_Notes__c = 'Test';
        opp1.DAS_Start_Date__c = System.today();
        Update opp1;
        
        opplist.add(opp1);
        
        
        //OpportunityChangeRequestCtrl.setAuditRecord(opplist,NULL);
        
        oppmap.put(opp1.id,opp1);
        
        
        //OpportunityChangeRequestCtrl.setAuditRecord(opplist,oppmap);
        
        
        Test.stopTest();
    }
    
}