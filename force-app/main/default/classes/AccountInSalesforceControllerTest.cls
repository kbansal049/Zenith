@isTest
private class AccountInSalesforceControllerTest {
    
    
    @testSetup
    static void setup() {
        Id RecordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
        Account acc = new Account();
        acc.Name='testacc';
        acc.recordtypeid = RecordTypeIdAcc;  
        acc.Type ='Prospect';
        acc.Subsidiary_HQ_Flag__c  = false;
        acc.Prospect_Type__c ='Pipeline';
        acc.BillingCountry = 'US';
        acc.Industry = 'Insurance';
        acc.ZPA_Use_Cases__c = 'Accelerated Merger and Acquisition';
        acc.ZIA_Use_Cases__c = 'Proxy replacement;Data Protection';
        acc.Namedrop__c = 'Yes';
        insert acc; 
        
        Event e = new Event();
        e.Subject = 'Meeting';
        e.WhatId = acc.Id;
        e.ActivityDate = System.Date.today() - 10;
        e.StartDateTime= System.Date.today() - 10;
        e.EndDateTime=System.Date.today() - 10;
        e.Type = 'Other - Internal Meeting';
		
        INSERT e;
        
        // Id accountid = acc.id;
        
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
        
        Case cs = new case();
        cs.AccountId =acc.id;
        insert cs;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.id;
        opp.Name = 'TestOpp';
        opp.CloseDate = system.today();
        opp.StageName ='13 - Closed & Approved By Finance';
        opp.Proposed_Number_of_Users__c =25;
        opp.Expected_Term_Months__c =3.0;
        opp.Type ='New Business';
        opp.Product_Type__c ='Web';
        opp.LeadSource ='Events';
        insert opp;
        
        
        
        Access_Request__c accessReq = new Access_Request__c();
        accessReq.Account__c = acc.Id;
        accessReq.Object_Type__c = 'Test';
        accessReq.Approver__c = System.UserInfo.getUserId();
        accessReq.Request_Type__c  = 'Account Access';
        accessReq.Request_Status__c = 'Requested';
        accessReq.Requested_From__c = System.UserInfo.getUserId();
        //INSERT accessReq;
        

        
        
        
    }

    
    static testMethod void testmethod1(){
        try{
            
            List<Account> acclist = [Select Id,name,Prospect_Type__c from Account  limit 1];
            string accrecid = acclist[0].id;
            system.debug('Prospect_Type__c--'+acclist[0].Prospect_Type__c);
            List<Opportunity> opplist = [select id,Accountid,name,Type from Opportunity where Accountid =:accrecid AND Type ='New Business'];
            // if(!acclist.isEmpty()){
            Test.startTest();
            AccountInSalesforceController obj = new AccountInSalesforceController();
            AccountInSalesforceController.getPickListData();
            AccountInSalesforceController.fetchAccount('testacc','','', 'Insurance','Proxy replacement','Accelerated Merger and Acquisition','Yes');
            AccountInSalesforceController.fetchAccount('testacc','Americas','', 'Insurance','Proxy replacement','Accelerated Merger and Acquisition','Yes');
            AccountInSalesforceController.fetchAccount('testacc','','AMERICAS', 'Insurance','Proxy replacement','Accelerated Merger and Acquisition','Yes');
            AccountInSalesforceController.fetchAccount('','','', 'Insurance','Proxy replacement','Accelerated Merger and Acquisition','Yes');
            AccountInSalesforceController.moreInfoData(accrecid);
            AccountInSalesforceController.redirectSCI(accrecid);
            sObject saccount = new Account();
            List<String> indOpt = AccountInSalesforceController.getAccountIndustryoptions(saccount,'Industry');
            AccountInSalesforceController.createAccountAccessRequest(accrecid,'testacc');
            
            
            Account acc = new Account(Id=accrecid);
            
            acc.SBQQ__DefaultOpportunity__c = opplist.get(0).Id;
        
            UPDATE acc;
            AccountInSalesforceController.redirectSCI(accrecid);
            
            
        	Test.stopTest();
            //}
        }
        catch(exception e){
            
        }
    }
    
}