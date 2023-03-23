@isTest
public class DealRegExpirationHelper_LWCTest {

    @isTest
    static void testdeal()
    {
        list<Account> accInsertList = new list<Account>();
         Account acc = new account();
        Acc.Name = 'Test Data';
        acc.Domain__c = 'abc.com';
        acc.Partner_Type__c = 'Partner-Reseller';
        acc.Sales_Engineer__c = UserInfo.getUserId();
        accInsertList.add(acc);

        Account acc1 = new account();
        Acc1.Name = 'Test partner';
        acc1.Domain__c = 'partner.com';
        acc1.Partner_Type__c = 'Partner-Reseller';
        acc1.Sales_Engineer__c = UserInfo.getUserId();
        accInsertList.add(acc1);

        Account acc2 = new account();
        Acc2.Name = 'Test partner';
        acc2.Domain__c = 'partner.com';
        acc2.Partner_Type__c = 'Partner-Reseller';
        acc2.Sales_Engineer__c = UserInfo.getUserId();
        accInsertList.add(acc2);
        insert accInsertList;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        acc2.Ultimate_Parent_Account__c = acc1.Id;
        update acc2;
        
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
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
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        Contact con = new Contact();
        con.firstName = 'Jhon';
        con.LastName = 'Smith';
        con.email = 'jhon@abcd.com';
        con.AccountId = acc2.Id;
        insert con;
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        test.startTest();
        /*Lead le = new Lead();
        le.Company = 'test Company';
        le.FirstName = 'Test';
        le.LastName = 'Name';
        le.Email = 'test@abc.com';
        insert le;*/
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        
        
         list<Deal_Reg__c> dealRegInsertList = new list<Deal_Reg__c>();

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
        deal.Status__c = 'Submitted';
        dealRegInsertList.add(deal);

        Deal_Reg__c deal1 = new Deal_Reg__c();
        deal1.End_Customer_Contact_Name__c = 'Test';
        deal1.End_Customer_Contact_Last_Name__c= 'Test';
        deal1.End_Customer_Country__c = 'US';
        deal1.End_Customer_Domain__c = 'abcd.com';
        deal1.End_Customer_Email__c  = 'jhon@abcd.com';
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
        deal1.Source__c = 'Deal Reg';
        deal1.Status__c = 'Submitted';
        //deal1.Deal_Reg_Teaming_Tech_Partner__c=deal1.Id;
        //deal1.Lead__c = le.id;
        deal1.Contact__c = con.id;
        dealRegInsertList.add(deal1);

        Deal_Reg__c deal2 = new Deal_Reg__c();
        deal2.End_Customer_Contact_Name__c = 'Test';
        deal2.End_Customer_Contact_Last_Name__c= 'Test';
        deal2.End_Customer_Country__c = 'US';
        deal2.End_Customer_Domain__c = 'abcd.com';
        deal2.End_Customer_Email__c  = 'Test@abcde.com';
        deal2.End_Customer_Name__c = 'ABC Inc';
        deal2.End_Customer_Phone__c = '123456789';
        deal2.End_Customer_State__c = 'US';
        deal2.DS_Review_Status__c = 'Pending Review';
        deal2.Estimated_Amount__c = 1234567;
        deal2.Expected_Close_Date__c = system.today() + 30;
        deal2.Market_Segment__c = 'SMB';
        deal2.Number_of_Users__c = 1234567;
        deal2.Partner_Account__c = acc1.Id;
        deal2.Partner_Company_Name__c = 'Test partner';
        deal2.Partner_Contact_Email__c = 'Test@partner.com';
        deal2.Partner_Contact_Name__c = 'Test';
        deal2.Partner_Contact_Last_Name__c  = 'Partner';
        deal2.Partner_Country__c  = 'US';
        deal2.Partner_Domain__c  = 'partner.com';
        deal2.Source__c = 'Deal Reg';
        deal2.Status__c = 'Submitted';
        dealRegInsertList.add(deal2);

        insert dealRegInsertList;
        test.stopTest();
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());

        Opportunity opp = new Opportunity();
        Opp.Name = 'Test Opp';
        Opp.CloseDate = system.Today() + 30;
        Opp.AccountId = acc.Id;
        Opp.Amount = 123456;
        opp.StageName = Label.Stage_6_Closed_Won /*'1 - Qualified and Budgeted'*/;
        opp.Deal_Reg__c = deal.Id;
        Opp.Associated_Deal_Registrations__c = deal.Name;
        //opp.Deal_Reg_Teaming_Tech_Partner__c=deal1.Id; // Commented as part of IBA-7556
        opp.Deal_Reg_Teaming_Reseller__c=deal1.Id;
        TriggerHandler.bypass('OpportunityTriggerHandler');
        insert Opp;
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
        ZscalerCustomSetting__c zp=new ZscalerCustomSetting__c();
       
        zp.Value__c='00570000002GeGO';
        zp.Name='Test';
        insert zp;
               List<genericApprovalActionController.SubmitRecordWrapper> reqList = new List<genericApprovalActionController.SubmitRecordWrapper>();
        genericApprovalActionController.SubmitRecordWrapper ctrl = new genericApprovalActionController.SubmitRecordWrapper();
        ctrl.comment = 'Submitting for Expiration Approval';
        ctrl.recordId = 'a3j3K000000JI6YQAW';
        ctrl.skipEntryCriteria = false;
        ctrl.submitterId = '00570000002GeGOAA0';
        reqList.add(ctrl);
        
              //genericApprovalActionController.submitRecord(reqList);
      /*   List<Approval.ProcessSubmitRequest> approvalProcessRequestList = new List<Approval.ProcessSubmitRequest>();
   
            Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
           
                newApprovalRequest.setComments( ctrl.comment);
        newApprovalRequest.setSkipEntryCriteria( ctrl.skipEntryCriteria );
           
        
            
                newApprovalRequest.setObjectId(ctrl.recordId);
           
          
                newApprovalRequest.setSubmitterId(ctrl.submitterId);
        newApprovalRequest.setNextApproverIds(ctrl.nextApproverIds);
           
                newApprovalRequest.setSkipEntryCriteria(false);
            
               
           
            approvalProcessRequestList.add(newApprovalRequest);
        
        if(approvalProcessRequestList.size() > 0) {
            for (Approval.ProcessSubmitRequest processRequest : approvalProcessRequestList) {
                
               // Approval.ProcessResult result = Approval.process(processRequest);
                
            }
        }*/
      // genericApprovalActionController.submitRecord sub=new genericApprovalActionController.submitRecord(reqList);
      
        //Approval.ProcessResult result = Approval.process(approvalProcessRequestList);
        
       // CaseCreationForAccountAndOpportunity.dealRegCaseCreation(deal1);
       // DealRegExpirationHelper_LWC dp=new DealRegExpirationHelper_LWC();
        DealRegExpirationHelper_LWC.checkDealRegValidity(deal1.Id);
        DealRegExpirationHelper_LWC.getOppsbeforeExpiration(deal1.Id);
        TriggerHandler.bypass('OpportunityTriggerHandler');
        DealRegExpirationHelper_LWC.saveExpiration(deal1.Id, 'drtoConvert', opp.Id, 'Hii');
        TriggerHandler.clearBypass('OpportunityTriggerHandler');

  

        
        
    }
}