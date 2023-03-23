@isTest(Seealldata=true)
public class PRstopPurgecontrollerTest{
    @isTest static void test(){
        test.starttest();
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acc = new Account(Name='TestAccount',Type='Customer',Domain__c='TestAccount.com');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact',Email = 'test@test.com', AccountId =acc.id);
        insert con;
        Opportunity opp = new Opportunity(Name = 'Test Opp',StageName ='Test stage', closeDate = system.today(),AccountId = acc.Id);
        insert opp;
        Id inlineRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
        
        Provisioning_Request__c Pr = new Provisioning_Request__c(Account__c = acc.id,
                                                             RecordTypeId = inlineRecordTypeId,
                                                             Organization_Domain__c = 'Test',
                                                             Additional_Organization_domains__c = 'Test',/*'Zscaler.net'*/
                                                             Send_Initial_l__c = 'ATT Usell',
                                                             Partner_Contact__c = con.id,
                                                             Opportunity__c= opp.id,                                                                 
                                                             Provisioning_Status__c = 'To Be Purged');
        insert Pr;
        List<Provisioning_Request__c> provisioningRequests = [select Id, Customer_Account_from_Opportunity__c, FailedReason__c, Primary_Eval_Contact__c, SE__c, SE__r.Email, Provisioning_Type__c, Partner_Contact__c, Partner_Contact__r.Email, Primary_Eval_Contact__r.Email, Primary_Eval_Contact__r.Name, Provisioning_Status__c, Org_ID_with_cloud__c, Organization_Domain__c, Opportunity__r.Account.Name, Send_Initial_l__c, RecordTypeId, RecordType.DeveloperName from Provisioning_Request__c where Opportunity__c != null  AND Account__c != null limit 1]; 
        system.debug('list'+provisioningRequests);
            
        //PageReference ref = new PageReference('/apex/PRStopPurgePage?id=' +Pr.Id);
        //Test.setCurrentPage(ref);
        //ProvisioningFevaRequestController con = new ProvisioningFevaRequestController();
        //Pagereference pgref=con.SubmitforStopPurge();
        
        Provisioning_Request__c Prvsn_Rqst = new Provisioning_Request__c();
        
        PageReference myVfPage2 = Page.ProvisionExtensionPage;
        Test.setCurrentPageReference(myVfPage2);
        ApexPages.StandardController sc2 = new ApexPages.StandardController(provisioningRequests[0]);   
        PRExtcontroller pc2= new PRExtcontroller(sc2);
        pc2.Prvsn_Rqst.Detailed_Reason_for_Contract_Extension__c = 'testing reason';
        pc2.Prvsn_Rqst.PR_Extension_Requested_Date__c = system.today();
        pc2.submitForApproval();
        //pc2.booster();

        /*ProcessInstance process = new ProcessInstance();
        process.ProcessDefinitionId = pr.Id;
        process.TargetObjectId =pr.Id;
        process.Status = 'started';
        process.ProcessDefinitionId = pc2.req.id; */
        
        PageReference myVfPage = Page.PRStopPurgePage;
        Test.setCurrentPageReference(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(provisioningRequests[0]);   
        PRstopPurgecontroller pc= new PRstopPurgecontroller(sc);            
        pc.Prvsn_Rqst.Reason_for_Stop_Purge__c = 'Testing';
        pc.SubmitforStopPurge();
        pc.cancelStopPurgePopup();
        //pc.booster();
                        
        test.stoptest();
    }
    @isTest static void test2(){
        test.starttest();
        TriggerUtility2.setPartnerDiscountExecuted();
        Account acc = new Account(Name='TestAccount',Type='Customer',Domain__c='TestAccount.com');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test Contact',Email = 'test@test.com', AccountId =acc.id);
        insert con;
        Opportunity opp = new Opportunity(Name = 'Test Opp',StageName ='Test stage', closeDate = system.today(),AccountId = acc.Id);
        insert opp;
        Id inlineRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
        
        Provisioning_Request__c Pr = new Provisioning_Request__c(Account__c = acc.id,
                                                             RecordTypeId = inlineRecordTypeId,
                                                             Organization_Domain__c = 'Test',
                                                             Additional_Organization_domains__c = 'Test',/*'Zscaler.net'*/
                                                             Send_Initial_l__c = 'ATT Usell',
                                                             Partner_Contact__c = con.id,
                                                             Opportunity__c= opp.id,
                                                             
                                                             Provisioning_Status__c = 'To Be Purged');
        insert Pr;
        List<Provisioning_Request__c> provisioningRequests = [select Id, Customer_Account_from_Opportunity__c, FailedReason__c, Primary_Eval_Contact__c, SE__c, SE__r.Email, Provisioning_Type__c, Partner_Contact__c, Partner_Contact__r.Email, Primary_Eval_Contact__r.Email, Primary_Eval_Contact__r.Name, Provisioning_Status__c, Org_ID_with_cloud__c, Organization_Domain__c, Opportunity__r.Account.Name, Send_Initial_l__c, RecordTypeId, RecordType.DeveloperName from Provisioning_Request__c where Opportunity__c != null  AND Account__c != null limit 1]; 
        system.debug('list'+provisioningRequests);
            
        //PageReference ref = new PageReference('/apex/PRStopPurgePage?id=' +Pr.Id);
        //Test.setCurrentPage(ref);
        //ProvisioningFevaRequestController con = new ProvisioningFevaRequestController();
        //Pagereference pgref=con.SubmitforStopPurge();
        
        Provisioning_Request__c Prvsn_Rqst = new Provisioning_Request__c();
        
        PageReference myVfPage = Page.PRStopPurgePage;
        Test.setCurrentPageReference(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(provisioningRequests[0]);   
        PRstopPurgecontroller pc= new PRstopPurgecontroller(sc); 
        pc.currentDetailedReasonforContractExtension = '';
        pc.Prvsn_Rqst.Reason_for_Stop_Purge__c = '';
        pc.SubmitforStopPurge();
        pc.cancelStopPurgePopup();
        //pc.booster();
        
        PageReference myVfPage2 = Page.ProvisionExtensionPage;
        Test.setCurrentPageReference(myVfPage2);
        ApexPages.StandardController sc2 = new ApexPages.StandardController(provisioningRequests[0]);   
        PRExtcontroller pc2= new PRExtcontroller(sc2);
        //pc2.booster();
            
        test.stoptest();
    }
}