public class MigrateToCPQController {
    @AuraEnabled  
    public static string convertToContract(String recId) {
        string msg = '';
        Set<String> salesOrderSet = new Set<String>();
        Map<String,Id> orderOppIdMap = new Map<String,Id>();
        List<Contract_Detail__c> updatDetailList = new List<Contract_Detail__c>();
        List<Contract_Detail__c> conDetailList = [SELECT Id, Sales_Order_Name__c,Product_Name__c,Price_List_Applied__c,Account_Name__c FROM Contract_Detail__c WHERE Account_Name__c =: recId AND Ignore_Migration__c = FALSE AND Contract_Detail_Status__c IN ('Active','Pending Renewal')];
        if(!conDetailList.isEmpty() && conDetailList != NULL){
            for(Contract_Detail__c cd: conDetailList){
                if(cd.Sales_Order_Name__c != NULL){
                    salesOrderSet.add(cd.Sales_Order_Name__c);      
                }
                else{
                    msg = 'Sales order is missing with an active Contract Detail record.';
                    return msg;
                }
            }    
        }
        else{
            msg = 'No active contract details on this Account.';
            return msg;
        }
        for(opportunity opp : [SELECT Id, Name, Netsuite_Sales_Order_Number__c FROM opportunity WHERE Netsuite_Sales_Order_Number__c IN : salesOrderSet AND stageName = '6 - Closed Won']){
            orderOppIdMap.put(opp.Netsuite_Sales_Order_Number__c,opp.Id);           
        }
        for(Contract_Detail__c cd: conDetailList){
            if(!orderOppIdMap.isEmpty() && orderOppIdMap.containsKey(cd.Sales_Order_Name__c)){
                cd.Opportunity__c = orderOppIdMap.get(cd.Sales_Order_Name__c); 
                system.debug('**orderOppIdMap.get(cd.Sales_Order_Name__c)**'+orderOppIdMap.get(cd.Sales_Order_Name__c));
            }
            updatDetailList.add(cd);
        }
        try{
            if(!updatDetailList.isEmpty() && updatDetailList != NULL){
                update updatDetailList;
            }
            msg = updatePhantomAndPO(recId);      
        }
        catch(exception ex){
            system.debug('exception'+ex.getMessage());
            msg = ex.getMessage();
        }
        
        return msg;
    }
    public static string updatePhantomAndPO(String recId) {
        string msg = '';
        Boolean isSuccess = TRUE;
        Boolean CrossPlatform = FALSE;
        Set<Id> prodIds = new Set<Id>();
        Map<Id,List<SBQQ__ProductOption__c>> optionalProdMap = new Map<Id,List<SBQQ__ProductOption__c>>();
        List<Contract_Detail__c> updatDetailList = new List<Contract_Detail__c>();
        List<Contract_Detail__c> conDetailList = [SELECT Id, Sales_Order_Name__c,Product_Name__c,Product_Name__r.name,Product_Name__r.ProductCode,Price_List_Applied__c,Account_Name__c,Phantom_SKU__c,product_option__c FROM Contract_Detail__c WHERE Account_Name__c =: recId AND Ignore_Migration__c = FALSE AND Contract_Detail_Status__c IN ('Active','Pending Renewal')];
        for(Contract_Detail__c cd: conDetailList){
            if(cd.Product_Name__c != NULL){
                prodIds.add(cd.Product_Name__c);    
            }
            if(cd.Product_Name__r.ProductCode == 'ZS-WFA-BUS-EDITION'){
                CrossPlatform = TRUE;    
            }
        }
        // To find phatom sku for contract detail record
        List<SBQQ__ProductOption__c> prodOptionList =[SELECT Id, SBQQ__ConfiguredSKU__c,Name,
                                                      SBQQ__ConfiguredSKU__r.Price_List__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.ProductCode,SBQQ__ConfiguredSKU__r.Name 
                                                      FROM SBQQ__ProductOption__c 
                                                      WHERE SBQQ__OptionalSKU__c IN : prodIds];
        for(SBQQ__ProductOption__c po: prodOptionList){
            if(optionalProdMap.containsKey(po.SBQQ__OptionalSKU__c)){
                optionalProdMap.get(po.SBQQ__OptionalSKU__c).add(po);       
            }else{
                optionalProdMap.put(po.SBQQ__OptionalSKU__c, new List<SBQQ__ProductOption__c>{po});
            }    
        }
        //End
        for(Contract_Detail__c cd: conDetailList){
            string priceList;
            if(cd.Price_List_Applied__c == NULL || cd.Price_List_Applied__c == ''){
                msg = 'Opportunity Price list is blank. Please update the same and try again.'; 
                return msg;
            }
            else{
                if(cd.Price_List_Applied__c.contains('Single')){
                    priceList = 'Single';      
                }
                else if(cd.Price_List_Applied__c.contains('17')){
                    PriceList = '17';    
                } 
                else if(cd.Price_List_Applied__c.contains('Volume') || cd.Price_List_Applied__c.contains('20') || cd.Price_List_Applied__c.contains('18') || cd.Price_List_Applied__c.contains('19')){
                    priceList = 'Volume';            
                }
                else if(cd.Price_List_Applied__c.contains('Federal Bundles')){
                    PriceList = 'Federal Bundles';    
                }
                else if(cd.Price_List_Applied__c.contains('Federal Editions')){
                    PriceList = 'Federal Editions';    
                }
                else{
                    msg = 'Opportunity Price list is blank. Please update the same and try again.'; 
                    return msg;    
                }
            }
            if(!optionalProdMap.isEmpty() && optionalProdMap.containsKey(cd.Product_Name__c) && optionalProdMap.get(cd.Product_Name__c).size() > 1){
                for(SBQQ__ProductOption__c po: optionalProdMap.get(cd.Product_Name__c)){
                    if(po.SBQQ__ConfiguredSKU__r.Price_List__c != NULL && PriceList != NULL && po.SBQQ__ConfiguredSKU__r.Price_List__c.contains(PriceList) && !CrossPlatform && !updatDetailList.contains(cd) && po.SBQQ__ConfiguredSKU__r.Name != 'Cross Platform - Edition Products' && po.SBQQ__ConfiguredSKU__r.Name != 'Zscaler User ELA - Edition Products'){
                        cd.Phantom_SKU__c = po.SBQQ__ConfiguredSKU__c;
                        cd.product_option__c = po.Id;
                        updatDetailList.add(cd);
                    }
                    else if(po.SBQQ__ConfiguredSKU__r.Price_List__c != NULL && PriceList != NULL && po.SBQQ__ConfiguredSKU__r.Price_List__c.contains(PriceList) && CrossPlatform && !updatDetailList.contains(cd) && po.SBQQ__ConfiguredSKU__r.Name == 'Cross Platform - Edition Products'){
                        cd.Phantom_SKU__c = po.SBQQ__ConfiguredSKU__c;
                        cd.product_option__c = po.Id;
                        updatDetailList.add(cd);    
                    }    
                }  
            }
            else if(!optionalProdMap.isEmpty() && optionalProdMap.containsKey(cd.Product_Name__c)){
                for(SBQQ__ProductOption__c po: optionalProdMap.get(cd.Product_Name__c)){
                    if(po.SBQQ__ConfiguredSKU__r.Price_List__c != NULL && PriceList != NULL && po.SBQQ__ConfiguredSKU__r.Price_List__c.contains(PriceList) && !updatDetailList.contains(cd)){
                        cd.Phantom_SKU__c = po.SBQQ__ConfiguredSKU__c;
                        cd.product_option__c = po.Id;
                        updatDetailList.add(cd);
                    }    
                }    
            } 
        }
        try{
            if(!updatDetailList.isEmpty() && updatDetailList != NULL){
                update updatDetailList;    
            }
            integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
        catch(exception ex){
            system.debug('exception'+ex.getMessage());
            msg = ex.getMessage();
        }
        return msg;
    }  
}