public class ContractDetailsIntegrationHandler {
    
    public static Set<ID> ContractDetailsIntegrationIDSet = new set<Id>();
    
    public static Set<String> salesOrderNumbers = new set<String>();
    
    
    public Static MAP<String,String> getPREMSupMAP {
        get{
            if(getPREMSupMAP == null){
                getPREMSupMAP = new MAP<String,String>();
                for(Premium_Support_Code_With_Tam_Code__mdt premTamCode : [SELECT Product_code__c,Generic_code__c FROM Premium_Support_Code_With_Tam_Code__mdt]){
                    getPREMSupMAP.put(premTamCode.Product_code__c, premTamCode.Generic_code__c);
                }
            }
            return getPREMSupMAP;
        }
        set;
    }
    
    
    private static List<Contract_Details_Integration_Sync__c> conList {
        get {
            
            if(conList == null){
                
                if(salesOrderNumbers != null && salesOrderNumbers.Size()>0){
                     conList =  [Select Id,Name,Active__c,Amount_USD__c,ARR_Finance__c,CD_Internal_ID__c,Contract_Detail_Status__c,Contract_Detail__c,Contract_No__c,
                                CreatedById,CreatedDate,Currency__c,Discount__c,Do_not_Aggregate__c,Do_Not_touch__c,End_Date__c,
                                IsDeleted,LastModifiedById,LastModifiedDate,List_Price__c,MRR_USD__c,NetSuite_End_Customer_ID__c,
                                NetSuite_End_Customer_Name__c,NetSuite_Parent_ID__c,NetSuite_Parent_Name__c,NetSuite_Partner_Internal_Id__c,
                                NetSuite_Partner_Name__c,ORGID__c,OwnerId,Premium_Support_ACV__c,Quantity__c,Ramp__c,Region__c,
                                Renewal_Status__c,Renewed_To_Internal_ID__c,Renew_Contract__c,Sales_Ops_Comments__c,Sales_Order_Date__c,Sales_Order_Internal_Id__c,
                                Sales_Representative__c,SKU_Churn_Date__c,SKU__c,Split_Breakdown__c,Start_Date__c,Sync_Failure_Reason__c,Sync_Status__c,
                                SystemModstamp,X90_Day_Renewal_Quote__c,Country_Language__c,Opportunity__c,Reason_for_Do_Not_touch__c,Contract_Detail_Name__c,Sales_Order_Number__c
                                from Contract_Details_Integration_Sync__c 
                                where  Sales_Order_Number__c != null and Sales_Order_Number__c  in : salesOrderNumbers];
                    
                }else if(ContractDetailsIntegrationIDSet != null && ContractDetailsIntegrationIDSet.size()>0){
                    conList =  [Select Id,Name,Active__c,Amount_USD__c,ARR_Finance__c,CD_Internal_ID__c,Contract_Detail_Status__c,Contract_Detail__c,Contract_No__c,
                                CreatedById,CreatedDate,Currency__c,Discount__c,Do_not_Aggregate__c,Do_Not_touch__c,End_Date__c,
                                IsDeleted,LastModifiedById,LastModifiedDate,List_Price__c,MRR_USD__c,NetSuite_End_Customer_ID__c,
                                NetSuite_End_Customer_Name__c,NetSuite_Parent_ID__c,NetSuite_Parent_Name__c,NetSuite_Partner_Internal_Id__c,
                                NetSuite_Partner_Name__c,ORGID__c,OwnerId,Premium_Support_ACV__c,Quantity__c,Ramp__c,Region__c,
                                Renewal_Status__c,Renewed_To_Internal_ID__c,Renew_Contract__c,Sales_Ops_Comments__c,Sales_Order_Date__c,Sales_Order_Internal_Id__c,
                                Sales_Representative__c,SKU_Churn_Date__c,SKU__c,Split_Breakdown__c,Start_Date__c,Sync_Failure_Reason__c,Sync_Status__c,
                                SystemModstamp,X90_Day_Renewal_Quote__c,Country_Language__c,Opportunity__c,Reason_for_Do_Not_touch__c,Contract_Detail_Name__c,Sales_Order_Number__c
                                from Contract_Details_Integration_Sync__c 
                                where  Sales_Order_Number__c != null and id  in : ContractDetailsIntegrationIDSet];
                }else{
                    conList =  new List<Contract_Details_Integration_Sync__c>();
                }
                
                
            }
            return conList;   
        }
        private  set; 
    }
    
