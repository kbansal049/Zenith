public Without Sharing class JiraTicketCreationController  {
    
    private final NC_JIRA_Ticket__c ncJira;
    private ID ncRecordID;
    
    @TestVisible
    private Static Boolean throwCustomException = false;
    
    public JiraTicketCreationController(ApexPages.StandardController stdController) {
        List<String> flds = new List<String>{'Node_Configuration__c'};
            if(!Test.isRunningTest())
            stdController.addFields(flds);
        this.ncJira = (NC_JIRA_Ticket__c)stdController.getRecord();
    }
    
    
    public PageReference validateAndRedirect(){
        System.debug('---validateAndRedirect---');
        PageReference retURL = null;
        String ncID = ApexPages.currentPage().getParameters().get('ncid');
        String recordID = ApexPages.currentPage().getParameters().get('id');
        system.debug('--ncJira--'+ncJira);
        system.debug('--recordID--'+recordID);
        
        if(( recordID == null || ncJira.id == null) &&
           (ncID != null && String.isNotBlank(ncID))){
               ncRecordID = ncID;
               List<NC_JIRA_Ticket__c> jiraList = [Select Id from NC_JIRA_Ticket__c where Node_Configuration__c = :ncID order by createdDate DESC limit 1];
               if(jiraList.size()>0){   
                   retURL = new PageReference('/apex/NC_JIRA_Ticket?id='+jiraList[0].Id+'&ncid='+ncid);
                   retURL.setRedirect(true);
               }   
           }
        return retURL;
    }
    
    public PageReference doRedirectNodeConfig(){
        System.debug('--doRedirectNodeConfig--called-- ');
        PageReference pageRef = null;
        System.debug('--ncJira--'+ncJira);
        System.debug('--ncRecordID--'+ncRecordID);
        if(ncJira != null && ncJira.Node_Configuration__c != null){
            pageRef = new PageReference('/'+ncJira.Node_Configuration__c);
            pageRef.setRedirect(true);
        }
        else if (ncRecordID != null){
            pageRef = new PageReference('/'+ncRecordID);
            pageRef.setRedirect(true);
        }
        return pageRef;
    }
    
    
    @auraEnabled (cacheable=true)
    public static JiraWrapper  getJiraDetails(Id jiraID){
        System.debug('---getJiraDetails--called--');
        System.debug('---getJiraDetails--jiraID--'+jiraID);
        
        JiraWrapper jrw = new JiraWrapper();
        try{
            List<NC_JIRA_Ticket__c> ncList = [Select id, name, Node_Configuration__c,Jira_Ticket_ID_LB__c,Jira_Ticket_ID_NC__c 
                                              from NC_JIRA_Ticket__c where id  = :jiraID];
            
            if(ncList.size()>0){
                jrw.hasError = false;
                jrw.jrRecord = ncList[0];
            }else{
                jrw.hasError = true;
                jrw.errMsg = 'Node Configuration record not found, please try with valid record id.';
            }
            
            if(throwCustomException){
                // Throw first exception
                throw new CustomException('First exception'); 
            }
        }catch(Exception ex){
            jrw.hasError = true;
            jrw.errMsg = 'Error Occured:'+ex.getMessage();
            System.debug('---Exception--ex:getMessage--'+ex.getMessage());
            System.debug('---Exception--ex:getLineNumber--'+ex.getLineNumber());
            System.debug('---Exception--ex:getStackTraceString--'+ex.getStackTraceString());
        }
        return jrw;
    }
    
    @auraEnabled (cacheable=true)
    public static NodeConfigWrapper  getNodeConfigDetails(Id ncID){
        System.debug('---getNodeConfigDetails--called--');
        System.debug('---getNodeConfigDetails--ncID--'+ncID);
        
        NodeConfigWrapper ncw = new NodeConfigWrapper();
        try{
            List<Node_Configuration__c> ncList = [Select id, name, recordtype.name,
                                                  
                                                  Account_Name__c,Opportunity_Name__c,
                                                  
                                                  Datacenter__c,Datacenter__r.Name,
                                                  Equipment_Request__c,Equipment_Request__r.Name,
                                                  
                                                  Equipment_Request__r.Opportunity__c,Equipment_Request__r.Opportunity__r.Name,
                                                  
                                                  Primary_DNS_Recursor__c,Secondary_DNS_Recursor__c,
                                                  Primary_NTP_Server__c,Secondary_NTP_Server__c,
                                                  
                                                  Node_Configuration_Status__c,
                                                  
                                                  MTS_IP_1__c,MTS_IP_2__c,
                                                  VPN_Public_IP__c,NC2_VPN_Public_IP__c,
                                                  VPN_Private_IP__c,NC2_VPN_Private_IP__c,
                                                  
                                                  Load_Balance_Public_IP__c,NC2_Load_Balance_Public_IP__c, 
                                                  
                                                  IPMI_Default_Gateway__c,NC2_IPMI_Default_Gateway__c,
                                                  LBC1_IPMI_Default_Gateway__c,LBC2_IPMI_Default_Gateway__c,
                                                  
                                                  Public_IPMI_IP__c,NC2_Public_IPMI_IP__c,Private_IPMI_IP__c,NC2_Private_IPMI_IP__c,
                                                  LBC1_Public_IPMI_IP__c,LBC2_Public_IPMI_IP__c,LBC1_Private_IPMI_IP__c,LBC2_Private_IPMI_IP__c,
                                                  
                                                  IPMI_CIDR_Netmask__c,NC2_IPMI_CIDR_Netmask__c,LBC1_IPMI_Subnet_Netmask__c,LBC2_IPMI_Subnet_Netmask__c,
                                                  
                                                  SI_Public_Service_IP__c, Public_Service_IP_2__c, Public_Service_IP_3__c, 
                                                  NC1_Public_Service_IP_4__c, NC1_Public_Service_IP_5__c, NC1_Public_Service_IP_6__c,  
                                                  LBC1_Public_Service_IP_1__c, LBC1_Public_Service_IP_2__c, LBC1_Public_Service_IP_3__c,  
                                                  NC2_Public_Service_IP_1__c, NC2_Public_Service_IP_2__c, NC2_Public_Service_IP_3__c, 
                                                  NC2_Public_Service_IP_4__c, NC2_Public_Service_IP_5__c, NC2_Public_Service_IP_6__c,  
                                                  LBC2_Public_Service_IP_1__c, LBC2_Public_Service_IP_2__c, LBC2_Public_Service_IP_3__c,  
                                                  SI_Private_Service_IP__c, Private_Service_IP_2__c, Private_Service_IP_3__c, 
                                                  NC1_Private_Service_IP_4__c, NC1_Private_Service_IP_5__c, NC1_Private_Service_IP_6__c,  
                                                  LBC1_Private_Service_IP_1__c, LBC1_Private_Service_IP_2__c, LBC1_Private_Service_IP_3__c,  
                                                  NC2_Private_Service_IP_1__c, NC2_Private_Service_IP_2__c, NC2_Private_Service_IP_3__c, 
                                                  NC2_Private_Service_IP_4__c, NC2_Private_Service_IP_5__c, NC2_Private_Service_IP_6__c,  
                                                  LBC2_Private_Service_IP_1__c, LBC2_Private_Service_IP_2__c, LBC2_Private_Service_IP_3__c,  
                                                  Service_CIDR_Netmask__c, NC2_Service_CIDR_Netmask__c,  LBC1_Service_Subnet_Netmask__c, 
                                                  LBC2_Service_Subnet_Netmask__c,  Service_Default_Gateway__c, NC2_Service_Default_Gateway__c, 
                                                  LBC1_Service_Default_Gateway__c, LBC2_Service_Default_Gateway__c,  Public_Management_IP__c, 
                                                  NC2_Public_Management_IP__c,  LBC1_Public_Management_IP__c, LBC2_Public_Management_IP__c,  
                                                  Private_Management_IP__c, NC2_Private_Management_IP__c,  LBC1_Private_Management_IP__c, 
                                                  LBC2_Private_Management_IP__c,  Management_CIDR__c, NC2_Management_CIDR_Netmask__c,  
                                                  LBC1_Management_Subnet_Netmask__c, LBC2_Management_Subnet_Netmask__c,  Management_Default_Gateway__c, 
                                                  NC2_Management_Default_Gateway__c,  LBC1_Management_Default_Gateway__c, LBC2_Management_Default_Gateway__c,
                                                  
                                                  
                                                  LBC1_Load_Balance_Public_IP_1__c,LBC1_Load_Balance_Public_IP_2__c,
                                                  LBC2_Load_Balance_Public_IP_1__c,LBC2_Load_Balance_Public_IP_2__c,
                                                  LBC1_Load_Balance_Private_IP_1__c,LBC1_Load_Balance_Private_IP_2__c,
                                                  LBC2_Load_Balance_Private_IP_1__c,LBC2_Load_Balance_Private_IP_2__c,
                                                  
                                                  VPN_Public_Virtual_IP__c,
                                                  VPN_Private_Virtual_IP__c,
                                                  
                                                  SI_Public_Virtual_IP__c,
                                                  SI_Private_Virtual_IP__c,
                                                  
                                                  SI_Public_Virtual_IP_1__c,SI_Public_Virtual_IP_2__c,Public_Virtual_IP_3__c,
                                                  SI_Private_Virtual_IP_1__c,SI_Private_Virtual_IP_2__c,Private_Virtual_IP_3__c,
                                                  
                                                  Load_Balance_Private_IP__c,
                                                  NC2_Load_Balance_Private_IP__c
                                                  
                                                  from Node_Configuration__c where id  = :ncID];
            
            if(ncList.size()>0){
                ncw.hasError = false;
                ncw.ncRecord = ncList[0];
            }else{
                ncw.hasError = true;
                ncw.errMsg = 'Node Configuration record not found, please try with valid record id.';
            }
            
            if(throwCustomException){
                // Throw first exception
                throw new CustomException('First exception'); 
            }
        }catch(Exception ex){
            ncw.hasError = true;
            ncw.errMsg = 'Error Occured:'+ex.getMessage();
            System.debug('---Exception--ex:getMessage--'+ex.getMessage());
            System.debug('---Exception--ex:getLineNumber--'+ex.getLineNumber());
            System.debug('---Exception--ex:getStackTraceString--'+ex.getStackTraceString());
        }
        System.debug('--getNodeConfigDetails--ncw--'+ncw);
        return ncw;
        
    }
    
    @auraEnabled
    public Static PlatformEventResultWrapper  generateJiraPlatFormEvent(ID jiraID, ID ncID){
        
        PlatformEventResultWrapper per = new PlatformEventResultWrapper();
        try{
            
            //IBA-2402 - Changes to Optimze usage of Platform Events
            List<Workato_Generic_Event__e> eventList = new List<Workato_Generic_Event__e>();
            Workato_Generic_Event__e evnt = new Workato_Generic_Event__e();
            evnt.Object_API_Name__c='NC_JIRA_Ticket_ID__c';
            evnt.Process__c ='NC_JIRA_Ticket_Creation';
            evnt.Record_Id__c = jiraID;
            evnt.Additional_Detail__c = Json.serialize(new NCRequestWrapper(ncID,jiraID,userinfo.getUserId()));
            System.debug('inside jira '+evnt.Additional_Detail__c);
            eventList.add(evnt);
            
            // Call method to publish events
            List<Database.SaveResult> results = EventBus.publish(eventList);
            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    per.isSuccess = true;
                    updateNodeConfigJiraStatus(ncID);
                    System.debug('---EventBus SaveResult-ID---'+sr.id);
                    System.debug('---EventBus ID---'+EventBus.getOperationId(sr));
                    System.debug('---Successfully published event---');
                } else {
                    per.isSuccess = false;
                    per.hasError = false;
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                        per.errMsg = err.getMessage();
                    }
                }       
            }
            
            if(throwCustomException){
                // Throw first exception
                throw new CustomException('First exception'); 
            }
            
        }catch(Exception ex){
            per.hasError = true;
            per.errMsg = 'Error Occured:'+ex.getMessage();
            System.debug('---Exception--ex:getMessage--'+ex.getMessage());
            System.debug('---Exception--ex:getLineNumber--'+ex.getLineNumber());
            System.debug('---Exception--ex:getStackTraceString--'+ex.getStackTraceString());
        }
        return per;
    }
    
    
    public class NCRequestWrapper {
        public String Node_Configuration;
        public String NC_JIRA_Ticket_ID;
        public String requestor;
        NCRequestWrapper(String nc, String ncj, String req){
            this.Node_Configuration = nc;
            this.NC_JIRA_Ticket_ID = ncj;
            this.requestor = req;
        }
    }
    
    @testVisible
    private static void  updateNodeConfigJiraStatus(String ncID){
        if(ncID != null && String.isNotBlank(ncID)){
            List<Node_Configuration__c> ncList = [Select Id,recordType.Name,recordType.developerName from Node_Configuration__c where id = :ncID];
            if(ncList.size()>0){
                Node_Configuration__c ncRecord = ncList[0];
                if(ncRecord.recordType.developerName == 'Load_Balancer_Only'){
                    ncRecord.LB_Jira_Integration_Status__c = 'Initiated';
                }else if(ncRecord.recordType.developerName == 'Service_Edge_5_LB' ||
                         ncRecord.recordType.developerName == 'Private_ZEN_with_LB'
                        )
                {
                    ncRecord.Jira_Integration_Status__c = 'Initiated';
                    ncRecord.LB_Jira_Integration_Status__c = 'Initiated';
                }else{
                    ncRecord.Jira_Integration_Status__c = 'Initiated';
                }
                ncRecord.Jira_Integration_Requested_By__c = UserInfo.getUserId();
                update ncRecord;
            }
        }
    }
    
    @auraEnabled (cacheable=true)
    public static DataCenterWrapper  getDataCenterDetails(Id dcID){
        System.debug('---getDataCenterDetails--called--');
        System.debug('---getDataCenterDetails--dcID--'+dcID);
        
        DataCenterWrapper dcw = new DataCenterWrapper();
        try{
            List<Datacenter__c> dcList = [Select id, name, recordtype.name,
                                          Shipment_Receiving_Contact_Name__c,Shipment_Receiving_contact_Email__c,
                                          Shipment_Receiving_Contact_Ph_No__c,Shipping_Address__c,
                                          Requested_Hardware_Model__c,Quantity_Requested__c,
                                          Quantity_Requested_for_LB__c,Project_Manager_Name__c,
                                          Projet_Manager_Email_Address__c,Project_Manager_Phone_No__c,
                                          Facility_Address__c,Facility_City__c,Facility_State__c,
                                          Facility_Country__c,Facility_ZIP_Code__c
                                          
                                          from Datacenter__c where id  = :dcID];
            
            if(dcList.size()>0){
                dcw.hasError = false;
                dcw.dcRecord = dcList[0];
            }else{
                dcw.hasError = true;
                dcw.errMsg = 'Data Center record not found, please try with valid record id.';
            }
        }catch(Exception ex){
            dcw.hasError = true;
            dcw.errMsg = 'Error Occured:'+ex.getMessage();
            System.debug('---Exception--ex:getMessage--'+ex.getMessage());
            System.debug('---Exception--ex:getLineNumber--'+ex.getLineNumber());
            System.debug('---Exception--ex:getStackTraceString--'+ex.getStackTraceString());
        }
        return dcw;
        
    }
    
    public class NodeConfigWrapper{
        @auraEnabled
        public Node_Configuration__c ncRecord;
        @auraEnabled
        public Boolean hasError;
        @auraEnabled
        public string errMsg;
    }
    
    public class DataCenterWrapper{
        @auraEnabled
        public Datacenter__c dcRecord;
        @auraEnabled
        public Boolean hasError;
        @auraEnabled
        public string errMsg;
    }
    
    public class JiraWrapper{
        @auraEnabled
        public NC_JIRA_Ticket__c jrRecord;
        @auraEnabled
        public Boolean hasError;
        @auraEnabled
        public string errMsg;
    }
    
    public class NodeConfigHideWrapper{
        @auraEnabled
        public Boolean isSuccess;
        @auraEnabled
        public Boolean hasError;
        @auraEnabled
        public string errMsg;
    }
    
    public class PlatformEventResultWrapper{
        @auraEnabled
        public Boolean isSuccess;
        @auraEnabled
        public Boolean hasError;
        @auraEnabled
        public string errMsg;
    }
    
    public class CustomException extends Exception {}
}