public class trg_ProvProductHandler {
    
    public static void ZDXPresentInPrg(List<Provisioning_Product__c> prvProd){
        system.debug('cominginsideproducttrigger***');
        set<Id> prgProductIds = new set<Id>();
        set<Id> productIds = new set<Id>();
        set<Id> updateIds = new set<Id>();
        Map<Id,String> requiredLicensesMap = new Map<Id,String>();
        Set<String> requiredLicenses = new Set<String>();
        List<Provisioning_Group__c> updateList = new List<Provisioning_Group__c>();
        if(prvProd !=null && prvProd.size()>0){
            for(Provisioning_Product__c prd : prvProd){
            	prgProductIds.add(prd.Id);    
            }   
        }
        List<Provisioning_Product__c> provisioningProducts = [SELECT Id, Product__c, Provisioning_Group__r.Product_Line__c, Provisioning_Group__r.Cross_Platform_Selected__c FROM Provisioning_Product__c WHERE Id IN : prgProductIds];
        for(Provisioning_Product__c prd : provisioningProducts){
            if(prd.Provisioning_Group__r.Product_Line__c == 'ZIA' && prd.Provisioning_Group__r.Cross_Platform_Selected__c == FALSE){
            	productIds.add(prd.Product__c);	    
            }    
        }
        if(productIds != NULL && !productIds.isEmpty()){
        	List<Product_License__c> licenseList = new List<Product_License__c>([SELECT ID,License_Product_Line__c,Product__c FROM Product_License__c WHERE Product__c IN: productIds]);
            for(Product_License__c pl : licenseList){
                requiredLicensesMap.put(pl.Product__c,pl.License_Product_Line__c);   
            }
            for(Provisioning_Product__c prd : provisioningProducts){
                if(requiredLicensesMap!= NULL && !requiredLicensesMap.isempty() && requiredLicensesMap.containsKey(prd.Product__c)){
                	string productlicensestring = requiredLicensesMap.get(prd.Product__c);
                    if(productlicensestring != NULL && productlicensestring.contains('ZDX')){
                    	updateIds.add(prd.Provisioning_Group__c);		    
                    }
                }
            }
            if(updateIds != NULL && !updateIds.isEmpty()){
                for(id prgId : updateIds){
                	Provisioning_Group__c prg = new Provisioning_Group__c(Id = prgId);
                    prg.Is_ZDX_Present__c = true;
                    updateList.add(prg);
                }    
            }
            if(!updateList.isEmpty() && updateList != NULL){
                TriggerHandler.bypass('ProvisioningGroupTriggerHandler');
                try{
                    update updateList;
                }catch(Exception ex){
                    ProvisioningErrorHandler.exceptionHandler('trg_ProvProductHandler','ZDXPresentInPrg',ex);
                }
                TriggerHandler.clearByPass('ProvisioningGroupTriggerHandler');
            }
        }
    }
    
