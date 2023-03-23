/*****************************************************************************************
Name: L2O_Constants
Copyright © Zscaler
__________________________________________________________________________________________
__________________________________________________________________________________________
Purpose:
--------
1. It is a Constant class and all developers should refer it in main class.
__________________________________________________________________________________________
__________________________________________________________________________________________
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Sachin Tandon        13/12/2022      IBA-5150  
******************************************************************************************/ 


/* Add Developer Notes here :
__________________________________________________________________________________________

 * Please use getRecordTypeInfosByDeveloperName() instead of getRecordTypeInfosByName to fetch recordtypeIds;
 * Append 'Object' at the end of Standard Object Name. Ex : Opportunity -> OpportunityObject
 * If User adds a new class.Please update the test class L2O_ConstantsTest

__________________________________________________________________________________________
*/
public class L2O_Constants {

    /*
	 * Declare all the variables here which will be called from another class.
     */
    public static Module Module {
        get {
            return Module == null ? (Module = new Module()) : Module;
        }
        private set;
    }
    
    public static PSOnboarding PSOnboarding {
        get {
            return PSOnboarding == null ? (PSOnboarding = new PSOnboarding()) : PSOnboarding;
        }
        private set;
    }
    
    public static OpportunityObject OpportunityObject {
        get {
            return OpportunityObject == null ? (OpportunityObject = new OpportunityObject()) : OpportunityObject;
        }
        private set;
    }

    public static OpportunityLineItemObject OpportunityLineItemObject {
        get {
            return OpportunityLineItemObject == null ? (OpportunityLineItemObject = new OpportunityLineItemObject()) : OpportunityLineItemObject;
        }
        private set;
    }

    public static OpportunityExtensionObject OpportunityExtensionObject {
        get {
            return OpportunityExtensionObject == null ? (OpportunityExtensionObject = new OpportunityExtensionObject()) : OpportunityExtensionObject;
        }
        private set;
    }
    
    public static InspireProject InspireProject {
        get {
            return InspireProject == null ? (InspireProject = new InspireProject()) : InspireProject;
        }
        private set;
    }

    public static PlannerGenericUserAssignment PlannerGenericUserAssignment {
        get {
            return PlannerGenericUserAssignment == null ? (PlannerGenericUserAssignment = new PlannerGenericUserAssignment()) : PlannerGenericUserAssignment;
        }
        private set;
    }
    
    public static ErrorLog ErrorLog {
        get {
            return ErrorLog == null ? (ErrorLog = new ErrorLog()) : ErrorLog;
        }
        private set;
    }
    
    // IBA-6010 START
    public static CustomerCreditsObject CustomerCreditsObject {
        get {
            return CustomerCreditsObject == null ? (CustomerCreditsObject = new CustomerCreditsObject()) : CustomerCreditsObject;
        }
        private set;
    }

    public static EmailTemplateInfo EmailTemplateInfo {
        get {
            return EmailTemplateInfo == null ? (EmailTemplateInfo = new EmailTemplateInfo()) : EmailTemplateInfo;
        }
        private set;
    }

    public static ProductInfo ProductInfo {
        get {
            return ProductInfo == null ? (ProductInfo = new ProductInfo()) : ProductInfo;
        }
        private set;
    }
    // IBA-6010 END

    // IBA-2983 START
    public static NodeConfigurationObject NodeConfigurationObject {
        get {
            return NodeConfigurationObject == null ? (NodeConfigurationObject = new NodeConfigurationObject()) : NodeConfigurationObject;
        }
        private set;
    }

    public static DataCenterObject DataCenterObject {
        get {
            return DataCenterObject == null ? (DataCenterObject = new DataCenterObject()) : DataCenterObject;
        }
        private set;
    }
    // IBA-2983 END

    // IBA-6872 START
    public static LeadObject LeadObject {
        get {
            return LeadObject == null ? (LeadObject = new LeadObject()) : LeadObject;
        }
        private set;
    }

    public static TaskObject TaskObject {
        get {
            return TaskObject == null ? (TaskObject = new TaskObject()) : TaskObject;
        }
        private set;
    }
    // IBA-6872 END
    
    public static AccountType AccountType {
        get {
            return AccountType == null ? (AccountType = new AccountType()) : AccountType;
        }
        private set;
    }

    // IBA-6527 START
    public static SalesTerritoryObject SalesTerritoryObject {
        get {
            return SalesTerritoryObject == null ? (SalesTerritoryObject = new SalesTerritoryObject()) : SalesTerritoryObject;
        }
        private set;
    }
    // IBA-6527 END
    
