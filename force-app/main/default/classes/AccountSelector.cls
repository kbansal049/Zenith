/**
 * @description       : This class contains over loaded selector methods for Account object
 * @author            : Ram Sangati
 * @last modified on  : 01-17-2023
 * @last modified by  : Ram Sangati
**/
public without sharing class AccountSelector {
    
    /**
     * This method is used to retrieve list of Account records with given fields and filter criteria
     * @param  fields        fields
     * @param  whereClause   whereClause
     * @param  orderByClause orderByClause
     * @param  limitClause   limitClause
     * @return               List of Cases / null
     */
    public static List<Account> getAccounts(String fields, String whereClause, String orderByClause, Integer limitClause){
        System.debug('111 ===>> Entered into getAccounts() ...!!');
        List<Account> accountList = new List<Account>();
        String soql = GCSCommonUtility.getSOQL('Account', fields, whereClause, orderByClause, limitClause);
        System.debug('111(A) ===>> Account soql val is: ' + soql);
        if(String.isNotBlank(soql)){
            accountList = Database.query(soql);
        }
        System.debug('111(B) ===>> accountList val is: ' + accountList);
        return accountList;
    }
}