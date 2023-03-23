@RestResource(urlMapping='/SYNCCLOUDUSAGE/*')
global with sharing class SYNCCLOUDUSAGE {
    global static Boolean avoidtriggers = false;
    
    @HttpPost
    global static Map<String, List<String>> doPost(Map<String, Account>  accmap ) {
        
        Map<String, List<String>> mapresult = new Map<String, List<String>>();
        System.debug('SYNCCLOUDUSAGE' + accmap);
        List<String> clouderrorlst = new List<String>();
        List<String> cloudsuccesslst = new List<String>();
        avoidtriggers = true;
        
        TriggerUtility.accTerritoryPatchExecuted();
        TriggerUtility.accSalesTeamExecuted();
        System.debug('SYNCCLOUDUSAGE' + accmap);
        
        if(accmap != null){
            Database.saveResult[] srList = database.update(accmap.values(),false);
            for (Database.saveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    clouderrorlst.add(sr.getId());
                }
              /*  else {
                    for(Database.Error err : sr.getErrors()) {
                        String s = '';
                        if(srList.indexOf(sr) != -1 && !accmap.values().isEmpty() && accmap.values().size() > srList.indexOf(sr) && accmap.values()[srList.indexOf(sr)] != null){
                            s = accmap.values()[srList.indexOf(sr)].Id;
                        }
                        clouderrorlst.add(s + ' - ' + err.getMessage());
                    }
                }*/
            }
            mapresult.put('cloudsuccesslst', cloudsuccesslst);
            if(!clouderrorlst.isEmpty()){
                mapresult.put('clouderrorlst', clouderrorlst);
            }
        }
        System.debug('SYNCCLOUDUSAGE cloudsuccesslst' + cloudsuccesslst);
        System.debug('SYNCCLOUDUSAGE clouderrorlst' + clouderrorlst);
        System.debug('SYNCCLOUDUSAGE ' + accmap.values());
        return mapresult;
        
    }
}