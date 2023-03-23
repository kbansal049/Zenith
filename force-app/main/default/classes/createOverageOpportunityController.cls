//  Created by Ayush Kangar As part of IBA-2489
public with sharing class createOverageOpportunityController {
    
    @InvocableMethod(label='Update Account Overage on Account' description='When overage opp is closed, update account overage on account to not checked.' category= 'Account')
    public static void updateAccForOverage(List<id> accountId){
    
            Account acc = [select id from account where id =: accountId.get(0) limit 1][0];
            acc.Account_Overage__c = 'Not Checked';
            TriggerHandler.bypass('AccountTriggerHandler');
            update acc;
            TriggerHandler.clearBypass('AccountTriggerHandler');
        }

}