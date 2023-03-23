public class ZB2BInteractiveRequest implements Queueable {
    
    String objectName;
    List <String> recordIds;
    public ZB2BInteractiveRequest(String objectName, List <String> recordIds) {
        this.objectName = objectName;
        this.recordIds = recordIds;
    }
    public void execute(QueueableContext context) {
        List <Product_Demo_Instance_Request__c> prList = new List <Product_Demo_Instance_Request__c> ();
        if (objectName != null && recordIds != null) {
            Id ZB2BInteractiveRecordTypeId = Schema.SObjectType.Product_Demo_Instance_Request__c.getRecordTypeInfosByName().get('ZB2B Interactive').getRecordTypeId();
            if (objectName == 'Lead') {
                List <Lead> leds = [Select Id, name, Account_Manager__c,bizible2__Account__c, Sales_Engineer__c, Email from Lead where Id in : recordIds];
                for (Lead led: leds) {
                    Product_Demo_Instance_Request__c pr = new Product_Demo_Instance_Request__c();
                    pr.recordTypeId = ZB2BInteractiveRecordTypeId;
                    pr.Lead__c = led.Id;
                    pr.Interactive_User_Email__c = led.Email;
                    pr.Provisioning_Status__c = 'Provisioning Inprogress';
                    pr.Account__c = led.bizible2__Account__c;
                    pr.Manager__c = led.Account_Manager__c;
                    pr.SE__c = led.Sales_Engineer__c;
                    pr.Integration_Status__c = 'Initiated';
                    pr.Full_Name__c = led.name;
                    pr.Provisioning_Date__c = System.today();
                    pr.Provisioning_End_Date__c = System.today() + 7;
                    prList.add(pr);
                }
                if (prList.size() > 0)
                    Insert prList;
            } else if (objectName == 'Contact') {
                List <Contact> cnts = [Select Id, name, AccountId, Account_Manager__c, Sales_Engineer__c, Email from Contact where Id in : recordIds];
                
                MAP<ID,ID> conIDLeadID = new MAP<ID,ID>();
                for(Lead  ld: [Select id,name,convertedContactID from Lead where convertedContactID in : recordIds]){
                    conIDLeadID.put(ld.convertedContactID,ld.id);
                }
                System.debug('--conIDLeadID--'+conIDLeadID);
                
                MAP<ID,ID> leadIDPDR = new MAP<ID,ID>();
                for(Product_Demo_Instance_Request__c  pdr: [Select id,name,Lead__c from Product_Demo_Instance_Request__c where Lead__c in : conIDLeadID.values() 
                                                            and Primary_Eval_Contact__c = null order by createddate]){
                                                                leadIDPDR.put(pdr.Lead__c,pdr.id);
                                                            }
                
                for (Contact con: cnts) {
                    if(conIDLeadID.containskey(con.id) && conIDLeadID.get(con.id) != null){
                        ID leadID = conIDLeadID.get(con.id);
                        ID pdrID = leadIDPDR.get(leadID);
                        if(pdrID != null){
                            Product_Demo_Instance_Request__c pr = new Product_Demo_Instance_Request__c();
                            pr.id = pdrID;
                            pr.Primary_Eval_Contact__c = con.id;
                            prList.add(pr);
                        }
                    }else{
                        Product_Demo_Instance_Request__c pr = new Product_Demo_Instance_Request__c();
                        pr.recordTypeId = ZB2BInteractiveRecordTypeId;
                        pr.Primary_Eval_Contact__c = con.Id;
                        pr.Account__c = con.AccountId;
                        pr.Interactive_User_Email__c = con.Email;
                        pr.Provisioning_Status__c = 'Provisioning Inprogress';
                        pr.Manager__c = con.Account_Manager__c;
                        pr.Integration_Status__c = 'Initiated';
                        pr.SE__c = con.Sales_Engineer__c;
                        pr.Full_Name__c = con.name;
                        pr.Provisioning_Date__c = System.today();
                        pr.Provisioning_End_Date__c = System.today() + 7;
                        prList.add(pr);
                    }
                }
                
                if (prList.size() > 0)
                    upsert prList;
            }
        }
    }
}