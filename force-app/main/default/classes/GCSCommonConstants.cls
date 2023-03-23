public with sharing class GCSCommonConstants {
    
    /*---- Case Object -- Start ----*/

    //Case Record Types -- Start
    public static final String CASE_SUPPORT_RECORD_TYPE_NAME = 'Support';
    public static final String CASE_EXPERIENCE_PROJECT_RECORD_TYPE_NAME = 'Experience_Project';
    public static final String CASE_SALES_OPS_RECORD_TYPE_NAME = 'Sales';
    public static final String CASE_DSAT_TICKET_RECORD_TYPE_NAME = 'DSAT_Ticket';
    public static final String CASE_ESCALATION_RECORD_TYPE_NAME = 'Escalation';
    //Case Record Types

    //Case Field Sets -- Start
    public static final String CASE_ESCALATION_HISTORY_CREATION_FIELDSET_NAME = 'Escalation_History_Creation';
    public static final String CASE_TAM_MEETING_HISTORY_FIELDSET_NAME = 'Case_TAM_Meeting_History_Set';
    //Case Field Sets

    //Case Type field -- Start
    public static final String CASE_TYPE_PROBLEM = 'Problem';
    public static final String CASE_TYPE_QUESTION = 'Question';
    public static final String CASE_TYPE_CATEGORIZATION = 'Categorization';
    public static final String CASE_TYPE_PROVISIONING = 'Provisioning';
    public static final String CASE_TYPE_PROVISIONING_REQUEST = 'Provisioning Request';
    //Case Type field -- End

    //Case Status field -- Start
    public static final String CASE_STATUS_NEW = 'New';
    public static final String CASE_STATUS_REOPEN = 'Re-Open';
    public static final String CASE_STATUS_RESEARCHING = 'Researching';
    public static final String CASE_STATUS_AWAITING_FIX = 'Awaiting Fix';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_CLOSED_RESOLVED = 'Closed - Resolved';
    public static final String CASE_STATUS_CLOSED_NO_ACTION = 'Closed - No Action';
    public static final String CASE_STATUS_CLOSED_NO_RESP = 'Closed - No Response';
    public static final String CASE_STATUS_CLOSED_DUPLICATE = 'Closed - Duplicate';
    public static final String CASE_STATUS_CUSTOMER_NOTE_ADDED = 'Customer Note Added';
    public static final String CASE_STATUS_ESCALATED_TO_ENGINEERING = 'Escalated to Engineering';
    public static final String CASE_STATUS_CUSTOMER_CALLBACK_SCHEDULED = 'Customer Callback Scheduled';
    public static final String CASE_STATUS_CUSTOMER_FOLLOW_UP_SCHEDULED = 'Customer Follow Up Scheduled';
    public static final String CASE_STATUS_PENDING_CUSTOMER = 'Pending Customer';
    public static final String CASE_STATUS_PENDING_FIX_VERIFICATION = 'Pending Fix Verification';
    public static final String CASE_STATUS_NEEDS_FOLLOW_UP = 'Needs Follow Up';
    public static final String CASE_STATUS_SLA_VIOLATED = 'SLA Violated';
    public static final String CASE_STATUS_RESOLVED = 'Resolved';
    //Case Status field -- End

    //Case Priority field -- Start
    public static final String CASE_PRIORITY_URGENT = 'Urgent (P1)';
    public static final String CASE_PRIORITY_HIGH = 'High (P2)';
    public static final String CASE_PRIORITY_MEDIUM = 'Medium (P3)';
    public static final String CASE_PRIORITY_LOW = 'Low (P4)';
    //Case Priority field -- End

    //Case Origin field -- Start
    public static final String CASE_ORIGIN_API = 'API';
    public static final String CASE_ORIGIN_SITEREVIEW = 'Sitereview';
    public static final String CASE_ORIGIN_PUBLIC_FORM = 'Public Form';
    public static final String CASE_ORIGIN_SUPPORT_PORTAL = 'Support Portal';
    public static final String CASE_ORIGIN_CHATBOT_PORTAL = 'Chatbot Portal';
    public static final String CASE_ORIGIN_PARTNER_PORTAL = 'Partner Portal';
    public static final String CASE_ORIGIN_PUBLIC_FORM_POST_REQ = 'Public Form - POST Request';
    public static final String CASE_ORIGIN_INT_AGENT = 'Internal Agent';
    public static final String CASE_ORIGIN_SERVICE_CONSOLE = 'Service Console';
    public static final String CASE_ORIGIN_SLACK_APP = 'Slack App';
    //Case Origin field -- End

    //Case Product field -- Start
    public static final String CASE_PRODUCT_ZIA = 'ZIA';
    public static final String CASE_PRODUCT_ZPA = 'ZPA';
    public static final String CASE_PRODUCT_CSPM = 'CSPM';
    public static final String CASE_PRODUCT_ZCSPM = 'ZCSPM';
    public static final String CASE_PRODUCT_ZWS = 'ZWS';
    public static final String CASE_PRODUCT_ZSCALER_DECEPTION = 'Zscaler Deception';
    public static final String CASE_PRODUCT_CLOUD_CONNECTOR = 'Cloud Connector';
    public static final String CASE_PRODUCT_ZPC = 'ZPC';
    public static final String CASE_PRODUCT_ZCC = 'Zscaler Client Connector';
    public static final String CASE_PRODUCT_PLATINUM = 'Platform';
    public static final String CASE_PRODUCT_BRANCH_CONNECTOR = 'Branch Connector';
    //Case Product field -- End

    //Case Product Type field -- Start
    public static final String CASE_PRODUCT_TYPE_ZPA = CASE_PRODUCT_ZPA;
    public static final String CASE_PRODUCT_TYPE_NON_ZPA = 'Non ZPA';
    public static final String CASE_PRODUCT_TYPE_ZCC = 'ZCC';
    //Case Product Type field -- End

    //Case - Case Source field -- Start
    public static final String CASE_CASE_SOURCE_INTEGRATION = 'Integration';
    //Case - Case Source field -- End

    //Case Priority Support field -- Start
    public static final String CASE_PRIORITY_SUPPORT_BACKLINE = 'Backline';
    public static final String CASE_PRIORITY_SUPPORT_P1 = 'P1';
    public static final String CASE_PRIORITY_SUPPORT_P2_P4 = 'P2-P4';
    //Case Priority Support field -- End

    //Case Overflow Support field -- Start
    public static final String CASE_OVERFLOW_SUPPORT_NO_OVERFLOW = 'No Overflow';
    //Case Overflow Support field -- End

    //Case Work Item field -- Start
    public static final String CASE_WORK_ITEM_PROGRESS_IN_PROGRESS = 'In-Progress';
    public static final String CASE_WORK_ITEM_PROGRESS_COMPLETED = 'Completed';
    //Case Work Item field -- End

    //Case TAM Unassigned Reason field -- Start
    public static final String CASE_TAM_UNASSIGNED_REASON_CASE_PRIORITY_P1_P4 = 'Case Priority - P1/P4';
    public static final String CASE_TAM_UNASSIGNED_REASON_CASE_TYPE_PROV_CAT = 'Case Type - Provisioning/Categorization';
    public static final String CASE_TAM_UNASSIGNED_REASON_NON_WORKING_HRS = 'Non Working Hours';
    public static final String CASE_TAM_UNASSIGNED_REASON_QUOTA_EXHAUSTED = 'Quota Exhausted';
    public static final String CASE_TAM_UNASSIGNED_REASON_TAM_OOO = 'TAM Out of Office';
    //Case TAM Unassigned Reason field -- End

    //Case - Case Category field -- Start
    public static final String CASE_CASE_CATEGORY_PROVISIONING_REQ = 'Provisioning Request';
    //Case - Case Category field -- End

    //Case - Case TAM Assignment field -- Start
    public static final String CASE_CASE_TAM_ASSIGNMENT_AUTO_ASSGN = 'Auto Assignment';
    //Case - Case TAM Assignment field -- End

    //Case - Case Resolution State field -- Start
    public static final String CASE_CASE_RESOLUTION_STATE_NOT_RESOLVED = 'Not Resolved';
    public static final String CASE_CASE_RESOLUTION_STATE_RESOLVED = 'Resolved';
    public static final String CASE_CASE_RESOLUTION_STATE_WORKAROUND_PROVIDED = 'Workaround Provided';
    //Case - Case Resolution State field -- End

    //Case Automated Trigger Reason field -- Start
    public static final String CASE_AUTO_TRIGGER_REASON_CUST_NOTE_ADDED_P1_CASE = 'Customer Note Added for a P1 Case';
    public static final String CASE_AUTO_TRIGGER_REASON_DEFCON_ESC_ON_CASE = 'DEFCON Escalation occurred on case';
    public static final String CASE_AUTO_TRIGGER_REASON_CUST_NOTE_ADDED_OWNER_INACTIVE = 'Customer note added & Case owner is OOO/Inactive';
    //Case Automated Trigger Reason field -- End

    //Case - Defcon Automation Reason field -- Start
    public static final String CASE_DEFCON_AUTO_REASON_DEFCON_LEVEL_CHANGED = 'Defcon Level Changed';
    public static final String CASE_DEFCON_AUTO_REASON_DEFCON_OWNER_CHANGED = 'Defcon Owner Changed';
    public static final String CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_0_VIOLATED = 'Auto Esc Lev 0 Violated';
    public static final String CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_1_VIOLATED = 'Auto Esc Lev 1 Violated';
    public static final String CASE_DEFCON_AUTO_REASON_AUTO_ESC_LEV_2_VIOLATED = 'Auto Esc Lev 2 Violated';
    public static final String CASE_DEFCON_AUTO_REASON_DEFCON_ASSIGNED_TO_MANAGER = 'Defcon assigned to Manager';
    public static final String CASE_DEFCON_AUTO_REASON_FOLLOW_UP_SLA_VIOLATED = 'Follow Up SLA Violated';
    public static final String CASE_DEFCON_AUTO_REASON_OWNERSHIP_SLA_VIOLATED = 'Ownership SLA Violated';
    //Case - Defcon Automation Reason field -- End

    //Case - Escalation Level field -- Start
    public static final String CASE_ESCALATION_LEVEL_LEVEL_0 = 'Level 0';
    public static final String CASE_ESCALATION_LEVEL_LEVEL_1 = 'Level 1';
    public static final String CASE_ESCALATION_LEVEL_LEVEL_2 = 'Level 2';
    //Case - Escalation Level field -- End

    //Case - Customer Segment field -- Start
    public static final String CASE_CUSTOMER_SEGMENT_PLATINUM = 'Platinum';
    //Case - Customer Segment field -- End

    //Case Skills -- Start
    public static final String CS_CASE_SKILL = 'CS';
    public static final String JAPAN_CASE_SKILL = 'Japan';
    public static final String ALL_REGIONS_CASE_SKILL = 'All Regions';
    public static final String PLATINUM_CASE_SKILL = 'Platinum';
    public static final String PREMIUM_CASE_SKILL = 'Premium';
    public static final String PREMIUM_PLUS_CASE_SKILL = 'Premium Plus';
    //Case Skills -- End

    //Case - Contact Time Slot field -- Start
    public static final String CASE_CONTACT_TIME_SLOT = '12:00 - 14:00';
    //Case - Contact Time Slot field -- End
    
    //Support Offering SKU's -- Start
    public static final String IN_COUNTRY_SUPPORT_SKU = 'ZCES-SUP-PREM-IN-CTRY';
    public static final String DEDICATED_TAM_SUPPORT_SKU = 'ZCES-SUP-DED-TAM';
    //Support Offering SKU's -- End

    //Support Types -- Start
    public static final String STANDARD = 'Standard';
    public static final String PREMIUM_SUPPORT = 'Premium Support';
    public static final String WITH_DEDICATED_TAM = ' with Dedicated TAM';
    public static final String PREMIUM_SUPPORT_PLUS = 'Premium Support Plus';
    public static final String PREMIUM_SUPPORT_PLUS_IN_COUNTRY = 'Premium Support Plus - In Country';
    //Support Types -- End

    //Support Offerings -- Start
    public static final String UNITED_STATES = 'United States';
    public static final String USA_ENGLISH = 'United States';
    //Support Offerings -- End

    //CaseMilestone Name field -- Start
    public static final String CASE_MILESTONE_SUBSEQUENT = 'Subsequent';
    public static final String CASE_MILESTONE_FIRST_RESPONSE = 'First Response';
    public static final String CASE_MILESTONE_OWNERSHIP_SLA = 'Ownership SLA';
    public static final String CASE_MILESTONE_FOLLOW_UP_SLA = 'Follow up SLA';
    public static final String CASE_MILESTONE_AUTO_ESC_SLA = 'Auto Esc SLA';
    //CaseMilestone Name field -- End

    //Queue.DeveloperName field -- Start
    public static final String Q_DEV_NAME_SUPPORT_QUEUE = 'Support_Queue';
    public static final String Q_DEV_NAME_ZPA_PRODUCT_QUEUE = 'ZPA_Product_Queue';
    public static final String Q_DEV_NAME_ZPC_SUPPORT_QUEUE = 'ZPC_Support_Queue';
    public static final String Q_DEV_NAME_ZWS_SUPPORT_QUEUE = 'ZWS_Support_Queue';
    public static final String Q_DEV_NAME_DEFCON_ESCALATION_QUEUE = 'Defcon_Escalation_Queue';
    public static final String Q_DEV_NAME_IN_COUNTRY_USA_SUPPORT_QUEUE = 'In_Country_USA_Support_Queue_Id';
    public static final String Q_DEV_NAME_IN_COUNTRY_USA_DEFCON_QUEUE = 'In_Country_USA_Defcon_Queue_Id';
    //Queue.DeveloperName field -- -- End

    //Queue.Name field -- Start
    public static final String Q_NAME_SUPPORT_QUEUE = 'Support Queue';
    public static final String Q_NAME_ZPA_SUPPORT_QUEUE = 'ZPA Support Queue';
    public static final String Q_NAME_ZPC_SUPPORT_QUEUE = 'ZPC Support Queue';
    public static final String Q_NAME_ZWS_SUPPORT_QUEUE = 'ZWS Support Queue';
    public static final String Q_NAME_DEFCON_ESCALATION_QUEUE = 'Defcon Escalation Queue';
    public static final String Q_NAME_IN_COUNTRY_USA_SUPPORT_QUEUE = 'In Country USA Support Queue Id';
    public static final String Q_NAME_IN_COUNTRY_USA_DEFCON_QUEUE = 'In Country USA Defcon Queue Id';
    //Queue.Name field -- -- End

    // Case Defcon Level - Start
    public static final String CASE_DEFCON_LEVEL_1 = '1';
    public static final String CASE_DEFCON_LEVEL_2 = '2';
    public static final String CASE_DEFCON_LEVEL_3 = '3';
    public static final String CASE_DEFCON_LEVEL_4 = '4';
    public static final String CASE_DEFCON_LEVEL_5 = '5';
    // Case Defcon Level - End

    //Common Constants -- Start
    public static final String STARTS_WITH_005 = '005';
    public static final String STARTS_WITH_00G = '00G';
    public static final String EMPTY_STRING = '';
    public static final String COMMA_STRING = ',';
    public static final String SEMI_COLON_STRING = ';';
    public static final String AT_THE_RATE_STRING = '@';
    public static final String CASE_STRING = 'Case';
    public static final String DUTY_MANAGER_STRING = 'Duty Manager';
    public static final String TAC_STRING = 'TAC';
    public static final String DM_STRING = 'DM';
    public static final String PRIOR_FRT_VIOLATION_WARNING_MSG = 'FRT SLA Violated';
    public static final String TAC_TIME_FORMAT = 'EEE, yyyy-MM-dd HH:mm:ss';
    public static final String ASIA_KOLKATA_TIME_ZONE = 'Asia/Kolkata';
    public static final String AMERICA_LA_TIME_ZONE = 'America/Los_Angeles';
    public static final String DATETIME_DATABASE_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'';
    public static final String CASE_TAM_ASSIGNMENT_AS_AUTO_ASSIGNMENT = 'Auto Assignment';
    public static final String CASE_PRIOR_OWNER_AS_AUTO_ASSIGNMENT = 'Auto_Assignment';
    public static final String CASE_PRIOR_OWNER_AS_CUSTOMER_OR_INT_USER = 'Customer (OR) Integration User';
    public static final String DML_EXCEPTION_ERROR_TYPE = 'System.DmlException';
    public static final String EMAIL_EXCEPTION_ERROR_TYPE = 'System.EmailException';
    public static final String APEX_TEST_PASS = 'Pass';
    public static final String APEX_TEST_FAIL = 'Fail';
    public static final String ALL_USERS_VISIBILITY = 'AllUsers';
    public static final String INTERNAL_USERS_VISIBILITY = 'InternalUsers';
    public static final String ZSCALER_DOMAIN = '@zscaler.com';
    public static final String LANGUAGE_ENCODING_AS_EN_US = 'en_US';
    public static final String EMAIL_ENCODING_AS_UTF_8 = 'UTF-8';
    public static final String ZS_SUPPORT_EMAIL_ID = 'support@zscaler.com';
    public static final String ZS_SUPPORT_NO_REPLY_EMAIL_ID = 'support-noreply@zscaler.com';
    public static final String ZS_TAC_IND_LEAD_EMAIL_ID = 'z-tac-ind-leads@zscaler.com';
    public static final String ZS_GCS_TAC_LEADERS_EMAIL_ID = 'z-gcs-tac-leaders@zscaler.com';
    public static final String ZS_SALESFORCE_EMAIL_ID = 'z-salesforce@zscaler.com';
    //Common Constants -- End

    //Integer Constants -- Start
    public static final Integer INTEGER_0 = 0;
    public static final Integer INTEGER_1 = 1;
    public static final Integer INTEGER_2 = 2;
    public static final Integer INTEGER_5 = 5;
    public static final Integer INTEGER_24 = 24;
    public static final Integer INTEGER_48 = 48;
    public static final Integer INTEGER_60 = 60;
    public static final Integer INTEGER_1000 = 1000;
    //Integer Constants -- End
    
    //Quota Management Constants - Start
    public static final String DAY_MONDAY = 'Mon';
    public static final String DAY_FRIDAY = 'Fri';
    public static final String DAY_SUNDAY = 'Sun';
    public static final String DAY_SATURDAY = 'Sat';
    //Quota Management Constants - End

    //Error Log Constants -- Start
    public static final String BIZ_AREA_AS_SERVICE_CLOUD = 'Service Cloud';
    public static final String ERROR_IN_AS_APEX = 'APEX';
    //Error Log Constants -- End

    //Email Template Names -- Start
    public static final String DEFCON_CURRENT_STATUS_NEXT_PLAN_UPD_EMAIL_TEMPLATE = 'Defcon_Current_Status_Next_Plan_Of_Action_Update_Email_Template_1669778137290';
    //Email Template Names -- End

    // ---- Test Case Trigger Common - Start
    public static final String TEST_SUPPORT_CASE_SUBJECT = 'Test Support Case';
    public static final String TEST_SALES_OPS_CASE_SUBJECT = 'Test Sales Ops Case';
    public static final String TEST_ESCALATION_CASE_SUBJECT = 'Test Escalation Case';
    public static final String TEST_ACCOUNT_NAME = 'GCS Test Account';
    public static final String TEST_CONTACT_LAST_NAME = 'GCS Test Contact Last Name';
    public static final String TEST_CONTACT_FIRST_NAME = 'GCS Test Contact First Name';
    public static final String TEST_USER_EMAIL = '2xyz@xyz.com';
    // ---- Test Case Trigger Common - End
    
    /*---- Case Object - End ----*/

    /*---- Case Integration Object - Start ----*/

    //Case Integration - Case Incident Type field -- Start
    public static final String CASE_INT_INCIDENT_TYPE_INCIDENT = 'Incident';
    public static final String CASE_INT_INCIDENT_TYPE_COMPLAINT = 'Complaint';
    //Case Integration - Case Incident Type field -- End

    /*---- Case Integration Object - End ----*/

    /*---- Action Plan Object - Start ----*/

    //Action Plan - Status field -- Start
    public static final String ACTION_PLAN_STATUS_COMPLETED = 'Completed';
    public static final String ACTION_PLAN_STATUS_CLOSED = 'Closed';
    public static final String ACTION_PLAN_STATUS_CANCELLED = 'Cancelled';
    //Action Plan - Status field -- End

    /*---- Action Plan Object - End ----*/

    /*---- Survey Object - Start ----*/

    //Survey Record Types -- Start
    public static final String CSAT_SURVEY_RECORD_TYPE_NAME = 'CSAT_Survey';
    //Survey Record Types

    /*---- Survey Object - End ----*/

    /*----ServiceResource Object - Start ----*/

    //ServiceResource Field - Type - Start ---
    public static final String SERVICE_RESOURCE_TYPE_TAM = 'TAM';
    public static final String SERVICE_RESOURCE_TYPE_BACKLINE = 'Backline';
    public static final String SERVICE_RESOURCE_TYPE_FRONTLINE = 'Frontline';
    //ServiceResource Field - Type - End ---

    //ServiceResource Field - ResourceType - Start ---
    public static final String SERVICE_RESOURCE_RESOURCETYPE_A = 'A';
    //ServiceResource Field - ResourceType - End ---
    
    /*----ServiceResource Object - End ----*/

    /*----Shift Object - Start ----*/

     //Shift Field - Product - Start ---
     public static final String SHIFT_PRODUCT_ZPA = CASE_PRODUCT_ZPA;
     public static final String PRODUCT_ZIA = 'ZIA';
     public static final String PRODUCT_ZPA = CASE_PRODUCT_ZPA;
     public static final String SHIFT_PRODUCT_ZIA_ZPA = 'ZIA+ZPA';
    //Shift Product field - End

    //Shift Segment field - Start
    public static final String SEGMENT_PREMIUM = 'Premium';
    public static final String SEGMENT_PREMIUM_PLUS = 'Premium Plus';
    //Shift Segment field - End
     
    //Shift Field - Type__c - Start
     public static final String TYPE_DUTY_MANAGER = 'Duty Manager';
     public static final String TYPE_ENGINEER = 'Engineer';
     public static final String SHIFT_TYPE_DUTY_MANAGER = 'Duty Manager';
    //Shift Field - Type - End

     //Shift Type field - Start
    public static final String TYPE_REGULAR = 'Regular';
    public static final String TYPE_RECURRING = 'Recurring';
    //Shift Type field - End
     
    //Shift Common Constants - Start
    public static final String TIME_SLOT_TYPE_EXTENDED = 'Extended';

    public static final String SHIFT_TYPE_P1 = 'P1';
    public static final String SHIFT_TYPE_P1_P4 = 'P1-P4';
    public static final String SHIFT_TYPE_P2_P4 = 'P2-P4';
    public static final String SHIFT_TYPE_RECURRING = 'Recurring';
    public static final String SHIFT_TYPE_BACKLINE = 'Backline';
    public static final String SHIFT_TYPE_WEEKEND = 'Weekend';

    public static final String SHIFT_TYPE_P1_P4_API = 'P1_P4';
    public static final String SHIFT_TYPE_P2_P4_API = 'P2_P4';

    public static final String SHIFT_STATUS_CONFIRMED = 'Confirmed';

    public static final String AGENT_STATUS_OVERFLOW = 'Overflow';
    public static final String AGENT_STATUS_BACKLOG = 'Backlog';
    public static final String AGENT_STATUS_QUOTA_MET = 'Quota_Met';
    public static final String AGENT_STATUS_ON_A_WEB_CASE = 'On_a_Web_Case';
    public static final String AGENT_STATUS_NO_CHANGE = 'No_Change';
    public static final String AGENT_STATUS_AVAILABLE_NOCHANGE = 'Available_NoChange';
    //Shift Common Constants - End

    /*----Shift Object - End ----*/

    /*----Service Appointment Object - Start ----*/

    //Service Appointment Common Constants - Start
    public static final String SUPPORT_MEETING_STATUS_CANCELED = 'Canceled';
    //Service Appointment Common Constants - End

    /*----Service Appointment Object - End ----*/

    /*----User Object - Start ----*/

    //USER Field - SERVICE LEVEL - Start ---
    public static final String USER_SERVICE_LEVEL_TAM = 'TAM';
    //USER Field - SERVICE LEVEL - END ---
    
    //User Level -- Start
    public static final String EXEC_USER_LEVEL = 'EXEC';
    public static final String VP_USER_LEVEL = 'VP';
    public static final String RVP_USER_LEVEL = 'RVP';
    public static final String SR_RVP_USER_LEVEL = 'Sr.RVP';
    public static final String DIRECTOR_USER_LEVEL = 'Director';
    //User Level -- End

    //Profile Names -- Start
    public static final String PARTNER_COMMUNITY_USER_PROFILE_NAME = 'Partner Community User';
    public static final String ZS_PARTNER_COMMUNITY_USER_PROFILE_NAME = 'Zscaler Partner Community User';
    public static final String CUSTOMER_COMMUNITY_USER_PROFILE_NAME = 'Customer Community User Profile';
    //Profile Names -- End

    /*----User Object - End ----*/

    /*---- Account Object -- Start ----*/

    //Account Record Types -- Start
    public static final String ACCOUNT_PARTNER_RECORD_TYPE_NAME = 'Partner';
    //Account Record Types -- End

    //Account Type -- Start
    public static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    //Account Type -- End

    //Account Prospect Type -- Start
    public static final String PROSPECT_TYPE_POC = 'POC';
    //Account Prospect Type -- End

    /*---- Account Object -- End ----*/
}