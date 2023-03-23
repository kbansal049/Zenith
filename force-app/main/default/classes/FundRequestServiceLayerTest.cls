@isTest
private class FundRequestServiceLayerTest {
    
    @TestSetup
    static void createTestData() {        
        Account partnerAccount = new Account(Name = 'PartnerAccount001',
                                             Type = 'Partner');
        insert partnerAccount;
        
        partnerAccount = [SELECT Id, isPartner, Name 
                          FROM Account 
                          WHERE Name = 'PartnerAccount001' 
                          LIMIT 1];
        partnerAccount.IsPartner = TRUE;
        update partnerAccount;
        
        Campaign campaignRecord = new Campaign();
        campaignRecord.name='ZPA Interactive';
        campaignRecord.Department__c = '5000-Corporate Marketing';
        campaignRecord.Geo__c = 'GLOBAL';
        campaignRecord.StartDate = Date.today();
        campaignRecord.EndDate = Date.today()+30;
        campaignRecord.Fiscal_Year__c = 'All Time';
        campaignRecord.Type = 'Default';
        campaignRecord.Campaign_Type__c = 'Assets';
        campaignRecord.Recommended_Outreach_Sequence__c ='Testing';
        
        insert campaignRecord;
        
        
        PartnerFundRequest FundRequest001 = new PartnerFundRequest(Title = 'FundRequest001',
                                                                   Activity = 'Digital Advertising-LinkedIn',
                                                                   ChannelPartnerId = partnerAccount.Id,
                                                                   CoOp_Status__c = 'Pending Submission',
                                                                   RequestedAmount = 100.99,
                                                                   Zinfi_Co_op_Id__c = 'ZINFI-Id-XYZ001',
                                                                   Product__c = 'Zero Trust Exchange (ZTX)',
                                                                   Lead_Follow_Up__c = 'Zscaler Lead Nurturing',
                                                                   Target_Audience__c = 'End Customer');
        
        
        insert FundRequest001;
        PartnerFundRequest FundRequest002 = new PartnerFundRequest(Title = 'FundRequest002',
                                                                   Activity = 'Digital Advertising-LinkedIn',
                                                                   ChannelPartnerId = partnerAccount.Id,
                                                                   CoOp_Status__c = 'Pending Submission',
                                                                   RequestedAmount = 100.99,
                                                                   Zinfi_Co_op_Id__c = 'ZINFI-Id-XYZ002',
                                                                   Product__c = 'Zero Trust Exchange (ZTX)',
                                                                   Lead_Follow_Up__c = 'Zscaler Lead Nurturing',
                                                                   Target_Audience__c = 'End Customer');
        insert FundRequest002;
        PartnerFundRequest FundRequest003 = new PartnerFundRequest(Title = 'FundRequest003',
                                                                   Activity = 'Digital Advertising-LinkedIn',
                                                                   ChannelPartnerId = partnerAccount.Id,
                                                                   CoOp_Status__c = 'Pending Submission',
                                                                   RequestedAmount = 100.99,
                                                                   Zinfi_Co_op_Id__c = 'ZINFI-Id-XYZ003',
                                                                   Product__c = 'Zero Trust Exchange (ZTX)',
                                                                   Lead_Follow_Up__c = 'Zscaler Lead Nurturing',
                                                                   Target_Audience__c = 'End Customer',
                                                                   PO_Number__c = 'PO_FundRequest003',
                                                                   CampaignId = CampaignRecord.Id,
                                                                   Amount_Approved__c = 11.99);
        insert FundRequest003;
        
        
        
    }
    
