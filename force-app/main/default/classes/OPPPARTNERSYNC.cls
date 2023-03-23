@RestResource(urlMapping='/OPPTYSYNCPART/*')
global with sharing class OPPPARTNERSYNC{
    
    @HttpGet
    global static Map<String, String> doGet() {
        
        RestRequest req = RestContext.request;
        Map<String, String> result = new map<String, String>();
        System.debug(req.params);
        System.debug(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8'));
        system.debug(Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')));
        if(req.params!= null && req.params.containskey('type') && EncodingUtil.urlDecode(req.params.get('type'),'UTF-8') == 'get_leads'){
            if(req.params.containskey('Start_Date') && EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8') != '' && req.params.containskey('End_Date') && EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8') != '' && Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) && Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8'))){
                List<Opportunity_Partner__c> opplst = new List<Opportunity_Partner__c>();
                for(Opportunity_Partner__c opp: [Select Account__c, Opportunity__c from Opportunity_partner__c where LastModifiedDate >= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) and LastModifiedDate <= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8')) and partner_type__c = 'Federal System Integrator']){
                    opplst.add(opp);
                }
                system.debug(opplst);
                if(!opplst.isEmpty()){
                    result.put('oppresults', JSON.serialize(opplst));
                }
            }
        }
        return result;
    }
    
}