public with sharing class customLookUpClassCPQ {
    
    /**
        Updated BY : Sateesh U 
        To Display the selected Look up results on lightning component.
    **/
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName, String partnerType,Boolean incentiveFilter) {
        //system.debug('ObjectName-->' + ObjectName);
        String sQuery;
        String searchKey = searchKeyWord + '%';
        List <sObject> returnList = new List <sObject>();
        //Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        if(partnerType == 'Tech Partner'){
            sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey and Type = \'Technology Partner\' order by createdDate DESC limit 10';
        }
        else{
            sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey and Type = \'Partner\' order by createdDate DESC limit 10';
        }
        if(String.isBlank(partnerType)){
           sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey and Status__c = \'Approved\' order by createdDate DESC limit 10';  
        }
        if(partnerType == 'FederalReseller'){   
            sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey and Type = \'Partner\' and Model_Type_Partner__c = \'Summit - Federal\' order by createdDate DESC limit 10';      
        }
        List < sObject > lstOfRecords = Database.query(sQuery);
        /*for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }*/
        if(ObjectName == 'Account' && (partnerType == 'Reseller' || partnerType == 'FederalReseller') && incentiveFilter == true){
            set<Id> accId = new set<Id>();
            for (Partner_Incentive__c incent : [SELECT id,Account__c,Active__c,Partner_Program__c,Partner_Role__c,Partner_Tier__c,Effective_End_Date__c,Effective_Start_Date__c FROM Partner_Incentive__c WHERE Account__c IN: lstOfRecords AND Active__c = true]) {
                accId.add(incent.Account__c);
            }
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