    public static CampaignObject CampaignObject {
        get {
            return CampaignObject == null ? (CampaignObject = new CampaignObject()) : CampaignObject;
        }
        private set;
    }
    
    public static ContactObject ContactObject {
        get {
            return ContactObject == null ? (ContactObject = new ContactObject()) : ContactObject;
        }
        private set;
    }

    public static AccountObject AccountObject {
        get {
            return AccountObject == null ? (AccountObject = new AccountObject()) : AccountObject;
        }
        private set;
    }
    
    /*
	 * Define all the classes with the Variables inside the class.
	 * Prototype of a class :
	 *  public Class <ClassName> 
     */
    
    public class Module {
        
        public final String CREATE_DEPLOYMENT_BATCH = 'CreateDeploymentBatch';
        public final String  PS_REVAMP_PROJECT = 'PS_Revamp_Project';
    }
    
    public class PSOnboarding {
        
        public final String RT_ZIA = 'ZIA';
        public final String RT_ZPA = 'ZPA';
        public final String RT_PS_ONBOARDING = 'PS_Onboarding';
        
        
          public final Id RT_ZIA_ID = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(RT_ZIA).getRecordTypeId();
          public final Id RT_ZPA_ID = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(RT_ZPA).getRecordTypeId();
          public final Id RT_PS_ONBOARDING_ID = Schema.SObjectType.PS_Questionnaire__c.getRecordTypeInfosByDeveloperName().get(RT_PS_ONBOARDING).getRecordTypeId();
    }
    
    public class InspireProject {
        
        public final String RT_DEPLOYMENT_PROJECT = 'Deployment_Project';
        
        public final Id RT_DEPLOYMENT_PROJECT_ID = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(RT_DEPLOYMENT_PROJECT).getRecordTypeId();
        
        public final String FIELDSET_PROJECT_HISTORY_TRACKING_FIELDS = 'Project_History_Tracking_Fields';
    }
    
    public class OpportunityObject {
        
        public final String RT_NEW_BUSINESS_OPEN = 'New_Business_Open';
        
        public final String PROJECT_TYPE_DEPLOYMENT = 'Deployment';
        
        public Final string Opp_STAGE_0 = '0 - pipeline generation';
		public Final string Opp_STAGE_1 = '1 - Discovery & Qualification';        
        public final String STAGE_CLOSED_WON = '6 - Closed Won';
        public final String STAGE_CLOSED_LOST = '7 - Closed Lost';
        
