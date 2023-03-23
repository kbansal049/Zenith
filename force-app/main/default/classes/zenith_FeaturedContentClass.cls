public without sharing class zenith_FeaturedContentClass {
    
    @AuraEnabled(cacheable=true)
    public static list<featureContentWrapper> getFeaturedList(){
        List<Featured_Content__c> featuredContentList;
      //  if (Schema.sObjectType.Featured_Content__c.isAccessible()) {
            featuredContentList = [Select Id, Name,Title__c,Url__c,Content__c,Image__c,CreatedDate  from Featured_Content__c];         
      //  }    
        List<featureContentWrapper> ftWrapper=new List<featureContentWrapper>();
        for(Featured_Content__c ft :featuredContentList){
            featureContentWrapper wrp=new featureContentWrapper();
            wrp.Id=ft.Id;
            wrp.name=ft.name;
            wrp.Title=ft.Title__c;
            wrp.Url=ft.Url__c;
            wrp.Content=ft.Content__c;
            wrp.image =ft.Image__c;
            wrp.CreatedDate =ft.CreatedDate;
            Datetime now = System.now();
            Datetime createdDate = ft.createdDate;
            Long timeDiff = (now.getTime() - createdDate.getTime()) / (3600*1000);
            if(timeDiff < 24){ 
                wrp.PostedHour=timeDiff;
            }
            else{
                wrp.CreatedDate=ft.CreatedDate; 
            }
            ftWrapper.add(wrp);   
        }
        return ftWrapper; 
    }
    public class featureContentWrapper{      
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String Title {get;set;}
        @AuraEnabled
        public String Url {get;set;}
        @AuraEnabled
        public String Content {get;set;}
        @AuraEnabled
        public String Image {get;set;}
        @AuraEnabled
        public dateTime CreatedDate {get;set;}
        @AuraEnabled
        public Long PostedHour {get;set;}
        
    }  
    
}