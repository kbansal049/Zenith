public class ProvisioningIntegrationTriggerHandler extends TriggerHandler {
    
    public static Id zscmToSFDC = Schema.SObjectType.Provisioning_Integration_Log__c.getRecordTypeInfosByName().get('ZscmToSfdc').getRecordTypeId();
    
    public override void afterInsert() {
        System.debug('-----ProvisioningIntegrationTriggerHandler AfterInsert Is Invoked----');
        List<Provisioning_Integration_Log__c> pgList = (List<Provisioning_Integration_Log__c>) trigger.new;
        fireProvistioningBrokerProcessingEventAfterInsert(pgList);
    }
    
    public override void afterUpdate() {        
        System.debug('---ProvisioningIntegrationTriggerHandler afterUpdate Is Invoked----');
        List<Provisioning_Integration_Log__c> pgList = (List<Provisioning_Integration_Log__c>) trigger.new;
        MAP<ID,Provisioning_Integration_Log__c> oldPGMap = (MAP<ID,Provisioning_Integration_Log__c>) trigger.oldmap;
        fireProvistioningBrokerProcessingEventAfterUpdate(pgList, oldPGMap);
    }
    
    
    @testvisible
    private void fireProvistioningBrokerProcessingEventAfterInsert(List<Provisioning_Integration_Log__c> pgList){
        System.debug('-----fireProvistioningBrokerProcessingEventAfterInsert afterInsert Is Invoked-----');
        List<Provisioning_Broker_Processing_Event__e> pgevntList = new list<Provisioning_Broker_Processing_Event__e>();
        for(Provisioning_Integration_Log__c logNew1: pgList){
            if(logNew1.RecordTypeId == zscmToSFDC && (logNew1.Status__c =='Requested' || logNew1.Status__c =='Failed' || logNew1.Status__c =='Received')){
                pgevntList.add(new Provisioning_Broker_Processing_Event__e(Provisioning_Integration_Log_ID__c= logNew1.Id,  Provisioning_Integration_Log_Name__c= logNew1.Name));
            }
        }
        System.debug('--ProvisioningIntegrationTriggerHandler--pgevntList--'+pgevntList);
        if(pgevntList !=null && pgevntList.size()>0){
            EventBus.publish(pgevntList);
        } 
    }
    
    @testvisible
    private void fireProvistioningBrokerProcessingEventAfterUpdate(List<Provisioning_Integration_Log__c> pgList, MAP<ID,Provisioning_Integration_Log__c> oldPGMap){
        System.debug('-----fireProvistioningBrokerProcessingEventAfterUpdate afterUpdate Is Invoked-----');
        List<Provisioning_Broker_Processing_Event__e> pgevntList = new list<Provisioning_Broker_Processing_Event__e>();
        for(Provisioning_Integration_Log__c piLog: pgList){
            Provisioning_Integration_Log__c oldPiLog = oldPGMap.get(piLog.ID);
            System.debug('----piLog--Status__c---'+piLog.Status__c);
            System.debug('----oldPiLog--Status__c---'+oldPiLog.Status__c);
            if(piLog.RecordTypeId == zscmToSFDC && (piLog.Status__c =='Failed') && piLog.Status__c !=  oldPiLog.Status__c){
                pgevntList.add(new Provisioning_Broker_Processing_Event__e(Provisioning_Integration_Log_ID__c = piLog.Id, Provisioning_Integration_Log_Name__c= piLog.Name));
            }
        }
        System.debug('--fireProvistioningBrokerProcessingEventAfterUpdate--pgevntList--'+pgevntList);
        if(pgevntList !=null && pgevntList.size()>0){
            EventBus.publish(pgevntList);
        }
    }
    
}