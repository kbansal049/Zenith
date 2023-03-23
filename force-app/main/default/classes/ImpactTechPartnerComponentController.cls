/**
 * VERSION        AUTHOR                  DATE              DETAIL              
   1.0            ------                 ---------        Initial 
   2.0            Swathi                 8/12/2022        IBA-5110
**/
public with sharing class ImpactTechPartnerComponentController {
	private final String PARTNER_TYPE = 'Impact Partner';//Added as part of IBA- 1742
    private static ImpactTechPartnerComponentController instance;
    public static ImpactTechPartnerComponentController getInstance() {
        if (instance == NULL) {
            instance = new ImpactTechPartnerComponentController();
        }

        return instance;
    }
    
    @AuraEnabled
    public static void updateOppotunityPartnerToImpact(Id oppPartnerId){
       try {
        	Opportunity_Partner__c oppPartner = [SELECT Id,Account__c, Opportunity__c from Opportunity_Partner__c WHERE Id = :oppPartnerId LIMIT 1];
        	Opportunity opportunityToUpdate = new Opportunity();
        	opportunityToUpdate.Id = oppPartner.Opportunity__c;
        	opportunityToUpdate.Secondary_Partner__c = oppPartner.Account__c;
            update opportunityToUpdate;
        } catch (System.DMLException e) {
            //System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean findLoggedInUserProfile(Id opportunityId){
        //IBA-5110 - Start
        Opportunity oppRecord = [Select Id,OwnerId from Opportunity where ID = :opportunityId Limit 1];
        System.debug('oppRecord '+oppRecord);
        System.debug('oppRecord '+Userinfo.getProfileId());
        System.debug('oppRecord '+Userinfo.getUserId());
        Show_Actions_on_Impact_Partner__c proftoskip = Show_Actions_on_Impact_Partner__c.getInstance(Userinfo.getProfileId());
        Show_Actions_on_Impact_Partner__c usertoskip = Show_Actions_on_Impact_Partner__c.getInstance(Userinfo.getUserId());
		System.debug('oppRecord '+proftoskip.Id);
        System.debug('oppRecord '+usertoskip.Id);
        System.debug('oppRecord '+oppRecord.OwnerId == Userinfo.getUserId());
        return (proftoskip.Id != null || usertoskip.Id != null || oppRecord.OwnerId == Userinfo.getUserId());
        //IBA-5110 - End
    }

    @AuraEnabled
    public static Account_Extension__c getPrimaryContacts(ID accountId){
        return [select ID,Tech_Partner_Primary_Contact__c,Tech_Partner_Primary_Contact__r.Name from Account_Extension__c where Account__c=:accountId];
    }

    private void submitForApproval(Opportunity_Partner__c oppPartner){
        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
        submitRequest.setComments('Submitting request for approval automatically'); //TODO: update the comment
        submitRequest.setObjectId(oppPartner.Id); //Opp Par record id
        submitRequest.setNextApproverIds(new Id[] {oppPartner.Regional_Director__c}); 

        System.debug('-=- submitForApproval -=- '+oppPartner);

        // Submit the approval request for the Opportunity
        Approval.ProcessResult result = Approval.process(submitRequest);
    }

    public class OpportunityPartnerWrapper {
        @AuraEnabled public String partnerRepEmail              { get; set; }
        @AuraEnabled public String impactPartnerAccount         { get; set; }
        @AuraEnabled public String recordId                     { get; set; }
        @AuraEnabled public String partnerRepName               { get; set; }
        @AuraEnabled public String impactPartnerContact         { get; set; }
    }

    @AuraEnabled
    public static String createOpportunityPartners(List<OpportunityPartnerWrapper> oppPartnerWrapList){
        System.debug('-=- Inside createOpportunityPartners -=- '+ oppPartnerWrapList);
        ImpactTechPartnerComponentController instance = ImpactTechPartnerComponentController.getInstance();
        instance.setOppPartnerWrapList(oppPartnerWrapList);
        instance.filterOppPartnerWrapMap(); //Remove the duplicate records from the list
        instance.retrievePartnerGeoVPEmail();
        List<Opportunity_Partner__c> oppPartnerToCreateList = instance.createOpportunityPartnerRecords();

        for (Opportunity_Partner__c oppPartner : oppPartnerToCreateList) {
            System.debug('-=- Geo_VP__c -=- '+oppPartner.Geo_VP__c);

            if (oppPartner.Geo_VP__c != NULL) {
                instance.submitForApproval(oppPartner);
            }

        }

        return 'SUCCESS';
    }


    private Map<Id, Id> TechnologyAllianceManagerMap;
    private void setTechnologyAllianceManagerMap(Map<Id, Id> TechnologyAllianceManagerMap) {
        this.TechnologyAllianceManagerMap = TechnologyAllianceManagerMap;
    }

    private Map<Id, Id> regionalManagerMap;
    private void setRegionalManagerMap(Map<Id, Id> regionalManagerMap) {
        this.regionalManagerMap = regionalManagerMap;
    }

    private void retrievePartnerGeoVPEmail() {
        Map<Id, Id> regionalManagerMap = new Map<Id, Id> ();
        Set<Id> relatedOpportunityIdSet = new Set<Id> ();
        Map<Id, Id> TechnologyAllianceManagerMap = new Map<Id, Id> ();
        Set<Id> relatedPartnerAccIdSet = new Set<Id> ();
        for (OpportunityPartnerWrapper oppPartnerWrap : oppPartnerWrapList) {
            relatedOpportunityIdSet.add(oppPartnerWrap.recordId);
            relatedPartnerAccIdSet.add(oppPartnerWrap.impactPartnerAccount);
        }
        System.debug('-=- relatedOpportunityIdSet -=- '+relatedOpportunityIdSet);
        System.debug('-=- relatedPartnerAccIdSet -=- '+relatedPartnerAccIdSet);
        for(Account acc : [Select ID,Technology_Alliance_Manager__c from Account where Id IN :relatedPartnerAccIdSet and Technology_Alliance_Manager__c!=NUll LIMIT 49999 ]){
            System.debug('=--=- acc -=-= '+acc);
            TechnologyAllianceManagerMap.put(acc.Id,acc.Technology_Alliance_Manager__c);
        }
        for (Opportunity opp : [Select Id, Account.Sales_Territory__r.GEO_VP__c from Opportunity WHERE Id IN :relatedOpportunityIdSet and Account.Sales_Territory__r.GEO_VP__c!=Null LIMIT 49999 ]) {  
            System.debug('=--=- opp -=-= '+opp);
            regionalManagerMap.put(opp.Id, opp.Account.Sales_Territory__r.GEO_VP__c);
        }
        setRegionalManagerMap(regionalManagerMap);
        setTechnologyAllianceManagerMap(TechnologyAllianceManagerMap);
    }

    

    private List<Opportunity_Partner__c> createOpportunityPartnerRecords() {
        List<Opportunity_Partner__c> oppPartnerToCreateList = new List<Opportunity_Partner__c>();
        Opportunity_Partner__c oppPartnerToCreate;
        System.debug('-=-=- oppPartnerWrapList -=- '+oppPartnerWrapList);
        for (OpportunityPartnerWrapper oppPartnerWrap : oppPartnerWrapList) {
            oppPartnerToCreate                      = new Opportunity_Partner__c();
            oppPartnerToCreate.Account__c           = oppPartnerWrap.impactPartnerAccount;
            oppPartnerToCreate.Partner_Type__c      = PARTNER_TYPE;
            oppPartnerToCreate.Opportunity__c       = oppPartnerWrap.recordId;
            oppPartnerToCreate.Partner_Contact__c   = oppPartnerWrap.impactPartnerContact;
            oppPartnerToCreate.Partner_Rep_Name__c  = oppPartnerWrap.partnerRepName;
            oppPartnerToCreate.Partner_Rep_Email__c = oppPartnerWrap.partnerRepEmail;
            oppPartnerToCreate.Approval_Status__c   = 'New';
            oppPartnerToCreate.Geo_VP__c = (regionalManagerMap != NULL) && (regionalManagerMap.containsKey(oppPartnerWrap.recordId))
            ? regionalManagerMap.get(oppPartnerWrap.recordId)
            : NULL;
            oppPartnerToCreate.Technology_Alliance_Manager__c = (TechnologyAllianceManagerMap != NULL) && (TechnologyAllianceManagerMap.containsKey(oppPartnerWrap.impactPartnerAccount))
            ? TechnologyAllianceManagerMap.get(oppPartnerWrap.impactPartnerAccount)
            : NULL;

            oppPartnerToCreateList.add(oppPartnerToCreate);
        }

        System.debug('-=-=- oppPartnerToCreateList -=- '+oppPartnerToCreateList);

        try {
            INSERT oppPartnerToCreateList;
        } catch (System.DMLException e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('-=- oppPartnerToCreateList -=- '+oppPartnerToCreateList);
        List<String> queryParamConditions = new List<String>();
        queryParamConditions.add('Id IN :oppPartnerToCreateList');
        String queryConditions = String.join(queryParamConditions, ' AND ');
        queryConditions = ' WHERE ' + queryConditions;
        setQueryConditions(queryConditions);
        setQueryLimit(49999);
        String queryString = constructQueryString();
        System.debug('queryString'+queryString);
        oppPartnerToCreateList = Database.query(queryString);
        return oppPartnerToCreateList;
    }

    

    private List<OpportunityPartnerWrapper> oppPartnerWrapList;
    private void setOppPartnerWrapList(List<OpportunityPartnerWrapper> oppPartnerWrapList) {
        this.oppPartnerWrapList = oppPartnerWrapList;
    }

    private void filterOppPartnerWrapMap() {
        Map<Id, OpportunityPartnerWrapper> oppPartnerWrapMap = new map<Id, OpportunityPartnerWrapper>();
		System.debug('oppPartnerWrapList '+oppPartnerWrapList);
        for (OpportunityPartnerWrapper wrap : oppPartnerWrapList) {
            oppPartnerWrapMap.put(wrap.impactPartnerAccount, wrap);
        }

        setOppPartnerWrapList(oppPartnerWrapMap.values());
    }

    private Id opportunityId;
    private void setOpportunityId(Id opportunityId) {
        this.opportunityId = opportunityId;
    }

    private final String QUERY_STRING = 'SELECT {0} FROM {1} {2} {3} {4}';
    private String queryConditions;
    private void setQueryConditions(String queryConditions) {
        this.queryConditions = queryConditions;
    }

    private Integer queryLimit = 200;
    private void setQueryLimit(Integer queryLimit){
        this.queryLimit = queryLimit;
    }

    private String constructQueryString() {

        String queryFields = 'Id,Opportunity__r.OwnerId, Opportunity__r.Opportunity_Area_Director__c, Regional_Director__c, Account__c, Account__r.Name, Activity_Type__c, CreatedById, CreatedBy.Name, CreatedDate, Approved_Rejected_Date__c,MEDDPICC_Activity_Type__c, Approval_Status__c,Geo_VP__c,Geo_VP__r.Name, Opportunity__c';
        
        String queryString = QUERY_STRING;
        List<String> queryStringParamList = new List<String> ();
        queryStringParamList.add(queryFields);
        queryStringParamList.add('Opportunity_Partner__c');
        queryStringParamList.add(queryConditions);
        queryStringParamList.add('ORDER BY CreatedDate');
        queryStringParamList.add('LIMIT :queryLimit');
        
        queryString = String.format(queryString, queryStringParamList);
        return queryString;
    }

    @AuraEnabled
    public static ImpactPartner_Response fetchImpactTechPartners(Id opportunityId){

        System.debug('-=-= opportunityId -=- '+opportunityId);
        ImpactTechPartnerComponentController instance = ImpactTechPartnerComponentController.getInstance();

        instance.setOpportunityId(opportunityId);
       

        List<Opportunity_Partner__c> oppParnerList = instance.fetchExistingOppPartnerRecords();
		Show_Actions_on_Impact_Partner__c proftoskip = Show_Actions_on_Impact_Partner__c.getInstance(Userinfo.getProfileId());//IBA-5110
        Show_Actions_on_Impact_Partner__c usertoskip = Show_Actions_on_Impact_Partner__c.getInstance(Userinfo.getUserId());//IBA-5110
        
        System.debug('-=-= oppParnerList -=- '+oppParnerList);
        ImpactPartner_Response resp = new ImpactPartner_Response();
        If(!oppParnerList.IsEmpty()){
			Set<String> statustoQuery = new Set<String>();
            statustoQuery.add(Label.Cosell_Invited);
            statustoQuery.add(Label.Cosell_Accepted);
            statustoQuery.add(Label.Cosell_Completed);
            Integer countofAWPOVinvited = [Select count() from Opportunity_Partner__c where Opportunity__c = :opportunityId and Partner_Type__c='Impact' and Approval_Status__c in :statustoQuery];
            resp.hasImpactInvited = countofAWPOVinvited > 0;
            system.debug(resp.hasImpactInvited);
            resp.isImpactPresent = false;
            resp.wrplst = new List<Impact_Wrapper>();
            for(Opportunity_Partner__c Opppartner: oppParnerList){
                resp.isImpactPresent = true;
                Impact_Wrapper wrp = new Impact_Wrapper();
                boolean showWd = false;
                boolean showComp = false;
                //Modified below if condition as part of IBA-5110
                if(!resp.hasImpactInvited && (Opppartner.Opportunity__r.OwnerId == UserInfo.getUserId() || proftoskip.Id != null || usertoskip.Id != null ) && (Opppartner.Approval_Status__c == Label.Cosell_Invited || Opppartner.Approval_Status__c == Label.Cosell_Accepted)){
                    showWd = true;
                    showComp = true;
                }
                wrp.rec = Opppartner;
                wrp.showComplete = showComp;
                wrp.showWithdraw = showWd;
                resp.wrplst.add(wrp);
            }
        }
        System.debug('resp '+resp);
        return resp;
    }


    private List<Opportunity_Partner__c> fetchExistingOppPartnerRecords() {
        List<String> queryParamConditions = new List<String>();
        queryParamConditions.add('Opportunity__c = :opportunityId');
        queryParamConditions.add('IsDeleted = FALSE');
        queryParamConditions.add('Partner_Type__c = :PARTNER_TYPE');

        String queryConditions = String.join(queryParamConditions, ' AND ');
        queryConditions = ' WHERE ' + queryConditions;
        setQueryConditions(queryConditions);
        setQueryLimit(200);
        String queryString = constructQueryString();

        List<Opportunity_Partner__c> oppParnerList = Database.query(queryString);
        return oppParnerList;
    }
    
    @AuraEnabled
    public static String updateStatus(Id recordId,String Status){
        try {
            Opportunity_Partner__c oppPartner = [select ID, Approval_Status__c from Opportunity_Partner__c where Id =:recordId and Partner_Type__c='Impact Partner'];
			oppPartner.Approval_Status__c = Status;
            update oppPartner;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return 'SUCCESS';
    }
    
    public class Impact_Wrapper{
        @AuraEnabled
        public Opportunity_Partner__c rec;
        @AuraEnabled
        public Boolean showWithdraw;
        @AuraEnabled
        public Boolean showComplete;

    }

    public class ImpactPartner_Response{
        @AuraEnabled
        public List<Impact_Wrapper> wrplst;
        @AuraEnabled
        public Boolean isImpactPresent;
        @AuraEnabled
        public Boolean hasImpactInvited;
    }
}