public with Sharing class Equipment_request_redirector {
    
    public Equipment_Request__c eReq {get; set;}
    public Map<String,string> urlparams; 
    String returl = '';
    public String error {get; set;}
    String oppId = '';
    String recordtypename = '';
    List<Opportunity> Opplst = new List<Opportunity>();
    
    Id pZenRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('PZEN').getRecordTypeId();
    Id vZenRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Virtual_ZEN').getRecordTypeId();
    Id pZenwithLBRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Private_ZEN_with_LB').getRecordTypeId();
    Id serviceedgePZENRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('ZIA_Service_Edge_PZEN').getRecordTypeId();
    Id serviceedgeVZENRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('ZIA_Service_Edge_VZEN').getRecordTypeId();
    Id caviumRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Cavium_Card').getRecordTypeId();				// Added by Ayush Kangar as part of CR# 3719 - Start
    //CR# 3552 START - Bikram 18th Jan 2022
    Id professionalServicesRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Professional_Services').getRecordTypeId();
    //CR# 3552 END - Bikram 18th Jan 2022
    
    public Equipment_request_redirector(ApexPages.StandardController controller) {
        urlparams = ApexPages.currentPage().getParameters();
        eReq = (Equipment_Request__c )controller.getRecord();
    }
    public pagereference init(){
        if(urlparams.containsKey('RecordType') && !urlparams.containsKey('id') && (urlparams.get('RecordType') == pZenRecordTypeId || urlparams.get('RecordType') == pZenwithLBRecordTypeId)){
            oppId = urlparams.containsKey('CF00N70000002s1R1_lkid') ? urlparams.get('CF00N70000002s1R1_lkid') : '';
            if(oppId != ''){
                Opplst = [Select Id, type from Opportunity where Id = :oppId and (type = 'New Business' or (type = 'Existing Customer (Add On)' and Account.PZEN_in_Asset__c = false ))];
                if(!Opplst.isEmpty()){
                    error = 'Old PZEN cannot be created for a ' + opplst[0].type + ' Opportunity';
                    return null;
                }
            }
        }
        if(urlparams.containsKey('RecordType') && !urlparams.containsKey('id') && (urlparams.get('RecordType') == vZenRecordTypeId)){
            oppId = urlparams.containsKey('CF00N70000002s1R1_lkid') ? urlparams.get('CF00N70000002s1R1_lkid') : '';
            if(oppId != ''){
                Opplst = [Select Id, type from Opportunity where Id = :oppId and (type = 'New Business' or (type = 'Existing Customer (Add On)' and Account.VZEN_in_Asset__c = false ))];
                if(!Opplst.isEmpty()){
                    error = 'Old VZEN cannot be created for a ' + opplst[0].type + ' Opportunity';
                    return null;
                }
            }
        }
        if(urlparams.containsKey('RecordType') && !urlparams.containsKey('id') && (urlparams.get('RecordType') == serviceedgePZENRecordTypeId)){
            oppId = urlparams.containsKey('CF00N70000002s1R1_lkid') ? urlparams.get('CF00N70000002s1R1_lkid') : '';
            if(oppId != ''){
                Opplst = [Select Id, type from Opportunity where Id = :oppId and Account.PZEN_in_Asset__c = true];
                if(!Opplst.isEmpty()){
                    error = 'ZIA Service Edge Equipment Request cannot be created as the Install Base has Old PZEN';
                    return null;
                }
            }
        }
        if(urlparams.containsKey('RecordType') && !urlparams.containsKey('id') && (urlparams.get('RecordType') == serviceedgeVZENRecordTypeId)){
            oppId = urlparams.containsKey('CF00N70000002s1R1_lkid') ? urlparams.get('CF00N70000002s1R1_lkid') : '';
            if(oppId != ''){
                Opplst = [Select Id, type from Opportunity where Id = :oppId and Account.VZEN_in_Asset__c = true];
                if(!Opplst.isEmpty()){
                    error = 'ZIA Virtual Service Edge Equipment Request cannot be created as the Install Base has Old VZEN';
                    return null;
                }
            }
        }
        if(urlparams.containsKey('RecordType') && !urlparams.containsKey('id') && (urlparams.get('RecordType') == pZenRecordTypeId || urlparams.get('RecordType') == pZenwithLBRecordTypeId || urlparams.get('RecordType') == serviceedgePZENRecordTypeId)){
            returl = '/apex/Equipment_Request_Creation?';
            if(urlparams != null){
                for(String s: urlparams.keyset()){
                    if(s != null && urlparams.get(s) != null && !s.contains('save_new'))
                        returl += '&'+s+'=' + String.escapeSingleQuotes(urlparams.get(s));
                }
                system.debug('++++'+returl);
            }
        }else if(urlparams.containsKey('id')){
            list<Equipment_Request__c> eqlst = [Select Id, RecordtypeId from Equipment_Request__c where Id = :urlparams.get('id')];
            if(!eqlst.isEmpty()){
                if(eqlst[0].RecordtypeId == pZenRecordTypeId || eqlst[0].RecordtypeId == pZenwithLBRecordTypeId || eqlst[0].RecordtypeId == serviceedgePZENRecordTypeId){
                    returl = '/apex/Equipment_Request_Creation?';
                    if(urlparams != null){
                        for(String s: urlparams.keyset()){
                            if(s != null && urlparams.get(s) != null && !s.contains('save_new'))
                                returl += '&'+s+'=' + String.escapeSingleQuotes(urlparams.get(s));
                        }
                        system.debug('++++'+returl);
                    }
                }
                // Added by Ayush Kangar as part of CR# 3719 - Start
                else if(eqlst[0].RecordtypeId == caviumRecordTypeId){
                    returl = '/apex/CaviumCardCreationPage?';
                    if(urlparams != null){
                        for(String s: urlparams.keyset()){
                            if(s != null && urlparams.get(s) != null && !s.contains('save_new'))
                                returl += '&'+s+'=' + String.escapeSingleQuotes(urlparams.get(s));
                        }
                    }	
                }
                // Added by Ayush Kangar as part of CR# 3719 - End
                //CR# 3552 START - Bikram 18th Jan 2022
                else if(eqlst[0].RecordtypeId == professionalServicesRecordTypeId){
                    returl = '/apex/ProfessionalServicesCreateEditVF?';
                    if(urlparams != null){
                        for(String s: urlparams.keyset()){
                            if(s != null && urlparams.get(s) != null && !s.contains('save_new'))
                                returl += '&'+s+'=' + String.escapeSingleQuotes(urlparams.get(s));
                        }
                    }	
                }
                //CR# 3552 END - Bikram 18th Jan 2022
                else{
                    returl = '/' + urlparams.get('id') + '/e?nooverride=1&retURL=/' + urlparams.get('id');
                    for(String s: urlparams.keyset()){
                        if(s != null && urlparams.get(s) != null && !s.contains('save_new') && !s.contains('retURL'))
                            returl += '&'+s+'=' + String.escapeSingleQuotes(urlparams.get(s));
                    }
                }
            }
        }
        // Added by Ayush Kangar as part of CR# 3719 - Start
        else if(urlparams.containsKey('RecordType') && !urlparams.containsKey('id') && urlparams.get('RecordType') == caviumRecordTypeId){
            returl = '/apex/CaviumCardCreationPage?';
            if(urlparams != null){
                for(String s: urlparams.keyset()){
                    if(s != null && urlparams.get(s) != null && !s.contains('save_new'))
                        returl += '&'+s+'=' + String.escapeSingleQuotes(urlparams.get(s));
                }
            }
        }	
        // Added by Ayush Kangar as part of CR# 3719 - End
        //CR# 3552 START - Bikram 18th Jan 2022
        else if(urlparams.containsKey('RecordType') && !urlparams.containsKey('id') && 
                urlparams.get('RecordType') == professionalServicesRecordTypeId){
                    returl = '/apex/ProfessionalServicesCreateEditVF?';
                    if(urlparams != null){
                        for(String s: urlparams.keyset()){
                            if(s != null && urlparams.get(s) != null && !s.contains('save_new'))
                                returl += '&'+s+'=' + String.escapeSingleQuotes(urlparams.get(s));
                        }
                    }
                }
        //CR# 3552 END - Bikram 18th Jan 2022
        else{
            Schema.DescribeSObjectResult r = Equipment_Request__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            returl = '/'+ keyPrefix + '/e?nooverride=1';
            if(urlparams != null){
                for(String s: urlparams.keyset()){
                    if(s != null && urlparams.get(s) != null && !s.contains('save_new'))
                        returl += '&'+s+'=' + urlparams.get(s);
                    system.debug('++++ INSIDE FOR'+returl);
                }
                system.debug('++++'+returl);
            }
        }
        system.debug('++++'+returl);
        return new Pagereference(returl);
    }
    
    public pagereference onClickGoBack(){
        if(oppId != null){
            return new PageReference('/'+oppId);
        }else{
            Schema.DescribeSObjectResult r = Equipment_Request__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            return new PageReference('/'+ keyPrefix + '/o');
        }
    }
    
}