/*****************************************************************************************
Name: NFRLicenceTriggerHandler
Copyright © Zscaler
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
VERSION        AUTHOR                  DATE             	 DETAIL              
1.0            NA                      NA               	 Initial Development
2.0			   Varun				   NA					 CR#1920
3.0            Mahesh T		       	   14/04/2022       	 CR#4651 -Fixed Workflow issue
4.0            Mahesh T				   17/05/2022			 CR#4831-(Not to Set PR Status to Decommisioned for NFR RecordType Technology Partners)
5.0			   Mahesh T				   09/14/2022(MM/DD/YYY) IBA-2863  Modified Expiry Date for Technology Partners on Extension
******************************************************************************************/
public class NFRLicenceTriggerHandler {


    private static NFRLicenceTriggerHandler nfrLicenseTriggerHandlerInstance;
    public static NFRLicenceTriggerHandler getNfrLicenseTriggerHandlerInstance() {
        if (nfrLicenseTriggerHandlerInstance == NULL) {
            nfrLicenseTriggerHandlerInstance = new NFRLicenceTriggerHandler();
        }

        return nfrLicenseTriggerHandlerInstance;
    }
    
    public Static Map<Id, RecordType> recordTyepMap = new Map<Id, RecordType>([Select Id, Name from RecordType Where sObjectType = 'NFR__c']);
    
    public static void onBeforeInsert(List<NFR__c> newNFRList){
        //Commented Code - CR# 3535
        /**for(NFR__c rec : newNFRList){
            if(rec.Start_Date__c != null){
                rec.Expiry_Date_FromStartDate__c = rec.Start_Date__c.addMonths(12);
            }
        }*/
    }
    
    public static void OnAfterInsert( List<NFR__c> newNFRList){
        //Commented Code - CR# 3535
        /**List<NFR__c> NFRList = [Select Id
                                ,Approval_Status__c
                                ,Account_Name__r.Id
                                ,Account_Name__r.Account_Manager__r.Id
                                ,ZIA_NFR__c
                                ,ZPA_NFR__c
                                ,SIP__c
                                ,Additional_Organisation_Domain__c
                                ,NFR_SE_Email__c
                                ,Number_of_Users__c
                                ,Organisation_Domain__c
                                ,Partner_Contact__r.Id
                                ,Preferred_Cloud__c
                                ,NFR_Sales_Engineer__c
                                ,Send_Initial_Credentials_To__c
                                ,Expiry_Date_FromStartDate__c
                                ,User_Authentication_Domains__c
                                ,Is_Customer_Using_ZIA__c
                                ,Is_Zapp_used__c
                                ,Comments__c
                                ,Start_Date__c
                                ,RecordTypeId
                                ZIA_Org_ID__c,
                                ZPA_Org_ID__c
                                From NFR__c Where id IN: newNFRList];
        List<Provisioning_Request__c> provisonRequestList = new List<Provisioning_Request__c>();
        Set<Id> NFRIds = new Set<Id>();
        for(NFR__c rec : NFRList){
            Provisioning_Request__c provRequest = new Provisioning_Request__c();
            if(rec.Approval_Status__c == 'Approved' && rec.ZIA_NFR__c == true && rec.SIP__c == true){
                provRequest = provisionRequestCreate(rec, 'ZIA');
                provisonRequestList.add(provRequest);
            }
            else if(rec.Approval_Status__c == 'Approved' && rec.ZIA_NFR__c == true){
                provRequest = provisionRequestCreate(rec, 'ZIA');
                provisonRequestList.add(provRequest);
            }
            else if(rec.Approval_Status__c == 'Approved' && rec.SIP__c == true){
                provRequest = provisionRequestCreate(rec, 'SIP');
                provisonRequestList.add(provRequest);
            }
            if(rec.Approval_Status__c == 'Approved' && rec.ZPA_NFR__c == true){
                provRequest = provisionRequestCreate(rec, 'ZPA');
                provisonRequestList.add(provRequest);
            }
            //CR# 1920 Start
            if(rec.Approval_Status__c == 'Approved' && rec.ZDX_NFR__c == true){
                provRequest = provisionRequestCreate(rec, 'ZDX');
                provisonRequestList.add(provRequest);
            }
            if(rec.Approval_Status__c == 'Approved' && rec.Z_CBI_NFR__c == true){
                provRequest = provisionRequestCreate(rec, 'CBI');
                provisonRequestList.add(provRequest);
            }
            //CR# 1920 End
            if(rec.Start_Date__c != null && recordTyepMap.get(rec.RecordTypeId).Name == 'Technology Partners'){
                rec.Expiry_Date_FromStartDate__c = rec.Start_Date__c.addMonths(12);
            }
            if(rec.Expiry_Date_FromStartDate__c != null){
                NFRIds.add(rec.Id);
            }
        }
        //NFR Approved then Create PR_split_v6 (After insert)
        if(provisonRequestList.size() > 0){ 
            insert provisonRequestList;
            // if PR is 'SIP/(ZDX/CBI - CR# 1920)' then creating POC Product. 
            List<POC_Product__c> POCProductList = preparePOCProductList(provisonRequestList);
            if(POCProductList.size() > 0){
                insert POCProductList;
            }
        }
        //Query the Provisioning Request record related to NFR
        List<Provisioning_Request__c> Provision_RequestList = [Select Id, Provisioning_Status__c From Provisioning_Request__c Where NFR_Form_Link__c IN: NFRIds];
        for(Provisioning_Request__c provRec : Provision_RequestList){
            provRec.Provisioning_Status__c = 'Request Decommission';
        }
        //NFR Expired update PR status
        if(Provision_RequestList.size()>0){
            update Provision_RequestList;
        }**/
    }


