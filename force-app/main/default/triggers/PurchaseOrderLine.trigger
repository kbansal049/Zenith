/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   23-02-2022   Mahesh T.    Initial Version CR#4244
*/
trigger PurchaseOrderLine on Purchase_Order_Line__c (after insert,after update,after delete) {
    
    

     Purchase_Order_Line__c[] objects = null;   

     if (Trigger.isDelete) {
         objects = Trigger.old;
     } else {
        objects = Trigger.new;
     }
    list<Purchase_Order_Line__c> l1 = new list<Purchase_Order_Line__c>();
    for ( Purchase_Order_Line__c campid:objects){
        if(campid.Purchase_Order_Line_Campaign__c!=null){
          l1.add(campid);    
        }
    }
     LREngine.Context ctx = new LREngine.Context(Campaign.SobjectType, // parent object
                                            Purchase_Order_Line__c.SobjectType,  // child object
                                            Schema.SObjectType.Purchase_Order_Line__c.fields.Purchase_Order_Line_Campaign__c // relationship field name
                                            );     
     ctx.add(
            new LREngine.RollupSummaryField(Schema.SObjectType.Campaign.fields.PO_VC_Amount__c,
                                            Schema.SObjectType.Purchase_Order_Line__c.fields.Purchase_Order_Line_Amount_USD__c,
                                            LREngine.RollupOperation.Sum 
                                         ));                                       
     Sobject[] masters = LREngine.rollUp(ctx, l1);    

     update masters;


}