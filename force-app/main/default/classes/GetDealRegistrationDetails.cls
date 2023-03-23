@RestResource(urlMapping='/GetDealRegistrationDetails/*')
global without sharing class GetDealRegistrationDetails {
    global static final String INVALID_SINGLE_REQUEST_INPUT = 'Invalid request. Deal Reg Partner Account Id is mandatory';
    global static final String NO_DATA_FOUND = 'No matching deal registrations found';
    
    @HttpGet
    global static void getRegisteredDeals() {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;

        Map<String, String> requestParams = restReq.params;
        String endpoint = restReq.requestURI;
        Boolean isRequestValid = true;

        String partneraccId, partneremail, partnerrole, dealRegId, tab;
        Integer limitorder, pagenumber;
        List<Deal_Reg__c> dealReglist = new List<Deal_Reg__c>();

        //Validating the input params
        
        if ((!requestParams.containsKey('partner_acc_id')
                || !requestParams.containsKey('partneremail')
                || !requestParams.containsKey('partnerrole')
                || !requestParams.containsKey('pagenumber')
                || !requestParams.containsKey('limit'))
            || (null == requestParams.get('partner_acc_id')
                || null == requestParams.get('partneremail')
                || null == requestParams.get('partnerrole')
                || null == requestParams.get('pagenumber')
                || null == requestParams.get('limit')) 
            || ('' == requestParams.get('partner_acc_id')
                || '' == requestParams.get('partneremail')
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
        partneremail = requestParams.get('partneremail');
        dealRegId = requestParams.get('dealRegId');
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
        String query = 'SELECT Account_Manager__r.Name, Account_Manager_Phone__c, Approval_Status__c, Area__c, Area_Director__r.Name, AW_Partner_Intent__c, Channel_Manager__r.Name, Channel_Manager_Phone__c, Contact__r.Name, '
                        + 'CreatedDate, Customer_Role_And_Title__c, Deal_Description__c, Deal_Reg_Type__c, End_Customer_City__c, End_Customer_Contact_Last_Name__c, End_Customer_Contact_Name__c, End_Customer_Country__c, '
                        + 'End_Customer_Domain__c, End_Customer_Email__c, End_Customer_Name__c, End_Customer_Phone__c, End_Customer_Postal_Code__c, End_Customer_State__c, End_Customer_Street_Address__c, '
                        + 'End_Customer_TC_Email__c, End_Customer_TC_Name__c, End_Customer_TC_Last_Name__c, End_Customer_TC_Phone__c, Technical_Contact_Role_and_Title__c, Owner.Name, '
                        + 'Estimated_Amount__c, Expected_Close_Date__c, Expiration_Date__c, GEO__c, GEO_VP__c, Id, Market_Segment__c, Name, Number_of_Users__c, Partner_Account__c, Partner_Account__r.Name, '
                        + 'Partner_Account_Owner_Email__c, Partner_Account_SE_Email__c, Partner_Alternate_Email_1__c, Partner_Alternate_Email_2__c, Partner_Alternate_Email_3__c, Partner_Company_Name__c, '
                        + 'Partner_Contact_Email__c, Partner_Contact_Last_Name__c, Partner_Contact_Name__c, Partner_Country__c, Partner_Domain__c, Partner_Phone__c, Partner_Role__c, Partner_State__c, POV_Partner_Intent__c, '
                        + 'Product_Areas__c, RecordType.Name, Region__c, Sales_Territory__c, Security_ISA_Email__c, Security_ISA_Name__c, Source__c, Status__c, Territory_Name__c, Territory_Type__c, '
                        + '(Select Id, Activity__c, Status__c from DR_Cosell_Partners__r) FROM Deal_Reg__c';
        
        if(dealRegId != null && dealRegId != ''){
            query += ' WHERE Id = :dealRegId ' ;
        }else if(partnerrole == 'User' && null != partneremail && partneremail != ''){
            query += ' WHERE Partner_Contact_Email__c = :partneremail and Partner_Account__c = :partneraccId ' ;
        }else if (partnerrole == 'Manager' && null != partneraccId && partneraccId != '') {
            query += ' WHERE Partner_Account__c in :acctHierarchyIds ' ;
        } else {
            query = '';
        }

        if(tab == 'Open' && query != '' && (dealRegId == null || dealRegId == '')){
            query += ' and Status__c not in (\'Converted\', \'Expired\',\'Rejected\') ';
        }

        //for total count -pagination
        Integer totalCount;
        if(query != ''){
            List<Deal_Reg__c> dllst = Database.query(query);
            totalCount = dllst != null && !dllst.isEmpty() ? dllst.size() : 0;
        }

        //actual query with pagination and sorting
        if(query != '' && (dealRegId == null || dealRegId == '')){
            query += ' ORDER BY CreatedDate DESC limit :limitorder OFFSET :pagenumber';
        }

        if(query != ''){
            dealReglist = Database.query(query);
        }

        if (dealReglist.isEmpty()) {
            restRes.statusCode = 404;
            restRes.responseBody = Blob.valueOf(NO_DATA_FOUND);
        } else {
            List<DealRegistrationGetModel> resplst = new List<DealRegistrationGetModel>();
            for(Deal_Reg__c dr: dealReglist){
                DealRegistrationGetModel resp = new DealRegistrationGetModel();
                resp.alternateemail1 = dr.Partner_Alternate_Email_1__c;
                resp.alternateemail2 = dr.Partner_Alternate_Email_2__c;
                resp.amount = dr.Estimated_Amount__c;
                resp.channelManagerName = dr.Channel_Manager__r.Name;
                resp.zscalerContact = dr.Channel_Manager__r.Name;
                resp.channelManagerPhone = dr.Channel_Manager_Phone__c;
                resp.closeDate = dr.Expected_Close_Date__c;
                resp.customerCity = dr.End_Customer_City__c;
                resp.customerCountry = dr.End_Customer_Country__c;
                resp.customerName = dr.End_Customer_Name__c;
                resp.customerPostal = dr.End_Customer_Postal_Code__c;
                resp.customerState = dr.End_Customer_State__c;
                resp.customerStreetAddress = dr.End_Customer_Street_Address__c;
                resp.dealDescription = dr.Deal_Description__c;
                resp.dealRegExpirationDate = dr.Expiration_Date__c;
                resp.dealRegId = dr.Id;
                resp.dealRegNumber = dr.Name;
                resp.dealRegSubmissionDate = Date.valueOf(dr.CreatedDate);
                resp.dealType = dr.Deal_Reg_Type__c;
                resp.numberOfSeats = dr.Number_of_Users__c;
                resp.partnerContact = dr.Partner_Contact_Name__c + ' ' + dr.Partner_Contact_Last_Name__c;
                resp.partnerName = dr.Partner_Account__r.Name;
                resp.partnerEmail = dr.Partner_Contact_Email__c;
                resp.partnerphone = dr.Partner_Phone__c;
                resp.primaryContactEmail = dr.End_Customer_Email__c;
                resp.primaryContactFirstName = dr.End_Customer_Contact_Name__c;
                resp.primaryContactLastName = dr.End_Customer_Contact_Last_Name__c;
                resp.primaryContactPhone = dr.End_Customer_Phone__c;
                resp.primaryContactRoleAndTitle = dr.Customer_Role_And_Title__c;
                resp.productAreas = dr.Product_Areas__c;
                resp.securityISA = dr.Security_ISA_Name__c;
                resp.status = dr.Status__c;
                resp.technicalContactEmail = dr.End_Customer_TC_Email__c;
                resp.technicalContactFirstName = dr.End_Customer_TC_Name__c;
                resp.technicalContactLastName = dr.End_Customer_TC_Last_Name__c;
                resp.technicalContactPhone = dr.End_Customer_TC_Phone__c;
                resp.technicalRoleAndTitle = dr.Technical_Contact_Role_and_Title__c;
                resp.awIntent = dr.AW_Partner_Intent__c;
                resp.povIntent = dr.POV_Partner_Intent__c;
                resp.approvalStatus = dr.Approval_Status__c;
                resp.dealRegOwner = dr.Owner.Name;

                if(dr.POV_Partner_Intent__c == 'Yes'){
                    resp.povStatus = 'Intent';
                }else{
                    resp.povStatus = 'No';
                }

                if(dr.AW_Partner_Intent__c == 'Yes'){
                    resp.awStatus = 'Intent';
                }else{
                    resp.awStatus = 'No';
                }

                for(Cosell_Activities__c csa: dr.DR_Cosell_Partners__r){
                    if(csa.Activity__c == 'POV'){
                        resp.povStatus = csa.Status__c;
                    }
                    if(csa.Activity__c == 'Architecture Workshop'){
                        resp.awStatus = csa.Status__c;
                    }
                }
                resp.showOppDetails = dr.Status__c == 'Converted';
                if(dealRegId != null && dealRegId != '' && dr.Status__c == 'Converted'){
                    List<Opportunity> opplst = [Select Id, Forecast_Category__c, Stagename, Closedate, Name from Opportunity where Deal_Reg__c = :dealRegId];
                    if(!opplst.isEmpty()){
                        resp.oppName = opplst[0].Name;
                        resp.oppStage = opplst[0].Stagename;
                        resp.oppCloseDate = opplst[0].Closedate;
                        resp.oppForecastCategory = opplst[0].Forecast_Category__c;
                    }
                }
                resplst.add(resp);
            }
            DealRegistrationResponse dresp = new DealRegistrationResponse();
            dresp.dealReglist= resplst;
            dresp.totalCount= totalCount;
            restRes.responseBody = Blob.valueOf(JSON.serialize(dresp));
        }
    }
    global class DealRegistrationResponse {
        List<DealRegistrationGetModel> dealReglist;
        Integer totalCount;
    }
    global class DealRegistrationGetModel {
        public String dealRegId;
        public String dealRegNumber;
        public Date closeDate;
        public String partnerContact;
        public String zscalerContact;
        public String customerName;
        public Decimal amount;
        public String awStatus;
        public String povStatus;
        public String status;
        public String approvalStatus;
        public String dealRegOwner;
        public String dealType;
        public String partnerName;
        public String partnerEmail;
        public String partnerphone;
        public String alternateemail1;
        public String alternateemail2;
        public String securityISA;
        public String customerStreetAddress;
        public String customerCity;
        public String customerCountry;
        public String customerPostal;
        public String customerState;
        public String primaryContactFirstName;
        public String primaryContactLastName;
        public String primaryContactPhone;
        public String primaryContactEmail;
        public String primaryContactRoleAndTitle;
        public String technicalContactFirstName;
        public String technicalContactLastName;
        public String technicalContactPhone;
        public String technicalContactEmail;
        public String technicalRoleAndTitle;
        public Decimal numberOfSeats;
        public String productAreas;
        public String dealDescription;
        public String channelManagerName;
        public String channelManagerPhone;
        public String awIntent;
        public String povIntent;
        public Date dealRegExpirationDate;
        public Date dealRegSubmissionDate;
        public Boolean showOppDetails;
        public String oppName;
        public String oppStage;
        public String oppForecastCategory;
        public Date oppCloseDate;
    }
    
}