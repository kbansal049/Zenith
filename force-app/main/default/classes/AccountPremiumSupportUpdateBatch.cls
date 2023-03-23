/**
 * @description       : Batch class to update support type on Account
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 31-Mar-2022
 * @last modified by  : Ritesh Kumar
 **/
public class AccountPremiumSupportUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    static final String APEX_CLASS_NAME = 'AccountPremiumSupportUpdateBatch';
    ZscalerBatchFramework zb = new ZscalerBatchFramework('AccountPremiumSupportUpdateBatch');

    Map<Id, String> accountToNewSupportLevel = new Map<Id, String>();
    Map<Id, Decimal> accountToNewSupportOrder = new Map<Id, Decimal>();
    Map<Id, String> accountToSupportOfferingMap = new Map<Id, String>(); //Added by Ankit - IBA-6457
    Map<Id, Boolean> accountDedicatedTAMMap = new Map<Id, Boolean>();
    Set<String> productSKU = new Set<String>(); //AccountPS_BatchProducts
    Set<Id> accountIds = new Set<Id>();

    public AccountPremiumSupportUpdateBatch(Set<Id> accountIds) {
        this.accountIds = accountIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        this.zb.callStart();
        System.debug('000(A) ==>>> accountIds val is: '+accountIds);

        String query = 'SELECT Id, Name, Premium_Support_ACV__c, Premium_Support_Type__c, Support_Type__c, Support_Offering__c FROM Account ';
        if(!accountIds.isEmpty()){
            query += ' WHERE ID = :accountIds ';
        }else{
            query += ' WHERE Premium_Support_ACV__c != 0 AND Override_Premium_Support_Type__c = FALSE ';
        }
        System.debug('000(B) ==>>> query val is: '+query);
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope){
        final String METHOD_NAME = 'execute';
        this.zb.callExecute(scope[0]?.Id, scope.size());

        try{
            Map<String, Decimal> supportTypeOrderMap = new Map<String, Decimal>();
            for (Support_Type_Order__mdt supportTypeOrder : [SELECT Support_Type__c, Order__c FROM Support_Type_Order__mdt]) {
                supportTypeOrderMap.put(supportTypeOrder.Support_Type__c, supportTypeOrder.Order__c);
            }

            Set<Id> accountIdSet = new Set<Id>();
            for (Account accountRecord : scope) {
                accountIdSet.add(accountRecord.Id);
            }
            System.debug('111(A1A) ==>>> accountIdSet val is: '+accountIdSet);

            productSKU.addAll(Label.AccountPS_BatchProducts.split(','));
            System.debug('111(A2A) ==>>> productSKU val is: '+productSKU);
            for (Contract_Detail__c contractDetail : [SELECT Id, Name, Product_SKU__c, Account_Name__c, NS_Product_Name__c, 
                                                        NS_Product_SKU__c, Support_Type_Name__c, Support_Type_Product_Code__c, 
                                                        Support_Type_Order__c, Country_Language__c 
                                                    FROM Contract_Detail__c 
                                                    WHERE Account_Name__c IN :accountIdSet 
                                                        AND Product_SKU__c IN :productSKU 
                                                        AND Active__c = true 
                                                    ORDER BY Support_Type_Order__c DESC]) {
                System.debug('111(B) ==>>> contractDetail val is: '+contractDetail);
                if(contractDetail.NS_Product_SKU__c == GCSCommonConstants.IN_COUNTRY_SUPPORT_SKU){
                    accountToSupportOfferingMap.put(contractDetail.Account_Name__c, contractDetail.Country_Language__c);
                }else if(contractDetail.Support_Type_Order__c != null){
                    if(contractDetail.NS_Product_SKU__c == GCSCommonConstants.DEDICATED_TAM_SUPPORT_SKU){
                        accountDedicatedTAMMap.put(contractDetail.Account_Name__c, true);
                    }else{
                        Decimal supportOrder = accountToNewSupportOrder.containsKey(contractDetail.Account_Name__c) 
                                                ? accountToNewSupportOrder.get(contractDetail.Account_Name__c) 
                                                : 0;
                        if(contractDetail.Support_Type_Order__c > supportOrder){
                            accountToNewSupportOrder.put(contractDetail.Account_Name__c, contractDetail.Support_Type_Order__c);
                            accountToNewSupportLevel.put(contractDetail.Account_Name__c, contractDetail.Support_Type_Name__c);
                        }
                    }
                }
            }
            System.debug('111(C1C) ==>>> accountToSupportOfferingMap val is: '+accountToSupportOfferingMap);
            System.debug('111(C2C) ==>>> accountDedicatedTAMMap val is: '+accountDedicatedTAMMap);
            System.debug('111(C3C) ==>>> accountToNewSupportOrder val is: '+accountToNewSupportOrder);
            System.debug('111(C4C) ==>>> accountToNewSupportLevel val is: '+accountToNewSupportLevel);

            List<Account> accountsToUpdate = new List<Account>();
            for(Account accountRecord : scope){
                System.debug('111(D) ==>>> accountRecord.Id val is: '+accountRecord.Id);   
                if(accountToSupportOfferingMap.containsKey(accountRecord.Id) 
                    && accountToSupportOfferingMap.get(accountRecord.Id) == GCSCommonConstants.UNITED_STATES){
                    accountRecord.Support_Type__c = GCSCommonConstants.PREMIUM_SUPPORT_PLUS_IN_COUNTRY;
                    accountRecord.Support_Offering__c = GCSCommonConstants.PREMIUM_SUPPORT_PLUS + GCSCommonConstants.SEMI_COLON_STRING + GCSCommonConstants.UNITED_STATES;
                    accountsToUpdate.add(accountRecord);
                }else if(accountToNewSupportLevel.containsKey(accountRecord.Id)){
                    accountRecord.Support_Type__c = accountDedicatedTAMMap.containsKey(accountRecord.Id) 
                                                    ? accountRecord.Support_Type__c + GCSCommonConstants.WITH_DEDICATED_TAM 
                                                    : accountRecord.Support_Type__c;

                    //Added by Anup - IBA-4769 - Start
                    Integer thresholdRevenue = Integer.valueOf(Label.Account_Threshold_Revenue_For_Default_Support_Type);
                    if(accountRecord.Support_Type__c != GCSCommonConstants.PREMIUM_SUPPORT_PLUS_IN_COUNTRY 
                        && thresholdRevenue != null 
                        && accountRecord.Premium_Support_ACV__c > thresholdRevenue){
                        accountRecord.Support_Type__c = Label.Account_Default_Support_Type_Threshold_ACV; //Added by Ankit - IBA-6457
                    }
                    //Added by Anup - IBA-4769 - End

                    if(accountRecord.Support_Type__c == GCSCommonConstants.STANDARD 
                        || accountRecord.Support_Type__c == GCSCommonConstants.PREMIUM_SUPPORT
                        || accountRecord.Support_Type__c == GCSCommonConstants.PREMIUM_SUPPORT_PLUS){
                        accountRecord.Support_Offering__c = String.isNotBlank(accountRecord.Support_Offering__c) 
                                                            ? accountRecord.Support_Offering__c + GCSCommonConstants.SEMI_COLON_STRING + accountRecord.Support_Type__c
                                                            : accountRecord.Support_Type__c;
                    }
                    accountsToUpdate.add(accountRecord);
                }
                System.debug('111(E1E) ==>>> accountRecord.Support_Type__c val is: '+accountRecord.Support_Type__c);
                System.debug('111(E2E) ==>>> accountRecord.Support_Offering__c val is: '+accountRecord.Support_Offering__c);
            }
            System.debug('111(F1F) ==>>> accountsToUpdate val is: '+accountsToUpdate);
            List<Database.SaveResult> updateResultList = Database.update(accountsToUpdate, false);
            System.debug('111(F2F) ==>>> updateResultList val is: '+updateResultList);
            GCSCommonUtility.logDBInsertOrUpdateError(updateResultList, APEX_CLASS_NAME, METHOD_NAME, GCSCommonConstants.EMPTY_STRING);
        }
        catch(Exception e) {
            GCSCommonUtility.insertZscalerErrorLog(APEX_CLASS_NAME, METHOD_NAME, 
                GCSCommonConstants.EMPTY_STRING, e.getStackTraceString(), String.valueOf(e), e.getTypeName());
        }
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug('Finish Method');
        this.zb.callFinish(bc);
    }
}