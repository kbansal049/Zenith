public with sharing class SearchController {
    
    
    @AuraEnabled
    public static List<sObject> search(String objectName, List<String> fields, String searchTerm, String filter){
        System.debug('--SearchController---search--called--'+objectName);
        System.debug('--objectName--'+objectName);
        System.debug('--fields--'+fields);
        System.debug('--searchTerm--'+searchTerm);
        System.debug('--filter--'+filter);
        String searchKeyword = searchTerm + '*';
        String returningQuery = objectName+' ( Id, '+ String.join(fields,',') +  (filter != null && filter.trim().length()>0 ? (' '+ filter.trim()) : '') + ')';
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 20';
        System.debug('--query--'+query);
        List<List<sObject>> searchRecords = Search.Query(Query);
        System.debug('--searchRecords--'+searchRecords);
        return searchRecords.get(0);
    }
    @AuraEnabled
    public static List<sObject> searchBasedOnID(String objectName, List<String> fields,  String searchTerm){
        System.debug('--SearchController---searchBasedOnID--called--'+objectName);
        System.debug('--objectName--'+objectName);
        System.debug('--fields--'+fields);
        System.debug('--searchTerm--'+searchTerm);
        String searchKeyword = searchTerm;
        String returningQuery = 'Id, '+String.join(fields,',');
        String query = 'Select '+returningQuery+' from '+objectName + ' where id = :searchKeyword LIMIT 20';
        if(objectName == 'User'){
            query = 'Select '+returningQuery+' from '+objectName + ' where id = :searchKeyword AND UserType =\'Standard\' AND IsActive =true LIMIT 20';
        }
        System.debug('--query--'+query);
        List<sObject> searchRecords = Database.Query(Query);
        System.debug('--searchRecords--'+searchRecords);
        return searchRecords;
    }
    
}