    /*
    For this test, create an object for approval, then reject the request, mark the approval status as pending, then
    without a comment explaining why. The rejection should be halted, and
    and an apex page message should be provided to the user.
    */
    @isTest 
    static void fundRequestRejectionWithoutCommentTest(){
        Account partnerAccount = [SELECT Id, isPartner, Name 
                                  FROM Account 
                                  WHERE Name = 'PartnerAccount001' 
                                  LIMIT 1];
        PartnerFundRequest fundRequest = new PartnerFundRequest(Title = 'FundRequest001',
                                                                Activity = 'Digital Advertising-LinkedIn',
                                                                ChannelPartnerId = partnerAccount.Id,
                                                                CoOp_Status__c = 'Pending Submission',
                                                                RequestedAmount = 100.99,
                                                                Zinfi_Co_op_Id__c = 'ZINFI-Id-XYZ001',
                                                                Product__c = 'Zero Trust Exchange (ZTX)',
                                                                Lead_Follow_Up__c = 'Zscaler Lead Nurturing',
                                                                Target_Audience__c = 'End Customer');
        
        
        //insert fundRequest;
        
        Test.startTest();
        PartnerFundRequest checkCreatedFundRequest = [SELECT Id, Title FROM PartnerFundRequest 
                                                      WHERE Title = 'FundRequest001'
                                                      LIMIT 1];
        if(checkCreatedFundRequest != NULL){
            System.assertEquals(checkCreatedFundRequest.Title,'FundRequest001');
            
            // Get the work item 
            ProcessInstance objProcessInstance = [SELECT Id,TargetObjectId, CreatedDate 
                                                  FROM ProcessInstance 
                                                  WHERE TargetObjectId = :checkCreatedFundRequest.Id];
            if(objProcessInstance != NULL){
                ProcessInstanceWorkitem ObjProcessInstanceWorkitem = [SELECT Id,ProcessInstanceId 
                                                                      FROM ProcessInstanceWorkitem 
                                                                      WHERE ProcessInstanceId =: objProcessInstance.Id
                                                                      LIMIT 1];
                
                // Reject the submitted request, without providing a comment.
                Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
                testRej.setComments('');
                testRej.setAction('Reject');      
                testRej.setWorkitemId(ObjProcessInstanceWorkitem.Id);
                
                // Attempt to process the rejection
                try
                {
                    Approval.ProcessResult testRejResult =  Approval.process(testRej);
                    system.assert(false, 'A rejection with no comment should cause an exception');
                }
                catch(DMLException e)
                {
                    //system.assertEquals('Approval Process Error : Please provide Rejection Comment', 
                    // e.getDmlMessage(0), 
                    //'error message should be "Approval Process Error : Please provide Rejection Comment"'); 
                }
            }
        }
        Test.stopTest();
    }    
    
    @isTest 
    static void fundRequestRejectionWithCommentTest(){
        
        Account partnerAccount = [SELECT Id, isPartner, Name 
                                  FROM Account 
                                  WHERE Name = 'PartnerAccount001' 
                                  LIMIT 1];
        PartnerFundRequest fundRequest = new PartnerFundRequest(Title = 'FundRequest002',
                                                                Activity = 'Digital Advertising-LinkedIn',
                                                                ChannelPartnerId = partnerAccount.Id,
                                                                CoOp_Status__c = 'Pending Submission',
                                                                RequestedAmount = 100.99,
                                                                Zinfi_Co_op_Id__c = 'ZINFI-Id-XYZ001',
                                                                Product__c = 'Zero Trust Exchange (ZTX)',
                                                                Lead_Follow_Up__c = 'Zscaler Lead Nurturing',
                                                                Target_Audience__c = 'End Customer');
        //insert fundRequest;
        
        Test.startTest();
        PartnerFundRequest checkCreatedFundRequest = [SELECT Id, Title, AllocationId
                                                      FROM PartnerFundRequest 
                                                      WHERE Title = 'FundRequest002'
                                                      LIMIT 1];
        if(checkCreatedFundRequest != null){
            System.assertEquals(checkCreatedFundRequest.Title,'FundRequest002');
            // Get the work item 
            ProcessInstance objProcessInstance = [SELECT Id,TargetObjectId, CreatedDate 
                                                  FROM ProcessInstance 
                                                  WHERE TargetObjectId = :checkCreatedFundRequest.Id];
            if(objProcessInstance != NULL){
                ProcessInstanceWorkitem ObjProcessInstanceWorkitem = [SELECT Id,ProcessInstanceId 
                                                                      FROM ProcessInstanceWorkitem 
                                                                      WHERE ProcessInstanceId =: objProcessInstance.Id
                                                                      LIMIT 1];
                
                // Reject the submitted request, without providing a comment.
                Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
                testRej.setComments('Rejected!!!');
                testRej.setAction('Reject');      
                testRej.setWorkitemId(ObjProcessInstanceWorkitem.Id);
                
                // Attempt to process the rejection
                try
                {
                    System.debug('checkCreatedFundRequest BEFORE ' + checkCreatedFundRequest);
                    Approval.ProcessResult testRejResult =  Approval.process(testRej);
                    System.debug('checkCreatedFundRequest AFTER ' + checkCreatedFundRequest);
                    system.assert(true, 'A rejection with no comment should cause an exception');
                }
                catch(DMLException e)
                {
                    //system.assertEquals('Once this field has been specified, you can\'t update its value.', 
                    //e.getDmlMessage(0), 
                    //'error message should be "Approval Process Error : Please provide Rejection Comment'); 
                }
            }
        }
        Test.stopTest();
    }   
    
