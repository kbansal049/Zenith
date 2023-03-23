public class PurchaseInvoiceBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    ZscalerBatchFramework zb = new ZscalerBatchFramework('PurchaseInvoiceBatch');
		
    public Database.QueryLocator start(Database.BatchableContext context) {
        this.zb.callStart();
        String query = 'select id,ActualCost from campaign';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Campaign> records){
        this.zb.callExecute(records[0]?.Id, records.size());
       
        List<Campaign> lst = new List<Campaign>();
        List<Purchase_Invoice__c> lst1= [select id, Amount__c, Campaign__c from Purchase_Invoice__c where Campaign__c in :records];
		Map<Id,List<Purchase_Invoice__c>> mapCampToInvoice = new Map<Id,List<Purchase_Invoice__c>>();
			for(Purchase_Invoice__c pI : lst1)  {
    			if(!mapCampToInvoice.containsKey(pI.Campaign__c))     {
        			mapCampToInvoice.put(pI.Campaign__c,new List<Purchase_Invoice__c>());
    			}
   			 mapCampToInvoice.get(pI.Campaign__c).add(PI);
			}
        
        	for(Id cmpId : mapCampToInvoice.KeySet())  {
    			List<Purchase_Invoice__c> lstPi = mapCampToInvoice.get(cmpId);
    			Double totalAmount = 0;
    			
                for(Purchase_Invoice__c pi : lstPi)  {
        			totalAmount += pi.Amount__c;
    			}
    		
                Campaign ci = new Campaign();
    			ci.Id = cmpId;
    			ci.ActualCost = totalAmount;
    			lst.add(ci);
			}
        System.debug('listt'+lst);
		update lst;
        
        /*list<Campaign> cmplist = new list<campaign>();
        list<id> cmpidlist = new list<id>();
        for(Campaign cmp: records){
            cmpidlist.add(cmp.id);
        }*/
        
        //Map<id,Purchase_Invoice__c> purchasemap = new Map<id,Purchase_Invoice__c>([select id,amount__c from Purchase_Invoice__c where amount__c!=null and Campaign__c in:cmpidlist]);
        /*for(Campaign cmp:records){
            
        	//list<Purchase_Invoice__c> purchaselist = [select id,amount__c from Purchase_Invoice__c where amount__c!=null and Campaign__c =:cmp.id];
            if(cmp.ActualCost == null){
                cmp.ActualCost = 0;
            }
            
            //object o = purchasemap.get(cmp.id);
            for(Id key:purchasemap.keySet()){
                if(cmp.id == key){
                	List<Purchase_Invoice__c> purchaselist = new List<Purchase_Invoice__c>();
            		purchaselist.add(purchasemap.get(cmp.id));	
                    for(Purchase_Invoice__c p:purchaselist){
               				cmp.ActualCost+=p.Amount__c;
            			}    
                }
                
            }
            
        	cmplist.add(cmp);
        }
        update cmplist;*/
    }
    
    public void finish(Database.BatchableContext bc){
        this.zb.callFinish(bc);
        // execute any post-processing operations
    }

}