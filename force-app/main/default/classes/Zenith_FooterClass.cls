public without sharing class Zenith_FooterClass {
    public static final String BASE_URL=Label.Community_Base_URL;
    @AuraEnabled(cacheable=true)
    public static String getProfileName(){
        return  [Select Name,UserType  from Profile where Id =: UserInfo.getProfileId()].Name;    
    }
    
    @AuraEnabled(cacheable=true)
    public static MainWrapper fetchFooterLabels(){
        List<WrapperParent> parentLabels = new List<WrapperParent>();
        map<id,WrapperParent> parentMap = new map<id,WrapperParent>();
        map<id,List<WrapperParent>> childmenuList = new map<id,List<WrapperParent>>();
        
        for(Zenith_Footer__c menuItems :[ SELECT id,Parent__c, Name, Footer_Label__c, Order__c, Url__c, 
                                         Parent__r.Order__c,Parent__r.Url__c,Parent__r.Footer_Label__c  
                                         FROM Zenith_Footer__c ]){
                                             WrapperParent ch=new WrapperParent();
                                             ch.label=menuItems.Footer_Label__c;
                                             ch.url = Zenith_FooterClass.checkUrl(menuItems, ch);
                                             ch.order=(Integer)menuItems.Order__c;
                                             if(menuItems.Parent__c != null){
                                                 if(childmenuList.containsKey(menuItems.Parent__c)){
                                                     childmenuList.get(menuItems.Parent__c).add(ch);
                                                     childmenuList.get(menuItems.Parent__c).sort();
                                                 }else{
                                                     childmenuList.put(menuItems.Parent__c,new List<WrapperParent>{ch});
                                                 }
                                                 if(parentMap.containsKey(menuItems.Parent__c)) {
                                                     WrapperParent parent=parentMap.get(menuItems.Parent__c);
                                                     parent.childTabs=childmenuList.get(menuItems.Parent__c); 
                                                     parentMap.put(menuItems.Parent__c,parent);
                                                 }
                                                 else{ 
                                                     WrapperParent parent=new WrapperParent();
                                                     parent.order=(Integer)menuItems.Parent__r.Order__c;
                                                     parent.label=menuItems.Parent__r.Footer_Label__c;
                                                     parent.url=BASE_URL+menuItems.Parent__r.Url__c;
                                                     parent.childTabs=childmenuList.get(menuItems.Parent__c); 
                                                     parentMap.put(menuItems.Parent__c,parent);
                                                 }
                                             }
                                             else{
                                                 if(childmenuList.containsKey(menuItems.Id)){
                                                     ch.childTabs=childmenuList.get(menuItems.Id);
                                                 }
                                                 parentMap.put(menuItems.Id,ch);
                                             }
                                         }
        parentLabels=parentMap.values();
        parentLabels.sort();
        MainWrapper headerLabel = new MainWrapper();
        headerLabel.desktopLabels = parentLabels;
        return headerLabel;
    }
    
    public static String checkUrl(Zenith_Footer__c menuItems, WrapperParent ch){
        if(menuItems.Url__c!=null && menuItems.Url__c.startswith('http')){
            return menuItems.Url__c;
        }
        else if(menuItems.Url__c!=null){
            return BASE_URL+menuItems.Url__c;
        }
        else{
            ch.checkParentUrl=False;
            return 'NULL';
        }
    }
    
    public class MainWrapper {
        
        @AuraEnabled public List<WrapperParent> desktopLabels;
        
    }
    public class WrapperParent implements comparable{
        @AuraEnabled public string label;
        @AuraEnabled public string url;
        @AuraEnabled public Integer order;
        @AuraEnabled public List<WrapperParent> childTabs;
        @AuraEnabled public boolean checkParentUrl=True;
        //public WrapperParent(){}
        public Integer compareTo(Object compareToItem) {
            
            WrapperParent wrap = (WrapperParent)compareToItem;
            Integer returnValue = 0;
            if(wrap.order != null){
                If (order > wrap.order) {
                    return 1;
                } else if (order < wrap.order) {
                    return 0;
                }
            }else{
                return 1;
            }
            return 0;
        }
        
    }
}