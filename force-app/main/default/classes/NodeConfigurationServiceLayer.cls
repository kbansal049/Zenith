/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* NodeConfigurationServiceLayer
* @description    This is the Node Configuration Service Layer class, used to handle the all trigger
*                 process.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-12-07
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            Udit Jain
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2022-11-29      IBA-2983 Udit - Automated email to be sent to Customer (CR# 5205).
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class NodeConfigurationServiceLayer {

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-2983 : Automated email to be sent to Customer
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : sendEmailToNcBusiness .
    * @param    NAME : List<Node_Configuration__c> nodeConfigurationList      : Associated to Node_Configuration__c .
    * @param    NAME : Map<Id, Node_Configuration__c> nodeConfigurationOldMap : Associated to node configuration ID and Node_Configuration__c .
    * @return   TYPE : void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void sendEmailToNcBusiness(List<Node_Configuration__c> nodeConfigurationList, Map<Id, Node_Configuration__c> nodeConfigurationOldMap) {
        try{
            Set<Id> nodeConfigurationIdSet = new Set<Id> ();
            List<Node_Configuration__c> nodeConfigurationListWithParentValues = new List<Node_Configuration__c>();
            Map<Id, EmailTemplate> nodeConfigurationIdVsEmailTemplateMap = new Map<Id, EmailTemplate> ();
            List<StaticResource> staticResourceList = new List<StaticResource>();
            List<Messaging.SingleEmailMessage> mailLst = new List<Messaging.SingleEmailMessage> ();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            EmailTemplate nodeConfigurationPendingShipmentTemplate = this.getEmailTemplate(L2O_Constants.NodeConfigurationObject.ET_PENDING_SHIPMENT);
            EmailTemplate nodeConfigurationPendingDeploymentTemplate = this.getEmailTemplate(L2O_Constants.NodeConfigurationObject.ET_PENDING_DEPLOYMENT);
            
            for (Node_Configuration__c nodeConfig: nodeConfigurationList) {
                if (nodeConfigurationOldMap.get(nodeConfig.id).Node_Configuration_Status__c != nodeConfig.Node_Configuration_Status__c 
                    && (nodeConfig.Node_Configuration_Status__c == L2O_Constants.NodeConfigurationObject.STATUS_PENDING_SHIPMENT 
                    || nodeConfig.Node_Configuration_Status__c == L2O_Constants.NodeConfigurationObject.STATUS_PENDING_DEPLOYMENT)
                    && nodeConfig.Datacenter__c !=null) {
                        nodeConfigurationIdSet.add(nodeConfig.Id);
                    if (nodeConfig.Node_Configuration_Status__c == L2O_Constants.NodeConfigurationObject.STATUS_PENDING_SHIPMENT) {
                        nodeConfigurationIdVsEmailTemplateMap.put(nodeConfig.Id, nodeConfigurationPendingShipmentTemplate);
                    }
                    if (nodeConfig.Node_Configuration_Status__c == L2O_Constants.NodeConfigurationObject.STATUS_PENDING_DEPLOYMENT) {
                        nodeConfigurationIdVsEmailTemplateMap.put(nodeConfig.Id, nodeConfigurationPendingDeploymentTemplate);
                    }
                }
            }

            if (!nodeConfigurationIdSet.isEmpty() 
                && !nodeConfigurationIdVsEmailTemplateMap.isEmpty()) {
                nodeConfigurationListWithParentValues = this.fetchNodeConfigurationWithIdSet(nodeConfigurationIdSet);
                staticResourceList = [SELECT Name, Id, Body 
                                      FROM StaticResource 
                                      WHERE Name =: L2O_Constants.NodeConfigurationObject.SR_SHIPPING_NODE_CONFIG 
                                      LIMIT 1];

                for (Node_Configuration__c nodeConfiguration: nodeConfigurationListWithParentValues) {
                    List<String> sendTo = this.validateRecipients(nodeConfiguration);
                    if(!sendTo.isEmpty()){
                        EmailTemplate emailTemplate = nodeConfigurationIdVsEmailTemplateMap.get(nodeConfiguration.Id);
                        mail = new Messaging.SingleEmailMessage();
                        mail.setSubject(emailTemplate.Subject);
                        String emailhtmlValue = this.commonTemplateReplacements(emailTemplate.HtmlValue,nodeConfiguration);
                        emailhtmlValue = this.pendingDeploymentTemplateReplacements(emailhtmlValue,nodeConfiguration,staticResourceList,mail,efa);
                        emailhtmlValue = emailhtmlValue.replace('[location]', nodeConfiguration.Datacenter__r.Facility_Country__c);
                        mail.setHtmlBody(emailhtmlValue);
                        mail.setToAddresses(sendTo);
                        mailLst.add(mail);
                    }
                }
                    
                if (!mailLst.isEmpty()) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mailLst);
                }
            }
        }catch(Exception ex){
            ZscalerErrorLogsUtility.insertLogs('NodeConfigurationServiceLayer', 'sendEmailToNcBusiness', 'Apex',
                    UserInfo.getUserId(), 'Sales Cloud', ex.getStackTraceString(), ex.getMessage(), ex.getTypeName());
        }
        
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-2983 : Automated email to be sent to Customer
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : getEmailTemplate .
    * @param    NAME : String nodeConfigurationTemplate      : Associated to Emale Template Developer Name .
    * @return   TYPE : EmailTemplate
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private EmailTemplate getEmailTemplate(String nodeConfigurationTemplate) {
        List<EmailTemplate> templates = [SELECT Id, Subject, Description, HtmlValue, DeveloperName 
                                         FROM EmailTemplate 
                                         WHERE DeveloperName =: nodeConfigurationTemplate];
        return !templates.isEmpty() ? templates.get(0) : null;
    }

    

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-2983 : Automated email to be sent to Customer
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : validateRecipients .
    * @param    NAME : Node_Configuration__c nodeConfiguration      : Associated to Node_Configuration__c .
    * @return   TYPE : List<String>
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private List<String> validateRecipients(Node_Configuration__c nodeConfiguration){
        List<String> recipientsList = new List<String> ();
        if (nodeConfiguration.Datacenter__r.Projet_Manager_Email_Address__c != null) {
            recipientsList.add(nodeConfiguration.Datacenter__r.Projet_Manager_Email_Address__c);
        }
        if (nodeConfiguration.Datacenter__r.Account__c != null) {
            if (nodeConfiguration.Datacenter__r.Account__r.TAM_Email__c != null)
                recipientsList.add(nodeConfiguration.Datacenter__r.Account__r.TAM_Email__c);
            if (nodeConfiguration.Datacenter__r.Account__r.CSM_Name_New__c != null 
                && nodeConfiguration.Datacenter__r.Account__r.CSM_Name_New__r.Email != null)
                recipientsList.add(nodeConfiguration.Datacenter__r.Account__r.CSM_Name_New__r.Email);
            if (nodeConfiguration.Datacenter__r.Account__r.Sales_Engineer__c != null 
                && nodeConfiguration.Datacenter__r.Account__r.Sales_Engineer__r.Email != null)
                recipientsList.add(nodeConfiguration.Datacenter__r.Account__r.Sales_Engineer__r.Email);
            if (nodeConfiguration.Datacenter__r.Account__r.Account_Manager__c != null 
                && nodeConfiguration.Datacenter__r.Account__r.Account_Manager__r.Email != null)
                recipientsList.add(nodeConfiguration.Datacenter__r.Account__r.Account_Manager__r.Email);
        }
        return recipientsList;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-2983 : Automated email to be sent to Customer
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : fetchNodeConfigurationWithIdSet .
    * @param    NAME : Set<Id> nodeConfigurationIdSet      : Set of Node_Configuration__c Id.
    * @return   TYPE : List<Node_Configuration__c>
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private List<Node_Configuration__c> fetchNodeConfigurationWithIdSet(Set<Id> nodeConfigurationIdSet){
        return [SELECT Id, Node_Configuration_Status__c, Account_Name__c, Datacenter__c, Datacenter__r.Shipment_Receiving_Contact_Name__c, 
                    Datacenter__r.Projet_Manager_Email_Address__c,NC1_Asset_Tag__c, NC2_Asset_Tag__c,
                    Datacenter__r.Shipment_Receiving_contact_Email__c, Datacenter__r.Shipment_Receiving_Contact_Ph_No__c,
                    Datacenter__r.Customer_Contact__r.Name, Datacenter__r.Shipping_Address__c, Datacenter__r.Facility_Country__c,
                    Datacenter__r.Account__c, CreatedById, Equipment_Request__c, Equipment_Request__r.Quantity_requested1__c,
                    Datacenter__r.Account__r.TAM_Email__c, RecordType.DeveloperName, Datacenter__r.Requested_Hardware_Model__c,
                    Datacenter__r.Account__r.CSM_Name_New__c, Datacenter__r.Account__r.CSM_Name_New__r.Email,
                    Datacenter__r.Account__r.Sales_Engineer__c, Datacenter__r.Account__r.Sales_Engineer__r.Email,
                    Datacenter__r.Account__r.Account_Manager__c, Datacenter__r.Account__r.Account_Manager__r.Email,
                	Datacenter__r.Quantity_Requested__c
                FROM Node_Configuration__c 
                WHERE Id IN: nodeConfigurationIdSet 
                LIMIT 10000
                ];
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-2983 : Automated email to be sent to Customer
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : commonTemplateReplacements .
    * @param    NAME : String templateHTMLValue                 : HTML Value of Email Template.
    * @param    NAME : Node_Configuration__c nodeConfiguration  : Data of Node_Configuration__c.
    * @return   TYPE : String
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private String commonTemplateReplacements(String templateHTMLValue,Node_Configuration__c nodeConfiguration){
        templateHTMLValue = templateHTMLValue.replace('[customer name]', nodeConfiguration.Datacenter__r.Shipment_Receiving_Contact_Name__c != null ? nodeConfiguration.Datacenter__r.Shipment_Receiving_Contact_Name__c : '');
        templateHTMLValue = templateHTMLValue.replace('[account name]', nodeConfiguration.Account_Name__c != null ? nodeConfiguration.Account_Name__c : '');
        
        /*if (nodeConfiguration.Equipment_Request__c != null 
            && nodeConfiguration.Equipment_Request__r.Quantity_requested1__c != null) {
            templateHTMLValue = templateHTMLValue.replace('[nanologs]', nodeConfiguration.Equipment_Request__r.Quantity_requested1__c);
        }*/

        if (nodeConfiguration.Datacenter__r.Shipment_Receiving_Contact_Name__c != null
            || nodeConfiguration.Datacenter__r.Shipment_Receiving_contact_Email__c != null
            || nodeConfiguration.Datacenter__r.Shipment_Receiving_Contact_Ph_No__c != null ) {
            String shippingContactValue = nodeConfiguration.Datacenter__r.Shipment_Receiving_Contact_Name__c + '<br>' + nodeConfiguration.Datacenter__r.Shipment_Receiving_contact_Email__c + '<br>' + nodeConfiguration.Datacenter__r.Shipment_Receiving_Contact_Ph_No__c;
            templateHTMLValue = templateHTMLValue.replace('[shippingcontact]', shippingContactValue);
        }

        templateHTMLValue = templateHTMLValue.replace('[shippingDestination]', nodeConfiguration.Datacenter__r.Shipping_Address__c != null ? nodeConfiguration.Datacenter__r.Shipping_Address__c : '');
		
        return templateHTMLValue;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This Method was added as part of JIRA ID IBA-2983 : Automated email to be sent to Customer
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────
    * @method   NAME : pendingDeploymentTemplateReplacements .
    * @param    NAME : String templateHTMLValue                 : HTML Value of Email Template.
    * @param    NAME : Node_Configuration__c nodeConfiguration  : Data of Node_Configuration__c.
    * @param    NAME : List<StaticResource> staticResourceList  : Data of Attachment File.
    * @param    NAME : Messaging.SingleEmailMessage mail  : Data of Mail needs to be sent.
    * @param    NAME : Messaging.EmailFileAttachment efa  : Data of Attachment file to email.
    * @return   TYPE : String
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private String pendingDeploymentTemplateReplacements(String templateHTMLValue,Node_Configuration__c nodeConfiguration,List<StaticResource> staticResourceList,Messaging.SingleEmailMessage mail,Messaging.EmailFileAttachment efa){
        if(nodeConfiguration.Node_Configuration_Status__c == L2O_Constants.NodeConfigurationObject.STATUS_PENDING_DEPLOYMENT){
            if (nodeConfiguration.Node_Configuration_Status__c == L2O_Constants.NodeConfigurationObject.STATUS_PENDING_DEPLOYMENT 
                && !nodeConfiguration.Datacenter__r.Facility_Country__c.containsIgnoreCase('China')) {
                templateHTMLValue = templateHTMLValue.replace(System.Label.Node_Configuration_China_Location, '');
            }
            
            templateHTMLValue = templateHTMLValue.replace(' n ', ' '+String.valueof(nodeConfiguration.Datacenter__r.Quantity_Requested__c)+' ');
            
            if (nodeConfiguration.RecordType.DeveloperName == L2O_Constants.NodeConfigurationObject.RT_PRIVATE_ZEN_WITH_LB 
                || nodeConfiguration.RecordType.DeveloperName == L2O_Constants.NodeConfigurationObject.RT_SERVICE_EDGE_5_LB  
                || nodeConfiguration.Datacenter__r.Requested_Hardware_Model__c == L2O_Constants.DataCenterObject.RHM_SERVICE_EDGE_5 
                || nodeConfiguration.Datacenter__r.Requested_Hardware_Model__c == L2O_Constants.DataCenterObject.RHM_HW6) {
                templateHTMLValue = templateHTMLValue.replace('[10GNote]', System.Label.Node_Configuration_TenG_Connectivity);
            }else{
                templateHTMLValue = templateHTMLValue.replace('[10GNote]', '');
            }

            if (templateHTMLValue.contains('xxxx, xxxx')) {
                String assetTags = String.join(new List<String>{String.valueof(nodeConfiguration.NC1_Asset_Tag__c),String.valueof(nodeConfiguration.NC2_Asset_Tag__c)}, ',');
                templateHTMLValue = templateHTMLValue.replace('xxxx, xxxx', assetTags);
            }

            if (nodeConfiguration.RecordType.DeveloperName == L2O_Constants.NodeConfigurationObject.RT_LOAD_BALANCER_ONLY) {
                templateHTMLValue = templateHTMLValue.replace(System.Label.Node_Configuration_Installation_Instruction, System.Label.Node_Configuration_Load_Balancer_Installation);
            }

            if ((nodeConfiguration.RecordType.DeveloperName == L2O_Constants.NodeConfigurationObject.RT_SI_HTTP_ZEN 
                    || nodeConfiguration.RecordType.DeveloperName == L2O_Constants.NodeConfigurationObject.RT_SERVICE_EDGE) 
                    && nodeConfiguration.Datacenter__r.Requested_Hardware_Model__c != null) {
                if (nodeConfiguration.Datacenter__r.Requested_Hardware_Model__c == L2O_Constants.DataCenterObject.RHM_HW1
                    && !staticResourceList.isEmpty()) {
                    Blob tempBlob = staticResourceList[0].Body;
                    efa = new Messaging.EmailFileAttachment();
                    efa.setBody(tempBlob);
                    efa.setFileName('HW-1 Server-Shipping Insert.pdf');
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] {
                        efa
                    });
                }
                if (nodeConfiguration.Datacenter__r.Requested_Hardware_Model__c == L2O_Constants.DataCenterObject.RHM_SERVICE_EDGE_3) {
                    templateHTMLValue = templateHTMLValue.replace(System.Label.Node_Configuration_Installation_Instruction, System.Label.Node_Configuration_Request_Hardware_3);
                }
                if (nodeConfiguration.Datacenter__r.Requested_Hardware_Model__c == L2O_Constants.DataCenterObject.RHM_HW3) {
                    templateHTMLValue = templateHTMLValue.replace(System.Label.Node_Configuration_Installation_Instruction, System.Label.Node_Configuration_Request_Hardware_3);
                }
                if (nodeConfiguration.Datacenter__r.Requested_Hardware_Model__c == L2O_Constants.DataCenterObject.RHM_SERVICE_EDGE_5) {
                    templateHTMLValue = templateHTMLValue.replace(System.Label.Node_Configuration_Installation_Instruction, System.Label.Node_Configuration_Request_Hardware_6);
                }
                if (nodeConfiguration.Datacenter__r.Requested_Hardware_Model__c == L2O_Constants.DataCenterObject.RHM_HW6) {
                    templateHTMLValue = templateHTMLValue.replace(System.Label.Node_Configuration_Installation_Instruction, System.Label.Node_Configuration_Request_Hardware_6);
                }
            }

            if (nodeConfiguration.RecordType.DeveloperName == L2O_Constants.NodeConfigurationObject.RT_PRIVATE_ZEN_WITH_LB) {
                templateHTMLValue = templateHTMLValue.replace(System.Label.Node_Configuration_Installation_Instruction, System.Label.Node_Configuration_Private_ZEN_Installation);
            }

            if (nodeConfiguration.RecordType.DeveloperName == L2O_Constants.NodeConfigurationObject.RT_SERVICE_EDGE_5_LB) {
                templateHTMLValue = templateHTMLValue.replace(System.Label.Node_Configuration_Installation_Instruction, System.Label.Node_Configuration_Service_Edge_Installation);
            }
        }
        return templateHTMLValue;
    }
}