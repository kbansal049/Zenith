/*********************************************************************************
** Class Name: Set_OLISalePrice 
**
** Description: It's a trigger written mainly to handle the custom 
                functionalities on Opportunity LineIte.
**
** author     : Dilowar
*********************************************************************************/
public class Set_OLISalePrice{
    public static boolean blnRunOnce = false;
    
        public static void setOLIPrice(Set<Id> oppoIds){
        
        if(!oppoIds.isEmpty() && !System.isFuture() && !System.isBatch() && !blnRunOnce){
            blnRunOnce = true;
            setPriceFuture(oppoIds);
        }else if(!oppoIds.isEmpty() && (System.isFuture() || System.isBatch()) && !blnRunOnce){
            setPrice(oppoIds);
        }
    }

    
    @future
    public static void setPriceFuture(Set<Id> optIds){
        setPrice(optIds);
    }//End ofMethod setPriceFuture
    
    
    public static void setPrice(set<Id> oppoIds){
         
     List<OpportunityLineItem> UpdateOLIs =  new List<OpportunityLineItem>();
     for(OpportunityLineItem OLI:[Select UnitPrice ,ACV_New__c,Pricing_Meter__c,Discount,Quantity from OpportunityLineItem Where (OpportunityID IN :oppoIds AND Quantity!=null) AND SBQQ__QuoteLine__c!=null FOR UPDATE ]){      
            
         if(OLI.ACV_New__c==0 || OLI.ACV_New__c==null){
             OLI.UnitPrice=0;
         }
         if(OLI.ACV_New__c!=null){
             OLI.UnitPrice=OLI.Discount!=NULL ?(OLI.ACV_New__c)/((OLI.Quantity-OLI.Quantity*OLI.Discount)):(OLI.ACV_New__c)/(OLI.Quantity);

         }
          UpdateOLIs.add(OLI);
        }
        
        if(!UpdateOLIs.isEmpty()){
        blnRunOnce =true;
            UPDATE UpdateOLIs;
        }
    }//End of method setPrice
        
        
}