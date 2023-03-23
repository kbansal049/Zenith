/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   09-15-2021   Bharath R.    Initial Version
 * 2.0   11-18-2021   Mayank B.     Incremental Fix CR# 3665
 * 3.0   10-11-2022   Mahesh T      IBA-3700 Fix
 * 4.0   11-01-2022   Ritesh Kumar     IBA-4095 - Custom Setting changes 
*/

public class ContractDetailTriggerHelper{
    public static void beforeInsert(List<Contract_Detail__c> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        Set<String> setZIASKUCodes = new Set<String>();

        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>(); //CR# 3665 changes
        Set<Id> productNameIDSet = new Set<Id>(); //CR# 3665 changes
        
        //IBA-4095 - Start
        //setZIASKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZIA_Contract_Date').SKU_Codes__c.split(';'));
        //setZIASKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZIA_Contract_Date1').SKU_Codes__c.split(';'));
        for(Contract_Date_SKUs__c cdRecord : Contract_Date_SKUs__c.getAll().Values()){
            if(String.isNotBlank(cdRecord.family__c) && cdRecord.family__c.equalsIgnoreCase('ZIA')){
                setZIASKUCodes.addAll(cdRecord.SKU_Codes__c.split(';'));
            }
        }
        //IBA-4095 - End

        for(Contract_Detail__c contractDetail : newList){
            if(setZIASKUCodes.contains(contractDetail.Product_SKU__c))
                contractDetail.ZIA_Contract_Date_Eligible__c = TRUE;
            contractDetail.Active_Platform__c = contractDetail.Active__c;
            //CR# 3665 changes
            if(contractDetail.Product_Name__c != null){
                system.debug('Mayank, call to before insert: '+ contractDetail.id);
                contractDetailList.add(contractDetail);
                productNameIDSet.add(contractDetail.Product_Name__c);
            }
                
        }
        if(!TriggerUtility.isskipCopyProductDetailsExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Contract_Detail_Product_Sync') && tsmap.get('Execute_Contract_Detail_Product_Sync') != null && tsmap.get('Execute_Contract_Detail_Product_Sync').Execute__c){
            ContractDetailTriggerHelper.executeCDProductSync(newList);
        }
        //CR# 3665 changes
        if(!contractDetailList.isEmpty() && !productNameIDSet.isEmpty()){
            updateProductDetailOnContract(contractDetailList, productNameIDSet);
            //IBA-904
            populateProductSequenceOnContractDetails(contractDetailList);
        }
    }

    public static void afterInsert(List<Contract_Detail__c> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        //ContractDetailTriggerHelper.UpdateIncumbentPartneronAccount(newList);
      //  ContractDetailTriggerHelper.updateFirstZPAContractDateonAccount(newList); //CR# 3665 commenting
        
        // Added by Rajesh CR# 1251 : Start
       // ContractDetailTriggerHelper.updateFirstZDXContractDateonAccount(newList); //CR# 3665 commenting
        // Added by Rajesh CR# 1251 : End
        
        if(!TriggerUtility.isContractDetailAccountDeploymentExecuted() && tsmap != null && 
           !tsmap.isEmpty() && tsmap.containsKey('Execute_Contract_Detail_Account_Update') && 
           tsmap.get('Execute_Contract_Detail_Account_Update') != null && 
           tsmap.get('Execute_Contract_Detail_Account_Update').Execute__c)
        {
            ContractDetailTriggerHelper.updateAccountDeployment(newList);
        }

        if(!TriggerUtility.isupdateCountractDetails() && tsmap != null && 
           !tsmap.isEmpty() && tsmap.containsKey('Count_Quantity_On_Contract_Trigger') && 
           tsmap.get('Count_Quantity_On_Contract_Trigger') != null && 
           tsmap.get('Count_Quantity_On_Contract_Trigger').Execute__c)
        {
            ContractDetailTriggerHelper.updateQuantitySumOnScoreCard(newList);
        }
        
        if(!newList.isEmpty()){
            ContractDetailTriggerHelper.updateAccountExtension(newList);
        }
    }

    

