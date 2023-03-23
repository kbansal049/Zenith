@RestResource(urlMapping='/GetOpportunityDetails/*')
global class GetOpportunityDetails {
    global static final String INVALID_SINGLE_REQUEST_INPUT = 'Invalid request. Partner Account Id is mandatory';
    global static final String NO_DATA_FOUND = 'No matching Opportunities found';
    
    @HttpGet
    global static void getDeals() {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;

        Map<String, String> requestParams = restReq.params;
        String endpoint = restReq.requestURI;
        Boolean isRequestValid = true;

        String partneraccId, optyType;
        Boolean isClosed;
        Integer limitorder, pagenumber;
        List<Opportunity> opplist = new List<Opportunity>();

        //Validating the input params
        
        if ((!requestParams.containsKey('partner_acc_id')
                || !requestParams.containsKey('isClosed')
                || !requestParams.containsKey('optyType')
                || !requestParams.containsKey('pagenumber')
                || !requestParams.containsKey('limit'))
            || (null == requestParams.get('partner_acc_id')
                || null == requestParams.get('isClosed')
                || null == requestParams.get('optyType')
                || null == requestParams.get('pagenumber')
                || null == requestParams.get('limit')) 
            || ('' == requestParams.get('partner_acc_id')
                || '' == requestParams.get('isClosed')
                || '' == requestParams.get('optyType')
                || '' == requestParams.get('pagenumber')
                || '' == requestParams.get('limit'))){
            restRes.statusCode = 400;
            restRes.responseBody = Blob.valueOf(INVALID_SINGLE_REQUEST_INPUT);
            isRequestValid = false;
        } 

        //Stop right here if the request is not valid
        if (!isRequestValid) {
            return;
        }

        //Parse the query parameters
        partneraccId = requestParams.get('partner_acc_id');
        optyType = requestParams.get('optyType');
        isClosed = Boolean.valueOf(requestParams.get('isClosed'));
        limitorder = Integer.valueOf(requestParams.get('limit'));
        pagenumber = Integer.valueOf((Decimal.valueOf(requestParams.get('pagenumber')) - 1) * limitorder);
        Set<Id> acctHierarchyIds = new Set<Id>();

        if(partneraccId != null && partneraccId != ''){
            list<account> acclst = [Select Id, Ultimate_Parent_Account__c from account where Id = :partneraccId];
            if(!acclst.isEmpty()){
                if(acclst[0].Ultimate_Parent_Account__c != null){
                    acctHierarchyIds = GetHierarchy.getHierarchyfromUltimateParent(new Set<Id>{acclst[0].Ultimate_Parent_Account__c}, 10, 'Account');
                }else {
                    acctHierarchyIds = GetHierarchy.getHierarchyfromUltimateParent(new Set<Id>{acclst[0].Id}, 10, 'Account');
                }
            }
        }
        //Query the matching deal registrations
        String query = 'Select Id, Name,  Amount, CloseDate, Deal_Reg__c'
                     + '  FROM Opportunity ';

        //Filter the records based on the query parameters provided
        if (null != partneraccId && partneraccId != '') {
            query += ' WHERE Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = :optyType and IsClosed = :isClosed ORDER BY CreatedDate DESC limit :limitorder OFFSET :pagenumber' ;
        } else {
            query = '';
        }
        

        if(query != ''){
            opplist = Database.query(query);
        }

        if (opplist.isEmpty()) {
            restRes.statusCode = 404;
            restRes.responseBody = Blob.valueOf(NO_DATA_FOUND);
        } else {
            restRes.responseBody = Blob.valueOf(JSON.serialize(opplist));
        }
    }
}