    public static void afterinsert(List<Provisioning_Product__c> prvProd) {
        ZDXPresentInPrg(prvProd);
        if(prvProd !=null && prvProd.size()>0){
            map<String,String> mapProvProdwithPG = new map<String,String>();
             map<String,Set<Id>> mapProvProdwithPGSet = new map<String,Set<Id>>();
            
            for(Provisioning_Product__c obj :prvProd ){
                if(obj.Product__c !=null && obj.Provisioning_Group__c !=null){
                    if(obj.Product__c !=null && obj.Provisioning_Group__c !=null){
                    mapProvProdwithPG.put(obj.Product__c,obj.Provisioning_Group__c);
                }
                    Set<Id> tempPgSet = new Set<Id>();
                    if(mapProvProdwithPGSet.containskey(obj.Product__c) && mapProvProdwithPGSet.get(obj.Product__c) !=null ){
                        tempPgSet = mapProvProdwithPGSet.get(obj.Product__c);
                        tempPgSet.add(obj.Provisioning_Group__c);
                         mapProvProdwithPGSet.put(obj.Product__c,tempPgSet);
                    }
                    else{
                        tempPgSet.add(obj.Provisioning_Group__c);
                    mapProvProdwithPGSet.put(obj.Product__c,tempPgSet);
                    }
                }
            }
            System.debug('mapProvProdwithPGSet=='+mapProvProdwithPGSet);
            if(mapProvProdwithPGSet!=null && mapProvProdwithPGSet.size()>0){
                
                Set<String> proIdzSet = new Set<String>();
                Set<Id> NSSpgToupdate = new Set<Id>();
                List<Product_License__c> plList = [Select ID,Name,Product__c,Provisioning_License__c,POV_Quantity__c,License_SKU__c,Product_SKU_Code__c,License_Product_Line__c,
                                                   License_Based_On__c,License__c,Is_JIRA_Ticket_Required__c
                                                   from Product_License__c where License__c != null and Product__c != null and Product__c in : mapProvProdwithPGSet.keyset()];
                System.debug('plList=='+plList.size());
                if(plList !=null && plList.size()>0){
                    //
                    for(Product_License__c pl : plList){
                        System.debug('Is_JIRA_Ticket_Required__c==='+pl.Is_JIRA_Ticket_Required__c);
                        if(pl.Is_JIRA_Ticket_Required__c)
                            proIdzSet.add(pl.Product__c);
                    }
                    if(proIdzSet !=null && proIdzSet.size()>0){
                        Set<Id> pglistToupdate = new Set<Id>();
                        for(String pr :proIdzSet ){
                            if( mapProvProdwithPGSet.containsKey(pr) && mapProvProdwithPGSet.get(pr)!=null){
                                System.debug('mapProvProdwithPGSet.get(pr)=='+mapProvProdwithPGSet.get(pr));
                                pglistToupdate.addAll(mapProvProdwithPGSet.get(pr));
                            }
                        }
                        if(pglistToupdate !=null && pglistToupdate.size()>0)
                            updatePG(pglistToupdate);
                        //update pglistToupdate;
                    }
                }
                
                
                // for NSS code
                List<String> lstSku = System.label.Cloud_NSS_SKU_s.split(';');
                System.debug('lstSku== from label '+lstSku);
                List<product2> lstprod = [select id,name,productcode from Product2 where Id In: mapProvProdwithPG.keyset() ];
                System.debug('lstprod=='+lstprod);
                if(lstprod !=null && lstprod.size()>0){
                    for(Product2 prd: lstprod){
                        System.debug(lstSku.contains(prd.productcode)+'==='+mapProvProdwithPG.get(prd.id));
                        if(lstSku.contains(prd.productcode) && mapProvProdwithPG.get(prd.id)!=null 
                           && mapProvProdwithPG.containskey(prd.id)){
                            NSSpgToupdate.add(mapProvProdwithPG.get(prd.id));
                        }
                    }
                    System.debug('NSSpgToupdate=='+NSSpgToupdate);
                    if(NSSpgToupdate !=null && NSSpgToupdate.size()>0){
                         updateNSSPG(NSSpgToupdate);
                    }
                }
                
            }
        }
    }
    
    @future
    public static void updateNSSPG(Set<Id> pglist)
    {
        System.debug('Inside updateNSSPG ');
        List<Provisioning_Group__c> lstPg = new List<Provisioning_Group__c>();
        lstPg =[select id,Name,Owner.Name,Owner.email,Owner.Username,Is_Jira_Ticket_Required__c, opportunity__r.SE_Name__r.email
                from Provisioning_Group__c where id IN: pglist];
        if(lstPg !=null && lstPg.size()>0){
            for(Provisioning_Group__c pg: lstPg){
                pg.has_Cloud_NSS__c = true;
            }
            try{
                update lstPg;
            }catch(Exception ex){
                ProvisioningErrorHandler.exceptionHandler('trg_ProvProductHandler','updateNSSPG',ex);
            }
            // update pglist;
        }
    }
    
    @future
    public static void updatePG(Set<Id> pglist)
    {
        List<Provisioning_Group__c> lstPg = new List<Provisioning_Group__c>();
        for(Id pgId: pglist){
            Provisioning_Group__c pg = new Provisioning_Group__c();
            pg.Is_Jira_Ticket_Required__c = true;
            pg.Id = pgId;
            lstPg.add(pg);
        }
        if(lstPg !=null && lstPg.size()>0){
            try{
                update lstPg;
            }catch(Exception ex){
                ProvisioningErrorHandler.exceptionHandler('trg_ProvProductHandler','updatePG',ex);
            }
        }
        // update pglist;
    } 
    
}