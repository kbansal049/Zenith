public class UpdateContactTouchesBatch implements Database.Batchable<sObject>, Database.Stateful{
    ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateContactTouchesBatch');
    
    public Database.QueryLocator start(Database.BatchableContext context){
        this.zb.callStart();
        //String Recid='0030g000026aRQW'; //and id=:Accid  where id=:Recid
        String query = 'SELECT id,Last_Opened_Date__c,Touches_Since_Last_Open__c from Contact where Last_Opened_Date__c!=null';
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<Contact> ConList){
        try{
            this.zb.callExecute(ConList[0]?.Id, ConList.size());
            List<id> contact_ids = new List<id>();
            List<Contact> ConListtoupdate = new List<Contact>();
            for(Contact con:ConList){
                contact_ids.add(con.id);
                //contact_ids.add('0030g000026aRQW');
            }
            system.debug('contact_ids '+contact_ids);
            for(Contact c : [SELECT Last_Opened_Date__c,Touches_Since_Last_Open__c,(select id,ActivityDate from tasks where Status= 'Completed'),(select id,ActivityDate,enddatetime from events) FROM Contact WHERE ID IN :contact_ids and Last_Opened_Date__c!=null]){
                Integer taskscount =  c.tasks.size();
                Integer eventscount =  c.events.size();
                system.debug('taskscount   '+taskscount);
                system.debug('eventscount   '+eventscount);
                system.debug('c   '+c);
                
                Integer taskscount2 =  0;
                for(task t:c.tasks){
                    system.debug('tasks '+t);
                    if(t.ActivityDate>=c.Last_Opened_Date__c){
                        taskscount2=taskscount2+1;
                    }
                }
                system.debug('taskscount2  '+taskscount2);  
                integer Eventcount2 =  0;
                for(event evnt:c.events){
                    system.debug('evnt '+evnt);
                    if(evnt.ActivityDate>=c.Last_Opened_Date__c && evnt.enddatetime<=System.now()){
                        Eventcount2=Eventcount2+1;
                    }
                }
                system.debug('Eventcount2  '+Eventcount2);  
                Decimal totalcount2 = taskscount2+Eventcount2;
                system.debug('totalcount2  '+totalcount2);  
                c.Touches_Since_Last_Open__c=totalcount2;
                ConListtoupdate.add(c);
            }
            system.debug('ConListtoupdate '+ConListtoupdate);
            update ConListtoupdate;
            system.debug('ConListtoupdate '+ConListtoupdate);
        }catch(Exception e){
            
        }
    }
    
    public void finish(Database.BatchableContext context){
        this.zb.callFinish(context);
    } 
    
}