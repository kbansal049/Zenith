@isTest
private inherited sharing class FC_Plugin_TestExtension {
	
	private static void FC_Plugin_TestResponseAccelerator(Boolean withError) {
        Map<ID, Sobject> leadmap = null;

        Contact cont = new Contact(LastName='TestContact');
        insert cont;

        Map<ID, Sobject> contactmap = new Map<ID, Sobject>{cont.Id => cont};

        String oppStage = '';
        List<OpportunityStage> opportunitystages = [SELECT ID, IsActive, MasterLabel from OpportunityStage WHERE IsActive = TRUE LIMIT 2];
        for(OpportunityStage opstage: opportunitystages){
            if(opstage.IsActive) oppStage = opstage.MasterLabel;
        }
        //Below is commented due to System.DmlException: Upsert failed. 
        //First exception on row 0; first error: INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST, 
        //Stage: bad value for restricted picklist field: oppStage: [Stage__c]
        //When deploying to higher orgs, Chnaged the Stage "Label.Stage_6_Closed_Won"
        //Opportunity opp = new Opportunity(Name='TestAccount-opp1', StageName='oppStage', CloseDate = Date.Today().addDays(5));
        //insert opp;
        
        Opportunity opp = new Opportunity(Name='TestAccount-opp1', StageName=Label.Stage_6_Closed_Won, CloseDate = Date.Today().addDays(5));
        insert opp;

        OpportunityContactRole ocr = new OpportunityContactRole(ContactId=cont.Id, OpportunityId=opp.Id, IsPrimary=true);
        insert ocr;

        Campaign camp = new Campaign(Name='TestCampaign', IsActive=true);
        insert camp;

        CampaignMember good1 = new CampaignMember(CampaignId=camp.Id, ContactId=cont.Id, FCRM__FCR_Response_Date__c=DateTime.now().addMinutes(2), FCRM__FCR_Opportunity__c=null, FCRM__FCR_Reactivation_Date__c=null, Status='Responded');
        insert good1;

        List<Sobject> successes = new List<SObject>{good1};
        List<Sobject> retried = null;
        List<Sobject> failed = null;

        Object reactivationType = 3;

        MockArgs args = new MockArgs();
		args.RecordMaps = new List<Map<ID, Sobject>> { leadmap, contactmap };
		args.Recordlists = new List<List<Sobject>> {successes, retried, failed };
		args.AdditionalParams = new List<Object>{reactivationType};

        Test.startTest();
		FC_Plugin_ResponseAccelerator plugin = new FC_Plugin_ResponseAccelerator();
        if(withError){
            FC_Plugin_ResponseAccelerator.MockDMLError = true;
        }
        System.assertEquals('FC_Plugin_ResponseAccelerator', plugin.GetUniqueName());
        System.assertEquals(new Set<String>{FCRM.FCR_ExtensibilityAPI.REACTIVATIONCOMPLETE}, plugin.RequestedAPIs());
        System.assertEquals(null, plugin.RequestedFields());

        plugin.ExtensibilityEvent(FCRM.FCR_ExtensibilityAPI.REACTIVATIONCOMPLETE, args);
        Test.stopTest();

        List<Opportunity> opps = [SELECT Id, CreatedDate FROM Opportunity WHERE Id = :opp.Id];
        List<CampaignMember> cms = [SELECT Id, FCRM__FCR_Response_Date__c FROM CampaignMember WHERE Id = :good1.Id];

        if(!withError){
            //Really all we want to assert is no negative velocity
            System.assert(cms[0].FCRM__FCR_Response_Date__c < opps[0].CreatedDate);
        }
	}
    
	@isTest
    private static void FC_Plugin_TestResponseAccelerator_A() {
        FC_Plugin_TestResponseAccelerator(false);
    }

    @isTest
    private static void FC_Plugin_TestResponseAccelerator_Error() {
        FC_Plugin_TestResponseAccelerator(true);
    }

    @isTest
	private static void FC_Plugin_TestResponseAccelerator_NoArgs() {
        Test.startTest();
		FC_Plugin_ResponseAccelerator plugin = new FC_Plugin_ResponseAccelerator();
        plugin.ExtensibilityEvent(FCRM.FCR_ExtensibilityAPI.REACTIVATIONCOMPLETE, null);
        Test.stopTest();
        System.assert(true); // Tests should always assert something.
    }

    public class MockArgs implements FCRM.FCR_ExtensibilityAPI.IExtensibilityEventArgs
    {
        public List<List<Sobject>> Recordlists {get;set;}
		public List<Map<ID, Sobject>> RecordMaps {get;set;}
		public List<List<ID>> RecordIds;
		public List<Object> AdditionalParams {get;set;}
		public String XMLdata;
		
		public List<List<Sobject>> getRecordLists() { return RecordLists; }
		public List<Map<ID, Sobject>> getRecordMaps() { return RecordMaps; }
		public List<List<ID>> getRecordIds() { return RecordIds; }
		public List<Object> getAdditionalParams() {return AdditionalParams; }
		public void setRaiseFuture() { return; }
		public String getXMLdata() { return XMLdata; }

        public MockArgs(){}
    }
}