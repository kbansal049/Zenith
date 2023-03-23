/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-03-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ProvisioningGroupAPIUtilityUpdated {
    public static void callAPIGeneric(String objectId , String RequestBody){
        ProvisioningGroupHttpUtility.callPGBroker( objectId, RequestBody);
    }
   
    public static String PGRequestCreateTrial(Provisioning_Group__c prGrpObj, Account customer, 
                                              List<Provisioning_Contact__c>  prvContacts, 
                                              List<Provisioning_Product__c> ppList, 
                                              MAP<ID, List<Product_License__c>> plMAP)
    {
        ProvisioningWrapperUpdated wrp = new ProvisioningWrapperUpdated(prGrpObj,customer,prvContacts,ppList,plMAP);
        wrp.actionType = prGrpObj.Provisioning_Process__c; //'INTERNAL';
       
        wrp.origin = 'SFDC';
        wrp.requestData.prGroup.groupType = 'TRIAL';
        
        //Set SKu Status Value
        for(ProvisioningWrapperUpdated.Cls_product prd : wrp.requestData.licenses){
            prd.Status = 'Trial';
        }
        
        //Set teh Activity
        wrp.activity = 'CREATE';
        return JSON.serializePretty(wrp, true);
    }
    
    public static String PGRequestUpdateTrial(Provisioning_Group__c prGrpObj, Account customer, 
                                              List<Provisioning_Contact__c>  prvContacts, 
                                              List<Provisioning_Product__c> ppList, 
                                              MAP<ID, List<Product_License__c>> plMAP)
    {
        ProvisioningWrapperUpdated wrp = new ProvisioningWrapperUpdated(prGrpObj,customer,prvContacts,ppList,plMAP);
        wrp.activity = 'UPDATE';//'REPLACE';
        wrp.origin = 'SFDC';
        wrp.actionType = prGrpObj.Provisioning_Process__c; //'INTERNAL';
        
        //Set SKu Status Value
        for(ProvisioningWrapperUpdated.Cls_product prd : wrp.requestData.licenses){
            prd.Status = 'Trial';
        }                              
        return JSON.serializePretty(wrp, true);
    }
    
      public static String PGRequestReplaceTrial(Provisioning_Group__c prGrpObj, Account customer, 
                                              List<Provisioning_Contact__c>  prvContacts, 
                                              List<Provisioning_Product__c> ppList, 
                                              MAP<ID, List<Product_License__c>> plMAP)
    {
        ProvisioningWrapperUpdated wrp = new ProvisioningWrapperUpdated(prGrpObj,customer,prvContacts,ppList,plMAP);
        wrp.activity = 'REPLACE';//'REPLACE';
        wrp.origin = 'SFDC';
        wrp.actionType = prGrpObj.Provisioning_Process__c; //'INTERNAL';
        System.debug('Inside Replace Trial');
        //Set SKu Status Value
        for(ProvisioningWrapperUpdated.Cls_product prd : wrp.requestData.licenses){
            prd.Status = 'Trial';
        }                              
        return JSON.serializePretty(wrp, true);
    }
    
    public static String PGRequestCreateSubscription(Provisioning_Group__c prGrpObj, Account customer, 
                                              List<Provisioning_Contact__c>  prvContacts, 
                                              List<Provisioning_Product__c> ppList, 
                                              MAP<ID, List<Product_License__c>> plMAP)
    {
        ProvisioningWrapperUpdated wrp = new ProvisioningWrapperUpdated(prGrpObj,customer,prvContacts,ppList,plMAP);
        wrp.origin = 'SFDC';
        wrp.actionType = prGrpObj.Provisioning_Process__c; //'INTERNAL';
        
        //Set SKu Status Value
        for(ProvisioningWrapperUpdated.Cls_product prd : wrp.requestData.licenses){
            prd.Status = 'SUBSCRIBED';
        }
        
        //Set teh Activity
        wrp.activity = 'CREATE';
        
        return JSON.serializePretty(wrp, true);
    }
    
    public static String PGRequestUpdateSubscription(Provisioning_Group__c prGrpObj, Account customer, 
                                                      List<Provisioning_Contact__c>  prvContacts, 
                                                      List<Provisioning_Product__c> ppList, 
                                                      MAP<ID, List<Product_License__c>> plMAP)
    {
        ProvisioningWrapperUpdated wrp = new ProvisioningWrapperUpdated(prGrpObj,customer,prvContacts,ppList,plMAP);
        wrp.activity = 'UPDATE';//'REPLACE';
        wrp.origin = 'SFDC';
        wrp.actionType = prGrpObj.Provisioning_Process__c; //'INTERNAL';
        //Set SKu Status Value
        for(ProvisioningWrapperUpdated.Cls_product prd : wrp.requestData.licenses){
            prd.Status = (prd.Status == 'continuetrial')? 'Trial' : 'SUBSCRIBED';
        }
        return JSON.serializePretty(wrp, true);
    }
    
     public static String PGRequestReplaceSubscription(Provisioning_Group__c prGrpObj, Account customer, 
                                                      List<Provisioning_Contact__c>  prvContacts, 
                                                      List<Provisioning_Product__c> ppList, 
                                                      MAP<ID, List<Product_License__c>> plMAP)
    {
        ProvisioningWrapperUpdated wrp = new ProvisioningWrapperUpdated(prGrpObj,customer,prvContacts,ppList,plMAP);
        wrp.activity = 'REPLACE';//'';
        wrp.origin = 'SFDC';
        wrp.actionType = prGrpObj.Provisioning_Process__c; //'INTERNAL';
        //Set SKu Status Value
        for(ProvisioningWrapperUpdated.Cls_product prd : wrp.requestData.licenses){
            prd.Status = (prd.Status == 'continuetrial')? 'Trial' : 'SUBSCRIBED';
        }
        return JSON.serializePretty(wrp, true);
    }
}