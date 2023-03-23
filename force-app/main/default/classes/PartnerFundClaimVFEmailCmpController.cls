public class PartnerFundClaimVFEmailCmpController {
    
    public String partnerFundClaimId{get;set;}
    
    public List<PartnerFundClaim> fundClaimRecords{
        get{
            fundClaimRecords = [SELECT Id,Title,ChannelPartnerId,
                                Request.Partner_Account__r.Name,Request.Partner_Contact__c,Request.Partner_Contact_Email__c,
                                Request.Partner_Contact_Phone__c,Request.Extension__c,Request.Activity_Name__c,
                                Request.Category__c,Request.Sub_Category__c,Request.Start_Date__c,Request.End_Date__c,
                                Request.Activity_Location__c,Request.Estimated_of_Attendees__c,Request.Estimated_ROI__c,
                                Request.RequestedAmount,Request.Total_Activity_Cost__c,Request.Lead_Follow_Up__c,
                                Request.Target_Audience__c,Request.Zscaler_Focus_Solution__c
                                FROM PartnerFundClaim
                                WHERE Id =: partnerFundClaimId];
            return fundClaimRecords;
        }
        set;
    }
    
}