    public static void beforeUpdate(List<Contract_Detail__c> newList, Map<Id, Contract_Detail__c> newMap, Map<Id,Contract_Detail__c> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        Set<String> setZIASKUCodes = new Set<String>();
        
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>(); //CR# 3665 changes
        Set<Id> productNameIDSet = new Set<Id>(); //CR# 3665 changes

        //IBA-4095 - Start
        //setZIASKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZIA_Contract_Date').SKU_Codes__c.split(';'));
        //setZIASKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZIA_Contract_Date1').SKU_Codes__c.split(';'));        
        for(Contract_Date_SKUs__c cdRecord : Contract_Date_SKUs__c.getAll().Values()){
            if(String.isNotBlank(cdRecord.family__c) && cdRecord.family__c.equalsIgnoreCase('ZIA')){
                setZIASKUCodes.addAll(cdRecord.SKU_Codes__c.split(';'));
            }
        }
        //IBA-4095 - End

        for(Contract_Detail__c contractDetail : newList){
            if(setZIASKUCodes.contains(contractDetail.Product_SKU__c))
                contractDetail.ZIA_Contract_Date_Eligible__c = TRUE;
            contractDetail.Active_Platform__c = contractDetail.Active__c;
            
            //CR# 3665 changes
            if(contractDetail.Product_Name__c != null && newMap.get(contractDetail.Id).Product_Name__c != oldmap.get(contractDetail.Id).Product_Name__c){
                system.debug('Mayank, call to before udpate: '+ contractDetail.id);
                contractDetailList.add(contractDetail);
                productNameIDSet.add(contractDetail.Product_Name__c);
            }
            
        }
        if(!TriggerUtility.isskipCopyProductDetailsExecuted() && tsmap != null && !tsmap.isEmpty() && tsmap.containsKey('Execute_Contract_Detail_Product_Sync') && tsmap.get('Execute_Contract_Detail_Product_Sync') != null && tsmap.get('Execute_Contract_Detail_Product_Sync').Execute__c){
            ContractDetailTriggerHelper.executeCDProductSynconUpdate(newList, oldmap);
        }

        //CR# 3665 changes
        if(!contractDetailList.isEmpty() && !productNameIDSet.isEmpty()){
            updateProductDetailOnContract(contractDetailList, productNameIDSet);
        }
    }

    public static void afterUpdate(List<Contract_Detail__c> newList, Map<Id, Contract_Detail__c> newMap, Map<Id,Contract_Detail__c> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
       // ContractDetailTriggerHelper.updateFirstZPAContractDateonAccount(newList); //CR# 3665 commenting 
        
        // Added by Rajesh CR# 1251 : Start
      //  ContractDetailTriggerHelper.updateFirstZDXContractDateonAccount(newList); //CR# 3665 commenting 
        // Added by Rajesh CR# 1251 : End
        
        if(!TriggerUtility.isContractDetailAccountDeploymentExecuted() && tsmap != null && 
           !tsmap.isEmpty() && tsmap.containsKey('Execute_Contract_Detail_Account_Update') && 
           tsmap.get('Execute_Contract_Detail_Account_Update') != null && 
           tsmap.get('Execute_Contract_Detail_Account_Update').Execute__c){
            ContractDetailTriggerHelper.updateAccountDeployment(newList);
        }

        if(!TriggerUtility.isupdateCountractDetails() && tsmap != null && 
           !tsmap.isEmpty() && tsmap.containsKey('Count_Quantity_On_Contract_Trigger') && 
           tsmap.get('Count_Quantity_On_Contract_Trigger') != null && 
           tsmap.get('Count_Quantity_On_Contract_Trigger').Execute__c){
            ContractDetailTriggerHelper.updateQuantitySumOnScoreCard(newList);
        }
        if(!newList.isEmpty()){
            ContractDetailTriggerHelper.updateAccountExtension(newList);
        }
            
        
    }

