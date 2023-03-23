public with sharing class TeamingTechPartnerComponentController {

    private final String PARTNER_TYPE = 'Influence Partner';//Added as part of IBA- 1742

    private static TeamingTechPartnerComponentController instance;
    public static TeamingTechPartnerComponentController getInstance() {
        if (instance == NULL) {
            instance = new TeamingTechPartnerComponentController();
        }

        return instance;
    }

    @AuraEnabled
    public static List<PicklistWrapper>  describePicklistEntries(){
        TeamingTechPartnerComponentController instance = TeamingTechPartnerComponentController.getInstance();

        List<PicklistWrapper> pickListWrapperList = new List<PicklistWrapper>();
        PicklistWrapper picklistWrap;

        List<Schema.PicklistEntry> ple = instance.getPicklistEntries();
		for( Schema.PicklistEntry pickListVal : ple){

            picklistWrap = new PicklistWrapper();
            picklistWrap.label = pickListVal.getLabel();
            picklistWrap.value = pickListVal.getValue();
			pickListWrapperList.add(picklistWrap);
		}     

        return pickListWrapperList;
        
    }

    private List<Schema.PicklistEntry> getPicklistEntries() {

        Schema.DescribeFieldResult fieldResult = Opportunity_Partner__c.Activity_Type__c.getDescribe();

        return fieldResult.getPicklistValues();

    }

    public class PicklistWrapper {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
    }

    @AuraEnabled
    public static Boolean findLoggedInUserProfile(){

        List<User> userProfileList = [
            SELECT 
                Id, 
                Profile.Name 
            FROM 
                User 
            WHERE 
                Id = :UserInfo.getUserId() 
            LIMIT 1
        ];

        User loggedInUser;

        if (!userProfileList.isEmpty()) {
            loggedInUser = userProfileList.get(0);
        }

        return (
            (loggedInUser != NULL) 
            && (String.isNotBlank(loggedInUser.Profile.Name)) 
            && (loggedInUser.Profile.Name.equalsIgnoreCase('System Administrator')));
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
        @AuraEnabled public List<String> activityType           { get; set; }
        @AuraEnabled public String technologyPartnerAccount     { get; set; }
        @AuraEnabled public String recordId                     { get; set; }
        @AuraEnabled public Date activityDate                   { get; set; }
    }

    @AuraEnabled
    public static String createOpportunityPartners(List<OpportunityPartnerWrapper> oppPartnerWrapList){
        System.debug('-=- Inside createOpportunityPartners -=- ');

        TeamingTechPartnerComponentController instance = TeamingTechPartnerComponentController.getInstance();
        instance.setOppPartnerWrapList(oppPartnerWrapList);
        instance.filterOppPartnerWrapMap(); //Remove the duplicate records from the list
        instance.validateExistingOppPartnerRecords();


        instance.retrievePartnerAccountRegionalManagerEmail();
        
        
        List<Opportunity_Partner__c> oppPartnerToCreateList = instance.createOpportunityPartnerRecords();

        for (Opportunity_Partner__c oppPartner : oppPartnerToCreateList) {
            System.debug('-=- Regional_Director__c -=- '+oppPartner.Regional_Director__c);

            if (oppPartner.Regional_Director__c != NULL) {
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

    private void retrievePartnerAccountRegionalManagerEmail() {
       
        Map<Id, Id> regionalManagerMap = new Map<Id, Id> ();
		Map<Id, Id> TechnologyAllianceManagerMap = new Map<Id, Id> ();
        Set<Id> relatedOpportunityIdSet = new Set<Id> ();
        Set<Id> relatedPartnerAccIdSet = new Set<Id> ();
        for (OpportunityPartnerWrapper oppPartnerWrap : oppPartnerWrapList) {
            relatedOpportunityIdSet.add(oppPartnerWrap.recordId);
            relatedPartnerAccIdSet.add(oppPartnerWrap.technologyPartnerAccount);
        }
		System.debug('-=- relatedPartnerAccIdSet -=- '+relatedPartnerAccIdSet);
        for(Account acc : [Select ID,Technology_Alliance_Manager__c from Account where Technology_Alliance_Manager__c!=Null and Id IN :relatedPartnerAccIdSet LIMIT 49999 ]){
            System.debug('=--=- acc -=-= '+acc);
            TechnologyAllianceManagerMap.put(acc.Id,acc.Technology_Alliance_Manager__c);
        }

        System.debug('-=- relatedOpportunityIdSet -=- '+relatedOpportunityIdSet);
		

        for (Opportunity opp : [SELECT Id, Opportunity_Area_Director__c,Account.Area_Director__c FROM Opportunity WHERE Id IN :relatedOpportunityIdSet LIMIT 49999 ]) {
            
            System.debug('=--=- opp -=-= '+opp);
            //CR 2961: start
            //regionalManagerMap.put(opp.Id, opp.Opportunity_Area_Director__c);
            regionalManagerMap.put(opp.Id, opp.Account.Area_Director__c);
            //CR 2961: End
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
            oppPartnerToCreate.Account__c           = oppPartnerWrap.technologyPartnerAccount;
            oppPartnerToCreate.Partner_Type__c      = PARTNER_TYPE;
            oppPartnerToCreate.Activity_Type__c     = String.join(oppPartnerWrap.activityType, ', ');
            oppPartnerToCreate.Opportunity__c       = oppPartnerWrap.recordId;
            //oppPartnerToCreate.Activity_Date__c     = oppPartnerWrap.activityDate; //Not required
            /*oppPartnerToCreate.Regional_Account_Manager_Email__c = 
                (regionalManagerEmailMap != NULL) && (regionalManagerEmailMap.containsKey(oppPartnerWrap.technologyPartnerAccount))
                ? regionalManagerEmailMap.get(oppPartnerWrap.technologyPartnerAccount)
                : NULL;*/

                //Regional Director 

            oppPartnerToCreate.Regional_Director__c = (regionalManagerMap != NULL) && (regionalManagerMap.containsKey(oppPartnerWrap.recordId))
            ? regionalManagerMap.get(oppPartnerWrap.recordId)
            : NULL;
            oppPartnerToCreate.Technology_Alliance_Manager__c = (TechnologyAllianceManagerMap != NULL) && (TechnologyAllianceManagerMap.containsKey(oppPartnerWrap.technologyPartnerAccount))
            ? TechnologyAllianceManagerMap.get(oppPartnerWrap.technologyPartnerAccount)
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
        //TODO: add condition to filter with the type add AND Type Not IN :typeSet

        String queryConditions = String.join(queryParamConditions, ' AND ');
        queryConditions = ' WHERE ' + queryConditions;
        setQueryConditions(queryConditions);
        setQueryLimit(49999);
        String queryString = constructQueryString();
        oppPartnerToCreateList = Database.query(queryString);

        return oppPartnerToCreateList;
    }

    

    private List<OpportunityPartnerWrapper> oppPartnerWrapList;
    private void setOppPartnerWrapList(List<OpportunityPartnerWrapper> oppPartnerWrapList) {
        this.oppPartnerWrapList = oppPartnerWrapList;
    }

    private void filterOppPartnerWrapMap() {
        Map<Id, OpportunityPartnerWrapper> oppPartnerWrapMap = new map<Id, OpportunityPartnerWrapper>();

        for (OpportunityPartnerWrapper wrap : oppPartnerWrapList) {
            oppPartnerWrapMap.put(wrap.technologyPartnerAccount, wrap);
        }

        setOppPartnerWrapList(oppPartnerWrapMap.values());
    }

    private void validateExistingOppPartnerRecords() {

        System.debug('-=- inside validate ');

        Set<Id> opportunityIdSet    = new Set<Id> ();
        Set<Id> accountIdSet        = new Set<Id> ();

        for (OpportunityPartnerWrapper oppParnerWrap : oppPartnerWrapList) {
            opportunityIdSet.add(oppParnerWrap.recordId);
            accountIdSet.add(oppParnerWrap.technologyPartnerAccount);
        }

        System.debug('-=- opportunityIdSet -=- '+opportunityIdSet);

       

        List<String> queryParamConditions = new List<String>();
        queryParamConditions.add('Account__c IN :accountIdSet');
        queryParamConditions.add('Opportunity__c IN :opportunityIdSet');
        queryParamConditions.add('IsDeleted = FALSE');
        queryParamConditions.add('Partner_Type__c = :PARTNER_TYPE');

        String queryConditions = String.join(queryParamConditions, ' AND ');
        queryConditions = ' WHERE ' + queryConditions;
        setQueryConditions(queryConditions);
        setQueryLimit(49999);
        String queryString = constructQueryString();

        for (Opportunity_Partner__c oppPartner : Database.query(queryString)) {
            System.debug('-=-= oppPartner -=- '+oppPartner);

            for (OpportunityPartnerWrapper oppPartnerWrap : oppPartnerWrapList) {

                if (( oppPartnerWrap.technologyPartnerAccount ==  oppPartner.Account__c) && ( oppPartnerWrap.recordId == oppPartner.Opportunity__c )) {

                    throw new AuraHandledException('Influence partner already exists.');//Added as part of IBA- 1742

                }

            }
        }

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

        String queryFields = 'Id, Opportunity__r.Opportunity_Area_Director__c, Regional_Director__c,Regional_Director__r.Name, Account__c, Account__r.Name,toLabel(Account__r.Partner_Type__c), Activity_Type__c, CreatedById, CreatedBy.Name, CreatedDate, Approved_Rejected_Date__c, Approval_Status__c, Opportunity__c';
        
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
    public static List<Opportunity_Partner__c> fetchTeamingTechPartners(Id opportunityId){

        System.debug('-=-= opportunityId -=- '+opportunityId);
        TeamingTechPartnerComponentController instance = TeamingTechPartnerComponentController.getInstance();

        instance.setOpportunityId(opportunityId);
       

        List<Opportunity_Partner__c> oppParnerList = instance.fetchExistingOppPartnerRecords();

        
        System.debug('-=-= oppParnerList -=- '+oppParnerList);

        return oppParnerList;
    }


    private List<Opportunity_Partner__c> fetchExistingOppPartnerRecords() {
        List<String> queryParamConditions = new List<String>();
        //queryParamConditions.add('Account__c IN :accountIdSet');
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
    public static String deleteTeamingTechPartners(Id recordId){
        try {
            Opportunity_Partner__c oppPartner = new Opportunity_Partner__c(Id = recordId);

            DELETE oppPartner;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return 'SUCCESS';
    }
    

    
}