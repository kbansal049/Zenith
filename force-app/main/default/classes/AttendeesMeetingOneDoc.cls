global without sharing class AttendeesMeetingOneDoc extends OneDoc.BaseTemplateDataProvider{
    global AttendeesMeetingOneDoc() {
    }
    public override Object provide(Map<String, String> params) {    
        List<AttendeeWrapper> attlst = new List<AttendeeWrapper>();
        map<String,Contact> contactMap = new map<String,Contact>();//Added by Swathi : CR#1318
        List<Meeting__c> meetlst = [Select Id, Participants__c from Meeting__c where Id = :params.get('Id')];
        //boolean istrack = false;//Added by Swathi : CR#1318
        //CR#2865--Added condition to convert participant list to lowercase by Chetan
        if(!meetlst.isEmpty() && meetlst[0].Participants__c != null){
            Set<String> partlst = new Set<String>();
            for(String s:  meetlst[0].Participants__c.split(',')){
                partlst.add(s.toLowerCase().trim());
            }
            
            if(!partlst.isEmpty()){
                //Added by Swathi : CR#1318 start
                map<String,User> UserMap = new map<String,User>();
                
                Set<String> emailname = new Set<String>();
                for(Contact u : [Select Id, Account.Name, name, email, Title from contact where email in :partlst and AccountId in (Select Customer_Name__c from Meeting__c where id = :params.get('Id')) order by Title NULLS Last]){
                    if(partlst.contains(u.email)){
                        partlst.remove((u.email));
                    }
                    
                    if(!contactMap.containsKey(u.email)){
                        contactMap.put(u.email,u);
                        emailname.add(u.email);
                    }
                    System.debug('u'+u);
                }
                System.debug('emailname'+emailname);
                System.debug('contactMap'+contactMap);
                for(String u : emailname){
                    if(contactMap.containsKey(u) && contactMap.get(u) != null  ){
                        attlst.add(new AttendeeWrapper(contactMap.get(u).name, contactMap.get(u).account.name, contactMap.get(u).Title, contactMap.get(u).email));
                    }
                }
                
                Set<String> useremail = new Set<String>();
                for(User u : [Select Id, Name, email, Title, Account.Name from User where email in :partlst order by Title NULLS LAST]){
                    
                    if(!UserMap.containsKey(u.email)){
                        UserMap.put(u.email,u);
                        useremail.add(u.email);
                    }
                }
                for(String u : useremail){
                    if(UserMap.containsKey(u) && UserMap.get(u) != null  ){
                        attlst.add(new AttendeeWrapper(UserMap.get(u).name, UserMap.get(u).account.name != null ? UserMap.get(u).account.name : 'Zscaler', UserMap.get(u).title, UserMap.get(u).email));
                    }
                }
                System.debug('attlst from User '+ attlst); 
                //Added by Swathi : CR#1318 End
                System.debug('attlst from contact '+ attlst); 
            }
        }
        return JSON.serialize(attlst);
    }
    global class AttendeeWrapper{
        global String name;
        global String customername;
        global String role;
        global String email;
        global AttendeeWrapper(string n, string c, string r, string e){
            name = n;
            customername = ' ' + c;
            role = r;
            email = e;
        }
    }
    
}