    public static void beforedelete(List<Contract_Detail__c> oldlst, Map<Id, Contract_Detail__c> oldMap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
      //  ContractDetailTriggerHelper.updateFirstZPAContractDateonAccount(oldlst); //CR# 3665 commenting 
        
        // Added by Rajesh CR# 1251 : Start
       // ContractDetailTriggerHelper.updateFirstZDXContractDateonAccount(oldlst); //CR# 3665 commenting 
        // Added by Rajesh CR# 1251 : End
    }



    public static void afterDelete(List<Contract_Detail__c> oldlst, Map<Id, Contract_Detail__c> oldMap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        
        if(!TriggerUtility.isupdateCountractDetails() && tsmap != null && 
           !tsmap.isEmpty() && tsmap.containsKey('Count_Quantity_On_Contract_Trigger') && 
           tsmap.get('Count_Quantity_On_Contract_Trigger') != null && 
           tsmap.get('Count_Quantity_On_Contract_Trigger').Execute__c){
               ContractDetailTriggerHelper.updateQuantitySumOnScoreCard(oldlst);
           }
        
    }
    
    //Commented as a part of CR# 150 :Gurjinder :Start
    /* public static void UpdateIncumbentPartneronAccount(List<Contract_Detail__c> CntrctDetList){
        Set<String> IncumbentPartnerCntrctDetStatus= new Set<String>();
        String CntrctDetStatusString= ZscalerCustomSetting__c.getInstance('CntrctDetStatusString')!=null && ZscalerCustomSetting__c.getInstance('CntrctDetStatusString').Value__c!=null ? ZscalerCustomSetting__c.getInstance('CntrctDetStatusString').Value__c:'Pending Renewal,Active';
        IncumbentPartnerCntrctDetStatus.addall(CntrctDetStatusString.split(','));
        
        Set<id> AccidSet= new Set<id>();
        Map<id,id> CntrctDetAccidmap= new Map<id,id>();
        Map<id,Account> Accmap= new Map<id,Account>();
        List<Account> ListtoUpdateAccount= new List<Account>();
        for(Contract_Detail__c cd:CntrctDetList){
            if(cd.Partner_Account_Name__c!=null && cd.Contract_Detail_Status__c!=null && cd.Contract_Detail_Status__c!='' &&IncumbentPartnerCntrctDetStatus.contains(cd.Contract_Detail_Status__c)){
                AccidSet.add(cd.Partner_Account_Name__c);
                CntrctDetAccidmap.put(cd.id,cd.Account_Name__c);
            }
        }
        
        if(!AccidSet.isempty() && AccidSet.size()>0){
            Accmap = new Map<id,Account>([Select id,Name from Account where id IN:AccidSet]);           
        }
        if(Accmap!=null){
            for(Contract_Detail__c cd:CntrctDetList){
                if(cd.Partner_Account_Name__c!=null && Accmap.containskey(cd.Partner_Account_Name__c)){
                    Account acc= new Account(id=CntrctDetAccidmap.get(cd.id),Incumbent_Partner_Name__c=Accmap.get(cd.Partner_Account_Name__c).Name);
                    ListtoUpdateAccount.add(acc);
                }
            }
            
        }
        if(!ListtoUpdateAccount.isempty() && ListtoUpdateAccount.size()>0){ database.update(ListtoUpdateAccount,false);
        }
        
    } */
    //Commented as a part of CR# 150 :Gurjinder :Start
    //due to CR#402 added by minkesh patel 22-05-2020 start
    /*
    public static void updateFirstZPAContractDateonAccount(List<Contract_Detail__c> contrDetail){
        Set<Id> accIdSet = new Set<Id>();  
        Map<Id,Date> accMinDateMap = new  Map<Id,Date>();
        System.debug('cd.contrDetail+++++'+contrDetail);
        If(contrDetail != Null){
            for(Contract_Detail__c cd : contrDetail){
                System.debug('cd.Account_Name__c+++++'+cd.Account_Name__c);
                accIdSet.add(cd.Account_Name__c);
            }
            
            Set<String> setSKUCodes = new Set<String>();
            setSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZPA_Contract_Date').SKU_Codes__c.split(';'));
            for(Contract_Detail__c cd : [SELECT Id,
                                                Start_Date__c,
                                                Product_SKU__c,
                                                Account_Name__c
                                            FROM Contract_Detail__c
                                            WHERE Account_Name__c IN :accIdSet
                                            AND Start_Date__c != Null
                                            AND Product_SKU__c in :setSKUCodes]){
                if(accMinDateMap.containsKey(cd.Account_Name__c)){
                    Date minDate =  accMinDateMap.get(cd.Account_Name__c);
                    if(minDate > cd.Start_Date__c){ 
                        accMinDateMap.put(cd.Account_Name__c,cd.Start_Date__c);
                    }
                }else{
                    accMinDateMap.put(cd.Account_Name__c,cd.Start_Date__c);
                }
                
            }
            List<Account> accToUpdateList = new List<Account>();
            for(Id accId : accIdSet){
                if(!accMinDateMap.keySet().contains(accId)){
                    Account accObj = new Account(Id = accId ,First_ZPA_Contract_Date__c = null);
                    accToUpdateList.add(accObj);
                }                    
            }
            for(Id accId : accMinDateMap.keySet()){
                Account accObj = new Account(Id = accId ,First_ZPA_Contract_Date__c = accMinDateMap.get(accId));
                accToUpdateList.add(accObj);
            }
            if(!accToUpdateList.isEmpty()){
                update accToUpdateList;
            }
        }
    }
    */
    //due to CR#402 added by minkesh patel 22-05-2020 end

