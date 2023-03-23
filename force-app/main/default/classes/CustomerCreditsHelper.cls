/*****************************************************************************************
Name: CustomerCreditsHelper
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Apex Controller for Customer Credit Creation Process.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       10/08/2022      IBA-1932      Customer credits should be created only when the opportunity is closed won for first time.
2.0                Harish Gowda N       04/01/2023      IBA-5447      Create Customer Credit record when early Engagement request is approved.
3.0                Harish Gowda N       04/01/2023      IBA-5449      After opportunity is closed won, update customer credit and Account.
4.0                Harish Gowda N       04/01/2023      IBA-5450      After opportunity is closed lost, update customer credit and Account.
******************************************************************************************/ 

public class CustomerCreditsHelper {
    
    public static final Integer CREDIT_DURATION = 364;
    public static List<String> toAdressList = new List<String>();
    public static List<String> ccAdressList = new List<String>();
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-1932 : to create Customer Credits and prevent creation of Customer credits
when the opportunity is closed more than once.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : createCustomerCredits .
* @param    NAME : List<methodInputs> request .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    @InvocableMethod(label='Create Customer Credit Records On Opportunity Closure' description='Create Customer Credit Records On Opportunity Closure')
    public static void createCustomerCredits(List<methodInputs> request) {
        Map<Id, Boolean> opportunityIdToEECreditMap = New Map<Id, Boolean>();
        for(methodInputs methodInputObj : request){
            opportunityIdToEECreditMap.put(methodInputObj.opportunityId, methodInputObj.eeCredit);
        }
        createCustomerCreditsAndEEcredits(opportunityIdToEECreditMap);
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method helps to capture the input details coming to apex from flow .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : methodInputs .
* @param    NAME : NIL .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    public class methodInputs{
        @InvocableVariable
        public Id opportunityId;
        @InvocableVariable
        public Boolean eeCredit;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this is the main method which helps to Create and update the Customer Credits .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : createCustomerCreditsAndEEcredits .
* @param    NAME : Map<Id, Boolean> opportunityIdToEECreditMap .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void createCustomerCreditsAndEEcredits(Map<Id, Boolean> opportunityIdToEECreditMap){
        try {
            Set<Id> opportunityIdSetForStage6 = new Set<Id>();
            Set<Id> opportunityIdSetWithPsCreditForStage6 = new Set<Id>();
            Set<Id> opportunityIdSetForStage7 = new Set<Id>();
            Set<Id> opportunityIdstoSendEmail = new Set<Id>();
            List<OpportunityLineItem> opportunityproductList = new List<OpportunityLineItem>();
            List<Product_License__c> productLicenseList = new List<Product_License__c>();
            Set<Professional_Services_Credits__c> eeCreditsCreatedSetForSendingEmail = new Set<Professional_Services_Credits__c>();
            List<Professional_Services_Credits__c> customerCreditRecordListToInsert = new List<Professional_Services_Credits__c>();
            List<Professional_Services_Credits__c> trainingCreditListToInsert = new List<Professional_Services_Credits__c>();
            List<Professional_Services_Credits__c> existingCustomerCreditsList = new List<Professional_Services_Credits__c>();
            List<Professional_Services_Credits__c> customerCreditsListToUpdate = new List<Professional_Services_Credits__c>();
            Map<Id, OpportunityLineItem> productIdToOpportunityLineItemMap = new Map<Id, OpportunityLineItem>();
            Map<Id, Opportunity> opportunityIdToOpportunityMapToUpdate = new Map<Id, Opportunity>();
            Map<Id, Opportunity> opportunityIdToOpportunityMap = new Map<Id, Opportunity>();
            Map<String, OpportunityLineItem> productSKUToOpportunityLineItemMap = new Map<String, OpportunityLineItem>();
            Map<Id, String> opportunityIdToAccountNameMap = new Map<Id, String>();
            Boolean eeCreditLocal = false;
            
            opportunityIdToOpportunityMap = getOpportunity(opportunityIdToEECreditMap.keySet());
            for(String opportunityId : opportunityIdToEECreditMap.keySet()){
                eeCreditLocal = opportunityIdToEECreditMap.get(opportunityId);
            }
            if(!opportunityIdToEECreditMap.keySet().isEmpty()){
                //this condition would be called to create EE Credits once the Early Engagement request is Approved.
                if(eeCreditLocal == true){
                    opportunityproductList =  getopportunityproductList(opportunityIdToEECreditMap.keySet(),ZScalarConstants.CREDIT_STRING,'','');
                }
                //this condition would be called to create /or/ update Customer Credits once the Opportunity is closed i.e. either set to Stage 6 /or/ 7.
                else if(eeCreditLocal == false){
                    productSKUToOpportunityLineItemMap = prepareProductSKUToOpportunityLineItemMap(getopportunityproductList(opportunityIdToEECreditMap.keySet(),ZScalarConstants.CREDIT_STRING,ZScalarConstants.TRAINING_CREDIT_STRING,ZScalarConstants.SERVICES_STRING));
                    existingCustomerCreditsList = getExistingCustomerCredits(opportunityIdToEECreditMap.keySet());
                    if(!existingCustomerCreditsList.isEmpty()){
                        opportunityIdstoSendEmail = prepareOpportunityListToSendEmail(existingCustomerCreditsList);
                        sendEarlyEngagementCreditOpportunityClosedEmailNotification(opportunityIdstoSendEmail,opportunityIdToOpportunityMap);
                    }
                    for(Opportunity oppObj : opportunityIdToOpportunityMap.values()){
                        if(oppObj.StageName == ZScalarConstants.Opp_STAGE_6 && oppObj.Customer_Credit_Type__c == Null){
                            opportunityIdSetForStage6.add(oppObj.Id);
                        }
                        else if(oppObj.StageName == ZScalarConstants.Opp_STAGE_6 && oppObj.Customer_Credit_Type__c == ZScalarConstants.PS_CREDIT_RECORDTYPENAME){
                            opportunityIdSetWithPsCreditForStage6.add(oppObj.Id);   
                        }
                        else if(oppObj.StageName == ZScalarConstants.Opp_STAGE_7 && oppObj.Customer_Credit_Type__c != Null){
                            opportunityIdSetForStage7.add(oppObj.Id);   
                        }
                    }
                    if(!opportunityIdSetForStage6.isEmpty()){
                        //this condition would be called to create Customer Credits once the Opportunity is Closed i.e. set to Stage - 6 - Closed - Won.
                        opportunityproductList.addAll(getopportunityproductList(opportunityIdSetForStage6,ZScalarConstants.CREDIT_STRING,ZScalarConstants.TRAINING_CREDIT_STRING,ZScalarConstants.SERVICES_STRING));
                    }
                    if(!opportunityIdSetWithPsCreditForStage6.isEmpty()){
                        //this condition would be called to create the training Credits that were not created on the Early Engagement Request Approval on the Opportunity closure.
                        opportunityproductList.addAll(getopportunityproductList(opportunityIdSetWithPsCreditForStage6,'',ZScalarConstants.TRAINING_CREDIT_STRING,ZScalarConstants.SERVICES_STRING));
                        //this condition would be called to Update the ee Credits that were created once the Opportunity is Closed i.e. set to Stage - 6 - Closed - Won.
                        customerCreditsListToUpdate.addAll(prepareCustomerCreditsListToUpdate(existingCustomerCreditsList,productSKUToOpportunityLineItemMap,opportunityIdToOpportunityMap));
                    }
                    if(!opportunityIdSetForStage7.isEmpty()){
                        //this condition would be called to Update the ee Credits that were created once the Opportunity is Closed i.e. set to Stage - 7 - Closed - Lost .
                        customerCreditsListToUpdate.addAll(prepareCustomerCreditsListToUpdate(existingCustomerCreditsList,productSKUToOpportunityLineItemMap,opportunityIdToOpportunityMap));
                    }
                    //Preparing the Map of Product Id and Opportunity Product which will be used for getting the product licenses associated with the opportunity product.
                    productIdToOpportunityLineItemMap = prepareProductIdToOpportunityLineItemMap(opportunityproductList);
                    //getting all the Product License related to the Products associated to the Opportunities.
                    productLicenseList = getproductLicenseList(productIdToOpportunityLineItemMap.keySet());
                }
                
                if(!opportunityproductList.isEmpty()){
                    customerCreditRecordListToInsert = prepareCustomerCreditListToInsert(opportunityproductList,  opportunityIdToEECreditMap);
                    if(!productLicenseList.isEmpty()){
                        trainingCreditListToInsert = prepareTrainingCreditListToInsert(productLicenseList, productIdToOpportunityLineItemMap);
                        customerCreditRecordListToInsert.addAll(trainingCreditListToInsert);
                    }
                }
                // Inserting the Customer Credits List and U[pdating the Customer Credit Type on the Opportunity record .
                if (!customerCreditRecordListToInsert.isEmpty()) {
                    opportunityIdToOpportunityMapToUpdate = prepareOpportunityIdToOpportunityMap(customerCreditRecordListToInsert, opportunityIdToOpportunityMap.values());
                    DMLManager.insertAsSystem(customerCreditRecordListToInsert);
                    TriggerHandler.bypass('OpportunityTriggerHandler');
                    DMLManager.updateAsSystem(opportunityIdToOpportunityMapToUpdate.values());
                    TriggerHandler.clearBypass('OpportunityTriggerHandler');
                    opportunityIdToAccountNameMap = prepareOpportunityIdtoAccountNameMap(opportunityIdToOpportunityMap.values());
                    eeCreditsCreatedSetForSendingEmail = prepareEECreditsCreatedSetForSendingEmail(customerCreditRecordListToInsert);
                    if (!eeCreditsCreatedSetForSendingEmail.isEmpty()) {
                        sendEarlyEngagementCreditCreatedEmailNotification(eeCreditsCreatedSetForSendingEmail,opportunityIdToAccountNameMap);
                    }
                }
                // Updating the EE Credits on the Opportunity closure .
                if(!customerCreditsListToUpdate.isEmpty()){
                    DMLManager.updateAsSystem(customerCreditsListToUpdate);
                }
            }
        }
        catch (Exception e) {
            ZscalerErrorLogsUtility.insertlogs('CustomerCreditsHelper', 'createCustomerCredits', 'Apex', 
                                               UserInfo.getUserId(), 'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
        }
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to prepare and return the Opportunity object for the Opportunity Id passed .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getOpportunity .
* @param    NAME : Set<Id> opportunityIdSet .
* @return   TYPE : Map<Id, Opportunity> opportunityIdToOpportunityMapToReturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static Map<Id, Opportunity> getOpportunity (Set<Id> opportunityIdSet) {
        Map<Id, Opportunity> opportunityIdToOpportunityMapToReturn = new Map<Id, Opportunity>();
        List<Opportunity> opportunityListToLoop = [SELECT Id, Name, Customer_Credit_Type__c, StageName, CloseDate, Account.Name 
                                                   FROM Opportunity 
                                                   WHERE Id IN: opportunityIdSet];
        for(Opportunity oppObj : opportunityListToLoop){
            opportunityIdToOpportunityMapToReturn.put(oppObj.Id, oppObj);
        }
        return opportunityIdToOpportunityMapToReturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to get the Opportunity Products associated with The Opportunity .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getOpportunityproductList .
* @param    NAME : Set<Id> opportunityIdSet, String psCredit, String trainingCredit, String Services .
* @return   TYPE : List<OpportunityLineItem> opportunityproductListToReturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static List<OpportunityLineItem> getOpportunityproductList (Set<Id> opportunityIdSet, String psCredit, String trainingCredit, String Services) {
        List<OpportunityLineItem> opportunityproductListToReturn = new List<OpportunityLineItem>();
        opportunityproductListToReturn = [SELECT Id, Product2Id, Product_Category_Subtype__c, OpportunityId, ProductCode,
                                          Opportunity.CloseDate, Quantity, Opportunity.AccountId, Opportunity.Name,  
                                          Opportunity.Account.Is_Federal_Account_Sync__c, Opportunity.Account.Geo__c
                                          FROM OpportunityLineItem
                                          WHERE OpportunityId IN: opportunityIdSet
                                          AND (Product_Category_Subtype__c =: psCredit
                                               OR Product_Category_Subtype__c =: trainingCredit
                                               OR Product_Category_Subtype__c =: Services)];
        return opportunityproductListToReturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to get the Product Licenses associated with The Product Id's of the opportunity products .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getproductLicenseList .
* @param    NAME : Set<Id> productId .
* @return   TYPE : List<Product_License__c> productLicenseListToreturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static List<Product_License__c> getproductLicenseList (Set<Id> productId) {
        List<Product_License__c> productLicenseListToreturn = new List<Product_License__c>();
        productLicenseListToreturn = [SELECT Id, Product__c, POV_Quantity__c, License_SKU__c 
                                      FROM Product_License__c 
                                      WHERE Product__c IN :productId
                                      AND Provisioning_License__c =: ZScalarConstants.TRAINING_STRING];
        return productLicenseListToreturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to prepare the ProductId To Opportunity Product Map .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : prepareProductIdToOpportunityLineItemMap .
* @param    NAME : List<OpportunityLineItem> opportunityproductList .
* @return   TYPE : Map<Id, OpportunityLineItem> productIdToOpportunityLineItemMapToReturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static Map<Id, OpportunityLineItem> prepareProductIdToOpportunityLineItemMap (List<OpportunityLineItem> opportunityproductList) {
        Map<Id, OpportunityLineItem> productIdToOpportunityLineItemMapToReturn = new Map<Id, OpportunityLineItem>();
        for(OpportunityLineItem oppProductObj : opportunityproductList){
            //to add the Product Id and the Opportunity Product into the Map to create the Training Credits for Deployment SKU's
            if (oppProductObj.Product2Id != null && oppProductObj.Product_Category_Subtype__c == ZScalarConstants.SERVICES_STRING) {
                productIdToOpportunityLineItemMapToReturn.put(oppProductObj.Product2Id, oppProductObj);
            }
        }
        return productIdToOpportunityLineItemMapToReturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to prepare the Opportunity Id To Opportunity Map which would be used to 
update the Credit Type of the Opportunity .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : prepareOpportunityIdToOpportunityMap .
* @param    NAME : List<Professional_Services_Credits__c> customerCreditRecordListToInsert, List<Opportunity> opportunityList .
* @return   TYPE : Map<Id, Opportunity> opportunityIdToOpportunityMapToReturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static Map<Id, Opportunity> prepareOpportunityIdToOpportunityMap (List<Professional_Services_Credits__c> customerCreditRecordListToInsert, List<Opportunity> opportunityList) {
        Map<Id, Opportunity> opportunityIdToOpportunityMapToReturn = new Map<Id, Opportunity>();
        Map<Id, String> opportunityIdToCustomerCreditTypeMap = new Map<Id, String>();
        for(Opportunity oppObj : opportunityList){
            opportunityIdToCustomerCreditTypeMap.put(oppObj.Id,(String.isBlank(oppObj.Customer_Credit_Type__c)?'':oppObj.Customer_Credit_Type__c));
        }
        //Looping trough the Customer Credits List to prepare the Customer Credit type to update on Opportunity.
        for(Professional_Services_Credits__c customerCreditObj : customerCreditRecordListToInsert){
            if(customerCreditObj.RecordTypeId == ZScalarConstants.PS_CREDIT_RECORDTYPEID){
                String customerCreditType = opportunityIdToCustomerCreditTypeMap.get(customerCreditObj.Opportunity__c);
                opportunityIdToCustomerCreditTypeMap.put(customerCreditObj.Opportunity__c,(customerCreditType.contains(ZScalarConstants.PS_CREDIT_RECORDTYPENAME) ? customerCreditType : customerCreditType+';'+ZScalarConstants.PS_CREDIT_RECORDTYPENAME));
                
            }
            else  if(customerCreditObj.RecordTypeId == ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID){
                String customerCreditType = opportunityIdToCustomerCreditTypeMap.get(customerCreditObj.Opportunity__c);
                opportunityIdToCustomerCreditTypeMap.put(customerCreditObj.Opportunity__c,(customerCreditType.contains(ZScalarConstants.TRAINING_CREDIT_RECORDTYPENAME) ? customerCreditType : customerCreditType+';'+ZScalarConstants.TRAINING_CREDIT_RECORDTYPENAME));    
            }
        }
        //Looping trough the Customer Credits List to prepare the prepare the Opportunity Id To Opportunity Map.
        for(Professional_Services_Credits__c customerCreditObj : customerCreditRecordListToInsert){
            if(customerCreditObj.Opportunity__c != Null && !(opportunityIdToOpportunityMapToReturn.containsKey(customerCreditObj.Opportunity__c))){
                Opportunity opportunityObjNew = new Opportunity();
                opportunityObjNew.Id = customerCreditObj.Opportunity__c;
                opportunityObjNew.Customer_Credit_Type__c = opportunityIdToCustomerCreditTypeMap.get(customerCreditObj.Opportunity__c).removestart(';');
                opportunityIdToOpportunityMapToReturn.put(customerCreditObj.Opportunity__c, opportunityObjNew);
            }
        }
        return opportunityIdToOpportunityMapToReturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to prepare Customer Credits List to insert one each for Opportunity Product .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : prepareCustomerCreditListToInsert .
* @param    NAME : List<OpportunityLineItem> opportunityproductList,  Map<Id, Boolean> opportunityIdToEECreditMap .
* @return   TYPE : List<Professional_Services_Credits__c> customerCreditListToReturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static List<Professional_Services_Credits__c> prepareCustomerCreditListToInsert (List<OpportunityLineItem> opportunityproductList,  Map<Id, Boolean> opportunityIdToEECreditMap) {
        List<Professional_Services_Credits__c> customerCreditListToReturn = new List<Professional_Services_Credits__c>();
        // looping trough all the opportunity products returned via query to create one each Customer Credit record per Opportunity Product.
        for(OpportunityLineItem oppProductObj : opportunityproductList){
            if ((oppProductObj.Product_Category_Subtype__c == ZScalarConstants.CREDIT_STRING && 
                 oppProductObj.Opportunity.Account.Geo__c != L2O_Constants.CustomerCreditsObject.PUBLIC_SECTOR_STRING && 
                 !oppProductObj.Opportunity.Account.Is_Federal_Account_Sync__c) || 
                 (oppProductObj.Product_Category_Subtype__c == ZScalarConstants.TRAINING_CREDIT_STRING && 
                 ((oppProductObj.Opportunity.Account.Geo__c != L2O_Constants.CustomerCreditsObject.PUBLIC_SECTOR_STRING && 
                  !oppProductObj.Opportunity.Account.Is_Federal_Account_Sync__c) || 
                 (oppProductObj.Opportunity.Account.Geo__c == L2O_Constants.CustomerCreditsObject.PUBLIC_SECTOR_STRING && 
                  System.Label.Allow_Training_Credits_Creation_For_Public_Sector_Accounts == ZScalarConstants.TRUE_STRING) || 
               	 (oppProductObj.Opportunity.Account.Is_Federal_Account_Sync__c && 
               	  System.Label.Allow_Training_Credits_Creation_For_Fed_Accounts == ZScalarConstants.TRUE_STRING))))  {
                     
                Professional_Services_Credits__c newCustomerCreditRecordObj = new Professional_Services_Credits__c();       
                newCustomerCreditRecordObj.PS_Credit_Name__c = oppProductObj.Opportunity.Name+ '-' +oppProductObj.ProductCode;
                newCustomerCreditRecordObj.Opportunity__c = oppProductObj.OpportunityId;
                newCustomerCreditRecordObj.Opportunity_Close_Date__c = oppProductObj.Opportunity.CloseDate; 
                newCustomerCreditRecordObj.Credits_Expiration_Date__c =  newCustomerCreditRecordObj.Opportunity_Close_Date__c != null ? newCustomerCreditRecordObj.Opportunity_Close_Date__c.addDays(CREDIT_DURATION) : null;
                newCustomerCreditRecordObj.Credits_Purchased__c = oppProductObj.Quantity;
                newCustomerCreditRecordObj.Credits_Redeemed__c = 0;
                newCustomerCreditRecordObj.PS_Credit_SKU__c = oppProductObj.ProductCode;
                newCustomerCreditRecordObj.Account__c = oppProductObj.Opportunity.AccountId;
                if(oppProductObj.Product_Category_Subtype__c == ZScalarConstants.CREDIT_STRING){
                    newCustomerCreditRecordObj.RecordTypeId = ZScalarConstants.PS_CREDIT_RECORDTYPEID;
                }
                else if(oppProductObj.Product_Category_Subtype__c == ZScalarConstants.TRAINING_CREDIT_STRING){
                    newCustomerCreditRecordObj.RecordTypeId = ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID;
                }
                if(opportunityIdToEECreditMap.get(oppProductObj.OpportunityId) == True){
                    newCustomerCreditRecordObj.EE_Credit__c = True;
                }
                else{
                    newCustomerCreditRecordObj.EE_Credit__c = False;
                }
                /* IBA-6010 START, Added Allow_Training_Credits_Creation_For_Fed_Accounts Custom Label check to toggle the functionality in production
                    as part of Dark Deployment */
                if (newCustomerCreditRecordObj.Account__c != null && System.Label.Allow_Training_Credits_Creation_For_Fed_Accounts == ZScalarConstants.TRUE_STRING) {
                    newCustomerCreditRecordObj.Sync_To_Skilljar__c = !oppProductObj.Opportunity.Account.Is_Federal_Account_Sync__c;
                }
                /* IBA-6010 END */
                customerCreditListToReturn.add(newCustomerCreditRecordObj);
            }
        }
        return customerCreditListToReturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to prepare Training Credits List to insert if there are any Training or Services Product.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : prepareTrainingCreditListToInsert .
* @param    NAME : List<Product_License__c> productLicenseList, Map<Id, OpportunityLineItem> productIdToOpportunityLineItemMap .
* @return   TYPE : List<Professional_Services_Credits__c> trainingCreditListToReturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static List<Professional_Services_Credits__c> prepareTrainingCreditListToInsert (List<Product_License__c> productLicenseList, Map<Id, OpportunityLineItem> productIdToOpportunityLineItemMap) {
        List<Professional_Services_Credits__c> trainingCreditListToReturn = new List<Professional_Services_Credits__c>();
        // loopoing trough  all training product licenses to Create Training credits one each for license.
        for (Product_License__c productLicense : productLicenseList) {
            Professional_Services_Credits__c newTrainingCreditRecord = new Professional_Services_Credits__c();
            newTrainingCreditRecord.PS_Credit_Name__c = (productIdToOpportunityLineItemMap.get(productLicense.Product__c).OpportunityId != null ? 
                                                         productIdToOpportunityLineItemMap.get(productLicense.Product__c).Opportunity.Name : '') + ' - ' + productLicense.License_SKU__c;
            newTrainingCreditRecord.RecordTypeId = ZScalarConstants.TRAINING_CREDIT_RECORDTYPEID;
            newTrainingCreditRecord.Opportunity__c = productIdToOpportunityLineItemMap.get(productLicense.Product__c).OpportunityId;
            newTrainingCreditRecord.Opportunity_Close_Date__c = productIdToOpportunityLineItemMap.get(productLicense.Product__c).OpportunityId != null ? 
                productIdToOpportunityLineItemMap.get(productLicense.Product__c).Opportunity.CloseDate : null;
            newTrainingCreditRecord.Credits_Expiration_Date__c = newTrainingCreditRecord.Opportunity_Close_Date__c != null ? 
                newTrainingCreditRecord.Opportunity_Close_Date__c.addDays(CREDIT_DURATION) : null;
            newTrainingCreditRecord.Credits_Purchased__c = (productLicense.POV_Quantity__c != null ? Integer.valueOf(productLicense.POV_Quantity__c) : 0) * 
                (productIdToOpportunityLineItemMap.get(productLicense.Product__c).Quantity != null ? productIdToOpportunityLineItemMap.get(productLicense.Product__c).Quantity : 0);
            newTrainingCreditRecord.PS_Credit_SKU__c = productLicense.License_SKU__c;
            newTrainingCreditRecord.Account__c = productIdToOpportunityLineItemMap.get(productLicense.Product__c).OpportunityId != null ? 
                productIdToOpportunityLineItemMap.get(productLicense.Product__c).Opportunity.AccountId : null;

            /* IBA-6010 START, Added Allow_Training_Credits_Creation_For_Fed_Accounts Custom Label check to toggle the functionality in production
                as part of Dark Deployment */
            if (newTrainingCreditRecord.Account__c != null && System.Label.Allow_Training_Credits_Creation_For_Fed_Accounts == ZScalarConstants.TRUE_STRING) {
                newTrainingCreditRecord.Sync_To_Skilljar__c = !productIdToOpportunityLineItemMap.get(productLicense.Product__c).Opportunity.Account.Is_Federal_Account_Sync__c;
            }
            /* IBA-6010 END */
            trainingCreditListToReturn.add(newTrainingCreditRecord);
        }
        return trainingCreditListToReturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to get the ExistingCustomerCredits for the Opportunity.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : getExistingCustomerCredits .
* @param    NAME : Set<Id> opportunityIdSet  .
* @return   TYPE : list<Professional_Services_Credits__c> existingCreditsToReturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static List<Professional_Services_Credits__c> getExistingCustomerCredits (Set<Id> opportunityIdSet) {
        list<Professional_Services_Credits__c> existingCreditsToReturn = new List<Professional_Services_Credits__c>();
        existingCreditsToReturn = [SELECT Id, Name, Credits_Expiration_Date__c, Credits_Purchased__c, 
                                   Credits_Redeemed__c, Credits_Remaining__c, EE_Credit__c, Is_Redemption_Valid__c,
                                   Opportunity__c, Opportunity_Close_Date__c, PS_Credit_Name__c, PS_Credit_SKU__c,
                                   RecordType.Name
                                   FROM Professional_Services_Credits__c 
                                   WHERE Opportunity__c IN: opportunityIdSet
                                   AND EE_Credit__c = true
                                   AND RecordType.Name =: ZScalarConstants.PS_CREDIT_RECORDTYPENAME];
        return existingCreditsToReturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to prepare Product SKU To Opportunity Product Map.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : prepareProductSKUToOpportunityLineItemMap .
* @param    NAME : List<OpportunityLineItem> opportunityproductList .
* @return   TYPE : Map<String, OpportunityLineItem> productSKUToOpportunityLineItemMapToReturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static Map<String, OpportunityLineItem>  prepareProductSKUToOpportunityLineItemMap (List<OpportunityLineItem> opportunityproductList) {
        Map<String, OpportunityLineItem> productSKUToOpportunityLineItemMapToReturn = new Map<String, OpportunityLineItem>();
        for(OpportunityLineItem oppProductObj : opportunityproductList){
            productSKUToOpportunityLineItemMapToReturn.put(oppProductObj.ProductCode, oppProductObj);
        }
        return productSKUToOpportunityLineItemMapToReturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to prepare Product SKU To Opportunity Product Map.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : prepareCustomerCreditsListToUpdate .
* @param    NAME : List<Professional_Services_Credits__c> existingCustomerCreditsList, Map<String, OpportunityLineItem> productSKUToOpportunityLineItemMap, Map<Id,Opportunity> opportunityIdToOpportunityMap .
* @return   TYPE : List<Professional_Services_Credits__c> customerCreditsListToReturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static List<Professional_Services_Credits__c> prepareCustomerCreditsListToUpdate (List<Professional_Services_Credits__c> existingCustomerCreditsList, Map<String, OpportunityLineItem> productSKUToOpportunityLineItemMap, Map<Id,Opportunity> opportunityIdToOpportunityMap) {
        List<Professional_Services_Credits__c> customerCreditsListToReturn = new List<Professional_Services_Credits__c>();
        for(Professional_Services_Credits__c eeCreditObjExisting : existingCustomerCreditsList){
            OpportunityLineItem eeOppProductObj = productSKUToOpportunityLineItemMap.get(eeCreditObjExisting.PS_Credit_SKU__c);
            Professional_Services_Credits__c eeCreditObjToUpdate = new Professional_Services_Credits__c();
            eeCreditObjToUpdate.Id = eeCreditObjExisting.Id;
            eeCreditObjToUpdate.EE_Credit__c = false;
            if(opportunityIdToOpportunityMap.get(eeCreditObjExisting.Opportunity__c).StageName == ZScalarConstants.Opp_STAGE_6){
                if(productSKUToOpportunityLineItemMap.containsKey(eeCreditObjExisting.PS_Credit_SKU__c)){
                    if(eeCreditObjExisting.Credits_Purchased__c != eeOppProductObj.Quantity){
                        eeCreditObjToUpdate.Credits_Purchased__c = eeOppProductObj.Quantity;
                    }
                }
                else {
                    eeCreditObjToUpdate.Credits_Purchased__c = 0;
                }
                if(eeCreditObjExisting.Opportunity_Close_Date__c != opportunityIdToOpportunityMap.get(eeCreditObjExisting.Opportunity__c).CloseDate){
                    eeCreditObjToUpdate.Opportunity_Close_Date__c = opportunityIdToOpportunityMap.get(eeCreditObjExisting.Opportunity__c).CloseDate;
                    eeCreditObjToUpdate.Credits_Expiration_Date__c = opportunityIdToOpportunityMap.get(eeCreditObjExisting.Opportunity__c).CloseDate.addDays(CREDIT_DURATION);
                }
            }
            else if(opportunityIdToOpportunityMap.get(eeCreditObjExisting.Opportunity__c).StageName == ZScalarConstants.Opp_STAGE_7){
                eeCreditObjToUpdate.Credits_Purchased__c = 0;
            }
            customerCreditsListToReturn.add(eeCreditObjToUpdate);
        }
        return customerCreditsListToReturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to prepare the Opportunity Id's related to EE Credits
which were closed  and which will be used for sending the emails.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : prepareOpportunityListToSendEmail .
* @param    NAME : List<Professional_Services_Credits__c> existingCustomerCreditsList .
* @return   TYPE : Set<Id> opportunityIdsToreturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static Set<Id> prepareOpportunityListToSendEmail (List<Professional_Services_Credits__c> existingCustomerCreditsList) {
        Set<Id> opportunityIdsToreturn = new Set<Id>();
        for(Professional_Services_Credits__c creditObj : existingCustomerCreditsList){
            opportunityIdsToreturn.add(creditObj.Opportunity__c);
        }
        return opportunityIdsToreturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to prepare Set of EE Credits created for sending emails.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : prepareEECreditsCreatedSetForSendingEmail .
* @param    NAME : List<Professional_Services_Credits__c> customerCreditRecordListToInsert .
* @return   TYPE : Set<Professional_Services_Credits__c> eeCreditsCreatedSetToreturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static Set<Professional_Services_Credits__c> prepareEECreditsCreatedSetForSendingEmail (List<Professional_Services_Credits__c> customerCreditRecordListToInsert) {
        Set<Professional_Services_Credits__c> eeCreditsCreatedSetToreturn = new Set<Professional_Services_Credits__c>();
        for(Professional_Services_Credits__c eeCreditObj : customerCreditRecordListToInsert){
            if(eeCreditObj.RecordTypeId == ZScalarConstants.PS_CREDIT_RECORDTYPEID && eeCreditObj.EE_Credit__c == true){
                eeCreditsCreatedSetToreturn.add(eeCreditObj);
            }
        }
        return eeCreditsCreatedSetToreturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to prepare the Opportunity Id related Account Name Map.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : prepareOpportunityIdtoAccountNameMap .
* @param    NAME : List<Opportunity> opportunityList .
* @return   TYPE : Map<Id, String> opportunityIdToAccountNameMapToreturn .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    private static Map<Id, String> prepareOpportunityIdtoAccountNameMap (List<Opportunity> opportunityList) {
        Map<Id, String> opportunityIdToAccountNameMapToreturn = new Map<Id, String>();
        for(Opportunity optyObj : opportunityList){
            opportunityIdToAccountNameMapToreturn.put(optyObj.Id, optyObj.Account.Name);
        }
        return opportunityIdToAccountNameMapToreturn;
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to prepare Product SKU To Opportunity Product Map.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : sendEarlyEngagementCreditOpportunityClosedEmailNotification .
* @param    NAME : Set<Id> opprtunityIdSet, Map<Id, Opportunity> opportunityIdToOpportunityMap .
* @return   TYPE : Void .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void sendEarlyEngagementCreditOpportunityClosedEmailNotification (Set<Id> opprtunityIdSet,Map<Id, Opportunity> opportunityIdToOpportunityMap) {
        String emailConfig = 'EE_Credit_Opportunity_Closed';
        Opportunity opportunityObjToSendEmail = New Opportunity();
        String Subject;
        toAdressList.add(ZScalarConstants.PS_OPS_TEAM_EMAIL_ADDRESS);
        List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
        EmailUtility emailUtility = new EmailUtility(emailConfig);
        for(String oppurtunityId : opprtunityIdSet){
            opportunityObjToSendEmail = opportunityIdToOpportunityMap.get(oppurtunityId);
            Subject = emailUtility.template.Subject +' '+'"'+opportunityObjToSendEmail.Name+'"'+' '+'-'+'"'+opportunityObjToSendEmail.StageName+'"';
            emailsToBeSent.add(emailUtility.prepareEmailWithCustomSubject(toAdressList,ccAdressList,oppurtunityId,Subject));
        }
        emailUtility.sendEmails(emailsToBeSent);
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA-5447 : this method is used to prepare Product SKU To Opportunity Product Map.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : sendEarlyEngagementCreditCreatedEmailNotification .
* @param    NAME : Set<Professional_Services_Credits__c> eeCreditsCreatedSetForSendingEmail, Map<Id, String> opportunityIdToAccountNameMap.
* @return   TYPE : Void .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/
    public static void sendEarlyEngagementCreditCreatedEmailNotification (Set<Professional_Services_Credits__c> eeCreditsCreatedSetForSendingEmail,Map<Id, String> opportunityIdToAccountNameMap) {
        String emailConfig = 'EE_Credit_Created';
        toAdressList.add(ZScalarConstants.PS_OPS_TEAM_EMAIL_ADDRESS);
        List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
        EmailUtility emailUtility = new EmailUtility(emailConfig);
        for(Professional_Services_Credits__c psCreditObj : eeCreditsCreatedSetForSendingEmail){
            String htmlBody = emailUtility.template.HtmlValue;
            htmlBody = htmlBody.replace('Account Name',  '<a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+psCreditObj.Account__c+'">'+opportunityIdToAccountNameMap.get(psCreditObj.Opportunity__c)+'</a>');
            emailUtility.htmlBody = htmlBody;
            emailsToBeSent.add(emailUtility.prepareEmailWithCustomSubject(toAdressList,ccAdressList,psCreditObj.Id,''));
        }
        emailUtility.sendEmails(emailsToBeSent);
    }
    
}