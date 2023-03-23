public class SecurityPolicyDataModel {
    
    //public string threatProtection,securityException,trafficInspection,overallGrade,SSLInspection,inboundOutboundTraffic,protocolInspection,malwareDetection,advancedThreats,browserControl,cloudSandbox,SSLExceptions,securityExceptions;
	public protocolInspection protocol_inspection;
    public Sandbox sandbox;
    public sslInspection ssl_inspection;
    public inboundOutboundTraffic inbound_outbound_traffic;
    public malware malware;
    public advancedThreats advanced_threats;
    public browserControl browser_control;
    public sslExceptions ssl_exceptions;
    public securityExceptions security_exceptions;
    
    public class protocolInspection  {
        public String grade;
    }
    
    public class Sandbox  {
        public String grade;
    }
    
    public class sslInspection  {
        public String grade;
    }
    
    public class inboundOutboundTraffic  {
        public String grade;
    }
    
    public class malware  {
        public String grade;
    }
	
    public class advancedThreats  {
        public String grade;
    }
    
    public class browserControl {
        public String grade;
    }
    
    public class sslExceptions  {
        public String grade;
    }
    
    public class securityExceptions  {
       public String grade; 
    }
}