    //IBA-903
    public static void populateProductSequenceOnContractDetails(List<Contract_Detail__c> contractDetailList) {
        Map<Id, Decimal> orderToProdSeqMap = new Map<Id, Decimal>();

        for(Contract_Detail__c cd: contractDetailList) {
            if(cd.Sales_Order__c != null) {
                orderToProdSeqMap.put(cd.Sales_Order__c, 1);
            }
        }

        for (AggregateResult ar : [Select Sales_Order__c, max(Products_Sequence__c) 
                                    from Contract_Detail__c where Sales_Order__c in :orderToProdSeqMap.keySet()
                                    group by Sales_Order__c]) {
            if(ar.get('expr0') != null) {
                Decimal tempSeq = (Decimal)ar.get('expr0') + 1;
                orderToProdSeqMap.put((Id)ar.get('Sales_Order__c'), tempSeq);
            }                         
        }

        for(Contract_Detail__c cd: contractDetailList) {
            if(orderToProdSeqMap.get(cd.Sales_Order__c) != null) {
                cd.Products_Sequence__c = orderToProdSeqMap.get(cd.Sales_Order__c);
                orderToProdSeqMap.put(cd.Sales_Order__c, cd.Products_Sequence__c + 1);
            }
        }
    }

    //CR#714: Abhishek: Account Entitlements to accomodate Editions: start
    public static void executeCDProductSynconUpdate(List<Contract_Detail__c> contrDetail, Map<Id, Contract_Detail__c> oldmap){
        List<Contract_Detail__c> conlst = new List<Contract_Detail__c>();
        for(Contract_Detail__c cd: contrDetail){
            if(oldmap != null && cd.Product_Name__c != oldmap.get(cd.Id).Product_Name__c){
                conlst.add(cd);
            }
        }
        
        if(!conlst.isEmpty()){
            executeCDProductSync(conlst);
        }
    }



