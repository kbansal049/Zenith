public class ProvEventTriggerHandlerUpdated {
    public static void ProvEventAPICallout(List<Provisioning_Event__e> prvEvnt) {
        System.debug('--ProvEventTriggerHandlerUpdated--ProvEventAPICallout called---');
        
        Set<Id> pgIdSet = new Set<Id>();
        for(Provisioning_Event__e event:prvEvnt){
            if(event.PG_ID__c !=null){
                pgIdSet.add(event.PG_ID__c);                
            }
        }
        System.debug('--ProvEventTriggerHandlerUpdated--pgIdSet---'+pgIdSet);
        
        if(pgIdSet !=null && pgIdSet.size()>0){
            try{
                MAP<ID, Provisioning_Group__c> pgMAP = new MAP<ID,Provisioning_Group__c>(retrivePGRecrods(pgIdSet));
                System.debug('--pgMAP---'+pgMAP);
                
                MAP<ID, List<Provisioning_Contact__c>> pgConMAP =  retriveProvContactRecords(pgIdSet);
                System.debug('--pgConMAP---'+pgConMAP);
                
                MAP<ID, List<Provisioning_Product__c>> pgProductsMAP =  retriveProvProductRecords(pgIdSet);
                System.debug('--pgProductsMAP---'+pgProductsMAP);
                
                MAP<ID, List<Product_License__c>> productLicenseMAP =  retriveProductLicencesRecords(pgProductsMAP);
                System.debug('--productLicenseMAP---'+productLicenseMAP);
                
                for(Provisioning_Group__c pg : pgMAP.values()){
                    List<Provisioning_Contact__c> conList = pgConMAP.containskey(pg.id) ? pgConMAP.get(pg.id) :  new List<Provisioning_Contact__c>();
                    
                    List<Provisioning_Product__c> productList = pgProductsMAP.containskey(pg.id) ? pgProductsMAP.get(pg.id) :  new List<Provisioning_Product__c>();
                    
                    System.debug('pg.RecordType.Name '+pg.RecordType.Name+' '+pg.PG_Request_Type__c);
                    
                    if(pg.RecordType.Name =='Trial' && pg.PG_Request_Type__c =='Create'){
                        System.debug('pg.RecordType.Name2222 '+pg.RecordType.Name+' '+pg.PG_Request_Type__c);
                        String json = ProvisioningGroupAPIUtilityUpdated.PGRequestCreateTrial(pg,pg.Account__r,conList, productList, productLicenseMAP);
                        System.debug('json '+json);
                        ProvisioningGroupAPIUtilityUpdated.callAPIGeneric(pg.Id, json); 
                    }
                    else if(pg.RecordType.Name =='Trial' && pg.PG_Request_Type__c =='Replace'){
                        String json= ProvisioningGroupAPIUtilityUpdated.PGRequestReplaceTrial(pg,pg.Account__r,conList, productList, productLicenseMAP);
                        ProvisioningGroupAPIUtilityUpdated.callAPIGeneric(pg.Id, json); 
                    }
                    else if(pg.RecordType.Name =='Trial' && pg.PG_Request_Type__c =='Update'){
                        String json= ProvisioningGroupAPIUtilityUpdated.PGRequestUpdateTrial(pg,pg.Account__r,conList, productList, productLicenseMAP);
                        ProvisioningGroupAPIUtilityUpdated.callAPIGeneric(pg.Id, json); 
                    }
                    else if(pg.RecordType.Name =='Subscription' && pg.PG_Request_Type__c =='Create'){
                        String json= ProvisioningGroupAPIUtilityUpdated.PGRequestCreateSubscription(pg,pg.Account__r,conList, productList, productLicenseMAP);
                        ProvisioningGroupAPIUtilityUpdated.callAPIGeneric(pg.Id, json); 
                    }
                    else if(pg.RecordType.Name =='Subscription' && pg.PG_Request_Type__c =='Update'){
                        String json= ProvisioningGroupAPIUtilityUpdated.PGRequestUpdateSubscription(pg,pg.Account__r,conList, productList, productLicenseMAP);
                        ProvisioningGroupAPIUtilityUpdated.callAPIGeneric(pg.Id, json); 
                    }
                    else if(pg.RecordType.Name =='Subscription' && pg.PG_Request_Type__c =='Replace'){
                        String json= ProvisioningGroupAPIUtilityUpdated.PGRequestReplaceSubscription(pg,pg.Account__r,conList, productList, productLicenseMAP);
                        ProvisioningGroupAPIUtilityUpdated.callAPIGeneric(pg.Id, json); 
                    }   
                }
            }catch(Exception ex){
                ProvisioningErrorHandler.exceptionHandler('ProvEventTriggerHandlerUpdated','ProvEventAPICallout',ex);
            }
        }
    }
    
    @testvisible
    private static List<Provisioning_Group__c> retrivePGRecrods(Set<ID> pgIdSet){
        return [select id,Name,
                
                RecordType.DeveloperName,
                RecordType.Name,Proxy_Cloud__c,
                
                Product_Line__c,Preferred_Cloud__c,
                Organization_Domain__c,Provisioning_Process__c,
                Additional_Organization_domains__c,
                Start_Date__c,
                End_Date__c,
                Send_Initial_Login_Credentials_To__c,
                Status__c,Approval_Status__c,
                PG_Request_Type__c,ZSCM_End_Date__c,
                
                //Cloud Details
                Zscaler_Cloud_ID__c,
                Zscaler_Cloud_ID__r.Name,
                Zscaler_Cloud_ID__r.Customer_Id__c,
                
                //Associated Cloud Details
                Associated_ZIA_Zscaler_Cloud__c,
                Associated_ZIA_Zscaler_Cloud__r.Name,
                Associated_ZIA_Zscaler_Cloud__r.Customer_Id__c,
                
                ZPA_Preferred_Cloud__c,
                
                //Opportunity
                opportunity__c,
                opportunity__r.Name,
                opportunity__r.Netsuite_Sales_Order_Number__c,
                opportunity__r.Type,opportunity__r.Id,
                
                //Customer
                Account__r.name,Account__r.Parent.name,Account__r.Operational_HQ__c,Account__r.Region_New__c,
                Account__r.BillingCountry,Account__r.ZIA_Customer_Id__c,Account__r.ZPA_Customer_ID__c,Account__r.Area__c ,
                Account__r.Type,Account__r.No_of_Employees_Users__c,Account__r.Industry,Account__r.Geo__c,Account__r.FP_A_Parent_industry__c,
                Account__r.Sales_Territory__r.Provisioning_Geographical_Region__c,
                Account__r.Sales_Territory__r.Provisioning_Region__c,Account__r.District__c, Account__r.NumberOfEmployees,
                 
                CreatedDate,LastModifiedDate,Owner.Name,Owner.email,Owner.Username,
                // cluster details
                Nanolog_Cluster__c,Nanolog_Cluster__r.id,Nanolog_Cluster__r.name,Nanolog_Cluster__r.clusterId__c,
                Sandbox_Cluster__c,Sandbox_Cluster__r.id,Sandbox_Cluster__r.name,Sandbox_Cluster__r.clusterId__c,
                 SMCDSS_DLP_Cluster__c,SMCDSS_DLP_Cluster__r.id,SMCDSS_DLP_Cluster__r.name,SMCDSS_DLP_Cluster__r.clusterId__c,Exception_to_Cluster_assignment__c
                
                from Provisioning_Group__c 
                where id IN: pgIdSet];
    }
    
    @testvisible
    private static MAP<ID, List<Provisioning_Product__c>> retriveProvProductRecords(Set<ID> pgIdSet){
        MAP<ID, List<Provisioning_Product__c>> pgContMAp = new MAP<ID, List<Provisioning_Product__c>>();
        for(Provisioning_Product__c pc : [select id,Name,
                                          Product_Name__c,SKU__c,
                                          Product_Family__c,
                                          Product_Category__c,
                                          Quantity__c,
                                          Start_Date__c,End_Date__c,
                                          
                                          ContinueTrialForFutureDatedSku__c,
                                          Product__c,
                                          Product__r.Provisioning_Product_Family__c,
                                          
                                          //PG Details
                                          Provisioning_Group__c,
                                          Provisioning_Group__r.Name,
                                          
                                          //Cloud Details
                                          Zscaler_Cloud_ID__c,
                                          Zscaler_Cloud_ID__r.Name,
                                          
                                          CreatedDate,LastModifiedDate
                                          from Provisioning_Product__c  where Provisioning_Group__c != null and Provisioning_Group__c IN: pgIdSet])
        {
            List<Provisioning_Product__c> pcList = pgContMAp.containsKey(pc.Provisioning_Group__c) ? pgContMAp.get(pc.Provisioning_Group__c) : new List<Provisioning_Product__c>();
            pcList.add(pc);
            pgContMAp.put(pc.Provisioning_Group__c, pcList);
        }
        return pgContMAp;
    }
    
    @testvisible
    private static MAP<ID, List<Provisioning_Contact__c>> retriveProvContactRecords(Set<ID> pgIdSet){
        MAP<ID, List<Provisioning_Contact__c>> pgContMAp = new MAP<ID, List<Provisioning_Contact__c>>();
        for(Provisioning_Contact__c pc : [Select ID,Name,Provisioning_Group__c,
                                          Type__c,Contact__c,Email__c,User_Name__c,
                                          User__c,User__r.Id,User__r.Email,User__r.phone,User__r.Title
                                          from Provisioning_Contact__c where Provisioning_Group__c != null and Provisioning_Group__c in : pgIdSet])
        {
            List<Provisioning_Contact__c> pcList = pgContMAp.containsKey(pc.Provisioning_Group__c) ? pgContMAp.get(pc.Provisioning_Group__c) : new List<Provisioning_Contact__c>();
            pcList.add(pc);
            pgContMAp.put(pc.Provisioning_Group__c, pcList);
        }
        return pgContMAp;
    }
    
    @testvisible
    private static MAP<ID, List<Product_License__c>> retriveProductLicencesRecords(MAP<ID, List<Provisioning_Product__c>> provProducts){
        System.debug('--retriveProductLicencesRecords--called---');
        System.debug('--provProducts---'+provProducts);
        
        MAP<ID, List<Product_License__c>> productLicenseMap = new MAP<ID, List<Product_License__c>>();
        
        Set<ID> productIDs = new Set<ID>();
        for(ID pgID : provProducts.keyset()){
            for(Provisioning_Product__c pp : provProducts.get(pgID)){
                if(pp.Product__c != null){
                    productIDs.add(pp.Product__c);
                }
            }
        }
        System.debug('--productIDs---'+productIDs);
        
        for(Product_License__c pc : [Select ID,Name,Product__c,Provisioning_License__c,POV_Quantity__c,License_SKU__c,Product_SKU_Code__c,License_Product_Line__c,
                                     License_Based_On__c,License__c,Is_JIRA_Ticket_Required__c,License_Code__c
                                     from Product_License__c where License__c != null and Product__c != null and Product__c in : productIDs])
        {
            List<Product_License__c> pcList = productLicenseMap.containsKey(pc.Product__c) ? productLicenseMap.get(pc.Product__c) : new List<Product_License__c>();
            pcList.add(pc);
            productLicenseMap.put(pc.Product__c, pcList);
        }
        
        return productLicenseMap;
    }
}