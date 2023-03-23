public class CaseSpecialInstructionCmpCtrl {
    
    @AuraEnabled(cacheable=true)
    public static string fetchAccountSpecialInst(String caseId){
        try {
            if(!String.isBlank(caseId)){
                Case cs = [select id, AccountId, Account.Account_Special_Instructions__c from case where Id=:caseId];
                if(cs.AccountId!= null && cs.Account.Account_Special_Instructions__c!=null){
                    return cs.Account.Account_Special_Instructions__c;
                }else{
                    return 'Error';
                }
            }else{
                return 'Error';
            }            
        } catch (Exception ex) {
            return 'Error';
        }

    }
}