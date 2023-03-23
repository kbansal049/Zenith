@RestResource(urlMapping='/EngagementServices/*')
global without sharing class EngagementServices {
    global static final String INVALID_GET_REQUEST = 'Invalid request. Partner Account, Partner Contact and Root Id are mandatory';
    global static final String INVALID_POST_REQUEST = 'Invalid request. Partner Account, Contact Name, Root Id and Content are mandatory';
    global static final String NO_DATA_FOUND = 'No matching Engagements found';
    global static final String POST_SUCCESS = 'Engagement successfully created.';
    global static final String POST_FAILURE = 'Engagement POST Failure.';
    
    @HttpPost
    global static void createEngagement(){
        RestRequest restReq = RestContext.Request;
        RestResponse restRes = RestContext.Response;

        EngagementPostResponse response = new EngagementPostResponse();
        System.debug(restReq.requestBody.toString());
        EngagementPostRequest request = (EngagementPostRequest)JSON.deserialize(restReq.requestBody.toString(), EngagementPostRequest.class);
        System.debug(request);
        Id recId = request.rootId != null && request.rootId != '' ? (Id)request.rootId : null;
        String excep = '';

        if ((null == request.rootId
                || null == request.feedbody
                || null == request.partner_acc_id
                || null == request.contactName)
            || ('' == request.rootId
                || '' == request.feedbody
                || '' == request.partner_acc_id
                || '' == request.contactName)){
                    response.status_code = '-1';
                    response.status_message = INVALID_POST_REQUEST;
                    restRes.responseBody = Blob.valueOf(JSON.serialize(response));
                    restRes.statusCode = 400;
        } else{
            String atmentionId = '';
            if(recId != null){
                if(recId.getSobjectType().getDescribe().getName() == 'Contact'){
                    if(request.partner_acc_id != null && request.partner_acc_id != ''){
                        List<Account> acclst = [Select Id, Channel_Manager__c, OwnerId from account where id = :request.partner_acc_id];
                        if(!acclst.isEmpty()){
                            atmentionId = acclst[0].Channel_Manager__c != null ? acclst[0].Channel_Manager__c : acclst[0].OwnerId;
                        }
                    }
                }else if(recId.getSobjectType().getDescribe().getName() == 'Deal_Reg__c'){
                    List<Deal_Reg__c> drlst = [Select Id, OwnerId from Deal_Reg__c where id = :recId];
                    if(!drlst.isEmpty()){
                        atmentionId = drlst[0].OwnerId;
                    }
                }else if(recId.getSobjectType().getDescribe().getName() == 'Cosell_Activities__c'){
                    List<Cosell_Activities__c> csalst = [Select Id, OwnerId from Cosell_Activities__c where id = :recId];
                    if(!csalst.isEmpty()){
                        atmentionId = csalst[0].OwnerId;
                    }
                }
            }
            try {
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                mentionSegmentInput.id = atmentionId;
                messageBodyInput.messageSegments.add(mentionSegmentInput);

                textSegmentInput.text = ' - Posted by: ' + request.contactName + ': \n\n' + request.feedbody;
                messageBodyInput.messageSegments.add(textSegmentInput);

                feedItemInput.body = messageBodyInput;
                feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = recId;

                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                //Set the response parameters
                response.status_message = POST_SUCCESS;
                response.status_code = '1';
                restRes.responseBody = Blob.valueOf(JSON.serialize(response));
            } catch (Exception ex) {
                System.debug('Error: ' + ex.getMessage() + '\nStack trace: ' + ex.getStackTraceString());
                //Set the response parameters
                excep = ex.getMessage();
                response.status_message = POST_FAILURE;
                response.status_code = '-1';
                restRes.responseBody = Blob.valueOf(JSON.serialize(response));
                restRes.statusCode = 400;
            }
        }

        CreateIntegrationLogs.createLogs(recId, 'POST', '', '', restReq.requestBody.toString(), restRes.responseBody.toString(), string.valueOf(restRes.statusCode), restRes.statusCode == 200 ? 'Success': 'Failure', excep, 'EngagementServices', request.contactName);
    }

    @HttpGet
    global static void getEngagements() {
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;

        Map<String, String> requestParams = restReq.params;
        String endpoint = restReq.requestURI;
        Boolean isRequestValid = true;

        String partneraccId, rootId, contactName;
        Integer limitorder;
        List<FeedItem> fiList = new List<FeedItem>();

        //Validating the input params
        
        if ((!requestParams.containsKey('partner_acc_id')
                || !requestParams.containsKey('rootId')
                || !requestParams.containsKey('limit')
                || !requestParams.containsKey('contactName'))
            || (null == requestParams.get('partner_acc_id')
                || null == requestParams.get('rootId')
                || null == requestParams.get('limit')
                || null == requestParams.get('contactName')) 
            || ('' == requestParams.get('partner_acc_id')
                || '' == requestParams.get('rootId')
                || '' == requestParams.get('limit')
                || '' == requestParams.get('contactName'))){
            restRes.statusCode = 400;
            restRes.responseBody = Blob.valueOf(INVALID_GET_REQUEST);
            isRequestValid = false;
        } 

        //Stop right here if the request is not valid
        if (!isRequestValid) {
            return;
        }

        //Parse the query parameters
        partneraccId = requestParams.get('partner_acc_id');
        rootId = requestParams.get('rootId');
        contactName = requestParams.get('contactName');
        limitorder = Integer.valueOf(requestParams.get('limit'));
        //pagenumber = Integer.valueOf((Decimal.valueOf(requestParams.get('pagenumber')) - 1) * limitorder);
        
        String query = 'SELECT Id, Body, ParentId, CreatedbyId, createdby.Name, createddate '
                        + ' FROM FeedItem where Visibility = \'AllUsers\' and (type=\'TextPost\' or type = \'LinkPost\' or type=\'ContentPost\')';
        
        if(rootId != null && rootId != ''){
            query += ' and ParentId = :rootId ' ;
        } else {
            query = '';
        }


        //for total count - pagination
        Integer totalCount;
        if(query != ''){
            List<FeedItem> dllst = Database.query(query);
            totalCount = dllst != null && !dllst.isEmpty() ? dllst.size() : 0;
        }

        //actual query with pagination and sorting
        if(query != ''){
            query += ' ORDER BY CreatedDate DESC limit :limitorder';
        }

        if(query != ''){
            fiList = Database.query(query);
        }

        if (fiList.isEmpty()) {
            restRes.statusCode = 404;
            restRes.responseBody = Blob.valueOf(NO_DATA_FOUND);
        } else {
            List<EngagementDetail> resplst = new List<EngagementDetail>();
            for(FeedItem fi: fiList){
                EngagementDetail resp = new EngagementDetail();
                resp.feedbody = fi.Body;
                resp.createddate = fi.Createddate.getTime();
                resp.userName = fi.createdbyId == UserInfo.getUserId() ? contactName : fi.createdby.Name;
                resplst.add(resp);
            }
            EngagementGetResponse dresp = new EngagementGetResponse();
            dresp.eglst= resplst;
            dresp.totalCount= totalCount;
            restRes.responseBody = Blob.valueOf(JSON.serialize(dresp));
        }
    }
    
    global class EngagementGetResponse {
        List<EngagementDetail> eglst;
        Integer totalCount;
    }

    global class EngagementDetail {
        public String feedbody;
        public String userName;
        public Long createddate;
    }

    global class EngagementPostResponse {
        public String status_message;
        public String status_code;
    }

    global class EngagementPostRequest {
        public String rootId;
        public String feedbody;
        public String partner_acc_id;
        public String contactName;
    }
}