/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 07-12-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ProvisioningGroupTriggerHandler extends TriggerHandler {
    
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
    public static Id trialPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Trial').getRecordTypeId();//IBA-399
    public static Id subsPGRecordTypeId = Schema.SObjectType.Provisioning_Group__c.getRecordTypeInfosByName().get('Subscription').getRecordTypeId();//IBA-399
    
    /* public override void beforeInsert(){
        Boolean isInsert = true;
        Boolean isUpdate = false;
        Map<id,Provisioning_Group__c> TriggerOLDmap = (MAP<ID,Provisioning_Group__c>) trigger.oldmap;
        fieldUpdatesOptimized(trigger.new,trigger.oldmap,isInsert,Isupdate);
    }*/
    
    public override void beforeInsert(){
        List<Provisioning_Group__c> pgList = (List<Provisioning_Group__c>) trigger.new;
        setSEManagerValues(pgList);
        SubmitZIAForProvisioning(pgList,null,false);
        SubmitZPAForProvisioning(pgList,null,false);
    }
    
    public override void beforeUpdate(){
        System.debug('ProvisioningGroupTriggerHandler.beforeUpdate() is invoked ...!!');
        Boolean isInsert = false;
        Boolean isUpdate = true;
        List<Provisioning_Group__c> pgList = (List<Provisioning_Group__c>) trigger.new;
        System.debug('>>>pgList :'+pgList);
        MAP<ID,Provisioning_Group__c> oldPGMap = (MAP<ID,Provisioning_Group__c>) trigger.oldmap;
        updateDates(pgList,oldPGMap);
        fieldUpdatesOptimized(pgList,oldPGMap,isInsert,Isupdate);
        setSEManagerValues(pgList);
        SubmitZIAForProvisioning(pgList,oldPGMap,true);
        SubmitZPAForProvisioning(pgList,oldPGMap,true);
    }
    
    public override void afterInsert() {
        System.debug('ProvisioningGroupTriggerHandler AfterInsert Is Invoked');
        List<Provisioning_Group__c> pgList = (List<Provisioning_Group__c>) trigger.new;
        List<Provisioning_Event__e> pgevntList = new list<Provisioning_Event__e>();
        List<Provisioning_Event_Manual__e> pgevntManualList = new list<Provisioning_Event_Manual__e>();
        CreateClusterCaseForZIA(pgList, Null, false);//IBA-2265
        CreateReviewCaseForZPA(pgList, Null, false);
        for(Provisioning_Group__c pg: pgList){
           if(pg.Status__c =='Requested' && pg.Approval_Status__c=='Approved'&& pg.Provisioning_Broker_Eligible__c == true){
                pgevntList.add(new Provisioning_Event__e(PG_ID__c= pg.Id));
            }
            else if(pg.Provisioning_Type__c == 'Manual' && pg.Approval_Status__c == 'Approved' )
            {
                pgevntManualList.add(new Provisioning_Event_Manual__e(PG_ID__c= pg.Id));
            }
        }
        
        System.debug('--ProvisioningGroupTriggerHandler--pgevntList--'+pgevntList);
        if(pgevntList !=null && pgevntList.size()>0){
            EventBus.publish(pgevntList);
        }
        
        System.debug('--ProvisioningGroupTriggerHandler--pgevntManualList--'+pgevntManualList);
        if(pgevntManualList.size()>0){
            EventBus.publish(pgevntManualList);
        }
    }
    
    public override void afterUpdate() {
        System.debug('ProvisioningGroupTriggerHandler.afterUpdate() is invoked ...!!');
        List<Provisioning_Group__c> pgList = (List<Provisioning_Group__c>) trigger.new;
        MAP<ID,Provisioning_Group__c> oldPGMap = (MAP<ID,Provisioning_Group__c>) trigger.oldmap;
        MAP<ID,Provisioning_Group__c> newPGMap = (MAP<ID,Provisioning_Group__c>) trigger.newmap;
        
        fireProvistioningEventAfterUpdate(pgList, oldPGMap);
        initiateBrokerProcessForWaitingPGs(pgList, oldPGMap);
        fireJiraIntegration(pgList, oldPGMap);

        CreateClusterCaseForZIA(pgList, oldPGMap, true);//IBA-2265
        initiateWaitingSubscriptionZDXPGs(pgList, oldPGMap);
        archiveOldPGAfterProvision(pgList, oldPGMap);
        updatePGAfterExtension(pgList, oldPGMap);
        //autoCreatePGForSubscription(pgList, oldPGMap);//IBA-399
        updateTenantForManual(pgList, oldPGMap);
        splitProvisioningGroupsBasedOnDates(pgList, newPGMap, oldPGMap);
        archiveOldPGAPGSubscription(pgList, oldPGMap);
        processPRGAfterDecomission(pgList, oldPGMap);
        processPRFafterProvisioingfrCBI(pgList, oldPGMap);
		CreateReviewCaseForZPA(pgList, oldPGMap, true);
     }

     
 @testvisible
    private void fireJiraIntegration(List<Provisioning_Group__c> pgList, MAP<ID,Provisioning_Group__c> oldPGMap){

        List<Workato_Generic_Event__e> eventList = new List<Workato_Generic_Event__e>();
       for(Provisioning_Group__c prg : pgList){
            if(prg.status__c=='Provisioned' && prg.Is_Jira_Ticket_Required__c
             && prg.status__c != oldPGMap.get(prg.id).status__c && prg.Provisioning_Process__c !='Extension'){
                Workato_Generic_Event__e evnt = new Workato_Generic_Event__e();
                evnt.Object_API_Name__c='Provisioning_Group__c';
                evnt.Process__c ='Jira Integration';
                evnt.Record_Id__c = prg.id;
                evnt.Additional_Detail__c = jiraWrapper.getjiraJson(prg.id);
                 System.debug('inside jira '+evnt.Additional_Detail__c);
                eventList.add(evnt);
            }
        } 

        if(eventList !=null && eventList.size()>0){
            Eventbus.publish(eventList);
        }
    }
     
    //in case of trial update startdate and endDate 
    public static void updateDates(List<Provisioning_Group__c> pgList, MAP<ID,Provisioning_Group__c> oldPGMap){
        System.debug('ProvisioningGroupTriggerHandler.beforeUpdate().updateDates() is invoked ...!!');
        Set<Id> prgIdSet = new Set<Id>();
        for(Provisioning_Group__c prg : pgList){
            System.debug(prg.Status__c+'=prg.Status__c='+prg.Provisioning_Process__c+'---'+oldPGMap.get(prg.id).Status__c);
            if(prg.Status__c == 'Requested' && prg.Provisioning_Process__c=='New Tenant' && prg.RecordTypeId==trialPGRecordTypeId 
               && oldPGMap.get(prg.id).Status__c != prg.Status__c){
                prg.Start_Date__c = System.today();
                if(prg.Is_Internal_Provisioning__c){
                    if(Date.isLeapYear(prg.Start_Date__c.year())){
                        prg.End_Date__c = prg.Start_Date__c.addDays(729);
                    }else{
                        prg.End_Date__c = prg.Start_Date__c.addDays(728);
                    }
                }else{
                    prg.End_Date__c = prg.Start_Date__c.addDays(29);
                }
                
                //ZSCM end date should include start date value as well. So the ZSCM end date should be 365 days for leap year (or) 364 days for non leap year including start date
                if(Date.isLeapYear(prg.Start_Date__c.year())){
                    prg.ZSCM_End_Date__c = prg.Start_Date__c.addDays(365);
                }else{
                    prg.ZSCM_End_Date__c = prg.Start_Date__c.addDays(364);
                }
                prgIdSet.add(prg.id);
            }
        }
        if(!prgIdSet.isEmpty()){
            List<Provisioning_Product__c> lstprod = [select id, name ,Start_Date__c, End_Date__c, Provisioning_Group__r.Is_Internal_Provisioning__c
                                                     from Provisioning_Product__c where Provisioning_Group__c In:prgIdSet];
            if(lstprod !=null && lstprod.size()>0){
                for(Provisioning_Product__c prd : lstprod){
                    prd.Start_Date__c = System.today();
                    if(prd.Provisioning_Group__r.Is_Internal_Provisioning__c){
                        if(Date.isLeapYear(prd.Start_Date__c.year())){
                            prd.End_Date__c = prd.Start_Date__c.addDays(729);
                        }else{
                            prd.End_Date__c = prd.Start_Date__c.addDays(728);
                        }
                    }else{
                        prd.End_Date__c = prd.Start_Date__c.addDays(29);
                    }
                }
                try{
                    update lstprod;
                }catch(Exception ex){
                    ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupTriggerHandler','updateDates',ex);
                }
            }
        }
    }
    
    @testvisible
    public static void fieldUpdatesOptimized(List<Provisioning_Group__c> pgList, MAP<ID,Provisioning_Group__c> oldPGMap,Boolean isInsert,Boolean Isupdate){
        System.debug('ProvisioningGroupTriggerHandler.beforeUpdate().fieldUpdatesOptimized() is invoked ...!!');
        Set<id> oppIdSet = new Set<id>();
        Set<id> associatedPRGIdSet = new Set<id>();
        for(Provisioning_Group__c prg : pgList){
            if(!prg.is_internal_provisioning__c){
            oppIdSet.add(prg.Opportunity__c);
            }
            associatedPRGIdSet.add(prg.Associated_Provisioning_Group__c);

        }
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, StageName, Validation_Plan__c, Opportunity.Patch__r.PatchTeam__r.Theater__c,
                                                                Geo_Account__c, Region_Account__c, Area__c, SE_Name__c, SE_Name__r.managerid  
                                                                FROM Opportunity 
                                                                WHERE Id IN :oppIdSet]);
        
        Map<Id, Provisioning_Group__c> associatedPRGsMap = new Map<Id, Provisioning_Group__c>([SELECT Id, Status__c FROM Provisioning_Group__c WHERE Id IN :associatedPRGIdSet]);

        for(Provisioning_Group__c prg : pgList){
            if(prg.Opportunity__c!=null){
                System.debug('=oppMap.get=='+oppMap.get(prg.Opportunity__c));
                System.debug('=oppMap.get(prg.Opportunity__c)='+oppMap.get(prg.Opportunity__c).Validation_Plan__c);
                if( oppMap.get(prg.Opportunity__c).Validation_Plan__c != ''){
                    prg.Technical_Validation_Plan__c = oppMap.get(prg.Opportunity__c).Validation_Plan__c;
                }
            }
            if(prg.Status__c!=null && 
                prg.Approval_Status__c!=null &&
                prg.Product_line__c!=null && 
                prg.Status__c=='Initiated'&&
                prg.Approval_Status__c=='Approved' &&
                prg.Product_line__c!='ZIA' && (prg.Product_Line__c != 'ZPA' || (prg.Product_Line__c == 'ZPA' && prg.PG_Request_Type__c != 'CREATE')) &&
                prg.Associated_Provisioning_Group__c!=null &&
                associatedPRGsMap!=null &&
                prg.Provisioning_Process__c!='Extension' && //IBA-5311
                associatedPRGsMap.get(prg.Associated_Provisioning_Group__c).Status__c=='Provisioned')
            {
                prg.Status__c='Requested';
            }
        }
    }

    @testvisible
    private void fireProvistioningEventAfterUpdate(List<Provisioning_Group__c> pgList, MAP<ID,Provisioning_Group__c> oldPGMap){
        System.debug('ProvisioningGroupTriggerHandler.afterUpdate().fireProvistioningEventAfterUpdate() is invoked ...!!');
        List<Provisioning_Event__e> pgevntList = new list<Provisioning_Event__e>();
        List<Provisioning_Event_Manual__e> pgevntManualList = new list<Provisioning_Event_Manual__e>();
        for(Provisioning_Group__c pg: pgList){
            Provisioning_Group__c oldPg = oldPGMap.get(pg.ID);
            if(pg.Product_Line__c!='CBI' && pg.Product_Line__c!='Deception'){
                if(pg.Provisioning_Type__c == 'Auto' && pg.Provisioning_Broker_Eligible__c == true
                   && pg.Status__c =='Requested'  && pg.Approval_Status__c=='Approved'
                   && ((pg.Status__c !=  oldPg.Status__c) || (pg.Approval_Status__c != oldPg.Approval_Status__c))){
                    pgevntList.add(new Provisioning_Event__e(PG_ID__c= pg.Id));
                }else if(pg.Provisioning_Type__c == 'Manual'
                        && pg.Approval_Status__c=='Approved'
                        && ((pg.Provisioning_Type__c !=  oldPg.Provisioning_Type__c) || (pg.Approval_Status__c != oldPg.Approval_Status__c))){
                    pgevntManualList.add(new Provisioning_Event_Manual__e(PG_ID__c= pg.Id));
                }
            }else if(pg.Product_Line__c=='CBI' || pg.Product_Line__c=='Deception'){
                if( pg.Provisioning_Type__c == 'Manual'
                   && pg.Approval_Status__c=='Approved' &&  pg.Status__c=='Requested'
                   && pg.Associated_ZIA_Zscaler_Cloud__c != null
                   && ((pg.Provisioning_Type__c !=  oldPg.Provisioning_Type__c) ||
                    (pg.Approval_Status__c != oldPg.Approval_Status__c) ||
                    (pg.Status__c != oldPg.Status__c))){
                    pgevntManualList.add(new Provisioning_Event_Manual__e(PG_ID__c= pg.Id));
                }
            }
        }
        
        if(pgevntList !=null && pgevntList.size()>0){
            EventBus.publish(pgevntList);
        }
        
        if(pgevntManualList.size()>0){
            EventBus.publish(pgevntManualList);
        }
    }
    
    @testvisible
    private void initiateWaitingSubscriptionZDXPGs(List<Provisioning_Group__c> pgList, Map<Id, Provisioning_Group__c> oldPGMap){
        Map<Id, Provisioning_Group__c> pgMap = new Map<Id, Provisioning_Group__c>(pgList);
        Map<Id, Id> cloudIdvsPG = new Map<Id, Id>();
        for(Provisioning_Group__c pg : pgList){
            if(pg.Status__c == 'Provisioned' 
               && pg.Status__c != oldPGMap.get(pg.Id).Status__c 
               && pg.RecordTypeId == subsPGRecordTypeId 
               && pg.Product_Line__c == 'ZIA' 
               && pg.Zscaler_Cloud_ID__c == oldPGMap.get(pg.Id).Zscaler_Cloud_ID__c 
               && pg.PG_Request_Type__c == 'Replace'){
                cloudIdvsPG.put(pg.Zscaler_Cloud_ID__c, pg.id);
            }
        }
            
        Map<Id, Provisioning_Group__c> pgUpdateMap = new Map<Id, Provisioning_Group__c>();
        if(!cloudIdvsPG.isEmpty()){
            List<Zscaler_Cloud_ID__c> lstcloud = [SELECT Id, Name, 
                                                    (SELECT Id, Name, Status__c, Zscaler_Cloud_ID__c 
                                                     FROM Provisioning_Groups_ZIA_Cloud__r 
                                                     WHERE product_line__c = 'ZDX'
                                                        AND Status__c = 'Waiting' 
                                                        AND Zscaler_Cloud_ID__c != null 
                                                        AND PG_Request_Type__c ='Replace' 
                                                        AND Sub_Status__c = 'Order Created' ORDER BY createdDate DESC)
                                                FROM Zscaler_Cloud_ID__c 
                                                WHERE Id IN :CloudIdvsPG.keySet()];
            if(!lstcloud.isEmpty()){
                List<Provisioning_Group__c> pglstToUpdate = new List<Provisioning_Group__c>();
                for(Zscaler_Cloud_ID__c objzs : lstcloud){
                    if(objzs.Provisioning_Groups_ZIA_Cloud__r != null 
                       && !objzs.Provisioning_Groups_ZIA_Cloud__r.isEmpty()){
                        for(Provisioning_Group__c pgobj : objzs.Provisioning_Groups_ZIA_Cloud__r){
                            pgobj.status__c = 'Requested';
                            pglstToUpdate.add(pgobj);
                        }
                    }
                }
                if(!pglstToUpdate.isEmpty()){
                    try{
                        update pglstToUpdate;
                    }catch(Exception ex){
                        ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupTriggerHandler','initiateWaitingSubscriptionZDXPGs',ex);
                    }                
                }
            }
        }
    }

    @testvisible
    private void initiateBrokerProcessForWaitingPGs(List<Provisioning_Group__c> pgList, Map<Id, Provisioning_Group__c> oldPGMap){
        System.debug('ProvisioningGroupTriggerHandler.afterUpdate().initiateBrokerProcessForWaitingPGs() is invoked ...!!');
        Map<Id, Provisioning_Group__c> pgMap = new Map<Id, Provisioning_Group__c>(pgList);
        Map<Id, Id> pgvsOpty = new Map<Id, Id>();
        Set<Id> ziaRejectedOptySet = new Set<Id>();
        for(Provisioning_Group__c pg : pgList){
            if(pg.Status__c == 'Provisioned' && pg.Zscaler_Cloud_ID__c != oldPGMap.get(pg.Id).Zscaler_Cloud_ID__c){
                pgvsOpty.put(pg.id, pg.Opportunity__c);
            }else if(pg.Approval_Status__c == 'Rejected'){
                ziaRejectedOptySet.add(pg.Opportunity__c);
            }
        }
        
        Map<Id, Provisioning_Group__c> pgUpdateMap = new Map<Id, Provisioning_Group__c>();
        List<Provisioning_Group__c> tobeUpdRejectedWaitingPGsList = null;
        if(!pgvsOpty.isEmpty()){
            /************************************ Waiting PGs ******************/
            Map<Id, List<Provisioning_Group__c>> parentPGWaitingPGsMap = new Map<Id, List<Provisioning_Group__c>>();
            for(Provisioning_Group__c waitingPG : [SELECT Id, Name, Provisioning_Request__c, Failure_Reason__c, Opportunity__c, Product_Line__c, Approval_Status__c, Associated_Provisioning_Group__c,PG_Request_Type__c
                                                    FROM Provisioning_Group__c 
                                                    WHERE Opportunity__c IN :pgvsOpty.values()
                                                    AND Status__c = 'Waiting'
                                                    AND Associated_Provisioning_Group__c IN :pgvsOpty.keyset()
                                                ])
            {
                if(parentPGWaitingPGsMap.containskey(waitingPG.Associated_Provisioning_Group__c)){
                    List<Provisioning_Group__c> waitingPGsList = parentPGWaitingPGsMap.get(waitingPG.Associated_Provisioning_Group__c);
                    waitingPGsList.add(waitingPG);
                    parentPGWaitingPGsMap.put(waitingPG.Associated_Provisioning_Group__c, waitingPGsList);
                }else{
                    List<Provisioning_Group__c> waitingPGsList = new List<Provisioning_Group__c>();  
                    waitingPGsList.add(waitingPG);
                    parentPGWaitingPGsMap.put(waitingPG.Associated_Provisioning_Group__c, waitingPGsList);
                }
            }
            
            /**************************** Waiting PGs Prcessing *******************************************/
            for(Id parentPGID : pgvsOpty.keyset()){
                Provisioning_Group__c parentPG = pgMap.get(parentPGID);
                if(parentPGWaitingPGsMap.containskey(parentPGID)){
                    for(Provisioning_Group__c waitingPG : parentPGWaitingPGsMap.get(parentPGID)){
                        if(waitingPG.Product_Line__c != 'CBI' && waitingPG.Product_Line__c != 'Deception'){
                            waitingPG.Associated_ZIA_Zscaler_Cloud__c = parentPG.Zscaler_Cloud_ID__c;
                            if((waitingPG.Product_Line__c != 'ZPA') || (waitingPG.Product_Line__c == 'ZPA' && waitingPG.PG_Request_Type__c != 'CREATE')){
                            waitingPG.Status__c = waitingPG.Approval_Status__c == 'Approved' ? 'Requested' : 'Initiated';
                            }
                            pgUpdateMap.put(waitingPG.Id, waitingPG);
                        }else if(waitingPG.Product_Line__c == 'CBI' || waitingPG.Product_Line__c == 'Deception'){
                            waitingPG.Associated_ZIA_Zscaler_Cloud__c = parentPG.Zscaler_Cloud_ID__c;
                            waitingPG.Manually_Processed__c = true;
                            waitingPG.Provisioning_Type__c = 'Manual';
                            waitingPG.Provisioning_Broker_Eligible__c = false;
                            waitingPG.Status__c = waitingPG.Approval_Status__c == 'Approved' ? 'Requested' : 'Initiated';
                            pgUpdateMap.put(waitingPG.Id, waitingPG);
                        }
                    }
                }
            }
        }else if(!ziaRejectedOptySet.isEmpty()){
            tobeUpdRejectedWaitingPGsList = new List<Provisioning_Group__c>();
            /************************************ When ZIA PG approval is Rejected then all Waiting PGs approval should be Rejected ******************/
            for(Provisioning_Group__c waitingPG : [SELECT Id, Name, Approval_Status__c, Product_Line__c  
                                                    FROM Provisioning_Group__c 
                                                    WHERE Opportunity__c IN :ziaRejectedOptySet
                                                    AND Status__c IN ('Waiting', 'Initiated')
                                                ])
            {
                if(waitingPG.Product_Line__c != 'ZIA'){
                    waitingPG.Status__c = 'Archived';
                    waitingPG.Approval_Status__c = 'Rejected';
                    waitingPG.Approval_Comments__c = 'Associated ZIA PRG got Rejected.';
                }else if(waitingPG.Product_Line__c == 'ZIA'){
                    waitingPG.Status__c = 'Archived';
                }
                tobeUpdRejectedWaitingPGsList.add(waitingPG);
                pgUpdateMap.put(waitingPG.Id, waitingPG);
            }
        }

        if(!pgUpdateMap.isEmpty()){
            List<Database.SaveResult> waitingPgsUpdResultList = Database.update(pgUpdateMap.values());
        }else if(tobeUpdRejectedWaitingPGsList != null && !pgUpdateMap.isEmpty()){
            //Bypass Triggers to avoid recursive trigger execution
            TriggerHandler.bypass('ProvisioningGroupTriggerHandler');
            List<Database.SaveResult> waitingRejectedPGsUpdResultList = Database.update(pgUpdateMap.values());
            TriggerHandler.clearBypass('ProvisioningGroupTriggerHandler');
        }
    }
    
    @testvisible
    private void archiveOldPGAfterProvision(List<Provisioning_Group__c> pgList, MAP<ID,Provisioning_Group__c> oldPGMap){
        System.debug('ProvisioningGroupTriggerHandler.afterUpdate().archiveOldPGAfterProvision() is invoked ...!!');
        List<Id> idsOfPGToArchive = new list<Id>();
        List<Id> idsOfPGToCancelArchive = new list<Id>();
        for(Provisioning_Group__c pg : pgList){
            Provisioning_Group__c oldPg = oldPGMap.get(pg.ID);
            if(pg.Renewed_From_Provisioning_Group__c!=null && 
                pg.Status__c != null && 
                oldPg.Status__c != null && 
                pg.Status__c != oldPg.Status__c && 
                pg.Status__c=='Provisioned' && 
                pg.Provisioning_Process__c != null && 
                (pg.Provisioning_Process__c == 'Add SKU'|| pg.Provisioning_Process__c == 'Change Platform SKU' || pg.Provisioning_Process__c == 'Associate ZIA' || pg.Provisioning_Process__c=='Add Feature'
                || (pg.PG_Request_Type__c == 'Replace' && pg.Workload_Communication_Product_Included__c == true)) ){
                idsOfPGToArchive.add(pg.Renewed_From_Provisioning_Group__c);
            }else if(pg.Status__c != null && 
                oldPg.Status__c != null && 
                pg.Approval_Status__c == 'Rejected' && 
                pg.Approval_Status__c != oldPg.Approval_Status__c && 
                pg.Provisioning_Process__c != null && 
                (pg.Provisioning_Process__c == 'Add SKU' || pg.Provisioning_Process__c == 'Change Platform SKU' || pg.Provisioning_Process__c == 'Associate ZIA' || pg.Provisioning_Process__c=='Add Feature'
                || (pg.PG_Request_Type__c == 'Replace' && pg.Workload_Communication_Product_Included__c == true)) ){
                idsOfPGToCancelArchive.add(pg.Renewed_From_Provisioning_Group__c);
            }
        }
        
        List<Provisioning_Group__c> pgsToUpdate = new List<Provisioning_Group__c>();
        for(Provisioning_Group__c archivePG : [Select id,Status__c,End_Date__c
                                               from Provisioning_Group__c where id in:idsOfPGToArchive])
        {
            archivePG.Status__c = 'Archived';
            archivePG.End_Date__c = System.today();
            pgsToUpdate.add(archivePG);
        }
        
        for(Provisioning_Group__c provisionPG : [Select id,Status__c
                                                 from Provisioning_Group__c where id in:idsOfPGToCancelArchive])
        {
            provisionPG.Status__c = 'Provisioned';
            pgsToUpdate.add(provisionPG);
        }
        
        if(pgsToUpdate != null && !pgsToUpdate.isEmpty()){
            Database.update(pgsToUpdate);
        }
    }
    
    @testvisible
    private void updatePGAfterExtension(List<Provisioning_Group__c> pgList, MAP<ID,Provisioning_Group__c> oldPGMap){
        System.debug('ProvisioningGroupTriggerHandler.afterUpdate().updatePGAfterExtension() is invoked ...!!');
        List<Id> idsOfPGToExtend = new list<Id>();
        List<Id> idsOfPGToNotExtend = new list<Id>();
        List<Provisioning_Product__c> provProducts = new List<Provisioning_Product__c>();
        List<Provisioning_Product__c> provProductToUpdate = new List<Provisioning_Product__c>();
        for(Provisioning_Group__c pg: pgList){
            Provisioning_Group__c oldPg = oldPGMap.get(pg.ID);
            if(pg.Approval_Status__c!=null && 
                pg.Provisioning_Extension_Status__c!=null &&
                pg.Provisioning_Extension_Status__c=='Extended' &&
                oldPg!=null &&
                pg.Provisioning_Extension_Status__c!=oldPg.Provisioning_Extension_Status__c &&
                pg.Provisioning_Process__c=='Extension' && 
                pg.Approval_Status__c=='Approved'){
                    idsOfPGToExtend.add(pg.Id);
            }else if(pg.Approval_Status__c!= null && 
                pg.Approval_Status__c!=oldPg.Approval_Status__c && 
                pg.Approval_Status__c=='Rejected' && 
                oldPg.Provisioning_Extension_Status__c!=null  && 
                oldPg.Provisioning_Extension_Status__c=='Extension Requested' && 
                pg.Provisioning_Process__c=='Extension'){
                    idsOfPGToNotExtend.add(pg.Id);
            }

        }
        
        List<Provisioning_Group__c> pgsToUpdate = new List<Provisioning_Group__c>();
        List<Provision_Request_Extension__c> pgExtensionList = new List<Provision_Request_Extension__c>();
        for(Provisioning_Group__c extendPG : [Select id,Status__c,End_Date__c,Number_of_Extensions__c,Extension_Reason__c,
                                              Extension_Requested_On__c,Opportunity__c,Name,
                                              (Select Id, End_Date__c from Provisioning_Products__r) 
                                              from Provisioning_Group__c where id in:idsOfPGToExtend ]){
            //extendPG.Provisioning_Extension_Status__c='Extended';
            if(oldPGMap.get(extendPG.Id).Provisioning_Extension_Status__c!=null 
                && oldPGMap.get(extendPG.Id).Provisioning_Extension_Status__c=='Extension Requested'){
                extendPG.Number_of_Extensions__c= extendPG.Number_of_Extensions__c+1;
                extendPG.End_Date__c= extendPG.End_Date__c!=null?extendPG.End_Date__c+30:System.today()+30;
                provProducts.addall(extendPG.Provisioning_Products__r);
                pgsToUpdate.add(extendPG);
            }
            Provision_Request_Extension__c pgExtensions = new Provision_Request_Extension__c();
            pgExtensions.Current_Expiry_Date__c = oldPGMap.get(extendPG.Id).End_Date__c;
            pgExtensions.Detailed_Reason_for_Contract_Extension__c = extendPG.Extension_Reason__c;
            pgExtensions.Extension_Requested_On__c = extendPG.Extension_Requested_On__c;
            pgExtensions.Extension_Requested_Till__c = extendPG.End_Date__c;
            pgExtensions.Number_of_Extensions__c = extendPG.Number_of_Extensions__c;
            pgExtensions.Opportunity__c = extendPG.Opportunity__c;
            pgExtensions.Provisioning_Request_Group__c = extendPG.Id;
            pgExtensions.Name = extendPG.Name;
            pgExtensionList.add(pgExtensions);
        }
        
        for(Provisioning_Group__c provisionPG : [Select id,Status__c
                                                 from Provisioning_Group__c where id in:idsOfPGToNotExtend]){
            provisionPG.Provisioning_Extension_Status__c='Extension Rejected';
            pgsToUpdate.add(provisionPG);
        }
        
        if(provProducts!=null){
            for(Provisioning_Product__c pp: provProducts){
                pp.End_Date__c=pp.End_Date__c!=null?pp.End_Date__c + 30:System.today()+30;
                provProductToUpdate.add(pp);
            }
        }
        
        if(pgsToUpdate != null && !pgsToUpdate.isEmpty()){
            Database.update(pgsToUpdate);
        }
        
        if(provProductToUpdate != null && !provProductToUpdate.isEmpty()){
            Database.update(provProductToUpdate);
        }

        if(pgExtensionList != null && !pgExtensionList.isEmpty()){
            try{
                Database.insert(pgExtensionList);
            }catch(Exception ex){
                ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupTriggerHandler','updatePGAfterExtension',ex);
            }
            
        }
                
    }
