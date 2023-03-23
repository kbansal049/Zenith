public class OpportunityChangeRequestCtrl { 
    public static void setAuditRecord(List<Opportunity> lstNew , Map<Id,Opportunity> mapOld)  {
        list<Opportunity_Audit_History__c> auditlst = new list<Opportunity_Audit_History__c>();
        for(Schema.FieldSetMember fld:SObjectType.Opportunity.FieldSets.Opportunity_History.getFields()) {
            String val = String.valueOf(fld.getFieldPath());
            for(Opportunity opp:lstNew){            
                if((mapOld == null ||mapOld.get(opp.id).get(val)!=opp.get(val))){			//Updated by Ayush Kangar as part of IBA-5177 
                    Opportunity_Audit_History__c audit = new Opportunity_Audit_History__c();    
                    if(mapOld != null && mapOld.get(opp.id ) != null){
                        audit.Old_value__c = String.valueOf(mapOld.get(opp.id).get(val));
                        TriggerUtility2.OppAfterUpdateExecuted();
                    }
                    audit.Field_Name__c = fld.getLabel();
                    audit.New_Value__c = String.valueOf(opp.get(val));
                    audit.Opportunity_Change_Request__c = opp.id;
                    auditlst.add(audit);                   
                }
            }        
        }
        if(auditlst.size()>0){
            insert auditlst;
            TriggerUtility2.OppAfterInsertExecuted();
        }
        
    }
    
}