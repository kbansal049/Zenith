public class ZScalarConstants {
    
    public static string Opp_RecType_Name_New_Business_Close = 'New Business Close';
    public static string Opp_RecType_Name_Upsell_Opportunity_Closed = 'Upsell Opportunity Closed';
    public static string Opp_RecType_Name_New_Business = 'New Business';
    public static string Opp_RecType_Name_Upsell_Opportunity = 'Upsell Opportunity';
    public static string Opp_RecType_Name_Renewal_Opportunity = 'Renewal Opportunity';
       
    public static string Opp_RecType_Id_New_Business_Close = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Opp_RecType_Name_New_Business_Close).getRecordTypeId();
    public static string Opp_RecType_Id_Upsell_Opportunity_Closed = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Opp_RecType_Name_Upsell_Opportunity_Closed).getRecordTypeId();
    public static string Opp_RecType_Id_New_Business = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Opp_RecType_Name_New_Business).getRecordTypeId();
    public static string Opp_RecType_Id_Upsell_Opportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Opp_RecType_Name_Upsell_Opportunity).getRecordTypeId();
    public static string Opp_RecType_Id_Renewal_Opportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Opp_RecType_Name_Renewal_Opportunity).getRecordTypeId();
    
    public static string Opp_Type_New_Business = 'New Business';
    public static string Opp_Type_Existing_Customer_Add_On = 'Existing Customer (Add On)';
    public static string Opp_Type_Existing_Customer_Renewal = 'Existing Customer (Renewal)';
    
    public static string Opp_LeadSource_Advertisement = 'Advertisement';
    public static string Opp_LeadSource_Webinars = 'Webinars';
    public static string Opp_LeadSource_Events = 'Events';
    public static string Opp_LeadSource_External_DM = 'External DM';
    public static string Opp_LeadSource_List_Import = 'List Import';
    public static string Opp_LeadSource_Search = 'Search';
    public static string Opp_LeadSource_Paid_Search = 'Paid Search';
    public static string Opp_LeadSource_Website_Direct = 'Website Direct';
    public static string Opp_LeadSource_Website_Referral = 'Website Referral';
    public static string Opp_LeadSource_Social_Media = 'Social Media';
    public static string Opp_LeadSource_Content_Syndication = 'Content Syndication';
    public static string Opp_LeadSource_Publisher = 'Publisher';
    public static string Opp_LeadSource_Telemarketing = 'Telemarketing';
    public static string Opp_LeadSource_Marketing_Campaign = 'Marketing Campaign';
    public static string Opp_LeadSource_Deal_Registration = 'Deal Registration';
    public static string Opp_LeadSource_Partners = 'Partners';
    public static string Opp_LeadSource_Service_Provider = 'Service Provider';
    public static string Opp_LeadSource_Sales_Generated = 'Sales Generated';
    
    public static string Opp_Validation_Stage_6_Technical_Win = '6 - Technical Win';
    public static string Opp_Validation_Stage_7_Technical_Loss = '7 - Technical Loss';
    public static string Opp_Validation_Stage_1_Establishing_Plan_sucess_criteria = '1 - Establishing Plan & success criteria';
    public static string Opp_Validation_Stage_2_Configuration_in_Progress = '2 - Configuration in Progress';
    public static string Opp_Validation_Stage_3_Detailed_validation_in_progress = '3 - Detailed validation in progress';
    public static string Opp_Validation_Stage_4_Delivering_validation_findings_report = '4 - Delivering validation findings report';
    public static string Opp_Validation_Stage_8_Not_Required = '8 - Not Required';
    public static string Opp_Validation_Stage_8B_Not_Required_Preferred = '8B - Not Required - Preferred';
    public static string Opp_Validation_Stage_0_Not_Started = '0 - Not Started';
    
    //Opportunity Stage Contant Value .
    public static string Opp_STAGE_1 = '1 - Discovery & Qualification	';
    public static string Opp_STAGE_2 = '2 - Architecture & Alignment';
    public static string Opp_STAGE_3 = '3 - Sponsorship';
    public static string Opp_STAGE_4 = '4 - Impact Validation';
    public static string Opp_STAGE_5 = '5 - Procurement';
    public static string Opp_STAGE_5A = '5A - Submitted for Order Review';
    public static string Opp_STAGE_5B = '5B - In Process with Finance';
    public static string Opp_STAGE_5C = '5C - Sales Rep Action Required';
    public static string Opp_STAGE_5D = '5D - Approved, awaiting processing';
    public static string Opp_STAGE_6 = '6 - Closed Won';
    public static string Opp_STAGE_7 = '7 - Closed Lost';
    
    public static string Value_Creation_Stage_Qualified = 'Qualified';
    public static string Value_Creation_Stage_Interview_Scheduled = 'Interview Scheduled';
    public static string Value_Creation_Stage_Interview_Completed = 'Interview Completed';
    public static string Value_Creation_Stage_Model_Completed = 'Model Completed';
    public static string Value_Creation_Stage_Output_Presented = 'Output Presented';
    public static string Value_Creation_Stage_Stalled = 'Stalled';
    public static string Value_Creation_Stage_Customer_declined_presentation = 'Customer declined presentation';
    public static string Value_Creation_Stage_RSM_Withdrew_Post_Qualified = 'RSM Withdrew Post-Qualified';
    
    public static string QUIP_DOCUMENT_EMAIL_TEMPLATE = 'PS_Onboarding_Document_Generated_Template_for_Opportunities';
    public static string QUIP_DOCUMENT_EMAIL_TEMPLATE_STAGE5 = 'PS_Onboarding_Document_Generated_Template_for_Opportunities_Of_Stage_5';

    public static final String PROJECT_RT_DEPLOYMENT_PROJECT = 'Deployment_Project';
    public static final String PROJECT_RT_ZCP_SPECIALIST_SERVICES = 'ZCP_Specialist_Services';

    public static final String PROJECT_STATUS_COMPLETED = 'Completed';

    public static final String PROFILE_SYSTEM_ADMINISTRATOR = 'System Administrator';
    public static final String PROFILE_CORE_SALES = 'Core Sales';

    public static final String ROLE_IT_BUSINESS_SYSTEMS = 'IT/Business Systems';
    public static final String ROLE_CUSTOMER_EXPERIENCE_AND_TRANSFORMATION = 'Customer Experience and Transformation';
    
    //Skill Jar Related Constant Values
    public static final string TRAINING_CODE_STRING = 'Training_Code';
    public static final string TRAINING_CODE_UPDATE_STRING = 'Training_Code_Update';
    public static final string PS_CREDIT_RECORDTYPENAME = 'Professional Service Credits';
    public static final string TRAINING_CREDIT_RECORDTYPENAME = 'Training Credits';
    public static final string PS_OFFERING_RECORDTYPENAME = 'Professional Service Offerings';
    public static final string TRAINING_OFFERING_RECORDTYPENAME = 'Training Offerings';
    public static final string ZS_ERROR_LOG_INPROGRESS_STATUS_VALUE = 'In Progress';
    public static final string PS_CREDIT_RECORDTYPEID = Schema.SObjectType.Professional_Services_Credits__c.getRecordTypeInfosByName().get(PS_CREDIT_RECORDTYPENAME).getRecordTypeId();
    public static final string TRAINING_CREDIT_RECORDTYPEID = Schema.SObjectType.Professional_Services_Credits__c.getRecordTypeInfosByName().get(TRAINING_CREDIT_RECORDTYPENAME).getRecordTypeId();
    public static final string PS_OFFERING_RECORDTYPEID = Schema.SObjectType.PS_Offering__c.getRecordTypeInfosByName().get(PS_OFFERING_RECORDTYPENAME).getRecordTypeId();
    public static final string TRAINING_OFFERING_RECORDTYPEID = Schema.SObjectType.PS_Offering__c.getRecordTypeInfosByName().get(TRAINING_OFFERING_RECORDTYPENAME).getRecordTypeId();
    public static final string SKILLJAR_STUDENT_WELCOME_EMAIL_TEMPLATE = 'SkillJar_Student_Welcome_Email_Template';
    public static final string TRAINING_CREDIT_INSERT_EMAIL_TEMPLATE = 'Training_Credit_insert_Email_Template_New';
    public static final string ZCES_EDU_CREDIT_SKU = 'ZCES-EDU-CREDIT';
    public static final string PS_REDEMPTION_RECORDTYPENAME = 'Professional Service Redemption';
    public static final string PS_REDEMPTION_RECORDTYPEID = Schema.SObjectType.PS_Credit_Redemption__c.getRecordTypeInfosByName().get(PS_REDEMPTION_RECORDTYPENAME).getRecordTypeId();
    public static final string TRAINING_REDEMPTION_RECORDTYPENAME = 'Training Redemption';
    public static final string TRAINING_REDEMPTION_RECORDTYPEID = Schema.SObjectType.PS_Credit_Redemption__c.getRecordTypeInfosByName().get(TRAINING_REDEMPTION_RECORDTYPENAME).getRecordTypeId();
    public static final string CREDIT_STRING = 'Credit';
    public static final string TRAINING_CREDIT_STRING = 'Training Credit';
    public static final string SERVICES_STRING = 'Services';
    public static final string TRAINING_STRING = 'Training';
    public static final String PS_CREDIT_INSERT_EMAIL_TEMPLATE = 'Notification_For_Opportunity_Closed_With_PS_Credit';
    public static final String ATTACK_SURFACE_DISCOVERY_REPORT_PS_OFFERING = 'Attack_Surface_Discovery_Report';
    public static final string ATTACK_SURFACE_DISCOVERY_REPORT_EMAIL_TEMPLATE = 'Attack_Surface_Discovery_Report_Email_Template';
    public static final string SUPPORT_NO_REPLY_EMAIL_ADDRESS = 'support-noreply@zscaler.com';
    public static final string PROJECT_CREATION_STATUS_PENDING = 'Pending';
    public static final string PROJECT_CREATION_STATUS_NOT_APPLICABLE = 'Not Applicable';
    public static final string PROJECT_CREATION_STATUS_SUCCESS = 'Success';
    public static final string PROJECT_CREATION_STATUS_FAILED = 'Failed';
    public static final String EE_CREDIT_OPPORTUNITY_CLOSED_EMAIL_NOTIFICATION_TEMPLATE = 'Early_Engagement_Credit_Opportunity_Closed_Email_Notification';
    public static final string PS_OPS_TEAM_EMAIL_ADDRESS = 'z-ps-ops-team@zscaler.com';
	
    // IBA-6010 START
    public static final String TRUE_STRING = 'true';
    public static final String EMPTY_STRING = '';

    public static final String ACCOUNT_CUSTOM_FIELD_API_NAME = 'Account__c';
    // IBA-6010 END

    // IBA-6527 START
    public static final String CONTACT_ID_PREFIX = Schema.SObjectType.Contact.getKeyPrefix();
    public static final String LEAD_ID_PREFIX = Schema.SObjectType.Lead.getKeyPrefix();

    public static final String INSERT_STRING = 'INSERT';
    public static final String UPDATE_STRING = 'UPDATE';

    public static final String CONTACT_OBJECT_API_NAME = 'Contact';

    public static final String LOCALE_EN_US = 'en_US';
    // IBA-6527 END
    
    /*public ZScalarConstants(){
        Opp_RecType_Id_New_Business_Close = [Select Id,Name From RecordType where sobjecttype = 'Opportunity' And Name = :Opp_RecType_Name_New_Business_Close].Id;
        Opp_RecType_Id_Upsell_Opportunity_Closed = [Select Id,Name From RecordType where sobjecttype = 'Opportunity' And Name = :Opp_RecType_Name_Upsell_Opportunity_Closed].Id;
        Opp_RecType_Id_New_Business = [Select Id,Name From RecordType where sobjecttype = 'Opportunity' And Name = :Opp_RecType_Name_New_Business].Id;
        Opp_RecType_Id_Upsell_Opportunity = [Select Id,Name From RecordType where sobjecttype = 'Opportunity' And Name = :Opp_RecType_Name_Upsell_Opportunity].Id;
        Opp_RecType_Id_Renewal_Opportunity = [Select Id,Name From RecordType where sobjecttype = 'Opportunity' And Name = :Opp_RecType_Name_Renewal_Opportunity].Id;
    }*/
    
}