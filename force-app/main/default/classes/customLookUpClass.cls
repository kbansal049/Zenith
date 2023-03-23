public with sharing class customLookUpClass {
    
    /**
        Updated BY : Sateesh U 
        To Display the selected Look up results on lightning component.
    **/
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName, String partnerType,Boolean incentiveFilter, String opportunityArea) {
       //System.debug('partnerType'+partnerType+'incentiveFilter'+incentiveFilter+'ObjectName'+ObjectName+'opportunityArea'+opportunityArea);
        String sQuery;
        String searchKey = searchKeyWord + '%';
        List <sObject> returnList = new List <sObject>();
        //Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        if(partnerType == 'Tech Partner'){
            sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey and Type = \'Technology Partner\' order by createdDate DESC limit 10';
        }
        else{
            //System.debug('Inside Else'+ObjectName);
            sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey and Type = \'Partner\' order by createdDate DESC limit 10';
        }
        if(String.isBlank(partnerType)){
           sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey and Status__c = \'Approved\' order by createdDate DESC limit 10';  
        }
       
       if(partnerType == 'FederalReseller'){  
           // System.debug('FederalReseller'+ObjectName);
           sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey and Type = \'Partner\' and Model_Type_Partner__c = \'Summit - Federal\' AND isFederalDistributor__c = false order by createdDate DESC limit 10';      
       }
       // CR# 4581 Added by Mahesh T --Start// CR# 4581 Added by Mahesh T --Start
       if(partnerType == 'Distributor' && ( opportunityArea == 'Federal Distributor'  )){
           //System.debug('Distributor'+ObjectName);
           sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey AND Type = \'Partner\' AND isFederalDistributor__c = TRUE order by createdDate DESC limit 10';
       }
       else if(partnerType == 'Distributor' && ( opportunityArea != 'Federal Distributor'  )){
        	// System.debug('not federal'+ObjectName);
            sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey AND Type = \'Partner\' AND isFederalDistributor__c = false  order by createdDate DESC limit 10';
       }  // CR# 4581  --Stop
        List < sObject > lstOfRecords = Database.query(sQuery);
        /*for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }*/
       if(ObjectName == 'Account'  && incentiveFilter == true){
           System.debug('Inside Incentive');
            set<Id> accId = new set<Id>();
           // CR# 4581 Added by Mahesh T --Start
           if(partnerType == 'FederalReseller'){
               // System.debug('FederalReseller incentiveFilter'+ObjectName);
               for (Partner_Incentive__c incent : [SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c FROM Partner_Incentive__c 
                                                   WHERE Account__c IN: lstOfRecords AND Active__c = true 
                                                          and Partner_Program__c ='Summit - Federal'
                                                          and Account__r.isFederalDistributor__c = false ]) {
                accId.add(incent.Account__c);
            }
           }
            if(partnerType == 'Reseller'){
               for (Partner_Incentive__c incent : [SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c FROM Partner_Incentive__c 
                                                   WHERE Account__c IN: lstOfRecords AND Active__c = true 
                                                   		 and  Partner_Program__c !='Summit - Federal'
                                                  		 and Account__r.isFederalDistributor__c = false	]) {
                   accId.add(incent.Account__c);
               }
           } // CR# 4581  --Stop
            for (sObject obj: lstOfRecords) {
                if(accId.contains(obj.Id)){
                    returnList.add(obj);
                }
            }
        }else{
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
        }
        return returnList;
    }
}