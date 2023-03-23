public with sharing class RelatedListController {
    @AuraEnabled(cacheable=true) 
    public static ResponseWrapper fetchRecords(String req){
        RequestWrapper request = (RequestWrapper)JSON.deserialize(req, RequestWrapper.class);
        ResponseWrapper response = new ResponseWrapper();
        system.debug(req);
        system.debug(request);
        if(request.fieldSetName != null  && request.objName != null 
            && request.parent_API_Name != null && request.child_API_Name != null 
            && request.parentId != null){
                Id parentId = (Id)request.parentId;
                Integer lim = request.lmt != null ? request.lmt : 50000;
                String parentqry = 'Select Id ';
                if(request.parent_API_Name != 'Id'){
                    parentqry += ', ' + request.parent_API_Name;
                }
                parentqry += ' from ' + (parentId.getSobjectType().getDescribe().getName()) + ' where Id = :parentId ';
                List<SObject> parentLst = database.query(parentqry);

                String query = 'SELECT ';
                List<Map<String, Object>> colsList = new List<Map<String, Object>>();
                Map<String, string> mapaptdt = new Map<String, string>();
                
                for(Apex_Type_to_DataTable_Type__mdt apt: [select Apex_Type__c,DataTable_Type__c,Field_Name__c,Object_Name__c from Apex_Type_to_DataTable_Type__mdt 
                                                           where DataTable_Type__c != null ]){
                    //Modified by Swathi : CR1222 Start                   
                    if(apt.Apex_Type__c !=null){
                    	mapaptdt.put(apt.Apex_Type__c.tolowerCase(), apt.DataTable_Type__c);                                             
                    }
                    else if(apt.Field_Name__c !=null && apt.Object_Name__c == request.objName )
                    	mapaptdt.put(apt.Field_Name__c, apt.DataTable_Type__c);
                    //Modified by Swathi : CR1222 End
                }
                for(Schema.FieldSetMember f : getFields(request.fieldSetName, request.objName)) {
                    query += f.getFieldPath() + ', ';
                    Map<String, Object> colJSON = new Map<String, Object>();
                    colJSON.put('label', f.getLabel());
                    colJSON.put('fieldName', f.getFieldPath());
                    colJSON.put('hideDefaultActions', False); // modified by Swathi : CR1222 
                    colJSON.put('sortable', true);
                    colJSON.put('wrapText', true);
                    if(f.getSObjectField().getDescribe().isUpdateable() && request.showInlineEdit != null && request.showInlineEdit){
                        colJSON.put('editable', true);
                    }
                    //Added by Chetan Start
                    if(f.getSObjectField().getDescribe().isUpdateable() && request.showInlineEdit != null && (f.getSObjectField().getDescribe().getName()=='TAM_Meeting_Notes__c' || f.getSObjectField().getDescribe().getName()=='Visible_in_Doc__c') && !request.showInlineEdit){
                        colJSON.put('editable', true);
                    }
                    //Added by Chetan End
                    String apextype = '' + f.getSObjectField().getDescribe().type;
                    apextype = apextype.toLowerCase();
                    String typeVal = 'text';
                    //Added by swathi : CR1222 starts
                    String fieldtype = '' + f.getFieldPath();
                    System.debug('fieldtype '+fieldtype);
                    if(mapaptdt != null && !mapaptdt.isEmpty() && mapaptdt.containsKey(fieldtype)){
                        typeVal = mapaptdt.get(fieldtype);
                    }
                    //Added by swathi : CR1222 ends
                    else if(mapaptdt != null && !mapaptdt.isEmpty() && mapaptdt.containsKey(apextype)){
                    	typeVal = mapaptdt.get(apextype); 
                    }
                    system.debug(apextype);
                    system.debug(typeVal);
                    colJSON.put('type', typeVal);
                    colsList.add(colJSON);
                }
                
                query += ' Id, ' + request.child_API_Name + ' FROM ' + request.objName + ' where ' + request.child_API_Name + ' = ';
                if(!parentLst.isEmpty()){
                    String relId = (String)parentLst[0].get(request.parent_API_Name);
                    response.relatedId = relId;
                    query += ':relId';
                }else{
                    query += ':parentId';
                }

                if(request.filterCondition != null){
                    query += ' AND ' +  request.filterCondition;
                }
                //Added by Swathi CR:1221 Start
                if(request.objName == 'Objective__c'){
                    query += ' order by Name ASC limit :lim';
                }
                //Added by Swathi CR:1221 End
                else
                	query += ' order by createddate desc limit :lim';
                response.collst = colsList;
                system.debug(query);
                response.soblst = Database.query(query);
                response.showData = !response.soblst.isEmpty();
                system.debug(response);
            }
            return response;
    }
    @AuraEnabled 
    public static List<DefaultParams> getdefaultParameters(String recId, String meetingId){
        List<DefaultParams> lstparams = new List<DefaultParams>();
        if(recId != null){
            Id recordId = (Id)recId;
            if(recordId.getSobjectType().getDescribe().getName() == 'Case'){
                for(Case cs: [Select Id, AccountId from Case where Id = :recordId]){
                    DefaultParams par = new DefaultParams();
                    par.name = 'Customer__c';
                    par.value = cs.AccountId;
                    lstparams.add(par);
                    par = new DefaultParams();
                    par.name = 'Case__c';
                    par.value = cs.Id;
                    lstparams.add(par);
                    par = new DefaultParams();
                    par.name = 'Meeting__c';
                    par.value = meetingId;
                    lstparams.add(par);
                }
            }else if(recordId.getSobjectType().getDescribe().getName() == 'Objective__c'){
                for(Objective__c cs: [Select Id, Meeting_ID__r.Customer_Name__c from Objective__c where Id = :recordId]){
                    DefaultParams par = new DefaultParams();
                    par.name = 'Customer__c';
                    par.value = cs.Meeting_ID__r.Customer_Name__c;
                    lstparams.add(par);
                    par = new DefaultParams();
                    par.name = 'Objective__c';
                    par.value = cs.Id;
                    lstparams.add(par);
                    par = new DefaultParams();
                    par.name = 'Meeting__c';
                    par.value = meetingId;
                    lstparams.add(par);
                }
            }else if(recordId.getSobjectType().getDescribe().getName() == 'inspire1__Project__c'){
                for(inspire1__Project__c cs: [Select Id, inspire1__Account__c from inspire1__Project__c where Id = :recordId]){
                    DefaultParams par = new DefaultParams();
                    par.name = 'Customer__c';
                    par.value = cs.inspire1__Account__c;
                    lstparams.add(par);
                    par = new DefaultParams();
                    par.name = 'Project__c';
                    par.value = cs.Id;
                    lstparams.add(par);
                    par = new DefaultParams();
                    par.name = 'Meeting__c';
                    par.value = meetingId;
                    lstparams.add(par);
                }
            }
        }
        return lstparams;
    }

    private static List<Schema.FieldSetMember> getFields(String fsname, String objname) {
        return Schema.getGlobalDescribe().get(objname).getDescribe().fieldSets.getMap().get(fsname).getFields();
    }

    @AuraEnabled 
    public static void saveRecs(List<SObject> soblst) {
        update soblst;
    }

    @AuraEnabled 
    public static void createRecord(List<SObject> soblst) {
        insert soblst;
    }

    @AuraEnabled 
    public static void delRecs(SObject rec) {
        delete rec;
    }

    public class ResponseWrapper{
        @AuraEnabled 
        public List<Map<String,Object>> collst{get; set;}
        @AuraEnabled 
        public List<SObject> soblst{get; set;}
        @AuraEnabled 
        public String relatedId{get; set;}
        @AuraEnabled 
        public boolean showData{get; set;}
        
    }
    public class RequestWrapper{
        @AuraEnabled 
        public string parentId{get; set;}
        @AuraEnabled 
        public boolean showInlineEdit{get; set;}
        @AuraEnabled 
        public string parent_API_Name{get; set;}
        @AuraEnabled 
        public string child_API_Name{get; set;}
        @AuraEnabled 
        public string objName{get; set;}
        @AuraEnabled 
        public string filterCondition{get; set;}
        @AuraEnabled 
        public string fieldSetName{get; set;}
        @AuraEnabled 
        public Integer lmt{get; set;}
        
    }
    public class DefaultParams{
        @AuraEnabled
        public string name{get; set;}
        @AuraEnabled
        public string value{get; set;}
        
    }
}