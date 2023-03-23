global without sharing class jiraWrapper {
    global String PRGId;
    global String Summary;  //3423423
    global String Description;  //A023432423423
    global String Cluster;  //A3345345
    global String Region;
    
    global String Cloud;  //A3345345
    global String accountId;
     global String accountName;
    global String customerId;
    
    public static String getjiraJson(Id pgId){
        Boolean isCASB = false;
        boolean isDLP = false;
        Provisioning_Group__c   pg =[select id,Zscaler_Cloud_ID__c,Account__c,Account__r.name,Account__r.billingCountry,Account__r.ZIA_Customer_Id__c, Zscaler_Cloud_ID__r.Name,
                                     Zscaler_Cloud_ID__r.Org_Name__c,Geo__c,Is_Jira_Ticket_Required__c,Account__r.Geo__c,Account__r.Area__c,Account__r.District__c,
                                     Account__r.FY18_Sales_Territory__r.Provisioning_Jira_Geo__c,
                                     (select id,name,Product__c from Provisioning_Products__r) ,Preferred_Cloud__c
                                     from Provisioning_Group__c where id=:pgId limit 1];
        
        jiraWrapper wrp = new jiraWrapper();
        wrp.PRGId = pg.id;
        
        System.debug('pg.Provisioning_Products__r=='+pg.Provisioning_Products__r);
        if(pg.Provisioning_Products__r !=null && pg.Provisioning_Products__r.size()>0 ){
           
            
              /*  List<Product_License__c> plList = [Select ID,Name,Product__c,Provisioning_License__c,POV_Quantity__c,License_SKU__c,Product_SKU_Code__c,License_Product_Line__c,
                                                   License_Based_On__c,License__c,Is_JIRA_Ticket_Required__c
                                                   from Product_License__c where License__c != null and Product__c != null and Product__c in : ppIdSet];
                System.debug('plList=='+plList.size()); */
                if(pg.Zscaler_Cloud_ID__r.name !=null){
                    if(pg.Zscaler_Cloud_ID__r.name.contains('-')){
                        wrp.customerId =pg.Zscaler_Cloud_ID__r.name.subStringAfter('-');
                    }
                    
                }
            wrp.Summary = 'Enable CASB/DLP';
            wrp.Description = 'Please assign CASB/DLP cluster for ORGID-'+wrp.customerId;
            wrp.cluster ='SMCASB,SMDLP'; 
            
            
            System.debug('pg.Account__r.Geo__c=='+pg.Account__r.Geo__c);
            if(pg.Account__r.Geo__c=='Americas')
                wrp.Region = 'US';
            else if (pg.Account__r.Geo__c=='APJ')
                  wrp.Region = 'APAC';
            else if (pg.Account__r.Geo__c=='EMEA')
                 wrp.Region = 'EMEA';
              else if (pg.Account__r.Geo__c=='Public Sector')
                 wrp.Region =  pg.Account__r.FY18_Sales_Territory__r.Provisioning_Jira_Geo__c !=null ? pg.Account__r.FY18_Sales_Territory__r.Provisioning_Jira_Geo__c :'US';
             else if(pg.Account__r.Geo__c=='WW Enterprise'){
                    if(pg.Account__r.Area__c.contains('AMS')){
                         wrp.Region = 'US';
                    }else if(pg.Account__r.Area__c.contains('EMEA') ){
                         wrp.Region = 'EMEA';
                    }
                 else if(pg.Account__r.Area__c.contains('APJ')){
                         wrp.Region = 'APAC';
                    }
                    
                }
                else if(pg.Account__r.Geo__c=='WW Commercial'){ //
                    if(pg.Account__r.District__c.contains('AMS')){
                         wrp.Region = 'US';
                    }else if(pg.Account__r.District__c.contains('EMEA') ){
                        wrp.Region = 'EMEA';
                    }
                     if(pg.Account__r.District__c.contains('APJ')){
                         wrp.Region = 'APAC';
                    }
                    
                    
                }
           // wrp.Region = 'APAC';//pg.Geo__c; Public Sector


            if(pg.Preferred_Cloud__c !=null){
                List<String> lstCloud = System.label.Cloud_Mapping.split(';');
                Map<String,String> mapcloud = new map<String,String>();
                for(String st : lstcloud){
                    mapcloud.put(st.substringBefore('-'),st.substringAfter('-'));
                }
                if(mapcloud !=null && mapcloud.containskey(pg.Preferred_Cloud__c))
                 	wrp.Cloud = mapcloud.get(pg.Preferred_Cloud__c);
                    
            }
            	
            wrp.accountId = pg.Account__c;
            wrp.accountName = pg.Account__r.name;
           
           
        }
        
        System.debug('wrp=='+Json.serialize(wrp));
        return Json.serialize(wrp);
    }
    
    global  static jiraWrapper parse(String json){
        return (jiraWrapper) System.JSON.deserialize(json, jiraWrapper.class);
    }
}