public class SecurityPolicyDataMappingService  implements Database.Batchable<sObject>,Database.Stateful {
    ZscalerBatchFramework zb = new ZscalerBatchFramework('SecurityPolicyDataMappingService');
    public string query;
	public List<id> objIds;
    public static list<BWC_Data__c> successList = new List<BWC_Data__c>();
    
    public SecurityPolicyDataMappingService(){
        query = 'select id,Security_Policy_Data__c,Threat_Protection__c ,Security_Exception__c,Traffic_Inspection__c,Overall_Grade__c,SSL_Inspection__c,Inbound_Outbound_Traffic__c,Protocol_Inspection__c,Malware_Detection__c,Advanced_Threats__c,Browser_Control__c,Cloud_Sandbox__c,SSL_Exceptions__c,Security_Exceptions__c from BWC_Data__c where is_Current_Month__c  = true';
    }
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        return Database.getQueryLocator(query);
    }
    public void execute (Database.BatchableContext context, List<BWC_Data__c> monthlyCouldlist){
        this.zb.callExecute(monthlyCouldlist[0]?.Id, monthlyCouldlist.size());
        if(monthlyCouldlist.size()>0){
            securityPolicyDataMappingFromJSON(monthlyCouldlist);
        }
    }
    
    public static void securityPolicyDataMappingFromJSON(List<BWC_Data__c> monthlyCouldlist){
        try{
            for(BWC_Data__c mountlyCloudObj : monthlyCouldlist){
                System.debug('---outside if---'+monthlyCouldlist.size());
                //if(String.isNotBlank(mountlyCloudObj.Security_Policy_Data__c)){
                    System.debug('---insideif---');
                    SecurityPolicyDataModel jsonDataModel = (SecurityPolicyDataModel)JSON.deserialize(mountlyCloudObj.Security_Policy_Data__c,SecurityPolicyDataModel.class);
                    

					Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(mountlyCloudObj.Security_Policy_Data__c);
					
					System.debug('---json-----'+jsonObj.get('protocol_inspection'));
                    
                    if(jsonDataModel.protocol_inspection != null && jsonDataModel.protocol_inspection.grade != null && jsonDataModel.protocol_inspection.grade != 'NOT_APPLICABLE' )  {
                        mountlyCloudObj.Protocol_Inspection__c = jsonDataModel.protocol_inspection.grade;
                    }else  {
                        mountlyCloudObj.Protocol_Inspection__c = null;
                    }
                
                	if(jsonDataModel.sandbox != null && jsonDataModel.sandbox.grade != null && jsonDataModel.sandbox.grade != 'NOT_APPLICABLE' )  {
                        mountlyCloudObj.Cloud_Sandbox__c = jsonDataModel.sandbox.grade;
                    }else  {
                        mountlyCloudObj.Cloud_Sandbox__c = null;
                    }
                
                	if(jsonDataModel.ssl_inspection != null && jsonDataModel.ssl_inspection.grade != null && jsonDataModel.ssl_inspection.grade != 'NOT_APPLICABLE' )  {
                        mountlyCloudObj.SSL_Inspection__c = jsonDataModel.ssl_inspection.grade;
                    }else  {
                        mountlyCloudObj.SSL_Inspection__c = null;
                    }
                
                	if(jsonDataModel.inbound_outbound_traffic != null && jsonDataModel.inbound_outbound_traffic.grade != null && jsonDataModel.inbound_outbound_traffic.grade != 'NOT_APPLICABLE' )  {
                        mountlyCloudObj.Inbound_Outbound_Traffic__c = jsonDataModel.inbound_outbound_traffic.grade;
                    }else  {
                        mountlyCloudObj.Inbound_Outbound_Traffic__c = null;
                    }
                
                	if(jsonDataModel.malware != null && jsonDataModel.malware.grade != null && jsonDataModel.malware.grade != 'NOT_APPLICABLE' )  {
                        mountlyCloudObj.Malware_Detection__c = jsonDataModel.malware.grade;
                    }else  {
                        mountlyCloudObj.Malware_Detection__c = null;
                    }
                	
                	if(jsonDataModel.advanced_threats != null && jsonDataModel.advanced_threats.grade != null && jsonDataModel.advanced_threats.grade != 'NOT_APPLICABLE' )  {
                        mountlyCloudObj.Advanced_Threats__c = jsonDataModel.advanced_threats.grade;
                    }else  {
                        mountlyCloudObj.Advanced_Threats__c = null;
                    }
                
                	if(jsonDataModel.browser_control != null && jsonDataModel.browser_control.grade != null && jsonDataModel.browser_control.grade != 'NOT_APPLICABLE' )  {
                        mountlyCloudObj.Browser_Control__c = jsonDataModel.browser_control.grade;
                    }else  {
                        mountlyCloudObj.Browser_Control__c = null;
                    }
                
                	if(jsonDataModel.ssl_exceptions != null && jsonDataModel.ssl_exceptions.grade != null && jsonDataModel.ssl_exceptions.grade != 'NOT_APPLICABLE' )  {
                        mountlyCloudObj.SSL_Exceptions__c = jsonDataModel.ssl_exceptions.grade;
                    }else  {
                        mountlyCloudObj.SSL_Exceptions__c = null;
                    }
                
                	if(jsonDataModel.security_exceptions != null && jsonDataModel.security_exceptions.grade != null && jsonDataModel.security_exceptions.grade != 'NOT_APPLICABLE' )  {
                        mountlyCloudObj.Security_Exceptions__c = jsonDataModel.security_exceptions.grade;
                    }else  {
                        mountlyCloudObj.Security_Exceptions__c = null;
                    }
                    
                    /*
                    mountlyCloudObj.Threat_Protection__c = checkJSON(jsonDataModel.threatProtection);
                    mountlyCloudObj.Security_Exception__c = checkJSON(jsonDataModel.securityException);
                    mountlyCloudObj.Traffic_Inspection__c = checkJSON(jsonDataModel.trafficInspection);
                    mountlyCloudObj.Overall_Grade__c = checkJSON(jsonDataModel.overallGrade);
                    mountlyCloudObj.SSL_Inspection__c = checkJSON(jsonDataModel.SSLInspection);
                    mountlyCloudObj.Inbound_Outbound_Traffic__c = checkJSON(jsonDataModel.inboundOutboundTraffic);
                    mountlyCloudObj.Protocol_Inspection__c =checkJSON(jsonDataModel.protocolInspection);
                    mountlyCloudObj.Malware_Detection__c = checkJSON(jsonDataModel.malwareDetection);
                    mountlyCloudObj.Advanced_Threats__c = checkJSON(jsonDataModel.advancedThreats);
                    mountlyCloudObj.Browser_Control__c = checkJSON(jsonDataModel.browserControl);
                    mountlyCloudObj.Cloud_Sandbox__c = checkJSON(jsonDataModel.cloudSandbox);
                    mountlyCloudObj.SSL_Exceptions__c = checkJSON(jsonDataModel.SSLExceptions);
                    mountlyCloudObj.Security_Exceptions__c = checkJSON(jsonDataModel.securityExceptions);
                    system.debug('---json values---'+mountlyCloudObj);
					*/                    
					successList.add(mountlyCloudObj);
                    
                    
                //}
            }
            if(successList.size()>0){
                System.debug('---inside successList--');
                update successList;
            }
        }
        catch(Exception e){
            System.debug('--exception--'+e.getMessage());
        }
    }
    public void finish(Database.BatchableContext context){
    	this.zb.callFinish(context);
    }
    
    public static String checkJSON(String objKey){
        return (objKey !=null && String.isNotBlank(objKey))?objKey:'';
    }
    
}