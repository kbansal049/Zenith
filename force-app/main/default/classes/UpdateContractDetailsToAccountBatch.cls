/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   09-15-2021   Bharath R.    Initial Version
 * 2.0   11-28-2021   Mayank B.     Incremental fix CR# 3665
 * 3.0	 27-01-2022   Mahesh T      Fix for 4078
 * 4.0   25-03-2022   Mahesh T      Added for CR#3918
 * 5.0   20-04-2022   Swathi        Added for CR#4688
 * 6.0   23-03-2022   Swathi        CR# 4250 and CR# 4342 Changes
 * 7.0   09-14-2022.  Karthik.      IBA-2471 to update ARR values
 * 8.0   10-04-2022   Mahesh T      IBA-2910 to update #Users Purchased: ZDX Platform
 * 9.0   11-01-2022   Ritesh K      IBA-4095 Reference update to include ZIA_Contract_Date2 ,ZPA_Contract_Date1
 * 10.0  11-014-2022  Ritesh K      IBA-1645 Update Number of Entitled ZPA Connectors for Bundles (CR# 5140)
*/
public class UpdateContractDetailsToAccountBatch implements Database.Batchable<sObject>, Database.Stateful{
    public string query;
	ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateContractDetailsToAccountBatch');
    
    public List<String> acctTypes = new List<String>{'Customer','Ex-Customer'};
        public Set<Id> accIds = new Set<Id>();
    public UpdateContractDetailsToAccountBatch(){
        this.query = 'SELECT Id, First_ZDX_Contract_Date__c, No_Of_ZDX_Platform_Users__c,Total_ZIA_Platform_Users_Purchased__c, Total_ZPA_Platform_Users_Purchased__c FROM Account WHERE Type in :acctTypes  ';  
    }
    public UpdateContractDetailsToAccountBatch(Set<Id> queryParam){
        accIds.addAll(queryParam); 
        this.query = 'SELECT Id, First_ZDX_Contract_Date__c, No_Of_ZDX_Platform_Users__c,Total_ZIA_Platform_Users_Purchased__c, Total_ZPA_Platform_Users_Purchased__c FROM Account WHERE Id in :accIds';  
    }   
    public Database.QueryLocator start(Database.BatchableContext BC){   
         this.zb.callStart();
        
        /* List<String> acctTypes = new List<String>{'Customer','Ex-Customer'};
String query = 'SELECT Id, First_ZDX_Contract_Date__c, No_Of_ZDX_Platform_Users__c FROM Account WHERE Type in :acctTypes'; */
        System.debug('-=-= query -=- '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> accList){
                
        this.zb.callExecute(accList[0]?.Id, accList.size());
        
        Map<Id, Account> accMap = new Map<Id, Account>();
        for (Account acc : accList) {
            accMap.put(acc.Id, acc);
        }

        Set<String> setSKUCodes = new Set<String>();
        //IBA-4095
        Set<String> ZIA_SKU_Code_Set = new Set<String>();
        Set<String> ZPA_SKU_Code_Set = new Set<String>();
        Set<String> ZDX_SKU_Code_Set = new Set<String>();
        for(Contract_Date_SKUs__c cdRecord : Contract_Date_SKUs__c.getAll().Values()){
            if(String.isNotBlank(cdRecord.family__c)){
                if(cdRecord.family__c.equalsIgnoreCase('ZIA')){ ZIA_SKU_Code_Set.addAll(cdRecord.SKU_Codes__c.split(';'));}
                else if(cdRecord.family__c.equalsIgnoreCase('ZPA')){ ZPA_SKU_Code_Set.addAll(cdRecord.SKU_Codes__c.split(';'));}
                else if(cdRecord.family__c.equalsIgnoreCase('ZDX')){ ZDX_SKU_Code_Set.addAll(cdRecord.SKU_Codes__c.split(';'));}
            }
        }
        //IBA-4095
        //setSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZDX_Contract_Date').SKU_Codes__c.split(';'));
        
        Map<Id,Account> accIdVsRollUp = new  Map<Id,Account>();
        for (AggregateResult aggregateData :[SELECT MIN(Start_Date__c) minStartDt,Account_Name__c
                                             FROM Contract_Detail__c 
                                             WHERE Account_Name__c IN :accList
                                             AND Start_Date__c != Null 
                                             AND Product_SKU__c IN :ZDX_SKU_Code_Set
                                             GROUP BY Account_Name__c])
        {
            System.debug('AggRes++'+aggregateData);
            Account acctToUpdate = new Account();
            acctToUpdate.id = (id)aggregateData.get('Account_Name__c');
            acctToUpdate.First_ZDX_Contract_Date__c = (Date)aggregateData.get('minStartDt');
            accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);                                    
            System.debug('AccList++'+acctToUpdate);
        }
        //Counting the ZDX Platform users
        List<String> contractStatus = new List<String>{'Active','Pending Renewal'};
        
        Set<String> setZDX_ADVPlusSKUCodes = new Set<String>();
        setZDX_ADVPlusSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZDX_Adv_Plus').SKU_Codes__c.split(';'));
      //  System.debug('setZDX_ADVPlusSKUCodes'+setZDX_ADVPlusSKUCodes);
        
        Set<String> setZDX_M365SKUCodes = new Set<String>();
        setZDX_M365SKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZDX_M365').SKU_Codes__c.split(';'));
            
        Set<String> setZDX_ADVSKUCodes = new Set<String>();
        setZDX_ADVSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZDX_Adv').SKU_Codes__c.split(';'));
        
        Set<String> setZDX_STDSKUCodes = new Set<String>();
        setZDX_STDSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZDX_Standard').SKU_Codes__c.split(';'));
        setZDX_STDSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZDX_Standard2').SKU_Codes__c.split(';'));
        setZDX_STDSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZDX_Standard3').SKU_Codes__c.split(';'));
        setZDX_STDSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZDX_Standard4').SKU_Codes__c.split(';'));
       
        Set<Id> zdxAdvAccIds = new Set<Id>();
        // Added as part ofIBA-2910 --Mahesh T
        List<Account> zdxAdvAcc = new List<Account>();
        List<Account> zdxM365Acc = new List<Account>();
        List<Account> zdxStandardAcc = new List<Account>();
        //ZDX ADV SKUs count
        Boolean trackZDXaggregateData = false; // Added as part of CR#4688
        //Added as part of IBA-2910 --Start
          for (AggregateResult aggregateData :[SELECT SUM(Quantity__c) qty,Account_Name__c,Product_SKU__c
                                             FROM Contract_Detail__c 
                                             WHERE Account_Name__c IN :accList
                                             AND Start_Date__c != Null 
                                             AND Product_SKU__c IN :setZDX_ADVPlusSKUCodes
                                             AND Contract_Detail_Status__c IN :contractStatus
                                             //AND Do_not_Aggregate__c = false
                                             AND Ramp_Status__c = 'Fully Ramped Line'
                                             AND Quantity__c > 0
                                             AND Amount_USD__c >= 0 
                                             GROUP BY Account_Name__c,Product_SKU__c
                                             ORDER BY SUM(Quantity__c) DESC LIMIT 1])
        {
            System.debug('ZDX_ADV_Plus++'+aggregateData);
            Account acctToUpdate = new Account();
            Id aggAccId = (id)aggregateData.get('Account_Name__c');
            if(accIdVsRollUp.containsKey(aggAccId)){
                acctToUpdate = accIdVsRollUp.get(aggAccId);                                                            
            }else {
                acctToUpdate.id = aggAccId;    
            }                                    
            acctToUpdate.No_Of_ZDX_Platform_Users__c = (Decimal)aggregateData.get('qty');
            accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);
            zdxAdvAccIds.add(aggAccId);                                                          
            System.debug('AccList++'+acctToUpdate);
            trackZDXaggregateData = true; // Added as part of CR#4688
        }
          
        //Remove ZDX ADV Plus Accounts from list
        for(Account accClean:accList){
            if(!zdxAdvAccIds.contains(accClean.id)){
                zdxAdvAcc.add(accClean);
            }
        }
      
        for (AggregateResult aggregateData :[SELECT SUM(Quantity__c) qty,Account_Name__c,Product_SKU__c
                                             FROM Contract_Detail__c 
                                             WHERE Account_Name__c IN :zdxAdvAcc
                                             AND Start_Date__c != Null 
                                             AND Product_SKU__c IN :setZDX_ADVSKUCodes
                                             AND Contract_Detail_Status__c IN :contractStatus
                                             //AND Do_not_Aggregate__c = false
                                             AND Ramp_Status__c = 'Fully Ramped Line'
                                             AND Quantity__c > 0
                                             AND Amount_USD__c >= 0 
                                             GROUP BY Account_Name__c,Product_SKU__c
											 ORDER BY SUM(Quantity__c) DESC LIMIT 1 ])
        {
            System.debug('zdxAdv++'+aggregateData);
            Account acctToUpdate = new Account();
            Id aggAccId = (id)aggregateData.get('Account_Name__c');
            if(accIdVsRollUp.containsKey(aggAccId)){
                acctToUpdate = accIdVsRollUp.get(aggAccId);                                                            
            }else {
                acctToUpdate.id = aggAccId;    
            }                                    
            acctToUpdate.No_Of_ZDX_Platform_Users__c = (Decimal)aggregateData.get('qty');
            accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);
            zdxAdvAccIds.add(aggAccId);                                                          
            System.debug('AccList++'+acctToUpdate);
            trackZDXaggregateData = true; // Added as part of CR#4688
        }
        
        
        //Remove ZDX ADV Accounts from list
        for(Account accClean:accList){
            if(!zdxAdvAccIds.contains(accClean.id)){
                zdxM365Acc.add(accClean);
            }
        }
        
          for (AggregateResult aggregateData :[SELECT SUM(Quantity__c) qty,Account_Name__c,Product_SKU__c
                                             FROM Contract_Detail__c 
                                             WHERE Account_Name__c IN :zdxM365Acc
                                             AND Start_Date__c != Null 
                                             AND Product_SKU__c IN :setZDX_M365SKUCodes
                                             AND Contract_Detail_Status__c IN :contractStatus
                                             //AND Do_not_Aggregate__c = false
                                             AND Ramp_Status__c = 'Fully Ramped Line'
                                             AND Quantity__c > 0
                                             AND Amount_USD__c >= 0 
                                             GROUP BY Account_Name__c,Product_SKU__c
											 ORDER BY SUM(Quantity__c) DESC LIMIT 1])
        {
            System.debug('zdxM365++'+aggregateData);
            Account acctToUpdate = new Account();
            Id aggAccId = (id)aggregateData.get('Account_Name__c');
            if(accIdVsRollUp.containsKey(aggAccId)){
                acctToUpdate = accIdVsRollUp.get(aggAccId);                                                            
            }else {
                acctToUpdate.id = aggAccId;    
            }                                    
            acctToUpdate.No_Of_ZDX_Platform_Users__c = (Decimal)aggregateData.get('qty');
            accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);
            zdxAdvAccIds.add(aggAccId);                                                          
            System.debug('AccList++'+acctToUpdate);
            trackZDXaggregateData = true; // Added as part of CR#4688
        }
        
        
        //Remove ZDX ADV Accounts from list
        for(Account accClean:accList){
            if(!zdxAdvAccIds.contains(accClean.id)){
                zdxStandardAcc.add(accClean);
            }
        }
        //IBA-2910--Stop
        //ZDX STD SKUs count
        System.debug('zdxStandardAcc ::'+zdxStandardAcc);
        System.debug('zdxStandardAcc ::'+setZDX_STDSKUCodes);
        System.debug('zdxStandardAcc ::'+contractStatus);
        for (AggregateResult aggregateData :[SELECT SUM(Quantity__c) qty,Account_Name__c,Product_SKU__c
                                             FROM Contract_Detail__c 
                                             WHERE Account_Name__c IN :zdxStandardAcc
                                             AND Start_Date__c != Null 
                                             AND Product_SKU__c IN :setZDX_STDSKUCodes
                                             AND Contract_Detail_Status__c IN :contractStatus
                                             //AND Do_not_Aggregate__c = false
                                             AND Ramp_Status__c = 'Fully Ramped Line'
                                             AND Quantity__c > 0 
                                             AND Amount_USD__c >= 0 
                                             GROUP BY Account_Name__c,Product_SKU__c
											 ORDER BY SUM(Quantity__c) DESC LIMIT 1])
        {
            System.debug('zdxStandard++'+aggregateData);
            Account acctToUpdate = new Account();
            Id aggAccId = (id)aggregateData.get('Account_Name__c');
            if(accIdVsRollUp.containsKey(aggAccId)){
                acctToUpdate = accIdVsRollUp.get(aggAccId);                                                            
            }else {
                acctToUpdate.id = aggAccId;    
            }                                    
            acctToUpdate.No_Of_ZDX_Platform_Users__c = (Decimal)aggregateData.get('qty');
            accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);
            zdxAdvAccIds.add(aggAccId);                                                          
            System.debug('AccList++'+acctToUpdate);
            trackZDXaggregateData = true; // Added as part of CR#4688
        }
        // Added as part of CR#4688 - Start
        if(!trackZDXaggregateData || Test.isRunningTest() ){
            Account aggAccId = (accMap.values()[0]);
            if(accIdVsRollUp.containsKey(aggAccId.Id)){
                aggAccId = accIdVsRollUp.get(aggAccId.Id);                                                            
            }else {
                aggAccId.id = aggAccId.Id;    
            }                                    
            aggAccId.No_Of_ZDX_Platform_Users__c = 0;
            accIdVsRollUp.put(aggAccId.id, aggAccId);                                                          
            System.debug('TotalZDXAccList++'+aggAccId);
        }
        // Added as part of CR#4688 - End
        //ZPA Cross Platform User count
        Boolean trackZPAaggregateResult = false; // Added as part of CR#4688
        for (AggregateResult aggregateData : [SELECT SUM(Quantity__c) qty,Account_Name__c 
                                             FROM Contract_Detail__c 
                                             WHERE Start_Date__c != Null 
                                             AND Account_Name__c IN :accList
                                             AND Contract_Detail_Status__c IN :contractStatus 
                                             //AND Do_not_Aggregate__c = false
                                             AND Ramp_Status__c = 'Fully Ramped Line' 
                                             AND Quantity__c > 0  
                                             AND Amount_USD__c >= 0 
                                             AND Product_Name__r.Product_Line__c in ('ZPA','Cross Platform') 
                                             AND Product_Name__r.isBundle__c= true 
                                             GROUP BY Account_Name__c] )
        {
            System.debug('AggRes++'+aggregateData);
            Account acctToUpdate = new Account();
            Id aggAccId = (id)aggregateData.get('Account_Name__c');
            if(accIdVsRollUp.containsKey(aggAccId)){
                acctToUpdate = accIdVsRollUp.get(aggAccId);                                                            
            }else {
                acctToUpdate.id = aggAccId;    
            }                                    
            acctToUpdate.Total_ZPA_Platform_Users_Purchased__c = (Decimal)aggregateData.get('qty');
            accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);
            zdxAdvAccIds.add(aggAccId);                                                          
            System.debug('ZPAAccList++'+acctToUpdate);
            trackZPAaggregateResult = true; // Added as part of CR#4688
        }
        // Added as part of CR#4688 - Start
        if(!trackZPAaggregateResult){
            Account aggAccId = (accMap.values()[0]);
            if(accIdVsRollUp.containsKey(aggAccId.Id)){
                aggAccId = accIdVsRollUp.get(aggAccId.Id);                                                            
            }else {
                aggAccId.id = aggAccId.Id;    
            }                                    
            aggAccId.Total_ZPA_Platform_Users_Purchased__c = 0;
            accIdVsRollUp.put(aggAccId.id, aggAccId);                                                          
            System.debug('TotalZPAAccList++'+aggAccId);
        }
        // Added as part of CR#4688 - End
        //ZIA Cross Platform User count
        Boolean trackZIAaggregateResult = false; // Added as part of CR#4688
        for (AggregateResult aggregateData :[SELECT SUM(Quantity__c) qty,Account_Name__c 
                                             FROM Contract_Detail__c 
                                             WHERE Start_Date__c != Null 
                                             AND Account_Name__c IN :accList
                                             AND Contract_Detail_Status__c IN :contractStatus 
                                             //AND Do_not_Aggregate__c = false
                                             AND Ramp_Status__c = 'Fully Ramped Line' 
                                             AND Quantity__c > 0 
                                             AND Amount_USD__c >= 0 
                                             AND Product_Name__r.Product_Line__c in ('ZIA','Cross Platform') 
                                             AND Product_Name__r.isBundle__c= true 
                                             GROUP BY Account_Name__c])
        {
            System.debug('AggRes++'+aggregateData);
            Account acctToUpdate = new Account();
            Id aggAccId = (id)aggregateData.get('Account_Name__c');
            if(accIdVsRollUp.containsKey(aggAccId)){
                acctToUpdate = accIdVsRollUp.get(aggAccId);                                                            
            }else {
                acctToUpdate.id = aggAccId;    
            }                                    
            acctToUpdate.Total_ZIA_Platform_Users_Purchased__c	 = (Decimal)aggregateData.get('qty');
            accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);
            zdxAdvAccIds.add(aggAccId);                                                          
            System.debug('ZIAAccList++'+acctToUpdate);
            trackZIAaggregateResult = true; // Added as part of CR#4688
        }
        // Added as part of CR#4688 - Start
        if(!trackZIAaggregateResult){
            Account aggAccId = (accMap.values()[0]);
            if(accIdVsRollUp.containsKey(aggAccId.Id)){
                aggAccId = accIdVsRollUp.get(aggAccId.Id);                                                            
            }else {
                aggAccId.id = aggAccId.Id;    
            }                                    
            aggAccId.Total_ZIA_Platform_Users_Purchased__c = 0;
            accIdVsRollUp.put(aggAccId.id, aggAccId);                                                         
            System.debug('totalZIAAccList++'+aggAccId);
        }
        // Added as part of CR#4688 - End
         // Added for ZDX CR#3918
         for (AggregateResult aggregateData :[select sum(ZDX_L30D_Active_Users__c) ZDXL30DActiveUsers ,
                                               SUM(ZDX_L30_Device_Count__c) ZDXL30DeviceCount,
                                               SUM(ZDX_Incident_Count__c) ZDXIncidentCount,
                                               Account__c 
                                                from Zscaler_Cloud_ID__c 
												where Latest_ZDX_Cloud_Usage__c !=null  and Account__c in :accList
                                               	group by Account__c 
                                               	order by Account__c])
        {
            System.debug('ZDX AggRes++'+aggregateData);
            Account acctToUpdate = new Account();
           	Id aggAccId = (Id)aggregateData.get('Account__c');
            if(accIdVsRollUp.containsKey(aggAccId)){
                acctToUpdate = accIdVsRollUp.get(aggAccId);                                                            
            }else {
                acctToUpdate.id = aggAccId;    
            }                                    
            acctToUpdate.ZDX_Active_Users_L30D__c = (Decimal)aggregateData.get('ZDXL30DActiveUsers');
            acctToUpdate.ZDX_Active_Devices__c	  = (Decimal)aggregateData.get('ZDXL30DeviceCount');
            acctToUpdate.Total_Incidents_detected_in_last_Month__c = (Decimal)aggregateData.get('ZDXIncidentCount');
            accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);                                    
            System.debug('ZDX AccList++'+acctToUpdate);
        } 
        
        
        //CR# 3665 changes

        setSKUCodes = new Set<String>();
        Set<String> setZDXSKUCodes = new Set<String>();
        Set<String> setZPASKUCodes = new Set<String>();
        //setZDXSKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZDX_Contract_Date').SKU_Codes__c.split(';'));
        //setZPASKUCodes.addAll(SKUs_Referred_in_Renewal_Upsell_NS_Calc__c.getValues('ZPA_Contract_Date').SKU_Codes__c.split(';'));
        //setSKUCodes.addAll(setZDXSKUCodes);
        //setSKUCodes.addAll(setZPASKUCodes);
        setZDXSKUCodes.addAll(ZDX_SKU_Code_Set);//IBA-4095-Rakshitha
        setZPASKUCodes.addAll(ZPA_SKU_Code_Set);//IBA-4095-Rakshitha
        setSKUCodes.addAll(ZDX_SKU_Code_Set);//IBA-4095
        setSKUCodes.addAll(ZPA_SKU_Code_Set);//IBA-4095
        Set<String> conDetailStatusSet = new Set<String>();
        conDetailStatusSet.add('Active');
        conDetailStatusSet.add('Pending Renewal');
        Map<Id, List<Contract_Detail__c>> AccountIdContractDetailMap = new Map<Id, List<Contract_Detail__c>>();
        for (Contract_Detail__c cd :[SELECT id,Account_Name__c, Premium_Support_ACV__c, Start_Date__c,Quantity__c,
                                     MRR_USD__c,Zscaler_Product_Family__c,Do_not_Aggregate__c,Amount_USD__c,
                                     Account_Name__r.First_ZDX_Contract_Date__c, Product_SKU__c,Price_Per_User__c,Ramp_Status__c,
                                     Account_Name__r.First_ZPA_Contract_Date__c, Product_Name__r.Name, Contract_Detail_Status__c, Product_Name__c, //Null pointer fix
                                     Is_Bundle_SKU__c,Premium_Support_ACV_Number__c,Active__c,Is_Contract_Active__c FROM Contract_Detail__c 
                                     WHERE Account_Name__c IN :accList order by Account_Name__c])
        {

            System.debug('AggRes++'+cd);
            Account acctToUpdate = new Account();
            Id aggAccId = cd.Account_Name__c;
            if(accIdVsRollUp.containsKey(aggAccId)){
                acctToUpdate = accIdVsRollUp.get(aggAccId);                                                            
            }else {
                acctToUpdate.id = aggAccId;    
            } 
            //CR# 3665 changes Support Type to Premium Support
            //IBA-3554 : Commenting Code in order to have a single source of populating the Support Type on the account
            /*if(cd.Product_Name__c != null && cd.Product_Name__r.Name.contains('Premium Support') && cd.Premium_Support_ACV__c  > 0 && conDetailStatusSet.contains(cd.Contract_Detail_Status__c)){
                
                if((cd.Premium_Support_ACV__c) < 3000){
                    acctToUpdate.Support_Type__c = 'Premium Support';
                } else{
                    acctToUpdate.Support_Type__c = 'Premium Support Plus';
                }
            }*/
            //CR# 3665 changes updateFirstZDXContractDateonAccount and updateFirstZPAContractDateonAccount
            if(cd.Start_Date__c != null && setSKUCodes.contains(cd.Product_SKU__c) ){
                
                if((cd.Account_Name__r.First_ZDX_Contract_Date__c == null || cd.Account_Name__r.First_ZDX_Contract_Date__c > cd.Start_Date__c) && setZDXSKUCodes.contains(cd.Product_SKU__c) ){
                    acctToUpdate.First_ZDX_Contract_Date__c = cd.Start_Date__c;
                }
                if((cd.Account_Name__r.First_ZPA_Contract_Date__c == null || cd.Account_Name__r.First_ZPA_Contract_Date__c > cd.Start_Date__c)  && setZPASKUCodes.contains(cd.Product_SKU__c)){
                    acctToUpdate.First_ZPA_Contract_Date__c = cd.Start_Date__c;
                }

            }
            
            
            accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);
            zdxAdvAccIds.add(aggAccId);                                                          
            System.debug('ZIAAccList++'+acctToUpdate);
			//CR#4250 Start
            conDetailStatusSet.add('Pending Activation');
            conDetailStatusSet.add('Renewed');
            //if(conDetailStatusSet.contains(cd.Contract_Detail_Status__c)){
                if(!AccountIdContractDetailMap.containsKey(cd.Account_Name__c)){
                        AccountIdContractDetailMap.put(cd.Account_Name__c, new List<Contract_Detail__c>());
                    }
            	AccountIdContractDetailMap.get(cd.Account_Name__c).add(cd);
            //}
            //CR#4250 End
            
        }
        //CR#4250 and CR#4342 Start
        if(!AccountIdContractDetailMap.isEmpty()){
            for (Id acc : AccountIdContractDetailMap.keyset()) {
            	Decimal ZIAMRRUSD = 0.00;
                Decimal ZPAMRRUSD = 0.00;
                Decimal MRRUSD = 0.00;
                Decimal PPUBandwidth = 0.00;
                Decimal PPUCloudFirewall = 0.00;
                Decimal PPUCloudSandbox = 0.00;
                Decimal PPUDLP = 0.00;
                Decimal PPUNSS = 0.00;
                Decimal UserPurchasedBandwidthControl = 0.00;
                Decimal UsersPurchasedCloudFirewall = 0.00;
                Decimal UsersPurchasedCloudSandbox = 0.00;
                Decimal UsersPurchasedNSS = 0.00;
                Decimal UsersPurchasedZIAPlatform = 0.00;
                Decimal UsersPurchasedZPAPlatform = 0.00;
                Decimal PremiumSupportACVs = 0.00;
                Decimal RollUpofNSSFirewalls = 0.00;
                Decimal RollUpofNSSPlatform = 0.00;
                Decimal ActiveContract = 0.00;
                Decimal UsersPurchasedDLP = 0.00;
                for(Contract_Detail__c cd : AccountIdContractDetailMap.get(acc)){
                    if((cd.Contract_Detail_Status__c =='Active' || cd.Contract_Detail_Status__c =='Pending Renewal') && cd.Do_not_Aggregate__c == false){
                        if(cd.MRR_USD__c!=Null)
                            MRRUSD +=cd.MRR_USD__c;
                        if(cd.Zscaler_Product_Family__c=='ZIA' && cd.MRR_USD__c!=Null)
                            ZIAMRRUSD +=cd.MRR_USD__c;
                        if(cd.Zscaler_Product_Family__c=='ZPA' && cd.MRR_USD__c!=Null)
                            ZPAMRRUSD +=cd.MRR_USD__c;
                        if((cd.Product_SKU__c=='ZMAN-WEB-BAND' || cd.Product_SKU__c=='ZIA-BW-CTRL') && cd.Price_Per_User__c!=Null)
                            PPUBandwidth +=cd.Price_Per_User__c;
                        if((cd.Product_SKU__c=='ZFW-NG-WITH-LOG' || cd.Product_SKU__c=='ZIA-FIREWALL') && cd.Price_Per_User__c!=Null)
                            PPUCloudFirewall +=cd.Price_Per_User__c;
                        if((cd.Product_SKU__c=='ZSEC-WEB-ABA' || cd.Product_SKU__c=='ZIA-SANDBOX') && cd.Price_Per_User__c!=Null)
                            PPUCloudSandbox +=cd.Price_Per_User__c;
                        if((cd.Product_SKU__c=='ZDLP-WEB' || cd.Product_SKU__c=='ZIA-DLP-ENT') && cd.Price_Per_User__c!=Null)
                            PPUDLP +=cd.Price_Per_User__c;
                        if((cd.Product_SKU__c=='Z-LOGFEED' || cd.Product_SKU__c=='ZIA-NSS') && cd.Price_Per_User__c!=Null)
                            PPUNSS +=cd.Price_Per_User__c;
                        if((cd.Product_SKU__c=='ZMAN-WEB-BAND' || cd.Product_SKU__c=='ZIA-BW-CTRL' || cd.Product_SKU__c=='ZIA-TRANS-BUNDLE' || 
                            cd.Product_SKU__c=='ZIA-TRANS-EDITION' || cd.Product_SKU__c=='ZIA-ELA-BUNDLE' || cd.Product_SKU__c=='ZIA-ELA-EDITION' ||
                            cd.Product_SKU__c=='ZIA-BUS-BUNDLE' || cd.Product_SKU__c=='ZIA-BUS-EDITION' || cd.Product_SKU__c=='ZSUITE-WEBENT' ) && cd.Amount_USD__c >=0 && cd.Quantity__c!=Null)
                            UserPurchasedBandwidthControl +=cd.Quantity__c;
                        if((cd.Product_SKU__c=='ZFW-NG-WITH-LOG' || cd.Product_SKU__c=='ZIA-FIREWALL' || cd.Product_SKU__c=='ZIA-TRANS-BUNDLE' || 
                            cd.Product_SKU__c=='ZIA-TRANS-EDITION' || cd.Product_SKU__c=='ZIA-ELA-BUNDLE' || cd.Product_SKU__c=='ZIA-ELA-EDITION' ) && cd.Amount_USD__c >=0 && cd.Quantity__c!=Null)
                            UsersPurchasedCloudFirewall +=cd.Quantity__c;
                        if((cd.Product_SKU__c=='ZSEC-WEB-ABA' || cd.Product_SKU__c=='ZIA-SANDBOX' || cd.Product_SKU__c=='ZIA-TRANS-BUNDLE' || 
                            cd.Product_SKU__c=='ZIA-ELA-BUNDLE' || cd.Product_SKU__c=='ZIA-TRANS-EDITION' || cd.Product_SKU__c=='ZIA-ELA-EDITION' ) && cd.Amount_USD__c >=0 && cd.Quantity__c!=Null)
                            UsersPurchasedCloudSandbox +=cd.Quantity__c;
                        if((cd.Product_SKU__c=='Z-LOGFEED' || cd.Product_SKU__c=='ZIA-NSS' || cd.Product_SKU__c=='ZIA-BUS-BUNDLE' || cd.Product_SKU__c=='ZIA-ELA-EDITION' || cd.Product_SKU__c=='ZIA-BUS-EDITION' ||
                            cd.Product_SKU__c=='ZIA-TRANS-BUNDLE' || cd.Product_SKU__c=='ZIA-ELA-BUNDLE' || cd.Product_SKU__c=='ZIA-TRANS-EDITION' ) && cd.Amount_USD__c >=0 && cd.Quantity__c!=Null)
                            UsersPurchasedNSS +=cd.Quantity__c;
                        if(Cd.Zscaler_Product_Family__c!=Null && cd.Zscaler_Product_Family__c.contains('ZIA') && cd.Quantity__c!=Null && cd.Amount_USD__c >=0 && cd.Is_Bundle_SKU__c)
                            UsersPurchasedZIAPlatform +=cd.Quantity__c;
                        if(cd.Zscaler_Product_Family__c!=Null && cd.Zscaler_Product_Family__c.contains('ZPA') && cd.Quantity__c!=Null && cd.Amount_USD__c >=0 && cd.Is_Bundle_SKU__c)
                            UsersPurchasedZPAPlatform +=cd.Quantity__c;
                    }
                    if(cd.Premium_Support_ACV_Number__c!=Null && cd.Is_Contract_Active__c && conDetailStatusSet.contains(cd.Contract_Detail_Status__c)){
                        PremiumSupportACVs +=cd.Premium_Support_ACV_Number__c;
                    }
                    if(cd.Amount_USD__c >=0 && conDetailStatusSet.contains(cd.Contract_Detail_Status__c) && cd.Contract_Detail_Status__c !='Renewed'){
                        ActiveContract +=1;
                    }
                    if((cd.Product_SKU__c=='ZDLP-WEB' || cd.Product_SKU__c=='ZIA-DLP-ENT' || cd.Product_SKU__c=='ZIA-ELA-BUNDLE'|| cd.Product_SKU__c=='ZSUITE-WEBENT' || 
                        cd.Product_SKU__c=='ZIA-ELA-EDITION') && cd.Do_not_Aggregate__c == false && cd.Quantity__c!=Null && conDetailStatusSet.contains(cd.Contract_Detail_Status__c) && cd.Contract_Detail_Status__c !='Renewed' ){
                        UsersPurchasedDLP +=cd.Quantity__c;
                    }
                    if((cd.Product_SKU__c=='Z-LOGFEED-FW-MGMT' || cd.Product_SKU__c=='ZIA-NSS-LOGREC') && (cd.Contract_Detail_Status__c =='Active' || cd.Contract_Detail_Status__c =='Pending Renewal')){
                        RollUpofNSSFirewalls +=1;
                    }
                    if((cd.Product_SKU__c=='Z-LOGFEED-MGMT' || cd.Product_SKU__c=='ZIA-NSS-LOGREC' || cd.Product_SKU__c =='Z-LOGFEED-LIVE-MGMT') && (cd.Contract_Detail_Status__c =='Active' || cd.Contract_Detail_Status__c =='Pending Renewal')){
                        RollUpofNSSPlatform +=1;
                    }
                    
                }
                Account acctToUpdate = new Account();
                if(accIdVsRollUp.containsKey(acc)){
                	acctToUpdate = accIdVsRollUp.get(acc);                                                            
                }else {
                     acctToUpdate.id = acc;    
                }                                    
                acctToUpdate.MRR_ZIAs__c = ZIAMRRUSD;
                acctToUpdate.MRR_ZPAs__c = ZPAMRRUSD;
                acctToUpdate.Total_MRRs__c = MRRUSD;
                acctToUpdate.PPU_Bandwidth_Controls__c = PPUBandwidth;
                acctToUpdate.PPU_Cloud_Firewalls__c = PPUCloudFirewall;
                acctToUpdate.PPU_Cloud_Sandboxs__c = PPUCloudSandbox;
                acctToUpdate.PPU_DLPs__c = PPUDLP;
                acctToUpdate.PPU_NSSs__c = PPUNSS;
                acctToUpdate.Users_Purchased_Bandwidth_Control__c = UserPurchasedBandwidthControl;
                acctToUpdate.Users_Purchased_Cloud_Firewall__c = UsersPurchasedCloudFirewall;
                acctToUpdate.Users_Purchased_Cloud_Sandbox__c = UsersPurchasedCloudSandbox;
                acctToUpdate.Users_Purchased_NSS__c = UsersPurchasedNSS;
                acctToUpdate.Users_Purchased_ZIA_Platform__c = UsersPurchasedZIAPlatform;
                acctToUpdate.Users_Purchased_ZPA_Platform__c = UsersPurchasedZPAPlatform;
                acctToUpdate.Premium_Support_ACVs__c = PremiumSupportACVs;
                acctToUpdate.Roll_Up_of_NSS_Firewalls__c = RollUpofNSSFirewalls;
                acctToUpdate.Roll_Up_of_NSS_Platform__c = RollUpofNSSPlatform;
                acctToUpdate.Active_Contract__c = ActiveContract;
                acctToUpdate.Users_Purchased_DLP__c = UsersPurchasedDLP;
                accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);
                
        	}
        }
        System.debug('accIdVsRollUp '+accIdVsRollUp);
        //CR#4250 and CR#4342 End

        //CR# 2434 - OLD CODE
        /* List<ZPA_Connector_Count_matrix__mdt> connectorCountList = [SELECT Product_Codes__c,Quantity__c,Count__c FROM ZPA_Connector_Count_matrix__mdt];
        Map<String, ZPA_Connector_Count_matrix__mdt> productCodeToConnectorCountMap = new Map<String, ZPA_Connector_Count_matrix__mdt>();
        for (ZPA_Connector_Count_matrix__mdt zcc : connectorCountList) {
            for (String productCode : zcc.Product_Codes__c.split(',')) {
                productCodeToConnectorCountMap.put(productCode,zcc);
            }
        }
        System.debug('productCodeToConnectorCountMap>> '+ productCodeToConnectorCountMap);
        
        Map<Id,Decimal> accountToNoOfZPAConnectors = new  Map<Id,Decimal>();
        for (AggregateResult aggregateData :[SELECT SUM(Quantity__c) qty,Account_Name__c, Product_SKU__c
                                                FROM Contract_Detail__c 
                                                WHERE Account_Name__c IN :accList
                                                AND Active__c = TRUE AND ((Amount_USD__c > 0 AND Quantity__c > 0) OR (Amount_USD__c < 0 AND Quantity__c < 0))
                                                AND Product_SKU__c IN :productCodeToConnectorCountMap.KeySet()
                                                GROUP BY Account_Name__c, Product_SKU__c ORDER BY Account_Name__c DESC])
        {   
            String productCode = (String)aggregateData.get('Product_SKU__c');
            Id accountId = (id)aggregateData.get('Account_Name__c'); 
            if(productCodeToConnectorCountMap.containsKey(productCode)){
                Decimal productQuantity = (Decimal)aggregateData.get('qty');
                Decimal noOfEntitledZPAConnectors = accountToNoOfZPAConnectors.containsKey(accountId)? accountToNoOfZPAConnectors.get(accountId) : 0;

                Decimal baseQuantity = productCodeToConnectorCountMap.get(productCode).Quantity__c;
                Decimal count = productCodeToConnectorCountMap.get(productCode).Count__c;
                Decimal defaultCount = (productQuantity > 0) && (productQuantity < baseQuantity) ? count : 0;
                noOfEntitledZPAConnectors += (productQuantity/baseQuantity) >=1 ? Math.ceil((productQuantity/baseQuantity))*count : defaultCount;
                accountToNoOfZPAConnectors.put(accountId,noOfEntitledZPAConnectors);
            }

            Account acctToUpdate = new Account();
            if(accIdVsRollUp.containsKey(accountId)){
                acctToUpdate = accIdVsRollUp.get(accountId);
            } else {
                acctToUpdate.id = accountId;
            }
            acctToUpdate.Number_Of_Entitled_ZPA_Connectors__c = accountToNoOfZPAConnectors.containsKey(accountId)? accountToNoOfZPAConnectors.get(accountId) : acctToUpdate.Number_Of_Entitled_ZPA_Connectors__c;
            accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);
        }
        
        for(Account acc : accList){
            if(!accountToNoOfZPAConnectors.containsKey(acc.Id)){
                Account acctToUpdate = new Account();
                if(accIdVsRollUp.containsKey(acc.Id)){
                    acctToUpdate = accIdVsRollUp.get(acc.Id);
                } else {
                    acctToUpdate.id = acc.Id;
                }
                acctToUpdate.Number_Of_Entitled_ZPA_Connectors__c = 0;
                accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);
            }
        } */
        //CR# 2434 - OLD CODE
        //IBA-1645 - NEW CODE
        List<ZPA_Connector_Count_matrix__mdt> connectorCountList = [SELECT Product_Codes__c,Quantity__c,Count__c,Is_Bundle__c FROM ZPA_Connector_Count_matrix__mdt];
        Map<String, ZPA_Connector_Count_matrix__mdt> productCodeToConnectorCountMap = new Map<String, ZPA_Connector_Count_matrix__mdt>();
        Set<String> bundleProductCodes = new Set<String>();
        for (ZPA_Connector_Count_matrix__mdt zcc : connectorCountList) {
            for (String productCode : zcc.Product_Codes__c.split(',')) {
                productCodeToConnectorCountMap.put(productCode,zcc);
                if(zcc.Is_Bundle__c){
                    bundleProductCodes.add(productCode);
                }
            }
        }
        System.debug('productCodeToConnectorCountMap>> '+ productCodeToConnectorCountMap);
        
        Map<Id,Decimal> accountToNoOfZPAConnectors = new  Map<Id,Decimal>();

        Map<Id, Map<String, Decimal>> accountToProductQtyMap = new Map<Id, Map<String, Decimal>>();
        /* for (AggregateResult aggregateData :[SELECT SUM(Quantity__c) qty,Account_Name__c, Product_SKU__c
                                                FROM Contract_Detail__c 
                                                WHERE Account_Name__c IN :accList
                                                AND Active__c = TRUE AND ((Amount_USD__c > 0 AND Quantity__c > 0) OR (Amount_USD__c < 0 AND Quantity__c < 0))
                                                AND Product_SKU__c IN :productCodeToConnectorCountMap.KeySet()
                                                GROUP BY Account_Name__c, Product_SKU__c ORDER BY Account_Name__c DESC])
        {   
            String productCode = (String)aggregateData.get('Product_SKU__c');
            Id accountId = (id)aggregateData.get('Account_Name__c'); 

            if(productCodeToConnectorCountMap.containsKey(productCode)){
                Map<String, Decimal> productQtyMap = new Map<String, Decimal>();
                Decimal productQuantity = (Decimal)aggregateData.get('qty');
                productQtyMap.put(productCode, productQuantity);                
                if(accountToProductQtyMap.containsKey(accountId)){
                    accountToProductQtyMap.get(accountId).put(productCode, productQuantity);
                } else {
                    accountToProductQtyMap.put(accountId,productQtyMap);
                }
            }
        } */

        for (Contract_Detail__c contractDetail :[SELECT Quantity__c,Account_Name__c, Product_SKU__c,List_Price__c,NetSuite_List_Price__c,List_Total__c
                                                FROM Contract_Detail__c 
                                                WHERE Account_Name__c IN :accList
                                                AND Active__c = TRUE AND ((Amount_USD__c > 0 AND Quantity__c > 0) OR (Amount_USD__c < 0 AND Quantity__c < 0))
                                                AND Product_SKU__c IN :productCodeToConnectorCountMap.KeySet()
                                                ORDER BY Account_Name__c DESC])
        {   
            String productCode = contractDetail.Product_SKU__c;
            Id accountId = contractDetail.Account_Name__c; 
            Decimal quantity = contractDetail.Quantity__c != null?contractDetail.Quantity__c:0;
            if(bundleProductCodes.contains(productCode)){quantity = contractDetail.List_Total__c;}
            if(productCodeToConnectorCountMap.containsKey(productCode)){
                if(accountToProductQtyMap.containsKey(accountId)){
                    Map<String, Decimal> productQtyMap = accountToProductQtyMap.get(accountId);
                    if(productQtyMap.containsKey(productCode)){
                        Decimal totalQuantity = productQtyMap.get(productCode);
                        totalQuantity += quantity;
                        productQtyMap.put(productCode,totalQuantity);
                        accountToProductQtyMap.put(accountId, productQtyMap);
                    } else {
                        productQtyMap.put(productCode,quantity);
                        accountToProductQtyMap.put(accountId, productQtyMap);
                    }
                } else {
                    accountToProductQtyMap.put(accountId, new Map<String, Decimal> {productCode => quantity});
                }                
            }
        }

        if(!accountToProductQtyMap.isEmpty()){
            for (Id accountId : accountToProductQtyMap.keySet()) {
                Boolean zpaBusPro = false;
                for(String productCode : accountToProductQtyMap.get(accountId).keySet()){
                    if(bundleProductCodes.contains(productCode)){
                        Decimal productQuantity = accountToProductQtyMap.get(accountId).get(productCode);
                        Decimal baseQuantity = productCodeToConnectorCountMap.get(productCode).Quantity__c;
                        Decimal totalConnectorsToAdd = 0;
                        if(productCode.equalsIgnoreCase('ZPA-BUS') && accountToProductQtyMap.get(accountId).containsKey('ZPA-PRO') && !zpaBusPro){
                            Decimal totalListPriceZPAPRO = accountToProductQtyMap.get(accountId).get('ZPA-PRO');
                            totalConnectorsToAdd = Math.ceil((productQuantity + totalListPriceZPAPRO)/baseQuantity);
                            zpaBusPro = true;
                        }else if(productCode.equalsIgnoreCase('ZPA-PRO') && accountToProductQtyMap.get(accountId).containsKey('ZPA-BUS') && !zpaBusPro){
                            Decimal totalListPriceZPABUS = accountToProductQtyMap.get(accountId).get('ZPA-BUS');
                            totalConnectorsToAdd = Math.ceil((productQuantity + totalListPriceZPABUS)/baseQuantity);
                            zpaBusPro = true;
                        }else if(!zpaBusPro){
                            totalConnectorsToAdd = Math.ceil(productQuantity/baseQuantity);
                        }
                        Decimal noOfEntitledZPAConnectors = accountToNoOfZPAConnectors.containsKey(accountId)? accountToNoOfZPAConnectors.get(accountId) : 0;
                        noOfEntitledZPAConnectors += totalConnectorsToAdd;
                        accountToNoOfZPAConnectors.put(accountId,noOfEntitledZPAConnectors);
                    } else if(productCodeToConnectorCountMap.containsKey(productCode)){
                        Decimal productQuantity = accountToProductQtyMap.get(accountId).get(productCode);
                        String zpaBusEditionPromo = 'ZPA-BUS-EDITION-100USERS-PROMO';
                        if ((productCode.equalsIgnoreCase('ZPA-BUS-EDITION') && accountToProductQtyMap.get(accountId).containsKey(zpaBusEditionPromo)) || productCode.equalsIgnoreCase(zpaBusEditionPromo)) {
                            Decimal promoQuantity = accountToProductQtyMap.get(accountId).get(zpaBusEditionPromo);
                            Decimal baseQuantity = productCodeToConnectorCountMap.get(zpaBusEditionPromo).Quantity__c;
                            Decimal count = productCodeToConnectorCountMap.get(zpaBusEditionPromo).Count__c;
                            Decimal defaultCount = (promoQuantity > 0) && (promoQuantity < baseQuantity) ? count : 0;
                            if(productCode.equalsIgnoreCase(zpaBusEditionPromo)){productQuantity=0;}
                            productQuantity += (promoQuantity/baseQuantity) >=1 ? Math.ceil((promoQuantity/baseQuantity))*count : defaultCount;
                        }
                        //if(!productCode.equalsIgnoreCase(zpaBusEditionPromo)){
                        if(productCode.equalsIgnoreCase(zpaBusEditionPromo)){
                            if(accountToProductQtyMap.get(accountId).containsKey('ZPA-BUS-EDITION')){
                                continue;
                            } else {
                                productCode = 'ZPA-BUS-EDITION';
                            }
                        }
                        Decimal noOfEntitledZPAConnectors = accountToNoOfZPAConnectors.containsKey(accountId)? accountToNoOfZPAConnectors.get(accountId) : 0;                            
                        Decimal baseQuantity = productCodeToConnectorCountMap.get(productCode).Quantity__c;
                        Decimal count = productCodeToConnectorCountMap.get(productCode).Count__c;
                        Decimal defaultCount = (productQuantity > 0) && (productQuantity < baseQuantity) ? count : 0;
                        noOfEntitledZPAConnectors += (productQuantity/baseQuantity) >=1 ? Math.ceil((productQuantity/baseQuantity))*count : defaultCount;
                        accountToNoOfZPAConnectors.put(accountId,noOfEntitledZPAConnectors);
                        //}
                    }
                }
    
                Account acctToUpdate = new Account();
                if(accIdVsRollUp.containsKey(accountId)){
                    acctToUpdate = accIdVsRollUp.get(accountId);
                } else {
                    acctToUpdate.id = accountId;
                }
                acctToUpdate.Number_Of_Entitled_ZPA_Connectors__c = accountToNoOfZPAConnectors.containsKey(accountId)? accountToNoOfZPAConnectors.get(accountId) : acctToUpdate.Number_Of_Entitled_ZPA_Connectors__c;
                accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);
            }
        }
        
        for(Account acc : accList){
            if(!accountToNoOfZPAConnectors.containsKey(acc.Id)){
                Account acctToUpdate = new Account();
                if(accIdVsRollUp.containsKey(acc.Id)){
                    acctToUpdate = accIdVsRollUp.get(acc.Id);
                } else {
                    acctToUpdate.id = acc.Id;
                }
                acctToUpdate.Number_Of_Entitled_ZPA_Connectors__c = 0;
                accIdVsRollUp.put(acctToUpdate.id, acctToUpdate);
            }
        }
        //IBA-1645

        //CR# 3665 Account Extension changes
        List<Account_Extension__c> accExtensionListToUpdate = new List<Account_Extension__c>();
        List<Account_Extension__c> accountExtensionList = [Select id,Account__c,Account__r.CSM_Name_New__c,Account__r.CSM_Name_2__c, Account__r.Type,Account__r.Account_Renewable_ACV__c, Customer_Success_Engagement__c, Converted_To_Customer_On__c,Override_CS_Engagement__c from Account_Extension__c where Account__c IN :accList  AND Account__r.Type = 'Customer'];
        //Added Override_CS_Engagement__c check for CR#4078 
        for (Account_Extension__c accExt : accountExtensionList) {
            if(accExt.Override_CS_Engagement__c == false && accExt.Account__r.Account_Renewable_ACV__c != null && accExt.Account__r.Account_Renewable_ACV__c>=200000 && accExt.Customer_Success_Engagement__c != 'high'){
                accExt.Customer_Success_Engagement__c = 'high';
                accExtensionListToUpdate.add(accExt);
            } else if(accExt.Override_CS_Engagement__c == false && accExt.Account__r.Account_Renewable_ACV__c != null && accExt.Account__r.Account_Renewable_ACV__c<200000 && accExt.Customer_Success_Engagement__c != 'tech'){
                accExt.Customer_Success_Engagement__c = 'tech';
                accExtensionListToUpdate.add(accExt);
            }            
            
        }
        if(!accExtensionListToUpdate.isEmpty())
        {
            TriggerUtility.setAccountExtension();
            try{
                update accExtensionListToUpdate;
            }
            catch(Exception e){
                ZscalerErrorLogsUtility.insertlogsForAsync('UpdateContractDetailsToAccountBatch', 'execute', 'Async Apex',userInfo.getUserId(), 'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
            }
        }
        


        //Final Account Update
        List<Account> accountToUpdateList = new List<Account> ();
        TriggerUtility.SkipAccTriggerExecuted();
        accountToUpdateList.addAll(accIdVsRollUp.values());
        System.debug('Final=='+accountToUpdateList);
        if (!accountToUpdateList.isEmpty()) {
           try{
                UPDATE accountToUpdateList;
            }
            catch(Exception e){
                ZscalerErrorLogsUtility.insertlogsForAsync('UpdateContractDetailsToAccountBatch', 'execute', 'Async Apex',userInfo.getUserId(),'Sales cloud', e.getStackTraceString(), e.getMessage(), e.getTypeName());
            }
        }
        
        
        TriggerUtility.SkipAccTriggerReset();        
    }
    public void finish(Database.BatchableContext BC){
       
        this.zb.callFinish(BC);
        
    }
}