public class OpportunityLineTriggerHandler {
    
    public static void triggerEventHandler(List<OpportunityLineItem> newOLIs,Map<id,OpportunityLineItem> oldOLIs){
        if(trigger.isafter){
            if(trigger.isInsert){
               afterInsertTriggerEventHandler(newOLIs);
            }
            else if(trigger.isUpdate){
                 afterUpdateTriggerEventHandler(newOLIs,oldOLIs);
            }
        }
    }//End of method-triggerEventHandler
    public static void afterInsertTriggerEventHandler(List<OpportunityLineItem> newOLIs){
       Set<Id> optIds = new Set<id>();
        for(OpportunityLineItem OLI :newOLIs){
               
                    optIds.add(OLI.opportunityId);
                
        }
        if(!optIds.isEmpty()){
            Set_OLISalePrice.setOLIPrice(optIds);
        }
    }
    public static void afterUpdateTriggerEventHandler(List<OpportunityLineItem> newOLIs,Map<Id,OpportunityLineItem> oldOLIs){
       Set<Id> optIds = new Set<id>();
        for(OpportunityLineItem OLI :newOLIs){
  
      
           Double UnitPrice = OLI.ACV_New__c!=NULL &&  OLI.ACV_New__c!=0?OLI.ACV_New__c:0;
           if(OLI.ACV_New__c!=null  &&  OLI.ACV_New__c!=0){
            UnitPrice=OLI.Discount!=NULL ?(OLI.ACV_New__c)/((OLI.Quantity-OLI.Quantity*OLI.Discount)):(OLI.ACV_New__c)/(OLI.Quantity);
            }
            if(OLI.TotalPrice!= oldOLIs.get(OLI.id).TotalPrice || OLI.UnitPrice!=UnitPrice ){
                optIds.add(OLI.opportunityId);
            }
        }
        if(!optIds.isEmpty()){
            Set_OLISalePrice.setOLIPrice(optIds);
        }
    }//
}