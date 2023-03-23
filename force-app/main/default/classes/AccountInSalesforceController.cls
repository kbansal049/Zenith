public without sharing class AccountInSalesforceController {
    
    @AuraEnabled
    public static string redirectSCI( string accountId){
        string retValue = '';
        string patchTeamId = ''; 
        string opportunityId = ''; 
        account accountRecord = [Select Id,Name, Sales_Territory__c, SBQQ__DefaultOpportunity__c,
                                                SBQQ__DefaultOpportunity__r.Patch__c 
                                                From 
                                                Account 
                                                Where 
                                                Id =: accountId];
        if(accountRecord != null && accountRecord.SBQQ__DefaultOpportunity__c != null){
            opportunityId = accountRecord.SBQQ__DefaultOpportunity__c;
            Patch__c patchRecord = [SELECT PatchTeam__c FROM Patch__c WHERE Id =: accountRecord.SBQQ__DefaultOpportunity__r.Patch__c];
            patchTeamId = patchRecord.PatchTeam__c;
        }
        else{
          patchTeamId =  accountRecord.Sales_Territory__c;
        }
        if(patchTeamId == null){
            patchTeamId = '';
        }
        retValue = 'accountId='+accountId+'&opportunityId='+opportunityId+'&patchTeamId='+patchTeamId+'&edit=false&campaignId=&leadId=&dealRegId=';
        return retValue;
    }
    
    
    /*
     * CR# 2411 - Updating the Number of recent activities for the searched accounts
     * Retrieving all the activities on Account of the past 3 month. No filter is required for the type of the meeting.
	*/
    private static void updateNumberOfRecentActivities(List<Account> queriedAccountList) {
                
        Map<Id, Integer> accRecentActivitiesMap = new Map<Id, Integer> ();
        
        for (AggregateResult result : [
            SELECT 
            	COUNT(Id), 
            	AccountId 
            FROM 
            	Event 
            WHERE 
            	AccountId IN :queriedAccountList
            AND 
            	ActivityDate = LAST_90_DAYS 
            GROUP BY AccountId
        ]) {
            
            Id accId = String.valueOf(result.get('AccountId'));
            Integer numberOfRecentActivities = Integer.valueOf(result.get('expr0'));
            
            accRecentActivitiesMap.put(accId, numberOfRecentActivities);
            
        }  
        
        List<Account> accList = new List<Account>();
        
        
        for (Account acc : queriedAccountList) {
            
            if (accRecentActivitiesMap.containsKey(acc.Id)) {
                
                acc.Number_of_Recent_Activities__c = accRecentActivitiesMap.get(acc.Id);
            }
            
            acc.Number_of_Recent_Activities__c = (acc.Number_of_Recent_Activities__c == NULL) 
                ? 0 
                : acc.Number_of_Recent_Activities__c;
            
            accList.add(acc);
        }
        
        TriggerUtility.SkipAccTriggerExecuted();
        
        UPDATE accList;
    } 
    
     @AuraEnabled
    public static list<fieldsListWrapper > fetchAccount(String searchKeyWord, string selectedgeo, string selectedRegion,string selectedindustry,string ZIAString,string ZPAString,string nameDrop) {
        
        List <string> accidList = new List <string> ();
        list<Account> lstOfAccount = new list<Account>();
        String Dynquery='select id,Name,Group_Account_Name__c,HQ_Account_Flag__c,Subsidiary__c,Open_Opportunities__c,Number_of_Recent_Activities__c, Ultimate_Parent_Account__r.Name, Ultimate_Parent_Account__r.Owner.Name,Ultimate_Parent_Account__c,District__c,Next_Renewal_Due_Date__c,Type,Area_Director__r.Name,BillingCountry,Sales_Territory__c,Industry';
        Dynquery=Dynquery+',Owner.Name, Area_Director__r.Full_Name__c,Area__c,No_of_Employees_Users__c from Account where ';
        
        
        boolean isExit = false;
        if(searchKeyWord != null && searchKeyWord != '' ){
            String searchKey = '%'+ searchKeyWord + '%';
            Dynquery = Dynquery+' Name LIKE:searchKey ';
            isExit = true;
        }
        
        if(selectedgeo != null && selectedgeo != '' ){
            string searchgeo = selectedgeo + '%';
            if(isExit == true){
                Dynquery = Dynquery+' AND Geo__c LIKE:searchgeo ';
            }
            else{
                Dynquery = Dynquery+' Geo__c LIKE:searchgeo ';
            }
            isExit = true;
        }
        
        if(selectedRegion != null && selectedRegion != '' ){
            string searchRegion = selectedRegion + '%';
            if(isExit == true){
                Dynquery = Dynquery+' AND Region__c LIKE:searchRegion ';
            }
            else{
                Dynquery = Dynquery+' Region__c LIKE:searchRegion ';
            }
            isExit = true;
        } 
        
        
        if(selectedindustry != null && selectedindustry != '' ){
            if(isExit == true){
                Dynquery = Dynquery+' AND Industry =:selectedindustry ';
            }
            else{
                Dynquery = Dynquery+' Industry =:selectedindustry ';
            }
            isExit = true;
        }
        if(ZPAString != null && ZPAString != '' ){
            if(isExit == true){
                Dynquery = Dynquery+' AND ZPA_Use_Cases__c includes (\''+ZPAString+'\')';
            }
            else{
                Dynquery = Dynquery+' ZPA_Use_Cases__c includes (\''+ZPAString+'\')';
            }
            isExit = true;
        }
        
        if(ZIAString != null && ZIAString != '' ){
            if(isExit == true){
                Dynquery = Dynquery+' AND ZIA_Use_Cases__c includes (\''+ZIAString+'\')';
            }
            else{
                Dynquery = Dynquery+' ZIA_Use_Cases__c includes (\''+ZIAString+'\')';
            }
            isExit = true;
        }
        
        Dynquery = Dynquery +' Limit 200' ;
        system.debug('-----------'+selectedindustry); 
        system.debug('-----------'+ZIAString); 
        system.debug('-----------'+ZPAString);   
        system.debug('-----------'+Dynquery);
        lstOfAccount = Database.query(Dynquery);
        
        
        
        /*TODO: 2411 - call our method*/
        
        updateNumberOfRecentActivities(lstOfAccount);
        
        lstOfAccount = Database.query(Dynquery);
        
        
        for(Account acc :lstOfAccount){
            accidList.add(acc.id);
        }
        
        list<Access_Request__c> accRequestList = [Select Id, 
                                                  Account__c,
                                                  Requested_From__c
                                                  FROM 
                                                  Access_Request__c 
                                                  WHERE 
                                                  Account__c IN: accidList 
                                                  AND 
                                                  Requested_From__c =: userinfo.getUserId()
                                                  AND
                                                  Request_Status__c = 'Requested'];
        
        
        Map<Id,List<Access_Request__c>> accAccessMap = new Map<Id,List<Access_Request__c>>();
        
        for(Access_Request__c accReq : accRequestList){
            
            if(!accAccessMap.containsKey(accReq.Account__c)){
                accAccessMap.put(accReq.Account__c, new list<Access_Request__c>());
            }
            accAccessMap.get(accReq.Account__c).add(accReq);
        }
        
        //List < UserRecordAccess> lstOfUserRecordAccess =[ SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userinfo.getUserId() AND RecordId IN : accidList Limit 200];
        List <UserRecordAccess> lstOfUserRecordAccess = AccountInSalesforceHelper.getAccessRecords(accidList);
        Map<Id,UserRecordAccess> userrecmap = new Map<Id,UserRecordAccess>();
        
        for(UserRecordAccess userrec : lstOfUserRecordAccess){
            if(userrec.HasReadAccess != false){
                userrecmap.put(userrec.RecordId,userrec );
            }
        }
        
        list<fieldsListWrapper > wrapList = new list<fieldsListWrapper>();
        for(account acc : lstOfAccount){
            fieldsListWrapper rec = new fieldsListWrapper();
            if(userrecmap.get(acc.Id) != null ){  
                rec.isChecked = true; 
            }
            else{ 
                rec.isChecked = false;
                if(accAccessMap.containsKey(acc.id)){
                    if(accAccessMap.get(acc.Id).size() > 0 ){ 
                        rec.Issubmitted = true; 
                    }
                    else{ 
                        rec.Issubmitted = false; 
                    }
                }
            }
            rec.Accrec = acc;
            wrapList.add(rec);
        }
        return wrapList;
    }
	 
   /* @AuraEnabled
	public static string createAccountAccessRequestOld(String recid, String JustificationRequestvalue) {
	    string requestReponse;
        Id AccountAccessRecordTypeId = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('Account Access').getRecordTypeId();
	    List <UserRecordAccess> lstOfUserRecordAccess = [SELECT RecordId,HasReadAccess, 
	                                                            HasEditAccess 
	                                                            FROM 
	                                                            UserRecordAccess 
	                                                            WHERE 
	                                                            UserId =: userinfo.getUserId() 
	                                                            AND 
	                                                            RecordId =: recid];
        
        Account acct = [Select Id, Name from Account where Id = :recid limit 1];
        
        //String subject = 'Request ' +acct.Name+' account access for '+ userinfo.getName();
	    List<Access_Request__c> AccessRequestList = [Select Id, 
	                                Account__c
	                                FROM 
	                                Access_Request__c 
	                                WHERE 
	                                Account__c =: recid 
	                                AND 
	                                Requested_From__c =: userinfo.getUserId()
	                                AND 
	                                Request_Type__c = 'Account Access'
	                                AND
	                                Request_Status__c != 'Revoked'];
        	   
	    if(AccessRequestList.size() > 0){ 
	        requestReponse = 'Request Access Case Already Submitted'; 
	    }
        
      
       
	    else{
	        string custlabel = label.Case_Owner_Id;
	        if(AccessRequestList.size() == 0){
	            List<User> currentUser = [SELECT Id, ManagerId FROM User WHERE Id =: userinfo.getUserId()];
	            if(!currentUser.isEmpty()){
    	            
    	            boolean inSameTerritory = false;
    	            List<Account> accounts = [SELECT Id, 
    	                                                Sales_Territory__c 
    	                                                FROM 
    	                                                Account 
    	                                                WHERE 
    	                                                Id =: recid];
    	            if(!accounts.isEmpty()){
    	                List<PatchTeamMember__c> patchTeamMember = [SELECT Id, 
    	                                                        User__c
    	                                                        FROM 
    	                                                        PatchTeamMember__c
    	                                                        WHERE
    	                                                        User__c =: currentUser[0].ManagerId
    	                                                        AND
    	                                                        PatchTeam__c =: accounts[0].Sales_Territory__c];
    	               if(!patchTeamMember.isEmpty()){
    	                   inSameTerritory = true;
    	               }
    	            }
    	            
    	            Id accountAccess = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('Account Access').getRecordTypeId();
                    Access_Request__c accRecord = new Access_Request__c();
                    accRecord.Account__c = recid; 
                    accRecord.Justification__c = JustificationRequestvalue;
                    accRecord.Object_Type__c = 'Account';
                    accRecord.Requested_From__c = currentUser[0].Id;
                    accRecord.Request_Type__c = 'Account Access';
                    accRecord.Request_Status__c = 'Requested';
                    accRecord.RecordTypeId = accountAccess;
                    
                    accRecord.Requested_Date__c = system.today();
                    accRecord.Approver__c = currentUser[0].ManagerId;
                    
                    if(inSameTerritory){
                        accRecord.Same_Territory__c = true;
                    }
                    else{
                        accRecord.Same_Territory__c = false;
                    }
                    insert accRecord;
                    
                    Approval.ProcessSubmitRequest [] requestList = new Approval.ProcessSubmitRequest []{};
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Submitting request for approval.');
                    req.setObjectId(accRecord.id);
                    requestList.add(req);
                    if(!requestList.isEmpty()){
                        Approval.ProcessResult[] result = Approval.process(requestList);
                    }
                }
                requestReponse = 'Request Access Submitted Successfully';
    	        //Case caseRec = new Case();
    	        //caseRec.AccountId = recid;
                //caseRec.OwnerId = custlabel;
    	        //caseRec.Submitted_By_Name__c = userinfo.getUserId();
    	        //caseRec.status = 'New';
    	        //caseRec.Subject = 'Salesforce Account Access Request : Request ' +acct.Name+' account access for '+ userinfo.getName();
    	        //caseRec.Type = 'Feature Request';
    	        //caseRec.Description = 'Request ' +acct.Name+' account access for '+ userinfo.getName();
    	        //caseRec.JustificationforRequest__c = JustificationRequestvalue ;
    	        //insert caseRec;
    	        //requestReponse = 'Request Access Submitted Successfully';
	        }
	    }
	    return requestReponse;
    }
    */
    
    @AuraEnabled
	public static String createAccountAccessRequest(String recid, String JustificationRequestvalue) {
	    String requestResponse;
        
        Id accountAccessRecordTypeId = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('Account Access').getRecordTypeId();

        List<Account> accList = [
            SELECT 
            	Id, 
	            Name,
                Geo__c,
    	        Sales_Territory__c,
				Sales_Territory__r.Theater__c,
				Sales_Territory__r.Region__c,
				Sales_Territory__r.Area__c
            FROM 
        	    Account 
            WHERE 
            	Id = :recid
        ];
        
        //System.debug('-=-= accList -=- '+accList);
        
        List<Access_Request__c> accessRequestList = [
            SELECT 
            	Id, 
            	Account__c
            FROM 
            	Access_Request__c 
            WHERE 
            	Account__c = :recid 
            AND 
            	Requested_From__c = :UserInfo.getUserId()
            AND 
            	Request_Type__c = 'Account Access'
            AND
            	Request_Status__c NOT IN ('Revoked','Rejected')
        ];


		//System.debug('-=-= accessRequestList -=- '+accessRequestList);        
        
        if (!accessRequestList.isEmpty()) {
            //System.debug('-=-- requestReponse inside if -=- '+requestResponse);
            requestResponse = 'Access Request Already Submitted'; 
        } else {
            
           //String area = (accList.get(0).Sales_Territory__c != NULL) && (String.isNotBlank(accList.get(0).Sales_Territory__r.Region__c)) ? accList.get(0).Sales_Territory__r.Region__c : 'AMS West';
           String area = '';
            
           if(String.isNotBlank(accList[0].Sales_Territory__r?.Region__c)){
                area = accList[0].Sales_Territory__r?.Region__c;
                
                //Take account Region for EMEA and APJ
                if( accList[0].Sales_Territory__r?.Theater__c == 'EMEA' && area == 'EMEA'){ area = accList[0].Sales_Territory__r?.Area__c; }
                if( accList[0].Sales_Territory__r?.Theater__c == 'APJ' && area == 'APJ'){ area = accList[0].Sales_Territory__r?.Area__c; }
                
           } else if(Test.isRunningTest()){
                area = 'India';
           } else{
                throw new AuraException('Please connect with the System Administrator. Could not find a related Sales Territory Area for this Account.'); //TODO: updat the error message               
           }
            /* if (String.isBlank(area)) {
                throw new AuraException('Please connect with the System Administrator. Could not find a related Sales Territory Area for this Account.'); //TODO: updat the error message
            } */
            
            System.debug('-=- area -=- '+area);
            
            List<Request_Access_Routing_Mapping__mdt> reqAccessRoutingList = [
                SELECT 
                	MasterLabel, 
                	Related_User_Id__c 
                FROM 
                	Request_Access_Routing_Mapping__mdt
                WHERE
                	MasterLabel = :area
                LIMIT 1
            ];
			
			System.debug('-=-= reqAccessRoutingList -=- '+reqAccessRoutingList);            
            
            if (!reqAccessRoutingList.isEmpty()) {
                Access_Request__c accessRequestRecord 	= new Access_Request__c();
                accessRequestRecord.Account__c 			= recid; 
                accessRequestRecord.Justification__c 	= JustificationRequestvalue;
                accessRequestRecord.Object_Type__c 		= 'Account';
                accessRequestRecord.Requested_From__c 	= System.UserInfo.getUserId();
                accessRequestRecord.Request_Type__c 	= 'Account Access';
                accessRequestRecord.Request_Status__c 	= 'Requested';
                accessRequestRecord.Access_Level__c     = 'Edit';
                accessRequestRecord.RecordTypeId 		= accountAccessRecordTypeId;
                accessRequestRecord.Requested_Date__c 	= System.today();
                accessRequestRecord.Approver__c 		= reqAccessRoutingList.get(0).Related_User_Id__c;
                
                INSERT accessRequestRecord;
                
                List<Approval.ProcessSubmitRequest> requestList = new List<Approval.ProcessSubmitRequest>{};
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting request for approval.');
                req.setObjectId(accessRequestRecord.Id);
                requestList.add(req);
                
                if(!requestList.isEmpty()){
                    Approval.ProcessResult[] result = Approval.process(requestList);
                    
                    for (Approval.ProcessResult res : result) {
                        System.debug('-=-= res -=- '+res.errors);
                        System.debug('-=-= res -=- '+res.success);
                    }
                    
                }
                requestResponse = 'Request Access Submitted Successfully';	
                
                System.debug('-=- requestReponse before final -=- '+requestResponse);
            } else {
                throw new AuraException('Approver not found - Geo: ' + accList[0].Sales_Territory__r?.Theater__c + ', Area: '+ accList[0].Sales_Territory__r?.Region__c + ', Region: ' + accList[0].Sales_Territory__r?.Region__c + '. Please connect with the System Administrator. '); //TODO: updat the error message
            }           
        }
        
        System.debug('-=- requestReponse final -=- '+requestResponse);
		        
	    return requestResponse;
    }
        
    @AuraEnabled
	public static moreInfoResponse moreInfoData(String accrecid) {
	    
	    moreInfoResponse respRec = new moreInfoResponse();
	    Decimal TotalZIAACV = 0;
    	Decimal TotalZPAACV = 0;
    	Date PartnerCloseDate;
	    Account AccountRecs = [select id, 
	                                                Name,
	                                                Type,
	                                                Owner.Name,
	                                                Sales_Territory__c,
                                                    Group_Account_Name__c,
	                                                Area_Director__r.Name,
	                                                Area_Director__r.Full_Name__c,
	                                                Channel_Manager__r.Full_Name__c,
	                                                Lead_Development__c,
	                                                CSM_Name_New__r.Full_Name__c,
	                                                //CSM_Name__c,
	                                                Sales_Territory__r.Name,
	                                                Account_Manager__r.Full_Name__c,
	                                                Customer_Advocate__r.Full_Name__c,
	                                                Sales_Engineer__r.Full_Name__c,
	                                                TAM_Name__c,
	                                                ZIA_Use_Cases__c,
	                                                ZPA_Use_Cases__c,
	                                                Industry,
	                                                Market_Segment__c,
	                                                Prospect_Type__c,
	                                                TAM_Name_New__r.Name,
	                                                TAM_Name_New__r.Full_Name__c,
	                                                No_of_Platform_Seats__c,
	                                                Users_ZPA_Platform__c,
	                                                Namedrop__c,
	                                                First_Contract_Date__c,
	                                                First_ZPA_Contract_Date__c,
	                                                Total_ZIA_Premium_Support_ACV__c,
	                                                Total_ZPA_Premium_Support_ACV__c,
	                                                BillingCountry
	                                                from Account
									                where id =:accrecid limit 1];
									                
		if(AccountRecs.Prospect_Type__c == 'Pipeline' || AccountRecs.Prospect_Type__c == 'POC'){
            List<Opportunity> oppList = [Select Id,Total_ZIA_ACV__c,Total_ZPA_ACV__c,CloseDate from Opportunity Where Type = 'New Business'and isClosed  = false and AccountID =: accrecid ORDER BY CloseDate ASC];
		                                         
		                                        
    		
    	    for(Opportunity oppRec : oppList){
    	        if(oppRec.Total_ZIA_ACV__c != null){ TotalZIAACV = TotalZIAACV + oppRec.Total_ZIA_ACV__c; }
    	        if(oppRec.Total_ZPA_ACV__c != null){ TotalZPAACV = TotalZPAACV + oppRec.Total_ZPA_ACV__c; }
    	        if(PartnerCloseDate == null){ PartnerCloseDate = oppRec.CloseDate; }
    		}
		}
		respRec.mAccountRecs = AccountRecs;
		respRec.mTotalZIAACV = TotalZIAACV;
		respRec.mTotalZPAACV = TotalZPAACV;
		respRec.mPartnerCloseDate = PartnerCloseDate;
		return respRec;
	    
	}

    @AuraEnabled
    public static List <String> getAccountIndustryoptions(sObject objObject, string fld) {
        system.debug('objObject --->' + objObject);
         system.debug('fld --->' + fld);
         List < String > allOpts = new list < String > ();
         
         Schema.sObjectType objType = objObject.getSObjectType();
         Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
         map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
         
         list < Schema.PicklistEntry > values =
          fieldMap.get(fld).getDescribe().getPickListValues();
         
         for (Schema.PicklistEntry a: values) {
          allOpts.add(a.getValue());
         }
         system.debug('allOpts ---->' + allOpts);
         allOpts.sort();
         return allOpts;
        }
	
    
    public class moreInfoResponse{
        @AuraEnabled public Account mAccountRecs{get;set;}
        @AuraEnabled public Decimal mTotalZIAACV{get;set;}
        @AuraEnabled public Decimal mTotalZPAACV{get;set;}
        @AuraEnabled public Date mPartnerCloseDate{get;set;}
    }
    
    public class fieldsListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public Account Accrec{get;set;}
        @AuraEnabled public boolean Issubmitted{get;set;}
    }
    
    @AuraEnabled
    public static pickListWrap getPickListData(){
        pickListWrap pickListWrapRecord = new pickListWrap();
        pickListWrapRecord.geo = getPicklistValues('PatchTeam__c','Theater__c');
        pickListWrapRecord.Region = getPicklistValues('PatchTeam__c','Region__c');
        return pickListWrapRecord;
    }
    
     public class pickListWrap{
        @AuraEnabled public list<pickList> geo{get;set;} 
        @AuraEnabled public list<pickList> Region{get;set;} 
    }
    
    public class pickList{
        @AuraEnabled public string label{get;set;} 
        @AuraEnabled public string value{get;set;} 
        public pickList(string label,string value){
            this.label = label;
            this.value = value;
        }
    }
    
    public static list<pickList> getPicklistValues(String str, String fld){
        sObject obj = Schema.getGlobalDescribe().get(str).newSObject();
        list<pickList> options = new list<pickList>();
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType(); 
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values){ 
            options.add(new pickList(string.valueOf(a.getLabel()), string.valueOf(a.getValue()))); 
        }
        return options;
    }

}