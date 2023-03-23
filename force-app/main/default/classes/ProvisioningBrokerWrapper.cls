global class ProvisioningBrokerWrapper {
    
       
    global String requestID;	//3423423
    global String prGroupId;	//A023432423423
    global String sfdcAccountId;	//A3345345
    global String pgNumber;
    global List<cls_customerInfo> customerInfo;
    
    global class cls_customerInfo {
       // public String customerID;	//23424324
        public String betaCustomerId;
        public String productionCustomerId;
        public String cloudName;	//ZIA
        public String tenantID;	//zscaler.net-234523
        public String tenantName;	//CustomerName-PRGroup
        public String domain;	//ertrt.com
        public String additionalDomains;	//werwe.com,were.com
        public String tenantStatus;	//Trial
        public String requestStatus;	//success
        public String failureReason;	//
        public string subscriptionId;
        public String accountType;
        public String partnerInfo; 
        public String subscriptionName;
        public String customerName;
    }
    
    global  static ProvisioningBrokerWrapper parse(String json){
        return (ProvisioningBrokerWrapper) System.JSON.deserialize(json, ProvisioningBrokerWrapper.class);
    }
}