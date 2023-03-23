public class TargetCustomerHelper {
    public static void createTargetCustomerHistory(List<Target_Customer__c> NewList,Map<Id, Target_Customer__c> OldMap){
        list<Target_Customer_Field_History__c> auditlst = new list<Target_Customer_Field_History__c>();
        for(Schema.FieldSetMember fld:SObjectType.Target_Customer__c.FieldSets.Target_Customer_History.getFields()) {
            String val = String.valueOf(fld.getFieldPath());
            System.debug('val-->'+val);
            for(Target_Customer__c tc:NewList){
                if( tc.get(val)!=null && (OldMap == null ||OldMap.get(tc.id).get(val)!=tc.get(val))){
                	Target_Customer_Field_History__c audit = new Target_Customer_Field_History__c();    
                    if(OldMap != null && OldMap.get(tc.id ) != null){
                        audit.Previous_Value__c = String.valueOf(OldMap.get(tc.id).get(val));
                    }
                    audit.Field_Name__c = fld.getLabel();
                    audit.New_Value__c = String.valueOf(tc.get(val));
                    audit.Target_Customer__c = tc.id;
                    audit.Date__c=System.Now();
                    audit.Modified_By__c = UserInfo.getUserId();
                    auditlst.add(audit);
                    
                }
            }   
        }
        if(auditlst.size()>0){
        	insert auditlst;
            TriggerUtility2.TargetafterInsertAndUpdateExecuted();
    	}
    }

    //CR# 2914 - Added by Ritesh Kumar - START
    public static void updateTargetCustomerOnEvent(List<Target_Customer__c> newList,Map<Id, Target_Customer__c> oldMap){
        Set<Id> partnerIdSet = new Set<Id>();
        Set<Id> customerIdSet = new Set<Id>();
        Map<String, Target_Customer__c> targetCustomerMap = new Map<String, Target_Customer__c>();
        Map<Id, Target_Customer__c> newTargetCustomerMap = new Map<Id, Target_Customer__c>();

        for (Target_Customer__c targetCustomer : newList) {
            if((targetCustomer.Customer__c != null && oldMap?.get(targetCustomer.Id)?.Customer__c != targetCustomer.Customer__c) || 
                (targetCustomer.Partner__c != null && oldMap?.get(targetCustomer.Id)?.Partner__c != targetCustomer.Partner__c)){
                partnerIdSet.add(targetCustomer.Partner__c);
                customerIdSet.add(targetCustomer.Customer__c);
                String tempString = String.valueOf(targetCustomer.Partner__c) + String.valueOf(targetCustomer.Customer__c);
                targetCustomerMap.put(tempString, targetCustomer);
                newTargetCustomerMap.put(targetCustomer.Id, targetCustomer);
            }
        }

        if(!partnerIdSet.isEmpty() && !customerIdSet.isEmpty()){
            List<Event> eventList = [SELECT Id, WhatId, Customer_Name__c, Type, Target_Customer__c FROM Event WHERE WhatId IN :partnerIdSet OR Customer_Name__c IN :customerIdSet OR Target_Customer__c IN :newTargetCustomerMap.keyset()];
            System.debug('eventList==>' + eventList);
            List<Event> eventToUpdate = new List<Event>();

            for (Event eventRecord : eventList) {
                String tempString = String.valueOf(eventRecord.WhatId) + String.valueOf(eventRecord.Customer_Name__c);
                if(targetCustomerMap.containsKey(tempString)){
                    eventRecord.Target_Customer__c = targetCustomerMap.get(tempString).Id;
                    eventToUpdate.add(eventRecord);
                } else{
                    if(newTargetCustomerMap.containsKey(eventRecord.Target_Customer__c)){
                        Target_Customer__c targetCustomer = newTargetCustomerMap.get(eventRecord.Target_Customer__c);
                        if( eventRecord.Target_Customer__c == targetCustomer.Id && (eventRecord.WhatId != targetCustomer.Partner__c || eventRecord.Customer_Name__c != targetCustomer.Customer__c)){
                            eventRecord.Target_Customer__c = null;
                            eventToUpdate.add(eventRecord);
                        }
                    }
                }
            }
            update eventToUpdate;
        }

        TriggerUtility2.TargetafterInsertAndUpdateExecuted();
    }
    //CR# 2914 - Added by Ritesh Kumar - END
}