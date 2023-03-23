public class GenericFieldMappingController {
    
    public static List<Generic_Field_Mapping__mdt> getMappingFromMetaData(String srcObName, String trgtName){
        return [Select Id, Label, Target_Field_API_Name__c,
                Source_Field_API_Name__c,Source_Object__c,Target_Object__c,Origin__c,
                (Select Id, Label, Source_Value__c, Target_Value__c,
                 Generic_Field_Mapping_Record__c, Active__c from 
                 Generic_Field_Value_Field_Mappings__r where Active__c = True) 
                from Generic_Field_Mapping__mdt where Active__c = True  
                and Source_Object__c= :srcObName and Target_Object__c= :trgtName];
    }
    
    public static Object prepareRecordFromGenericFieldMapping(sObject srcObj, sObject trgObj, List<Generic_Field_Mapping__mdt> metaDataList){
        System.debug('---prepareRecordFromGenericFieldMapping---');
        System.debug('---srcObj---'+srcObj);
        for(Generic_Field_Mapping__mdt genericMDT : metaDataList) {                                            
            if(genericMDT.Generic_Field_Value_Field_Mappings__r.size() >= 1){
                Object fieldVals = getValueFromMapping(srcObj, genericMDT);
                if(fieldVals != null){
                    trgObj.put(genericMDT.Target_Field_API_Name__c, fieldVals); 
                }
            }else{
                trgObj.put(genericMDT.Target_Field_API_Name__c, srcObj.get(genericMDT.Source_Field_API_Name__c));
            }                                                         
        }
        System.debug('--trgObj--'+trgObj);
        return trgObj;
    }
    
    
    public static Object getValueFromMapping(sObject SourceObj, Generic_Field_Mapping__mdt gfmMDT){
        Object objRec = null;
        if(gfmMDT !=null && gfmMDT.Generic_Field_Value_Field_Mappings__r != null){
            Map<Object,Object> valueMAP = new Map<Object,Object>();
            for(Generic_Field_Value_Field_Mapping__mdt childRec : gfmMDT.Generic_Field_Value_Field_Mappings__r){
                valueMAP.put(childRec.Source_Value__c, childRec.Target_Value__c);
            }
            objRec = SourceObj.get(gfmMDT.Source_Field_API_Name__c) != null && valueMAP.containskey(SourceObj.get(gfmMDT.Source_Field_API_Name__c)) ? valueMAP.get(SourceObj.get(gfmMDT.Source_Field_API_Name__c)) : null;
        }
        return objRec;
    }
    
}