        public final Id RT_NEW_BUSINESS_OPEN_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RT_NEW_BUSINESS_OPEN).getRecordTypeId();
        public final Map<Id, Schema.RecordTypeInfo> recordTypeIdToRecordTypeInfoMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
    }

    public class PlannerGenericUserAssignment {
        public final String USERNAME_GENERIC_CONSULTANT = 'Generic Consultant';
        public final String USERNAME_GENERIC_PM = 'Generic PM';
    }

    public class ErrorLog {
        public final String APEX = 'Apex';
        public final String BIZ_AREA = 'Sales cloud';
        public final String ERROR_IN = 'Apex';

        public final String CLASS_PS_PSREDEMPTIONSCREENCONTROLLER = 'PS_PSRedemptionScreenController';
    }

    public class OpportunityExtensionObject {
        public final String PROJECT_CREATION_STATUS_NOT_APPLICABLE = 'Not Applicable';
        public final String PROJECT_CREATION_STATUS_PENDING = 'Pending';
        public final String PROJECT_CREATION_STATUS_SUCCESS = 'Success';
        public final String PROJECT_CREATION_STATUS_FAILED = 'Failed';
    }

    public class OpportunityLineItemObject {
        public final String PRODUCT_CATEGORY_SUBTYPE_SERVICES = 'Services';
    }
    
    // IBA-6010 START
    public class CustomerCreditsObject {
        public final String PUBLIC_SECTOR_STRING = 'Public Sector';
    }

    public class EmailTemplateInfo {
        public final String TRAINING_CREDIT_EMAIL_TEMPLATE_FOR_FED_ACCOUNTS = 'Training_Credit_Insert_Email_Template_For_Fed_Accounts';

        public final String TRAINING_CREDITS_CREATED_EMAIL_CONFIG = 'Training_Credits_Created';
        public final String CTM_NO_LONGER_AT_COMPANY_EMAIL_CONFIG = 'CTM_No_Longer_At_Company_Notification';
        public final String TRAINING_CREDITS_CREATED_FOR_FED_ACCOUNT_EMAIL_CONFIG = 'Training_Credits_Created_For_Fed_Account';

        public final String PROFESSIONAL_SERVICE_CREDITS_ACCOUNT_MERGE_FIELD = '{!Professional_Services_Credits__c.Account__c}';
        public final String CONTACT_NAME_MERGE_FIELD = '{!Contact.Name}';
    }

    public class ProductInfo {
        public final String ZCES_EDU_CREDIT_PRODUCT_CODE = 'ZCES-EDU-CREDIT';
        public final String ZCES_PRO_CREDITS_PRODUCT_CODE = 'ZCES-PRO-CREDITS';
    }
    // IBA-6010 END

    // IBA-2983 START
    public class NodeConfigurationObject {
        public final String RT_LOAD_BALANCER_ONLY = 'Load_Balancer_Only';
        public final String RT_SI_HTTP_ZEN = 'SI_HTTP_ZEN';
        public final String RT_SERVICE_EDGE = 'Service_Edge';
        public final String RT_PRIVATE_ZEN_WITH_LB = 'Private_ZEN_with_LB';
        public final String RT_SERVICE_EDGE_5_LB = 'Service_Edge_5_LB';

        public final String STATUS_PENDING_SHIPMENT = 'Pending Shipment';
        public final String STATUS_PENDING_DEPLOYMENT = 'Pending Deployment';

        public final String ET_PENDING_SHIPMENT = 'Node_Configuration_Pending_Shipment_Email';
        public final String ET_PENDING_DEPLOYMENT = 'Node_Configuration_Pending_Deployment_Email';
        public final String SR_SHIPPING_NODE_CONFIG = 'Shipping_Node_Config';
    }

    public class DataCenterObject {
        public final String RHM_SERVICE_EDGE_3 = 'ZIA – Service Edge 3';
        public final String RHM_SERVICE_EDGE_5 = 'ZIA – Service Edge 5';
        public final String RHM_HW3 = 'HW-3';
        public final String RHM_HW6 = 'HW-6';
        public final String RHM_HW1 = 'HW-1 (Replacement Only)';
    }
    // IBA-2983 END

    // IBA-6872 START
    public class LeadObject {
        public final String LEAD_SOURCE_ADVERTISEMENT = 'Advertisement';
        public final String LEAD_STATUS_ACTIVELY_ENGAGED = 'Actively Engaged';
        public final String LEAD_STATUS_PENDING_MARKETING_QUALIFICATION = 'Pending Marketing Qualification';
        public final String LEAD_STATUS_RECYCLED_TO_MARKETING = 'Recycled to Marketing';
        public final String LEAD_STATUS_DISQUALIFIED = 'Disqualified';
        public final String LEAD_STATUS_MQL_SALES_UNTOUCHED = 'Marketing Qualified: Sales Untouched';
        public final String LEAD_STATUS_SAL_SALES_CONNECTED_LEAD = 'SAL: Sales Connected Lead';
        public final String LEAD_STATUS_ACCEPTED = 'Accepted';
        public final String LEAD_STATUS_MEETING_SCHEDULED = 'Meeting Scheduled';
        public final String MARKETO_STRING = 'Marketo';
        public final String LEAD_STRING = 'Lead';
        public final String LEAD_AREA_EMEA = 'EMEA';
        public final String TRIGGER_SWITCH_EXECUTE_CONTACT_LEAD_RELATED_TASK = 'Execute_ContOrLead_RelatedTask';
    }

    public class TaskObject {
        public final String TASK_STATUS_COMPLETED = 'Completed';
        public final String TASK_STATUS_IN_PROGRESS = 'In Progress';
        public final String TASK_SUBJECT_CALL = 'Call';
    }
    // IBA-6872 END

    // IBA-6527 START
    public class SalesTerritoryObject {
        public final String AREA_US_NORTH_CENTRAL = 'US North Central';
        public final String AREA_US_FEDERAL = 'US Federal';
        public final String REGION_US_CENTRAL = 'US Central';
        public final String TERRITORY_TYPE_GENERAL_BUSINESS = 'General Business';
        public final String GEO_AMERICAS = 'AMERICAS';
    }
    // IBA-6527 END
    
    public class AccountType{
        public final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
        public final String ACCOUNT_TYPE_PROSPECT = 'Prospect';
        public final String ACCOUNT_TYPE_EX_CUSTOMER = 'Ex-Customer';
    }
    
    public class CampaignObject {
        public final String RT_MARKETING = 'Marketing';
    }

    public class ContactObject {
        public final String CONTACT_TRIGGER_HELPER_STRING = 'ContactTriggerHelper';
    }

    public class AccountObject {
        public final String ACCOUNT_TRIGGER_HANDLER_NAME = 'AccountTriggerHandler';
    }
}