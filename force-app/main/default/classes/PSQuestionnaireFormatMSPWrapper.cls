global class PSQuestionnaireFormatMSPWrapper extends OneDoc.BaseTemplateDataProvider {
    public override Object provide(Map<String, String> params) {
    List<PS_Questionnaire__c> psq = [select id,Traffic_Sources__c,Internet_Egress_Points_Locations__c,GRE_Device_Vendors_Currently_In_Use__c,IPSEC_Device_Vendors_Currently_In_Use__c,End_User_Traffic_Forwarded_To_The_Existi__c from PS_Questionnaire__c where Id=:params.get('Id')];
    String trafficsources='';
    String geolocations='';
    String grevendors='';
    String ipsecvendors='';
    String existingproxy='';
        if(!psq.isEmpty())
            {
                if(psq[0].Traffic_Sources__c!=null)
                {
                    trafficsources=psq[0].Traffic_Sources__c.replace(';',' ,');
                }
                if(psq[0].Internet_Egress_Points_Locations__c!=null)
                {
                    geolocations=psq[0].Internet_Egress_Points_Locations__c.replace(';',' ,');
                }
                if(psq[0].GRE_Device_Vendors_Currently_In_Use__c!=null)
                {
                    grevendors=psq[0].GRE_Device_Vendors_Currently_In_Use__c.replace(';',' ,');
                }
                if(psq[0].IPSEC_Device_Vendors_Currently_In_Use__c!=null)
                {
                    ipsecvendors=psq[0].IPSEC_Device_Vendors_Currently_In_Use__c.replace(';',' ,');
                }
                if(psq[0].End_User_Traffic_Forwarded_To_The_Existi__c!=null)
                {
                    existingproxy=psq[0].End_User_Traffic_Forwarded_To_The_Existi__c.replace(';',' ,');
                }
            }
        FormatWrapper result=new FormatWrapper(trafficsources,geolocations,grevendors,ipsecvendors,existingproxy);
        system.debug(result);
        return JSON.serialize(result);
    }
    
    global class FormatWrapper{
        global String trafficsources;
        global String geolocations;
        global String grevendors;
        global String ipsecvendors;
        global String existingproxy;
        global FormatWrapper(string trafficsources, string geolocations, string grevendors, string ipsecvendors, string existingproxy){
            this.trafficsources = trafficsources;
            this.geolocations = geolocations;
            this.grevendors = grevendors;
            this.ipsecvendors = ipsecvendors;
            this.existingproxy = existingproxy;
        }
    }
}