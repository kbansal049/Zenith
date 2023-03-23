// One time batch to trigger the Account to update the Market Segment
public class UpdateMarketSegmentonAccountbatch implements Database.Batchable<SObject>, Database.Stateful {
   ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateMarketSegmentonAccountbatch');
    public Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        // string query = 'SELECT id,No_of_Employees_Users__c,NumberOfEmployees,Market_Segment__c from Account where Override_Market_Segment__c=False and id in:Accidset';
        set<string> Employeerangeset= new Set<string>();
        Employeerangeset.add('1000 - 1999');
        Employeerangeset.add('2000 - 7999');
        Employeerangeset.add('8000 - 19999');
        string query='';
        if(!test.isrunningtest()){
        query = 'SELECT id,No_of_Employees_Users__c,NumberOfEmployees,Market_Segment__c from Account where Override_Market_Segment__c=False and No_of_Employees_Users__c IN:Employeerangeset'; 
        }else{
        query = 'SELECT id,No_of_Employees_Users__c,NumberOfEmployees,Market_Segment__c from Account where Override_Market_Segment__c=False'; 
        }
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<Account> NewAccountList){
		this.zb.callExecute(NewAccountList[0]?.Id, NewAccountList.size());
        if(NewAccountList.size()>0){
            for(Account acc:NewAccountList){    
                system.debug('inside if condition'+acc);
                /* boolean needtoexecute2=false;
                boolean needtoexecute3=false;
                 if(IsInsert){
                    if(acc.NumberOfEmployees != null){
                        needtoexecute2=true;
                    }
                    if(acc.NumberOfEmployees == null && acc.No_of_Employees_Users__c != null){
                        needtoexecute3=true;
                    }
                }
                if(isupdate){
                    Account oldAccount;
                    oldAccount = oldMap.get(acc.Id);
                    
                    if(!acc.Override_Market_Segment__c && (acc.TriggerPatchAssignment__c || (acc.NumberOfEmployees!= null && acc.NumberOfEmployees != oldAccount.NumberOfEmployees) || (acc.No_of_Employees_Users__c != oldAccount.No_of_Employees_Users__c && acc.NumberOfEmployees!=null))){
                        needtoexecute2=true;
                    }
                    if(!acc.Override_Market_Segment__c && (acc.TriggerPatchAssignment__c || (acc.No_of_Employees_Users__c != oldAccount.No_of_Employees_Users__c && acc.NumberOfEmployees==null))){
                        needtoexecute3=true;
                    }
                } */

            
                // if((needtoexecute2 || needtoexecute3){
               // system.debug('inside if condition');
                if(acc.NumberOfEmployees == null && acc.No_of_Employees_Users__c == null ){
                    system.debug('inside first if condition');
                    acc.Market_Segment__c='SMB';
                    acc.No_of_Employees_Users__c='0 - 99';
                }else if(acc.NumberOfEmployees != null ){
                    system.debug('inside second if condition');
                    for(Market_Segmentation_Setting__c setting : Market_Segmentation_Setting__c.getall().values() ) {
                        if(acc.NumberOfEmployees >= setting.Start_Range__c && acc.NumberOfEmployees <=setting.End_Range__c) {
                        system.debug('setting  '+setting);          //setting.Is_EMEA_Region__c ==  isEMEARegion  // for future use
                            acc.Market_Segment__c = setting.Market_Segmentation__c;

                            if(acc.NumberOfEmployees>=40000){
                                acc.No_of_Employees_Users__c='40000+';
                            }else if(acc.NumberOfEmployees>=20000){
                                acc.No_of_Employees_Users__c='20000 - 39999';
                            }else if(acc.NumberOfEmployees>=5500){
                                acc.No_of_Employees_Users__c='5500 - 19999';
                            }else if(acc.NumberOfEmployees>=1250){
                                acc.No_of_Employees_Users__c='1250 - 5499';
                            }else if(acc.NumberOfEmployees>=1000){
                                acc.No_of_Employees_Users__c='1000 - 1249';
                            }else if(acc.NumberOfEmployees>=500){
                                acc.No_of_Employees_Users__c='500 - 999';
                            }else if(acc.NumberOfEmployees>=250){
                                acc.No_of_Employees_Users__c='250 - 499';
                            }else if(acc.NumberOfEmployees>=100){
                                acc.No_of_Employees_Users__c='100 - 249';
                            }else if(acc.NumberOfEmployees>=0){
                                acc.No_of_Employees_Users__c='0 - 99';
                            }                           
                                break;
                            }
                        }
                }
                else if (acc.NumberOfEmployees == null && acc.No_of_Employees_Users__c != null){
                    system.debug('inside third if condition');                  
                    Integer startRange = 0, endRange = 0;
                    if(acc.No_of_Employees_Users__c.contains(' - ')){
                        startRange =Integer.valueOf( acc.No_of_Employees_Users__c.split(' - ')[0].trim() );
                        endRange = Integer.valueOf( acc.No_of_Employees_Users__c.split(' - ')[1].trim() );
                    }else if(acc.No_of_Employees_Users__c.contains('+')){
                        startRange =Integer.valueOf( acc.No_of_Employees_Users__c.substringBefore('+').trim() );
                    }
                    system.debug('startRange  '+startRange);
                    system.debug('endRange  '+endRange);
                    for(Market_Segmentation_Setting__c setting : Market_Segmentation_Setting__c.getall().values() ) {
                        if(acc.No_of_Employees_Users__c.contains(' - ') && setting.Start_Range__c <= startRange && setting.End_Range__c >= endRange) { //setting.Is_EMEA_Region__c ==  isEMEARegion  // for future use
                            system.debug('setting  '+setting);  
                            acc.Market_Segment__c  = setting.Market_Segmentation__c;
                            system.debug('acc.Market_Segment__c  '+acc.Market_Segment__c);
                            break;
                        } else if(acc.No_of_Employees_Users__c.contains('+') && setting.Start_Range__c == startRange ) {
                            system.debug('setting  '+setting);
                            acc.Market_Segment__c  = setting.Market_Segmentation__c;
                            system.debug('acc.Market_Segment__c  '+acc.Market_Segment__c);
                            break;
                        }
                    
                    }
                
                }
            }
        
            //}
            
        }
        TriggerUtility.UpdatingMarketsegmentforEMEAsettrue();
        update NewAccountList;
                
    }
    
    public void finish(Database.BatchableContext BC) {
        this.zb.callFinish(bc);
    }
}