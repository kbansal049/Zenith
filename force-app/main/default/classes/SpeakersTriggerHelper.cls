/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* SpeakersTriggerHelper
* @description    This is the Speakers Trigger Helper class called synchronously from SpeakersTriggerHandler.
*				  Contains the helper methods that can be called from SpeakersTriggerHandler class.
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
* 2022-05-25      IBA-4849 Digvijay - Creation of the class for adding the helper method to populate
                  Speaker's Account Name from CXO Speaker's Account
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class SpeakersTriggerHelper {

    /**
     * Gives the CXO Speaker Record Type Id
     */
    public static Id cxoSpeakerRecordTypeId {
        get {
            if (cxoSpeakerRecordTypeId == null) {
                cxoSpeakerRecordTypeId = Schema.SObjectType.Speakers__c.getRecordTypeInfosByName().get(ZSL2OConstants.CXO_SPEAKER_RECORD_TYPE_NAME).getRecordTypeId();
            }
            return cxoSpeakerRecordTypeId;
        } set;
    } 

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4613 : to populate Speakers_Account_Name on the 
                                                          Speaker record from the associated 
                                                          CXO Speaker's Account Name.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : populateSpeakersAccountName .
    * @param    NAME : List<Speakers__c> speakersList .
    * @param    NAME : Set<Id> contactIdsSet .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void populateSpeakersAccountName(List<Speakers__c> speakersList, Set<Id> contactIdsSet) {
        try {
            Map<Id, Contact> contactIdToContactMap = new Map<Id, Contact>([ SELECT Id, Account.Name, AccountId FROM Contact 
                                                                        WHERE Id IN :contactIdsSet ]);

            for (Speakers__c speaker : speakersList) {
                if (contactIdToContactMap.containsKey(speaker.CXO_Speaker__c) && 
                    contactIdToContactMap.get(speaker.CXO_Speaker__c).AccountId != null && 
                    speaker.Speakers_Account_Name__c != contactIdToContactMap.get(speaker.CXO_Speaker__c).Account.Name) {
                    
                    speaker.Speakers_Account_Name__c = contactIdToContactMap.get(speaker.CXO_Speaker__c).Account.Name;
                }
            }
        } catch (Exception ex) {
            ZscalerErrorLogsUtility.insertLogs('SpeakersTriggerHelper', 'populateSpeakersAccountName', 'Apex', 
                UserInfo.getUserId(), 'Sales Cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
            throw new SpeakersTriggerHelperException(ex.getMessage());
        }
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-4614 : to add the error if Rating is provided or
                                                          not provided accordingly.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : checkForStatusAndRatingValidation .
    * @param    NAME : List<Speakers__c> newSpeakersList .
    * @return   TYPE : void .
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void checkForStatusAndRatingValidation(List<Speakers__c> newSpeakersList) {
        for (Speakers__c speaker : newSpeakersList) {
            if (speaker.RecordTypeId == cxoSpeakerRecordTypeId) {
                if (speaker.status__c != ZSL2OConstants.STATUS_ATTENDED && (String.isNotBlank(speaker.Tech_Savvy__c) || 
                    String.isNotBlank(speaker.Presence_Communication__c) || String.isNotBlank(speaker.Rated_By__c))) {
                    speaker.addError(ZSL2OConstants.SPEAKERS_SPEAKER_RATING_NOT_ALLOWED_ERROR_MESSAGE);

                } else if (speaker.Status__c == ZSL2OConstants.STATUS_ATTENDED && 
                    ((String.isNotBlank(speaker.Tech_Savvy__c) && (String.isBlank(speaker.Presence_Communication__c) || String.isBlank(speaker.Rated_By__c))) || 
                    (String.isNotBlank(speaker.Presence_Communication__c) && (String.isBlank(speaker.Tech_Savvy__c) || String.isBlank(speaker.Rated_By__c))) || 
                    (String.isNotBlank(speaker.Rated_By__c) && (String.isBlank(speaker.Tech_Savvy__c) || String.isBlank(speaker.Presence_Communication__c))))) {
                    speaker.addError(ZSL2OConstants.SPEAKERS_FILL_MANDATORY_FIELDS_WHEN_RATING_THE_SPEAKER_ERROR_MESSAGE);
                }
            }
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-5188 : to get the associated CXO Speaker (Contact)
                                                          Ids from Speakers.
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : getAssociatedCXOSpeakerIds .
    * @param    NAME : List<Speakers__c> speakersList .
    * @return   TYPE : Set<Id> associated CXO Speaker (Contact) Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<Id> getAssociatedCXOSpeakerIds(List<Speakers__c> speakersList) {
        if (speakersList == null || speakersList.isEmpty()) {
            return new Set<Id>();
        }

        Set<Id> cxoSpeakerContactIdsSet = new Set<Id>();
        for (Speakers__c speaker : speakersList) {
            if (speaker.RecordTypeId == cxoSpeakerRecordTypeId && speaker.CXO_Speaker__c != null) {
                cxoSpeakerContactIdsSet.add(speaker.CXO_Speaker__c);
            }
        }

        return cxoSpeakerContactIdsSet;
    }

    private class SpeakersTriggerHelperException extends Exception {}
}