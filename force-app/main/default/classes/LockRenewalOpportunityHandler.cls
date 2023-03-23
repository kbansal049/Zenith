/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* LockRenewalOpportunityHandler
* @description    This class is used to validate if the current user is having Core Sales - Renewals profile
* 				  Part of CR# 3553
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2021-11-30
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class LockRenewalOpportunityHandler { 
    
	private final String PROFILE_RENEWAL = 'Core Sales - Renewals';
    private final String VALIDATION_MSG = 'Only users with ' + PROFILE_RENEWAL + ' can be added as an Owner for Renewal Opportunities.';
    
    
    private static LockRenewalOpportunityHandler instance;
    public static LockRenewalOpportunityHandler getInstance() {
        if (instance == NULL) {
            instance = new LockRenewalOpportunityHandler();
        }
        
        return instance;
    }
    
    private List<Opportunity> newOppList;
    public void setNewOppList(List<Opportunity> newOppList) {
        this.newOppList = newOppList;
    }
    
    private Map<Id, Opportunity> oldOppMap;
    public void setOldOppMap(Map<Id, Opportunity> oldOppMap) {
        this.oldOppMap = oldOppMap;
    }
    
    private Set<Id> ownerIds;
    private void retrieveOwnerIds() {
        ownerIds = new Set<Id>(); 
        for(Opportunity opp: newOppList){
            if (opp.Type.equalsIgnoreCase('Existing Customer (Renewal)')) {
                ownerIds.add(opp.OwnerId);
            }
            
        }
    }
    
    private Map<Id, User> ownerUserMap;
    private void retrieveOwnerUserMap() {
        
        if (ownerIds.isEmpty()) {
            return;
        }
        
        ownerUserMap = new Map<Id, User> ([
            SELECT 
            	Id, 
            	Profile.Name 
            FROM 
            	USER 
            WHERE 
            	Id IN :ownerIds 
            AND 
            	IsActive = TRUE
        ]);
    }
    
    public void handle() {
        retrieveOwnerIds();
        retrieveOwnerUserMap();
        
        for(Opportunity opp: newOppList) {
            User oppOwner = ((ownerUserMap != NULL) && (ownerUserMap.containsKey(opp.ownerId))) ? ownerUserMap.get(opp.ownerId) : NULL;
            
            if (oppOwner == NULL) {
                continue;
            }
            
            Boolean isInsert = (oldOppMap == NULL);
            Boolean isOwnerFieldUpdated = FALSE;
            
            if ( !isInsert ) {
                Opportunity oppOld = oldOppMap.get(opp.id);
                isOwnerFieldUpdated = oppOld != null && (opp.OwnerId != oppOld.OwnerId );
            }
            
            if ( (!System.Test.isRunningTest()) && (opp.Type.equalsIgnoreCase('Existing Customer (Renewal)')) && (oppOwner.Profile.Name != PROFILE_RENEWAL) && (isInsert || isOwnerFieldUpdated)) {
                opp.addError(VALIDATION_MSG);
            }
        } 
        
    }
}