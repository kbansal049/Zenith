public class ZTEXDemoTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert(){
        System.debug('ZTEXDemoTriggerHandler BeforeInsert Is Invoked');
        List<ZTEX_Demo_Env__c> pgList = (List<ZTEX_Demo_Env__c>) trigger.new;
        callZTEXBeforeInsert(pgList);
    }
    
    public override void afterInsert() {
        System.debug('ZTEXDemoTriggerHandler AfterInsert Is Invoked');
        List<ZTEX_Demo_Env__c> pgList = (List<ZTEX_Demo_Env__c>) trigger.new;
        
        callZTEXRequestFlowInsert(pgList);
    }
    
    public override void afterUpdate() {
        System.debug('ZTEXDemoTriggerHandler.afterUpdate() is invoked');
        List<ZTEX_Demo_Env__c> zList = (List<ZTEX_Demo_Env__c>) trigger.new;
        MAP<ID,ZTEX_Demo_Env__c> zOldMAP = (MAP<ID,ZTEX_Demo_Env__c>) trigger.oldmap;
        
        
        callZTEXRequestFlowUpdate(zList, zOldMAP);
    }
    
    
    
    public void callZTEXRequestFlowInsert(List<ZTEX_Demo_Env__c> ztexList){
        List<ZTEX_Demo_Env__c> eventList = new List<ZTEX_Demo_Env__c>();
        for(ZTEX_Demo_Env__c ztexDemo : ztexList){
            if(ztexDemo.Request_Status__c == 'Requested'){
                eventList.add(ztexDemo);
            }
        }
        if(eventList.size()>0){
            fireGenericPlatformEvent(eventList);
        }  
    }
    
    
     public void callZTEXRequestFlowUpdate(List<ZTEX_Demo_Env__c> ztexList, MAP<ID,ZTEX_Demo_Env__c> oldMAP){
        List<ZTEX_Demo_Env__c> eventList = new List<ZTEX_Demo_Env__c>();
        for(ZTEX_Demo_Env__c ztexDemo : ztexList){
            if(ztexDemo.Request_Status__c == 'Requested' && ztexDemo.Request_Status__c != oldMAP.get(ztexDemo.id).Request_Status__c){
                eventList.add(ztexDemo);
            }
        }
        if(eventList.size()>0){
            fireGenericPlatformEvent(eventList);
        }  
    }
    
    
    @testVisible
    private void fireGenericPlatformEvent(List<ZTEX_Demo_Env__c> ztexList){
        List<Workato_Generic_Event__e> eventList = new List<Workato_Generic_Event__e>();
        for(ZTEX_Demo_Env__c ztexDemo : ztexList){
            if(ztexDemo.Request_Status__c == 'Requested'){
                Workato_Generic_Event__e evnt = new Workato_Generic_Event__e();
                evnt.Object_API_Name__c='ZTEX_Demo_Env__c';
                evnt.Process__c ='ZTEX Request';
                evnt.Record_Id__c = ztexDemo.id;
                evnt.Additional_Detail__c = Json.serialize(new ZTEXRequestWrapper(ztexDemo));
                eventList.add(evnt);
            }
        }
        if(eventList !=null && eventList.size()>0){
            Eventbus.publish(eventList);
        }
        
    }
    
    public class ZTEXRequestWrapper {
        public String ZTEXRequest;
        public String RequestorEmail;
        public Date RequestDate;
        ZTEXRequestWrapper(ZTEX_Demo_Env__c zDemo){
            this.ZTEXRequest = zDemo.Name;
            this.RequestorEmail = zDemo.Requestor_Email__c;
            this.RequestDate = zDemo.Request_Date__c;
        }
    }
    
    public void callZTEXBeforeInsert(List<ZTEX_Demo_Env__c> ztexList){
        Set<ID> contactIDSet = new Set<ID>();
        List<ZTEX_Demo_Env__c> eventList = new List<ZTEX_Demo_Env__c>();
        for(ZTEX_Demo_Env__c ztexDemo : ztexList){
            if(ztexDemo.Partner_Contact__c!=Null ){
                contactIDSet.add(ztexDemo.Partner_Contact__c);
            }
        }
        System.debug('contactIDSet '+contactIDSet);
        Map<ID,Contact> contactDetailMap = new Map<ID,Contact>();
        For(Contact cont :[Select ID,Email from Contact where ID in: contactIDSet]){
            contactDetailMap.put(cont.ID,cont);
        }
        System.debug('contactDetailMap '+contactDetailMap);
        for(ZTEX_Demo_Env__c ztexDemo : ztexList){
            if(ztexDemo.Partner_Contact__c!=Null && contactDetailMap.containsKey(ztexDemo.Partner_Contact__c)){
                ztexDemo.Requestor_Email__c = contactDetailMap.get(ztexDemo.Partner_Contact__c).Email;
            }
            ztexDemo.User_Name__c = userinfo.getuserId();
        }
    }

}