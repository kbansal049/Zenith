/**
* @description    This is the Contact Trigger handler class called synchronously from genericContactTrigger.
*                 All the methods needs to be called synchronously from the genericContactTrigger
*                 should be called from here in the before/after insert/update methods.
* 1.0            Satishakumar Awati   14th Dec 2022   Move Contact Trigger to New Trigger Framework
**/
public class ContactTriggerHandler extends TriggerHandler {
    
    List<Contact> newRecords = (List<Contact>) Trigger.New;
    Map<Id, Contact> newRecordsMap = (Map<Id, Contact>) Trigger.newMap;
    List<Contact> oldRecords = (List<Contact>) Trigger.old;
    Map<Id, Contact> oldRecordsMap = (Map<Id, Contact>) Trigger.oldMap;

    /**
    * @description This Method was added to handle all before Insert Operations of genericContactTrigger
    * @author zscaler.com | 12-08-2022 
    **/
    public override void beforeInsert(){
        changeContactOwnershipIfPatchNotRealigning();
            //added by Gurjinder:Start
        ContactTriggerHelper.insertFunnelStageAutomation(newRecords);
    }

    /**
    * @description This Method was added to handle all before Update Operations of genericContactTrigger
    * @author zscaler.com | 12-08-2022 
    **/
    public override void beforeUpdate(){
        changeContactOwnershipIfPatchNotRealigning();
        // added by Shubham
        ContactTriggerHelper.populateSynctoPRM(newRecords, oldRecordsMap);
        //Added by Gurjinder : CR# 1256 : Start
        ContactTriggerHelper.updateTouchesSinceLastOpen(newRecords, oldRecordsMap);
        //Added by Gurjinder : CR# 1256 : End
        ContactTriggerHelper.updateFunnelStageAutomation(newRecords, oldRecordsMap);
    }

    /**
    * @description This Method was added to handle all after Insert Operations of genericContactTrigger
    * @author zscaler.com | 12-08-2022 
    **/
    public override void afterInsert(){
        TriggerHandler.bypass('ContactTriggerHandler');
        ContactTriggerHelper.updateContactWhiteSpace(newRecords, null);
        //added by Gurjinder:Start
        ContactTriggerHelper.ZCloudIDContactInsert(newRecords);
        //added by Gurjinder:End
        ContactTriggerHelper.processInteractiveList(newRecords, null, ZScalarConstants.INSERT_STRING);
    }

    /**
    * @description This Method was added to handle all after Update Operations of genericContactTrigger
    * @author zscaler.com | 12-08-2022 
    **/
    public override void afterUpdate(){
        TriggerHandler.bypass('ContactTriggerHandler');
        updateWhiteSpaceAndCampaignMemberIfPatchNotRealigning();
        ContactTriggerHelper.UpdateTaskFields(newRecords, oldRecordsMap);
        ContactTriggerHelper.processInteractiveList(newRecords, oldRecordsMap, ZScalarConstants.UPDATE_STRING);
    }

    /**
    * @description This Method was added to handle all before delete Operations of genericContactTrigger
    * @author zscaler.com | 12-08-2022 
    **/
    public override void beforeDelete(){
        ContactTriggerHelper.ZCloudIDContactDelete(oldRecords);
    }
    
    /**
    * @description This Method was added to call the submethods to update Contact ownership and 
    *   ZCloudIds associated to the contacts after checking the Patch Realignment
    * @author zscaler.com | 07-02-2022 
    **/
    public void changeContactOwnershipIfPatchNotRealigning() {
        if(!TriggerUtility.isPatchRealigning()){
            Map<Id, Contact> oldContactMap = (Trigger.isUpdate ? oldRecordsMap : null);
            ContactPatchManager.getPatchInformation(newRecords);
            ContactTriggerHelper.changeContactOwnership(newRecords, oldContactMap);
            
            if (Trigger.isUpdate) {
                ContactTriggerHelper.ZCloudIDContactUpdate(newRecords, oldContactMap);
            }
        }
    }

    /**
    * @description This Method was added to call the submethods to update Contact ownership and 
    *   ZCloudIds associated to the contacts after checking the Patch Realignment
    * @author zscaler.com | 07-02-2022 
    **/
    public void updateWhiteSpaceAndCampaignMemberIfPatchNotRealigning() {
        if(!TriggerUtility.isPatchRealigning()){
            Map<id, id> contactIdTerritoryIdMap = ContactTriggerHelper.getMapContactIdAndTerrityId(newRecords, oldRecordsMap);
            if(contactIdTerritoryIdMap != null && !contactIdTerritoryIdMap.isEmpty()){
                CampaignMemberPatchManager.getPatchInformation(contactIdTerritoryIdMap, ZScalarConstants.CONTACT_OBJECT_API_NAME);
            }

            if(!TriggerUtility.isconWhiteSpaceUpdateExecuted()){
                ContactTriggerHelper.updateContactWhiteSpace(newRecords, oldRecordsMap);
            }

            //Added by Swathi: CR 1505 start
            if(!TriggerUtility2.isUpdateCampaignMemberBasedOnContExecuted()){
                ContactTriggerHelper.updateCampaignMemberBasedCont(newRecords, oldRecordsMap);
            }    
            //Added by Swathi: CR 1505 end
        }
    }
}