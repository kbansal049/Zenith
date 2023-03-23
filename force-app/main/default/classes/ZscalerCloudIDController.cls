/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-12-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ZscalerCloudIDController {
    public static Id trailPRGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
    public static Id subscriptionPRGRecordTypeIds = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();
    
    @auraEnabled
    public static ZscalerCloudWrapper retrivePGRecords(ID zCloudID, ID opptId){
        System.debug('-----retrivePGRecords-----zCloudID--'+zCloudID);
        
        Set<ID> recordTypeIDs = new Set<ID>();
        recordTypeIDs.add(trailPRGRecordTypeId);
        recordTypeIDs.add(subscriptionPRGRecordTypeIds);

        Zscaler_Cloud_ID__c zCloud = getZscalerCloudRecord(zCloudID);

        List<Provisioning_Group__c> prgList = [SELECT Id, Name, 
                        RecordTypeId, RecordType.Name, 
                        Product_Line__c, Preferred_Cloud__c, 
                        Status__c, Approval_Status__c, Sub_Status__c, 
                        PG_Request_Type__c, Provisioning_Type__c, 
                        Organization_Domain__c, Additional_Organization_domains__c, 
                        Provisioning_Process__c, Account_Industry_Vertical__c, 
                        Is_Active__c, ZSCM_Tenant_Link__c, 
                        Start_Date__c, End_Date__c, 
                        CreatedDate, CreatedBy.Name, 
                        Subscription_Id__c, Subscription_Name__c, 
                        Account__c, Account__r.Name, 
                        Opportunity__c, Opportunity__r.Name, Opportunity__r.SBQQ__PrimaryQuote__c, 
                        Opportunity__r.Netsuite_Sales_Order_Number__c, Opportunity__r.Netsuite_Sales_Order_Link__c, 
                        Provisioning_Request__c, Provisioning_Request__r.Name, 
                        Associated_ZIA_Zscaler_Cloud__c, Associated_ZIA_Zscaler_Cloud__r.Name, Associated_ZIA_Zscaler_Cloud__r.Org_Name__c, 
                        Zscaler_Cloud_ID__c, Zscaler_Cloud_ID__r.Name, Zscaler_Cloud_ID__r.Org_Name__c,  

                        (SELECT Id, Product__c, Name, Zscaler_Cloud_ID__c, Product_Name__c, SKU__c, Quantity__c, Start_Date__c, End_Date__c  
                        FROM Provisioning_Products__r),
                        
                        (SELECT Id, Contact__c, Name, Zscaler_Cloud_ID__c, User__c, toLabel(Type__c), User_Name__c, Email__c 
                        FROM Provisioning_Contacts__r) 
                        
                        FROM Provisioning_Group__c 
                        WHERE Zscaler_Cloud_ID__c = :zCloud.ID
                        AND RecordTypeId IN :recordTypeIDs
                        ORDER BY Name DESC];
        
        List<ProcessInstance> piList = [SELECT Id, TargetObjectId, LastActor.Name, Status, CreatedDate, CompletedDate, 
                          (SELECT Id, CreatedDate, ActorId, Actor.Name, OriginalActorId, OriginalActor.Name, StepNodeId, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC),  
                          (SELECT Id, CreatedDate, ProcessNodeName FROM Nodes ORDER BY CreatedDate DESC) 
                          FROM ProcessInstance
                          WHERE TargetObjectId IN :prgList 
                          ORDER BY TargetObject.Name DESC];

        Map<Id, List<ProcessInstanceStepWrapper>> pisWrapMap = new Map<Id, List<ProcessInstanceStepWrapper>>();
        if(!piList.isEmpty()){
            for(ProcessInstance pi : piList){
                if((pi.Nodes != null && !pi.Nodes.isEmpty()) 
                    && (pi.Steps != null && !pi.Steps.isEmpty())){
                    List<ProcessInstanceStepWrapper> pisWrapList = getUpdatedProcessInstanceStepWrapperList(pi.Nodes, pi.Steps);
                    pisWrapMap.put(pi.TargetObjectId, pisWrapList);
                }
            }
        }

        List<ProvisioningWrapper> prgWrapperList = new List<ProvisioningWrapper>();
        for(Provisioning_Group__c currentPrg : prgList){
            if(pisWrapMap.containsKey(currentPrg.Id)){
                prgWrapperList.add(new ProvisioningWrapper(currentPrg, pisWrapMap.get(currentPrg.Id)));
            }else{
                prgWrapperList.add(new ProvisioningWrapper(currentPrg, null));
            }
        }

        ZscalerCloudWrapper zWrap = new ZscalerCloudWrapper();
        zWrap.pgList = prgWrapperList;
        System.debug('-----retrivePGRecords-----zWrap--'+zWrap);
        return zWrap;
    }

    @TestVisible
    private static List<ProcessInstanceStepWrapper> getUpdatedProcessInstanceStepWrapperList(List<ProcessInstanceNode> pinList, List<ProcessInstanceStep> pisList){
        List<ProcessInstanceStepWrapper> updatedPisWrapList = new List<ProcessInstanceStepWrapper>();

        //TODO: Hard coded the the below node step mapping as I couldn't find better relationship b/w these two objects
        if(pinList.size() == 1 && pisList.size() == 3){
            ProcessInstanceStepWrapper updatedPisWrap0 = new ProcessInstanceStepWrapper();
            updatedPisWrap0.pis = pisList[0];
            updatedPisWrap0.processNodeName = pinList[0].ProcessNodeName;
            updatedPisWrapList.add(updatedPisWrap0);

            ProcessInstanceStepWrapper updatedPisWrap1 = new ProcessInstanceStepWrapper();
            updatedPisWrap1.pis = pisList[1];
            updatedPisWrap1.processNodeName = pinList[0].ProcessNodeName;
            updatedPisWrapList.add(updatedPisWrap1);

            ProcessInstanceStepWrapper updatedPisWrap2 = new ProcessInstanceStepWrapper();
            updatedPisWrap2.pis = pisList[2];
            updatedPisWrap2.processNodeName = 'Approval Request Submitted';
            updatedPisWrapList.add(updatedPisWrap2);
        }else if(pinList.size() == 2 && pisList.size() == 4){
            ProcessInstanceStepWrapper updatedPisWrap0 = new ProcessInstanceStepWrapper();
            updatedPisWrap0.pis = pisList[0];
            updatedPisWrap0.processNodeName = pinList[0].ProcessNodeName;
            updatedPisWrapList.add(updatedPisWrap0);

            ProcessInstanceStepWrapper updatedPisWrap1 = new ProcessInstanceStepWrapper();
            updatedPisWrap1.pis = pisList[1];
            updatedPisWrap1.processNodeName = pinList[0].ProcessNodeName;
            updatedPisWrapList.add(updatedPisWrap1);

            ProcessInstanceStepWrapper updatedPisWrap2 = new ProcessInstanceStepWrapper();
            updatedPisWrap2.pis = pisList[2];
            updatedPisWrap2.processNodeName = pinList[1].ProcessNodeName;
            updatedPisWrapList.add(updatedPisWrap2);

            ProcessInstanceStepWrapper updatedPisWrap3 = new ProcessInstanceStepWrapper();
            updatedPisWrap3.pis = pisList[2];
            updatedPisWrap3.processNodeName = 'Approval Request Submitted';
            updatedPisWrapList.add(updatedPisWrap3);
        }
        return updatedPisWrapList;
    }
    
    @auraEnabled
    public static void firePlatformEvents(ID zCloudID){
        System.debug('-----firePlatformEvents-----zCloudID--'+zCloudID);
        Zscaler_Cloud_ID__c zCloud = getZscalerCloudRecord(zCloudID);

        if(zCloud != null){
            //Fire generic Workato Platfrom Event
            fireGenericPlatformEvent(zcloud);
            
            TriggerHandler.bypass('AccountTriggerHandler');
            TriggerHandler.bypass('OpportunityTriggerHandler');
            zCloud.ZSCM_Refresh_Status__c = 'Initiated';
            update zCloud;
        }
    }
    
    @testVisible
    private static Zscaler_Cloud_ID__c getZscalerCloudRecord(ID zCloudID){
        return [SELECT Id, Name, Account__c, Cloud_Type__c FROM Zscaler_Cloud_ID__c WHERE Id = :zCloudID LIMIT 1];
    }

    @testVisible
    private static String retriveCloudIDfromName(String cloudName){
        String cloudID = cloudName;
        if(cloudName.contains('-')){
            cloudID = cloudName.split('-').size() > 0 ? cloudName.split('-')[1] : cloudName; 
        }
        return cloudID;
    }
    
    @testVisible
    private static String retriveCloudTypeFromName(String cloudName){
        String cloudID = null;
        if(cloudName.containsIgnoreCase('zscalerone')){
            cloudID = 'ZSCALERONE';
        }
        else if(cloudName.containsIgnoreCase('zscalertwo')){
            cloudID = 'ZSCALERTWO';
        }
        else if(cloudName.containsIgnoreCase('zscalerthree')){
            cloudID = 'ZSCALERTHREE';
        }
        else{
            cloudName = cloudName.toUpperCase();
            cloudID = cloudName.split('.NET').size() > 0 ? (cloudName.split('.NET')[0]).toupperCASE() : cloudName.toupperCASE(); 
        }
        return cloudID;
    }
    
    @testVisible
    private static void fireGenericPlatformEvent(Zscaler_Cloud_ID__c zcloud){
        Workato_Generic_Event__e evnt = new Workato_Generic_Event__e();
        evnt.Object_API_Name__c='Zscaler_Cloud_ID__c';
        evnt.Process__c ='Cloud Detail Retrieval';
        evnt.Record_Id__c = zcloud.id;
        evnt.Additional_Detail__c = Json.serialize(new CloudDetailRequestWrapper(zcloud));
        System.debug('--evnt--'+evnt);
        // Publish test event
        Database.SaveResult sr = EventBus.publish(evnt);
        System.debug('--evnt--result--'+sr);
    }
    
    public class CloudDetailRequestWrapper {
        public String Zscaler_User_ID;
        public String Zscaler_Account_Id;
        public String Zscaler_Cloud_ID;
        public String ZSCM_CloudID;
        public String Zscaler_Cloud_Type;
        CloudDetailRequestWrapper(Zscaler_Cloud_ID__c zCloud){
            this.Zscaler_User_ID = UserInfo.getUserId();
            this.Zscaler_Account_Id = zCloud.Account__c;
            this.Zscaler_Cloud_ID = zCloud.Account__c;
            this.ZSCM_CloudID = retriveCloudIDfromName(zCloud.Name);
            this.Zscaler_Cloud_Type = retriveCloudTypeFromName(zCloud.Name);
        }
    }
    
    public class ZscalerCloudWrapper {
        @auraEnabled
        public List<ProvisioningWrapper> pgList;
    }

    public class ProvisioningWrapper{
        @auraEnabled
        public Provisioning_Group__c prg;

        @auraEnabled
        public List<ProcessInstanceStepWrapper> pisWrapList;

        public ProvisioningWrapper(Provisioning_Group__c pg, List<ProcessInstanceStepWrapper> pisList){
            prg = pg;
            pisWrapList = pisList;
        }
    }

    public class ProcessInstanceStepWrapper {
        @auraEnabled
        public ProcessInstanceStep pis;

        @auraEnabled
        public String processNodeName;
    }
}