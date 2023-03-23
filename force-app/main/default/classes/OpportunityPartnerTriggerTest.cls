@isTest
private class OpportunityPartnerTriggerTest {

    @IsTest
    static void testInsert(){
        List<Account> accList = new List<Account>();
        Account acc = creatAccount();
        acc.Type = 'Technology Partner';
        accList.add(acc);
        accList.add(creatAccount());
        accList.add(creatAccount());
        insert accList;
        Opportunity opp = createOpportunity (acc.Id);     

        List<Opportunity_Partner__c> oppPartnerList = new List<Opportunity_Partner__c>();
        oppPartnerList.add(createPartner(opp.id,accList[0].id,'Tech Partner',true));
        oppPartnerList.add(createPartner(opp.id,accList[1].id,'Reseller',true));
        oppPartnerList.add(createPartner(opp.id,accList[2].id,'Distributor',true));
		oppPartnerList.add(createPartner(opp.id,accList[2].id,'Professional Services',true));
        insert oppPartnerList;  
    }

    @IsTest
    static void testUpdate(){
        List<Account> accList = new List<Account>();
        Account acc = creatAccount();
        acc.Type = 'Technology Partner';
        accList.add(acc);
        accList.add(creatAccount());
        accList.add(creatAccount());
        accList.add(creatAccount());
        accList.add(creatAccount());
        insert accList;

        Opportunity opp = createOpportunity (acc.Id);    

        List<Opportunity_Partner__c> oppPartnerList = new List<Opportunity_Partner__c>();
        oppPartnerList.add(createPartner(opp.id,accList[0].id,'Tech Partner',true));
        oppPartnerList.add(createPartner(opp.id,accList[1].id,'Reseller',false));
        oppPartnerList.add(createPartner(opp.id,accList[2].id,'Distributor',false));
        oppPartnerList.add(createPartner(opp.id,accList[3].id,'Influence Partner',false));
        oppPartnerList.add(createPartner(opp.id,accList[4].id,'Professional Services',false));

        insert oppPartnerList;  
        
        oppPartnerList[1].Is_Primary__c = true;
        oppPartnerList[2].Is_Primary__c = true;
        oppPartnerList[3].Is_Primary__c = true;
        oppPartnerList[3].Approval_Status__c='Approved';
        oppPartnerList[4].Is_Primary__c = true;
        
        update oppPartnerList;
        
        oppPartnerList[1].Is_Primary__c = false;
        oppPartnerList[2].Is_Primary__c = false;
        oppPartnerList[3].Is_Primary__c = false;
        oppPartnerList[4].Is_Primary__c = false;
        
        update oppPartnerList;
    }
    
    @IsTest
    static void testDelete(){
        List<Account> accList = new List<Account>();
        accList.add(creatAccount());
        accList.add(creatAccount());
        insert accList;

        Opportunity opp = createOpportunity (accList[0].Id);            

        Opportunity_Partner__c OppDistributorPartner = createPartner(opp.id,accList[1].id,'Tech Partner',false);
        insert OppDistributorPartner;

        OppDistributorPartner.Is_Primary__c = true;
        update OppDistributorPartner;
        
        Opportunity_Partner__c OppResellerPartner = createPartner(opp.id,accList[0].id,'Reseller',false);
        insert OppResellerPartner;
        Opportunity_Partner__c OppDistributor = createPartner(opp.id,accList[1].id,'Distributor',false);
        insert OppDistributor;
        Opportunity_Partner__c OppPSPartner = createPartner(opp.id,accList[1].id,'Professional Services',false);
        insert OppPSPartner;

        OppResellerPartner.Is_Primary__c = true;
        OppResellerPartner.Distributor__c =accList[1].Id;
        update OppResellerPartner;

        Delete OppResellerPartner;

        TriggerUtility2.OppRelTechPartner= false;
        Delete OppDistributorPartner;
    }
	
	public static opportunity createOpportunity (string accountId) {
        Opportunity opp = new Opportunity ();
        opp.Name = 'test opportunity';
        opp.StageName = Label.Stage_1_Alignment /*'0 - Initial Prospecting'*/;
        opp.closedate =  Date.today();
        opp.accountId = accountId;
        insert opp;
        return opp;
    }
    
    private static Account creatAccount () {
        Account acc = new Account ();
        acc.Name = 'Test Account';
        acc.APTS_Platform_Subscription_End_Date__c = Date.today();
        return acc;
    }
    
    public static Opportunity_Partner__c createPartner (string oppId,string accountId, string partnerType , boolean isPrimary) {
        Opportunity_Partner__c OppPartner = new Opportunity_Partner__c();
        OppPartner.Is_Primary__c = isPrimary;
        OppPartner.Opportunity__c = oppId;
        OppPartner.Partner_Type__c = partnerType;
        OppPartner.Account__c = accountId;        
        return OppPartner;
    }
}