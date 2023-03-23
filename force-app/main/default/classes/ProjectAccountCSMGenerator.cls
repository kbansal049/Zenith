/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ProjectAccountCSMGenerator
* @description    This class is being used in the  Project object trigger to set the value for
*                 CSM User from the related Account CSM
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-05-19
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public with sharing class ProjectAccountCSMGenerator {
    private static ProjectAccountCSMGenerator instance;
    public static ProjectAccountCSMGenerator getInstance() {
        if (instance == NULL) {
            instance = new ProjectAccountCSMGenerator();
        }

        return instance;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Public method which initiates the call from trigger.
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/

    public void handleAccountCSMGeneration() {

        retrieveProjectRelatedDetails();
        updateCSMUserFieldValue();

    }

    private Map<Id, inspire1__Project__c> projectMap;
    private void setProjectMap(Map<Id, inspire1__Project__c> projectMap) {
        this.projectMap = projectMap;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Queries the related Account's CSM Name which will be used for Project:CSM
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/

    private void retrieveProjectRelatedDetails() {
        List<inspire1__Project__c> newProjectList = (List<inspire1__Project__c>) Trigger.new;

        Map<Id, inspire1__Project__c> projectMap
            = new Map<Id, inspire1__Project__c> ([
                SELECT 
                    Id, 
                    inspire1__Account__r.CSM_Name_New__c
                FROM
                    inspire1__Project__c
                WHERE 
                    Id IN :newProjectList
                LIMIT 10000
            ]);

        setProjectMap(projectMap);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────┐
    * Updates the CSM User value of the Project
    * ────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @param    NAME    DESCRIPTION (MENTION PARAMETER TYPE IN DESCRIPTION)
    * @return   TYPE    DESCRIPTION (MENTION LIKELY VALUES IN DESCRIPTION)
    * ───────────────────────────────────────────────────────────────────────────────────────────────┘
    **/

    private void updateCSMUserFieldValue() {
        for (inspire1__Project__c project : (List<inspire1__Project__c>) Trigger.new) {
            inspire1__Project__c projectFromMap = NULL;

            if ((projectMap != NULL) 
                && (!projectMap.isEmpty()) 
                && (projectMap.containsKey(project.Id))) {

                projectFromMap = projectMap.get(project.Id);
            }

            if ((projectFromMap != NULL) 
                && (projectFromMap.inspire1__Account__c != NULL) 
                && (projectFromMap.inspire1__Account__r.CSM_Name_New__c != NULL)) {
                
                project.CSM_User__c = projectFromMap.inspire1__Account__r.CSM_Name_New__c;
            }

        }
    }

}