import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";

import getJiraDetails from "@salesforce/apex/JiraTicketCreationController.getJiraDetails";
import getNCDetails from "@salesforce/apex/JiraTicketCreationController.getNodeConfigDetails";
import getDCDetails from "@salesforce/apex/JiraTicketCreationController.getDataCenterDetails";
import generateEvent from "@salesforce/apex/JiraTicketCreationController.generateJiraPlatFormEvent";
import { loadStyle } from "lightning/platformResourceLoader";

import nCJiraStyle from "@salesforce/resourceUrl/nCJiraTicketCSS";
//import ncWatchers from "@salesforce/label/c.JIRA_Ticket_Watchers";

export default class NCJiraTicketCreation extends NavigationMixin(
  LightningElement
) {
  //label = {
  //  ncWatchers
  //};

  static delegatesFocus = true;
  @track activeSections = ["A", "B", "C", "D", "E", "F", "G", "H"];

  @track currentStep = "1";
  @track ncRecord;
  @track dcRecord;

  @api recordId;
  @api ncJiraTicketId;
  @api nodeConfigId;

  @track ncRecordType;

  @track ncRecordId;
  @track dataCenterId;

  @track customerConInfo;
  @track shippingConInfo;

  @track hardwareType;
  @track lbhardwareType;

  @track quantity;
  @track lbquantity;

  @track dnsServers;
  @track ntpServers;

  @track pubVirtualIp;
  @track privateVirtualIp;
  @track vpnPubVirtualIp;
  @track vpnPrivateVirtualIp;

  @track wireNCData;
  @track wireDCData;

  @track priority = "Minor";
  @track dataCenterVal = "N/A";
  @track provDataCenterVal = "N/A - N/A";
  @track issueType = "ops-privnode-new";

  //Timer For 5 seconds
  intervalID;
  @track count = 0;
  @track completed = 5;

  //NC Details
  @track ncIPMIpublicIp;
  @track nc2IPMIpublicIp;
  @track ncIPMIprivateIp;
  @track nc2IPMIprivateIp;
  @track ncIPMIDefaultGateway;
  @track nc2IPMIDefaultGateway;
  @track ncIPMISubnetNetmask;
  @track nc2IPMISubnetNetmask;
  @track ncPubServicesIP;
  @track nc2PubServicesIP;
  @track ncPrivServicesIP;
  @track nc2PrivServicesIP;
  @track ncServiceCIDRNetmask;
  @track nc2ServiceCIDRNetmask;
  @track ncServiceDefaultGateway;
  @track nc2ServiceDefaultGateway;
  @track ncPublicManagementIP;
  @track nc2PublicManagementIP;
  @track ncPrivateManagementIP;
  @track nc2PrivateManagementIP;
  @track ncManagementSubnetNetmask;
  @track nc2ManagementSubnetNetmask;
  @track ncManagementDefaultGateway;
  @track nc2ManagementDefaultGateway;

  //LB Details
  @track lbIPMIpublicIp;
  @track lb2IPMIpublicIp;
  @track lbIPMIprivateIp;
  @track lb2IPMIprivateIp;
  @track lbIPMIDefaultGateway;
  @track lb2IPMIDefaultGateway;
  @track lbIPMISubnetNetmask;
  @track lb2IPMISubnetNetmask;
  @track lbPubServicesIP;
  @track lb2PubServicesIP;
  @track lbPrivServicesIP;
  @track lb2PrivServicesIP;
  @track lbServiceCIDRNetmask;
  @track lb2ServiceCIDRNetmask;
  @track lbServiceDefaultGateway;
  @track lb2ServiceDefaultGateway;
  @track lbPublicManagementIP;
  @track lb2PublicManagementIP;
  @track lbPrivateManagementIP;
  @track lb2PrivateManagementIP;
  @track lbManagementSubnetNetmask;
  @track lb2ManagementSubnetNetmask;
  @track lbManagementDefaultGateway;
  @track lb2ManagementDefaultGateway;

  @track description;

  @track isLoaded = true;
  @track isModalOpen = false;
  @track hasError = false;
  @track errMsg;

  @wire(getJiraDetails, {
    jiraID: "$recordId"
  })
  wiredJiraDetails({ error, data }) {
    if (data) {
      console.log("--getJiraDetails-", data);
      if (data.hasError) {
        this.hasError = true;
        this.errMsg = data.errMsg;
      } else {
        this.hasError = false;
        this.errMsg = "";
        // eslint-disable-next-line @lwc/lwc/no-api-reassignments
        this.nodeConfigId = data.jrRecord.Node_Configuration__c;
      }
    } else if (error) {
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      console.log("---message--", message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading NC Jira Ticket record.",
          message,
          variant: "error"
        })
      );
      console.log("-getNCDetails--error--", error);
      this.hasError = false;
      this.errMsg = "Error Occured, Please check the details";
    }
  }

  @wire(getNCDetails, {
    ncID: "$nodeConfigId"
  })
  wiredNCDetails({ error, data }) {
    if (data) {
      console.log("--getNCDetails-", data);
      if (data.hasError) {
        this.hasError = true;
        this.errMsg = data.errMsg;
      } else {
        this.hasError = false;
        this.ncRecord = data.ncRecord;
        this.errMsg = "";
        this.ncRecordType = data.ncRecord.RecordType.Name;
        this.prepouplateNCDetails();
        this.activeSections = ["A", "B", "C", "D", "E", "F", "G", "H"];
      }
    } else if (error) {
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      console.log("---message--", message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading Node Configuration record.",
          message,
          variant: "error"
        })
      );

      console.log("-getNCDetails--error--", error);
      this.hasError = false;
      this.errMsg = "Error Occured, Please check the details";
    }
  }

  @wire(getDCDetails, {
    dcID: "$dataCenterId"
  })
  wiredDCDetails({ error, data }) {
    if (data) {
      console.log("--getDCDetails-", data);
      if (data.hasError) {
        this.hasError = true;
        this.errMsg = data.errMsg;
      } else {
        this.hasError = false;
        this.dcRecord = data.dcRecord;
        this.errMsg = "";
        this.prepouplateDCDetails();
      }
    } else if (error) {
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
      console.log("---message--", message);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error loading Data Center record.",
          message,
          variant: "error"
        })
      );

      console.log("-getDCDetails--error--", error);
      this.hasError = false;
      this.errMsg = "Error Occured, Please check the details";
    }
  }

  prepouplateDCDetails() {
    console.log("---prepouplateDCDetails--this.dcRecord --", this.dcRecord);
    if (this.dcRecord) {
      //shipping Contact Details
      let shippingDetails = [];
      let shippName = this.getApexFieldValue(
        this.dcRecord,
        "Shipment_Receiving_Contact_Name__c"
      );
      if (shippName) {
        shippingDetails.push(shippName);
      }
      let shippEmail = this.getApexFieldValue(
        this.dcRecord,
        "Shipment_Receiving_contact_Email__c"
      );
      if (shippEmail) {
        shippingDetails.push(shippEmail);
      }
      let shippPhone = this.getApexFieldValue(
        this.dcRecord,
        "Shipment_Receiving_Contact_Ph_No__c"
      );
      if (shippPhone) {
        shippingDetails.push(shippPhone);
      }
      this.shippingConInfo = shippingDetails.join(", \n");

      //Customer Contact Name and Email
      let contactDetails = [];
      let conName = this.getApexFieldValue(
        this.dcRecord,
        "Shipment_Receiving_Contact_Name__c"
      );
      if (conName) {
        contactDetails.push(conName);
      }
      let conEmail = this.getApexFieldValue(
        this.dcRecord,
        "Shipment_Receiving_contact_Email__c"
      );
      if (conEmail) {
        contactDetails.push(conEmail);
      }
      this.customerConInfo = contactDetails.join(", \n");

      //Hardware Type
      let hardwareModal = this.getApexFieldValue(
        this.dcRecord,
        "Requested_Hardware_Model__c"
      );

      console.log("---ncRecordType----", this.ncRecordType);
      console.log("---hardwareModal----", hardwareModal);

      if (
        this.ncRecordType &&
        this.ncRecordType === "Private Nanolog Cluster"
      ) {
        this.hardwareType = "ZN2860";
      } else {
        this.hardwareType = this.hardwareModal(hardwareModal);
      }

      // Added for CR# 3014
      if (this.ncRecordType === "Service Edge 5 + LB" || 
          this.ncRecordType === "Load Balancer Only"  || 
          this.ncRecordType === "Private ZEN with LB"    ) {
              this.lbhardwareType = "ZN1885";
      } else {
        this.lbhardwareType = this.lbhardwareModal(hardwareModal);
      }

      //Decription Field
      this.description =
        this.getApexFieldValue(this.dcRecord, "Project_Manager_Name__c") +
        "\n" +
        this.getApexFieldValue(
          this.dcRecord,
          "Projet_Manager_Email_Address__c"
        ) +
        "\n" +
        this.getApexFieldValue(this.dcRecord, "Project_Manager_Phone_No__c");
    }
  }

  prepouplateNCDetails() {
    console.log("---prepouplateNCDetails--this.ncRecord --", this.ncRecord);
    if (this.ncRecord) {
      //DataCenter Record ID
      this.dataCenterId = this.getApexFieldValue(
        this.ncRecord,
        "Datacenter__c"
      );

      //Components
      this.ncComponent = this.getComponents(this.ncRecordType);

      //LBComponents
      this.lbComponent = this.getLBComponents(this.ncRecordType);

      //IPMI Details
      this.ncIPMIpublicIp = this.getApexFieldValue(
        this.ncRecord,
        "Public_IPMI_IP__c"
      );
      this.nc2IPMIpublicIp = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Public_IPMI_IP__c"
      );
      this.ncIPMIprivateIp = this.getApexFieldValue(
        this.ncRecord,
        "Private_IPMI_IP__c"
      );
      this.nc2IPMIprivateIp = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Private_IPMI_IP__c"
      );

      //Load Balancer IPMI Details
      this.lbIPMIpublicIp = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Public_IPMI_IP__c"
      );
      this.lb2IPMIpublicIp = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Public_IPMI_IP__c"
      );
      this.lbIPMIprivateIp = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Private_IPMI_IP__c"
      );
      this.lb2IPMIprivateIp = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Private_IPMI_IP__c"
      );

      //IPMI Default Gateway && IPMI Default Gateway (secondary)
      this.ncIPMIDefaultGateway = this.getApexFieldValue(
        this.ncRecord,
        "IPMI_Default_Gateway__c"
      );
      this.nc2IPMIDefaultGateway = this.getApexFieldValue(
        this.ncRecord,
        "NC2_IPMI_Default_Gateway__c"
      );

      //LB IPMI Default Gateway && LB IPMI Default Gateway (secondary)
      this.lbIPMIDefaultGateway = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_IPMI_Default_Gateway__c"
      );
      this.lb2IPMIDefaultGateway = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_IPMI_Default_Gateway__c"
      );

      //IPMI Subnet / Netmask && IPMI Subnet / Netmask (secondary)
      this.ncIPMISubnetNetmask = this.formatToJiraIP(
        this.getApexFieldValue(this.ncRecord, "IPMI_CIDR_Netmask__c")
      );
      this.nc2IPMISubnetNetmask = this.formatToJiraIP(
        this.getApexFieldValue(this.ncRecord, "NC2_IPMI_CIDR_Netmask__c")
      );

      //LB IPMI Subnet / Netmask && LB IPMI Subnet / Netmask (secondary)
      this.lbIPMISubnetNetmask = this.formatToJiraIP(
        this.getApexFieldValue(this.ncRecord, "LBC1_IPMI_Subnet_Netmask__c")
      );
      this.lb2IPMISubnetNetmask = this.formatToJiraIP(
        this.getApexFieldValue(this.ncRecord, "LBC2_IPMI_Subnet_Netmask__c")
      );

      //DNS Servers
      let dnsDetails = [];
      let letDNS1 = this.getApexFieldValue(
        this.ncRecord,
        "Primary_DNS_Recursor__c"
      );
      let letDNS2 = this.getApexFieldValue(
        this.ncRecord,
        "Secondary_DNS_Recursor__c"
      );
      if (letDNS1) {
        dnsDetails.push(letDNS1);
      }
      if (letDNS2) {
        dnsDetails.push(letDNS2);
      }
      this.dnsServers = dnsDetails.join();

      //NTP Servers
      let ntpDetails = [];
      let letNTP1 = this.getApexFieldValue(
        this.ncRecord,
        "Primary_NTP_Server__c"
      );
      let letNTP2 = this.getApexFieldValue(
        this.ncRecord,
        "Secondary_NTP_Server__c"
      );
      if (letNTP1) {
        ntpDetails.push(letNTP1);
      }
      if (letNTP2) {
        ntpDetails.push(letNTP2);
      }
      this.ntpServers = ntpDetails.join();

      //Public Virtual IP
      let pubVPNDetails = [];
      let pubVPN = this.getApexFieldValue(
        this.ncRecord,
        "SI_Public_Virtual_IP__c"
      );
      let pubVPN1 = this.getApexFieldValue(
        this.ncRecord,
        "SI_Public_Virtual_IP_1__c"
      );
      let pubVPN2 = this.getApexFieldValue(
        this.ncRecord,
        "SI_Public_Virtual_IP_2__c"
      );
      let pubVPN3 = this.getApexFieldValue(
        this.ncRecord,
        "Public_Virtual_IP_3__c"
      );
      if (pubVPN) {
        pubVPNDetails.push(pubVPN);
      }
      if (pubVPN1) {
        pubVPNDetails.push(pubVPN1);
      }
      if (pubVPN2) {
        pubVPNDetails.push(pubVPN2);
      }
      if (pubVPN3) {
        pubVPNDetails.push(pubVPN3);
      }
      this.pubVirtualIp = pubVPNDetails.join();

      //Private Virtual IP
      let privVPNDetails = [];
      let priVPN = this.getApexFieldValue(
        this.ncRecord,
        "SI_Private_Virtual_IP__c"
      );
      let priVPN1 = this.getApexFieldValue(
        this.ncRecord,
        "SI_Private_Virtual_IP_1__c"
      );
      let priVPN2 = this.getApexFieldValue(
        this.ncRecord,
        "SI_Private_Virtual_IP_2__c"
      );
      let priVPN3 = this.getApexFieldValue(
        this.ncRecord,
        "Private_Virtual_IP_3__c"
      );
      if (priVPN) {
        privVPNDetails.push(priVPN);
      }
      if (priVPN1) {
        privVPNDetails.push(priVPN1);
      }
      if (priVPN2) {
        privVPNDetails.push(priVPN2);
      }
      if (priVPN3) {
        privVPNDetails.push(priVPN3);
      }
      this.privateVirtualIp = privVPNDetails.join();

      //VPN Public Virtual IP
      this.vpnPubVirtualIp = this.formatToJiraIP(
        this.getApexFieldValue(this.ncRecord, "VPN_Public_Virtual_IP__c")
      );

      //VPN Private Virtual IP
      this.vpnPrivateVirtualIp = this.formatToJiraIP(
        this.getApexFieldValue(this.ncRecord, "VPN_Private_Virtual_IP__c")
      );

      //Public Service(s) IP
      this.fillPublicServiceIP();

      //Public Service(s) IP (secondary)
      this.fillPublicServiceSecondaryIP();

      //Private Service(s) IP
      this.fillPrivateServiceIP();

      //Private Service(s) IP (secondary)
      this.fillPrivateServiceSecondaryIP();

      if (!this.checkifNotLoadBalancerOnly()) {
        //LB Public Service(s) IP
        this.fillLBPublicServiceIPLoadBalancerOnly();
        //LB Public Service(s) IP (secondary)
        this.fillLBPublicServiceSecondaryIPLoadBalancerOnly();
        //LB Private Service(s) IP
        this.fillLBPrivateServiceIPLoadBalancerOnly();
        //LB Private Service(s) IP (secondary)
        this.fillLBPrivateServiceSecondaryIPLoadBalancerOnly();
      } else {
        //LB Public Service(s) IP
        this.fillLBPublicServiceIP();
        //LB Public Service(s) IP (secondary)
        this.fillLBPublicServiceSecondaryIP();
        //LB Private Service(s) IP
        this.fillLBPrivateServiceIP();
        //LB Private Service(s) IP (secondary)
        this.fillLBPrivateServiceSecondaryIP();
      }

      //NC1-Service Subnet / Netmask && NC2-Service Subnet/ Netmask
      this.ncServiceCIDRNetmask = this.formatToJiraIP(
        this.getApexFieldValue(this.ncRecord, "Service_CIDR_Netmask__c")
      );
      this.nc2ServiceCIDRNetmask = this.formatToJiraIP(
        this.getApexFieldValue(this.ncRecord, "NC2_Service_CIDR_Netmask__c")
      );

      //LB LBC1-Service Subnet/Netmask / Netmask && LB LBC2-Service Subnet/Netmask
      this.lbServiceCIDRNetmask = this.formatToJiraIP(
        this.getApexFieldValue(this.ncRecord, "LBC1_Service_Subnet_Netmask__c")
      );
      this.lb2ServiceCIDRNetmask = this.formatToJiraIP(
        this.getApexFieldValue(this.ncRecord, "LBC2_Service_Subnet_Netmask__c")
      );

      //

      //NC1-Service Default Gateway && NC2-Service Default Gateway
      this.ncServiceDefaultGateway = this.getApexFieldValue(
        this.ncRecord,
        "Service_Default_Gateway__c"
      );
      this.nc2ServiceDefaultGateway = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Service_Default_Gateway__c"
      );

      //LBC1-Service Default Gateway && LBC2-Service Default Gateway
      this.lbServiceDefaultGateway = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Service_Default_Gateway__c"
      );
      this.lb2ServiceDefaultGateway = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Service_Default_Gateway__c"
      );

      //

      //Public Management IP && Public Management IP (secondary)
      this.ncPublicManagementIP = this.getApexFieldValue(
        this.ncRecord,
        "Public_Management_IP__c"
      );
      this.nc2PublicManagementIP = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Public_Management_IP__c"
      );

      //LBC1-Public Management IP && LBC2-Public Management IP
      this.lbPublicManagementIP = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Public_Management_IP__c"
      );
      this.lb2PublicManagementIP = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Public_Management_IP__c"
      );

      //

      //Private Management IP && Private Management IP (secondary)
      this.ncPrivateManagementIP = this.getApexFieldValue(
        this.ncRecord,
        "Private_Management_IP__c"
      );
      this.nc2PrivateManagementIP = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Private_Management_IP__c"
      );

      //LBC1-Private Management IP && LBC2-Private Management IP
      this.lbPrivateManagementIP = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Private_Management_IP__c"
      );
      this.lb2PrivateManagementIP = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Private_Management_IP__c"
      );

      //

      //Management Subnet / Netmask && Management Subnet / Netmask (secondary)
      this.ncManagementSubnetNetmask = this.formatToJiraIP(
        this.getApexFieldValue(this.ncRecord, "Management_CIDR__c")
      );
      this.nc2ManagementSubnetNetmask = this.formatToJiraIP(
        this.getApexFieldValue(this.ncRecord, "NC2_Management_CIDR_Netmask__c")
      );

      //LBC1-Management Subnet / Netmask && LBC2-Management Subnet / Netmask
      this.lbManagementSubnetNetmask = this.formatToJiraIP(
        this.getApexFieldValue(
          this.ncRecord,
          "LBC1_Management_Subnet_Netmask__c"
        )
      );
      this.lb2ManagementSubnetNetmask = this.formatToJiraIP(
        this.getApexFieldValue(
          this.ncRecord,
          "LBC2_Management_Subnet_Netmask__c"
        )
      );

      //

      //Management Default Gateway && Management Default Gateway (secondary)
      this.ncManagementDefaultGateway = this.getApexFieldValue(
        this.ncRecord,
        "Management_Default_Gateway__c"
      );
      this.nc2ManagementDefaultGateway = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Management_Default_Gateway__c"
      );

      //LBC1-Management Default Gateway && LBC2-Management Default Gateway
      this.lbManagementDefaultGateway = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Management_Default_Gateway__c"
      );
      this.lb2ManagementDefaultGateway = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Management_Default_Gateway__c"
      );

      //Quantity
      if (
        this.ncRecordType &&
        this.ncRecordType === "Private Nanolog Cluster"
      ) {
        this.quantity = "1";
      } else {
        let pubIP = this.getApexFieldValue(
          this.ncRecord,
          "NC2_Public_IPMI_IP__c"
        );
        if (pubIP && pubIP.length > 0) {
          this.quantity = "2";
        } else {
          this.quantity = "1";
        }
      }

      //LB Quantity
      this.lbquantity = "2";
    }
  }

  connectedCallback() {
    Promise.all([loadStyle(this, nCJiraStyle)]);

    console.log("--connectedCallback called starts--");
    console.log("--nodeConfigId--", this.nodeConfigId);
    console.log("--recordId--", this.recordId);
    console.log("--ncJiraTicketId--", this.ncJiraTicketId);
    console.log("--connectedCallback called ends--");
    this.currentStep = "1";
  }

  handleSubmit(event) {
    this.isLoaded = false;
    event.preventDefault();
    // Get data from submitted form
    let fields = event.detail.fields;
    console.log("--handleSubmit--", fields);
    fields.Show_JIRA_Integartion__c = false;
    // You need to submit the form after modifications
    this.template.querySelector("lightning-record-edit-form").submit(fields);
  }

  handleSuccess(event) {
    console.log("onsuccess event recordEditForm", event.detail.id);
    // eslint-disable-next-line @lwc/lwc/no-api-reassignments
    this.recordId = event.detail.id;
    this.fireToastEvent(
      "Success",
      "NC Jira Ticket record saved successfully.",
      "success"
    );
    this.currentStep = "2";
    this.isLoaded = true;
  }

  handleError(event) {
    this.isLoaded = true;
    console.log("onerror event recordEditForm", event);
  }

  backToFirstStep() {
    this.currentStep = "1";
  }

  openModal() {
    this.isModalOpen = true;
  }
  closeModal() {
    this.isModalOpen = false;
  }
  submitDetails() {
    this.isModalOpen = false;
    this.submitToJira();
  }

  submitToJira(event) {
    this.isLoaded = false;
    console.log("---submitToJira--called---");
    console.log("---submitToJira--event---", event);
    console.log("---submitToJira--recordId---", this.recordId);
    console.log("---submitToJira--nodeConfigId---", this.nodeConfigId);
    if (this.recordId) {
      generateEvent({
        jiraID: this.recordId,
        ncID: this.nodeConfigId
      })
        .then((result) => {
          this.isLoaded = true;
          console.log("---submitToJira--result--", result);
          if (result.isSuccess) {
            let msg = "Integation Request generated successfully";
            this.fireToastEvent("Success", msg, "success");
            this.currentStep = "3";
          } else {
            this.isLoaded = true;
            this.fireToastEvent("Error Occured,", result.errMsg, "error");
            this.currentStep = "2";
          }

          //Timer Code Starts
          // eslint-disable-next-line @lwc/lwc/no-async-operation
          this.intervalID = setInterval(
            function () {
              this.count++;
              console.log("--count--", this.count);
              if (this.count === this.completed) {
                clearInterval(this.intervalID);
                this.navigateToNodeConfig();
              }
            }.bind(this),
            1000
          );
          //Timer Code Ends
        })
        .catch((error) => {
          this.isLoaded = true;
          this.currentStep = "2";
          console.log("---error--", error);
          const evt = new ShowToastEvent({
            title:
              "Integation Request generation failed, Please contact administartor.",
            message: "Record ID: " + this.recordId,
            variant: "error"
          });
          this.dispatchEvent(evt);
        });
    }
  }

  nodeConfigChangeHandler(event) {
    console.log("--nodeConfigChangeHandler--ncID--", event.detail.value);
    console.log("--nodeConfigChangeHandler--ncID--", event.target.value);
    if (event.target.value) {
      // eslint-disable-next-line @lwc/lwc/no-api-reassignments
      this.nodeConfigId = event.target.value;
    }
  }

  get checkIfManadtoryForSecondary() {
    return this.quantity && this.quantity === "2" ? true : false;
  }

  get checkIfNewRecordCreation() {
    return this.isRecordEmpty(this.recordId) === true ? true : false;
  }

  get dataCenterName() {
    return this.ncRecord !== undefined
      ? this.getApexParentFieldValue(this.ncRecord, "Datacenter__r", "Name")
      : "";
  }

  get opportunityName() {
    return this.ncRecord !== undefined &&
      this.ncRecord &&
      this.getApexFieldValue(this.ncRecord, "Opportunity_Name__c")
      ? this.getApexFieldValue(this.ncRecord, "Opportunity_Name__c")
      : "";
  }

  get equipmentRequestName() {
    return this.ncRecord !== undefined
      ? this.getApexParentFieldValue(
          this.ncRecord,
          "Equipment_Request__r",
          "Name"
        )
      : "";
  }

  get customerName() {
    return this.ncRecord !== undefined && this.ncRecord
      ? this.getApexFieldValue(this.ncRecord, "Account_Name__c")
      : "";
  }

  get checkIfDataCenterRecordLoaded() {
    return this.isRecordEmpty(this.ncRecord) === true ? false : true;
  }

  get shippingContact() {
    return this.dcRecord !== undefined
      ? this.getApexFieldValue(
          this.dcRecord,
          "Shipment_Receiving_Contact_Name__c"
        )
      : "";
  }

  get shippingEmail() {
    return this.dcRecord !== undefined
      ? this.getApexFieldValue(
          this.dcRecord,
          "Shipment_Receiving_contact_Email__c"
        )
      : "";
  }

  get shippingPhone() {
    return this.dcRecord !== undefined
      ? this.getApexFieldValue(
          this.dcRecord,
          "Shipment_Receiving_Contact_Ph_No__c"
        )
      : "";
  }

  get shippingAddress() {
    //Facility Details to be added
    let shippingAddress = [];
    if (this.dcRecord !== undefined) {
      let shippAdd = this.getApexFieldValue(
        this.dcRecord,
        "Shipping_Address__c"
      );
      if (shippAdd) {
        shippingAddress.push(shippAdd);
        shippingAddress.push("\n");
      }

      //Facilty Street
      let flStreet = this.getApexFieldValue(
        this.dcRecord,
        "Facility_Address__c"
      );
      if (shippAdd) {
        shippingAddress.push(flStreet);
      }

      //Facilty City
      let facilityDet = [];
      let flcity = this.getApexFieldValue(this.dcRecord, "Facility_City__c");
      if (flcity) {
        facilityDet.push(flcity);
      }

      //Facilty State + ZIP
      let facilityStateZIP = [];
      let flstate = this.getApexFieldValue(this.dcRecord, "Facility_State__c");
      let flzip = this.getApexFieldValue(this.dcRecord, "Facility_ZIP_Code__c");
      if (flstate) {
        facilityStateZIP.push(flstate);
      }
      if (flzip) {
        facilityStateZIP.push(flzip);
      }
      if (facilityStateZIP.length > 0) {
        facilityDet.push(facilityStateZIP.join(" "));
      }

      //Facilty Country
      let flcountry = this.getApexFieldValue(
        this.dcRecord,
        "Facility_Country__c"
      );
      if (flcountry) {
        facilityDet.push(flcountry);
      }

      if (facilityDet.length > 0) {
        shippingAddress.push(facilityDet.join(","));
      }
    }
    return shippingAddress.length > 0 ? shippingAddress.join("\n") : "";
  }

  get checkIfShowNCFields() {
    return this.checkifNotLoadBalancerOnly();
  }

  checkifNotLoadBalancerOnly() {
    return this.ncRecordType && this.ncRecordType !== "Load Balancer Only"
      ? true
      : false;
  }

  get checkIfNanoLog() {
    return this.ncRecordType && this.ncRecordType === "Private Nanolog Cluster"
      ? true
      : false;
  }

  get checkIfShowLBFields() {
    console.log("---checkIfShowLBFields--", this.ncRecordType);
    return this.ncRecordType &&
      (this.ncRecordType === "Load Balancer Only" ||
        this.ncRecordType === "Private ZEN with LB" ||
        this.ncRecordType === "Service Edge 5 + LB")
      ? true
      : false;
  }

  get checkIFNodeConfigPresent() {
    return this.isRecordEmpty(this.nodeConfigId) ? true : false;
  }

  getApexFieldValue(record, field) {
    return record && record[field] ? record[field] : "";
  }

  getApexParentFieldValue(record, parentField, field) {
    return record && record[parentField] && record[parentField][field]
      ? record[parentField][field]
      : "";
  }

  fillPublicServiceIP() {
    //Public Service(s) IP

    if (this.ncRecord) {
      let pubServerIPs = [];

      let letSMLBIP = this.getApexFieldValue(
        this.ncRecord,
        "Load_Balance_Public_IP__c"
      );
      let letPubIP1 = this.getApexFieldValue(
        this.ncRecord,
        "SI_Public_Service_IP__c"
      );
      let letPubIP2 = this.getApexFieldValue(
        this.ncRecord,
        "Public_Service_IP_2__c"
      );
      let letPubIP3 = this.getApexFieldValue(
        this.ncRecord,
        "Public_Service_IP_3__c"
      );
      let letPubIP4 = this.getApexFieldValue(
        this.ncRecord,
        "NC1_Public_Service_IP_4__c"
      );
      let letPubIP5 = this.getApexFieldValue(
        this.ncRecord,
        "NC1_Public_Service_IP_5__c"
      );
      let letPubIP6 = this.getApexFieldValue(
        this.ncRecord,
        "NC1_Public_Service_IP_6__c"
      );
      let letPubZVPNIP = this.getApexFieldValue(
        this.ncRecord,
        "VPN_Public_IP__c"
      );
     
     // let letMTSIP = this.getApexFieldValue(this.ncRecord, "MTS_IP_1__c");

      if (
        this.ncRecordType === "Private ZEN" ||
        this.ncRecordType === "Service Edge"
      ) {
        if (letSMLBIP) {
          pubServerIPs.push("SMLB A:" + letSMLBIP);
        }
      }
      if (letPubIP1) {
        pubServerIPs.push("SME 1A:" + letPubIP1);
      }
      if (letPubIP2) {
        pubServerIPs.push("SME 2A:" + letPubIP2);
      }
      if (letPubIP3) {
        pubServerIPs.push("SME 3A:" + letPubIP3);
      }
      if (letPubIP4) {
        pubServerIPs.push("SME 4A:" + letPubIP4);
      }
      if (letPubIP5) {
        pubServerIPs.push("SME 5A:" + letPubIP5);
      }
      if (letPubIP6) {
        pubServerIPs.push("SME 6A:" + letPubIP6);
      }
      if (
        this.ncRecordType === "Private ZEN" ||
        this.ncRecordType === "Service Edge"
      ) {
        if (letPubZVPNIP) {
          pubServerIPs.push("ZVPN A:" + letPubZVPNIP);
        }
      }
      /* Removing MTS at SME level CR# 2594
      if (letMTSIP) {
        pubServerIPs.push("MTS A:" + letMTSIP);
      }
      */
      console.log("---fillPublicServiceIP--", pubServerIPs);
      this.ncPubServicesIP = pubServerIPs.join("\n");
    }
  }

  fillPublicServiceSecondaryIP() {
    //Public Service(s) IP (secondary)
    if (this.ncRecord) {
      let pub2ServerIPs = [];

      let letSMLB2IP = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Load_Balance_Public_IP__c"
      );
      let letPub2IP1 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Public_Service_IP_1__c"
      );
      let letPub2IP2 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Public_Service_IP_2__c"
      );
      let letPub2IP3 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Public_Service_IP_3__c"
      );
      let letPub2IP4 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Public_Service_IP_4__c"
      );
      let letPub2IP5 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Public_Service_IP_5__c"
      );
      let letPub2IP6 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Public_Service_IP_6__c"
      );
      let letPubZVPN2IP = this.getApexFieldValue(
        this.ncRecord,
        "NC2_VPN_Public_IP__c"
      );
      //let letMTS2IP = this.getApexFieldValue(this.ncRecord, "MTS_IP_2__c");

      if (
        this.ncRecordType === "Private ZEN" ||
        this.ncRecordType === "Service Edge"
      ) {
        if (letSMLB2IP) {
          pub2ServerIPs.push("SMLB B:" + letSMLB2IP);
        }
      }
      if (letPub2IP1) {
        pub2ServerIPs.push("SME 1B:" + letPub2IP1);
      }
      if (letPub2IP2) {
        pub2ServerIPs.push("SME 2B:" + letPub2IP2);
      }
      if (letPub2IP3) {
        pub2ServerIPs.push("SME 3B:" + letPub2IP3);
      }
      if (letPub2IP4) {
        pub2ServerIPs.push("SME 4B:" + letPub2IP4);
      }
      if (letPub2IP5) {
        pub2ServerIPs.push("SME 5B:" + letPub2IP5);
      }
      if (letPub2IP6) {
        pub2ServerIPs.push("SME 6B:" + letPub2IP6);
      }
      if (
        this.ncRecordType === "Private ZEN" ||
        this.ncRecordType === "Service Edge"
      ) {
        if (letPubZVPN2IP) {
          pub2ServerIPs.push("ZVPN B:" + letPubZVPN2IP);
        }
      }
     /* Removing MTS at SME level CR# 2594 
      if (letMTS2IP) {
        pub2ServerIPs.push("MTS B:" + letMTS2IP);
      }  
       */
      console.log("---fillPublicServiceSecondaryIP--", pub2ServerIPs);
      this.nc2PubServicesIP = pub2ServerIPs.join("\n");
    }
  }

  fillLBPublicServiceIP() {
    //LB Public Service(s) IP
    if (this.ncRecord) {
      let publbServerIPs = [];
      let letlbPubIP1 = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Public_Service_IP_1__c"
      );
      let letlbPubIP2 = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Public_Service_IP_2__c"
      );
      let letlbPubIP3 = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Public_Service_IP_3__c"
      );
      if (letlbPubIP1) {
        publbServerIPs.push("SMLB 1A:" + letlbPubIP1);
      }
      if (letlbPubIP2) {
        publbServerIPs.push("SMLB 2A:" + letlbPubIP2);
      }
      if (letlbPubIP3) {
        publbServerIPs.push("SMLB 3A:" + letlbPubIP3);
      }
      	 //Adding MTS for CR# 2594
      if (
          this.ncRecordType === "Private ZEN with LB" ||
          this.ncRecordType === "Service Edge 5 + LB"   ) {
             
          let letMTSIP = this.getApexFieldValue(this.ncRecord, "MTS_IP_1__c");
          if (letMTSIP && letlbPubIP1) {
                 publbServerIPs.push("MTS A:" + letMTSIP);
             }
      }
      console.log("---fillLBPublicServiceIP--", publbServerIPs);
      this.lbPubServicesIP = publbServerIPs.join("\n");
    }
  }

  fillLBPublicServiceSecondaryIP() {
    //LB Public Service(s) IP (secondary)
    if (this.ncRecord) {
      let publb2ServerIPs = [];
      let letPublb2IP1 = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Public_Service_IP_1__c"
      );
      let letPublb2IP2 = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Public_Service_IP_2__c"
      );
      let letPublb2IP3 = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Public_Service_IP_3__c"
      );
      if (letPublb2IP1) {
        publb2ServerIPs.push("SMLB 1B:" + letPublb2IP1);
      }
      if (letPublb2IP2) {
        publb2ServerIPs.push("SMLB 2B:" + letPublb2IP2);
      }
      if (letPublb2IP3) {
        publb2ServerIPs.push("SMLB 3B:" + letPublb2IP3);
      }

        //Adding MTS for CR# 2594
      if (
          this.ncRecordType === "Private ZEN with LB" ||
          this.ncRecordType === "Service Edge 5 + LB"   ) {
          
            let letMTS2IP = this.getApexFieldValue(this.ncRecord, "MTS_IP_2__c");
            if (letMTS2IP && letPublb2IP1) {
                 publb2ServerIPs.push("MTS B:" + letMTS2IP);
            }
      }
      console.log("---fillLBPublicServiceSecondaryIP--", publb2ServerIPs);
      this.lb2PubServicesIP = publb2ServerIPs.join("\n");
    }
  }

  fillPrivateServiceIP() {
    //Private Service(s) IP
    if (this.ncRecord) {
      let privServerIPs = [];

      let letPrivIPLB = this.getApexFieldValue(
        this.ncRecord,
        "Load_Balance_Private_IP__c"
      );
      let letPrivIP1 = this.getApexFieldValue(
        this.ncRecord,
        "SI_Private_Service_IP__c"
      );
      let letPrivIP2 = this.getApexFieldValue(
        this.ncRecord,
        "Private_Service_IP_2__c"
      );
      let letPrivIP3 = this.getApexFieldValue(
        this.ncRecord,
        "Private_Service_IP_3__c"
      );
      let letPrivIP4 = this.getApexFieldValue(
        this.ncRecord,
        "NC1_Private_Service_IP_4__c"
      );
      let letPrivIP5 = this.getApexFieldValue(
        this.ncRecord,
        "NC1_Private_Service_IP_5__c"
      );
      let letPrivIP6 = this.getApexFieldValue(
        this.ncRecord,
        "NC1_Private_Service_IP_6__c"
      );
      let letPrivZVPNIP = this.getApexFieldValue(
        this.ncRecord,
        "VPN_Private_IP__c"
      );

      if (letPrivIPLB) {
        privServerIPs.push("SMLB A:" + letPrivIPLB);
      }
      if (letPrivIP1) {
        privServerIPs.push("SME 1A:" + letPrivIP1);
      }
      if (letPrivIP2) {
        privServerIPs.push("SME 2A:" + letPrivIP2);
      }
      if (letPrivIP3) {
        privServerIPs.push("SME 3A:" + letPrivIP3);
      }
      if (letPrivIP4) {
        privServerIPs.push("SME 4A:" + letPrivIP4);
      }
      if (letPrivIP5) {
        privServerIPs.push("SME 5A:" + letPrivIP5);
      }
      if (letPrivIP6) {
        privServerIPs.push("SME 6A:" + letPrivIP6);
      }
      if (
        this.ncRecordType === "Private ZEN" ||
        this.ncRecordType === "Service Edge"
      ) {
        if (letPrivZVPNIP) {
          privServerIPs.push("ZVPN A:" + letPrivZVPNIP);
        }
      }
      console.log("---fillPrivateServiceIP--", privServerIPs);
      this.ncPrivServicesIP = privServerIPs.join("\n");
    }
  }

  fillPrivateServiceSecondaryIP() {
    //Private Service(s) IP (secondary)
    if (this.ncRecord) {
      let priv2ServerIPs = [];

      let letPrivIPLB2 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Load_Balance_Private_IP__c"
      );
      let letPriv2IP1 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Private_Service_IP_1__c"
      );
      let letPriv2IP2 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Private_Service_IP_2__c"
      );
      let letPriv2IP3 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Private_Service_IP_3__c"
      );
      let letPriv2IP4 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Private_Service_IP_4__c"
      );
      let letPriv2IP5 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Private_Service_IP_5__c"
      );
      let letPriv2IP6 = this.getApexFieldValue(
        this.ncRecord,
        "NC2_Private_Service_IP_6__c"
      );
      let letPrivZVPN2IP = this.getApexFieldValue(
        this.ncRecord,
        "NC2_VPN_Private_IP__c"
      );

      
      if (letPrivIPLB2) {
        priv2ServerIPs.push("SMLB B:" + letPrivIPLB2);
      }
      if (letPriv2IP1) {
        priv2ServerIPs.push("SME 1B:" + letPriv2IP1);
      }
      if (letPriv2IP2) {
        priv2ServerIPs.push("SME 2B:" + letPriv2IP2);
      }
      if (letPriv2IP3) {
        priv2ServerIPs.push("SME 3B:" + letPriv2IP3);
      }
      if (letPriv2IP4) {
        priv2ServerIPs.push("SME 4B:" + letPriv2IP4);
      }
      if (letPriv2IP5) {
        priv2ServerIPs.push("SME 5B:" + letPriv2IP5);
      }
      if (letPriv2IP6) {
        priv2ServerIPs.push("SME 6B:" + letPriv2IP6);
      }
      if (
        this.ncRecordType === "Private ZEN" ||
        this.ncRecordType === "Service Edge"
      ) {
        if (letPrivZVPN2IP) {
          priv2ServerIPs.push("ZVPN B:" + letPrivZVPN2IP);
        }
      }
      console.log("---fillPrivateServiceSecondaryIP--", priv2ServerIPs);
      this.nc2PrivServicesIP = priv2ServerIPs.join("\n");
    }
  }

  fillLBPrivateServiceIP() {
    //LB Private Service(s) IP
    if (this.ncRecord) {
      let privLBServerIPs = [];

      let letPrivlbIP1 = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Private_Service_IP_1__c"
      );
      let letPrivlbIP2 = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Private_Service_IP_2__c"
      );
      let letPrivlbIP3 = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Private_Service_IP_3__c"
      );
      if (letPrivlbIP1) {
        privLBServerIPs.push("SMLB 1A:" + letPrivlbIP1);
      }
      if (letPrivlbIP2) {
        privLBServerIPs.push("SMLB 2A:" + letPrivlbIP2);
      }
      if (letPrivlbIP3) {
        privLBServerIPs.push("SMLB 3A:" + letPrivlbIP3);
      }
      //Adding MTS for CR# 2594
      if (
        this.ncRecordType === "Private ZEN with LB" ||
        this.ncRecordType === "Service Edge 5 + LB"   ) {
           let letMTSIP = this.getApexFieldValue(this.ncRecord, "MTS_IP_1__c");
           if (letMTSIP && letPrivlbIP1) {
               privLBServerIPs.push("MTS A:" + letMTSIP);
          }
        }
      console.log("---fillLBPrivateServiceIP--", privLBServerIPs);
      this.lbPrivServicesIP = privLBServerIPs.join("\n");
    }
  }

  fillLBPrivateServiceSecondaryIP() {
    //LB Private Service(s) IP (secondary)
    if (this.ncRecord) {
      let privlb2ServerIPs = [];
      let letPrivlb2IP1 = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Private_Service_IP_1__c"
      );
      let letPrivlb2IP2 = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Private_Service_IP_2__c"
      );
      let letPrivlb2IP3 = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Private_Service_IP_3__c"
      );

      if (letPrivlb2IP1) {
        privlb2ServerIPs.push("SMLB 1B:" + letPrivlb2IP1);
      }
      if (letPrivlb2IP2) {
        privlb2ServerIPs.push("SMLB 2B:" + letPrivlb2IP2);
      }
      if (letPrivlb2IP3) {
        privlb2ServerIPs.push("SMLB 3B:" + letPrivlb2IP3);
      }
       //Adding MTS for CR# 2594
       if (
        this.ncRecordType === "Private ZEN with LB" ||
        this.ncRecordType === "Service Edge 5 + LB"   ) {
           let letMTS2IP = this.getApexFieldValue(this.ncRecord, "MTS_IP_2__c");
           if (letMTS2IP && letPrivlb2IP1) {
                privlb2ServerIPs.push("MTS B:" + letMTS2IP);
           }
        }
      console.log("---fillLBPrivateServiceSecondaryIP--", privlb2ServerIPs);
      this.lb2PrivServicesIP = privlb2ServerIPs.join("\n");
    }
  }

  //For Record Type : Load Balancer only
  fillLBPublicServiceIPLoadBalancerOnly() {
    //LB Public Service(s) IP
    if (this.ncRecord) {
      let publbServerIPs = [];
      let letlbPubIP1 = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Load_Balance_Public_IP_1__c"
      );
      let letlbPubIP2 = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Load_Balance_Public_IP_2__c"
      );
      if (letlbPubIP1) {
        publbServerIPs.push("SMLB 1A:" + letlbPubIP1);
      }
      if (letlbPubIP2) {
        publbServerIPs.push("SMLB 2A:" + letlbPubIP2);
      }
      
      //Adding MTS for CR# 2594
      if (this.ncRecordType === "Load Balancer Only"  ) {
          
          let letMTSIP = this.getApexFieldValue(this.ncRecord, "MTS_IP_1__c");
          if (letMTSIP && letlbPubIP1) {
              publbServerIPs.push("MTS A:" + letMTSIP);
         }
      } 
      console.log("---fillLBPublicServiceIPLoadBalancerOnly--", publbServerIPs);
      this.lbPubServicesIP = publbServerIPs.join("\n");
    }
  }

  fillLBPublicServiceSecondaryIPLoadBalancerOnly() {
    //LB Public Service(s) IP (secondary)
    if (this.ncRecord) {
      let publb2ServerIPs = [];
      let letPublb2IP1 = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Load_Balance_Public_IP_1__c"
      );
      let letPublb2IP2 = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Load_Balance_Public_IP_2__c"
      );
      if (letPublb2IP1) {
        publb2ServerIPs.push("SMLB 1B:" + letPublb2IP1);
      }
      if (letPublb2IP2) {
        publb2ServerIPs.push("SMLB 2B:" + letPublb2IP2);
      }
      
      //Adding MTS for CR# 2594
      if (this.ncRecordType === "Load Balancer Only"  ) {
          
        let letMTS2IP = this.getApexFieldValue(this.ncRecord, "MTS_IP_2__c");
        if (letMTS2IP && letPublb2IP1) {
          publb2ServerIPs.push("MTS B:" + letMTS2IP);
       }
    } 
      console.log(
        "---fillLBPublicServiceSecondaryIPLoadBalancerOnly--",
        publb2ServerIPs
      );
      this.lb2PubServicesIP = publb2ServerIPs.join("\n");
    }
  }

  fillLBPrivateServiceIPLoadBalancerOnly() {
    //LB Private Service(s) IP
    if (this.ncRecord) {
      let privLBServerIPs = [];

      let letPrivlbIP1 = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Load_Balance_Private_IP_1__c"
      );
      let letPrivlbIP2 = this.getApexFieldValue(
        this.ncRecord,
        "LBC1_Load_Balance_Private_IP_2__c"
      );

      if (letPrivlbIP1) {
        privLBServerIPs.push("SMLB 1A:" + letPrivlbIP1);
      }
      if (letPrivlbIP2) {
        privLBServerIPs.push("SMLB 2A:" + letPrivlbIP2);
      }
       //Adding MTS for CR# 2594
      if (this.ncRecordType === "Load Balancer Only"  ) {
           let letMTSIP = this.getApexFieldValue(this.ncRecord, "MTS_IP_1__c");
           if (letMTSIP && letPrivlbIP1) {
            privLBServerIPs.push("MTS A:" + letMTSIP);
            }
      } 
      console.log(
        "---fillLBPrivateServiceIPLoadBalancerOnly--",
        privLBServerIPs
      );
      this.lbPrivServicesIP = privLBServerIPs.join("\n");
    }
  }

  fillLBPrivateServiceSecondaryIPLoadBalancerOnly() {
    //LB Private Service(s) IP (secondary)
    if (this.ncRecord) {
      let privlb2ServerIPs = [];
      let letPrivlb2IP1 = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Load_Balance_Private_IP_1__c"
      );
      let letPrivlb2IP2 = this.getApexFieldValue(
        this.ncRecord,
        "LBC2_Load_Balance_Private_IP_2__c"
      );
      if (letPrivlb2IP1) {
        privlb2ServerIPs.push("SMLB 1B:" + letPrivlb2IP1);
      }
      if (letPrivlb2IP2) {
        privlb2ServerIPs.push("SMLB 2B:" + letPrivlb2IP2);
      }
      
       //Adding MTS for CR# 2594
      if (this.ncRecordType === "Load Balancer Only"  ) {
          let letMTS2IP = this.getApexFieldValue(this.ncRecord, "MTS_IP_2__c");
          if (letMTS2IP && letPrivlb2IP1) {
                 privlb2ServerIPs.push("MTS B:" + letMTS2IP);
          }
      } 
      console.log(
        "---fillLBPrivateServiceSecondaryIPLoadBalancerOnly--",
        privlb2ServerIPs
      );
      this.lb2PrivServicesIP = privlb2ServerIPs.join("\n");
    }
  }

 // Added  Cr# 3014, IBA-6087 changes
  hardwareModal(inpModal) {
    let retModal;
    switch (inpModal) {
      case "HW-3":
        retModal = "ZN1887";
        break;
      case "HW-6":
        retModal = "ZN1875";
        break;
      case "ZIA – Service Edge 3":
        retModal = "ZN1887";
        break;
      case "ZIA – Service Edge 5":
        retModal = "ZN1875";
        break;
      case "ZIA Service Edge-5 + LB (>5Gbps only)":
        retModal = "ZN1875";
        break;
      case "HW-1 (Replacement Only)":
        retModal = "ZN1865";
        break;
      default:
        retModal = "";
      // code block
    }
    return retModal;
  }

  //IBA-6087 changes
  lbhardwareModal(inpModal) {
    let retModal;
    switch (inpModal) {
      case "HW-3":
        retModal = "ZN1882";
        break;
      case "HW-6":
        retModal = "ZN1870";
        break;
      case "ZIA – Service Edge 3":
        retModal = "ZN1885";
        break;
      case "ZIA – Service Edge 5":
        retModal = "ZN1885";
        break;
      case "ZIA Service Edge-5 + LB (>5Gbps only)":
        retModal = "ZN1885";
        break;
      case "HW-1 (Replacement Only)":
        retModal = "ZN1865";
        break;
      default:
        retModal = "";
      // code block
    }
    return retModal;
  }

  // IBA-6087 changes
  getComponents(inp) {
    let retModal;
    switch (inp) {
      case "Private Nanolog Cluster":
        retModal = "SMSM";
        break;
      case "Private ZEN":
        retModal = "SME";
        break;
      case "Private ZEN with LB":
        retModal = "SME";
        break;
      case "Service Edge":
        retModal = "SME";
        break;
      case "Service Edge 5 + LB":
        retModal = "SME";
        break;
      default:
        retModal = "";
      // code block
    }
    return retModal;
  }

  getLBComponents(inp) {
    let retModal;
    switch (inp) {
      case "Load Balancer Only":
        retModal = "SMLB";
        break;
      case "Private ZEN with LB":
        retModal = "SMLB";
        break;
      case "Service Edge 5 + LB":
        retModal = "SMLB";
        break;
      default:
        retModal = "";
      // code block
    }
    return retModal;
  }

  isRecordEmpty(value) {
    return value ? false : true;
  }

  formatToJiraIP(ip) {
    return ip
      ? ip.replaceAll("(", "").replaceAll(")", "").split(" ").join(" - ")
      : "";
  }

  fireToastEvent(title, message, variant) {
    //Lightning Toast
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);

    //VF PAge Toast
    const vfPageSuccessToast = new CustomEvent("showToastOnVF", {
      detail: {
        title: title,
        message: message,
        variant: variant
      },
      bubbles: true,
      composed: true
    });
    // Fire the custom event
    this.dispatchEvent(vfPageSuccessToast);
  }

  navigateToNodeConfig() {
    console.log("--navigateToNodeConfig--", this.nodeConfigId);
    if (this.nodeConfigId) {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: this.nodeConfigId,
          objectApiName: "Node_Configuration__c",
          actionName: "view"
        }
      });

      // Fire the custom event
      const vfPageRedirect = new CustomEvent("redirectToNodeConfig", {
        detail: {
          nodeConfigId: this.nodeConfigId
        },
        bubbles: true,
        composed: true
      });
      this.dispatchEvent(vfPageRedirect);
    }
  }

  get showFirstStep() {
    return this.currentStep && this.currentStep === "1" ? true : false;
  }
  get showSecondStep() {
    return this.currentStep && this.currentStep === "2" ? true : false;
  }
  get showThirdStep() {
    return this.currentStep && this.currentStep === "3" ? true : false;
  }

  get checkIfShowNCFieldsCSS() {
    return this.checkifNotLoadBalancerOnly()
      ? "slds-accordion__section"
      : "slds-accordion__section slds-is-open";
  }

  @track ncSectionExpand = true;
  @track ncSectionBodyCSS = "slds-m-bottom_x-large slds-show";

  toggleNCSectionVisibility() {
    if (this.ncSectionExpand === true) {
      this.ncSectionExpand = false;
      this.ncSectionBodyCSS = "slds-m-bottom_x-large slds-hide";
    } else {
      this.ncSectionExpand = true;
      this.ncSectionBodyCSS = "slds-m-bottom_x-large slds-show";
    }
  }

  get ncSectionButtonType() {
    let ret = "";
    if (this.ncSectionExpand) {
      ret = "utility:chevrondown";
    } else {
      ret = "utility:chevronright";
    }
    return ret;
  }

  @track lbSectionExpand = true;
  @track lbSectionBodyCSS = "slds-m-bottom_x-large slds-show";
  toggleLBSectionVisibility() {
    if (this.lbSectionExpand === true) {
      this.lbSectionExpand = false;
      this.lbSectionBodyCSS = "slds-m-bottom_x-large slds-hide";
    } else {
      this.lbSectionExpand = true;
      this.lbSectionBodyCSS = "slds-m-bottom_x-large slds-show";
    }
  }

  get lbSectionButtonType() {
    let ret = "";
    if (this.lbSectionExpand) {
      ret = "utility:chevrondown";
    } else {
      ret = "utility:chevronright";
    }
    return ret;
  }
}