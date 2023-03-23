public with sharing class CustomLookupController {

    private static String queryString = 'SELECT Id, {0} FROM {1} {2} {3}';

    @AuraEnabled
    public static List<QueriedRecordWrapper> findRecords(RecordDetailsWrapper recordDetailsWrap) {
        System.debug('-=- record details wrap -=- '+recordDetailsWrap);

        List<String> queryFormatterList = new List<String>();
        queryFormatterList.add(recordDetailsWrap.searchField);// 0th index will be replaced with the field
        queryFormatterList.add(recordDetailsWrap.objectName);

        String searchKey = String.escapeSingleQuotes(recordDetailsWrap.searchKey); 
        searchKey = '\'%' + searchKey + '%\'';
        String queryCondition;
        //IBA - 1600 - Start
        if(recordDetailsWrap.partnerType=='Influence'){
            String partnerTypevalue = recordDetailsWrap.valuefield;//Added as part of IBA- 1742
        	queryCondition = ' WHERE ' + recordDetailsWrap.searchField + ' LIKE ' + searchKey;
        	queryCondition = queryCondition + ' AND Partner_Type__c =:partnerTypevalue';//updating the query of IBA- 1742
        }
        else if(recordDetailsWrap.partnerType=='Impact'){
            String techPartnerReferralAgreement = 'Impact';
        	queryCondition = ' WHERE ' + recordDetailsWrap.searchField + ' LIKE ' + searchKey;
        	queryCondition = queryCondition + ' AND Tech_Partner_Referral_Agreement__c =:techPartnerReferralAgreement';
        }
		//IBA - 1600 - End
        /*if ((recordDetailsWrap.existingRecords != NULL) && (!recordDetailsWrap.existingRecords.isEmpty())) {
            queryCondition = queryCondition + ' AND Id NOT IN :recordDetailsWrap.existingRecords';
        }*/

        queryFormatterList.add(queryCondition);
        queryFormatterList.add(' LIMIT 50000 ');

        queryString = String.format(queryString, queryFormatterList);

        System.debug('-=- queryString -=- '+queryString);
        

        List<SObject> recordList = Database.query(queryString);

        System.debug('-=- result -=- '+recordList);

        List<QueriedRecordWrapper> queriedRecordWrapperList = new List<QueriedRecordWrapper>();

        QueriedRecordWrapper queriedRecordWrap;

        for (SObject rec : recordList) {
            queriedRecordWrap               = new QueriedRecordWrapper();
            queriedRecordWrap.recordId      = String.valueOf(rec.get('Id'));
            queriedRecordWrap.recordName    = String.valueOf(rec.get(recordDetailsWrap.searchField));

            queriedRecordWrapperList.add(queriedRecordWrap);
        }

        
        return queriedRecordWrapperList;
    }

    public class RecordDetailsWrapper {
        @AuraEnabled public String searchKey { get; set; }
        @AuraEnabled public String objectName { get; set; }
        @AuraEnabled public String searchField { get; set; }
        @AuraEnabled public String valuefield { get; set; } //Added as part of IBA- 1742
        @AuraEnabled public String partnerType { get; set; }// Added as part of IBA - 1600
        //@AuraEnabled public List<Id> existingRecords { get; set; }
    }

    public class QueriedRecordWrapper {
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public String recordName { get; set; }
    }
}