    private Map<Id, Map<String, List<String>>> prCloudPOCProductMap;
    private void setPrCloudPOCProductMap(Map<Id, Map<String, List<String>>> prCloudPOCProductMap) {
        this.prCloudPOCProductMap = prCloudPOCProductMap;
    }
    
    public static void OnAfterUpdate(List<NFR__c> newNFRList, Map<ID, NFR__c> oldNFRMap){
        //Updated logic - CR#3535
        Map<Id, NFR__c> NFRMap = new Map<Id, NFR__c> ([Select Id
                                ,Approval_Status__c
                                ,Account_Name__r.Id
                                ,Account_Manager__c
                                ,Account_Name__r.Account_Manager__r.Id
                                ,Account_Name__r.ownerId
                                ,ZIA_NFR__c
                                ,ZPA_NFR__c
                                ,SIP__c
                      	          ,Additional_Organisation_Domain__c
                                ,NFR_SE_Email__c
                                ,Partner_Email__c
                                ,Number_of_Users__c
                                ,Organisation_Domain__c
                                ,Partner_Contact__r.Id
                                ,Preferred_Cloud__c
                                ,NFR_Sales_Engineer__c
                                ,Send_Initial_Credentials_To__c
                                ,Expiry_Date_FromStartDate__c
                                ,NFR_Licence_Status__c
                                ,User_Authentication_Domains__c
                                ,Is_Customer_Using_ZIA__c
                                ,Is_Zapp_used__c
                                ,Comments__c
                                ,RecordTypeId,
                                ZIA_Org_ID__c,
                                ZPA_Org_ID__c,
                                Start_Date__c,
                                Cloud_With_POC_Products__c,
                                Preferred_ZPA_Cloud__c,
                                ZIA_Org_ID_to_be_associated_with_ZPA__c,
                                Account_Area__c,Account_Sub_Region__c
                                From NFR__c Where id IN: newNFRList]);
        
        List<Provisioning_Request__c> provisonRequestList = new List<Provisioning_Request__c>();
        Set<Id> statusChangedNFRIds = new Set<Id>();
        Set<Id> statusExpairedNFRIds = new Set<Id>();
        
        List<String> productSKUList = new List<String>();
        
        for(NFR__c rec : NFRMap.values()){
            Provisioning_Request__c provRequest = new Provisioning_Request__c();
            
            
            Map<String, List<String>> cloudPOCProductMap = new Map<String, List<String>>();
            
            if (String.isNotBlank(rec.Cloud_With_POC_Products__c)) {
                cloudPOCProductMap = (Map<String, List<String>>) JSON.deserialize(rec.Cloud_With_POC_Products__c, Map<String, List<String>>.class);
            }
                   
            if((oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c) && (rec.Approval_Status__c == 'Approved') && (cloudPOCProductMap!=null)){
                for (String prType : cloudPOCProductMap.keyset()) {
                    
                    productSKUList.addAll(cloudPOCProductMap.get(prType));
                    
                    provRequest = provisionRequestCreateUpdated(rec, prType);
                    provisonRequestList.add(provRequest);
                }
            }
            
            System.debug('rec.Approval_Status__c' + rec.Approval_Status__c);
            System.debug('rec.NFR_Licence_Status__c' + rec.NFR_Licence_Status__c);
            
            if((oldNFRMap.get(rec.Id).NFR_Licence_Status__c != rec.NFR_Licence_Status__c && rec.NFR_Licence_Status__c == 'Extension Requested'
              && oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Extension Requested' ) || 
              (oldNFRMap.get(rec.Id).NFR_Licence_Status__c != rec.NFR_Licence_Status__c && rec.NFR_Licence_Status__c == 'Extension In Progress'
              && oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Extension In Progress' &&
              (rec.Account_Area__c=='WW' || rec.Account_Sub_Region__c=='AMS National') && recordTyepMap.get(rec.RecordTypeId).Name == 'Partners')
               /**&& recordTyepMap.get(rec.RecordTypeId).Name == 'Partners'*/){
                   
                    Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
                	newApprovalRequest.setComments('Submit for Manager\'s approval');
                	newApprovalRequest.setObjectId(rec.Id);
                	newApprovalRequest.setSubmitterId(UserInfo.getUserId());
                	Approval.ProcessResult result = Approval.process(newApprovalRequest);
            }
            if(oldNFRMap.get(rec.Id).NFR_Licence_Status__c != rec.NFR_Licence_Status__c && rec.NFR_Licence_Status__c == 'Expiration Requested'
              && oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Expiration Requested' && recordTyepMap.get(rec.RecordTypeId).Name == 'Partners' ){
                  	Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
                	newApprovalRequest.setComments('Submit for Manager\'s approval');
                	newApprovalRequest.setObjectId(rec.Id);
                	newApprovalRequest.setSubmitterId(UserInfo.getUserId());
                	Approval.ProcessResult result = Approval.process(newApprovalRequest);
            }
            
        }
          
        if (!provisonRequestList.isEmpty()) {
            INSERT provisonRequestList;
        }    
       
        Set<String> productSKUSet = new Set<String> ();
        productSKUSet.addALL(productSKUList);
       
        NFRLicenceTriggerHelper instance = NFRLicenceTriggerHelper.getInstance();
        instance.generateSkuProductMap(productSKUSet);
        
        List<POC_Product__c> POCProductList = new List<POC_Product__c> ();

        Map<Id, Map<String, List<String>>> prCloudPOCProductMap = new Map<Id, Map<String, List<String>>> ();

        for (Provisioning_Request__c pr : provisonRequestList) {

            Map<String, List<String>> cloudPOCProductMap = new Map<String, List<String>>();
            
            NFR__c rec = NFRMap.get(pr.NFR_Form_Link__c);
            
            if (String.isNotBlank(rec.Cloud_With_POC_Products__c)) {
                cloudPOCProductMap = (Map<String, List<String>>) JSON.deserialize(rec.Cloud_With_POC_Products__c, Map<String, List<String>>.class);

                prCloudPOCProductMap.put(pr.Id, cloudPOCProductMap);
            }
            
            instance.setProvReq(pr);
            instance.setCloudPOCProductMap(cloudPOCProductMap);
            
            POCProductList.addAll(instance.preparePOCProductListUpdated1());
            
        }
       
        INSERT POCProductList;
        
        if(!TriggerUtility2.isNFRafterUpdateExecuted()){
            NFRLicenceTriggerHandler nfrLicenseTriggerHandlerInstance = NFRLicenceTriggerHandler.getNfrLicenseTriggerHandlerInstance();
            nfrLicenseTriggerHandlerInstance.setPrCloudPOCProductMap(prCloudPOCProductMap);

        	nfrLicenseTriggerHandlerInstance.updateProvisioningFields(newNFRList, oldNFRMap);
        }
        
    }
        
    public static void OnBeforeUpdate(List<NFR__c> newNFRList,Map<ID, NFR__c> oldNFRMap){
        
        Set<Id> statusChangedNFRIds = new Set<Id>();
        
        for(NFR__c rec : newNFRList){
            if(oldNFRMap.get(rec.Id).Start_Date__c != rec.Start_Date__c && rec.Start_Date__c != null){
                if(rec.Start_Date__c != null){
                    rec.Expiry_Date_FromStartDate__c = rec.Start_Date__c.addMonths(12);
                }
            }
            
             //CR#4651 Deactivated Workfow NFR Update Additional Org Domain and moved the logic to beforeupdate 
			if(rec.OwnerId !=null && rec.NFR_Sales_Engineer__c != null && oldNFRMap.get(rec.Id).NFR_Sales_Engineer__c != rec.NFR_Sales_Engineer__c ){        
                    rec.NFR_SE_Email__c = rec.NFR_Sales_Engineer__r.Email;  
            }
            //CR# 1920 Start
            if(oldNFRMap.get(rec.Id).NFR_Licence_Status__c != rec.NFR_Licence_Status__c && rec.NFR_Licence_Status__c == 'Expiration Requested'){
            		rec.Approval_Status__c = 'Expiration Requested';
              }
            
            if(oldNFRMap.get(rec.Id).NFR_Licence_Status__c != rec.NFR_Licence_Status__c && rec.NFR_Licence_Status__c == 'Extension Requested'
              && oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Extension Requested'){
            		rec.Send_Extension_Email__c = true;
              }
            
            if(oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Extended' && recordTyepMap.get(rec.RecordTypeId).Name == 'Partners'){
                rec.NFR_Licence_Status__c = 'Extended';
                if(rec.Number_of_Extensions__c != null){
                    rec.Number_of_Extensions__c = rec.Number_of_Extensions__c + 1;
                }
                else{
                    rec.Number_of_Extensions__c = 1;
                }
                if(rec.Expiry_Date_FromStartDate__c != null){
                    rec.Expiry_Date_FromStartDate__c = rec.Expiry_Date_FromStartDate__c.addMonths(12);
                }
            }
            if(oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && (rec.Account_Area__c=='WW' || rec.Account_Sub_Region__c=='AMS National') && rec.Approval_Status__c == 'Extension Requested' ){
                rec.NFR_Licence_Status__c = 'Extension In Progress';
                rec.Approval_Status__c = 'Extension In Progress';
                rec.Send_Extension_Email__c = true;
            }
            
            //CR# 1920 End
            //NFR Extension: Checking licence status if is changed to 'In-Progress' then update the Expiry date,licence status and Number of Extension.
            if(oldNFRMap.get(rec.Id).NFR_Licence_Status__c != rec.NFR_Licence_Status__c && rec.NFR_Licence_Status__c == 'Extended' && recordTyepMap.get(rec.RecordTypeId).Name == 'Technology Partners'){
                
                rec.NFR_Licence_Status__c = 'Acive';
                if(rec.Number_of_Extensions__c != null){
                    rec.Number_of_Extensions__c = rec.Number_of_Extensions__c + 1;
                }
                else{
                    rec.Number_of_Extensions__c = 1;
                }
                if(rec.Expiry_Date_FromStartDate__c != null){
                    //IBA-2863 Modified for Technology Partners--Mahesh T	
                    rec.Expiry_Date_FromStartDate__c = system.today().addMonths(12);
                }
            }
            
            
            if(oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Approved'){
                if(recordTyepMap.get(rec.RecordTypeId).Name == 'Technology Partners'){
                    rec.Expiry_Date_FromStartDate__c = system.today().addMonths(12);
                }
            }
            
            if(oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Submitted'){
                rec.Submitted_by__c = UserInfo.getUserId();
            }
            //updateProvisioningStatus(statusChangedNFRIds, 'Extended');Commented As Part of CR# 1920
        }
    } 
       
    public static Provisioning_Request__c provisionRequestCreateUpdated(NFR__c rec, String NFRType){
        
        Id NFRRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('NFR Licence').getRecordTypeId();
        Id cbiRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Cloud Browser Isolation (C.B.I)').getRecordTypeId();//CR#1920

        String preferedCloud =  NFRType.equalsIgnoreCase('ZPA') ? rec.Preferred_ZPA_Cloud__c :rec.Preferred_Cloud__c;
        
        Provisioning_Request__c provRequest = new Provisioning_Request__c();
        provRequest.Account_Manager__c = rec.Account_Name__r.Account_Manager__r.Id;
        if(rec.Account_Manager__c!=null){
            provRequest.Account_Manager__c = rec.Account_Manager__c;
        }
        provRequest.Account__c = rec.Account_Name__r.Id;
        provRequest.Additional_Organization_domains__c = rec.Additional_Organisation_Domain__c;
        provRequest.NFR_Form_Link__c = rec.Id;
        provRequest.NFR_SE_Email_PR__c = rec.NFR_SE_Email__c;
        provRequest.Number_of_Users__c = rec.Number_of_Users__c;
        provRequest.Organization_Domain__c = rec.Organisation_Domain__c;
        provRequest.Partner_Contact__c = rec.Partner_Contact__r.Id;
        provRequest.ZIA_Org_ID_to_be_used_for_Zapp__c = rec.ZIA_Org_ID_to_be_associated_with_ZPA__c;
        provRequest.Product_Line_for_PR__c = NFRType;

        provRequest.Preferred_Cloud__c = preferedCloud; 
        
        provRequest.Provisioning_Status__c = 'Requested';
        provRequest.RecordTypeId = NFRRecordTypeId;
        provRequest.SE__c = rec.NFR_Sales_Engineer__c;
        provRequest.Eval_Comments__c = rec.Comments__c;
        //CR# 1920 Start
        provRequest.ZIA_Org_ID__c=rec.ZIA_Org_ID__c;
        provRequest.ZPA_Org_ID__c=rec.ZPA_Org_ID__c;

        if(NFRType == 'CBI'){
        	provRequest.RecordTypeId = cbiRecordTypeId;
        }
        
        //CR# 1920 End            
        //CR# 1920 End
        provRequest.User_Authentication_Domains__c = rec.User_Authentication_Domains__c;
        provRequest.Is_Customer_Using_ZIA__c = rec.Is_Customer_Using_ZIA__c;
        provRequest.Is_Zapp_used__c = rec.Is_Zapp_used__c;
        
        provRequest.Send_Initial_l__c = rec.Send_Initial_Credentials_To__c;
        return provRequest;
    }
    
    //Start CR# 1920
    public void updateProvisioningFields(List < NFR__c > newList, Map<Id, NFR__c> oldmap){
        Id techPartnerRecordTypeId = Schema.SObjectType.NFR__c.getRecordTypeInfosByDeveloperName().get('Technology_Partners').getRecordTypeId();
        Map<Id, NFR__c> mapOfNFRAndDetails =  new Map<Id, NFR__c>();
        List<Provisioning_Request__c> listOfPR = new List<Provisioning_Request__c>(); 
        Set<ID> NFRIdSet = new Set<ID>();
        for(NFR__c NFRRec : newList){
            if(NFRRec.Approval_Status__c == 'Approved' || NFRRec.NFR_Licence_Status__c == 'Expired' || NFRRec.NFR_Licence_Status__c == 'In-Progress' || NFRRec.Approval_Status__c == 'Extension In Progress'
               || NFRRec.Approval_Status__c == 'Extension Requested' || NFRRec.NFR_Licence_Status__c == 'Extended' || NFRRec.NFR_Licence_Status__c == 'Expiration Requested' ||  NFRRec.Approval_Status__c == 'Extended')
            	mapOfNFRAndDetails.put(NFRRec.Id,NFRRec);
        }
        for(Provisioning_Request__c provRec : [Select Id, Provisioning_Status__c,NFR_Form_Link__c,ZIA_Org_ID__c,ZPA_Org_ID__c,Product_Line_for_PR__c,
                                               Additional_Organization_domains__c,Account__c,NFR_SE_Email_PR__c,Number_of_Users__c,Products__c,
                                               Organization_Domain__c,Partner_Contact__c,Preferred_Cloud__c,SE__c,Eval_Comments__c,
                                               Send_Initial_l__c,User_Authentication_Domains__c,Is_Customer_Using_ZIA__c,Is_Zapp_used__c
                                               From Provisioning_Request__c Where NFR_Form_Link__c IN: mapOfNFRAndDetails.keySet()]) {

            
            Map<String, List<String>> cloudPOCProductMap = prCloudPOCProductMap.containsKey(provRec.Id) ? prCloudPOCProductMap.get(provRec.Id) : new Map<String, List<String>>();

            List<String> skuIdProductList = new List<String> ();

            if (cloudPOCProductMap.containsKey(provRec.Product_Line_for_PR__c)) {
                skuIdProductList = cloudPOCProductMap.get(provRec.Product_Line_for_PR__c);

                provRec.Products__c = String.join(skuIdProductList, ';');

            }
                                     
            if(mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).RecordTypeId == techPartnerRecordTypeId){
             //	Commented below as part of CR#4831-Start Request to Not to Set PR Status to Decommisioned for NFR RecordType Technology Partners)
              /*  if(oldmap.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c == 'Expiration Requested'){
                	provRec.Provisioning_Status__c = 'Request Decommission';
            	}
            	if(oldmap.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c == 'Expired'){  
            		provRec.Provisioning_Status__c = 'Decommissioned';
            	}  --CR#4381 End */
            	if(oldmap.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c == 'Acive' && oldmap.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c=='Extension In Progress'){
                	provRec.Provisioning_Status__c = 'Extended';
            	}  
            }else{
                if(oldmap.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c == 'Expiration Requested'){
                	provRec.Provisioning_Status__c = 'Request Decommission';
            	}
            	if(oldmap.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c == 'Expired'){
                	provRec.Provisioning_Status__c = 'Decommissioned';
            	}
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).Approval_Status__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Approval_Status__c &&
               (mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Approval_Status__c == 'Extension Requested' || mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Approval_Status__c == 'Extension In Progress')){
                provRec.Provisioning_Status__c = 'Request Extension';
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Licence_Status__c == 'Extended'){
                provRec.Provisioning_Status__c = 'Extended';
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).ZIA_Org_ID__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).ZIA_Org_ID__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).ZIA_Org_ID__c !=Null && (provRec.Provisioning_Status__c!=Null && provRec.Provisioning_Status__c=='Provisioned')){
                provRec.ZIA_Org_ID__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).ZIA_Org_ID__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).ZPA_Org_ID__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).ZPA_Org_ID__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).ZPA_Org_ID__c !=Null && (provRec.Provisioning_Status__c!=Null && provRec.Provisioning_Status__c=='Provisioned')){
                provRec.ZPA_Org_ID__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).ZPA_Org_ID__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).Additional_Organisation_Domain__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Additional_Organisation_Domain__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Additional_Organisation_Domain__c !=Null){
                provRec.Additional_Organization_domains__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Additional_Organisation_Domain__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).Account_Name__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Account_Name__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Account_Name__c !=Null){
                provRec.Account__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Account_Name__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).NFR_SE_Email__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_SE_Email__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_SE_Email__c !=Null){
                provRec.NFR_SE_Email_PR__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_SE_Email__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).Number_of_Users__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Number_of_Users__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Number_of_Users__c !=Null){
                provRec.Number_of_Users__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Number_of_Users__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).Organisation_Domain__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Organisation_Domain__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Organisation_Domain__c !=Null){
                provRec.Organization_Domain__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Organisation_Domain__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).Partner_Contact__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Partner_Contact__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Partner_Contact__c !=Null){
                provRec.Partner_Contact__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Partner_Contact__r.Id;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).Preferred_Cloud__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Preferred_Cloud__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Preferred_Cloud__c !=Null){
                provRec.Preferred_Cloud__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Preferred_Cloud__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).NFR_Sales_Engineer__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Sales_Engineer__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Sales_Engineer__c !=Null){
                provRec.SE__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).NFR_Sales_Engineer__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).Comments__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Comments__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Comments__c !=Null){
                provRec.Eval_Comments__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Comments__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).Send_Initial_Credentials_To__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Send_Initial_Credentials_To__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Send_Initial_Credentials_To__c !=Null){
                provRec.Send_Initial_l__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Send_Initial_Credentials_To__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).User_Authentication_Domains__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).User_Authentication_Domains__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).User_Authentication_Domains__c !=Null){
                provRec.User_Authentication_Domains__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).User_Authentication_Domains__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).Is_Customer_Using_ZIA__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Is_Customer_Using_ZIA__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Is_Customer_Using_ZIA__c !=Null){
                provRec.Is_Customer_Using_ZIA__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Is_Customer_Using_ZIA__c;
            }
            if(oldmap.get(provRec.NFR_Form_Link__c).Is_Zapp_used__c != mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Is_Zapp_used__c && mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Is_Zapp_used__c !=Null){
                provRec.Is_Zapp_used__c = mapOfNFRAndDetails.get(provRec.NFR_Form_Link__c).Is_Zapp_used__c;
            }
            listOfPR.add(provRec);
        }
        if(!listOfPR.isEmpty()){
            update listOfPR;
            TriggerUtility2.PRNFRFieldUpdateExecuted();
        }
       
    }
    //End CR# 1920
}