    //CR 977 start
    public static void updateQuantitySumOnScoreCard(list<Contract_Detail__c> consList){
        
        Map<String,Contract_Detail_Sku__c> gbSkuTypeMap = Contract_Detail_Sku__c.getAll();
        Map<String,Contract_Sku_Bundle_Type__c> bundleSkuType = Contract_Sku_Bundle_Type__c.getAll();
        Map<String,Contract_4GB_Sku_Type__c> sku4GBType = Contract_4GB_Sku_Type__c.getAll();//Contract_4GB_Sku_Type__c.getAll();
        List<String> BUNDLE_SKU =new List<String>();
        List<String> GB_SKU =new List<String>();
        List<String> GB_4SKU =new List<String>();
        Set<Id> actIds =new Set<Id>();
        for(Contract_Detail__c contract : consList){
            actids.add(contract.Account_Name__c);
        }
        for(Contract_Detail_Sku__c contdet : gbSkuTypeMap.values()){
            GB_SKU.add(contdet.value__c);
        }
        
        for(Contract_Sku_Bundle_Type__c contdet : bundleSkuType.values()){
            BUNDLE_SKU.add(contdet.value__c);
        }
        for(Contract_4GB_Sku_Type__c contdet : sku4GBType.values()){
            GB_4SKU.add(contdet.value__c);
        }
        GB_SKU.addAll(BUNDLE_SKU);
        
        GB_SKU.addAll(GB_4SKU);
        //list<account> accountList = [select id,(select id,Contract_Detail_Status__c,APTS_SKU__c,Quantity__c from Contract_Details__r where Contract_Detail_Status__c = 'Active' and APTS_SKU__c in: GB_SKU) from account where id in : actIds];
        Map<id,double> accountSum = new map<id,double>();
        
        
        for(Account acnt : [select id,(select id,Contract_Detail_Status__c,APTS_SKU__c,Quantity__c from Contract_Details__r where Active__c=true and APTS_SKU__c in: GB_SKU) from account where id in : actIds]) {   
            double sum =0;
            List<Contract_Detail__c> contractList = acnt.Contract_Details__r;
            for(Contract_Detail__c contract : contractList){
                if(bundleSkuType.containsKey(contract.APTS_SKU__c)){
                    sum = sum + (contract.Quantity__c/10 + contract.Quantity__c/20);    
                }
                if (gbSkuTypeMap.containsKey(contract.APTS_SKU__c)){
                    sum =sum + contract.Quantity__c;    
                }
                if (sku4GBType.containsKey(contract.APTS_SKU__c)){
                    sum =sum + contract.Quantity__c*4;
                }
            }
            accountSum.put(acnt.id,sum);
        }
        List<Account_Extension__c> accountExtUpdateList = [select id,account__c,Unauth_Traffic_Entitlement_GB_month__c from Account_Extension__c where account__c in : accountSum.keyset()];
        for(Account_Extension__c singleAccountExtn : accountExtUpdateList){
            singleAccountExtn.Unauth_Traffic_Entitlement_GB_month__c = accountSum.get(singleAccountExtn.Account__c);
        }
        TriggerUtility.stopUpdateCountractDetailsseetTrue();
        update accountExtUpdateList;
    }
    // CR 977 end

