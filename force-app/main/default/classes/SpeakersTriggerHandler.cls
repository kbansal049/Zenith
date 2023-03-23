/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SpeakersTriggerHandler
* @description    This is the Speakers Trigger handler class called synchronously from SpeakersTrigger.
*				  All the methods needs to be called synchronously from the Speakers Trigger
* 				  should be called from here in the before/after insert/update methods.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-11-23
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            Digvijay Singh
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2022-05-25      IBA-4849 Digvijay - Creation of the class for adding the logic to populate
                  Speaker's Account Name from CXO Speaker's Account on beforeInsert and beforeUpdate
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class SpeakersTriggerHandler extends TriggerHandler {

    List<Speakers__c> newSpeakersList = (List<Speakers__c>) Trigger.New;
    Map<Id, Speakers__c> newSpeakerIdToSpeakerMap = (Map<Id, Speakers__c>) Trigger.newMap;
    List<Speakers__c> oldSpeakersList = (List<Speakers__c>) Trigger.old;
    Map<Id, Speakers__c> oldSpeakerIdToSpeakerMap = (Map<Id, Speakers__c>) Trigger.oldMap;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4849 : to handle Before Insert logic during DML,
                                                          called automatically from the SpeakersTrigger.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : beforeInsert .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void beforeInsert() {
        SpeakersTriggerHelper.checkForStatusAndRatingValidation(newSpeakersList);
        filterSpeakersAndPopulateSpeakersAccountName(newSpeakersList, null);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4849 : to handle Before Update logic during DML,
                                                          called automatically from the SpeakersTrigger.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : beforeUpdate .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void beforeUpdate() {
        SpeakersTriggerHelper.checkForStatusAndRatingValidation(newSpeakersList);
        filterSpeakersAndPopulateSpeakersAccountName(newSpeakersList, oldSpeakerIdToSpeakerMap);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4849 : to handle After Insert logic during DML,
                                                          called automatically from the SpeakersTrigger.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : afterInsert .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void afterInsert() {
        updateRelatedCXOSpeakersSpeakerStatus(newSpeakersList, null);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4849 : to handle After Update logic during DML,
                                                          called automatically from the SpeakersTrigger.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : afterUpdate .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void afterUpdate() {
        updateRelatedCXOSpeakersSpeakerStatus(newSpeakersList, oldSpeakerIdToSpeakerMap);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4613 : to filter the Speaker records and populate 
                                                          Speakers_Account_Name on the Speaker record 
                                                          from the associated CXO Speaker's Account Name.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : filterSpeakersAndPopulateSpeakersAccountName .
    * @param    NAME : List<Speakers__c> newSpeakersList .
    * @param    NAME : Map<Id, Speakers__c> oldSpeakerIdToSpeakerMap .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void filterSpeakersAndPopulateSpeakersAccountName(List<Speakers__c> newSpeakersList, Map<Id, Speakers__c> oldSpeakerIdToSpeakerMap) {
        Boolean isInsert = oldSpeakerIdToSpeakerMap == null;

        Map<Id, Speakers__c> contactIdToSpeakerMap = new Map<Id, Speakers__c>();

        Set<Id> contactIdsSet = new Set<Id>();
        List<Speakers__c> filteredSpeakersList = new List<Speakers__c>();
        
        for (Speakers__c speaker : newSpeakersList) {
            if (speaker.RecordTypeId == SpeakersTriggerHelper.cxoSpeakerRecordTypeId && speaker.CXO_Speaker__c != null && (isInsert || 
                (speaker.Status__c != oldSpeakerIdToSpeakerMap.get(speaker.Id).Status__c && speaker.Status__c == ZSL2OConstants.STATUS_ATTENDED))) {
                
                contactIdsSet.add(speaker.CXO_Speaker__c);
                filteredSpeakersList.add(speaker);
            }
        }

        if (!filteredSpeakersList.isEmpty()) {
            SpeakersTriggerHelper.populateSpeakersAccountName(filteredSpeakersList, contactIdsSet);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4613 : to update the related CXO Speaker's 
                                                          Speaker Status based on the Speaker's Status.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : updateRelatedCXOSpeakersSpeakerStatus .
    * @param    NAME : List<Speakers__c> newSpeakersList .
    * @param    NAME : Map<Id, Speakers__c> oldSpeakerIdToSpeakerMap .
    * @return   TYPE : void .
    * @throws   TYPE : SpeakersTriggerHelperException .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateRelatedCXOSpeakersSpeakerStatus(List<Speakers__c> newSpeakersList, Map<Id, Speakers__c> oldSpeakerIdToSpeakerMap) {
        try {
            Map<Id, Contact> contactIdToContactMapToUpdate = new Map<Id, Contact>();
            Map<Id, Integer> cxoSpeakerIdToExistingCampaignsCountMap = new Map<Id, Integer>();
            List<Speakers__c> filteredSpeakersList = new List<Speakers__c>();
            Boolean isInsert = oldSpeakerIdToSpeakerMap == null;

            for (Speakers__c speaker : newSpeakersList) {
                Speakers__c oldSpeaker = isInsert ? null : oldSpeakerIdToSpeakerMap.get(speaker.Id);
                
                if (speaker.RecordTypeId == SpeakersTriggerHelper.cxoSpeakerRecordTypeId  && speaker.CXO_Speaker__c != null && 
                    (isInsert || (speaker.Status__c != oldSpeaker.Status__c && (speaker.Status__c == ZSL2OConstants.STATUS_ATTENDED || 
                    oldSpeaker.Status__c == ZSL2OConstants.STATUS_ATTENDED)))) {
                    filteredSpeakersList.add(speaker);
                }
            }

            Set<Id> cxoSpeakerContactIdsSet = SpeakersTriggerHelper.getAssociatedCXOSpeakerIds(filteredSpeakersList);

            List<AggregateResult> uniqueCampaignsCountByCxoSpeakerList = [SELECT CXO_Speaker__c, COUNT_DISTINCT(Campaign__c) COUNT_OF_DISTINCT_CAMPAIGNS FROM Speakers__c 
                                                                            WHERE CXO_Speaker__c IN :cxoSpeakerContactIdsSet AND Status__c = :ZSL2OConstants.STATUS_ATTENDED 
                                                                            GROUP BY CXO_Speaker__c];

            for (AggregateResult uniqueCampaignsCountByCxoSpeaker : uniqueCampaignsCountByCxoSpeakerList) {
                cxoSpeakerIdToExistingCampaignsCountMap.put(String.valueOf(uniqueCampaignsCountByCxoSpeaker.get('CXO_Speaker__c')), 
                    Integer.valueOf(uniqueCampaignsCountByCxoSpeaker.get('COUNT_OF_DISTINCT_CAMPAIGNS')));
            }

            for (Speakers__c speaker : filteredSpeakersList) {
                Speakers__c oldSpeaker = isInsert ? null : oldSpeakerIdToSpeakerMap.get(speaker.Id);
                
                if (speaker.Status__c == ZSL2OConstants.STATUS_ATTENDED) {
                    Contact contactToUpdate = new Contact(
                        Id = speaker.CXO_Speaker__c,
                        Speaker_Status__c = speaker.Status__c
                    );
                    contactIdToContactMapToUpdate.put(contactToUpdate.Id, contactToUpdate);

                } else if (!isInsert && oldSpeaker.Status__c == ZSL2OConstants.STATUS_ATTENDED && 
                    !cxoSpeakerIdToExistingCampaignsCountMap.containsKey(speaker.CXO_Speaker__c)) {
                    Contact contactToUpdate = new Contact(
                        Id = speaker.CXO_Speaker__c,
                        Speaker_Status__c = null
                    );
                    contactIdToContactMapToUpdate.put(contactToUpdate.Id, contactToUpdate);
                }
            }
    
            if (!contactIdToContactMapToUpdate.isEmpty()) {
                update contactIdToContactMapToUpdate.values();
            }

        } catch (Exception ex) {
            ZscalerErrorLogsUtility.insertLogs('SpeakersTriggerHelper', 'updateRelatedCXOSpeakersSpeakerStatus', 'Apex', 
                UserInfo.getUserId(), 'Sales Cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
            throw new SpeakersTriggerHandlerException(ex.getMessage());
        }
    }

    private class SpeakersTriggerHandlerException extends Exception {}
}