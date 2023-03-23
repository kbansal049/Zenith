public class FundClaimServiceLayer {
    
    public class FundClaimServiceLayerException extends Exception {
    }
    
    public void changeFundClaimStatusAndAmount(List<PartnerFundClaim> triggerNew){        
        
        for(PartnerFundClaim fundClaimRecord : triggerNew){
            if(fundClaimRecord.Zinfi_Claim_Id__c != NULL && 
               (fundClaimRecord.Claim_Status__c == 'Pending Submission' || fundClaimRecord.Claim_Status__c == 'Under Review')){
                   fundClaimRecord.Claim_Status__c = 'Under Review';
                   fundClaimRecord.Status = 'Submitted';
               }
            //To avoid the system validation on Amount field, "Enter a claim amount that's less than or equal to the request amount."
            if(fundClaimRecord.Amount == NULL){
                fundClaimRecord.Amount = 0.00;
            }
        }        
    }
    
    public void statusUpdateAndFieldValidation(List<PartnerFundClaim> triggerNew, Map<Id, PartnerFundClaim> triggerMapOld){        
        
        for(PartnerFundClaim fundClaimRecord : triggerNew){
            if(fundClaimRecord.Claim_Status__c == 'Approved' && 
               triggerMapOld.get(fundClaimRecord.Id).Claim_Status__c != 'Approved'){
                   fundClaimRecord.Status = 'Approved';
               }
            if(fundClaimRecord.Claim_Status__c == 'Approved' && 
               triggerMapOld.get(fundClaimRecord.Id).Claim_Status__c != 'Approved' &&
               fundClaimRecord.Amount_Approved__c == NULL){                   
                   fundClaimRecord.addError('Please enter Amount Approved');
               }
            if(fundClaimRecord.Claim_Status__c == 'Pending Submission' && 
               triggerMapOld.get(fundClaimRecord.Id).Claim_Status__c != 'Pending Submission'){
                   fundClaimRecord.Status = 'Submitted';
                   fundClaimRecord.Claim_Status__c = 'Under Review';
               }
            if(fundClaimRecord.Claim_Status__c == 'Paid' && 
               triggerMapOld.get(fundClaimRecord.Id).Claim_Status__c != 'Paid'){
                   fundClaimRecord.Status = 'Paid';
                   if(String.isBlank(fundClaimRecord.Payment_Id__c)){
                       fundClaimRecord.addError('Please provide Payment Id');
                   }else if(fundClaimRecord.Payment_Date__c == NULL){
                       fundClaimRecord.addError('Please provide Payment Date');
                   }else if(String.isBlank(fundClaimRecord.Invoice_Number__c)){
                       fundClaimRecord.addError('Please provide Invoice Number');
                   }else if(fundClaimRecord.Amount_Paid__c == NULL){
                       fundClaimRecord.addError('Please provide Amount Paid');
                   }
               }
            if(fundClaimRecord.Claim_Status__c == 'Rejected/Denied' && 
               triggerMapOld.get(fundClaimRecord.Id).Claim_Status__c != 'Rejected/Denied'){
                   fundClaimRecord.Status = 'Rejected';
                   if(String.isBlank(fundClaimRecord.Comments__c)){
                       fundClaimRecord.addError('Please provide Comments');
                   }
               }
        }        
    }
}