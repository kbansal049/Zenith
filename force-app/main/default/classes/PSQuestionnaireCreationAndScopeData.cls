global without sharing class PSQuestionnaireCreationAndScopeData extends OneDoc.BaseTemplateDataProvider {
    public override Object provide(Map<String, String> params) { 
        Date currentdate = System.today();
        String createdby = UserInfo.getName();
        String windows = 'Not In Scope';
        String macs = 'Not In Scope';
        String vdi = 'Not In Scope';
        String kiosk = 'Not In Scope';
        String android = 'Not In Scope';
        String ios = 'Not In Scope';
        String servers = 'Not In Scope';
        String iot = 'Not In Scope';
        String byod = 'Not In Scope';
        String guest = 'Not In Scope';
        List<PS_Questionnaire__c> psqList = [select id, Traffic_Sources__c from PS_Questionnaire__c where Id=:params.get('Id')];
        
        if(psqList[0].Traffic_Sources__c != null){
            List<String> trafficSources = psqList[0].Traffic_Sources__c.split(';');    
            if(trafficSources.contains('Corporate Windows Workstations')){
                windows = 'In Scope';
            }
            if(trafficSources.contains('Corporate MAC Workstations')){
                macs = 'In Scope';
            }
            if(trafficSources.contains('Virtual Desktop Infra (VDI) Users')){
                vdi = 'In Scope';
            }
            if(trafficSources.contains('Kiosk/Shared Machines')){
                kiosk = 'In Scope';
            }
            if(trafficSources.contains('Corporate Android Devices')){
                android = 'In Scope';
            }
            if(trafficSources.contains('Corporate IOS Devices')){
                ios = 'In Scope';
            }
            if(trafficSources.contains('Servers')){
                servers = 'In Scope';
            }
            if(trafficSources.contains('Guest Wifi Users')){
                guest = 'In Scope';
            }
            if(trafficSources.contains('BYOD Users')){
                byod = 'In Scope';
            }
            if(trafficSources.contains('IoT (Connected Devices)')){
                iot = 'In Scope';
            }
        }
        
        DataWrapper result = new DataWrapper(currentdate, createdBy, windows, macs, vdi, kiosk, android, ios, servers, iot, byod, guest);
        return JSON.serialize(result);
        
    }
    global class DataWrapper{
        global Date currentdate;
        global String createdby;
        global String windows;
        global String macs;
        global String vdi;
        global String kiosk;
        global String android;
        global String ios;
        global String servers;
        global String iot;
        global String byod;
        global String guest;
        
        global DataWrapper(Date currentdate, String createdby, String windows, String macs, String vdi, String kiosk, String android, String ios, String servers, String iot, String byod, String guest){
            this.currentDate = currentdate;
            this.createdby = createdby;
            this.windows = windows;
            this.macs = macs;
            this.vdi = vdi;
            this.kiosk = kiosk;
            this.android = android;
            this.ios = ios;
            this.servers = servers;
            this.iot = iot;
            this.byod = byod;
            this.guest = guest;
        }
    }
}