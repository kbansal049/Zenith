/*****************************************************************************************
History
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Initial Development
2.0            Swathi Goudar          30-Aug-2022        IBA-1511
******************************************************************************************/
public without sharing class coSellActivityLWCHelper {
    @AuraEnabled
    public static Cosell_Activities__c updateStatus(Cosell_Activities__c rec, string status){
        if(rec != null && status != null){
            rec.Status__c = status;
            update rec;
        }
        if(status == Label.Cosell_Completed){
            OpportunityPartnerController.WrapperClass ctrl = new OpportunityPartnerController.WrapperClass();
            ctrl.SelectedRecord = new Account(Id = rec.Partner__c,Name = rec.Partner__r.Name);
            List<OpportunityPartnerController.WrapperClass> wrplst = new List<OpportunityPartnerController.WrapperClass>{ctrl};
            if(rec.Opportunity__c != null && rec.Partner__c != null && rec.Activity__c != null){
                OpportunityPartnerController.SavePartnerRec(rec.Opportunity__c, JSON.serialize(wrplst), rec.Activity__c);
            }
        }
        return rec;
    }
    @AuraEnabled
    public static Cosell_Activities__c updateContact(Cosell_Activities__c rec, string contId){
        system.debug('inside update contact' + rec + ' val is ' + contId);
        if(rec != null && contId != null){
            
            rec.Partner_Contact__c = contId;
            update rec;
        }
        return rec;
    }
    @AuraEnabled
    public static Cosell_Activities__c createCosell(Cosell_Activities__c rec){
        if(rec != null){
            rec.Status__c = Label.Cosell_Invited;
            insert rec;
        }
        return rec;
    }
    @AuraEnabled(cacheable=true)
    public static Cosell_Response getCosellDetails(Id oppId){
        Cosell_Response resp = new Cosell_Response();
        if(oppId != null){
            Set<String> statustoQuery = new Set<String>();
            statustoQuery.add(Label.Cosell_Invited);
            statustoQuery.add(Label.Cosell_Accepted);
            statustoQuery.add(Label.Cosell_Completed);
            Integer countofAWinvited = [Select count() from Cosell_Activities__c where Opportunity__c = :oppId and Activity__c = 'Architecture Workshop' and Status__c in :statustoQuery];
            Integer countofPOVinvited = [Select count() from Cosell_Activities__c where Opportunity__c = :oppId and Activity__c = 'POV' and Status__c in :statustoQuery];
            Integer countofAWPOVinvited = [Select count() from Cosell_Activities__c where Opportunity__c = :oppId and Activity__c = 'AW/POV' and Status__c in :statustoQuery]; //CR# 2556 - Added by Ritesh
            resp.hasAWinvited = countofAWinvited > 0;
            resp.hasPOVinvited = countofPOVinvited > 0;
            resp.hasAWPOVinvited = countofAWPOVinvited > 0; //CR# 2556 - Added by Ritesh
            system.debug(resp.hasAWinvited);
            system.debug(resp.hasPOVinvited);
            resp.isCosellPresent = false;
            resp.wrplst = new List<Cosell_Wrapper>();
            for(Cosell_Activities__c csa: [Select Id, Activity__c, Deal_Reg__c,Deal_Reg__r.Status__c , Opportunity__c, Partner__c, Partner__r.Name,Partner__r.Type, Partner_Contact__c, Partner_Contact__r.Name, Partner_Contact_Email__c, Status__c from Cosell_Activities__c where Opportunity__c = :oppId]){
                resp.isCosellPresent = true;
                Cosell_Wrapper wrp = new Cosell_Wrapper(); 
                boolean showInv = false;
                boolean showWd = false;
                boolean showComp = false;
                if(csa.status__c == Label.Cosell_Invited){
                    //IBA-1511 - start
                    if((csa.Partner__r.Type=='Technology Partner') || (csa.Activity__c != 'AW/POV')){
                    	showWd = true;
                    }
                    if((csa.Deal_Reg__c!=Null && csa.Deal_Reg__r.Status__c != 'Expired') || csa.Deal_Reg__c==Null || 
                      (csa.Partner__r.Type=='Technology Partner')){
                        showComp = true;
                    }
                    //IBA-1511 - end
                }else if(csa.status__c == Label.Cosell_Accepted){
                    //IBA-1511 - start
                    if((csa.Activity__c != 'AW/POV') || (csa.Partner__r.Type=='Technology Partner')){
                    	showWd = true;
                    }
                    //IBA-1511 - end
                    showComp = true;
                }else if(!resp.hasAWinvited && csa.Activity__c == 'Architecture Workshop' && csa.status__c == Label.Cosell_Interested){
                    showWd = true;
                    showComp = true;
                    showInv = true;
                }else if(!resp.hasPOVinvited && csa.Activity__c == 'POV' && csa.status__c == Label.Cosell_Interested){
                    showWd = true;
                    showComp = true;
                    showInv = true;
                }
                //CR# 2556 - Added by Ritesh - START
                else if(!resp.hasAWPOVinvited && csa.Activity__c == 'AW/POV' && csa.status__c == Label.Cosell_Interested){
                    showWd = true;
                    showComp = true;
                    showInv = true;
                }
                //CR# 2556 - Added by Ritesh - END
                wrp.rec = csa;
                wrp.showComplete = showComp;
                wrp.showInvite = showInv;
                wrp.showWithdraw = showWd;
                resp.wrplst.add(wrp);
            }
        }
        return resp;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getExistingPartners(Id opportunityId){
        Set<String> resSet = new Set<String> ();
        if(opportunityId != null){
            
            for(Cosell_Activities__c csa: [Select Id, Activity__c, Deal_Reg__c, Opportunity__c, Partner__c, Partner__r.Name, Partner_Contact__c, Partner_Contact__r.Name, Partner_Contact_Email__c, Status__c from Cosell_Activities__c where Opportunity__c = :opportunityId and partner__c != null and Activity__c != null]){
                resSet.add(csa.partner__c + csa.Activity__c);
            }
        }
        return new List<String>(resSet);
    }

    public class Cosell_Wrapper{
        @AuraEnabled
        public Cosell_Activities__c rec;
        @AuraEnabled
        public Boolean showInvite;
        @AuraEnabled
        public Boolean showWithdraw;
        @AuraEnabled
        public Boolean showComplete;

    }

    public class Cosell_Response{
        @AuraEnabled
        public List<Cosell_Wrapper> wrplst;
        @AuraEnabled
        public Boolean isCosellPresent;
        @AuraEnabled
        public Boolean hasAWinvited;
        @AuraEnabled
        public Boolean hasPOVinvited;
        @AuraEnabled
        public Boolean hasAWPOVinvited;//CR# 2556 - Added by Ritesh
    }
}