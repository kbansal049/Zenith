/*****************************************************************************************
Name: PSCredit_CreateProjectForRedemptionBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1.Apex Batch  for Professional_Services_Credits__c to Create the Inspire Planner Project
during the redemption process - it creates one project each per redemption record.
It will be scheduled to run once per day and Run as user having all the access and License of Inspire Planner Project.
==========================================================================================
==========================================================================================
History
-------
VERSION            AUTHOR               DATE            DETAIL              
1.0                Harish Gowda N       27/10/2022      IBA - 1933 - Allow all users to redeem PS credits and create Project.
2.0                Harish Gowda N       28/11/2022      IBA - 1933 - Making chages to populate Template Id instead of Project Template.
3.0                Sachin Tandon        08/1/2023       IBA - 4866 - Early Engagement Process : Populate Opportunity on Project
4.0                Sachin Tandon        16/1/2023       IBA - 4866 - Early Engagement Process : Refactor batch code
******************************************************************************************/ 
global class PSCredit_CreateProjectForRedemptionBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{
    
    public List<String> errorlst = new List<String>();
    public List<Id> projectIdList = New list<Id>();
    public List<Id> errorProjectIdList = New list<Id>();
    public Map<String,String> projectIdWithErrorMessageMap= New Map<String,String>();
    public List<PS_Credit_Redemption__c> creditRedemptionListglobal = New List<PS_Credit_Redemption__c>();
    private string query = null;
    public Integer noOfRecordsProcessed = 0;
    public dateTime startTime = datetime.now();
    Public String batchObjectName = 'PS_Credit_Redemption__c';
    public dateTime actualExecutionTime ;
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA - 1933 : This is Constructor for passing Query as parameter and executing the batch.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : PSCredit_CreateProjectForRedemptionBatch .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    public PSCredit_CreateProjectForRedemptionBatch(String reqQuery){
        if(reqQuery != null){
            query = reqQuery;
        }
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA - 1933 : This is Constructor for the batch class.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : PSCredit_CreateProjectForRedemptionBatch .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/     
    public PSCredit_CreateProjectForRedemptionBatch(){
        
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA - 1933 : This is Start Method of the Batch Class to pass the query of the records to be processed.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : start .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    public Database.QueryLocator start(Database.BatchableContext bc){
        actualExecutionTime = datetime.now();
        string pendingStr = 'Pending';
        string psRedemptionRecordTypeIdStr =  ZScalarConstants.PS_REDEMPTION_RECORDTYPEID;
        String query = 'SELECT Id, Name, Account__c, Account__r.Name, PS_Offering__r.Project_Template__c, Deployment_Service_Project__c, Project__c, Project_Creation_Status__c, Project_Creation_Failure_Reason__c, Project_Deployment_Expiration_Date__c, Project_Deployment_Start_Date__c, Project_Executive_Summary__c, Project_Primary_Customer_Contact__c, Project_Requester_Time_Zone__c, PS_Offering__c,IsEarlyEngagementRedemption__c FROM PS_Credit_Redemption__c WHERE Project_Creation_Status__c =: pendingStr AND RecordTypeId =: psRedemptionRecordTypeIdStr';
        return Database.getQueryLocator(query);
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA - 1933 : This is Execute Method of the Batch Class to handle all the process happeining in the Batch class.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : execute .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    public void execute(Database.BatchableContext bc, List<PS_Credit_Redemption__c> creditRedemptionList){
        try {  
            creditRedemptionListglobal.addAll(creditRedemptionList);
            noOfRecordsProcessed = noOfRecordsProcessed + creditRedemptionList.Size();
            this.createInspirePlannerProjects(creditRedemptionList);
        }catch(Exception ex) {
            system.debug('hagon exception -->'+ ex.getMessage()+ ex.getTypeName()+ex.getStackTraceString());
            ZscalerErrorLogsUtility.insertLogsForAsync('PSCredit_CreateProjectForRedemptionBatch', 'createInspirePlannerProjects',
                                                       'Apex', UserInfo.getUserId(),
                                                       'Sales Cloud', ex.getStackTraceString(), 
                                                       'Error While Creating Projects for the Credit Redemption Records for Redemption process: ' + ex.getMessage(), ex.getTypeName());
            
            throw ex;
        }
        
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA - 1933 : This is Finish Method of the Batch Class to handle post processing logic of the Batch class .
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : finish .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    public void finish(Database.BatchableContext bc){
        
        Map<Id,inspire1__Project__c> deploymentProjectWithRedemptionIDMap = PSCredit_CreateRedemptionProjectHelper.getDeploymentProjectIdForRedemption(projectIdList);
        Map<Id,Professional_Service_Project__c> pspProjectWithRedemptionIDMap = PSCredit_CreateRedemptionProjectHelper.getPSPProjectIdForRedemption(projectIdList);
        Map<Id,String>  redemptionIdWithErrorMessageMap = PSCredit_CreateRedemptionProjectHelper.getRedemptionIdWithErrorMessage(errorProjectIdList);
        List<PS_Credit_Redemption__c> creditRedemptionListToUpdate = New List<PS_Credit_Redemption__c>();
        
        if(!creditRedemptionListglobal.isEmpty() && !projectIdList.isEmpty()){
            for(PS_Credit_Redemption__c creditRedemptionObjNew :creditRedemptionListglobal){
                PS_Credit_Redemption__c creditRedemptionObjlocal = New PS_Credit_Redemption__c();
                creditRedemptionObjlocal.Id = creditRedemptionObjNew.Id;
                creditRedemptionObjlocal.Project__c =  deploymentProjectWithRedemptionIDMap.get(creditRedemptionObjNew.Id).Id;
                creditRedemptionObjlocal.Deployment_Service_Project__c =  pspProjectWithRedemptionIDMap.containskey(creditRedemptionObjNew.Id) ? pspProjectWithRedemptionIDMap.get(creditRedemptionObjNew.Id).Id: null;
                creditRedemptionObjlocal.Project_Creation_Status__c = ZScalarConstants.PROJECT_CREATION_STATUS_SUCCESS;
                creditRedemptionListToUpdate.add(creditRedemptionObjlocal);
            }
        }
        //to update the Project Creation Status as failed on the Redemption record along with the failure message .
        if(!errorProjectIdList.isEmpty() || Test.isRunningTest()){
            for(String errorCreditRedemptionObjId :redemptionIdWithErrorMessageMap.keyset()){
                PS_Credit_Redemption__c creditRedemptionObjError = New PS_Credit_Redemption__c();
                creditRedemptionObjError.Id = errorCreditRedemptionObjId;
                creditRedemptionObjError.Project_Creation_Status__c = ZScalarConstants.PROJECT_CREATION_STATUS_FAILED;
                creditRedemptionObjError.Project_Creation_Failure_Reason__c = redemptionIdWithErrorMessageMap.get(errorCreditRedemptionObjId);
                creditRedemptionListToUpdate.add(creditRedemptionObjError);
            }
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
            list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
            //Sending Email to inform the SFDC Support team about the failure .
            if(!errorlst.isEmpty() || Test.isRunningTest()){
                Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                mail1.setToAddresses(new String[] {Label.Customer_Credits_Batch_Notification_Email});
                if ( !owea.isEmpty() ) {
                    mail1.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail1.setsenderDisplayName('Sales Ops System Admin');
                }
                mail1.setSubject('Project Creation Failure For PS Credit Redemption Process');
                mail1.setPlainTextBody('Below are the details of records that have failed - Project Creation Status of all the related Redemption Records has been updated as failed with suitable error message , please help to check and reprocess the same :' + errorlst);
                messageList.add(mail1);
                Messaging.sendEmail(messageList);
            }
        }
        
        if(!creditRedemptionListToUpdate.isEmpty()){
            Update creditRedemptionListToUpdate;
        }
        // Calling the BatchJobMonitoringHelper method to insert Batch Stats .
        BatchJobMonitoringHelper.insertBatchJobMonitoring('PSCredit_CreateProjectForRedemptionBatch',noOfRecordsProcessed,BC.getJobId(),startTime, batchObjectName,actualExecutionTime);
        
    }
    
    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA - 1933 : This method will Create Projects one each for the redemption records being passed.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : createInspirePlannerProjects .
* @param    NAME : List<PS_Credit_Redemption__c> creditRedemptionList .
* @return   TYPE : NIL .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/ 
    private void createInspirePlannerProjects(List<PS_Credit_Redemption__c> creditRedemptionList) {
        
        List<inspire1__Project__c> projectListToInsert = new  List<inspire1__Project__c>();
        List<inspire1__Project__c> projectListToUpdate = new  List<inspire1__Project__c>();
        Id projectId;
        Id developmentProjectId = Schema.SObjectType.inspire1__Project__c.getRecordTypeInfosByDeveloperName().get(ZScalarConstants.PROJECT_RT_DEPLOYMENT_PROJECT).getRecordTypeId();
        Id generiConsultantId;
        Id genericPMId;
        
        Map<String,Id> userIdByName = PSCredit_CreateRedemptionProjectHelper.userIdByName;
        generiConsultantId = PSCredit_CreateRedemptionProjectHelper.getUserId(userIdByName,L2O_Constants.PlannerGenericUserAssignment.USERNAME_GENERIC_CONSULTANT);
        genericPMId = PSCredit_CreateRedemptionProjectHelper.getUserId(userIdByName,L2O_Constants.PlannerGenericUserAssignment.USERNAME_GENERIC_CONSULTANT);
        
        Set<Id> accountIdSet = New Set<Id>();
        Set<Id> creditRedemptionIdSet = New Set<Id>();
        for(PS_Credit_Redemption__c creditRedemptionObj: creditRedemptionList){
            accountIdSet.add(creditRedemptionObj.Account__c);
            creditRedemptionIdSet.add(creditRedemptionObj.Id);
        }
        
        Map<Id,Integer> accountIdtoRFCountMap = PSCredit_CreateRedemptionProjectHelper.getAvailableProjectsCount(accountIdSet);
        Map<Id,String> redemptionIdWithCreditSKUMap = PSCredit_CreateRedemptionProjectHelper.getCreditSkuForPsCredit(creditRedemptionIdSet);
        Map<Id,String> redemptionIdWithNotesMap = New Map<Id,String>();
        Map<Id,PSCredit_CreateRedemptionProjectHelper.OpportunityIdentificationModel> opportunityIdentificationModelByCreditRedemptionId = PSCredit_CreateRedemptionProjectHelper.getOpportunityIdByCreditRedemptionId(creditRedemptionIdSet);

        for(PS_Credit_Redemption__c creditRedemptionObj: creditRedemptionList){

            //Null check for the Available RF Project Count .
            Integer availableProjectsCount = accountIdtoRFCountMap.containskey(creditRedemptionObj.Account__c) ? accountIdtoRFCountMap.get(creditRedemptionObj.Account__c) + 1:1; 
            accountIdtoRFCountMap.put(creditRedemptionObj.Account__c,availableProjectsCount);
            redemptionIdWithNotesMap.put(creditRedemptionObj.Id, creditRedemptionObj.Project_Executive_Summary__c);
            
            inspire1__Project__c projectobj = New inspire1__Project__c(); 
            projectobj.inspire1__Account__c = creditRedemptionObj.Account__c;
            projectobj.RecordTypeId = developmentProjectId;
            projectobj.PS_Offering__c = creditRedemptionObj.PS_Offering__c;
            projectobj.Full_Project_Name__c = 'New Project - ' + creditRedemptionObj.Account__r.Name + '-RF' + availableProjectsCount;
            projectobj.project_type__c = 'Credit';
            projectobj.inspire1__Project_Status__c = 'Pending Assignment';
            projectobj.Project_Manager__c = genericPMId;
            projectobj.Primary_Deployment_Consultant__c = generiConsultantId;
            projectobj.Requester_Time_Zone__c = creditRedemptionObj.Project_Requester_Time_Zone__c;
            projectobj.Deployment_Start_Date__c = creditRedemptionObj.Project_Deployment_Start_Date__c;
            projectobj.Deployment_Expiration_Date__c = creditRedemptionObj.Project_Deployment_Expiration_Date__c;
            projectobj.Primary_Customer_Contact__c = creditRedemptionObj.Project_Primary_Customer_Contact__c;
            projectobj.Management_Notes__c = creditRedemptionObj.Project_Executive_Summary__c;
            projectobj.Template_ID__c =  creditRedemptionObj.PS_Offering__r.Project_Template__c;
            projectobj.Deployment_Package__c = redemptionIdWithCreditSKUMap.get(creditRedemptionObj.Id);
            projectobj.Credit_Redemptions__c = creditRedemptionObj.Id;
            projectobj.Early_Engagements__c = creditRedemptionObj.IsEarlyEngagementRedemption__c;
            projectobj.Opportunity__c = PSCredit_CreateRedemptionProjectHelper.getOpportunityId(opportunityIdentificationModelByCreditRedemptionId,creditRedemptionObj.Id);
            projectListToInsert.add(projectobj);
        }
        
        if(!projectListToInsert.isEmpty()){
            Database.SaveResult[] srList = database.insert(projectListToInsert);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    projectId = sr.getId();
                    projectIdList.add(projectId);
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errorlst.add(sr.getId() + ' - ' + err.getMessage());
                        errorProjectIdList.add(sr.getId());
                        projectIdWithErrorMessageMap.put(sr.getId(), err.getMessage());
                    }
                }
            }
            // To Update the Executive summary on the Project Record being created from the related Redemption record.
            for(inspire1__Project__c proObj: projectListToInsert) {
                inspire1__Project__c projectObjForUpdate = New inspire1__Project__c();
                projectObjForUpdate.Id = proObj.Id;
                projectObjForUpdate.Management_Notes__c = redemptionIdWithNotesMap.get(proObj.Credit_Redemptions__c);
                projectListToUpdate.add(projectObjForUpdate);
            }
            // update the Execute Summary Notes on the Projects being inserted.
            if(!projectListToUpdate.isEmpty()){
                TriggerHandler.bypass('InspireProjectMasterTriggerHandler');
                Update projectListToUpdate;
                TriggerHandler.clearBypass('InspireProjectMasterTriggerHandler');
            }
        }
    }

    /**
* ─────────────────────────────────────────────────────────────────────────────────────────────┐
* This Method was added as part of IBA - 1933 : This is execute method to execute the batch from scheduler interface.
* ──────────────────────────────────────────────────────────────────────────────────────────────
* @Method   NAME : execute .
* ─────────────────────────────────────────────────────────────────────────────────────────────┘
*/  
    global void execute(SchedulableContext sc) {
        PSCredit_CreateProjectForRedemptionBatch psCreditCreateProjectForRedemptionBatch = new PSCredit_CreateProjectForRedemptionBatch(); 
        Database.executeBatch(psCreditCreateProjectForRedemptionBatch);
    }

}