//Creating Case for CBI Products after the PRG is Provisioned
@testvisible
private void processPRFafterProvisioingfrCBI(List<Provisioning_Group__c>pgList , Map<ID, Provisioning_Group__c> oldPGMap ){
    List<Case> casesToInsertProvisionedCBI = new List<Case>();
    Case cs;
    List<Provisioning_Product__c> prgProv =[Select id ,SKU__c , Provisioning_Group__c from Provisioning_Product__c where provisioning_Group__c=:pgList];

    Map<Id,List<String>> pgVsSku = new Map<Id,List<String>>();
    for(Provisioning_Product__c pp:prgProv){
        if(!pgVsSku.keySet().contains(pp.Provisioning_Group__c)){
            pgVsSku.put(pp.Provisioning_Group__c,new List<String>());
        }
        pgVsSku.get(pp.Provisioning_Group__c).add(pp.SKU__c);
    }

    for(Provisioning_Group__c pg: pgList){
        Provisioning_Group__c oldPg = oldPGMap.get(pg.ID);
        if(pg != null && pg.Provisioning_Process__c != null && pg.Status__c != null 
                && (pg.Status__c != oldPg.Status__c)
                && pg.Status__c == 'Provisioned'){
                    Boolean skuPresentInLabel = false;
                    if(!pgVsSku.isEmpty() && pgVsSku != NULL && pgVsSku.containsKey(pg.id)){
                    	for(String sku:pgVsSku.get(pg.id)){
                            if(System.Label.CBI_Product_Code.contains(sku)){
                                skuPresentInLabel = true;
                                break;
                            }
                        }    
                    }
                    if(skuPresentInLabel){
                        cs = createCBICase(pg, pg.Name + ' : CBI Case Request');
                    }
                }
                if(cs != null){
                    casesToInsertProvisionedCBI.add(cs);
                }  
                if(!casesToInsertProvisionedCBI.isEmpty() && casesToInsertProvisionedCBI != null){
                    List<Database.UpsertResult> caseInsertResultList = Database.upsert(casesToInsertProvisionedCBI);                }
    }
}

    
    //Creating Case for Request Decomission PRGs in scope of MVP1
    @testvisible
    private void processPRGAfterDecomission(List<Provisioning_Group__c> pgList, Map<ID, Provisioning_Group__c> oldPGMap){
        System.debug('ProvisioningGroupTriggerHandler.afterUpdate().processPRGAfterDecomission() is invoked ...!!');
        List<Case> casesToInsertForDecommission = new List<Case>();
        Case cs;
       

        for(Provisioning_Group__c pg: pgList){
            Provisioning_Group__c oldPg = oldPGMap.get(pg.ID);
            if(pg != null && pg.Provisioning_Process__c != null && pg.Status__c != null 
                && (pg.Status__c != oldPg.Status__c)
                && pg.Provisioning_Process__c == 'Decommission'
                && pg.Status__c == 'Request Decommission'){
                    
                    cs = prepareCaseRecord(pg, pg.Name + ' : Tenant Decommission Request');
                }
            if(cs != null){
                casesToInsertForDecommission.add(cs);
            }  
        }
        if(!casesToInsertForDecommission.isEmpty() && casesToInsertForDecommission != null){
            try{
                List<Database.SaveResult> caseInsertResultList = Database.insert(casesToInsertForDecommission);
            }catch(Exception ex){
                ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupTriggerHandler','processPRGAfterDecomission',ex);
            }
        }
    }
    
    @testvisible
    private static Case prepareCaseRecord(Provisioning_Group__c pg, String sub){
        System.debug('In prepareCaseRecord(), Provisioning_Group__c val is: '+pg);
        Case cs = null;
        Map<String, DefaultData__c> ddmap = DefaultData__c.getAll();
        if(ddmap != null && !ddmap.isEmpty() && ddmap.containsKey('PRCaseCreationDefault')){
            cs = new Case(RecordTypeId = caseSupportRT);
            DefaultData__c dd = ddmap.get('PRCaseCreationDefault');
            List<Contact> conlist = new List<Contact>();
            cs.Provisioning_Group__c = pg.Id;
            if(pg.Product_Line__c != null && pg.Product_Line__c == 'ZPA'){
                cs.Product_New__c = 'ZPA';
            }
            else{
                cs.Product_New__c = 'ZIA';
            }
            cs.Case_Type__c = dd.Type__c;
            cs.Case_Category__c = dd.Category__c;
            cs.Subject = sub;
            cs.Status = dd.Stage_Status__c;
            cs.Priority = dd.Priority__c;
            cs.Description = 'Organisation Domain: ' + pg.Organization_Domain__c 
                + '\nPreferred Cloud: ' + pg.Preferred_Cloud__c 
                + '\nComments for Provisioning team: '+ pg.Comments__c != null ? pg.Comments__c : ' ' 
                + '\nExisting Zscaler Tenant Id: ' + pg.Associated_ZIA_Zscaler_Cloud__r.Name != null ? pg.Associated_ZIA_Zscaler_Cloud__r.name : ' ';
            
            String defaultPRDecommisionContact = ZscalerCustomSetting__c.getInstance('DefaultPRDecommisionContact') != null 
                                                    && ZscalerCustomSetting__c.getInstance('DefaultPRDecommisionContact').Value__c != null 
                                                        ? ZscalerCustomSetting__c.getInstance('DefaultPRDecommisionContact').Value__c 
                                                        : '';
            cs.ContactId = Id.valueof(defaultPRDecommisionContact);
            cs.Opportunity_Name__c = pg.Opportunity__c;
            cs.AccountId = dd.Provisioning_Account_Id__c;
        }
        System.debug('1212 ==>>> In prepareCaseRecord(), Case record is: ' + cs);
        return cs;
    }

    @testvisible
    private static Case createCBICase(Provisioning_Group__c pg, String sub){
        Case cs = null;
        Map<String, DefaultData__c> ddmap = DefaultData__c.getAll();
        if(ddmap != null && !ddmap.isEmpty() && ddmap.containsKey('PRCaseCreationDefault')){
            cs = new Case(RecordTypeId = caseSupportRT);
            DefaultData__c dd = ddmap.get('PRCaseCreationDefault');
            cs.Provisioning_Group__c = pg.Id;
            cs.Case_Type__c = dd.Type__c;
            cs.Subject = sub;
            cs.Status = dd.Stage_Status__c;
            cs.Priority = dd.Priority__c;
            cs.Opportunity_Name__c = pg.Opportunity__c;
            cs.AccountId = dd.Provisioning_Account_Id__c;
            cs.Case_Category__c = 'Deployment/Configuration';
            cs.Product_New__c = 'CBI';            
        }
        return cs;

    }

    
    @testvisible
    private void updateTenantForManual(List<Provisioning_Group__c> pgList, MAP<ID,Provisioning_Group__c> oldPGMap){
        Set<ID>pgIdsSet = new set<Id>();
        Map<Id,String> mapPGwithCloud = new map<Id,String>();
        for(Provisioning_Group__c pg: pgList){
            if(pg.Provisioning_Type__c =='Manual' && pg.Zscaler_Cloud_ID__c != null 
                && oldPGMap.get(pg.id).Zscaler_Cloud_ID__c != pg.Zscaler_Cloud_ID__c){
                mapPGwithCloud.put(pg.id,pg.Zscaler_Cloud_ID__c);
            }
        }

        if(mapPGwithCloud != null && mapPGwithCloud.size() > 0){
            //update Product
            List<Provisioning_Product__c>  lstProduct = [select id,Product_Line__c,Provisioning_Group__c ,Zscaler_Cloud_ID__c from Provisioning_Product__c where Provisioning_Group__c IN: mapPGwithCloud.keySet()];
            if(lstProduct !=null && lstProduct.size()>0){
                for(Provisioning_Product__c prObj : lstProduct){
                    if(mapPGwithCloud.containskey(prObj.Provisioning_Group__c) && mapPGwithCloud.get(prObj.Provisioning_Group__c) !=null){
                        prObj.Zscaler_Cloud_ID__c = mapPGwithCloud.get(prObj.Provisioning_Group__c);
                    }
                }
                try{
                    update lstProduct;
                }catch(Exception ex){
                    ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupTriggerHandler','updateTenantForManual',ex);
                }   
            }

            //updateContact 
            List<Provisioning_Contact__c> lstCont = [select id,Zscaler_Cloud_ID__c,Provisioning_Group__c, Provisioning_Group__r.Product_Line__c from Provisioning_Contact__c where Provisioning_Group__c IN: mapPGwithCloud.keySet()];
            if(lstCont !=null && lstCont.size() > 0){
                for(Provisioning_Contact__c pc : lstCont) {
                    if(mapPGwithCloud.containsKey(pc.Provisioning_Group__c) && mapPGwithCloud.get(pc.Provisioning_Group__c)!=null) {
                        pc.Zscaler_Cloud_ID__c = mapPGwithCloud.get(pc.Provisioning_Group__c);
                    }   
                }
                try{
                    update lstCont;
                }catch(Exception ex){
                    ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupTriggerHandler','updateTenantForManual lstCont',ex);
                }
            }
        }
    }

    //IBA-399 START
    @TestVisible
    private static void splitProvisioningGroupsBasedOnDates(List<Provisioning_Group__c> newProvisioningGroupList, Map<Id, Provisioning_Group__c> newPGMap, Map<Id, Provisioning_Group__c> oldPGMap) {
        Set<Id> provGroupIds =  new Set<Id>();
        List<Provisioning_Group__c> filteredProvisioningGroupList               = new List<Provisioning_Group__c>();
        Map<Id, Set<Date>> provGroupToProductsDatesMap                          = new Map<Id, Set<Date>>();
        Map<Id, List<Provisioning_Product__c>> provGroupToProductsMap           = new Map<Id, List<Provisioning_Product__c>>();
        Map<String, Provisioning_Group__c> oldPGIdsToNewListMap                 = new Map<String, Provisioning_Group__c>();
        Map<String, List<Provisioning_Product__c>> oldPGIdsToNewProvProdListMap = new Map<String, List<Provisioning_Product__c>>();
        List<Provisioning_Group__c> pgUpdateList                                = new List<Provisioning_Group__c>();
        Map<string,Date> minDateMap 											= new Map<string,Date>();
        Map<string,set<Date>> RampDatesMap 										= new Map<string,set<Date>>();
        Map<Id,List<Provisioning_Contact__c>> provContactMap = new Map<Id,List<Provisioning_Contact__c>>();
        List<Provisioning_Contact__c> provContactList = new List<Provisioning_Contact__c>();
        Set<Id> productIds = new Set<Id>();
        set<string> rampProducts = new Set<string>();
        for(Provisioning_Group__c newPG: newProvisioningGroupList) {
            Provisioning_Group__c oldPG = oldPGMap.get(newPG.Id);
            if ((oldPGMap.get(newPG.Id).Sub_Status__c != 'Order Created' && newPG.Sub_Status__c == 'Order Created') &&
                newPG.RecordTypeId == subsPGRecordTypeId) {
                    filteredProvisioningGroupList.add(newPG);
                    provGroupIds.add(newPG.Id);
            }
        }
        for(Provisioning_Contact__c PC : [SELECT Id,Contact__c,Email__c,Name,Provisioning_Group__c,Type__c,User__c,User_Name__c,Zscaler_Cloud_ID__c,Provisioning_Group__r.Zscaler_Cloud_ID__c FROM Provisioning_Contact__c WHERE Provisioning_Group__c IN : provGroupIds]){
            if(provContactMap.containsKey(PC.Provisioning_Group__c)){
                provContactMap.get(PC.Provisioning_Group__c).add(PC);
            }
            else{
                provContactMap.put(PC.Provisioning_Group__c,new List<Provisioning_Contact__c>{PC});
            }
        }
        
        if(!filteredProvisioningGroupList.isEmpty()) {
            String provisioningProductFields = getFieldNamesOfSObject('Provisioning_Product__c');
            String query = 'SELECT ' + provisioningProductFields + ' FROM Provisioning_Product__c ' + 
                'WHERE Provisioning_Group__c IN :filteredProvisioningGroupList';
            for(Provisioning_Product__c provProd : Database.query(query)){
                Set<Date> startDatesSet = new Set<Date>(provGroupToProductsDatesMap.containsKey(provProd.Provisioning_Group__c) ? 
                provGroupToProductsDatesMap.get(provProd.Provisioning_Group__c) : 
                new Set<Date>());
                List<Provisioning_Product__c> provProdsList = new List<Provisioning_Product__c>(provGroupToProductsMap.containsKey(provProd.Provisioning_Group__c) ? 
                provGroupToProductsMap.get(provProd.Provisioning_Group__c) : 
                new List<Provisioning_Product__c>());

                startDatesSet.add(provProd.Start_Date__c);
                provProdsList.add(provProd);
                provGroupToProductsDatesMap.put(provProd.Provisioning_Group__c, startDatesSet);
                provGroupToProductsMap.put(provProd.Provisioning_Group__c, provProdsList);
                productIds.add(provProd.product__c);
                if(minDateMap != NULL && minDateMap.containsKey(provProd.Provisioning_Group__c+'-'+provProd.product__c)){
                    rampProducts.add(provProd.Provisioning_Group__c+'-'+provProd.product__c);
                    RampDatesMap.get(provProd.Provisioning_Group__c+'-'+provProd.product__c).add(provProd.Start_Date__c);
                    if(Date.valueof(provProd.Start_Date__c) < Date.valueof(minDateMap.get(provProd.Provisioning_Group__c+'-'+provProd.product__c))){
                    	minDateMap.put(provProd.Provisioning_Group__c+'-'+provProd.product__c,provProd.Start_Date__c);    
                    }	    
                }
                else{
                	minDateMap.put(provProd.Provisioning_Group__c+'-'+provProd.product__c,provProd.Start_Date__c); 
                    RampDatesMap.put(provProd.Provisioning_Group__c+'-'+provProd.product__c,new set<date>{provProd.Start_Date__c});
                }
            }
        }
        for(Id pgId: provGroupToProductsDatesMap.keySet()){
            if(provGroupToProductsDatesMap.get(pgId).size() > 1) {
                for(Date startDate: provGroupToProductsDatesMap.get(pgId)) {
                    Map<Id, Provisioning_Product__c> splitProvProdsMap = new Map<Id, Provisioning_Product__c>();
                    String splitPGKey = String.valueOf(pgId) + String.valueOf(startDate);
                    Provisioning_Group__c splitPG = newPGMap.containsKey(pgId) ? newPGMap.get(pgId).clone(false, true, false, false) : new Provisioning_Group__c();
                    splitPG.Provisioning_Submission_Date__c = startDate;
                    splitPG.Original_Provisioning_Group__c = pgId;
                    splitPG.Status__c = 'Waiting';
                    splitPG.PG_Request_Type__c = 'Replace';
                    splitPG.Provisioning_Process__c ='Split PRG for Ramps';
                    splitPG.Subscription_Id__c = '';
                    splitPG.Subscription_Name__c = '';
                    splitPG.Provisioning_Type__c = 'Auto';
                    Date lowestStartDate;
                    Date highestEndDate;
                    Date prodHighestEndDate;
                    Map<Id, Date> prodHighestEndDateMap = new Map<Id, Date>();
                    Map<Id, Date> prodLowestStartDateMap = new Map<Id, Date>();
                    for(Provisioning_Product__c provProd :provGroupToProductsMap.get(pgId)) {
                        if(prodHighestEndDateMap.get(provProd.Product__c) == null || prodHighestEndDateMap.get(provProd.Product__c) < provProd.End_Date__c) {
                            prodHighestEndDateMap.put(provProd.Product__c, provProd.End_Date__c);
                        }
                        if(prodLowestStartDateMap.get(provProd.Product__c) == null || prodLowestStartDateMap.get(provProd.Product__c) > provProd.Start_Date__c) {
                            prodLowestStartDateMap.put(provProd.Product__c, provProd.Start_Date__c);
                        }
                        
                        
                        
                        if(provProd.End_Date__c > startDate) {
                            
                            if(provProd.Start_Date__c > startDate) {
                                if(splitProvProdsMap.get(provProd.product__c) == null && splitPG.product_line__c == 'ZIA') {
                                    Provisioning_Product__c splitPP = provProd.clone(false, true, false, false);
                                    splitPP.ContinueTrialForFutureDatedSku__c = true;
                                    splitProvProdsMap.put(splitPP.product__c, splitPP);
                                }
                            } else {
                                Provisioning_Product__c splitPP = provProd.clone(false, true, false, false);
                                splitProvProdsMap.put(splitPP.product__c, splitPP);
                            }
                            
                            
                            /*if(lowestStartDate == null || provProd.Start_Date__c < lowestStartDate) {
                                lowestStartDate = provProd.Start_Date__c;
                            }
                            /*if(highestEndDate == null || provProd.End_Date__c > highestEndDate) {
                                highestEndDate = provProd.End_Date__c;
                            }*/
                        }
                    }
                    for(Provisioning_Product__c provProd :splitProvProdsMap.values()) {
                        provProd.End_Date__c = splitPG.End_Date__c;
                        provProd.Start_Date__c = splitPG.Start_Date__c;
                    	if(rampProducts.contains(pgId+'-'+provProd.product__c) && RampDatesMap.containsKey(pgId+'-'+provProd.product__c) && RampDatesMap.get(pgId+'-'+provProd.product__c).contains(startDate) 
                           && minDateMap != NULL && minDateMap.containsKey(pgId+'-'+provProd.product__c) && minDateMap.get(pgId+'-'+provProd.product__c) != startDate){
            				splitPG.Provisioning_Type__c = 'Manual';    
            			}
                    }
                    //splitPG.Start_Date__c = lowestStartDate;
                    //splitPG.End_Date__c = highestEndDate;
                    oldPGIdsToNewListMap.put(splitPGKey, splitPG);
                    oldPGIdsToNewProvProdListMap.put(splitPGKey, splitProvProdsMap.values());
                }
                Provisioning_Group__c origPG = new Provisioning_Group__c();
                origPG.Id = pgId;
                origPG.Status__c = 'Archived';
                pgUpdateList.add(origPG);
            } 
            else {
                if(newPGMap.get(pgId).Provisioning_Submission_Date__c <= system.today() && newPGMap.get(pgId).Product_Line__c != 'ZDX'){
                    Provisioning_Group__c origPG = new Provisioning_Group__c();
                    origPG.Id = pgId;
                    origPG.Status__c = 'Requested';
                    pgUpdateList.add(origPG);
                }
            }
        }
        if(oldPGIdsToNewListMap.values() != null && !oldPGIdsToNewListMap.values().isEmpty()) {
            try{
                insert oldPGIdsToNewListMap.values();
            }catch(Exception ex){
                ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupTriggerHandler','splitProvisioningGroupsBasedOnDates',ex);
            }
            
        }

        List<Provisioning_Product__c> newProvProdUpdateList = new List<Provisioning_Product__c>();
        for(String pgKey: oldPGIdsToNewProvProdListMap.keySet()) {
            Id newPGId = oldPGIdsToNewListMap.get(pgKey).Id;
            for(Provisioning_Product__c pp: oldPGIdsToNewProvProdListMap.get(pgKey)) {
                pp.Provisioning_Group__c = newPGId;
                newProvProdUpdateList.add(pp);
            }
        }
        if(newProvProdUpdateList != null && !newProvProdUpdateList.isEmpty()) {
            try{
                insert newProvProdUpdateList;
            }catch(Exception ex){
                ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupTriggerHandler','splitProvisioningGroupsBasedOnDates-newProvProdUpdateList',ex);
            }
        }
        
        for(Provisioning_Group__c pg: oldPGIdsToNewListMap.values()) {
            if(pg.Provisioning_Submission_Date__c != null && pg.Provisioning_Submission_Date__c <= System.today() && pg.Product_Line__c != 'ZDX') {
                Provisioning_Group__c newSplitPG = new Provisioning_Group__c();
                newSplitPG.Id = pg.Id;
                newSplitPG.Status__c = 'Requested';
                pgUpdateList.add(newSplitPG);
            }
            if(provContactMap != NULL && provContactMap.containsKey(pg.Original_Provisioning_Group__c)){
                for(Provisioning_Contact__c PC : provContactMap.get(pg.Original_Provisioning_Group__c)){
                    Provisioning_Contact__c newPC = PC.clone(false,true,false,false);
                    newPC.Provisioning_Group__c = pg.Id;
                    provContactList.add(newPC);
                }
            }
        }
        
        if(provContactList != null && !provContactList.isEmpty()) {
            try{
                insert provContactList;
            }catch(Exception ex){
                ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupTriggerHandler','splitProvisioningGroupsBasedOnDates-provContactList',ex);
            }
        }
        
        if(pgUpdateList != null && !pgUpdateList.isEmpty()) {
            try{
                update pgUpdateList;
            }catch(Exception ex){
                ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupTriggerHandler','splitProvisioningGroupsBasedOnDates-pgUpdateList',ex);
            }
        }
    }

    //IBA-399 START
    /*@TestVisible
    private static void autoCreatePGForSubscription(List<Provisioning_Group__c> newProvisioningGroupList, Map<Id, Provisioning_Group__c> oldPGMap) {
        try{
            Map<Id,Date> maxEndDateMap = new Map<Id,Date>();
            Map<Id,Date> minStartDateMap = new Map<Id,Date>();
            Set<Id> provGroupIds =  new Set<Id>();
            List<Provisioning_Contact__c> provContactList = new List<Provisioning_Contact__c>();
            Map<Id, Id> cloudIdToNewPGIdMap = new Map<Id, Id>(); 
            List<Provisioning_Group__c> filteredProvisioningGroupList = new List<Provisioning_Group__c>();
            for(Provisioning_Group__c currentPG: newProvisioningGroupList) {
                if ((((oldPGMap == null || (oldPGMap.get(currentPG.Id).Zscaler_Cloud_ID__c == null)) && currentPG.Zscaler_Cloud_ID__c != null) ||
                    ((oldPGMap == null || (oldPGMap.get(currentPG.Id).Status__c != 'Provisioned')) && currentPG.Status__c == 'Provisioned')) &&
                    currentPG.RecordTypeId == trialPGRecordTypeId && currentPG.PG_for_Subscription__c == true) {
                    filteredProvisioningGroupList.add(currentPG);
                }
            }
            
            Map<Id, List<Provisioning_Product__c>> provisioningGroupWithProductsMap = new Map<Id, List<Provisioning_Product__c>>(); 
            if(!filteredProvisioningGroupList.isEmpty()) {
                provisioningGroupWithProductsMap = getPGAndRelatedProvisioningProducts(filteredProvisioningGroupList);
            }

            List<Provisioning_Group__c> provisioningGroupListToInsert = new List<Provisioning_Group__c>();
            List<Provisioning_Group__c> provisioningGroupListToUpdate = new List<Provisioning_Group__c>();
            List<Provisioning_Product__c> provisioningProductsListToInsert = new List<Provisioning_Product__c>();
            Map<String, List<Provisioning_Product__c>> pgKeyToProvProdsMap = new Map<String, List<Provisioning_Product__c>>();
            
            for (Provisioning_Group__c provisioningGroup : filteredProvisioningGroupList) {
                provGroupIds.add(provisioningGroup.Id);
                Provisioning_Group__c clonedProvisioningGroup = provisioningGroup.clone(false, true, false, false);
                clonedProvisioningGroup.RecordTypeId = subsPGRecordTypeId;
                clonedProvisioningGroup.Status__c = 'Waiting';
                clonedProvisioningGroup.Sub_Status__c = 'Waiting for Order';
                clonedProvisioningGroup.PG_Request_Type__c = 'Replace';
                clonedProvisioningGroup.Provisioning_Process__c ='Convert Trial to Subscription';
                clonedProvisioningGroup.Original_Provisioning_Group__c = provisioningGroup.Id;
                clonedProvisioningGroup.PG_for_Subscription__c = false;
                List<Provisioning_Product__c> provisioningProductsList = new List<Provisioning_Product__c>();
                List<Provisioning_Product__c> tempProductsList = provisioningGroupWithProductsMap.containsKey(provisioningGroup.Id) ? provisioningGroupWithProductsMap.get(provisioningGroup.Id) : new List<Provisioning_Product__c>();
                
                for (Provisioning_Product__c provisioningProduct : tempProductsList) {
                    Provisioning_Product__c clonedProvisioningProduct = provisioningProduct.clone(false, true, false, false);
                    if(clonedProvisioningProduct.Subscription_Lines_Data__c != null) {
                        List<String> subscriptionsData = clonedProvisioningProduct.Subscription_Lines_Data__c.split(',');
                        List<String> fieldsData = subscriptionsData[0].split(':');
                        clonedProvisioningProduct.Start_Date__c = Date.valueOf(fieldsData[0]);
                        clonedProvisioningProduct.End_Date__c   = Date.valueOf(fieldsData[1]);
                        clonedProvisioningProduct.Quantity__c   = Decimal.valueOf(fieldsData[2]);
                        clonedProvisioningProduct.Status__c     = 'Subscribed';
                        provisioningProductsList.add(clonedProvisioningProduct);
                        if(subscriptionsData.size() > 1) {
                            for(String subsData: subscriptionsData) {
                                fieldsData = subsData.split(':');
                                if(clonedProvisioningProduct.Start_Date__c < Date.valueOf(fieldsData[0])) {
                                    Provisioning_Product__c clonedProvisioningProduct1 = provisioningProduct.clone(false, true, false, false);
                                    clonedProvisioningProduct1.Start_Date__c = Date.valueOf(fieldsData[0]);
                                    clonedProvisioningProduct1.End_Date__c   = Date.valueOf(fieldsData[1]);
                                    clonedProvisioningProduct1.Quantity__c   = Decimal.valueOf(fieldsData[2]);
                                    provisioningProductsList.add(clonedProvisioningProduct1);
                                }
                            }
                        }
                    }
                }
                for (Provisioning_Product__c provisioningProduct : provisioningProductsList) {
                    if(!maxEndDateMap.containsKey(provisioningProduct.Provisioning_Group__c)){
                        maxEndDateMap.put(provisioningProduct.Provisioning_Group__c,provisioningProduct.End_Date__c);               
                    }
                    else{
                        if(provisioningProduct.End_Date__c > maxEndDateMap.get(provisioningProduct.Provisioning_Group__c)){
                            maxEndDateMap.put(provisioningProduct.Provisioning_Group__c,provisioningProduct.End_Date__c);       
                        }           
                    }
                    if(!minStartDateMap.containsKey(provisioningProduct.Provisioning_Group__c)){
                        minStartDateMap.put(provisioningProduct.Provisioning_Group__c,provisioningProduct.Start_Date__c);       
                    }
                    else{
                        if(provisioningProduct.Start_Date__c < minStartDateMap.get(provisioningProduct.Provisioning_Group__c)){
                            minStartDateMap.put(provisioningProduct.Provisioning_Group__c,provisioningProduct.Start_Date__c);       
                        }
                    }
                }
                clonedProvisioningGroup.Start_Date__c = minStartDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c);
                clonedProvisioningGroup.End_Date__c = maxEndDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c);
                clonedProvisioningGroup.Provisioning_Submission_Date__c = minStartDateMap.get(clonedProvisioningGroup.Original_Provisioning_Group__c);
                clonedProvisioningGroup.ZSCM_End_Date__c = clonedProvisioningGroup.End_Date__c;
                clonedProvisioningGroup.Subscription_Id__c = '';
                clonedProvisioningGroup.Subscription_Name__c = '';
                provisioningGroupListToInsert.add(clonedProvisioningGroup);
                
                String pgKey = (clonedProvisioningGroup.Opportunity__c != null ? String.valueOf(clonedProvisioningGroup.Opportunity__c) : '') + 
                    (clonedProvisioningGroup.Zscaler_Cloud_ID__c != null ? String.valueOf(clonedProvisioningGroup.Zscaler_Cloud_ID__c) : '') ;
                pgKeyToProvProdsMap.put(pgKey, provisioningProductsList);
            }
            provContactList = CreateSalesOrderExtensionCPQSalesLWCNew.cloneProvisioningContacts(provGroupIds);
            
            if (!provisioningGroupListToInsert.isEmpty()) {
                insert provisioningGroupListToInsert;
                //To associate the new Provisioning Products to newly created Provisioning Groups
                for (Provisioning_Group__c provisioningGroup : provisioningGroupListToInsert) {
                    cloudIdToNewPGIdMap.put(provisioningGroup.Zscaler_Cloud_ID__c,provisioningGroup.Id);
                    String pgKey = (provisioningGroup.Opportunity__c != null ? String.valueOf(provisioningGroup.Opportunity__c) : '') + 
                        (provisioningGroup.Zscaler_Cloud_ID__c != null ? String.valueOf(provisioningGroup.Zscaler_Cloud_ID__c) : '') ;
                    
                    List<Provisioning_Product__c> provisioningProductsList = pgKeyToProvProdsMap.containsKey(pgKey) ? pgKeyToProvProdsMap.get(pgKey) : new List<Provisioning_Product__c>();
                    
                    for (Provisioning_Product__c provisioningProduct : provisioningProductsList) {
                        provisioningProduct.Provisioning_Group__c = provisioningGroup.Id;
                        provisioningProductsListToInsert.add(provisioningProduct);
                    }
                }
                
                if (!provisioningProductsListToInsert.isEmpty()) {
                    insert provisioningProductsListToInsert;
                }
                
                List<Provisioning_Group__c> oldPGUpdateList = new List<Provisioning_Group__c>();
                for (Provisioning_Group__c provisioningGroup : filteredProvisioningGroupList) {
                    Provisioning_Group__c pg = new Provisioning_Group__c();
                    pg.Id = provisioningGroup.Id;
                    pg.status__c = 'Archived';
                    oldPGUpdateList.add(pg);
                }
                for(Provisioning_Contact__c pc : provContactList){
                    if(cloudIdToNewPGIdMap.containsKey(pc.Provisioning_Group__r.Zscaler_Cloud_ID__c)){
                        pc.Provisioning_Group__c = cloudIdToNewPGIdMap.get(pc.Provisioning_Group__r.Zscaler_Cloud_ID__c);    
                    }
                }

                if(provContactList != null && !provContactList.isEmpty()) {
                    insert provContactList;
                }
            }
        }
        catch(Exception ex){
            System.debug('--autoCreatePGForSubscriptionMessage--Exception--- '+ex);
        }
    }*/
    
    @TestVisible
    private static String getFieldNamesOfSObject(String objectName) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        
        String queryFields = '';
        for(String fieldName : fieldMap.keySet()) {
           // if(fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                queryFields += fieldName + ',';
           // }
        }
        queryFields = queryFields.removeEnd(',');
        return queryFields;
    }
    
    @TestVisible
    private static Map<Id, List<Provisioning_Product__c>> getPGAndRelatedProvisioningProducts(List<Provisioning_Group__c> provisioningGroupList) {
        String provisioningProductFields = getFieldNamesOfSObject('Provisioning_Product__c');
        String query = 'SELECT ' + provisioningProductFields + ' FROM Provisioning_Product__c ' + 
            'WHERE Provisioning_Group__c IN :provisioningGroupList';
        List<Provisioning_Product__c> provisioningProductsList = Database.query(query);
        
        Map< Id, List<Provisioning_Product__c>> pgIdToProvisioningProductsMap = new Map<Id, List<Provisioning_Product__c>>();
        for (Provisioning_Product__c provisioningProduct : provisioningProductsList) {
            if (!pgIdToProvisioningProductsMap.containsKey(provisioningProduct.Provisioning_Group__c)) {
                pgIdToProvisioningProductsMap.put(provisioningProduct.Provisioning_Group__c, new List<Provisioning_Product__c>());
            }
            pgIdToProvisioningProductsMap.get(provisioningProduct.Provisioning_Group__c).add(provisioningProduct);
        }
        return pgIdToProvisioningProductsMap;
    }
    // IBA-399 END
    
    private void archiveOldPGAPGSubscription(List<Provisioning_Group__c> pgList, MAP<ID,Provisioning_Group__c> oldPGMap){
        System.debug('ProvisioningGroupTriggerHandler.afterUpdate().archiveOldPGAPGSubscription() is invoked ...!!');
        List<Id> idsOfPGToArchive = new list<Id>();
        List<Id> idsOfPGToCancelArchive = new list<Id>();
        String recordTypeId = subsPGRecordTypeId;
        set<Id> pgIds = new set<Id>();
        for(Provisioning_Group__c pg : pgList){
            Provisioning_Group__c oldPg = oldPGMap.get(pg.ID);
            pgIds.add(pg.ID);
        }
        List<Provisioning_Group__c> filteredPGList = [SELECT id,Name,Original_Provisioning_Group__c,Provisioning_Process__c,Original_Provisioning_Group__r.Original_Provisioning_Group__c,Status__c,PG_for_Subscription__c,RecordTypeId 
                                              FROM Provisioning_Group__c
                                              WHERE Id IN : pgIds];
        for(Provisioning_Group__c pg : filteredPGList){
            if(((pg.Original_Provisioning_Group__c!=null || (pg.Provisioning_Process__c == 'Split PRG for Ramps' && pg.Original_Provisioning_Group__r.Original_Provisioning_Group__c != NULL)) && pg.Status__c != null && oldPGMap.get(pg.Id).Status__c!=null && pg.Status__c != oldPGMap.get(pg.Id).Status__c &&
               pg.Status__c=='Provisioned') && ((pg.PG_for_Subscription__c ==true && pg.RecordTypeId == trialPGRecordTypeId)|| pg.RecordTypeId == subsPGRecordTypeId)){
                if(pg.Provisioning_Process__c == 'Split PRG for Ramps'){
                    idsOfPGToArchive.add(pg.Original_Provisioning_Group__r.Original_Provisioning_Group__c);       
                }
                else{
                    idsOfPGToArchive.add(pg.Original_Provisioning_Group__c);
                }
            }    
        }    
        List<Provisioning_Group__c> pgsToUpdate = new List<Provisioning_Group__c>();
        for(Provisioning_Group__c archivePG : [Select id,Status__c,End_Date__c
                                               from Provisioning_Group__c where id in:idsOfPGToArchive and Status__c ='Provisioned'])
        {
            archivePG.Status__c='Archived';
            pgsToUpdate.add(archivePG);
        }
        if(pgsToUpdate != null && !pgsToUpdate.isEmpty()){
            Database.update(pgsToUpdate);
        }
    }
    
    @TestVisible
    private static void setSEManagerValues(List<Provisioning_Group__c> provisioningGroupList) {
        List<Provisioning_Group__c> pgList = new List<Provisioning_Group__c>();
        for(Provisioning_Group__c prg : provisioningGroupList){
            if(prg.Approval_Status__c == 'Not Submitted' && (prg.Opportunity__c != null || prg.Account__c != null) && (prg.SE__c == null || prg.SE_Manager_Email__c == null)){
                pgList.add(prg);
            }
        }
        
        if(pgList.size()>0){
            Set<ID> opportunityIDs = new Set<ID>();
            Set<ID> accountIDs = new Set<ID>();
            for(Provisioning_Group__c prg : pgList){
                if(prg.Opportunity__c != null){
                    opportunityIDs.add(prg.Opportunity__c);
                }
                if(prg.Account__c != null){
                    accountIDs.add(prg.Opportunity__c);
                }
            }
            
            MAP<ID, Opportunity> oppMAP = new MAP<ID, opportunity>([Select id,SE_Name__c,SE_Name__r.ManagerID from Opportunity where id in :opportunityIDs]);
            MAP<ID, Account> accMAP = new MAP<ID, Account>([Select id,Sales_Territory__r.Sales_Engineer__c,Sales_Territory__r.Sales_Engineer__r.ManagerID from Account where id in :accountIDs]);
            
            for(Provisioning_Group__c prg : pgList){
                //Set SE
                if(prg.SE__c == null && prg.Opportunity__c != null){
                    prg.SE__c = oppMAP.containskey(prg.Opportunity__c) && oppMAP.get(prg.Opportunity__c).SE_Name__c != null 
                        ? oppMAP.get(prg.Opportunity__c).SE_Name__c 
                        : prg.SE__c;
                }
                if(prg.SE__c == null && prg.Account__c != null){
                    prg.SE__c = (accMAP.containskey(prg.Account__c) && accMAP.get(prg.Account__c).Sales_Territory__r.Sales_Engineer__c != null) 
                        ? accMAP.get(prg.Account__c).Sales_Territory__r.Sales_Engineer__c
                        : prg.SE__c;
                }
                
                //SET SE Manager
                if(prg.SE_Manager_Email__c == null && prg.Opportunity__c != null){
                    prg.SE_Manager_Email__c = oppMAP.containskey(prg.Opportunity__c) && oppMAP.get(prg.Opportunity__c).SE_Name__r.ManagerID != null
                        ? oppMAP.get(prg.Opportunity__c).SE_Name__r.ManagerID 
                        : prg.SE_Manager_Email__c;
                }
                if(prg.SE_Manager_Email__c == null && prg.Account__c != null){
                    prg.SE_Manager_Email__c = (accMAP.containskey(prg.Account__c) && accMAP.get(prg.Account__c).Sales_Territory__r.Sales_Engineer__r.ManagerID != null) 
                        ? accMAP.get(prg.Account__c).Sales_Territory__r.Sales_Engineer__r.ManagerID
                        : prg.SE_Manager_Email__c;
                }
            }
        }
    }
    // IBA-399 END

    //IBA-2265 START
    @testvisible
    private void CreateClusterCaseForZIA(List<Provisioning_Group__c> pgList, MAP<ID,Provisioning_Group__c> oldPGMap, Boolean isUpdate){
        System.debug('ProvisioningGroupTriggerHandler.afterUpdate().CreateClusterCaseForZIA() is invoked ...!!');   
        List<Case> casesToInsertForClusterUpdate = new List<Case>();
        Set<Id> prgIdsForCaseCreation = new Set<Id>();
        Case cs;
        for(Provisioning_Group__c prg : pgList){
            if(isUpdate && prg.Provisioning_Type__c == 'Auto' && prg.Product_Line__c == 'ZIA' && prg.Approval_Status__c == 'Approved' && 
                oldPGMap.get(prg.Id).Approval_Status__c != 'Approved' && prg.PG_Request_Type__c == 'Create' && (prg.Nanolog_Cluster__c == NULL
                || prg.Sandbox_Cluster__c == NULL) && prg.RecordTypeId == trialPGRecordTypeId){
                cs = prepareCaseRecord(prg, prg.Name + ' : Cluster Selection');
                if(cs != null){
                    casesToInsertForClusterUpdate.add(cs);
                }
            }
            else  if(prg.Status__c !='Requested' && prg.Approval_Status__c=='Approved' && prg.Provisioning_Type__c == 'Auto' && prg.Product_Line__c == 'ZIA' && 
                     !isUpdate && prg.PG_Request_Type__c == 'Create' && (prg.Nanolog_Cluster__c == NULL || prg.Sandbox_Cluster__c == NULL) && prg.RecordTypeId == trialPGRecordTypeId){
                cs = prepareCaseRecord(prg, prg.Name + ' : Cluster Selection');
                if(cs != null){
                    casesToInsertForClusterUpdate.add(cs);
                }       
            } 
        }
         if(!casesToInsertForClusterUpdate.isEmpty() && casesToInsertForClusterUpdate != null){
            try{
                List<Database.SaveResult> caseInsertResultList = Database.insert(casesToInsertForClusterUpdate);
            }catch(Exception ex){
                if(!ex.getMessage().contains('UNABLE_TO_LOCK_ROW')){
                	ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupTriggerHandler','CreateClusterCaseForZIA',ex);    
                }
                else{
                    caseRetryMethod(casesToInsertForClusterUpdate,1,'Cluster Case');
                }
            }
            
        }
    }
    //IBA-2265 END
    
    //IBA-2494 START
    @testvisible
    private void SubmitZIAForProvisioning(List<Provisioning_Group__c> pgList, MAP<ID,Provisioning_Group__c> oldPGMap, Boolean isUpdate){
        System.debug('ProvisioningGroupTriggerHandler.beforeUpdate().SubmitZIAForProvisioning() is invoked ...!!'); 
        if(!isUpdate){
            for(Provisioning_Group__c prg : pgList){
                if(prg.Provisioning_Process__c!='Extension' && prg.Provisioning_Type__c == 'Auto' && prg.Product_Line__c == 'ZIA' && prg.Approval_Status__c == 'Approved' && prg.PG_Request_Type__c != 'Create' && prg.RecordTypeId == trialPGRecordTypeId){
                    prg.Status__c = 'Requested';   
                }
                else if(prg.Provisioning_Process__c!='Extension' && prg.PG_Request_Type__c == 'Create' && prg.Nanolog_Cluster__c != NULL && prg.Sandbox_Cluster__c != NULL && 
                        prg.Provisioning_Type__c == 'Auto' && prg.Product_Line__c == 'ZIA' && prg.Approval_Status__c == 'Approved'  && prg.RecordTypeId == trialPGRecordTypeId){
                    prg.Status__c = 'Requested';
                    prg.Send_for_Provisioning__c = true;
                }
            }       
        }else{
            for(Provisioning_Group__c prg : pgList){
                if((prg.Provisioning_Type__c == 'Auto' && prg.Product_Line__c == 'ZIA' && prg.Send_for_Provisioning__c == TRUE && 
                 oldPGMap.get(prg.Id).Send_for_Provisioning__c != TRUE && prg.Approval_Status__c == 'Approved' && prg.PG_Request_Type__c == 'Create' && prg.RecordTypeId == trialPGRecordTypeId) || 
                 (prg.Provisioning_Type__c == 'Auto' && prg.Product_Line__c == 'ZIA' && prg.Approval_Status__c == 'Approved' && 
                 prg.PG_Request_Type__c != 'Create' && oldPGMap.get(prg.Id).Approval_Status__c != 'Approved' && prg.RecordTypeId == trialPGRecordTypeId) && prg.Provisioning_Process__c!='Extension'){
                    prg.Status__c = 'Requested';    
                }
                else if(prg.Provisioning_Process__c!='Extension' && prg.Provisioning_Type__c == 'Auto' && prg.Product_Line__c == 'ZIA' && prg.Approval_Status__c == 'Approved' && oldPGMap.get(prg.Id).Approval_Status__c != 'Approved' && 
                        prg.PG_Request_Type__c == 'Create' && prg.Nanolog_Cluster__c != NULL && prg.Sandbox_Cluster__c != NULL && prg.RecordTypeId == trialPGRecordTypeId){
                    prg.Status__c = 'Requested';
                    prg.Send_for_Provisioning__c = true;    
                }
            }    
        } 
    }
    //IBA-2494 END
    
    /*private static Map<Id, Decimal> getPOVQuantityFromProductLiocenses(Set<Id> productIds) {
        
        Map<Id, Decimal> productPOVQtyMap = new Map<Id, Decimal>();
        for(AggregateResult ar : [Select Product__c, max(POV_Quantity__c) povQty from Product_License__c where Product__c in : productIds and POV_Quantity__c != null group by Product__c]) {
            if(ar.get('povQty') != null) {
                String prodIdStr = String.valueOf(ar.get('Product__c'));
                String povQtyStr = String.valueOf(ar.get('povQty'));
                if(povQtyStr.isNumeric() && Decimal.valueOf(povQtyStr) > 0) {
                    productPOVQtyMap.put(Id.valueOf(prodIdStr), Decimal.valueOf(povQtyStr));
                }
            }
        }
        return productPOVQtyMap;
    }*/
    
    public static void caseRetryMethod(List<Case> casesToInsertForClusterUpdate, Integer retrycount, string caseType){
    	String hour = String.valueOf(Datetime.now().hour());
		String min = String.valueOf(Datetime.now().minute() + Integer.valueof(system.label.case_retry_count.right(1)));
        if(Integer.valueof(min) > 60){
        	hour = String.valueOf(Integer.valueof(hour)+1);
            min = string.valueOf(Integer.valueof(min)-60);     
        }
		String ss = String.valueOf(Datetime.now().second());
        String num = caseType +' '+ ss + ' ' + min + ' ' + hour+ ' 1';
		String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
		CaseRetrySchedulerClass cst = new CaseRetrySchedulerClass(casesToInsertForClusterUpdate,1,caseType);
		System.schedule('Case retry Job Started '+num, nextFireTime,cst);                    
    }
    
    //IBA-4736 START
    @testvisible
    private void CreateReviewCaseForZPA(List<Provisioning_Group__c> pgList, MAP<ID,Provisioning_Group__c> oldPGMap, Boolean isUpdate){
        System.debug('ProvisioningGroupTriggerHandler.afterUpdate().CreateReviewCaseForZPA() is invoked ...!!');   
        List<Case> casesToInsertForZPAReview = new List<Case>();
        Set<Id> prgIdsForCaseCreation = new Set<Id>();
        Case cs;
        for(Provisioning_Group__c prg : pgList){
            if(isUpdate){
            	if(prg.Provisioning_Type__c == 'Auto' && prg.Product_Line__c == 'ZPA' && prg.Approval_Status__c == 'Approved' && 
                oldPGMap.get(prg.Id).Approval_Status__c != 'Approved' && prg.PG_Request_Type__c == 'Create' && prg.RecordTypeId == trialPGRecordTypeId && prg.Zscaler_Cloud_ID__c == NULL){
                	cs = prepareCaseRecord(prg, 'Review new ZPA Tenant Request '+ prg.Name);
                	if(cs != null){
                    	casesToInsertForZPAReview.add(cs);
                	}
            	}
            }
            else{
           		if(prg.Status__c !='Requested' && prg.Approval_Status__c=='Approved' && prg.Provisioning_Type__c == 'Auto' && prg.Product_Line__c == 'ZPA' && 
                !isUpdate && prg.PG_Request_Type__c == 'Create' && prg.RecordTypeId == trialPGRecordTypeId && prg.Zscaler_Cloud_ID__c == NULL){
                    cs = prepareCaseRecord(prg, 'Review new ZPA Tenant Request '+ prg.Name);
                    if(cs != null){
                        casesToInsertForZPAReview.add(cs);
                    }       
                }     
            }   
        }
         if(!casesToInsertForZPAReview.isEmpty() && casesToInsertForZPAReview != null){
            try{
            List<Database.SaveResult> caseInsertResultList = Database.insert(casesToInsertForZPAReview);
            }catch(Exception ex){
                if(!ex.getMessage().contains('UNABLE_TO_LOCK_ROW')){
                ProvisioningErrorHandler.exceptionHandler('ProvisioningGroupTriggerHandler','casesToInsertForZPAReview',ex);
            }
                else{
                    caseRetryMethod(casesToInsertForZPAReview,1,'ZPA Review');
                }
            }
            
        }
    }
    
    @testvisible
    private void SubmitZPAForProvisioning(List<Provisioning_Group__c> pgList, MAP<ID,Provisioning_Group__c> oldPGMap, Boolean isUpdate){
        System.debug('ProvisioningGroupTriggerHandler.beforeUpdate().SubmitZIAForProvisioning() is invoked ...!!'); 
        if(isUpdate){
            for(Provisioning_Group__c prg : pgList){
                if(prg.Provisioning_Type__c == 'Auto' && prg.Product_Line__c == 'ZPA' && prg.Send_for_Provisioning__c == TRUE && prg.Zscaler_Cloud_ID__c == NULL &&
                 oldPGMap.get(prg.Id).Send_for_Provisioning__c != TRUE && prg.Approval_Status__c == 'Approved' && prg.PG_Request_Type__c == 'Create' && prg.RecordTypeId == trialPGRecordTypeId){
                    prg.Status__c = 'Requested';    
                }
                else if(prg.Provisioning_Type__c == 'Auto' && prg.Product_Line__c != 'ZIA' && (prg.Product_Line__c != 'ZPA' || (prg.Product_Line__c == 'ZPA' && prg.Zscaler_Cloud_ID__c != NULL))
                && prg.Approval_Status__c == 'Approved' && oldPGMap.get(prg.Id).Approval_Status__c != 'Approved' && prg.Status__c == 'Initiated'){
                	prg.Status__c = 'Requested';    
                }
            }    
        } 
    }
    //IBA-4736 END
}