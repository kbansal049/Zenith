/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-10-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Equipment_RequestTriggerhandler {
    
    List<Equipment_Request__c> recordNewList = new List<Equipment_Request__c>();
    List<Equipment_Request__c> recordOldList = new List<Equipment_Request__c>();
    Map<Id, Equipment_Request__c> recordNewMap = new Map<Id, Equipment_Request__c>();
    Map<Id, Equipment_Request__c> recordOldMap = new Map<Id, Equipment_Request__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public Equipment_RequestTriggerhandler(List<Equipment_Request__c> newList, List<Equipment_Request__c> oldList, Map<Id, Equipment_Request__c> newMap, Map<Id, Equipment_Request__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.recordNewList = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent(){
        UpdatePrimaryProjectCustomerContact(recordNewList);
    }
    
    public void BeforeUpdateEvent(){
        UpdatePrimaryProjectCustomerContact(recordNewList);
        //CR# 3552 Bikram : Check for Approval process reject field validation, Comments
        rejectionFieldValidation(this.recordNewList,this.recordOldMap);
    }
    
    public void BeforeDeleteEvent(){
        //CR# 2559 Bikram : Prevent Core SE profile users to delete the request if record is locked state due to approval process.
        restrictDeletionEquipmentRequest(this.recordOldMap);
    }
    
    public void AfterInsertEvent(){
        //CR# 3552 START : Bikram
        List <Opportunity> opportunityUpdate = new List <Opportunity>();
        Map<Id, Equipment_Request__c> psEquipReqIdAppProc1SubmittedMap = new Map<Id, Equipment_Request__c>();
        Map<Id, Equipment_Request__c> psEquipReqIdAppProc2SubmittedMap = new Map<Id, Equipment_Request__c>();
        for(Equipment_Request__c equipReqRecord : this.recordNewMap.values()){
            
            
            
            if(equipReqRecord.Type__c == 'Early Engagement' &&
               equipReqRecord.Early_Engagement_Approval_Process_Status__c != NULL){
                   if(equipReqRecord.Early_Engagement_Approval_Process_Status__c == 'Approval Process 1 (One Step Approval) - Submitted'){
                       psEquipReqIdAppProc1SubmittedMap.put(equipReqRecord.Id,equipReqRecord);
                   }
                   if(equipReqRecord.Early_Engagement_Approval_Process_Status__c == 'Approval Process 2 (Geo based approval) - Submitted'){
                       psEquipReqIdAppProc2SubmittedMap.put(equipReqRecord.Id,equipReqRecord);
                   }
               }
        }
        if(!psEquipReqIdAppProc1SubmittedMap.isEmpty()){
            createEmailWrapperForPSEarlyEngagement(psEquipReqIdAppProc1SubmittedMap, 'Approval_Process_1_Notification_Email_sent_to_the_submitter');
        }
        if(!psEquipReqIdAppProc2SubmittedMap.isEmpty()){
            createEmailWrapperForPSEarlyEngagement(psEquipReqIdAppProc2SubmittedMap, 'Approval_Process_1_Notification_Email_sent_to_the_submitter');
        }
        //if(opportunityUpdate!=null){
        ////    update opportunityUpdate;
        //}
        //CR# 3552 END : Bikram
    }
    
    public void AfterUpdateEvent(){
        //CR# 3552 START : Bikram
        Map<Id, Equipment_Request__c> psEquipReqIdAppProc1ApprovedSet = new Map<Id, Equipment_Request__c>();
        Map<Id, Equipment_Request__c> psEquipReqIdAppProc2ApprovedSet = new Map<Id, Equipment_Request__c>();        
        Map<Id, Equipment_Request__c> psEquipReqIdToSendRejectionEmailMap = new Map<Id, Equipment_Request__c>();
        Map<Id, Equipment_Request__c> psEquipReqIdToSendRejectionEmailAppProc2Map = new Map<Id, Equipment_Request__c>();
        //Set<Id> opportunityId = new Set<Id>();
        //Set<Id> opportunityId2 = new Set<Id>();
        Map<String, String> opportunityUpdate = new Map<String, String>();
        Map<Id,String> Product_SKU = new Map<Id,String>();
        
        
        for(Equipment_Request__c equipReqRecord : this.recordNewMap.values()){
            Equipment_Request__c oldER = this.recordOldMap.get(equipReqRecord.Id);
            
            if(equipReqRecord.Record_Type_Name__c=='Restricted SKU\'s' && equipReqRecord.Approval_Status__c == 'Approved' && oldER.Approval_Status__c != 'Approved'){
                //opportunityId.add(equipReqRecord.Opportunity__c);
                 //Opportunity opp = new Opportunity();
                 //opp = oppMapID.get(equipReqRecord.Opportunity__c);
                //if(oldER.Approval_Status__c != 'Approved'){
                  //  opportunityId2.add(equipReqRecord.Opportunity__c);
                    Product_SKU.put(equipReqRecord.Opportunity__c,equipReqRecord.Product_SKU__c);
              ///  }
                
                if(equipReqRecord.Country_Language__c!=null){
                	//opportunityId.add(equipReqRecord.Opportunity__c);
                    opportunityUpdate.put(equipReqRecord.Opportunity__c,equipReqRecord.Country_Language__c);
                }
                
            }
            
            if(equipReqRecord.Type__c == 'Early Engagement' &&
               equipReqRecord.Early_Engagement_Approval_Process_Status__c != NULL){
                   if(equipReqRecord.Early_Engagement_Approval_Process_Status__c == 'Approval Process 1 (One Step Approval) - Approved' && 
                      this.recordOldMap.get(equipReqRecord.Id).Early_Engagement_Approval_Process_Status__c != 'Approval Process 1 (One Step Approval) - Approved'){
                          psEquipReqIdAppProc1ApprovedSet.put(equipReqRecord.Id,equipReqRecord);
                      }
                   if(equipReqRecord.Early_Engagement_Approval_Process_Status__c == 'Approval Process 2 (Geo based approval) - Approved' && 
                      this.recordOldMap.get(equipReqRecord.Id).Early_Engagement_Approval_Process_Status__c != 'Approval Process 2 (Geo based approval) - Approved'){
                          psEquipReqIdAppProc2ApprovedSet.put(equipReqRecord.Id,equipReqRecord);
                      }
                   if(equipReqRecord.Early_Engagement_Approval_Process_Status__c == 'Approval Process 1 (One Step Approval) - Rejected' && 
                      this.recordOldMap.get(equipReqRecord.Id).Early_Engagement_Approval_Process_Status__c != 'Approval Process 1 (One Step Approval) - Rejected'){
                          psEquipReqIdToSendRejectionEmailMap.put(equipReqRecord.Id,equipReqRecord);
                      }
                   //CR# 4478 - Bikram 22nd Mar 22 START
                   if(equipReqRecord.Early_Engagement_Approval_Process_Status__c == 'Approval Process 2 (Geo based approval) - Rejected' && 
                      this.recordOldMap.get(equipReqRecord.Id).Early_Engagement_Approval_Process_Status__c != 'Approval Process 2 (Geo based approval) - Rejected'){
                          psEquipReqIdToSendRejectionEmailAppProc2Map.put(equipReqRecord.Id,equipReqRecord);
                      }
                   //CR# 4478 - Bikram 22nd Mar 22 END
               }
        }
        
        if(!Product_SKU.keyset().isEmpty()){
            
            List<Opportunity> updateOpportunity = new List<Opportunity>();
            List <Opportunity> opportunityToUpdate = [Select id,name,Country_Language__c,Approved_PRE_SKUs_ER__c from Opportunity where Id IN:Product_SKU.keySet()];
            for(Opportunity opp : opportunityToUpdate){
                if(opportunityUpdate.containsKey(opp.Id)){
                    if(!String.isBlank(opp.Country_Language__c) && !opp.Country_Language__c.CONTAINS(opportunityUpdate.get(opp.Id))){
                        opp.Country_Language__c = opp.Country_Language__c+';'+opportunityUpdate.get(opp.Id);
                    }
                    else if(String.isBlank(opp.Country_Language__c)){
                        opp.Country_Language__c = opportunityUpdate.get(opp.Id);
                    }
                    //updateOpportunity.add(opp);
                }
                if(opp.Approved_PRE_SKUs_ER__c != null &&  !opp.Approved_PRE_SKUs_ER__c.containsIgnoreCase(Product_SKU.get(opp.Id))){
                        opp.Approved_PRE_SKUs_ER__c=opp.Approved_PRE_SKUs_ER__c + '; ' + Product_SKU.get(opp.Id);
                        //updateOpportunity.add(opp);
                 }
                else if(String.isBlank(opp.Approved_PRE_SKUs_ER__c)){
                        opp.Approved_PRE_SKUs_ER__c = Product_SKU.get(opp.Id);
                        //updateOpportunity.add(opp);
                 }
                   updateOpportunity.add(opp);
                
            }
            
            if(updateOpportunity!=null){
                update updateOpportunity;
            }
            
           /* if(opportunityId2!=null){
                List <Opportunity> opportunityToUpdate2 = [Select id,Approved_PRE_SKUs_ER__c from Opportunity where Id IN:opportunityId2];
                for(Opportunity opp : opportunityToUpdate2){
                    
                    if(opp.Approved_PRE_SKUs_ER__c != null &&  !opp.Approved_PRE_SKUs_ER__c.containsIgnoreCase(Product_SKU.get(opp.Id))){
                        opp.Approved_PRE_SKUs_ER__c=opp.Approved_PRE_SKUs_ER__c + '; ' + Product_SKU.get(opp.Id);
                        updateOpportunity.add(opp);
                    }
                    else if(String.isBlank(opp.Approved_PRE_SKUs_ER__c)){
                        opp.Approved_PRE_SKUs_ER__c = Product_SKU.get(opp.Id);
                        updateOpportunity.add(opp);
                    }
                }
            }*/
            
           
        }
        
        if(!psEquipReqIdAppProc1ApprovedSet.isEmpty()){
            createEmailWrapperForPSEarlyEngagement(psEquipReqIdAppProc1ApprovedSet, 'Approval_Process_1_Approved_Email_sent_to_the_submitter');
        }
        if(!psEquipReqIdAppProc2ApprovedSet.isEmpty()){
            createEmailWrapperForPSEarlyEngagement(psEquipReqIdAppProc2ApprovedSet, 'Approval_Process_1_Approved_Email_sent_to_the_submitter');
        }
        if(!psEquipReqIdToSendRejectionEmailMap.isEmpty()){
            createEmailWrapperForPSEarlyEngagement(psEquipReqIdToSendRejectionEmailMap, 'Approval_Process_1_Rejection_Email_sent_to_the_submitter');
        }
        //CR# 4478 - Bikram 22nd Mar 22 START
        if(!psEquipReqIdToSendRejectionEmailAppProc2Map.isEmpty()){
            createEmailWrapperForPSEarlyEngagement(psEquipReqIdToSendRejectionEmailAppProc2Map, 'Approval_Process_1_Rejection_Email_sent_to_the_submitter');
        }
        //CR# 4478 - Bikram 22nd Mar 22 END
        //CR# 3552 END : Bikram
    }
    
    public void AfterDeleteEvent(){}
    
    public void AfterUndeleteEvent(){}
    
    /*Method for Update Opportunity's Professional service Request Submitted Fields and Update Primary_Project_Customer_Contact__c from 2 values*/
    public void UpdatePrimaryProjectCustomerContact(List<Equipment_Request__c> recordNewList){
        
        Set<Id> OpportunityIdSet = new Set<Id>();
        
        Map<Id, Opportunity> OpportunityChangeMap = new Map<Id, Opportunity>();
        
        /*Loop for getting opportunities which fields have to update and making sets of Opportunity Id's*/
        for(Equipment_Request__c er : recordNewList){
            
            OpportunityIdSet.add(er.Opportunity__c);
            
            //if(isInsert){
            
            /*if(ER.Approval_Status__c == 'Pending Approval' &&  ER.Stage__c == 'Open' /* er.Type__c == 'Others' || er.Type__c == 'Federal' || er.Type__c == 'Early Engagement' ){

OpportunityChangeMap.put(er.Opportunity__c, new Opportunity(Id = er.Opportunity__c, Professional_Service_Request_Submitted__c = true));

}else{

//OpportunityChangeMap.put(er.Opportunity__c, new Opportunity(Id = er.Opportunity__c, Professional_Service_Request_Submitted__c = false));
}
*/
            
            // }
        }
        
        //Update Professional service Request Submitted field on basis of Equipment Type field values
        if(!OpportunityChangeMap.isEmpty()){
            try{
                update OpportunityChangeMap.values();
            }catch(Exception e){
                System.debug(e.getMessage());
            }
        }
        
        Map<Id, Opportunity> OpportunityMap = new Map<Id, Opportunity>([SELECT Id, Name, Deployment_contact__c, 
                                                                        Primary_Project_Contact_Name__c, 
                                                                        Primary_Project_Contact_Email__c 
                                                                        FROM Opportunity
                                                                        WHERE Id IN : OpportunityIdSet]);
        
        /*Loop for Updating Primary_Project_Customer_Contact__c fields update from Opportunity Deployment_contact__c fields OR Primary_Project_Contact_Name__c fields*/
        for(Equipment_Request__c er : recordNewList){
            
            String Deploymentcontact = OpportunityMap.get(er.Opportunity__c).Deployment_contact__c;
            
            if(String.isNotBlank(Deploymentcontact) && String.isNotEmpty(Deploymentcontact)){
                
                er.Primary_Project_Customer_Contact__c = Deploymentcontact;
            }else{
                er.Secondary_Project_Customer_Contact_text__c  = OpportunityMap.get(er.Opportunity__c).Primary_Project_Contact_Name__c;
                er.Secondary_Project_Customer_Email_text__c  = OpportunityMap.get(er.Opportunity__c).Primary_Project_Contact_Email__c ;
               // er.Secondary_Project_Customer_Phone_Text__c  = OpportunityMap.get(er.Opportunity__c).Primary_Project_Contact_Phone__c ;
            }
        }
    }
    
    //CR# 2559 Bikram : Prevent Core SE profile users to delete the request if record is locked state due to approval process.
    public void restrictDeletionEquipmentRequest(Map<Id, Equipment_Request__c> equipmentReqOldMap){
        Map<Id,Boolean> recordLockStatus = new Map<Id,Boolean>();
        if(!equipmentReqOldMap.isEmpty()){
            recordLockStatus = Approval.isLocked(new List<Id>(equipmentReqOldMap.keySet()));            
        }
        if(!recordLockStatus.isEmpty()){
            List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            String loggedInUserProfileName = profileList[0].Name;
            for(Equipment_Request__c equipReq : equipmentReqOldMap.values()){
                if(loggedInUserProfileName == 'Core Sales - SE' && recordLockStatus.get(equipReq.Id)){
                    equipReq.addError('Record is Locked, cannot perform delete operation.');
                }
            }
        }
    }
    
    //CR# 3552 Bikram : Check for Approval process reject field validation, Comments
    public void rejectionFieldValidation(List<Equipment_Request__c> triggerNew, Map<Id, Equipment_Request__c> triggerMapOld){
        Map<Id, Equipment_Request__c> rejectedPSEarlyEngagementRequests = new Map<Id, Equipment_Request__c>();
        String fundReqRecs;   
        for(Equipment_Request__c equipReqRecord : triggerNew){
            if((triggerMapOld.get(equipReqRecord.Id).Early_Engagement_Approval_Process_Status__c != 'Approval Process 1 (One Step Approval) - Rejected' ||
                triggerMapOld.get(equipReqRecord.Id).Early_Engagement_Approval_Process_Status__c != 'Approval Process 2 (Geo based approval) - Rejected' )
               && 
               (equipReqRecord.Early_Engagement_Approval_Process_Status__c == 'Approval Process 1 (One Step Approval) - Rejected' ||
                equipReqRecord.Early_Engagement_Approval_Process_Status__c == 'Approval Process 2 (Geo based approval) - Rejected')){
                    rejectedPSEarlyEngagementRequests.put(equipReqRecord.Id,equipReqRecord);
                }
        }
        
        if(!rejectedPSEarlyEngagementRequests.isEmpty()){
            Set<Id> processInstanceIds = new Set<Id>();
            Map<Id,String> equipmentRequestIdCreatedByEmailMap = new Map<Id,String>();
            //Get the most recent approval process instance for the object.
            // If there are some approvals to be reviewed for approval, then
            // get the most recent process instance for each object.
            for (Equipment_Request__c equipReqRecs : [SELECT Id,CreatedBy.Email,
                                                      (SELECT ID
                                                       FROM ProcessInstances
                                                       ORDER BY CreatedDate DESC
                                                       LIMIT 1)
                                                      FROM Equipment_Request__c
                                                      WHERE ID IN :rejectedPSEarlyEngagementRequests.keySet()])
            {
                processInstanceIds.add(equipReqRecs.ProcessInstances[0].Id);
                equipmentRequestIdCreatedByEmailMap.put(equipReqRecs.Id,equipReqRecs.CreatedBy.Email);
            }
            
            // Now that we have the most recent process instances, we can check
            // the most recent process steps for comments. 
            for (ProcessInstance pi : [SELECT TargetObjectId,
                                       (SELECT Id, StepStatus, Comments 
                                        FROM Steps
                                        WHERE (StepStatus != 'Approved' OR StepStatus != 'Rejected')
                                        ORDER BY CreatedDate DESC
                                        LIMIT 1 )
                                       FROM ProcessInstance
                                       WHERE Id IN :processInstanceIds
                                       ORDER BY CreatedDate DESC])   
            {
                if(!pi.Steps.isEmpty() && rejectedPSEarlyEngagementRequests.containsKey(pi.TargetObjectId)){
                    if (String.isBlank(pi.Steps[0].Comments) &&
                        String.isBlank(rejectedPSEarlyEngagementRequests.get(pi.TargetObjectId).Approval_Process_Rejection_Comments__c))
                    {
                        rejectedPSEarlyEngagementRequests.get(pi.TargetObjectId).addError(
                            'Approval Process Error : Please provide Rejection Comment');
                    }else {
                        if(String.isNotBlank(rejectedPSEarlyEngagementRequests.get(pi.TargetObjectId).Approval_Process_Rejection_Comments__c) && 
                           String.isNotBlank(pi.Steps[0].Comments)){
                               rejectedPSEarlyEngagementRequests.get(pi.TargetObjectId).Approval_Process_Rejection_Comments__c += ', ' + pi.Steps[0].Comments.trim();
                           }else if(String.isNotBlank(pi.Steps[0].Comments)){
                               rejectedPSEarlyEngagementRequests.get(pi.TargetObjectId).Approval_Process_Rejection_Comments__c = pi.Steps[0].Comments.trim();
                           }
                    }
                    System.debug('rejectedPSEarlyEngagementRequests.get(pi.TargetObjectId) : ' + rejectedPSEarlyEngagementRequests.get(pi.TargetObjectId));
                }
            }
        }
    }
    
    //CR# 3552 Bikram : Get Related field details, equipReqRecord.Opportunity__r.Account.Account_Manager__r.Email
    private List<Equipment_Request__c> getEquipmentRecordRelatedFields(Set<Id> recordIdSet){
        
        List<Equipment_Request__c> equipmentRecordList = new List<Equipment_Request__c>();
        equipmentRecordList = [SELECT Id,CreatedBy.Email,
                               Opportunity__r.Account.Account_Manager__r.Email,
                               Opportunity__r.Account.CSM_Name_New__r.Email,
                               Opportunity__r.Account.CSM_Name_2__r.email,
                               // Added by Arsh - CR# 4543 -start
                               Opportunity__r.Account.TAM_Name_New__r.Email,
                               Opportunity__r.Owner.Email,
                               // Added by Arsh - CR# 4543 - end
                               Opportunity__r.Geo_Account__c
                               FROM Equipment_Request__c 
                               WHERE Id IN : recordIdSet];
        return equipmentRecordList;
    }
    
    //CR# 3552 Bikram : Email Wrapper for sendSingleEmailMessage
    private void createEmailWrapperForPSEarlyEngagement(Map<Id, Equipment_Request__c> newRecordMap, String emailTemplateDevloperNameStr){       
        if(!newRecordMap.isEmpty()){
            
            PSEarlyEngagementController psEarlyEngagementControllerObj = new PSEarlyEngagementController();
            List<PSEarlyEngagementController.SendSingleEmailMessageWrapper> sendSingleEmailMessageWrapperList = new List<PSEarlyEngagementController.SendSingleEmailMessageWrapper>(); 
            
            
            for(Equipment_Request__c equipReqRecord : getEquipmentRecordRelatedFields(newRecordMap.keySet())){
                System.debug('equipReqRecord : - ' + equipReqRecord);
                
                if(emailTemplateDevloperNameStr == 'Approval_Process_1_Notification_Email_sent_to_the_submitter'){
                    PSEarlyEngagementController.SendSingleEmailMessageWrapper sendSingleEmailMessageWrapperObj = new PSEarlyEngagementController.SendSingleEmailMessageWrapper();
                    List<String> toAddressesList = new List<String>();
                    List<String> ccAddressesList = new List<String>();
                    if(equipReqRecord.CreatedBy.Email != NULL){
                        toAddressesList.add(equipReqRecord.CreatedBy.Email);
                    }
                    if(equipReqRecord.Opportunity__r.Account.Account_Manager__r.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Account.Account_Manager__r.Email);
                    }
                    if(equipReqRecord.Opportunity__r.Account.CSM_Name_New__r.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Account.CSM_Name_New__r.Email);
                    }
                    if(equipReqRecord.Opportunity__r.Account.CSM_Name_2__r.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Account.CSM_Name_2__r.Email);
                    }
                    // Added by Arsh - CR# 4543 start
                    if(equipReqRecord.Opportunity__r.Account.TAM_Name_New__r.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Account.TAM_Name_New__r.Email);
                    }
                    if(equipReqRecord.Opportunity__r.Owner.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Owner.Email);
                    }
                    // Added by Arsh - CR# 4543 end
                    
                    sendSingleEmailMessageWrapperObj.toAddresses = toAddressesList;
                    sendSingleEmailMessageWrapperObj.ccAddresses = ccAddressesList;                                           
                    sendSingleEmailMessageWrapperObj.emailTemplateDevloperName = emailTemplateDevloperNameStr;
                    sendSingleEmailMessageWrapperObj.targetObjectRecord = equipReqRecord;  
                    
                    sendSingleEmailMessageWrapperList.add(sendSingleEmailMessageWrapperObj);
                }
                
                if(emailTemplateDevloperNameStr == 'Approval_Process_1_Approved_Email_sent_to_the_submitter'){
                    PSEarlyEngagementController.SendSingleEmailMessageWrapper sendSingleEmailMessageWrapperObj = new PSEarlyEngagementController.SendSingleEmailMessageWrapper();
                    List<String> toAddressesList = new List<String>();
                    List<String> ccAddressesList = new List<String>();
                    List<PS_EarlyEngagement_ApprovalEmail_CC_List__mdt> ccListMdtList
                        = PS_EarlyEngagement_ApprovalEmail_CC_List__mdt.getAll().values();
                    if(equipReqRecord.CreatedBy.Email != NULL){
                        toAddressesList.add(equipReqRecord.CreatedBy.Email);
                    }
                    for(PS_EarlyEngagement_ApprovalEmail_CC_List__mdt mdtRecord : ccListMdtList){
                        if(equipReqRecord.Opportunity__r.Geo_Account__c == 'Americas' && mdtRecord.Geo__c == 'Americas'){
                            ccAddressesList.addAll(mdtRecord.CC_List__c.split(','));
                        }
                        if(equipReqRecord.Opportunity__r.Geo_Account__c == 'APJ' && mdtRecord.Geo__c == 'APJ'){
                            ccAddressesList.addAll(mdtRecord.CC_List__c.split(','));
                        }
                        if(equipReqRecord.Opportunity__r.Geo_Account__c == 'EMEA' && mdtRecord.Geo__c == 'EMEA'){
                            ccAddressesList.addAll(mdtRecord.CC_List__c.split(','));
                        }
                        if(equipReqRecord.Opportunity__r.Geo_Account__c == 'Public Sector' && mdtRecord.Geo__c == 'Public Sector'){
                            ccAddressesList.addAll(mdtRecord.CC_List__c.split(','));
                        }
                        if(equipReqRecord.Opportunity__r.Geo_Account__c == 'WW Commercial' && mdtRecord.Geo__c == 'WW Commercial'){
                            ccAddressesList.addAll(mdtRecord.CC_List__c.split(','));
                        }
                        if(equipReqRecord.Opportunity__r.Geo_Account__c == 'WW Enterprise' && mdtRecord.Geo__c == 'WW Enterprise'){
                            ccAddressesList.addAll(mdtRecord.CC_List__c.split(','));
                        }
                    }
                    // Added by Arsh - CR# 4543 start :- cc account team on approval email
                    if(equipReqRecord.Opportunity__r.Account.Account_Manager__r.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Account.Account_Manager__r.Email);
                    }
                    if(equipReqRecord.Opportunity__r.Account.CSM_Name_New__r.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Account.CSM_Name_New__r.Email);
                    }
                    if(equipReqRecord.Opportunity__r.Account.CSM_Name_2__r.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Account.CSM_Name_2__r.Email);
                    }
                    if(equipReqRecord.Opportunity__r.Account.TAM_Name_New__r.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Account.TAM_Name_New__r.Email);
                    }
                    if(equipReqRecord.Opportunity__r.Owner.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Owner.Email);
                    }
                    // Added by Arsh - CR# 4543 end
                    
                    sendSingleEmailMessageWrapperObj.toAddresses = toAddressesList;
                    sendSingleEmailMessageWrapperObj.ccAddresses = ccAddressesList;                                           
                    sendSingleEmailMessageWrapperObj.emailTemplateDevloperName = emailTemplateDevloperNameStr;
                    sendSingleEmailMessageWrapperObj.targetObjectRecord = equipReqRecord;
                    
                    sendSingleEmailMessageWrapperList.add(sendSingleEmailMessageWrapperObj);
                }
                
                if(emailTemplateDevloperNameStr == 'Approval_Process_1_Rejection_Email_sent_to_the_submitter'){
                    PSEarlyEngagementController.SendSingleEmailMessageWrapper sendSingleEmailMessageWrapperObj = new PSEarlyEngagementController.SendSingleEmailMessageWrapper();
                    List<String> toAddressesList = new List<String>();
                    List<String> ccAddressesList = new List<String>();
                    if(equipReqRecord.CreatedBy.Email != NULL){
                        toAddressesList.add(equipReqRecord.CreatedBy.Email);
                    }
                    // Added by Arsh - CR# 4543 start :- cc account team on rejection email
                    if(equipReqRecord.Opportunity__r.Account.Account_Manager__r.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Account.Account_Manager__r.Email);
                    }
                    if(equipReqRecord.Opportunity__r.Account.CSM_Name_New__r.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Account.CSM_Name_New__r.Email);
                    }
                    if(equipReqRecord.Opportunity__r.Account.CSM_Name_2__r.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Account.CSM_Name_2__r.Email);
                    }
                    if(equipReqRecord.Opportunity__r.Account.TAM_Name_New__r.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Account.TAM_Name_New__r.Email);
                    }
                    if(equipReqRecord.Opportunity__r.Owner.Email != NULL){
                        ccAddressesList.add(equipReqRecord.Opportunity__r.Owner.Email);
                    }
                    // Added by Arsh - CR# 4543 end
                    
                    sendSingleEmailMessageWrapperObj.toAddresses = toAddressesList;
                    sendSingleEmailMessageWrapperObj.ccAddresses = ccAddressesList;                                           
                    sendSingleEmailMessageWrapperObj.emailTemplateDevloperName = emailTemplateDevloperNameStr;
                    sendSingleEmailMessageWrapperObj.targetObjectRecord = equipReqRecord;  
                    
                    sendSingleEmailMessageWrapperList.add(sendSingleEmailMessageWrapperObj);
                }
            }
            
            if(!sendSingleEmailMessageWrapperList.isEmpty()){
                psEarlyEngagementControllerObj.sendSingleEmailMessage(sendSingleEmailMessageWrapperList);
            }
        }        
    }
    
}