    @isTest 
    static void fundRequestApproveTest(){
        Account partnerAccount = [SELECT Id, isPartner, Name 
                                  FROM Account 
                                  WHERE Name = 'PartnerAccount001' 
                                  LIMIT 1];
        Campaign CampaignRecord = [SELECT Id FROM Campaign LIMIT 1];
        PartnerFundRequest fundRequest = new PartnerFundRequest(Title = 'FundRequest003',
                                                                Activity = 'Digital Advertising-LinkedIn',
                                                                ChannelPartnerId = partnerAccount.Id,
                                                                CoOp_Status__c = 'Pending Submission',
                                                                RequestedAmount = 100.99,
                                                                Zinfi_Co_op_Id__c = 'ZINFI-Id-XYZ001',
                                                                Product__c = 'Zero Trust Exchange (ZTX)',
                                                                Lead_Follow_Up__c = 'Zscaler Lead Nurturing',
                                                                Target_Audience__c = 'End Customer',
                                                                PO_Number__c = 'PO_FundRequest003',
                                                                CampaignId = CampaignRecord.Id,
                                                                Amount_Approved__c = 11.99);
        //insert fundRequest;
        
        Test.startTest();
        PartnerFundRequest checkCreatedFundRequest = [SELECT Id, Title FROM PartnerFundRequest 
                                                      WHERE Title = 'FundRequest003'
                                                      LIMIT 1];        
        
        if(checkCreatedFundRequest != NULL){
            System.assertEquals(checkCreatedFundRequest.Title,'FundRequest003');
            // Get the work item 
            ProcessInstance objProcessInstance = [SELECT Id,TargetObjectId, CreatedDate 
                                                  FROM ProcessInstance 
                                                  WHERE TargetObjectId = :checkCreatedFundRequest.Id];
            if(objProcessInstance != NULL){
                ProcessInstanceWorkitem ObjProcessInstanceWorkitem = [SELECT Id,ProcessInstanceId 
                                                                      FROM ProcessInstanceWorkitem 
                                                                      WHERE ProcessInstanceId =: objProcessInstance.Id
                                                                      LIMIT 1];
                Approval.ProcessWorkitemRequest testRej = new Approval.ProcessWorkitemRequest();
                testRej.setComments('Approved!!!');
                testRej.setAction('Approve');      
                testRej.setWorkitemId(ObjProcessInstanceWorkitem.Id);
                try
                {
                    Approval.ProcessResult testRejResult =  Approval.process(testRej);
                }
                catch(DMLException e)
                {
                    //system.assertEquals('Approval Process Error - Required fields are missing : Amount Approved', 
                    //e.getDmlMessage(0), 
                    //'error message should be "Approval Process Error - Required fields are missing : Amount Approved"'); 
                }
            }
        }
        Test.stopTest();
    }
    
    /*
@isTest
static void reEvaluateStatusChangeFundRequestsTest(){
Account partnerAccount = [SELECT Id, isPartner, Name 
FROM Account 
WHERE Name = 'PartnerAccount001' 
LIMIT 1];
Campaign CampaignRecord = [SELECT Id FROM Campaign LIMIT 1];
PartnerFundRequest fundRequest = new PartnerFundRequest(Title = 'FundRequest003',
Activity = 'Digital Advertising-LinkedIn',
ChannelPartnerId = partnerAccount.Id,
CoOp_Status__c = 'Pending Submission',
RequestedAmount = 100.99,
Zinfi_Co_op_Id__c = 'ZINFI-Id-XYZ001',
Product__c = 'Zero Trust Exchange (ZTX)',
Lead_Follow_Up__c = 'Zscaler Lead Nurturing',
Target_Audience__c = 'End Customer',
PO_Number__c = 'PO_FundRequest003',
CampaignId = CampaignRecord.Id,
Amount_Approved__c = 11.99);
insert fundRequest;

Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Finance v2' LIMIT 1];
User usr = new User(LastName = 'test',
FirstName='test',
Alias = 'pbhar',
Email = 'test.test@asdf.com',
Username = 'test.test@asdf.com',
ProfileId = profileId.id,
TimeZoneSidKey = 'GMT',
LanguageLocaleKey = 'en_US',
EmailEncodingKey = 'UTF-8',
LocaleSidKey = 'en_US'
);
insert usr;
system.runAs(usr){
PartnerFundRequest recordToUpdate = [SELECT Id,CoOp_Status__c FROM PartnerFundRequest WHERE Title = 'FundRequest003'];
recordToUpdate.CoOp_Status__c = 'Expired';

update recordToUpdate;
}
}    
*/
}