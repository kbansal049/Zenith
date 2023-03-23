/////This class  will sync commercial to Fed  Account fields. 
@RestResource(urlMapping='/TERRITORYSYNC/*')
global without sharing class TERRITORYSYNC{
    global static Boolean avoidtriggers = false;
    
    /////This method will sync commercial to Fed  Account fields. 
    @HttpGet
    global static  Map<String, String> doGet() {
        RestRequest req = RestContext.request;
        Map<String, String> result = new map<String, String>();
        
        list<ACCOUNT> listAcc = [SELECT Id  FROM Account where Is_Federal_Account_Sync__c = true ];
        System.debug('listAcc =' + listAcc);
        list<String> newReturn  = new list<String>();
        List<AggregateResult> listTeam = [select accountId, count(userId)  countAccTeam from AccountTeamMember where accountId in :listAcc group by accountId order by count(userId)  desc];
        System.debug('listTeam =' + listTeam);
        
        // This for loop will collect all accounts four fields to integrate back to Fed
        
        if(!listTeam.isEmpty()){
            for (AggregateResult acc :listTeam){
                newReturn.add(acc.get('AccountId')+ ' ' + acc.get('countAccTeam'));
            }
        }
        
        list<Opportunity> listOpp = [SELECT Id  FROM Opportunity where Is_Federal_Opportunity_Sync__c = true ];
        System.debug('listOpp =' + listOpp);
        list<String> newReturnOpp  = new list<String>();
        List<AggregateResult> listTeamOpp = [select OpportunityId , count(userId)  countAccTeam from OpportunityTeamMember where OpportunityId  in :listOpp group by OpportunityId  order by count(userId)  desc];
        System.debug('listTeamOpp =' + listTeamOpp);
        
        // This for loop will collect all accounts four fields to integrate back to Fed
        
        if(!listTeam.isEmpty()){
            for (AggregateResult opp :listTeamOpp){
                newReturnOpp.add(opp.get('OpportunityId')+ ' ' + opp.get('countAccTeam'));
            }
        }
        
      result.put('accresults', JSON.serialize(newReturn));
      result.put('oppresults', JSON.serialize(newReturnOpp));


        return result ;
    }
    
}