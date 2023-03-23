/*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name 
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2021-11-24      CR#3656/CR#3717: Swathi - Modified "accExtToUpdateMap" map condition to store lossing date Line No 249-265
  2022-05-06      CR#3678        : Mahesh T-Modified SIPA SKU and Logic as per CR
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class updateLatestContractDatesBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('updateLatestContractDatesBatch');
    public string query; 
    
    public updateLatestContractDatesBatch(String query){
        this.query = query;
        /*'SELECT Id  FROM ACCOUNT WHERE Type = \'Customer\''*/
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    
    public void execute (Database.BatchableContext context, List<Account> scope){
        this.zb.callExecute(scope[0]?.Id, scope.size());
        Map<Id,Account_Extension__c> accExtToUpdateMap = new Map<Id,Account_Extension__c>();
        Map<Id,Date> accMaxDateMap = new  Map<Id,Date>();
        Map<Id,Account_Extension__c> accExt = new Map<Id,Account_Extension__c>([SELECT ID, Account__c, 
                                                                                    Latest_ZPA_Contract_Date__c, 
                                                                                    Latest_ZIA_Contract_Date__c,
                                                                                    Latest_ZDX_Contract_Date__c,
                                                                                    Latest_ZCP_Contract_Date__c
                                                                                    FROM Account_Extension__c 
                                                                                    WHERE Account__c IN: scope]);
        Map<Id,Id> accVsAccExt = new Map<Id,Id>();
        for(Id acEx: accExt.keySet()){
            accVsAccExt.put(accExt.get(acEx).Account__c, acEx);
        }
        // ZPA Calculation Start
        Set<String> setSKUCodes = new Set<String>();
        setSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZPA_Contract_Date').SKU_Codes__c.split(';'));
        List<Contract_Detail__c> contractDetails = [SELECT Id, Start_Date__c, Product_SKU__c, Account_Name__c, APTS_Selling_Term__c,
                                                    Quantity__c, Contract_Detail_Status__c, Active__c
                                                    FROM Contract_Detail__c
                                                    WHERE Account_Name__c IN :accVsAccExt.keySet() AND Active__c = true 
                                                    AND Start_Date__c != null AND Product_SKU__c in :setSKUCodes
                                                    ORDER BY Account_Name__c, Quantity__c ASC];
        
        
        for(Contract_Detail__c cd : contractDetails){
            if(accExt.get(accVsAccExt.get(cd.Account_Name__c)).Latest_ZPA_Contract_Date__c == null ||(cd.Start_Date__c > accExt.get(accVsAccExt.get(cd.Account_Name__c)).Latest_ZPA_Contract_Date__c)){
                if(accMaxDateMap.containsKey(cd.Account_Name__c)){
                    Date maxDate =  accMaxDateMap.get(cd.Account_Name__c);
                    if(maxDate < cd.Start_Date__c){ 
                        accMaxDateMap.put(cd.Account_Name__c,cd.Start_Date__c);
                    }
                }else{
                    accMaxDateMap.put(cd.Account_Name__c,cd.Start_Date__c);
                }
            }
        }
        
        for(Id accId : accMaxDateMap.keySet()){
            if(accExtToUpdateMap.containsKey(accVsAccExt.get(accId))){
                Account_Extension__c accObj = accExtToUpdateMap.get(accVsAccExt.get(accId));
                accObj.Latest_ZPA_Contract_Date__c = accMaxDateMap.get(accId);
                accExtToUpdateMap.put(accVsAccExt.get(accId), accObj);
            }
            else{
                Account_Extension__c accObj = new Account_Extension__c(Id = accVsAccExt.get(accId) , Latest_ZPA_Contract_Date__c = accMaxDateMap.get(accId));
                accExtToUpdateMap.put(accVsAccExt.get(accId), accObj);
            }
        }
        // ZPA Calculation End
        
        // ZIA Calculation Start
        
        setSKUCodes = new Set<String>();
        accMaxDateMap = new  Map<Id,Date>();
        setSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZIA_Contract_Date').SKU_Codes__c.split(';'));
        setSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZIA_Contract_Date1').SKU_Codes__c.split(';'));
        contractDetails = [SELECT Id, Start_Date__c, Product_SKU__c, Account_Name__c, APTS_Selling_Term__c,
                                                    Quantity__c, Contract_Detail_Status__c, Active__c
                                                    FROM Contract_Detail__c
                                                    WHERE Account_Name__c IN: accVsAccExt.keySet() AND Active__c = true 
                                                    AND Start_Date__c != null AND Product_SKU__c in :setSKUCodes
                                                    ORDER BY Account_Name__c, Quantity__c ASC];
        
        for(Contract_Detail__c cd : contractDetails){   
            if(accExt.get(accVsAccExt.get(cd.Account_Name__c)).Latest_ZIA_Contract_Date__c == null || (cd.Start_Date__c > accExt.get(accVsAccExt.get(cd.Account_Name__c)).Latest_ZIA_Contract_Date__c)){
                if(accMaxDateMap.containsKey(cd.Account_Name__c)){
                    Date maxDate =  accMaxDateMap.get(cd.Account_Name__c);
                    if(maxDate < cd.Start_Date__c){ 
                        accMaxDateMap.put(cd.Account_Name__c,cd.Start_Date__c);
                    }
                }else{
                    accMaxDateMap.put(cd.Account_Name__c,cd.Start_Date__c);
                }
            }
            System.debug('accMaxDateMap '+accMaxDateMap);
        }
        
        for(Id accId : accMaxDateMap.keySet()){
            if(accExtToUpdateMap.containsKey(accVsAccExt.get(accId))){
                Account_Extension__c accObj = accExtToUpdateMap.get(accVsAccExt.get(accId));
                accObj.Latest_ZIA_Contract_Date__c = accMaxDateMap.get(accId);
                accExtToUpdateMap.put(accVsAccExt.get(accId), accObj);
                System.debug('accExtToUpdateMap '+accExtToUpdateMap);
            }
            else{
                Account_Extension__c accObj = new Account_Extension__c(Id = accVsAccExt.get(accId) , Latest_ZIA_Contract_Date__c = accMaxDateMap.get(accId));
                accExtToUpdateMap.put(accVsAccExt.get(accId), accObj);
            }
        }       
        // ZIA Calculation End
        
        // ZDX Calculation Start : Added by Rajesh CR# 1251 : Start
        
        setSKUCodes = new Set<String>();
        accMaxDateMap = new  Map<Id,Date>();
        setSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZDX_Contract_Date').SKU_Codes__c.split(';'));
        contractDetails = [SELECT Id, Start_Date__c, Product_SKU__c, Account_Name__c, APTS_Selling_Term__c,
                                                    Quantity__c, Contract_Detail_Status__c, Active__c
                                                    FROM Contract_Detail__c
                                                    WHERE Account_Name__c IN: accVsAccExt.keySet() AND Active__c = true 
                                                    AND Start_Date__c != null AND Product_SKU__c in :setSKUCodes
                                                    ORDER BY Account_Name__c, Quantity__c ASC];
        
        for(Contract_Detail__c cd : contractDetails){   
            if(accExt.get(accVsAccExt.get(cd.Account_Name__c)).Latest_ZDX_Contract_Date__c == null || (cd.Start_Date__c > accExt.get(accVsAccExt.get(cd.Account_Name__c)).Latest_ZDX_Contract_Date__c)){
                if(accMaxDateMap.containsKey(cd.Account_Name__c)){
                    Date maxDate =  accMaxDateMap.get(cd.Account_Name__c);
                    if(maxDate < cd.Start_Date__c){ 
                        accMaxDateMap.put(cd.Account_Name__c,cd.Start_Date__c);
                    }
                }else{
                    accMaxDateMap.put(cd.Account_Name__c,cd.Start_Date__c);
                }
            }
        }
        
        for(Id accId : accMaxDateMap.keySet()){
            if(accExtToUpdateMap.containsKey(accVsAccExt.get(accId))){
                Account_Extension__c accObj = accExtToUpdateMap.get(accVsAccExt.get(accId));
                accObj.Latest_ZDX_Contract_Date__c = accMaxDateMap.get(accId);
                accExtToUpdateMap.put(accVsAccExt.get(accId), accObj);
            }
            else{
                Account_Extension__c accObj = new Account_Extension__c(Id = accVsAccExt.get(accId) , Latest_ZDX_Contract_Date__c = accMaxDateMap.get(accId));
                accExtToUpdateMap.put(accVsAccExt.get(accId), accObj);
            }
        }       
        // ZIA Calculation End : Added by Rajesh CR# 1251 : End
        
        //CR# 2711 : Bikram, Added ZCP Logic, START
        
        setSKUCodes = new Set<String>();
        accMaxDateMap = new  Map<Id,Date>();
        setSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZCP_Contract_Date1').SKU_Codes__c.split(';'));
        setSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZCP_Contract_Date2').SKU_Codes__c.split(';'));
        setSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZCP_Contract_Date3').SKU_Codes__c.split(';'));
        
        contractDetails = [SELECT Id, Start_Date__c, Product_SKU__c, Account_Name__c, APTS_Selling_Term__c,
                           Quantity__c, Contract_Detail_Status__c, Active__c
                           FROM Contract_Detail__c
                           WHERE Account_Name__c IN :accVsAccExt.keySet() AND Active__c = true 
                           AND Start_Date__c != null AND Product_SKU__c in :setSKUCodes
                           ORDER BY Account_Name__c, Quantity__c ASC];
        
        for(Contract_Detail__c cd : contractDetails){
            if(accExt.get(accVsAccExt.get(cd.Account_Name__c)).Latest_ZCP_Contract_Date__c == null ||(cd.Start_Date__c > accExt.get(accVsAccExt.get(cd.Account_Name__c)).Latest_ZCP_Contract_Date__c)){
                if(accMaxDateMap.containsKey(cd.Account_Name__c)){
                    Date maxDate =  accMaxDateMap.get(cd.Account_Name__c);
                    if(maxDate < cd.Start_Date__c){ 
                        accMaxDateMap.put(cd.Account_Name__c,cd.Start_Date__c);
                    }
                }else{
                    accMaxDateMap.put(cd.Account_Name__c,cd.Start_Date__c);
                }
            }
        }
        
        for(Id accId : accMaxDateMap.keySet()){
            if(accExtToUpdateMap.containsKey(accVsAccExt.get(accId))){
                Account_Extension__c accObj = accExtToUpdateMap.get(accVsAccExt.get(accId));
                accObj.Latest_ZCP_Contract_Date__c = accMaxDateMap.get(accId);
                accExtToUpdateMap.put(accVsAccExt.get(accId), accObj);
            }
            else{
                Account_Extension__c accObj = new Account_Extension__c(Id = accVsAccExt.get(accId) , Latest_ZCP_Contract_Date__c = accMaxDateMap.get(accId));
                accExtToUpdateMap.put(accVsAccExt.get(accId), accObj);
            }
        }
        
        //CR# 2711 : Bikram, Added ZCP Logic, END
        
        //Added by Varun  -- CR# 2689 - Start
        //Modified SIPA SKU for CR#3678 
        Map<Id,List<Contract_Detail__c>> accountWithContractDetailsMap = new Map<Id,List<Contract_Detail__c>>();        
        Map<Id, Decimal> accountWithELASeatsMap = new Map<Id, Decimal>();
        Map<Id, Decimal> accountWithZPASeatsMap = new Map<Id, Decimal>();
        Map<Id, Decimal> accountWithExtraSipaSeatsMap = new Map<Id, Decimal>();
        Map<Id, Decimal> accountWithSIPASeatsMap = new Map<Id, Decimal>();
        
        for(Contract_Detail__c cDetail:[SELECT id,Account_Name__c,Product_SKU__c,APTS_SKU__c
                                        ,Quantity__c,Contract_Detail_Status__c from Contract_Detail__c where Account_Name__c
                                        IN :accVsAccExt.keySet()  and Contract_Detail_Status__c
                                        in('Active','Pending Renewal')  and Amount_USD__c >=0 
                                        and Product_SKU__c in ('ZS-SIPA','ZSC-SIPA','ZS-SIPA-PRE','ZSC-SIPA-PRE','ZPA-BUS-EDITION',
                                                               'ZIA-TRANS-EDITION','ZIA-ELA-EDITION','ZS-WFA-BUS-EDITION',
                                                               'ZS-SIPA-EXTRA-GB','ZIA-ELA-BUNDLE',
                                                               'ZPA-BUS','ZPA-BUS-LU')])
        {
            if(cDetail!=null){
                List<Contract_Detail__c> cdlst = accountWithContractDetailsMap.get(cDetail.Account_Name__c);
                if(cdlst == null)
                    cdlst = new List<Contract_Detail__c>();
                cdlst.add(cDetail);
                accountWithContractDetailsMap.put(cDetail.Account_Name__c,cdlst);
            }
        }    
        
        for(Id accId : accVsAccExt.keySet()){
            if(!accountWithContractDetailsMap.isEmpty() && accountWithContractDetailsMap.containskey(accId)){
                for(Contract_Detail__c cd:accountWithContractDetailsMap.get(accId)){
                    if(cd.APTS_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZIA_ELA_EDITION)||
                       cd.APTS_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE)){
                           
                           if(!accountWithELASeatsMap.containsKey(accId)){
                               accountWithELASeatsMap.put(accId, 0);
                           }
                           accountWithELASeatsMap.put(accId, accountWithELASeatsMap.get(accId)+cd.Quantity__c);
                       }
                    if(cd.APTS_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZPA_BUS_EDITION)
                       ||cd.APTS_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZPA_BUS)
                       ||cd.APTS_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU)
                       ||cd.APTS_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZS_SIPA)){   //Added by Ayush Kangar as part of CR# 5083
                           if (!accountWithZPASeatsMap.containsKey(accId))  {
                               accountWithZPASeatsMap.put(accId, 0);
                           }
                           accountWithZPASeatsMap.put(accId, accountWithZPASeatsMap.get(accId)+cd.Quantity__c);
                     } 
                     if(cd.APTS_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZS_SIPA_EXTRA_GB)){
                           if(!accountWithExtraSipaSeatsMap.containsKey(accId)){
                               accountWithExtraSipaSeatsMap.put(accId, 0);
                           }
                           accountWithExtraSipaSeatsMap.put(accId, accountWithExtraSipaSeatsMap.get(accId)+cd.Quantity__c);
                     }
                     else if(!cd.Product_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZIA_ELA_EDITION) 
                               && !cd.Product_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE)
                               && !cd.Product_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZPA_BUS_EDITION)
                               && !cd.Product_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZPA_BUS)
                               && !cd.Product_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZPA_BUS_LU)
                               && !cd.Product_SKU__c.equals(APTS_CONSTANTS.PROD_SKU_ZS_SIPA_EXTRA_GB)
                              ){
                           if(!accountWithSIPASeatsMap.containsKey(accId)){
                               accountWithSIPASeatsMap.put(accId, 0);
                           }
                           accountWithSIPASeatsMap.put(accId, accountWithSIPASeatsMap.get(accId)+cd.Quantity__c);
                           System.debug('inside else if');
                       }System.debug('accountWithSIPASeatsMap'+accountWithSIPASeatsMap);
                  }
             }
         }
        
        for(Id accId : accVsAccExt.keySet()){
            //Account_Extension__c accExc = new Account_Extension__c(id=accVsAccExt.get(accId));
            //Added by Swathi CR#3656/CR#3717 Start
            if(accExtToUpdateMap.containsKey(accVsAccExt.get(accId))){
                Account_Extension__c accExc = accExtToUpdateMap.get(accVsAccExt.get(accId));
                if(accountWithExtraSipaSeatsMap.containsKey(accId)){
                    accExc.SIPA_Extra_GBs__c = accountWithExtraSipaSeatsMap.get(accId);
                }
                if(accountWithELASeatsMap.containsKey(accId) && accountWithZPASeatsMap.containsKey(accId)){
                    if( accountWithELASeatsMap.get(accId) >= accountWithZPASeatsMap.get(accId)){
                        accExc.No_of_SIPA_Seats__c = accountWithELASeatsMap.get(accId);
                        System.debug('ELAGreater');
                    }
                    else{
                        accExc.No_of_SIPA_Seats__c = accountWithZPASeatsMap.get(accId);
                        System.debug('ZPA');     
                    }
                }
                if(accountWithELASeatsMap.containsKey(accId) && !accountWithZPASeatsMap.containsKey(accId)){
                    accExc.No_of_SIPA_Seats__c = accountWithELASeatsMap.get(accId);
                    System.debug('ELAAAA');               
                }    
                if(!accountWithELASeatsMap.containsKey(accId) && accountWithZPASeatsMap.containsKey(accId)){           //Added by Ayush Kangar as part of CR# 5083      
                    accExc.No_of_SIPA_Seats__c = accountWithZPASeatsMap.get(accId);
                    System.debug('ZPA-NO ELA');
                }
                else if(!accountWithELASeatsMap.containsKey(accId) && !accountWithZPASeatsMap.containsKey(accId) && accountWithSIPASeatsMap.containsKey(accId)){
                    accExc.No_of_SIPA_Seats__c = accountWithSIPASeatsMap.get(accId);
                    System.debug('ELSESEATSSS');
                }
                accExtToUpdateMap.put(accExc.Id,accExc);
            } 
            else{
                //Added by Swathi CR#3656/CR#3717 End
                Account_Extension__c accExc = new Account_Extension__c(id=accVsAccExt.get(accId));
                if(accountWithExtraSipaSeatsMap.containsKey(accId)){
                    accExc.SIPA_Extra_GBs__c = accountWithExtraSipaSeatsMap.get(accId);
                }
                if(accountWithELASeatsMap.containsKey(accId) && accountWithZPASeatsMap.containsKey(accId)){
                    if( accountWithELASeatsMap.get(accId) >= accountWithZPASeatsMap.get(accId)){
                        accExc.No_of_SIPA_Seats__c = accountWithELASeatsMap.get(accId);
                        System.debug('ELAGreater');
                    }
                    else{
                        accExc.No_of_SIPA_Seats__c = accountWithZPASeatsMap.get(accId);
                        System.debug('ZPA');     
                    }
                }
                 if(accountWithELASeatsMap.containsKey(accId) && !accountWithZPASeatsMap.containsKey(accId)){
                    accExc.No_of_SIPA_Seats__c = accountWithELASeatsMap.get(accId);
                    System.debug('ELAAAA');               
                }    
                if(!accountWithELASeatsMap.containsKey(accId) && accountWithZPASeatsMap.containsKey(accId)){                  
                    accExc.No_of_SIPA_Seats__c = accountWithZPASeatsMap.get(accId);
                    System.debug('ZPA-NO ELA');
                }
                else if(!accountWithELASeatsMap.containsKey(accId) && !accountWithZPASeatsMap.containsKey(accId) && accountWithSIPASeatsMap.containsKey(accId)){
                    accExc.No_of_SIPA_Seats__c = accountWithSIPASeatsMap.get(accId);
                    System.debug('ELSESEATSSS');
                }
                accExtToUpdateMap.put(accExc.Id,accExc);
            }
        }
        
        //Added by Varun  -- CR# 2689 - End
        
        //Added by Varun : CR# 1807: Start
        if(accExtToUpdateMap.size() > 0 && !accExtToUpdateMap.isEmpty()){
            System.debug('accExtToUpdateMap '+accExtToUpdateMap);
            update  AccountExtensionTriggerHelper.updateAccountExtensionCheckBoxFromBatch(accExtToUpdateMap.values());
            System.debug('accExtToUpdateMap '+accExtToUpdateMap);
        }
        //Added by Varun : CR# 1807: End
        
        contractDetails = [SELECT Id, Active__c, Active_Platform__c FROM Contract_Detail__c
                                                    WHERE Account_Name__c IN: accVsAccExt.keySet() AND Active__c = true 
                                                    AND Active_Platform__c = false];
        
        for(Contract_Detail__c cd : contractDetails){   
            cd.Active_Platform__c = cd.Active__c;
        }
        
        if(!contractDetails.isEmpty()){
            TriggerUtility.SkipConDetailTriggerExecuted();
            update contractDetails;
        }
           
    }
     
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
    }
}