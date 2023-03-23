@isTest
private class PartnerFundClaimVFEmailCmpControllerTest {
    
    @isTest static void fundClaimRecordsTestPositive() {
        PartnerFundClaimVFEmailCmpController obj = new PartnerFundClaimVFEmailCmpController();
        Id partnerFundClaimId = obj.partnerFundClaimId;
        List<PartnerFundClaim> fundClaimRecords = obj.fundClaimRecords;
    }

}