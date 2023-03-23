/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-09-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Trigger_Contract_Handler extends TriggerHandler{
    
    public override void beforeInsert(){  

    }
    
    public override void beforeUpdate(){
        
    }
    
    public override void afterInsert(){

    }
      
    public override void afterUpdate(){
        //Method to create Custom Renewals
        Trigger_Contract_Helper.createCustomRenewals(Trigger.new,(Map<Id,Contract>)Trigger.oldMap);
        
        //Method to trigger on Contract Split
        // Trigger_Contract_Helper.createContractOnSplit(newList);
    }    
    
}