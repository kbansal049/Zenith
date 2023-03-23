/*****************************************************************************************
Name: L2O_ConstantsTest
Copyright © Zscaler
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
Purpose:
--------
1. It is a test class for Constant class : L2O_Constants .
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Sachin Tandon        13/12/2022      IBA-5150  
******************************************************************************************/ 

@IsTest
public class L2O_ConstantsTest {

    private static final String ASSERT_MSG = 'Constants match';
    @IsTest
    static void verifyConstants() {
        
        //Add new Sub classes here
        L2O_Constants.Module module = L2O_Constants.Module;
        L2O_Constants.PSOnboarding psOnboarding = L2O_Constants.PSOnboarding;
        L2O_Constants.OpportunityObject opportunityObject = L2O_Constants.OpportunityObject;
        L2O_Constants.InspireProject planner = L2O_Constants.InspireProject;
        L2O_Constants.ErrorLog errorLog = L2O_Constants.ErrorLog;
        L2O_Constants.PlannerGenericUserAssignment user = L2O_Constants.PlannerGenericUserAssignment;
        L2O_Constants.CustomerCreditsObject customerCreditObject = L2O_Constants.CustomerCreditsObject;
        L2O_Constants.EmailTemplateInfo emailTemplateInfo = L2O_Constants.EmailTemplateInfo;
        L2O_Constants.OpportunityExtensionObject oppExtension = L2O_Constants.OpportunityExtensionObject;
        L2O_Constants.OpportunityLineItemObject oppLineItem = L2O_Constants.OpportunityLineItemObject;
        L2O_Constants.ProductInfo product = L2O_Constants.ProductInfo;
        L2O_Constants.NodeConfigurationObject nodeConfigurationObject = L2O_Constants.NodeConfigurationObject;
        L2O_Constants.DataCenterObject dataCenterObject = L2O_Constants.DataCenterObject;
        L2O_Constants.AccountType AccountType = L2O_Constants.AccountType;
        L2O_Constants.LeadObject leadObject = L2O_Constants.LeadObject;
        L2O_Constants.TaskObject taskObject = L2O_Constants.TaskObject;
        L2O_Constants.CampaignObject campaignObject = L2O_Constants.CampaignObject;
        L2O_Constants.ContactObject contactObject = L2O_Constants.ContactObject;
        L2O_Constants.AccountObject accountObject = L2O_Constants.AccountObject;
        L2O_Constants.SalesTerritoryObject salesTerritoryObject = L2O_Constants.SalesTerritoryObject;
        
        //Add Asserts here for above variables
        System.assertEquals('ZPA', psOnboarding.RT_ZPA,ASSERT_MSG);
        System.assertEquals('ZIA', psOnboarding.RT_ZIA,ASSERT_MSG);
        System.assertEquals('Deployment_Project', planner.RT_DEPLOYMENT_PROJECT,ASSERT_MSG);
        System.assertEquals('CreateDeploymentBatch', module.CREATE_DEPLOYMENT_BATCH,ASSERT_MSG);
        System.assertEquals('New_Business_Open', opportunityObject.RT_NEW_BUSINESS_OPEN,ASSERT_MSG);
        System.assertEquals('Apex', errorLog.APEX,ASSERT_MSG);
        System.assertEquals('Generic Consultant', user.USERNAME_GENERIC_CONSULTANT,ASSERT_MSG);
        System.assertEquals('Public Sector', customerCreditObject.PUBLIC_SECTOR_STRING, ASSERT_MSG);
        System.assertEquals('Training_Credit_Insert_Email_Template_For_Fed_Accounts', emailTemplateInfo.TRAINING_CREDIT_EMAIL_TEMPLATE_FOR_FED_ACCOUNTS, ASSERT_MSG);
        System.assertEquals('{!Professional_Services_Credits__c.Account__c}', emailTemplateInfo.PROFESSIONAL_SERVICE_CREDITS_ACCOUNT_MERGE_FIELD, ASSERT_MSG);
        System.assertEquals('Pending',oppExtension.PROJECT_CREATION_STATUS_PENDING,ASSERT_MSG);
        System.assertEquals('Services',oppLineItem.PRODUCT_CATEGORY_SUBTYPE_SERVICES,ASSERT_MSG);
        System.assertEquals('ZCES-EDU-CREDIT',product.ZCES_EDU_CREDIT_PRODUCT_CODE,ASSERT_MSG);
        System.assertEquals('Load_Balancer_Only', nodeConfigurationObject.RT_LOAD_BALANCER_ONLY, ASSERT_MSG);
        System.assertEquals('HW-3', dataCenterObject.RHM_HW3, ASSERT_MSG);
        System.assertEquals('Customer', AccountType.ACCOUNT_TYPE_CUSTOMER, ASSERT_MSG);
        System.assertEquals('Advertisement', leadObject.LEAD_SOURCE_ADVERTISEMENT, ASSERT_MSG);
        System.assertEquals('Completed', taskObject.TASK_STATUS_COMPLETED, ASSERT_MSG);
        System.assertEquals('Marketing', campaignObject.RT_MARKETING, ASSERT_MSG);
        System.assertEquals('Actively Engaged', leadObject.LEAD_STATUS_ACTIVELY_ENGAGED, ASSERT_MSG);
        System.assertEquals('Pending Marketing Qualification', leadObject.LEAD_STATUS_PENDING_MARKETING_QUALIFICATION, ASSERT_MSG);
        System.assertEquals('Recycled to Marketing', leadObject.LEAD_STATUS_RECYCLED_TO_MARKETING, ASSERT_MSG);
        System.assertEquals('Disqualified', leadObject.LEAD_STATUS_DISQUALIFIED, ASSERT_MSG);
        System.assertEquals('Marketing Qualified: Sales Untouched', leadObject.LEAD_STATUS_MQL_SALES_UNTOUCHED, ASSERT_MSG);
        System.assertEquals('SAL: Sales Connected Lead', leadObject.LEAD_STATUS_SAL_SALES_CONNECTED_LEAD, ASSERT_MSG);
        System.assertEquals('Accepted', leadObject.LEAD_STATUS_ACCEPTED, ASSERT_MSG);
        System.assertEquals('Meeting Scheduled', leadObject.LEAD_STATUS_MEETING_SCHEDULED, ASSERT_MSG);
        System.assertEquals('Marketo', leadObject.MARKETO_STRING, ASSERT_MSG);
        System.assertEquals('Lead', leadObject.LEAD_STRING, ASSERT_MSG);
        System.assertEquals('EMEA', leadObject.LEAD_AREA_EMEA, ASSERT_MSG);
        System.assertEquals('Execute_ContOrLead_RelatedTask', leadObject.TRIGGER_SWITCH_EXECUTE_CONTACT_LEAD_RELATED_TASK, ASSERT_MSG);
        System.assertEquals('Completed', taskObject.TASK_STATUS_COMPLETED, ASSERT_MSG);
        System.assertEquals('In Progress', taskObject.TASK_STATUS_IN_PROGRESS, ASSERT_MSG);
        System.assertEquals('Call', taskObject.TASK_SUBJECT_CALL, ASSERT_MSG);
        System.assertEquals('US North Central', salesTerritoryObject.AREA_US_NORTH_CENTRAL, ASSERT_MSG);
        System.assertEquals('US Federal', salesTerritoryObject.AREA_US_FEDERAL, ASSERT_MSG);
        System.assertEquals('US Central', salesTerritoryObject.REGION_US_CENTRAL, ASSERT_MSG);
        System.assertEquals('General Business', salesTerritoryObject.TERRITORY_TYPE_GENERAL_BUSINESS, ASSERT_MSG);
        System.assertEquals('AMERICAS', salesTerritoryObject.GEO_AMERICAS, ASSERT_MSG);
        System.assertEquals('ContactTriggerHelper', contactObject.CONTACT_TRIGGER_HELPER_STRING, ASSERT_MSG);
        System.assertEquals('AccountTriggerHandler', accountObject.ACCOUNT_TRIGGER_HANDLER_NAME, ASSERT_MSG);
    }
}