    //Used for Storing the Failed Record Ids
    public static Set<Id> errorIdList = new Set<Id>();
    
    public static void createContractDetails(){
        
        if(conList.size()>0){
            
            //By pass triggers here !important
            TriggerUtility.SkipAccTriggerExecuted();
            TriggerUtility.skipOpportunityTrigger();
            
            MAP<Id, Contract_Details_Integration_Sync__c> updateConSyncRecorMAP = new  MAP<Id, Contract_Details_Integration_Sync__c> (conList);
            
            System.debug('--updateConSyncRecorMAP--'+updateConSyncRecorMAP);
            
            //Fill order wise Contract Details
            MAP<String, List<Contract_Details_Integration_Sync__c>> orderWiseSyncMAP = new MAP<String, List<Contract_Details_Integration_Sync__c>>();
            for(Contract_Details_Integration_Sync__c cdi : conList){
                List<Contract_Details_Integration_Sync__c> cdiList = orderWiseSyncMAP.containskey(cdi.Sales_Order_Number__c) ? orderWiseSyncMAP.get(cdi.Sales_Order_Number__c)  : new List<Contract_Details_Integration_Sync__c>();
                cdiList.add(cdi);
                orderWiseSyncMAP.put(cdi.Sales_Order_Internal_Id__c,cdiList);
            }
            
            System.debug('--orderWiseSyncMAP--'+orderWiseSyncMAP);
            
            //Fill SKU Codes to retrive teh Product
            Set<String> SKUCodes = new Set<String>();
            
            //Fill Renewed To Internal id Set
            Set<String> renewedToIds = new Set<String>();
            
            //Fill Opportunity id Set
            Set<String> oppIds = new Set<String>();
            
            //Fill SO number
            Set<String> soNums = new Set<String>();
            
            //Fill SO number
            Set<String> salesRepZnum = new Set<String>();
            
            
            for(Contract_Details_Integration_Sync__c cdi : conList){
                if(cdi.SKU__c != null){
                    SKUCodes.add(cdi.SKU__c);
                }
                if(cdi.Renewed_To_Internal_ID__c != null){
                    renewedToIds.add(cdi.Renewed_To_Internal_ID__c);
                }
                if(cdi.Opportunity__c != null){
                    oppIds.add(cdi.Opportunity__c);
                }
                if(cdi.Sales_Order_Number__c != null){
                    soNums.add(cdi.Sales_Order_Number__c);
                }
                if(cdi.Sales_Representative__c != null){
                    String zNum = getSalesRepZNumber(cdi.Sales_Representative__c);
                    if(zNum != null){
                        salesRepZnum.add(zNum);
                    }
                }
            }
            
            SKUCodes.addall(getPREMSupMAP.values());
            
            
            System.debug('---SKUCodes--'+SKUCodes);
            System.debug('---renewedToIds--'+renewedToIds);
            System.debug('---oppIds--'+oppIds);
            System.debug('---soNums--'+soNums);
            System.debug('---salesRepZnum--'+salesRepZnum);
            
            
            //Retrive all the Products based on SKUs
            MAP<String, Product2> productMAP = new MAP<String, Product2>();
            for(product2 prd : [Select id,name,ProductCode,Product_SKU_External_ID__c from product2 where Product_SKU_External_ID__c in :SKUCodes and is_Phantom_SKU_s__c = false]){
                productMAp.put(prd.Product_SKU_External_ID__c, prd);
            }
            System.debug('---productMAP--'+productMAP);
            
            
            //Retrive all the Orders based on NS_Sales_Order_Number__c list
            MAP<String, Order> orderMAP = new MAP<String, Order>();
            for(Order ord : [Select id,Name,AccountId,NS_Sales_Order_Number__c,Premium_Support_Term__c from Order where NS_Sales_Order_Number__c != null and NS_Sales_Order_Number__c in : soNums]){
                orderMAP.put(ord.NS_Sales_Order_Number__c, ord);
            }
            System.debug('--orderMAP--'+orderMAP);
            
            
            
            MAP<Id,ID> oppPartnerMAP = new  MAP<Id, ID>();
            //CR# 4916 commented below 2 lines and added another 2 lines 
            /*for(Partner pt : [Select id,opportunityId,AccountFromId,AccountFrom.name,AccountToId,AccountTo.Name  from Partner where  isPrimary = true and opportunityId in : oppIds]){
                oppPartnerMAP.put(pt.opportunityId, pt.AccountToId);
            }*/
            for(Opportunity_Partner__c oppPartner : [Select id,Opportunity_Type__c,Opportunity__c,Account__c,Partner_Account_Id__c from Opportunity_Partner__c where Is_Primary__c = true and Opportunity__c IN : oppIds]){
                oppPartnerMAP.put(oppPartner.Opportunity__c, oppPartner.Account__c);
            }
            System.debug('--oppPartnerMAP--'+oppPartnerMAP);
            
            
            //Retrive all SalesRep
            MAP<String,ID> salesRapUserIDMAP = new  MAP<String, ID>();
            for(User pt : [Select id,EmployeeNumber  from User where EmployeeNumber != null and EmployeeNumber in : salesRepZnum]){
                salesRapUserIDMAP.put(pt.EmployeeNumber, pt.id);
            }
            System.debug('--salesRapUserIDMAP--'+salesRapUserIDMAP);
            
            
            //Account ID from Opportunity with SO Number as input
            MAP<String,ID> oppSOCustomerMAP = new MAP<String,ID>();
            for(Opportunity opp : [Select id,accountid,Netsuite_Sales_Order_Number__c from opportunity where Netsuite_Sales_Order_Number__c != null and Netsuite_Sales_Order_Number__c in :soNums order by createddate asc]){
                oppSOCustomerMAP.put(opp.Netsuite_Sales_Order_Number__c, opp.accountid);
            }
            System.debug('--oppSOCustomerMAP--'+oppSOCustomerMAP);
            
            //MAp to create/Update the Contract_Detail__c
            MAP<ID, Contract_Detail__c> equivalentContractDetMAP = new MAP<ID,Contract_Detail__c>();
            MAP<String, Id> cdExtVsCdiId = new MAP<String, Id>();
            
            MAP<Id,String> errorMsgMAP = new MAP<Id,String>();
            
            //Step 1 : Create the Contract_Detail__c Record
            for(String orderInternalID : orderWiseSyncMAP.keySet()){
                for(Contract_Details_Integration_Sync__c cdi : orderWiseSyncMAP.get(orderInternalID)){
                    if(!orderMAP.containskey(cdi.Sales_Order_Number__c)){
                        errorMsgMAP.put(cdi.id, 'Order : '+ cdi.Sales_Order_Number__c + ' does not exist in Salesforce.');
                        updateConSyncRecorMAP.get(cdi.id).Sync_Status__c = 'Failed';
                        updateConSyncRecorMAP.get(cdi.id).Sync_Failure_Reason__c = 'Order : '+ cdi.Sales_Order_Number__c + ' does not exist in Salesforce.';
                        continue;
                    }
                    
                    if(!productMAP.containskey(cdi.SKU__c)){
                        errorMsgMAP.put(cdi.id, 'SKU : '+ cdi.SKU__c + ' does not exist in Salesforce.');
                        updateConSyncRecorMAP.get(cdi.id).Sync_Status__c = 'Failed';
                        updateConSyncRecorMAP.get(cdi.id).Sync_Failure_Reason__c = 'SKU : '+ cdi.SKU__c + ' does not exist in Salesforce.';
                        continue;
                    }
                    
                    order ord = orderMAP.get(cdi.Sales_Order_Number__c);
                    
                    
                    product2 prd  = null;
                    product2 zscSupPrd  = null;
                    if(getPREMSupMAP.containskey(cdi.SKU__c)){
                        prd = productMAP.get(getPREMSupMAP.get(cdi.SKU__c));
                        zscSupPrd = productMAP.get(cdi.SKU__c);
                    }else{
                        prd = productMAP.get(cdi.SKU__c);
                    }
                    System.debug('--zscSupPrd--'+zscSupPrd);
                    
                    
                    //Fill Contarct Details
                    Contract_Detail__c cd = prepareContractDetailFromSyncRecord(cdi,ord,prd,zscSupPrd);
                    
                    
                    //Set the Partnet Account
                    if(cd.Opportunity__c != null &&  oppPartnerMAP.containskey(cd.Opportunity__c)){
                        Id partnerId = oppPartnerMAP.get(cd.Opportunity__c);
                        //Added Null check for CR#5103 
                        // 0017000000RYGPtAAP replaced by Label Zscaler_AccountId
                        if(partnerId != null && String.valueOf(partnerId).equalsIgnoreCase(System.Label.Zscaler_AccountId)){
                            //Zscaler is partner
                            cd.Partner_Account_Name__c = oppSOCustomerMAP.containskey(cdi.Sales_Order_Number__c) ? oppSOCustomerMAP.get(cdi.Sales_Order_Number__c) : oppPartnerMAP.get(cd.Opportunity__c);  
                        }else{
                            cd.Partner_Account_Name__c = oppPartnerMAP.get(cd.Opportunity__c);
                        }
                    }
                    
                    //Fill the salesRep lookup
                    if(cdi.Sales_Representative__c != null ){
                        String zNum = getSalesRepZNumber(cdi.Sales_Representative__c);
                        if(zNum != null){
                            ID salesRepID = salesRapUserIDMAP.containskey(zNum) ? salesRapUserIDMAP.get(zNum) : null;
                            if(salesRepID != null){
                                cd.Sales_Rep__c = salesRepID;
                            }         
                        }
                    }
                    
                    cdExtVsCdiId.put(cdi.CD_Internal_ID__c , cdi.id);
                    system.debug('----cd---'+cd);
                    equivalentContractDetMAP.put(cdi.id, cd);
                }
            }
            
            //cdExtVsCdiId
            system.debug('----cdExtVsCdiId---'+cdExtVsCdiId);
            
            Database.UpsertResult[] results =  Database.upsert(equivalentContractDetMAP.values(),Contract_Detail__c.CD_InternalID__c, false);
            system.debug('----results---'+results);
            
            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(index <= equivalentContractDetMAP.values().size()) {
                    Contract_Detail__c cdRecord = equivalentContractDetMAP.values().get(index);
                    if(cdExtVsCdiId.containskey(cdRecord.CD_InternalID__c)){
                        Id cdiId = cdExtVsCdiId.get(cdRecord.CD_InternalID__c);
                        //If Failed
                        Contract_Details_Integration_Sync__c cdi = updateConSyncRecorMAP.get(cdiId);
                        if(!results[index].isSuccess()){
                            String errorMsg = getErrorFromtheResult(results[index].getErrors());
                            errorMsgMAP.put(cdiId,errorMsg);
                            errorIdList.add(cdiId);
                            updateConSyncRecorMAP.get(cdiId).Sync_Status__c = 'Failed';
                            updateConSyncRecorMAP.get(cdiId).Sync_Failure_Reason__c = errorMsg;
                        }
                        //IF Success
                        else{
                            updateConSyncRecorMAP.get(cdiId).Contract_Detail__c = results[index].getId();
                            updateConSyncRecorMAP.get(cdiId).Sync_Status__c = 'Success';
                            updateConSyncRecorMAP.get(cdiId).Sync_Failure_Reason__c = '';
                        }
                    }
                }
            }
            System.debug('--errorMsgMAP--'+errorMsgMAP);
            
            
            //Retrive all Contract_Detail__c with renewedToIds
            MAP<String,Contract_Detail__c> renToContarctMAP = new MAP<String,Contract_Detail__c>();
            for(Contract_Detail__c cd : [Select Id,Name,CD_InternalID__c from Contract_Detail__c where CD_InternalID__c != null and CD_InternalID__c in :renewedToIds]){
                renToContarctMAP.put(cd.CD_InternalID__c, cd);
            }
            System.debug('--renToContarctMAP--'+renToContarctMAP);
            
            
            
            MAP<Id,String> updateErrorMsgMAP = new MAP<Id,String>();
            
            //Step 2 : Update the Contract_Detail__c Record, with RenewedFrom and RenewedTo
            MAP<ID,Contract_Detail__c> renewdContDetails = new  MAP<ID,Contract_Detail__c>();
            MAP<String, Id> renewCDExtVsCdiId = new MAP<String, Id>();
            for(String cdiId : updateConSyncRecorMAP.keySet()){
                Contract_Details_Integration_Sync__c cdi = updateConSyncRecorMAP.get(cdiId);
                Contract_Detail__c cd = equivalentContractDetMAP.get(cdiId);
                if(cd != null && cd.Id != null && renToContarctMAP.containskey(cdi.Renewed_To_Internal_ID__c)){
                    cd.Renewed_To_Contract_Details__c = renToContarctMAP.get(cdi.Renewed_To_Internal_ID__c).Id;
                    renewdContDetails.put(cdi.id, cd);
                    renewCDExtVsCdiId.put(cdi.CD_Internal_ID__c, cdi.id);
                }else if(cd != null && cd.Id != null && !renToContarctMAP.containskey(cdi.Renewed_To_Internal_ID__c)){
                    cd.Renewed_To_Contract_Details__c = null;
                }
            }
            System.debug('--renewdContDetails--'+renewdContDetails);
            
            Database.UpsertResult[] rnwResults =  Database.upsert(renewdContDetails.values(),Contract_Detail__c.CD_InternalID__c, false);
            System.debug('--rnwResults--'+rnwResults);
            
           
            for(Integer index = 0, size = rnwResults.size(); index < size; index++) {
                if(index <= renewdContDetails.values().size()) {
                    Contract_Detail__c cdRecord = renewdContDetails.values().get(index);
                    if(cdExtVsCdiId.containskey(cdRecord.CD_InternalID__c)){
                        Id cdiId = cdExtVsCdiId.get(cdRecord.CD_InternalID__c);
                        //If Failed
                        if(!rnwResults[index].isSuccess()){
                            String errorMsg = getErrorFromtheResult(rnwResults[index].getErrors());
                            updateErrorMsgMAP.put(cdiId,errorMsg);
                            errorIdList.add(cdiId);
                            updateConSyncRecorMAP.get(cdiId).Sync_Status__c = 'Failed';
                            updateConSyncRecorMAP.get(cdiId).Sync_Failure_Reason__c = errorMsg;
                        }else{
                            updateConSyncRecorMAP.get(cdiId).Sync_Status__c = 'Success';
                            updateConSyncRecorMAP.get(cdiId).Sync_Failure_Reason__c = '';
                        }
                    }
                }
            }
            System.debug('--updateErrorMsgMAP--'+updateErrorMsgMAP);
            
            //Step last : Update the Contract_Details_Integration_Sync__c with Success/Failure
            if(updateConSyncRecorMAP.size()>0){
                update updateConSyncRecorMAP.values();
            }
        }
        
    }
    
    
    private static String getErrorFromtheResult(List<Database.Error> Errors){
        return errors[0].getMessage().left(255);
    }
    
    //here we will not mapp any Self Lookup filed like, renewedFrom and renewedTo
    public static Contract_Detail__c prepareContractDetailFromSyncRecord(Contract_Details_Integration_Sync__c cdi, Order ord, product2 prd, Product2 zscSupTAMProduct){
        Contract_Detail__c cd = new Contract_Detail__c();
        cd.name = cdi.Contract_Detail_Name__c;
        cd.Account_Name__c = ord.AccountId;
        cd.Sales_Order__c = ord.id;
        cd.Product_Name__c = prd.id;
        cd.Opportunity__c = cdi.Opportunity__c;
        
        
        cd.CD_InternalID__c = cdi.CD_Internal_ID__c;
        cd.X90_Day_Renewal_Quote__c = cdi.X90_Day_Renewal_Quote__c;
        
        
        
        if(zscSupTAMProduct != null){
            cd.Support_Type_Name__c = zscSupTAMProduct.name;
            cd.Support_Type_Product_Code__c=zscSupTAMProduct.productCode;
            cd.Product_SKU__c = zscSupTAMProduct.productCode;
        }else{
            cd.Product_SKU__c = cdi.SKU__c;
        }
        
        cd.Currency__c = cdi.Currency__c;
        cd.List_Price__c = cdi.List_Price__c != null ? cdi.List_Price__c : 0;
        cd.Discount__c = cdi.Discount__c;
        cd.ARR_Finance__c = cdi.ARR_Finance__c != null ? cdi.ARR_Finance__c : 0;
        cd.Amount_USD__c = cdi.Amount_USD__c != null ? cdi.Amount_USD__c : 0;
        cd.MRR_USD__c = cdi.MRR_USD__c != null ? cdi.MRR_USD__c : 0;
        //cd.Premium_Support_ACV_Number__c = cdi.Premium_Support_ACV__c != null ? cdi.Premium_Support_ACV__c : 0;
        if(cdi.SKU__c == 'ZCES-SUP-PREM' || cdi.SKU__c == 'ZCES-SUP-PREM-PLUS' || cdi.SKU__c == 'ZCES-SUP-PREM-PLUS-16' || 
            cdi.SKU__c == 'ZCES-SUP-PREM-PLUS-24' || cdi.SKU__c == 'ZCES-SUP-TAMT' || cdi.SKU__c == 'ZSEC-SUP-TAM'
        ){
            cd.Premium_Support_ACV_Number__c = ord.Premium_Support_Term__c < 12 ? cd.MRR_USD__c*ord.Premium_Support_Term__c : cd.MRR_USD__c * 12;
        }
        
        cd.Start_Date__c = cdi.Start_Date__c;
        cd.End_Date__c = cdi.End_Date__c;
        cd.Quantity__c = cdi.Quantity__c;
        
        
        cd.Ramp__c = cdi.Ramp__c;
        
        cd.Region__c = cdi.Region__c;
        
        cd.Contract_No__c = cdi.Contract_No__c;
        cd.Contract_Detail_Status__c = cdi.Contract_Detail_Status__c;
        cd.SKU_Churn_Date__c = cdi.SKU_Churn_Date__c;
        
        cd.Renewal_Status__c = cdi.Renewal_Status__c;
        cd.Renew_Contract__c = cdi.Renew_Contract__c;
        cd.ORGID__c = cdi.ORGID__c;
        
        cd.Sales_Order_Date__c = cdi.Sales_Order_Date__c;
        
        //cd.Sales_Rep__c = cdi.Sales_Rep__c;
        cd.Sales_Representative__c =  cdi.Sales_Representative__c != null && cdi.Sales_Representative__c.startsWith('Z') ? getSalesRepName(cdi.Sales_Representative__c)  :  cdi.Sales_Representative__c;
        
        cd.Sales_Ops_Comments__c = cdi.Sales_Ops_Comments__c;
        //cd.Zscaler_Product_Family__c = cdi.Zscaler_Product_Family__c;
        
        if(cdi.CD_Internal_ID__c.isNumeric())
            cd.Internal_ID__c = Decimal.valueOf(cdi.CD_Internal_ID__c);
        
        cd.NetSuite_Parent_ID__c = cdi.NetSuite_Parent_ID__c;
        cd.NetSuite_Parent_Name__c = cdi.NetSuite_Parent_Name__c;
        
        cd.NetSuite_End_Customer_ID__c = cdi.NetSuite_End_Customer_ID__c;
        cd.NetSuite_Account_Name__c = cdi.NetSuite_End_Customer_Name__c;
        
        cd.Do_not_Aggregate__c = cdi.Do_not_Aggregate__c;
        cd.Do_Not_touch__c = cdi.Do_Not_touch__c;
        cd.Reason_for_Do_Not_touch__c = cdi.Reason_for_Do_Not_touch__c;
        cd.Country_Language__c = cdi.Country_Language__c; //IBA-5722
        return cd;
    }
     
    @testvisible
    public static String getSalesRepName(String salesRepName){
        String returnStr = null;
        for(String spl : salesRepName.split('^Z[0-9]{4,5}')){
            if(spl != null && spl.trim().length() > 0){
                returnStr = spl.trim();
            }
        }
        return returnStr;
    }
    
    @testvisible
    private static String getSalesRepZNumber(String salesRepName){
        String returnStr = null;
        Pattern r = Pattern.compile('^Z[0-9]{4,5}'); 
        Matcher rm = r.matcher(salesRepName);
        while (rm.find()) {
            if(rm.group() != null){
                returnStr = rm.group().trim();
            }
        }
        return returnStr;
    }

}