    public static void executeCDProductSync(List<Contract_Detail__c> contrDetail){
        Set<Id> prdIdSet = new Set<Id>();
        for(Contract_Detail__c cd: contrDetail){
            if(cd.Product_Name__c != null){
                prdIdSet.add(cd.Product_Name__c);
            }
        }
        Map<Id, Product2> prdMap;
        if(!prdIdSet.isEmpty()){
            prdMap = new Map<Id, Product2>([Select Id, ProductCode, isBundle__c from Product2 where id in :prdIdSet]);
        }
        if(prdMap != null && !prdMap.isEmpty()){
            for(Contract_Detail__c cd: contrDetail){
                if(cd.Product_Name__c != null){
                    cd.Is_Bundle_SKU__c = prdMap.containsKey(cd.Product_Name__c) ? prdMap.get(cd.Product_Name__c).isBundle__c : false;
                }else{
                    cd.Is_Bundle_SKU__c = false;
                }
            }
            TriggerUtility.skipCopyProductDetailsExecuted();
        }
    }
    //CR#714: Abhishek: Account Entitlements to accomodate Editions: start
    
    
    //CR#714: Abhishek: Update Account ZPA Suites and ZIA Suites 
    public static void updateAccountDeployment(List<Contract_Detail__c> contrDetailList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        
        MAP<String,String> skuAndPickListMappingZIA = new MAP<String,String>();
        MAP<String,String> skuAndPickListMappingZPA = new MAP<String,String>();
        
        //Added by Varun - CR 1068 - Start
        Map<Id, Account> accountToUpdate = new Map<Id, Account>();
        Set<Id> accountWithElaTam = new Set<Id>();
        //Added by Varun - CR 1068 - End
        
        Set<Id> accIDSet = new Set<Id>();
        for(Contract_Detail__c cd : contrDetailList ){
            if(cd.Account_Name__c != null){
                accIDSet.add(cd.Account_Name__c);
            }
        }
        
        //Added by Varun - CR 1068 - Start
        //IBA-3554 : Commenting Code in order to have a single source of populating the Support Type on the account
        /*List<Contract_Detail__c> conDetails = [Select id,Account_Name__c from Contract_Detail__c where Account_Name__c=:accIDSet and Product_SKU__c in ('ZIA-ELA-BUNDLE','ZCES-SUP-TAMT')];
        for(Contract_Detail__c contr:conDetails){
            accountWithElaTam.add(contr.Account_Name__c);
        }        
        
        if(accIDSet.size() > 0){
                Map<Id, Account> acc = new Map<Id, Account>([Select Id, Support_Type_Exception__c,Support_Type__c,Premium_Support_ACV__c from Account where id in:accIDSet]);

                for(Id accId : accIDSet){
                    if(!acc.get(accId).Support_Type_Exception__c && accountWithElaTam.contains(accId)){                 
                        //IBA-3700 changed the old value to Premium Support Plus
                        accountToUpdate.put(accId,new Account(Id=accId,Support_Type__c='Premium Support Plus'));
                    }
                    else if(!acc.get(accId).Support_Type_Exception__c && !accountWithElaTam.contains(accId) && acc.get(accId).Premium_Support_ACV__c<25000 ){
                        accountToUpdate.put(accId,new Account(Id=accId,Support_Type__c='Premium Support'));
                    }
                    else if(!acc.get(accId).Support_Type_Exception__c && !accountWithElaTam.contains(accId) && acc.get(accId).Premium_Support_ACV__c==0 ){
                        accountToUpdate.put(accId,new Account(Id=accId,Support_Type__c=''));
                    }
                }           
            }           
            
            if(accountToUpdate.size()>0){
                update accountToUpdate.values();  
            }*/
            //Added by Varun - CR 1068 - End
        
        //Get Existing ZIA Suite + ZPA Suite values from Account
        MAP<ID,Account> accMAP = new MAP<ID,Account>([Select Id,Platform_deployed__c, ZPA_Deployed__c from account where id  in :accIDSet]);
        
        
        //Get the Mapping from Custom MetaData
        for(Contract_Detail_and_Account_Deployment__mdt cda : [Select id,label,Type__c,SKU__c,Deployment_PicklList_Value__c 
                                                               from Contract_Detail_and_Account_Deployment__mdt
                                                               where SKU__c != null])
        {
            if(cda.Type__c == 'ZIA'){
                skuAndPickListMappingZIA.put(cda.SKU__c, cda.Deployment_PicklList_Value__c);
            }else if(cda.Type__c == 'ZPA'){
                skuAndPickListMappingZPA.put(cda.SKU__c, cda.Deployment_PicklList_Value__c);
            }  
        }
        
        MAP<Id,Account> accUpdateMAP = new MAP<Id,Account>();
        //Check for the Mapping Updation
        for(Contract_Detail__c cd : contrDetailList){
            if(cd.Account_Name__c != null){
                Account acc;
                if(accUpdateMAP.containsKey(cd.Account_Name__c)){
                    acc = accMAP.get(cd.Account_Name__c);
                }else{
                    acc = new Account(Id = cd.Account_Name__c);
                }
                //ZIA
                if(skuAndPickListMappingZIA.containskey(cd.APTS_SKU__c) &&  cd.Contract_Detail_Status__c == 'Active'){
                    String ziaDeployment = skuAndPickListMappingZIA.get(cd.APTS_SKU__c);
                    if(ziaDeployment != null && acc.Platform_deployed__c != ziaDeployment){
                        acc.Platform_deployed__c = ziaDeployment;
                        accUpdateMAP.put(acc.id,acc);
                    }
                }
                
                //ZPA
                else if(skuAndPickListMappingZPA.containskey(cd.APTS_SKU__c) && cd.Active__c == true){
                    String zpaDeployment = skuAndPickListMappingZPA.get(cd.APTS_SKU__c);
                    if(zpaDeployment != null && acc.ZPA_Deployed__c != zpaDeployment){
                        acc.ZPA_Deployed__c = zpaDeployment;
                        accUpdateMAP.put(acc.id,acc);
                    }
                }
            }
        }
        if(accUpdateMAP!= null && accUpdateMAP.size()>0){
            TriggerUtility.contractDetailAccountDeploymentExecuted();
            update accUpdateMAP.values();    
        }
    }
    
