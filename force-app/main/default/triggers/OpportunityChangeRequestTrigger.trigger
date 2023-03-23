trigger OpportunityChangeRequestTrigger on Opportunity (after insert,after update) {
    
    
    list<Opportunity_Audit_History__c> auditlst = new list<Opportunity_Audit_History__c>();
    
    List<id> ids = new List<id>();
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        //Map<Id,Opportunity> oppmap = trigger.oldMap;
        List<String> fields = new List<String>();
        for(Schema.FieldSetMember fld:SObjectType.Opportunity.FieldSets.Opportunity_History.getFields()) {
            String val = String.valueOf(fld.getFieldPath());
            System.debug('val-->'+val);
            for(Opportunity opp:trigger.new){
                System.debug('opp.get(val)-->'+opp.get(val));
                if( opp.get(val)!=null && (trigger.isInsert||trigger.oldMap.get(opp.id).get(val)!=opp.get(val))){
                    Opportunity_Audit_History__c audit = new Opportunity_Audit_History__c();
                    if(trigger.isUpdate){
                        
                            audit.Old_value__c = String.valueOf(trigger.oldMap.get(opp.id).get(val));
                        
                    }
                
                    audit.Field_Name__c = val;
                    audit.New_Value__c = String.valueOf(opp.get(val));
               
                audit.Opportunity_Change_Request__c = opp.id;
                auditlst.add(audit);
            }
            }
            fields.add(fld.getFieldPath());
        }
        
        System.debug('fields'+fields);
        
        /*for(Opportunity opp:trigger.new){
            
            if(opp.StageName!=null && (trigger.isInsert||trigger.oldMap.get(opp.id).StageName !=opp.StageName)){
                Opportunity_Audit_History__c audit = new Opportunity_Audit_History__c();
                if(trigger.isUpdate){
                    audit.Old_Value__c = trigger.oldMap.get(opp.id).StageName;
                }
                audit.New_Value__c = opp.StageName;
                audit.Opportunity_Change_Request__c = opp.id;
                auditlst.add(audit);
                //ids.add(opp.id);
            }               
        }*/
        //System.debug('opp audit list-->'+auditlst);
       
        if(auditlst.size()>0){
            insert auditlst;
        }
        //List<Opportunity> opplist = [Select id,name,StageName from opportunity];
    }
}