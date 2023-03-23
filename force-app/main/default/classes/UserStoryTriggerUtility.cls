public class UserStoryTriggerUtility{

    public static void beforeUpdate(List<copado__User_Story__c> newList, Map<Id, copado__User_Story__c> oldmap){

        //SCA result should be present
        String BypassValidateSCAResults=ZscalerCustomSetting__c.getInstance('BypassValidateSCAResults')!=null && ZscalerCustomSetting__c.getInstance('BypassValidateSCAResults').Value__c!=null ? ZscalerCustomSetting__c.getInstance('BypassValidateSCAResults').Value__c:'False';
        if(BypassValidateSCAResults=='True'){
        }else{
            validteSCAresults(newList,oldmap);
        }
    
        /*
        //Block promotions if Sandbox is not in sync
        US_Backpromotion_Limit_Exceeded__mdt PromotionsDisabled = US_Backpromotion_Limit_Exceeded__mdt.getInstance('Promotions_Disabled');
        Map<String, copado__Environment__c> AllEnvironments = new Map<String, copado__Environment__c>([select Name, Id from copado__Environment__c]);
               
        for(copado__User_Story__c US:newList){
        
            if((US.copado__Promote_and_Deploy__c == TRUE) && (US.copado__Promote_and_Deploy__c != oldmap.get(US.Id).copado__Promote_and_Deploy__c )){
            
                Id cc = US.copado__Environment__c;
                String CurrentEnvironment = AllEnvironments.get(US.copado__Environment__c).Name;
                            
                if(CurrentEnvironment.contains('SBDEV')){
                    Boolean ifChecked = (Boolean) PromotionsDisabled.get(CurrentEnvironment+ '__c');
                
                    if(ifChecked == TRUE){
                        US.addError('Your Dev Sandbox has been lagged by more than allowed number of User Stories. Please Backpromote the User Stories to keep your sandbox in sync.');
                    }
                }           
            }
        }
        */
    }
    
    public static void validteSCAresults(List<copado__User_Story__c> UserStorylist,Map<id,copado__User_Story__c> UserStoryOldmap){
        Set<id> UserStoryidSet= new Set<id>();
        for(copado__User_Story__c US:UserStorylist){
            if((US.copado__Promote_and_Deploy__c == TRUE) && (US.copado__Promote_and_Deploy__c != UserStoryOldmap.get(US.Id).copado__Promote_and_Deploy__c ) && !US.SCA_Override__c){
                if(US.copado__Metadata_Types_in_Selection__c!=''){
                    string tempstr=US.copado__Metadata_Types_in_Selection__c;
                    boolean RunSCAresults=false;
                    RunSCAresults=validateUserStoryMetadata(tempstr);   
                    if(RunSCAresults){
                        UserStoryidSet.add(US.id);
                    }                   
                }
                else{
                    us.addError('No metadata type added in User story');    
                }
            }
        }
        List<copado__Static_Code_Analysis_Result__c> SCAResult= new List<copado__Static_Code_Analysis_Result__c>();
        Map<id,string> UserStoryidmap= new map<id,string>();
        for(copado__User_Story__c us:[Select id,Name,(select id,copado__Org_Credential__c,copado__User_Story__c,copado__Score_v11__c,copado__Number_of_Violations__c,copado__Highest_Priority_Violation__c from copado__Static_Code_Analysis_Results__r order by createddate DESC Limit 1 ) from copado__User_Story__c where id IN:UserStoryidSet]){
            // Check if SCA is present
            if(us.copado__Static_Code_Analysis_Results__r.size()>0){
                SCAResult = us.copado__Static_Code_Analysis_Results__r;
                integer highestViolationAllowed = ZscalerCustomSetting__c.getInstance('SCABlockByViolation')!=null && ZscalerCustomSetting__c.getInstance('SCABlockByViolation').Value__c!=null ? Integer.valueOf(ZscalerCustomSetting__c.getInstance('SCABlockByViolation').Value__c):0;
                if(highestViolationAllowed > SCAResult[0].copado__Highest_Priority_Violation__c){
                    UserStoryidmap.put(us.id,'Violated');
                }
                else{
                    UserStoryidmap.put(us.id,'Passed');
                } 
            }else{
                UserStoryidmap.put(us.id,'Failed');
            }
        }
        for(copado__User_Story__c US:UserStorylist){
            if(UserStoryidmap.containskey(us.id) && UserStoryidmap.get(us.id)=='Failed'){               
                String SCAErrormessage=ZscalerCustomSetting__c.getInstance('SCAErrormessage')!=null && ZscalerCustomSetting__c.getInstance('SCAErrormessage').Value__c!=null ? ZscalerCustomSetting__c.getInstance('SCAErrormessage').Value__c:'User Story does not have any SCA results. Please run SCA results for User Story';
                us.addError(SCAErrormessage);
            }
            else if(UserStoryidmap.containskey(us.id) && UserStoryidmap.get(us.id)=='Violated'){
                String SCAErrormessage=ZscalerCustomSetting__c.getInstance('SCABlockByViolationMsg')!=null && ZscalerCustomSetting__c.getInstance('SCABlockByViolationMsg').Value__c!=null ? ZscalerCustomSetting__c.getInstance('SCABlockByViolationMsg').Value__c:'Your User story cannot be promoted as it contains Blocker/Critical Violation';
                us.addError(SCAErrormessage);
            }

        }
    }
    
    public static boolean validateUserStoryMetadata(string USmetadata){
        Set<string> MetadataSet= new Set<string>();
        string tempstr=ZscalerCustomSetting__c.getInstance('MetadatalistforSCA')!=null && ZscalerCustomSetting__c.getInstance('MetadatalistforSCA').Value__c!=null ? ZscalerCustomSetting__c.getInstance('MetadatalistforSCA').Value__c:'ApexClass,ApexTrigger,ApexComponent,ApexComponent,ApexPage,AuraDefinitionBundle,LightningComponentBundle';
        MetadataSet.addall(tempstr.split(','));
        boolean RunSCAresults=false;
        Set<string> USmetadataset= new set<string>();
        USmetadataset.addall(USmetadata.split(';'));
        
        for(string str:USmetadataset){
            if(MetadataSet.contains(str)){
                RunSCAresults=true;
            }
        }
        return RunSCAresults;
    }

}