@RestResource(urlMapping='/GetDealAmountbyQuarter/*')
global class GetDealAmountbyQuarter {
    global static final String INVALID_SINGLE_REQUEST_INPUT = 'Invalid request. Partner Account Id is mandatory';
    global static final String NO_DATA_FOUND = 'No matching Opportunities found';
    
    @HttpGet
    global static void getDealsbyQtr() {
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
        //Query the matching deal registrations
        String currQtrqueryNB ='',
                lastQtrqueryNB = '',
                lastminus1QtrqueryNB = '',
                lastminus2QtrqueryNB = '',
                lastminus3QtrqueryNB = '',
                currQtrqueryUB ='',
                lastQtrqueryUB = '',
                lastminus1QtrqueryUB = '',
                lastminus2QtrqueryUB = '',
                lastminus3QtrqueryUB = '',
                currQtrqueryRB ='',
                lastQtrqueryRB = '',
                lastminus1QtrqueryRB = '',
                lastminus2QtrqueryRB = '',
                lastminus3QtrqueryRB = '';
        String query = 'Select SUM(Amount) amt '
                     + '  FROM Opportunity ';
        ZForecastingDataModel.FiscalQuarterInfo curquarter = new ZForecastingDataModel.FiscalQuarterInfo();
        ZForecastingDataModel.FiscalQuarterInfo lastquarter = curquarter.Previous;
        ZForecastingDataModel.FiscalQuarterInfo lastminus1quarter = lastquarter.Previous;
        ZForecastingDataModel.FiscalQuarterInfo lastminus2quarter = lastminus1quarter.Previous;
        ZForecastingDataModel.FiscalQuarterInfo lastminus3quarter = lastminus2quarter.Previous;
        Date curquarterstartdate = curquarter.StartDate,
             curquarterenddate = curquarter.EndDate,
             lastquarterstartdate = lastquarter.StartDate,
             lastquarterenddate = lastquarter.EndDate,
             lastminus1quarterstartdate = lastminus1quarter.StartDate,
             lastminus1quarterenddate = lastminus1quarter.EndDate,
             lastminus2quarterstartdate = lastminus2quarter.StartDate,
             lastminus2quarterenddate = lastminus2quarter.EndDate,
             lastminus3quarterstartdate = lastminus3quarter.StartDate,
             lastminus3quarterenddate = lastminus3quarter.EndDate;
        //Filter the records based on the query parameters provided
        if (null != partneraccId && partneraccId != '') {
            if(role == 'User'){
                currQtrqueryNB =  query + ' WHERE Closedate >= :curquarterstartdate and Closedate >= :curquarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'New Business\' and IsClosed = true' ;
                lastQtrqueryNB =  query + ' WHERE Closedate >= :lastquarterstartdate and Closedate >= :lastquarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'New Business\' and IsClosed = true' ;
                lastminus1QtrqueryNB =  query + ' WHERE Closedate >= :lastminus1quarterstartdate and Closedate >= :lastminus1quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'New Business\' and IsClosed = true' ;
                lastminus2QtrqueryNB =  query + ' WHERE Closedate >= :lastminus2quarterstartdate and Closedate >= :lastminus2quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'New Business\' and IsClosed = true' ;
                lastminus3QtrqueryNB =  query + ' WHERE Closedate >= :lastminus3quarterstartdate and Closedate >= :lastminus3quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'New Business\' and IsClosed = true' ;
                currQtrqueryUB =  query + ' WHERE Closedate >= :curquarterstartdate and Closedate >= :curquarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'Existing Customer (Add On)\' and IsClosed = true' ;
                lastQtrqueryUB =  query + ' WHERE Closedate >= :lastquarterstartdate and Closedate >= :lastquarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'Existing Customer (Add On)\' and IsClosed = true' ;
                lastminus1QtrqueryUB =  query + ' WHERE Closedate >= :lastminus1quarterstartdate and Closedate >= :lastminus1quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'Existing Customer (Add On)\' and IsClosed = true' ;
                lastminus2QtrqueryUB =  query + ' WHERE Closedate >= :lastminus2quarterstartdate and Closedate >= :lastminus2quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'Existing Customer (Add On)\' and IsClosed = true' ;
                lastminus3QtrqueryUB =  query + ' WHERE Closedate >= :lastminus3quarterstartdate and Closedate >= :lastminus3quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'Existing Customer (Add On)\' and IsClosed = true' ;
                currQtrqueryRB =  query + ' WHERE Closedate >= :curquarterstartdate and Closedate >= :curquarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'Existing Customer (Renewal)\' and IsClosed = true' ;
                lastQtrqueryRB =  query + ' WHERE Closedate >= :lastquarterstartdate and Closedate >= :lastquarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'Existing Customer (Renewal)\' and IsClosed = true' ;
                lastminus1QtrqueryRB =  query + ' WHERE Closedate >= :lastminus1quarterstartdate and Closedate >= :lastminus1quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'Existing Customer (Renewal)\' and IsClosed = true' ;
                lastminus2QtrqueryRB =  query + ' WHERE Closedate >= :lastminus2quarterstartdate and Closedate >= :lastminus2quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'Existing Customer (Renewal)\' and IsClosed = true' ;
                lastminus3QtrqueryRB =  query + ' WHERE Closedate >= :lastminus3quarterstartdate and Closedate >= :lastminus3quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Contact_Email__c = :partnerEmail and Partner_Account__c = :partneraccId) and Type = \'Existing Customer (Renewal)\' and IsClosed = true' ;
            }else{
                currQtrqueryNB =  query + ' WHERE Closedate >= :curquarterstartdate and Closedate >= :curquarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'New Business\' and IsClosed = true' ;
                lastQtrqueryNB =  query + ' WHERE Closedate >= :lastquarterstartdate and Closedate >= :lastquarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'New Business\' and IsClosed = true' ;
                lastminus1QtrqueryNB =  query + ' WHERE Closedate >= :lastminus1quarterstartdate and Closedate >= :lastminus1quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'New Business\' and IsClosed = true' ;
                lastminus2QtrqueryNB =  query + ' WHERE Closedate >= :lastminus2quarterstartdate and Closedate >= :lastminus2quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'New Business\' and IsClosed = true' ;
                lastminus3QtrqueryNB =  query + ' WHERE Closedate >= :lastminus3quarterstartdate and Closedate >= :lastminus3quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'New Business\' and IsClosed = true' ;
                currQtrqueryUB =  query + ' WHERE Closedate >= :curquarterstartdate and Closedate >= :curquarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'Existing Customer (Add On)\' and IsClosed = true' ;
                lastQtrqueryUB =  query + ' WHERE Closedate >= :lastquarterstartdate and Closedate >= :lastquarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'Existing Customer (Add On)\' and IsClosed = true' ;
                lastminus1QtrqueryUB =  query + ' WHERE Closedate >= :lastminus1quarterstartdate and Closedate >= :lastminus1quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'Existing Customer (Add On)\' and IsClosed = true' ;
                lastminus2QtrqueryUB =  query + ' WHERE Closedate >= :lastminus2quarterstartdate and Closedate >= :lastminus2quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'Existing Customer (Add On)\' and IsClosed = true' ;
                lastminus3QtrqueryUB =  query + ' WHERE Closedate >= :lastminus3quarterstartdate and Closedate >= :lastminus3quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'Existing Customer (Add On)\' and IsClosed = true' ;
                currQtrqueryRB =  query + ' WHERE Closedate >= :curquarterstartdate and Closedate >= :curquarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'Existing Customer (Renewal)\' and IsClosed = true' ;
                lastQtrqueryRB =  query + ' WHERE Closedate >= :lastquarterstartdate and Closedate >= :lastquarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'Existing Customer (Renewal)\' and IsClosed = true' ;
                lastminus1QtrqueryRB =  query + ' WHERE Closedate >= :lastminus1quarterstartdate and Closedate >= :lastminus1quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'Existing Customer (Renewal)\' and IsClosed = true' ;
                lastminus2QtrqueryRB =  query + ' WHERE Closedate >= :lastminus2quarterstartdate and Closedate >= :lastminus2quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'Existing Customer (Renewal)\' and IsClosed = true' ;
                lastminus3QtrqueryRB =  query + ' WHERE Closedate >= :lastminus3quarterstartdate and Closedate >= :lastminus3quarterenddate and Deal_Reg__c in (Select Id from Deal_Reg__c where Partner_Account__c in :acctHierarchyIds) and Type = \'Existing Customer (Renewal)\' and IsClosed = true' ;
            }
            
        } 
        
        DealResponse ctrl = new DealResponse();
        if(currQtrqueryNB != ''){
            List<AggregateResult> newlist = Database.query(currQtrqueryNB);
            ctrl.currQtrNB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(lastQtrqueryNB != ''){
            List<AggregateResult> newlist = Database.query(lastQtrqueryNB);
            ctrl.lastQtrNB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(lastminus1QtrqueryNB != ''){
            List<AggregateResult> newlist = Database.query(lastminus1QtrqueryNB);
            ctrl.lastminus1QtrNB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(lastminus2QtrqueryNB != ''){
            List<AggregateResult> newlist = Database.query(lastminus2QtrqueryNB);
            ctrl.lastminus2QtrNB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(lastminus3QtrqueryNB != ''){
            List<AggregateResult> newlist = Database.query(lastminus3QtrqueryNB);
            ctrl.lastminus3QtrNB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(currQtrqueryUB != ''){
            List<AggregateResult> newlist = Database.query(currQtrqueryUB);
            ctrl.currQtrUB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(lastQtrqueryUB != ''){
            List<AggregateResult> newlist = Database.query(lastQtrqueryUB);
            ctrl.lastQtrUB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(lastminus1QtrqueryUB != ''){
            List<AggregateResult> newlist = Database.query(lastminus1QtrqueryUB);
            ctrl.lastminus1QtrUB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(lastminus2QtrqueryUB != ''){
            List<AggregateResult> newlist = Database.query(lastminus2QtrqueryUB);
            ctrl.lastminus2QtrUB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(lastminus3QtrqueryUB != ''){
            List<AggregateResult> newlist = Database.query(lastminus3QtrqueryUB);
            ctrl.lastminus3QtrUB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(currQtrqueryRB != ''){
            List<AggregateResult> newlist = Database.query(currQtrqueryRB);
            ctrl.currQtrRB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(lastQtrqueryRB != ''){
            List<AggregateResult> newlist = Database.query(lastQtrqueryRB);
            ctrl.lastQtrRB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(lastminus1QtrqueryRB != ''){
            List<AggregateResult> newlist = Database.query(lastminus1QtrqueryRB);
            ctrl.lastminus1QtrRB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(lastminus2QtrqueryRB != ''){
            List<AggregateResult> newlist = Database.query(lastminus2QtrqueryRB);
            ctrl.lastminus2QtrRB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        if(lastminus3QtrqueryRB != ''){
            List<AggregateResult> newlist = Database.query(lastminus3QtrqueryRB);
            ctrl.lastminus3QtrRB = newlist != null && !newlist.isEmpty() ? (Decimal)newlist[0].get('amt') : 0;
        }
        
        if (ctrl == null) {
            restRes.statusCode = 404;
            restRes.responseBody = Blob.valueOf(NO_DATA_FOUND);
        } else {
            restRes.responseBody = Blob.valueOf(JSON.serialize(ctrl));
        }
    }

    global class DealResponse{
        public Decimal currQtrNB;
        public Decimal lastQtrNB;
        public Decimal lastminus1QtrNB;
        public Decimal lastminus2QtrNB;
        public Decimal lastminus3QtrNB;
        public Decimal currQtrUB;
        public Decimal lastQtrUB;
        public Decimal lastminus1QtrUB;
        public Decimal lastminus2QtrUB;
        public Decimal lastminus3QtrUB;
        public Decimal currQtrRB;
        public Decimal lastQtrRB;
        public Decimal lastminus1QtrRB;
        public Decimal lastminus2QtrRB;
        public Decimal lastminus3QtrRB;
    }
}