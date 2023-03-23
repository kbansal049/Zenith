public without sharing class ManageRecursive {

    // Variable to count the no of times Triggers are called 
    public static integer timesOpportunityTriggerInvoked=0;
    public static integer timesAccountTriggerInvoked=0;
    public static Integer timesOpportunityExtensionInvoked = 0;
    public static Integer timesCampaignTriggerInvoked = 0;
    public static Integer timesLeadTriggerInvoked = 0;
    public static Integer timesCampaignMemberInvoked = 0;
    public static Integer timesMyWorkCenterInvoked = 0;
    public static Integer timesfocusPartnerTriggerInvoked = 0;
    public static Integer timesPartnerProspTriggerInvoked = 0;

    // Variable to Hold Processed Record Ids
    public static Set<Id> processedOpptyIds = new Set<Id>();
    public static Set<Id> processedOpportunityIds = new Set<Id>(); // To hold Opportunity Ids  called by MasterTriggerHandler

    public static Set<Id> processedAccIds = new Set<Id>();
    public static Set<Id> processedAccountIds = new Set<Id>(); // To hold Account Ids  called by AccountTriggerHandler
    
    // To hold OpportunityExtension Ids called by OpportunityExtensionTriggerHandler
    public static Set<Id> processedOppExtIds = new Set<Id>();
    public static Set<Id> processedOpportunityExtensionIds = new Set<Id>(); 
    
    public static Set<Id> processedCampnIds = new Set<Id>();
    public static Set<Id> processedCampaignIds = new Set<Id>(); // To hold Campaign Ids called by CampaignTriggerHandler
    
    public static Set<Id> processedLeadIds = new Set<Id>(); // To hold Lead Ids called by LeadTriggerHandler
    
    public static Set<Id> processedCampaignMemberIds = new Set<Id>(); // To hold Lead Ids called by LeadTriggerHandler
    
    public static Set<Id> processedMyWorkCenterIds = new Set<Id>(); // To hold Lead Ids called by MyWorkCenterHandler
    
    public static Set<Id> processedFocusPartnerIds = new Set<Id>(); // To hold Focus Partner IDs called by FocusPartnerMasterTriggerHandler
    
    public static Set<Id> processedPartnerProspIds = new Set<Id>(); // To hold Partner Prospect IDs called by PartnerProspectTriggerHandler
    
    public ManageRecursive() {

    }
}