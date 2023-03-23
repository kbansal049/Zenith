@RestResource(urlMapping='/GetCosellActivityDetails/*')
global without sharing class GetCosellActivityDetails {
    global static final String INVALID_SINGLE_REQUEST_INPUT = 'Invalid request. Partner Account and Partner Contact are mandatory';
    global static final String NO_DATA_FOUND = 'No matching Cosell Activities found';
    
    @HttpGet
    global static void getCosellActivity() {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;

        Map<String, String> requestParams = restReq.params;
        String endpoint = restReq.requestURI;
        Boolean isRequestValid = true;

        String partneraccId, partnercontactId, partnerrole, tab;
        Integer limitorder, pagenumber;
        List<Cosell_Activities__c> csalst = new List<Cosell_Activities__c>();

        //Validating the input params
        
        if ((!requestParams.containsKey('partner_acc_id')
                || !requestParams.containsKey('partnercontactId')
                || !requestParams.containsKey('partnerrole')
                || !requestParams.containsKey('pagenumber')
                || !requestParams.containsKey('limit'))
            || (null == requestParams.get('partner_acc_id')
                || null == requestParams.get('partnercontactId')
                || null == requestParams.get('partnerrole')
                || null == requestParams.get('pagenumber')
                || null == requestParams.get('limit')) 
            || ('' == requestParams.get('partner_acc_id')
                || '' == requestParams.get('partnercontactId')
                || '' == requestParams.get('partnerrole')
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
        partnerrole = requestParams.get('partnerrole');
        tab = requestParams.get('tab');
        partnercontactId = requestParams.get('partnercontactId');
        limitorder = Integer.valueOf(requestParams.get('limit'));
        pagenumber = Integer.valueOf((Decimal.valueOf(requestParams.get('pagenumber')) - 1) * limitorder);
        Set<Id> acctHierarchyIds = new Set<Id>();

        if(partnerrole == 'Manager' && partneraccId != null && partneraccId != ''){
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
        String query = 'Select Id, Activity__c, Deal_Reg__c, Deal_Reg__r.Name, Opportunity__c, Opportunity__r.Name, Owner.Name, '
                        + 'Partner__c, Partner__r.Name, Partner_Contact__c, Partner_Contact__r.Name, Partner_Contact_Email__c, '
                        + 'Opportunity__r.Account.Name, Status__c, Status_Start_Date__c from Cosell_Activities__c';
        
        if(partnerrole == 'User' && null != partnercontactId && partnercontactId != '' && null != partneraccId && partneraccId != ''){
            query += ' WHERE Partner_Contact__c = :partnercontactId and Partner__c = :partneraccId' ;
        }else if (partnerrole == 'Manager' && null != partneraccId && partneraccId != '') {
            query += ' WHERE Partner__c in :acctHierarchyIds ' ;
        } else {
            query = '';
        }
        
        if(tab == 'Invite' && query != ''){
            query += ' and Status__c = \'Invite\' ';
        }

        //for pagination count without pagination
        Integer count;
        if(query != ''){
            List<Cosell_Activities__c> csalstforcount = Database.query(query);
            count = csalstforcount != null && !csalstforcount.isEmpty() ? csalstforcount.size() : 0;
        }

        //actual query with pagination and sorting
        if(query != ''){
            query += ' ORDER BY CreatedDate DESC limit :limitorder OFFSET :pagenumber';
        }

        if(query != ''){
            csalst = Database.query(query);
        }

        if (csalst.isEmpty()) {
            restRes.statusCode = 404;
            restRes.responseBody = Blob.valueOf(NO_DATA_FOUND);
        } else {
            List<CosellGetModel> resplst = new List<CosellGetModel>();
            for(Cosell_Activities__c csa: csalst){
                CosellGetModel resp = new CosellGetModel();
                resp.csaId = csa.Id;
                resp.activity = csa.Activity__c;
                resp.dealReg = csa.Deal_Reg__r.Name;
                resp.opportunity = csa.Opportunity__r.Name;
                resp.partnercontact = csa.Partner_Contact__r.Name;
                resp.partnerName = csa.Partner__r.Name;
                resp.customerName = csa.Opportunity__r.Account.Name;
                resp.showacceptanddeny = csa.Status__c == 'Invite';
                resp.status = csa.Status__c;
                resp.dateStatusmodified = csa.Status_Start_Date__c != null ? Date.valueOf(csa.Status_Start_Date__c) : null ;
                resp.zscalercontact = csa.Owner.Name;
                resplst.add(resp);
            }
            CosellResponse csaresp = new CosellResponse();
            csaresp.coselllst = resplst;
            csaresp.totalCount = count;
            restRes.responseBody = Blob.valueOf(JSON.serialize(csaresp));
        }
    }

    global class CosellResponse {
        List<CosellGetModel> coselllst;
        Integer totalCount;
    }

    global class CosellGetModel {
        public String csaId;
        public String activity;
        public String dealReg;
        public String opportunity;
        public String partnerName;
        public String status;
        public Date dateStatusmodified;
        public Boolean showacceptanddeny;
        public String partnercontact;
        public String zscalercontact;
        public String customerName;
    }
}