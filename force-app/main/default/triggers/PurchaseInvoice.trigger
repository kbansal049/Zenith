trigger PurchaseInvoice on Purchase_Invoice__c (after insert,after update,after delete) {
  
     Purchase_Invoice__c[] objects = null;   

     if (Trigger.isDelete) {
         objects = Trigger.old;
     } else {
        objects = Trigger.new;
     }
    list<Purchase_Invoice__c> l1 = new list<Purchase_Invoice__c>();
    for ( Purchase_Invoice__c campid:objects){
        if(campid.Campaign__c!=null){
          l1.add(campid);    
        }
    }
     LREngine.Context ctx = new LREngine.Context(Campaign.SobjectType, // parent object
                                            Purchase_Invoice__c.SobjectType,  // child object
                                            Schema.SObjectType.Purchase_Invoice__c.fields.Campaign__c // relationship field name
                                            );     
     ctx.add(
            new LREngine.RollupSummaryField(Schema.SObjectType.Campaign.fields.ActualCost,
                                            Schema.SObjectType.Purchase_Invoice__c.fields.Amount__c,
                                            LREngine.RollupOperation.Sum 
                                         ));                                       
     Sobject[] masters = LREngine.rollUp(ctx, l1);    
    //for 
     update masters;
}