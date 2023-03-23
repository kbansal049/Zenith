public class ProductDemoInstanceRequestTriggerHandler {
    
    public static Id ZB2BInteractiveRecordTypeId = Schema.SObjectType.Product_Demo_Instance_Request__c.getRecordTypeInfosByName().get('ZB2B Interactive').getRecordTypeId();

    public static Id SafemarchRecordTypeId = Schema.SObjectType.Product_Demo_Instance_Request__c.getRecordTypeInfosByName().get('Safemarch for Partners').getRecordTypeId();
    public static Id ZPAImpartnerRecordTypeId = Schema.SObjectType.Product_Demo_Instance_Request__c.getRecordTypeInfosByName().get('ZPA Interactive for Partners').getRecordTypeId();


    public void MainEntry(System.TriggerOperation triggerEvent, Boolean IsExecuting, List<SObject> newlist, Map<ID, SObject> newMap, List<SObject> oldList, Map<ID,SObject> oldMap){
        List<Product_Demo_Instance_Request__c > lstNew = (List<Product_Demo_Instance_Request__c >)newlist;
        List<Product_Demo_Instance_Request__c > lstOld = (List<Product_Demo_Instance_Request__c >)oldList;
        Map<ID, Product_Demo_Instance_Request__c > mapNew = (Map<ID,Product_Demo_Instance_Request__c >)newMap;
        Map<ID, Product_Demo_Instance_Request__c > mapOld = (Map<ID,Product_Demo_Instance_Request__c >)oldMap;
        
        // Add entries to the dispatcher static variable if they need to be updated or do direct DML
        
        System.debug('ProductDemoInstanceRequestTriggerHandler MainEntry. triggerEvent: ' + triggerEvent);
        
        switch on triggerEvent {
            when BEFORE_INSERT{
                System.debug('Product_Demo_Instance_Request__c  ---- > BEFORE_INSERT');
                updateProvisionRquest(newlist);

                updateEmailforWF(newlist);

            }
            when BEFORE_UPDATE{
                System.debug('Product_Demo_Instance_Request__c  ---- > BEFORE_UPDATE');
                updateProvisionRquest(newlist);
            }
            when AFTER_INSERT {
                System.debug('Product_Demo_Instance_Request__c  ---- > AFTER_INSERT');
                sendProvisioningRequest(newlist);
            }
            when AFTER_UPDATE {
                System.debug('Product_Demo_Instance_Request__c  ---- > AFTER_UPDATE');
                extendProvisioningRequest(newlist,mapOld);
                updateContactwithSafemarch(newlist,mapOld);
            }
            when else {
                System.debug('Not expecting Trigger Event: ' + triggerEvent);
            }
        }
    }
    

    public static void extendProvisioningRequest(List<Product_Demo_Instance_Request__c> newlist,Map<ID, Product_Demo_Instance_Request__c > mapOld){

        if(!System.isFuture() && !System.isBatch()){
            Set<Id> extendPRId = new set<Id>();
            for(Product_Demo_Instance_Request__c pdir : newlist){   
                if(pdir.Request_Extension__c == 'Yes' && pdir.Request_Extension__c != mapOld.get(pdir.Id).Request_Extension__c){
                    if(pdir.Provisioning_Status__c == 'Decommissioned' || pdir.Is_Interactive_Extended__c == true){
                        pdir.addError('Either this request is Decommisioned or already extended once.');
                    }
                    else{
                        extendPRId.add(pdir.Id);
                    }
                  }
            }
            ExtendInteractiveController.ExtendInteractiveCustom(extendPRId);
        }
    }
    
    public static void updateContactwithSafemarch(List<Product_Demo_Instance_Request__c> newlist,Map<ID, Product_Demo_Instance_Request__c > mapOld){
        Set<Id> contactSafemarchPRId = new set<Id>();
        for(Product_Demo_Instance_Request__c pdir : newlist){   
            if(pdir.Record_Type_Name__c=='Safemarch for Partners' && pdir.Provisioning_Status__c=='Provisioned' && pdir.Provisioning_Status__c != mapOld.get(pdir.Id).Provisioning_Status__c){
                contactSafemarchPRId.add(pdir.Primary_Eval_Contact__c);                
            }
        }
        ExtendInteractiveController.updateContactforSafemarch(contactSafemarchPRId);
    }
    
    public static void updateProvisionRquest(List<Product_Demo_Instance_Request__c> newlist) {
        
        List<ID> conID = new List<ID>();
        
        for(Product_Demo_Instance_Request__c pdir : newlist){
            if(pdir.Interactive_Type__c == 'Safemarch for Partners'){
                pdir.RecordTypeId =SafemarchRecordTypeId;
                if(pdir.Primary_Eval_Contact__c != null){
                   conID.add(pdir.Primary_Eval_Contact__c); 
                }
            }
            else if(pdir.Interactive_Type__c == 'ZPA Interactive for Partners')
            {
                pdir.RecordTypeId = ZPAImpartnerRecordTypeId;          
            }
            else if(pdir.Interactive_Type__c == 'ZB2B Interactive for Prospects'){
                pdir.RecordTypeId = ZB2BInteractiveRecordTypeId;              
                
            }
        }
        //auto populate Partner_OKTA_ID__c with Contact-->OKTA_User_ID__c
        if(conID.size()>0){
            MAP<ID,Contact> conMAP = new MAP<ID,Contact>([Select id,OKTA_User_ID__c from Contact where id in : conID]);
            for(Product_Demo_Instance_Request__c pdir : newlist){
                if(pdir.Interactive_Type__c == 'Safemarch for Partners' && conMAP.containskey(pdir.Primary_Eval_Contact__c)){
                    pdir.Partner_OKTA_ID__c = conMAP.get(pdir.Primary_Eval_Contact__c).OKTA_User_ID__c;
                }
            }
        }
    }
    
    public static void updateEmailforWF(List<Product_Demo_Instance_Request__c> newlist) {
        Set<Id> contactId = new set<Id>();
        Set<Id> accountId = new Set<Id>();
        for(Product_Demo_Instance_Request__c pdir : newlist){
            contactId.add(pdir.Primary_Eval_Contact__c);
            accountId.add(pdir.Account__c);
        }
        Map<Id,Contact> newContactMap = new Map<Id,Contact>([select Email,Name from Contact where id in :contactId]);
        Map<Id,Account> newAccountMap = new Map<Id,Account>([select Channel_Manager__r.Email from Account where id in :accountId]);

        for(Product_Demo_Instance_Request__c pr : newlist){
            if(pr.Interactive_User_Email__c == null){
                pr.Interactive_User_Email__c = pr.Primary_Eval_Contact__c != null && newContactMap.containskey(pr.Primary_Eval_Contact__c) ? newContactMap.get(pr.Primary_Eval_Contact__c).Email : '';
            }
            if(pr.Full_Name__c == null){
                pr.Full_Name__c = pr.Primary_Eval_Contact__c != null && newContactMap.containskey(pr.Primary_Eval_Contact__c) ? newContactMap.get(pr.Primary_Eval_Contact__c).Name : '';
            }
            pr.ZScaler_RAM__c = pr.Account__c != null && newAccountMap.containskey(pr.Account__c) ? newAccountMap.get(pr.Account__c).Channel_Manager__r.Email : '';
        }
    }
   
    //Call ZB2B API
    public static void sendProvisioningRequest(List<Product_Demo_Instance_Request__c> newlist) {
        if(!System.isFuture() && !System.isBatch()){
            for(Product_Demo_Instance_Request__c pdir : newlist){
                ExtendInteractiveController.callOutInteractive(pdir.id); 
            }
        }
    }  
}