    // Added by Rajesh CR# 1251 : Start
    /*
    public static void updateFirstZDXContractDateonAccount(List<Contract_Detail__c> contrDetail){
        
        System.debug('-=- contrDetail -=- '+contrDetail);
        
        if(contrDetail != null){
            Set<Id> accIdSet = new Set<Id>();  
            Map<Id,Date> accMinDateMap = new  Map<Id,Date>();
            for(Contract_Detail__c cd : contrDetail){
                accIdSet.add(cd.Account_Name__c);
            }
            Map<Id,Account_Extension__c> accExt = new Map<Id,Account_Extension__c>([SELECT ID, Account__c, Account__r.First_ZDX_Contract_Date__c,
                                                                                        First_ZDX_Contract_Date__c
                                                                                        FROM Account_Extension__c 
                                                                                        WHERE Account__c IN: accIdSet]);
            
            System.debug('-=- accExt -=- '+accExt);
            
            Map<Id,Id> accVsAccExt = new Map<Id,Id>();
            for(Id acEx: accExt.keySet()){
                accVsAccExt.put(accExt.get(acEx).Account__c, acEx);
            }
            
            Set<String> setSKUCodes = new Set<String>();
            setSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZDX_Contract_Date').SKU_Codes__c.split(';'));
            List<Contract_Detail__c> contractDetails = [SELECT Id, Account_Name__c, Start_Date__c 
                                                                FROM Contract_Detail__c 
                                                                WHERE Account_Name__c IN :accIdSet 
                                                                AND Start_Date__c != Null 
                                                                AND Product_SKU__c in :setSKUCodes];
            
            System.debug('-=- contractDetails -=- '+contractDetails);
            for(Contract_Detail__c cd : contractDetails){
                if(accMinDateMap.containsKey(cd.Account_Name__c)){
                    Date minDate =  accMinDateMap.get(cd.Account_Name__c);
                    if(minDate > cd.Start_Date__c){ 
                        accMinDateMap.put(cd.Account_Name__c,cd.Start_Date__c);
                    }
                }else{
                    accMinDateMap.put(cd.Account_Name__c,cd.Start_Date__c);
                }                                                     
            }
            List<Account_Extension__c> accExtToUpdateList = new List<Account_Extension__c>();
            
            //Added by Aakash CR# 2794 : Start
            List<Account> accListToUpdate = new List<Account>();
            Account accToUpdate; 
            //Added by Aakash CR# 2794 : End
            
            for(Id accId : accMinDateMap.keySet()){
                Account_Extension__c acExt = accExt.get(accVsAccExt.get(accId));
                if(acExt.First_ZDX_Contract_Date__c == null || acExt.First_ZDX_Contract_Date__c > accMinDateMap.get(accId)){
                    acExt.First_ZDX_Contract_Date__c = accMinDateMap.get(accId);
                    accExtToUpdateList.add(acExt);
                }
                
                //Added by Aakash CR# 2794 : Start
                accToUpdate = new Account();
                accToUpdate.Id = accid;
                
                if(acExt.Account__r.First_ZDX_Contract_Date__c == null || acExt.Account__r.First_ZDX_Contract_Date__c > accMinDateMap.get(accId)){
                    accToUpdate.First_ZDX_Contract_Date__c = accMinDateMap.get(accid);
                }
                
                accListToUpdate.add(accToUpdate);
                //Added by Aakash CR# 2794 : End
            }
            if(!accExtToUpdateList.isEmpty() && accExtToUpdateList.size() > 0){
                update accExtToUpdateList;
            }
            // Added by Rajesh CR# 1251 : End
            
            //Added by Aakash CR# 2794 : Start
            
            if(!accListToUpdate.isEmpty()){
                update accListToUpdate;
            }
            
        }
    }
    */
     // Added by Aakash CR# 2794 : End


