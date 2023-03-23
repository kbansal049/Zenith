trigger UpdateSAonAcct on SCI_Zscaler_Attendee__c (after insert, after update,after delete, after undelete) {
    
    try{ 
        //After Insert
        //Bulk Supported = True
        if(trigger.isInsert && trigger.isAfter){
            MAP<ID,Account> acMAP = new MAP<ID,Account>();            
            Set<ID> accountID = new Set<ID>();
            for(SCI_Zscaler_Attendee__c z : trigger.new){
                if(z.Account_Id__c != null && z.Solution_Architect_attended_SCI__c == TRUE){
                   accountID.add(z.Account_Id__c);
                }
            }
            if(accountID.size()>0){
                for (Account QueriedAccount : [SELECT Id,Solution_Architect_Attended_SCI__c FROM Account where Solution_Architect_Attended_SCI__c != true and Id in :accountID]){
                     QueriedAccount.Solution_Architect_Attended_SCI__c = true;
                     acMAP.put(QueriedAccount.Id, QueriedAccount);
                }
            }
            if(acMAP.size()>0){
                Database.update(acMAP.values(), false);
            }
        }
        
        //After Update
        //Bulk Supported = True
        if(trigger.isupdate && trigger.isAfter){
            MAP<ID,Account> acUpadteMAP = new MAP<ID,Account>();
            Set<ID> accountID = new Set<ID>();
            for(SCI_Zscaler_Attendee__c z : trigger.new){
                if(z.Account_Id__c != null){
                   accountID.add(z.Account_Id__c);
                }
            }
           	MAP<ID,Account> accSCIMAP = new MAP<ID,Account>([SELECT Id,Solution_Architect_Attended_SCI__c FROM Account where  Id in :accountID]);    
            for(SCI_Zscaler_Attendee__c z :trigger.new){
                if(z.Account_Id__c != null && accSCIMAP.containskey(z.Account_Id__c)){
                    Account QueriedAccount = accSCIMAP.get(z.Account_Id__c);
                    if(z.Solution_Architect_attended_SCI__c == TRUE){   
                        if(QueriedAccount.Solution_Architect_Attended_SCI__c != true){
                            QueriedAccount.Solution_Architect_Attended_SCI__c = true;
                            acUpadteMAP.put(QueriedAccount.Id, QueriedAccount);
                        }
                    }else{
                       	SCI_Zscaler_Attendee__c zOld =  trigger.oldmap.get(z.id);
                        if(zOld.Solution_Architect_Attended_SCI__c == true){
                            Integer count = [SELECT count() from SCI_Zscaler_Attendee__c where Solution_Architect_Attended_SCI__c = true AND Account_Id__c = :z.Account_Id__c]; 
                            if(count>=1){
                                QueriedAccount.Solution_Architect_Attended_SCI__c = true;
                                acUpadteMAP.put(QueriedAccount.Id, QueriedAccount);
                            }else{
                                QueriedAccount.Solution_Architect_Attended_SCI__c = false;
                                acUpadteMAP.put(QueriedAccount.Id, QueriedAccount);
                            }
                        }
                    }
                }
            }
            
            if(acUpadteMAP.size()>0){
                Database.update(acUpadteMAP.values(), false);
            }
        }
        
        //After Delete
        //Bulk Supported = True
        if(trigger.isdelete && trigger.isAfter){
            MAP<ID,Account> acUpadteMAP = new MAP<ID,Account>();
            for(SCI_Zscaler_Attendee__c z :trigger.old){
                if(z.Solution_Architect_attended_SCI__c == TRUE && z.Account_Id__c != null){   
                    Account acc = new Account();
                    acc.id = z.Account_Id__c;
                    Integer count = [SELECT count() from SCI_Zscaler_Attendee__c where Solution_Architect_Attended_SCI__c = true AND Account_Id__c = :z.Account_Id__c]; 
                    if(count>=1){
                        acc.Solution_Architect_Attended_SCI__c = true;
                        acUpadteMAP.put(acc.Id, acc);
                    }else{
                        acc.Solution_Architect_Attended_SCI__c = false;
                        acUpadteMAP.put(acc.Id, acc);
                    }
                }
            }
            if(acUpadteMAP.size()>0){
                Database.update(acUpadteMAP.values(), false);
            }
        }
        
        //After UnDelete
        //Bulk Supported = True
        if(trigger.isundelete && trigger.isAfter){
            MAP<ID,Account> acUpadteMAP = new MAP<ID,Account>();
            Set<ID> accountID = new Set<ID>();
            for(SCI_Zscaler_Attendee__c z : trigger.new){
                if(z.Account_Id__c != null){
                   accountID.add(z.Account_Id__c);
                }
            }
           	MAP<ID,Account> accSCIMAP = new MAP<ID,Account>([SELECT Id,Solution_Architect_Attended_SCI__c FROM Account where  Id in :accountID]);  
            for(SCI_Zscaler_Attendee__c z :trigger.new){
                if(z.Solution_Architect_attended_SCI__c == TRUE && accSCIMAP.containskey(z.Account_Id__c)){   
                    Account accRec = accSCIMAP.get(z.Account_Id__c);
                    if(accRec.Solution_Architect_Attended_SCI__c != true){
                        accRec.Solution_Architect_Attended_SCI__c = true;
                        acUpadteMAP.put(accRec.Id, accRec);
                    }
                }
            }
            if(acUpadteMAP.size()>0){
                Database.update(acUpadteMAP.values(), false);
            }
        }
        
    }catch(Exception e){
        System.debug('An unexpected error has occurred: ' + e.getMessage());
    }
}