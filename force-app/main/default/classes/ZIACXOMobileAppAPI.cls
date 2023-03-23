@RestResource(urlMapping='/ZIACXOMobileAppAPI/*')
global with sharing class ZIACXOMobileAppAPI{
    global static Boolean avoidtriggers = false;
    
     @HttpGet
    global static Map<String, List<String>> doGet() {
        
        RestRequest req = RestContext.request;
        //Map<String, String> result = new map<String, String>();
        Map<String, List<string>> result = new map<String, List<String>>();
        Map<String,String> parmap = new Map<String, String>();
        Set<string> Cloudtypeset= new Set<string>();
        Cloudtypeset.add('ZIA');
        Cloudtypeset.add('ZPA');
        system.debug('email '+req.params);
        if(req != null && req.params!= null && req.params.containskey('email')){
            system.debug('email '+EncodingUtil.urlDecode(req.params.get('email'),'UTF-8'));
            string emailreceived=EncodingUtil.urlDecode(req.params.get('email'),'UTF-8');           
            List<Zscaler_Cloud_ID_Contact__c> ZCloudContactslist= new List<Zscaler_Cloud_ID_Contact__c>();
            Set<String> SendCIOReportstatus= new Set<String>();
            String ContactSendCIOReportstatus= ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus')!=null && ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus').Value__c!=null ? ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus').Value__c:'Send,Send delayed';
            SendCIOReportstatus.addall(ContactSendCIOReportstatus.split(','));
            //Select id,email from Contact where
            ZCloudContactslist = [select id,Contact__c,Org_ID__c from Zscaler_Cloud_ID_Contact__c  where Contact_Email__c=:emailreceived and Cloud_Type__c IN:Cloudtypeset and Email_Insights_Report__c IN : SendCIOReportstatus];
            if(ZCloudContactslist.size()>0){
                for(Zscaler_Cloud_ID_Contact__c zcc: ZCloudContactslist){
                    String delimiter = '-';
                    if(zcc.Org_ID__c.contains('-')){
                        string cloudname = zcc.Org_ID__c.substringBefore(delimiter).toLowerCase(); 
                        string companyid = zcc.Org_ID__c.substringAfter(delimiter);
                        if(result.containskey(cloudname)){
                            List<string> tempstr=result.get(cloudname);
                            //tempstr=tempstr+' , '+companyid;
                            tempstr.add(companyid);
                            result.put(cloudname,tempstr);
                        }else{
                            List<string> tempstr= new List<string>();
                            tempstr.add(companyid);
                            result.put(cloudname,tempstr);
                        }
                    }else if(zcc.Org_ID__c.isNumeric()){
                        if(result.containskey('ZPA')){
                            List<string> tempstr=result.get('zpa');
                            tempstr.add(zcc.Org_ID__c);
                            result.put('ZPA',tempstr);
                        }else{
                            List<string> tempstr= new List<string>();
                            tempstr.add(zcc.Org_ID__c);                                 
                            result.put('ZPA',tempstr);
                        }
                    }
                }
            }else{
                List<string> tempstr= new List<string>();
                tempstr.add('No Org Id’s for this email address on SFDC');              
                result.put('400',tempstr);
            }               
        }else{
            List<string> tempstr= new List<string>();
            tempstr.add('No Org Id’s for this email address on SFDC');              
            result.put('400',tempstr);
        }
        
        return result;
    }
    
}