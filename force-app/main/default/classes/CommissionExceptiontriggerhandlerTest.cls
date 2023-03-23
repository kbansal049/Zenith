@isTest
private class CommissionExceptiontriggerhandlerTest {
    @testSetup
    static void testDatasetup(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        insert TestDatafactory_Zscaler.getstageforecastcategorymap();
        //GetCommssionExceptionDetails.booster();
        Account acc = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com',Type='Prospect');
        insert acc;
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, 
                                          StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, 
                                          CloseDate = system.Today()+30);
        TriggerUtility.realignPatchReset();
        insert opp;

        Commission_Exception__c CE= new Commission_Exception__c(Opportunity__c=opp.id,Commission_Amount__c=10000, Exception_Categories__c='Re-classification Non Reg to Reg',Geo__c='Americas');        
        insert CE;
    }
    
    @isTest
    static void testbeforeUpdate(){
        List<Commission_Exception__c>  CommissionException = [SELECT Commission_Amount__c, Exception_Categories__c, Geo__c FROM Commission_Exception__c];
        
        Test.startTest();        
        	//Submit for Approval
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(CommissionException[0].id);
            Approval.ProcessResult result = Approval.process(req1);
            
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request with reservation.');
            req2.setAction('Approve');
            
            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(newWorkItemIds.get(0));
            
            // Approval for 1st step
            Approval.ProcessResult result2 =  Approval.process(req2);
        	
        	/*
        	newWorkItemIds = result2.getNewWorkitemIds();
            
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest req3 = new Approval.ProcessWorkitemRequest();
            req3.setComments('Approving request');
            req3.setAction('Approve');
            
            // Use the ID from the newly created item to specify the item to be worked
            req3.setWorkitemId(newWorkItemIds.get(0));
        	
        	// Approval for 2nd step
            Approval.ProcessResult result3 =  Approval.process(req3);
        	
        	CommissionExceptionApprovedCmpCtrl gce = new CommissionExceptionApprovedCmpCtrl();
            gce.ebId = CommissionException[0].Id;
            gce.typeofTemplate = 'ApprovalRequired';
            gce.approverName = 'Approver Name';
            String year = gce.yearVal;
            String url = gce.url;
            
            Commission_Exception__c cec = gce.GetcommissionException();
			*/
        Test.stopTest();
    }
    
    @isTest
    static void testCommExceptionApprovalPreviewCtrlr(){
        List<Commission_Exception__c>  CommissionException = [SELECT Commission_Amount__c, Exception_Categories__c, Geo__c FROM Commission_Exception__c];
        
        CommissionException[0].Exception_Categories__c='Compensation Exception';
        CommissionException[0].Geo__c='Americas';
        update CommissionException;
        
        Test.startTest(); 
        	PageReference testPage = Page.CommissionExceptionApprovalPreview;
        	Test.setCurrentPage(testPage);
       		TestPage.getParameters().put('Id', String.valueOf(CommissionException[0].Id));
        	ApexPages.StandardController sc = new  ApexPages.StandardController(CommissionException[0]);
        	CommExceptionApprovalPreviewCtrlr ctrl = new CommExceptionApprovalPreviewCtrlr(sc);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCommssionExceptionDetails(){
        List<Commission_Exception__c>  CommissionException = [SELECT Commission_Amount__c, Exception_Categories__c, Geo__c FROM Commission_Exception__c];
        
		GetCommssionExceptionDetails gce = new GetCommssionExceptionDetails();
        gce.ebId = CommissionException[0].Id;
        gce.typeofTemplate = 'ApprovalRequired';
        gce.approverName = 'Approver Name';
        String year = gce.yearVal;
        String url = gce.url;
        
        Commission_Exception__c cec = gce.getCommissionException();
        
    }

}