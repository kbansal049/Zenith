/**
 * @description       : This class contains over loaded selector methods for Case object
 * @author            : Ankit Bhatnagar
 * @last modified on  : 01-13-2023
 * @last modified by  : Ankit Bhatnagar
**/
public without sharing class CaseSelector {
    /**
     * This method is used to retrieve list of Case records with given fields and filter criteria
     * @param  fields        fields
     * @param  whereClause   whereClause
     * @param  orderByClause orderByClause
     * @param  limitClause   limitClause
     * @return               List of Cases / null
     */
    public static List<Case> getCases(String fields, String whereClause, String orderByClause, Integer limitClause){
        System.debug('222 ===>> Entered into getCases() ...!!');
        List<Case> caseList = new List<Case>();
        String soql = GCSCommonUtility.getSOQL('Case', fields, whereClause, orderByClause, limitClause);
        System.debug('222(A) ===>> Case soql val is: ' + soql);
        if(String.isNotBlank(soql)){
            caseList = Database.query(soql);
        }
        System.debug('222(B) ===>> caseList val is: ' + caseList);
        return caseList;
    }
}