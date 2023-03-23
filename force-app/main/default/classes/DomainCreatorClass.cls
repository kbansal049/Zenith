/**
 * IBA - 6578 - Use DomainCreator class to get the base URL
 * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_DomainCreator.htm
 */

public class DomainCreatorClass {

    @testVisible
    private static Boolean throwException = false;

    @AuraEnabled
    public static Map<String,String> getAllDomains(String packageName){
        try{
            if(DomainCreatorClass.throwException){ 
                throw throwException(); 
            }

			Map<String, String> domainMap = new Map<String, String>();
            domainMap.put('ContentHostname', DomainCreator.getContentHostname());
            domainMap.put('ExperienceCloudSitesBuilderHostname', DomainCreator.getExperienceCloudSitesBuilderHostname());
            domainMap.put('ExperienceCloudSitesHostname', DomainCreator.getExperienceCloudSitesHostname());
            domainMap.put('ExperienceCloudSitesLivePreviewHostname', DomainCreator.getExperienceCloudSitesLivePreviewHostname());
            domainMap.put('ExperienceCloudSitesPreviewHostname', DomainCreator.getExperienceCloudSitesPreviewHostname());
            domainMap.put('LightningContainerComponentHostname', DomainCreator.getLightningContainerComponentHostname(packageName));
            domainMap.put('LightningHostname', DomainCreator.getLightningHostname());
            domainMap.put('OrgMyDomainHostname', DomainCreator.getOrgMyDomainHostname());
            domainMap.put('SalesforceSitesHostname', DomainCreator.getSalesforceSitesHostname());
            domainMap.put('VisualforceHostname', DomainCreator.getVisualforceHostname(packageName));
            return domainMap; 
		}catch(Exception e){
			throw new AuraHandledException(e.getMessage());
		}
        
    } 

    @AuraEnabled
    public static string getDomain(String type, String packageName){
        try{
            if(DomainCreatorClass.throwException){ 
                throw throwException(); 
            }
            String domainType = type.toUpperCase();
            switch on domainType {
                when 'CONTENTHOSTNAME' {
                    return DomainCreator.getContentHostname();
                }
                when 'EXPERIENCECLOUDSITESBUILDERHOSTNAME' {
                    return DomainCreator.getExperienceCloudSitesBuilderHostname();
                }
                when 'EXPERIENCECLOUDSITESHOSTNAME' {
                    return DomainCreator.getExperienceCloudSitesHostname();
                }
                when 'EXPERIENCECLOUDSITESLIVEPREVIEWHOSTNAME' {
                    return DomainCreator.getExperienceCloudSitesLivePreviewHostname();
                }
                when 'EXPERIENCECLOUDSITESPREVIEWHOSTNAME' {
                    return DomainCreator.getExperienceCloudSitesPreviewHostname();
                }
                when 'LIGHTNINGCONTAINERCOMPONENTHOSTNAME' {
                    return DomainCreator.getLightningContainerComponentHostname(packageName);
                }
                when 'LIGHTNINGHOSTNAME' {
                    return DomainCreator.getLightningHostname();
                }
                when 'ORGMYDOMAINHOSTNAME' {
                    return DomainCreator.getOrgMyDomainHostname();
                }
                when 'SALESFORCESITESHOSTNAME' {
                    return DomainCreator.getSalesforceSitesHostname();
                }
                when 'VISUALFORCEHOSTNAME' {
                    return DomainCreator.getVisualforceHostname(packageName);
                }
                when else {
                    return null;
                }
            }
		}catch(Exception e){
			throw new AuraHandledException(e.getMessage());
		}
    }
    
    private static Exception throwException(){
        AuraHandledException e = new AuraHandledException('Exception from DomainCreator');
        e.setMessage('Exception from DomainCreator');
        return e;
    }
}