@RestResource(urlMapping='/GetDealInfoByType/*')
global without sharing class GetDealInfoByType {
    global static final String INVALID_SINGLE_REQUEST_INPUT = 'Invalid request. Partner Account Id is mandatory';
    global static final String NO_DATA_FOUND = 'No matching Opportunities found';
    
    @HttpGet
    global static void getDealsbyType() {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;

        Map<String, String> requestParams = restReq.params;
        String endpoint = restReq.requestURI;
        Boolean isRequestValid = true;

        String partneraccId, role, partnerEmail;

        //Validating the input params
        
        if ((!requestParams.containsKey('partner_acc_id')
                || !requestParams.containsKey('partnerEmail')
                || !requestParams.containsKey('role'))
            || (null == requestParams.get('partner_acc_id')
                || null == requestParams.get('partnerEmail') 
                || null == requestParams.get('role')) 
            || ('' == requestParams.get('partner_acc_id')
                || '' == requestParams.get('partnerEmail') 
                || '' == requestParams.get('role'))){
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
        partnerEmail = requestParams.get('partnerEmail');
        role = requestParams.get('role');
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
        ZForecastingDataModel.FiscalQuarterInfo curquarter = new ZForecastingDataModel.FiscalQuarterInfo();
        
        Date curquarterstartdate = curquarter.StartDate,
             curquarterenddate = curquarter.EndDate;

        //Query the matching deal registrations
        String newbusinessquery, upsellbusinessquery, totalbusinessquery;
        String query = 'Select SUM(Amount) amt '
                     + '  FROM Opportunity ';

        //Filter the records based on the query parameters provided
        if (null != partneraccId && partneraccId != '') {
            if(role == 'User'){
                newbusinessquery =  query + ' WHERE Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'New Business\' and IsClosed = true and iswon = true and closedate >= :curquarterstartdate and closedate <= :curquarterenddate' ;
                upsellbusinessquery =  query + ' WHERE Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'Existing Customer (Add On)\' and IsClosed = true and iswon = true and closedate >= :curquarterstartdate and closedate <= :curquarterenddate' ;
                totalbusinessquery =  query + ' WHERE Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and IsClosed = true and iswon = true and closedate >= :curquarterstartdate and closedate <= :curquarterenddate' ;
            }else{
                newbusinessquery =  query + ' WHERE Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'New Business\' and IsClosed = true and iswon = true and closedate >= :curquarterstartdate and closedate <= :curquarterenddate' ;
                upsellbusinessquery =  query + ' WHERE Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'Existing Customer (Add On)\' and IsClosed = true and iswon = true and closedate >= :curquarterstartdate and closedate <= :curquarterenddate' ;
                totalbusinessquery =  query + ' WHERE Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and IsClosed = true and iswon = true and closedate >= :curquarterstartdate and closedate <= :curquarterenddate' ;
            
            }
            
        } else {
            newbusinessquery = '';
            upsellbusinessquery = '';
            totalbusinessquery = '';
        }
        
        DealResponse ctrl = new DealResponse();
        if(newbusinessquery != ''){
            List<AggregateResult> newlist = Database.query(newbusinessquery);
            ctrl.newbusinessclosed = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(upsellbusinessquery != ''){
            List<AggregateResult> upselllist = Database.query(upsellbusinessquery);
            ctrl.upsellbusinessclosed = upselllist != null && !upselllist.isEmpty() ? (Decimal)upselllist[0].get('amt') : 0;
        }
        if(totalbusinessquery != ''){
            List<AggregateResult> totallist = Database.query(totalbusinessquery);
            ctrl.totalbusinessclosed = totallist != null && !totallist.isEmpty() ? (Decimal)totallist[0].get('amt') : 0;
        }

        if (ctrl == null) {
            restRes.statusCode = 404;
            restRes.responseBody = Blob.valueOf(NO_DATA_FOUND);
        } else {
            restRes.responseBody = Blob.valueOf(JSON.serialize(ctrl));
        }
    }

    global class DealResponse{
        public Decimal newbusinessclosed;
        public Decimal upsellbusinessclosed;
        public Decimal totalbusinessclosed;
    }
}