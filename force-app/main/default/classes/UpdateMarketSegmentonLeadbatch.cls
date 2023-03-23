// One time batch to trigger the Lead to update the Market Segment
public class UpdateMarketSegmentonLeadbatch implements Database.Batchable<SObject>, Database.Stateful {
   ZscalerBatchFramework zb = new ZscalerBatchFramework('UpdateMarketSegmentonLeadbatch');
    public Database.QueryLocator start(Database.BatchableContext BC){
        this.zb.callStart();
        set<string> Employeerangeset= new Set<string>();
        Employeerangeset.add('1000 - 1999');
        Employeerangeset.add('2000 - 7999');
        Employeerangeset.add('8000 - 19999');
        string query='';
        if(!test.isrunningtest()){
         query = 'SELECT id,No_Employees_Users__c,NumberOfEmployees,Market_Segment__c,Market_Segment_Batch_Procesed__c,Override_Market_Segment__c from Lead where Override_Market_Segment__c=False and NumberOfEmployees=null and No_Employees_Users__c IN:Employeerangeset';
        }else{
        query = 'SELECT id,No_Employees_Users__c,NumberOfEmployees,Market_Segment__c,Market_Segment_Batch_Procesed__c,Override_Market_Segment__c from Lead where Override_Market_Segment__c=False';
        }
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> LeadList){
		this.zb.callExecute(LeadList[0]?.Id, LeadList.size());
        if(LeadList.size()>0){
            for(Lead ld:LeadList){    
                system.debug('inside if condition'+ld);
                if(ld.No_Employees_Users__c=='1000 - 1999'){
                    ld.No_Employees_Users__c='1000 - 1249';
                }else if(ld.No_Employees_Users__c=='2000 - 7999'){
                    ld.No_Employees_Users__c='1250 - 5499';
                } else if(ld.No_Employees_Users__c=='8000 - 19999'){
                    ld.No_Employees_Users__c='5500 - 19999';
                }
                /*if(ld.NumberOfEmployees == null && ld.No_Employees_Users__c == null ){
                    system.debug('inside first if condition');
                    ld.Market_Segment__c='SMB';
                    ld.No_Employees_Users__c='0 - 99';
                }else if(ld.NumberOfEmployees != null ){
                    system.debug('inside second if condition');
                    for(Market_Segmentation_Setting__c setting : Market_Segmentation_Setting__c.getall().values() ) {
                        if(ld.NumberOfEmployees >= setting.Start_Range__c && ld.NumberOfEmployees <=setting.End_Range__c) {
                        system.debug('setting  '+setting);          //setting.Is_EMEA_Region__c ==  isEMEARegion  // for future use
                            ld.Market_Segment__c = setting.Market_Segmentation__c;
                            
                            if(ld.NumberOfEmployees>=40000){
                                ld.No_Employees_Users__c='40000+';
                            }else if(ld.NumberOfEmployees>=20000){
                                ld.No_Employees_Users__c='20000 - 39999';
                            }else if(ld.NumberOfEmployees>=5500){
                                ld.No_Employees_Users__c='5500 - 19999';
                            }else if(ld.NumberOfEmployees>=1250){
                                ld.No_Employees_Users__c='1250 - 5499';
                            }else if(ld.NumberOfEmployees>=1000){
                                ld.No_Employees_Users__c='1000 - 1249';
                            }else if(ld.NumberOfEmployees>=500){
                                ld.No_Employees_Users__c='500 - 999';
                            }else if(ld.NumberOfEmployees>=250){
                                ld.No_Employees_Users__c='250 - 499';
                            }else if(ld.NumberOfEmployees>=100){
                                ld.No_Employees_Users__c='100 - 249';
                            }else if(ld.NumberOfEmployees>=0){
                                ld.No_Employees_Users__c='0 - 99';
                            }                           
                                break;
                            }
                        }
                }
                else if (ld.NumberOfEmployees == null && ld.No_Employees_Users__c != null){
                    system.debug('inside third if condition');                  
                    Integer startRange = 0, endRange = 0;
                    if(ld.No_Employees_Users__c.contains(' - ')){
                        startRange =Integer.valueOf( ld.No_Employees_Users__c.split(' - ')[0].trim() );
                        endRange = Integer.valueOf( ld.No_Employees_Users__c.split(' - ')[1].trim() );
                    }else if(ld.No_Employees_Users__c.contains('+')){
                        startRange =Integer.valueOf( ld.No_Employees_Users__c.substringBefore('+').trim() );
                    }
                    system.debug('startRange  '+startRange);
                    system.debug('endRange  '+endRange);
                    for(Market_Segmentation_Setting__c setting : Market_Segmentation_Setting__c.getall().values() ) {
                        if(ld.No_Employees_Users__c.contains(' - ') && setting.Start_Range__c <= startRange && setting.End_Range__c >= endRange) { //setting.Is_EMEA_Region__c ==  isEMEARegion  // for future use
                            system.debug('setting  '+setting);  
                            ld.Market_Segment__c  = setting.Market_Segmentation__c;
                            system.debug('ld.Market_Segment__c  '+ld.Market_Segment__c);
                            break;
                        } else if(ld.No_Employees_Users__c.contains('+') && setting.Start_Range__c == startRange ) {
                            system.debug('setting  '+setting);
                            ld.Market_Segment__c  = setting.Market_Segmentation__c;
                            system.debug('ld.Market_Segment__c  '+ld.Market_Segment__c);
                            break;
                        }
                    
                    }
                
                }
                */
                ld.Market_Segment_Batch_Procesed__c=true;
            }
        
            //}
            
        }
        TriggerUtility.UpdatingMarketsegmentforLeadsettrue();
        TriggerUtility.afterUpdateRelatedLeadExecuted();
        Database.update(LeadList,false);
                
    }
    
    public void finish(Database.BatchableContext BC) {
		this.zb.callFinish(bc);        
    }
}