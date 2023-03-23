/////This class  will sync commercial to Fed  Account fields. 
@RestResource(urlMapping='/ACCTYSYNC/*')
global without sharing class ACCTYSYNCTOFED{
    global static Boolean avoidtriggers = false;
    
    /////This method will sync commercial to Fed  Account fields. 
    @HttpGet
    global static Map<String, String> doGet() {
        RestRequest req = RestContext.request;
        Map<String, String> result = new map<String, String>();
        List<ACCOUNT> acclst = new List<ACCOUNT>();
        // This for loop will collect all accounts four fields to integrate back to Fed
        for(ACCOUNT acc: [SELECT Id, First_ZDX_Contract_Date__c , No_Of_ZDX_Platform_Users__c , Total_ZPA_Platform_Users_Purchased__c , Total_ZIA_Platform_Users_Purchased__c, Support_Type__c , TAM_Name_New__c   , Secondary_TAM_Name__c , CSM_Name_New__c  , CSM_Name_2__c , type,name, First_Contract_Date__c,First_ZPA_Contract_Date__c FROM Account where Is_Federal_Account_Sync__c = true ]){
            acclst.add(acc);
        }
        system.debug('acclst:'+ acclst[0]);
        if(!acclst.isEmpty()){
            result.put('accresults', JSON.serialize(acclst));
        }
        
        return result;
    }
    
}