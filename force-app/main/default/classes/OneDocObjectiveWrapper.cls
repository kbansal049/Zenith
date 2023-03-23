global without sharing class OneDocObjectiveWrapper extends OneDoc.BaseTemplateDataProvider{
    global OneDocObjectiveWrapper() {
    }
    public override Object provide(Map<String, String> params) {
        Map<String, objWrapper> output = new Map<String, objWrapper>();
        //Map<String, Objective_List_for_Meeting__c> mapcs = new Map<string, Objective_List_for_Meeting__c>();
        Map<String, Objectives_List_For_Meeting__mdt> mapcs = new Map<string, Objectives_List_For_Meeting__mdt>();
        
        for(Objectives_List_For_Meeting__mdt cs: [Select label,Field_Name__c,Calculations__c,Is_Local_Breakouts__c,Is_ZAPP__c,Object_Name__c,
                                                                   Plan__c, Recommended_Alerts_for_Weekly_Discussion__c,
                                                                   Record_Label__c, Template_Reference_Label__c from Objectives_List_For_Meeting__mdt]){
            mapcs.put(cs.Record_Label__c, cs);
        }
        for(Objective__c obj: [Select Id, Name, Calculations__c, TAM_Notes__c, Visible_In_Doc__c from Objective__c where Meeting_ID__c = :params.get('Id')]){
            if(mapcs != null && obj.name != null && !mapcs.isEmpty() && mapcs.containskey(obj.name) && mapcs.get(obj.name) != null && mapcs.get(obj.name).Template_Reference_Label__c != null){
                output.put(mapcs.get(obj.name).Template_Reference_Label__c, new objwrapper(obj.Calculations__c, obj.TAM_Notes__c != null ? obj.TAM_Notes__c : ' ', obj.Visible_in_Doc__c));
            }
        }
        
        return JSON.serialize(output);
    }
    global class objWrapper{
        global Decimal measure;
        global String tamnotes;
        //Added By Anup : CR#1259 (added changes related to VisibleInDoc)
        global Boolean visibleInDoc;
        global objWrapper(Decimal m, string t, Boolean v){
            measure = m == null ? 0 : m;
            tamnotes = t;
            visibleInDoc = v;
        }
        //Added By Anup : CR#1259 - End
    }
}