public class PSCredit_CreateRedemptionProjectHelper {
    
    public static List<String> userNames = new List<String>{
        L2O_Constants.PlannerGenericUserAssignment.USERNAME_GENERIC_CONSULTANT,
        L2O_Constants.PlannerGenericUserAssignment.USERNAME_GENERIC_PM
    };

    public static Map<String,Id> userIdByName {
        get {
            
            return userIdByName == null ? getUserIdByName(userNames) : userIdByName;
        }
        private set;  
    }
    
    public static Map<String,Id> getUserIdByName(List<String> userNames) {
         
        Map<String,Id> userIdByUserName = new Map<String,Id>();
            for(User genericUser : [SELECT Id,Name from User where Name IN :userNames]) {
                userIdByUserName.put(genericUser.Name,genericUser.Id);
            }

			return userIdByUserName;
    }

    public PSCredit_CreateRedemptionProjectHelper() {        
    }

    public static Id getUserId(Map<String,Id> userIdByName, String name) {
        if(String.isNotBlank(name) && userIdByName.containsKey(name)) {
            return userIdByName.get(name);
        }

        return null;
    }

        /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of IBA - 1933 : this method calculates and returns the Number(i.e. RF number) that the Project record should be named with.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : getAvailableProjectsCount .
    * @param    NAME : Set<Id> accountIdSet .
    * @return   TYPE : Map<Id,Integer> accountIdtoRFCountMapLocal .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */  
    public static Map<Id,Integer> getAvailableProjectsCount(Set<Id> accountIdSet) {
        Map<Id,Integer> accountIdtoRFCountMapLocal = New Map<Id,Integer>();
        List<AggregateResult> projectAggrResult = [SELECT COUNT(Id) existingProjectsCount, inspire1__Account__c 
                                                FROM inspire1__Project__c 
                                                WHERE inspire1__Account__c IN: accountIdSet 
                                                AND Full_Project_Name__c LIKE '%-RF%'
                                                GROUP BY inspire1__Account__c];                                          
        
        for(AggregateResult projectAggrObj : projectAggrResult){
            accountIdtoRFCountMapLocal.put(String.valueOf(projectAggrObj.get('inspire1__Account__c')), Integer.valueOf(projectAggrObj.get('existingProjectsCount')));
        }
        
        return accountIdtoRFCountMapLocal;                                               
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of IBA - 1933 : This method will return the deployment package string that will mapped to the Project's
    Deployment package by taking it and clibbing it from all the related customer credit records.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : getCreditSkuForPsCredit .
    * @param    NAME : String creditRedemptionId .
    * @return   TYPE : String deploymentPackageStr .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */  
    public static Map<Id,String> getCreditSkuForPsCredit(Set<Id> creditRedemptionIdSet) {
        
        Map<Id,String> redemptionIdWithCreditSKUMapLocal = New  Map<Id,String>();
        String deploymentPackageStr = '';
        List<PS_Credit_Redemption_Junction__c> psCreditRedemptionJunctionList = new  List<PS_Credit_Redemption_Junction__c>();
        psCreditRedemptionJunctionList = [SELECT Id, Name, Professional_Services_Credit__c, PS_Credit_Redemption__c,
                                        Professional_Services_Credit__r.PS_Credit_SKU__c, PS_Credit_Redemption__r.PS_Credit_Redemption_Name__c
                                        FROM PS_Credit_Redemption_Junction__c
                                        WHERE PS_Credit_Redemption__c IN: creditRedemptionIdSet];
        
        for(PS_Credit_Redemption_Junction__c psCreditRedemptionJunctionObj : psCreditRedemptionJunctionList){
            if(redemptionIdWithCreditSKUMapLocal.containsKey(psCreditRedemptionJunctionObj.PS_Credit_Redemption__c)){
                deploymentPackageStr = redemptionIdWithCreditSKUMapLocal.get(psCreditRedemptionJunctionObj.PS_Credit_Redemption__c) + ';' + psCreditRedemptionJunctionObj.Professional_Services_Credit__r.PS_Credit_SKU__c;
                redemptionIdWithCreditSKUMapLocal.put(psCreditRedemptionJunctionObj.PS_Credit_Redemption__c, deploymentPackageStr);
            }
            else{
                redemptionIdWithCreditSKUMapLocal.put(psCreditRedemptionJunctionObj.PS_Credit_Redemption__c, psCreditRedemptionJunctionObj.Professional_Services_Credit__r.PS_Credit_SKU__c);
            }
        }
        return redemptionIdWithCreditSKUMapLocal;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of IBA - 1933 : This method will return the Map of Credit Redemption id and the Deployment Project associated with the credit redemption record .
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : getDeploymentProjectIdForRedemption .
    * @param    NAME : List<Id> projectIdList.
    * @return   TYPE : Map<Id,inspire1__Project__c> deploymentProjectWithRedemptionIDMapLocal .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */  
    public static Map<Id,inspire1__Project__c> getDeploymentProjectIdForRedemption(List<Id> projectIdList) {
        Map<Id,inspire1__Project__c> deploymentProjectWithRedemptionIDMapLocal = New  Map<Id,inspire1__Project__c>();
        List<inspire1__Project__c>  deploymentProjectList = new List<inspire1__Project__c>();
        
        deploymentProjectList = [SELECT Id, inspire1__Account__c , Credit_Redemptions__c
                                FROM inspire1__Project__c 
                                WHERE Id IN : projectIdList];
        
        if(!deploymentProjectList.isEmpty()){
            for(inspire1__Project__c deploymentProjectObj :deploymentProjectList){
                deploymentProjectWithRedemptionIDMapLocal.put(deploymentProjectObj.Credit_Redemptions__c,deploymentProjectObj);
            }
        }
        
        return deploymentProjectWithRedemptionIDMapLocal;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of IBA - 1933 : This method will return the Map of Credit Redemption id and the Professional Service Project Project associated with the credit redemption record .
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : getPSPProjectIdForRedemption .
    * @param    NAME : List<Id> projectIdList.
    * @return   TYPE : Map<Id,Professional_Service_Project__c> pspProjectWithRedemptionIDMapLocal .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */  
    public static Map<Id,Professional_Service_Project__c> getPSPProjectIdForRedemption(List<Id> projectIdList) {
        Map<Id,Professional_Service_Project__c> pspProjectWithRedemptionIDMapLocal = New  Map<Id,Professional_Service_Project__c>();
        List<Professional_Service_Project__c>  pspProjectList = new List<Professional_Service_Project__c>();
        
        pspProjectList = [SELECT Id, Related_Inspire_Project_ID__c, Credit_Redemptions__c
                        FROM Professional_Service_Project__c 
                        WHERE Related_Inspire_Project_ID__c IN : projectIdList];
        
        if(!pspProjectList.isEmpty()){
            for(Professional_Service_Project__c pspProjectObj :pspProjectList){
                pspProjectWithRedemptionIDMapLocal.put(pspProjectObj.Credit_Redemptions__c,pspProjectObj);
            }
        }
        
        return pspProjectWithRedemptionIDMapLocal;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of IBA - 1933 : This method will return the Map of Credit Redemption id and the Professional Service Project Project associated with the credit redemption record .
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @Method   NAME : getRedemptionIdWithErrorMessage .
    * @param    NAME : List<Id> projectIdList.
    * @return   TYPE : Map<Id,String> redemptionIdWithErrorMessageMap .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */  
    public static Map<Id,String> getRedemptionIdWithErrorMessage(List<Id> projectIdList) {
        Map<Id,String> redemptionIdWithErrorMessageMap = New  Map<Id,String>();
        List<inspire1__Project__c>  errorDeploymentProjectList = new List<inspire1__Project__c>();
        
        errorDeploymentProjectList = [SELECT Id, inspire1__Account__c , Credit_Redemptions__c
                                    FROM inspire1__Project__c 
                                    WHERE Id IN : projectIdList];
        
        if(!errorDeploymentProjectList.isEmpty()){
            for(inspire1__Project__c errorDeploymentProjectObj :errorDeploymentProjectList){
                redemptionIdWithErrorMessageMap.put(errorDeploymentProjectObj.Credit_Redemptions__c,redemptionIdWithErrorMessageMap.get(errorDeploymentProjectObj.Id));
            }
        }
        
        return redemptionIdWithErrorMessageMap;
    }

    /**
     * @description : IBA-5448 : To get Opportunity to be populated on Project
     * @param : creditRedemptionIds - List of credit Redemption Ids
     * @return Map<Id,OpportunityIdentificationModel> - map of opportunity Identification Model by credit Redemption Id
     */
    public static Map<Id,OpportunityIdentificationModel> getOpportunityIdByCreditRedemptionId(Set<Id> creditRedemptionIds) {
        
        List<PS_Credit_Redemption_Junction__c> customerCreditJunctions = getCustomerCreditJunctions(creditRedemptionIds);

        Map<Id,OpportunityIdentificationModel> opportuniyIdentificationModelByCreditRedemption = new Map<Id,OpportunityIdentificationModel>();
        for( PS_Credit_Redemption_Junction__c customerCreditJunction : customerCreditJunctions) {
            
            OpportunityIdentificationModel currentOpportunityIdentificationModel = new OpportunityIdentificationModel(customerCreditJunction);
            if(opportuniyIdentificationModelByCreditRedemption.containsKey(customerCreditJunction.PS_Credit_Redemption__c)) {
                OpportunityIdentificationModel existingModel = opportuniyIdentificationModelByCreditRedemption.get(customerCreditJunction.PS_Credit_Redemption__c);
                currentOpportunityIdentificationModel = getOpportunityIdentificationModelToBePopulated(existingModel,currentOpportunityIdentificationModel);
            }
            opportuniyIdentificationModelByCreditRedemption.put(customerCreditJunction.PS_Credit_Redemption__c,currentOpportunityIdentificationModel);
        }

        return opportuniyIdentificationModelByCreditRedemption;
    }    

    private static List<PS_Credit_Redemption_Junction__c> getCustomerCreditJunctions(Set<Id> creditRedemptionIds) {
        return [Select  Id,
                        Professional_Services_Credit__r.Credits_Expiration_Date__c,PS_Credit_Credits_Redeemed__c, PS_Credit_Redemption__c,
                        Professional_Services_Credit__c, Professional_Services_Credit__r.Opportunity__c,
                        Professional_Services_Credit__r.Opportunity__r.CreatedDate,  
                        Professional_Services_Credit__r.EE_Credit__c 
                FROM PS_Credit_Redemption_Junction__c 
                WHERE PS_Credit_Redemption__c IN :creditRedemptionIds];
    }
    
    private static OpportunityIdentificationModel getOpportunityIdentificationModelToBePopulated(OpportunityIdentificationModel existingModel, OpportunityIdentificationModel currentModel) {
        
        OpportunityIdentificationModel newopportunityModel = new OpportunityIdentificationModel();        
        if(isCreditsRedeemedEqual(existingModel,currentModel)) {
            
            if(isCreditsExpirationDateEqual(existingModel,currentModel)) {
                newopportunityModel = compareCreationDate(existingModel,currentModel);
            }else{
                newopportunityModel = compareExpirationDate(existingModel,currentModel);
            }
        }else {
            newopportunityModel = compareCreditsRedeemed(existingModel,currentModel);
        }
        return newopportunityModel;
    }

    private static Boolean isCreditsRedeemedEqual(OpportunityIdentificationModel existingModel, OpportunityIdentificationModel currentModel) {
        return existingModel.creditsRedeemed ==  currentModel.creditsRedeemed;
    }

    private static Boolean isCreditsExpirationDateEqual(OpportunityIdentificationModel existingModel, OpportunityIdentificationModel currentModel) {
        return existingModel.creditExpirationDate ==  currentModel.creditExpirationDate;
    }

    private static OpportunityIdentificationModel compareCreditsRedeemed(OpportunityIdentificationModel existingModel, OpportunityIdentificationModel currentModel) {
        return existingModel.creditsRedeemed > currentModel.creditsRedeemed ? existingModel : currentModel;
    }

    private static OpportunityIdentificationModel compareExpirationDate(OpportunityIdentificationModel existingModel, OpportunityIdentificationModel currentModel) {
        return existingModel.creditExpirationDate < currentModel.creditExpirationDate ? existingModel : currentModel;
    }

    private static OpportunityIdentificationModel compareCreationDate(OpportunityIdentificationModel existingModel, OpportunityIdentificationModel currentModel) {
        return existingModel.opportunityCreatedDate <= currentModel.opportunityCreatedDate ? existingModel : currentModel;
    }

    public static Id getOpportunityId(Map<Id,OpportunityIdentificationModel> oppByRedemptionId, Id creditRedemptionId) {
        if(oppByRedemptionId.containsKey(creditRedemptionId)) {
            return oppByRedemptionId.get(creditRedemptionId).OpportunityId;
        }

        return null;
    }

    /**
     * @Description : This class is used as a Model to identify which Opportunity should be populated on 
     */
    public Class OpportunityIdentificationModel {
        public Datetime opportunityCreatedDate;
        public Id opportunityId;
        public Decimal creditsRedeemed;
        public Date creditExpirationDate;

        public OpportunityIdentificationModel() {

        }
        
        public OpportunityIdentificationModel(PS_Credit_Redemption_Junction__c creditRedemptionJunction) {
            this.opportunityCreatedDate = creditRedemptionJunction.Professional_Services_Credit__r.Opportunity__r.CreatedDate;
            this.opportunityId = creditRedemptionJunction.Professional_Services_Credit__r.Opportunity__c;
            this.creditsRedeemed = creditRedemptionJunction.PS_Credit_Credits_Redeemed__c;
            this.creditExpirationDate = creditRedemptionJunction.Professional_Services_Credit__r.Credits_Expiration_Date__c;
        }        
    }

//IBA- 5448 and IBA-6089 END 
    
}