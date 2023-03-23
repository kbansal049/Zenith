public without sharing class CreateSAMLHistory {
    public static void createSSOsamlhistory(Map<String, String> req, String res, String accountId,String email,String status, String accName, String ziaorzpa){
        SSO_SAML_History__c sso = new SSO_SAML_History__c();
        String request = '{';
        for(String s: req.keyset()){
            request += s + ': ' + req.get(s) + ',';
        }
        request += '}';
        sso.SAML_Request__c = request;
        sso.SAML_Response__c = res;
        sso.Account_Id__c = accountId;
        sso.Email__c = email;
        sso.Status__c = status;
        sso.Account_Name__c = accName;
        sso.SSO_Initiated_from__c = ziaorzpa;
        sso.Found_Account__c = accountId != null && accountId != '';
        sso.Found_Email__c = email != null && email != '';
        insert sso ;
    }
    
    public static void createSSOsamlhistoryWithPortalDetails(Map<String, String> req, String res, String accountId,
                                                             String email,String status, String accName, String ziaorzpa,String cloudID, String portalUserName)
    {
        SSO_SAML_History__c sso = new SSO_SAML_History__c();
        String request = '{';
        for(String s: req.keyset()){
            request += s + ': ' + req.get(s) + ',';
        }
        request += '}';
        //Added by Anup - IBA-34 - Start
		String portalCountry = '';
		String portalState = '';
		portalCountry = ziaorzpa == 'ZPA' ? 'zpaLoginCountry':'ziaLoginCountry';
        portalState = ziaorzpa == 'ZPA' ? 'zpaLoginState':'ziaLoginState';
        if(req!= null && req.containsKey(portalCountry) && req.get(portalCountry)!=null){
            sso.Login_Country__c = req.get(portalCountry);
        }
        if(req!= null && req.containsKey(portalState) && req.get(portalState)!=null){
            sso.Login_State__c = req.get(portalState);
        }
        //Added by Ankit on 01/06/2022 - Start
        if(ziaorzpa.equalsIgnoreCase('EC')){
            ziaorzpa = 'Cloud Connector';
        }
        //Added by Ankit on 01/06/2022 - End
        //Added by Anup - IBA-34 - End
        sso.SAML_Request__c = request;
        sso.SAML_Response__c = res;
        sso.Account_Id__c = accountId;
        sso.Email__c = email;
        sso.Status__c = status != null ?  status.left(255) : '';
        sso.Account_Name__c = accName;
        sso.SSO_Initiated_from__c = ziaorzpa;
        sso.Found_Account__c = accountId != null && accountId != '';
        sso.Found_Email__c = email != null && email != '';
        sso.Cloud_Id__c = cloudID;
        sso.Portal_UserName__c = portalUserName;
        insert sso;
        
        System.debug('---createSSOsamlhistoryWithPortalDetails--'+JSON.serializePretty(sso));
    }
}