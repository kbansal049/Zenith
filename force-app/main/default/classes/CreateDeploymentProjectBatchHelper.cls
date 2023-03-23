public class CreateDeploymentProjectBatchHelper {
    public CreateDeploymentProjectBatchHelper() {

    }

    public static final List<String> PROJECT_FAILURE_STATUS = new List<String> {
        L2O_Constants.OpportunityExtensionObject.PROJECT_CREATION_STATUS_FAILED,
        L2O_Constants.OpportunityExtensionObject.PROJECT_CREATION_STATUS_PENDING
    };

    /**
     * @description getOpportunityIds
     * @param  opportunityExtensions opportunityExtensions Opportunity Extension with Opportunity Closed
     * @return                      Valid opportunityId Set
     */
    public static Map<Id,Opportunity_Extension__c> getOpportunityExtensionByOpportunityIdpportunityId(List<Opportunity_Extension__c> opportunityExtensions) {
        Map<Id,Opportunity_Extension__c> opportunityExtensionByOpportunityId = new Map<Id,Opportunity_Extension__c>();
        for(Opportunity_Extension__c opportunityExtension : opportunityExtensions) {
            opportunityExtensionByOpportunityId.put(opportunityExtension.Opportunity__c,opportunityExtension);
        }
        return opportunityExtensionByOpportunityId;
    }

    public static List<OpportunityLineItem> getOpportunityLineItems(Set<Id> opportunityIds) {
        return [SELECT  Id,ProductCode,Quantity,
                        QLI_Start_Date__c,QLI_End_Date__c,
                        Opportunity.Netsuite_Sales_Order_Number__c, 
                        Opportunity.District_Account__c,Opportunity.CloseDate,
                        Opportunity.Opportunity_Number__c,Opportunity.StageName,
                        Opportunity.AccountId,OpportunityId,Opportunity.Name,
                        Opportunity.Total_ZPA_ACV__c,Opportunity.Total_ZIA_ACV__c,
                        Opportunity.Geo_Account__c,Opportunity.Region_Account__c,
                        Opportunity.Area__c,Opportunity.Is_Federal_Opportunity_Sync__c,
                        Opportunity.Account.CSM_Name_New__c, Opportunity.Account.TAM_Name_New__c
                        FROM OpportunityLineItem
                        WHERE OpportunityId IN :opportunityIds
                        AND Product_Category_Subtype__c =: L2O_Constants.OpportunityLineItemObject.PRODUCT_CATEGORY_SUBTYPE_SERVICES ];
    }

    public static Map<Id,List<OpportunityLineItem>> getOpportunitiesWithDeploymentSKU(Map<Id,List<OpportunityLineItem>> opportunityLineItemsByOpportunityId, Map<Id,List<String>> deployemntProjectSKUsByOpportunityId) {
        Map<Id,List<OpportunityLineItem>> opportunitiesWithDeploymentSKU = new Map<Id,List<OpportunityLineItem>>(); 
        for(Id oppId : opportunityLineItemsByOpportunityId.keySet()) {
            for(OpportunityLineItem  lineItem : opportunityLineItemsByOpportunityId.get(oppId)) {
                if(deployemntProjectSKUsByOpportunityId.containsKey(oppId) && deployemntProjectSKUsByOpportunityId.get(oppId).contains(lineItem.ProductCode)) {
                    continue;
                }else{
                    if(!opportunitiesWithDeploymentSKU.containsKey(oppId)) {
                        opportunitiesWithDeploymentSKU.put(oppId,new List<OpportunityLineItem>());
                    }
                    opportunitiesWithDeploymentSKU.get(oppId).add(lineItem);
                }
            }
        }
        return opportunitiesWithDeploymentSKU;
    }

    public static List<Opportunity_Extension__c> updateOppExtensionStatus(
            List<Opportunity_Extension__c> opportunityExtensions,
            Map<Id,List<Inspire1__Project__c>> projectsByOppId, 
            Map<Id,List<OpportunityLineItem>> opportunityLineItemsByOppId 
    ) {
            List<Opportunity_Extension__c> opportunityExtensionsToBeUpdated = new List<Opportunity_Extension__c>();
            for(Opportunity_Extension__c opportunityExtension : opportunityExtensions) {
                
                Id oppId = opportunityExtension.Opportunity__c;
                if(!isProjectCreationNotApplicable(opportunityExtension)) {
                    if(isOpportunityEligibleForProjectCreation(oppId, opportunityLineItemsByOppId)) {
                        if(isProjectCreatedForLineItem(oppId, projectsByOppId)) {
                            if(areProjectsCreatedEqualToLineItems(oppId,projectsByOppId,opportunityLineItemsByOppId)) {
                                opportunityExtension.Project_Creation_Status__c = L2O_Constants.OpportunityExtensionObject.PROJECT_CREATION_STATUS_SUCCESS;
                            }else {
                                opportunityExtension.Project_Creation_Failure_Reason__c =  getProductCodeForWhichProjectCreationFailed(projectsByOppId.get(oppId),opportunityLineItemsByOppId.get(oppId));
                                opportunityExtension.Project_Creation_Status__c = L2O_Constants.OpportunityExtensionObject.PROJECT_CREATION_STATUS_PENDING;
                            }
                        }else {
                            opportunityExtension.Project_Creation_Failure_Reason__c = getProductCodeForWhichProjectCreationFailed(opportunityLineItemsByOppId.get(oppId));
                            opportunityExtension.Project_Creation_Status__c = L2O_Constants.OpportunityExtensionObject.PROJECT_CREATION_STATUS_FAILED;
                        }
                    }
                }
                opportunityExtensionsToBeUpdated.add(opportunityExtension);
            }
        
            return opportunityExtensionsToBeUpdated;
    }

    private static Boolean isProjectCreationNotApplicable(Opportunity_Extension__c opportunityExtension) {
        return opportunityExtension.Project_Creation_Status__c == L2O_Constants.OpportunityExtensionObject.PROJECT_CREATION_STATUS_NOT_APPLICABLE;
    }

    private static Boolean isOpportunityEligibleForProjectCreation(Id oppId, Map<Id,List<OpportunityLineItem>> opportunityLineItemsByOppId) {
        return opportunityLineItemsByOppId !=null && opportunityLineItemsByOppId.containsKey(oppId);
    }

    private static Boolean isProjectCreatedForLineItem(Id oppId, Map<Id,List<Inspire1__Project__c>> projectsByOppId) {
        return projectsByOppId !=null && projectsByOppId.containsKey(oppId);
    }

    private static Boolean areProjectsCreatedEqualToLineItems(
        Id oppId, 
        Map<Id,List<Inspire1__Project__c>> projectsByOppId, 
        Map<Id,List<OpportunityLineItem>> opportunityLineItemsByOppId
        ) {
        
            return projectsByOppId.get(oppId).size() == opportunityLineItemsByOppId.get(oppId).size();
    }

    @TestVisible
    private static String getProductCodeForWhichProjectCreationFailed(List<Inspire1__Project__c> projects, List<OpportunityLineItem> oppLineItems) {
        
        String productCodes = '';
        for(OpportunityLineItem lineItem : oppLineItems) {
            
            Boolean isLineItemPresent = false;
            for(Inspire1__Project__c project : projects) {
                if(project.Deployment_Package__c == lineItem.ProductCode) {
                    isLineItemPresent = true;
                    break;
                }
            }

            if(!isLineItemPresent) {
                productCodes = productCodes + lineItem.ProductCode + ', ';
            }
        }

        return productCodes;
    }

    @TestVisible
    private static String getProductCodeForWhichProjectCreationFailed(List<OpportunityLineItem> oppLineItems) {

        String productCodes = '';
        for(OpportunityLineItem lineItem : oppLineItems) {
            productCodes = productCodes + lineItem.ProductCode + ', ';
        }
        return productCodes;
    }

    public static Set<Id> getOpportunityIdsFailedProjectCreation(List<Opportunity_Extension__c> extensions) {
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity_Extension__c extension : extensions) {
            if(PROJECT_FAILURE_STATUS.contains(extension.Project_Creation_Status__c)) {
                oppIds.add(extension.opportunity__c);
            }
        }
        return oppIds;
    }

    public static Map<Id,List<String>> getOpportunitySKUsByOpportunityId(Map<Id,List<OpportunityLineItem>> opportunityLineItemsByOpportunityId) {
        Map<Id,List<String>> opportunitySKUsByOpportunityId = new Map<Id,List<String>>();
        for(Id oppId : opportunityLineItemsByOpportunityId.keySet()) {
            for(OpportunityLineItem lineItem : opportunityLineItemsByOpportunityId.get(oppId)) {

                if(!opportunitySKUsByOpportunityId.containsKey(oppId)) {
                    opportunitySKUsByOpportunityId.put(oppId,new List<String>{});
                }
                opportunitySKUsByOpportunityId.get(oppId).add(lineItem.ProductCode);
            }
        }

        return opportunitySKUsByOpportunityId;
    }

    /**
     * @description notifyUsersOfError - sends emails to user about Opportunity failed project creation
     * @param  opportunityIds Set<Id> 
     * @param  msg            String
     */
    public static void notifyUsersOfError(Set<Id> opportunityIds,String msg) {
        
        String emailConfig = 'Project_Creation_Failed';
        List<Messaging.SingleEmailMessage> emailsToBeSend = new List<Messaging.SingleEmailMessage>();
        EmailUtility emailUtility = new EmailUtility(emailConfig);
        
        for(Id opportunityId : opportunityIds) {
            emailUtility.htmlBody = prepareEmailBody(emailUtility.template,msg);
            emailsToBeSend.add(emailUtility.prepareEmail(opportunityId,''));
        }
        emailUtility.sendEmails(emailsToBeSend);
    }
    
    private static String prepareEmailBody(EmailTemplate template, String msg) {
        String emailTemplateBody = template.HtmlValue;
        emailTemplateBody = emailTemplateBody.replace('{reason}',msg);
        emailTemplateBody = emailTemplateBody.replace(']]>','');
        return emailTemplateBody;
    }

    /**
     * @description insertDebugLogs - Creates ZScaler Logs for opportunity failed Deployment Project creation.
     * @param  opportunityIds Set<Id>
     * @param  ex             ex 
     */
    public static void insertDebugLogs(Set<Id> opportunityIds,Exception ex) {
        if(ex == null) {
            return;
        }
        ZscalerErrorLogsUtility.insertLogsForAsync('OpportunityClosedWonTriggerHelper', 'createDeploymentProjectsWithPSQuestionnaires',
                                                   'Apex', null,
                                                   'Sales Cloud', ex.getStackTraceString() +' '+ ex.getCause() + ' '+ ex.getMessage(), 
                                                   'Project Creation failed Opp: '+ opportunityIds, ex.getTypeName());
        System.debug('opportunityIds Failed creation: ' +opportunityIds);
    }

}