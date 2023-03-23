@RestResource(urlMapping='/SYNCACCCLOUDUSAGE/*')
global with sharing class SYNCACCCLOUDUSAGE {
    global static Boolean avoidtriggers = false;
    
    @HttpPost
    global static Map<String, List<String>> doPost(Map<String, Account> accmap, Map<String,Customer_Score_Card__c> mapScoreCard) {
        
        System.debug('SYNCACCCLOUDUSAGE accmap' + accmap);
        System.debug('SYNCACCCLOUDUSAGE mapScoreCard' + mapScoreCard);

        List<String> errorlst = new List<String>();
        List<String> successlst = new List<String>();
        
        avoidtriggers = true;
        TriggerUtility.accTerritoryPatchExecuted();
        TriggerUtility.accSalesTeamExecuted();
        
        Map<String, List<String>> mapresult = new Map<String, List<String>>();
        Map<String, List<String>> mapresultErrors = new Map<String, List<String>>();

        System.debug('SYNCACCCLOUDUSAGE' + accmap.values());
        
        
        List<Customer_Score_Card__c> updateCard = new List<Customer_Score_Card__c>();
        try{
        
        List<Account> listAcc = [select Id from account where is_Federal_Account_Sync__c = true  OR type = 'Partner'];
        Map<Id, Account> mapAccount = new Map<Id, Account>(accmap.values());
        System.debug('mapAccount: ' + mapAccount);
        List<Customer_Score_Card__c> listCards =[SELECT Auth_ZIA_users_deployed_LM_Vs_LM_1__c,Auth_ZIA_users_deployed_LM_Vs_LM_6__c,Auth_ZIA_users_deployed_LM_Vs_LM_12__c,
        Bandwidth_LM_Vs_PM__c,Bandwidth_LM_Vs_6M_Ago__c,Bandwidth_LM_Vs_12M_Ago__c,Total_Bandwidth__c,Transactions_LM_vs_PM__c,
        Transactions_LM_Vs_6M_Ago__c,Transactions_LM_Vs_12M_Ago__c,ZPA_Active_Users_LM_Vs_LM_1__c,ZPA_Active_Users_LM_Vs_LM_6__c,
        ZPA_Active_Users_LM_Vs_LM_12__c,Account__c FROM  Customer_Score_Card__c where  Account__c in :mapAccount.keyset()];
  
        System.debug('listCards: ');
        System.debug('listCards: ' + listCards);

            

            for(Customer_Score_Card__c con :listCards) {
            if(mapScoreCard.get(con.Account__c)!=null){
            System.debug('con.Auth_ZIA_users_deployed_LM_Vs_LM_1__c: '+   mapScoreCard.get(con.Account__c).Auth_ZIA_users_deployed_LM_Vs_LM_1__c);

            con.Auth_ZIA_users_deployed_LM_Vs_LM_1__c  = mapScoreCard.get(con.Account__c).Auth_ZIA_users_deployed_LM_Vs_LM_1__c;
            System.debug('con.Auth_ZIA_users_deployed_LM_Vs_LM_1__c: '+ con.Auth_ZIA_users_deployed_LM_Vs_LM_1__c);
            System.debug('con.Auth_ZIA_users_deployed_LM_Vs_LM_1__c: '+ con.Auth_ZIA_users_deployed_LM_Vs_LM_1__c);


            con.Bandwidth_LM_Vs_12M_Ago__c = mapScoreCard.get(con.Account__c).Bandwidth_LM_Vs_12M_Ago__c;
            con.Auth_ZIA_users_deployed_LM_Vs_LM_1__c = mapScoreCard.get(con.Account__c).Auth_ZIA_users_deployed_LM_Vs_LM_1__c;
            con.Auth_ZIA_users_deployed_LM_Vs_LM_6__c = mapScoreCard.get(con.Account__c).Auth_ZIA_users_deployed_LM_Vs_LM_6__c;
            con.Auth_ZIA_users_deployed_LM_Vs_LM_12__c = mapScoreCard.get(con.Account__c).Auth_ZIA_users_deployed_LM_Vs_LM_12__c;
            con.Bandwidth_LM_Vs_PM__c = mapScoreCard.get(con.Account__c).Bandwidth_LM_Vs_PM__c;
            con.Bandwidth_LM_Vs_6M_Ago__c = mapScoreCard.get(con.Account__c).Bandwidth_LM_Vs_6M_Ago__c;
            con.Bandwidth_LM_Vs_12M_Ago__c = mapScoreCard.get(con.Account__c).Bandwidth_LM_Vs_12M_Ago__c;
            con.Total_Bandwidth__c = mapScoreCard.get(con.Account__c).Total_Bandwidth__c;
            con.Transactions_LM_vs_PM__c = mapScoreCard.get(con.Account__c).Transactions_LM_vs_PM__c;
            con.Transactions_LM_Vs_6M_Ago__c = mapScoreCard.get(con.Account__c).Transactions_LM_Vs_6M_Ago__c;
            con.Transactions_LM_Vs_12M_Ago__c = mapScoreCard.get(con.Account__c).Transactions_LM_Vs_12M_Ago__c;
            con.ZPA_Active_Users_LM_Vs_LM_1__c = mapScoreCard.get(con.Account__c).ZPA_Active_Users_LM_Vs_LM_1__c;
            con.ZPA_Active_Users_LM_Vs_LM_6__c = mapScoreCard.get(con.Account__c).ZPA_Active_Users_LM_Vs_LM_6__c;
            con.Transactions_LM_Vs_12M_Ago__c = mapScoreCard.get(con.Account__c).Transactions_LM_Vs_12M_Ago__c;
            con.ZPA_Active_Users_LM_Vs_LM_12__c = mapScoreCard.get(con.Account__c).ZPA_Active_Users_LM_Vs_LM_12__c;
			updateCard.add(con);
                    }
        }
        }catch (Exception e){
            System.debug('in catch'+ e.getMessage());
        }
         
        System.debug('SYNCACCCLOUDUSAGE updateCard' + updateCard);

        try{
        
        avoidtriggers = true;
        TriggerUtility.accTerritoryPatchExecuted();
        TriggerUtility.accSalesTeamExecuted();
        System.debug('SYNCACCCLOUDUSAGE' + updateCard);
        if(updateCard != null){
            Database.saveResult[] srList = database.update(updateCard,false);
            for (Database.saveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        String s = '';
                        if(srList.indexOf(sr) != -1 && !updateCard.isEmpty() && updateCard.size() > srList.indexOf(sr) && updateCard[srList.indexOf(sr)] != null){
                            s = updateCard[srList.indexOf(sr)].Id;
                        }
                        errorlst.add(s + ' - ' + err.getMessage());
                    }
                }
            }
            mapresult.put('successlst', successlst);
            mapresultErrors.put('errorlst', errorlst);

            if(!errorlst.isEmpty()){
                mapresult.put('errorlst', errorlst);
            }
        }
        System.debug('SYNCACCCLOUDUSAGE successlst' + successlst);
        System.debug('SYNCACCCLOUDUSAGE errorlst' + errorlst);
        
        }catch(Exception e){
       System.debug('SYNCACCCLOUDUSAGE in catch' + e.getMessage());
    }   
        

        return mapresultErrors ;
        
    }
}