     //CR# 3665 changes
     public static void updateProductDetailOnContract(List<Contract_Detail__c> contractDetailList, Set<Id> productNameIDSet){
        Map<Id, Product2> productNameMap = new Map<Id, Product2>();
        
        if(!productNameIDSet.isEmpty()){
            productNameMap = fetchproductDetails(productNameIDSet);
        }

        if(!contractDetailList.isEmpty() && !productNameMap.isEmpty()){
            for(Contract_Detail__c cd : contractDetailList){

                //Set_Zscaler_Product_Family_as_Per_Produc
                if(productNameMap.get(cd.Product_Name__c).ProductCode == 'ZS-WFA-BUS-EDITION'){
                    cd.Zscaler_Product_Family__c = 'ZIA/ZPA';
                }else if(productNameMap.get(cd.Product_Name__c).ProductCode == 'EDU-ZIA-SVC-EDGE-BUS'){
                    cd.Zscaler_Product_Family__c = 'ZIA';
                }else{
                    cd.Zscaler_Product_Family__c = productNameMap.get(cd.Product_Name__c).Zscaler_Product_Family__c;
                }
    
                //Set_Product_Code_on_Contract_Detail
                cd.Product_SKU__c = productNameMap.get(cd.Product_Name__c).ProductCode;

                //Set_the_Price_Per_User_for_Product
                if(productNameMap.get(cd.Product_Name__c).Price_Type__c == 'License Subscription' && cd.Quantity__c > 0 && cd.MRR_USD__c > 0){   
                    cd.Price_Per_User__c = ((cd.MRR_USD__c * 12) / cd.Quantity__c);
                }else{
                    cd.Price_Per_User__c = null;
                }
                
                //Set_Premium_Support_ACV
                if(productNameMap.get(cd.Product_Name__c).Name.contains('Premium Support') || productNameMap.get(cd.Product_Name__c).Name.contains('TAM Top Up') || productNameMap.get(cd.Product_Name__c).Name.contains('TAM Service for 1YR') ){
    
                    if(cd.Sales_Order_Premium_Support_Term__c < 12){
                        cd.Premium_Support_ACV_Number__c = cd.MRR_USD__c * cd.Sales_Order_Premium_Support_Term__c;
                    }else{
                        cd.Premium_Support_ACV_Number__c = cd.MRR_USD__c * 12;
                    }
                } else{
                    cd.Premium_Support_ACV_Number__c = 0 ;
                }
            }
        }
        
     }

     //CR# 3665 changes
     public static Map<Id, Product2> fetchproductDetails(Set<Id> productNameIDSet){

        return new Map<Id, Product2> ([Select 
                                                id,
                                                Name, 
                                                ProductCode,
                                                Zscaler_Product_Family__c,
                                                Price_Type__c
                                                from Product2 where id in :productNameIDSet
                                                ]);
     }
     // Added by Aakash CR# 2794 : End
     
    public static void updateAccountExtension(List<Contract_Detail__c> contrDetail){
        Set<Id> accountSet = new Set<Id>();
        for(Contract_Detail__c cd:contrDetail){
            accountSet.add(cd.Account_Name__c);
        }
        if(!(System.isBatch() || System.isFuture())){
        AccountTriggerHelper.UpdateCSMAccountExtenssionMethod(accountSet);
        }
    }
}

//Changes done for Contract Detail
//Field Creation on Contract_Detail__c object: Sales_Order_Premium_Support_Term__c	
//Code chnages in ContractDetailTriggerHelper Class
//Code changes in UpdateContractDetailsToAccountBatch class
//WF deactiavtion