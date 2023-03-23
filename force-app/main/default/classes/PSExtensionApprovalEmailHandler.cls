/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* PSExtensionApprovalEmailHandler
* @description    CR# 3599 - This class is the trigger handler class to send approval email to approvers.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Chandan Panigrahy
* @modifiedBy     Chandan Panigrahy
* @maintainedBy   Chandan Panigrahy
* @version        1.0
* @created        2022-02-14
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Developer Name
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/

public class PSExtensionApprovalEmailHandler {
    
    private static PSExtensionApprovalEmailHandler instance;
    public static PSExtensionApprovalEmailHandler getInstance() {
        
        if (instance == NULL) {
            instance = new PSExtensionApprovalEmailHandler();
        }
        
        return instance;
    }
    
    private Map<Id, PS_Extension__c> newPSExtMap;
    public void setNewPSExtMap(Map<Id, PS_Extension__c> newPSExtMap) {
        this.newPSExtMap = newPSExtMap;
    }
    
    
    private Map<Id, inspire1__Project__c> inspireProjectMap;
    private void setInspireProjectMap(Map<Id, inspire1__Project__c> inspireProjectMap) {
        this.inspireProjectMap = inspireProjectMap;
    }
    
    private Map<Id, Professional_Service_Project__c> proSerProjectMap;
    private void setProSerProjectMap(Map<Id, Professional_Service_Project__c> proSerProjectMap) {
        this.proSerProjectMap = proSerProjectMap;
    }
    
    
    private void retrieveRelatedProjects() {
        
        Set<Id> recIdSet = new Set<Id> ();
        Set<Id> projectIdSet = new Set<Id> ();
        Set<Id> profServProjectIdSet = new Set<Id> ();
        
        for (PS_Extension__c psExt: newPSExtMap.values()) {
            if (psExt.Professional_Service_Project__c != NULL) {
                profServProjectIdSet.add(psExt.Professional_Service_Project__c);
            } else if (psExt.Project__c != NULL) {
                projectIdSet.add(psExt.Project__c);
            }
        }
        
        
        Map<Id, inspire1__Project__c> inspireProjectMap = new Map<Id, inspire1__Project__c> (
            [SELECT Id,Extension_Type__c, Name, Opportunity__c, Opportunity__r.Geo_Account__c, Opportunity__r.Area__c, Opportunity__r.Region_Account__c FROM inspire1__Project__c WHERE Id IN :projectIdSet LIMIT 50000]
        );
        
        setInspireProjectMap(inspireProjectMap);
        
        Map<Id, Professional_Service_Project__c> proSerProjectMap = new Map<Id, Professional_Service_Project__c> (
            [SELECT Id, Name, Extension_Type__c, Opportunity__c, Opportunity__r.Geo_Account__c, Opportunity__r.Area__c, Opportunity__r.Region_Account__c FROM Professional_Service_Project__c WHERE Id IN :profServProjectIdSet LIMIT 50000]
        );
        
        
        setProSerProjectMap(proSerProjectMap);
        
    }
    
    private Map<String, Id> userEmailIdMap = new Map<String, Id> ();
    
    private final Set<String> userEmailIdSet = new Set<String> {
        'bwheeler@zscaler.com',
            'wdeardorff@zscaler.com',
            'usharma@zscaler.com',
            'acordeiro@zscaler.com',
            'sbhatia@zscaler.com',
            'robin.sharma@zscaler',
            'mmukerji@zscaler.com',
            'gstaff@zscaler.com',
            'rhelbaoui@zscaler.com',
            'jcavanaugh@zscaler.com',
            'bwheeler@zscaler.com.invalid',
            'wdeardorff@zscaler.com.invalid',
            'usharma@zscaler.com.invalid',
            'acordeiro@zscaler.com.invalid',
            'sbhatia@zscaler.com.invalid',
            'robin.sharma@zscaler.com.invalid',
            'mmukerji@zscaler.com.invalid',
            'gstaff@zscaler.com.invalid',
            'rhelbaoui@zscaler.com.invalid',
            'jcavanaugh@zscaler.com.invalid'
            };
                
                
                private Boolean isSandbox() {
                    Organization org = [Select IsSandbox,InstanceName from Organization];
                    
                    return org.IsSandbox;
                }
    
    private void retrieveUsers() {
        
        for (User usr : [SELECT Id, Email FROM User WHERE Email IN :userEmailIdSet]) {
            userEmailIdMap.put(usr.Email, usr.Id);
        }
        
        
    }
    
    
    
    
    private Map<String, Set<String>> geoUserEmailSetMap = new Map<String, Set<String>> {
        'Americas' => new Set<String> {'bwheeler@zscaler.com','wdeardorff@zscaler.com','usharma@zscaler.com', 'acordeiro@zscaler.com'},
            'Public Sector - SLED'=> new Set<String> {'bwheeler@zscaler.com','wdeardorff@zscaler.com','usharma@zscaler.com', 'acordeiro@zscaler.com'},
                'APJ'=> new Set<String> {'sbhatia@zscaler.com','robin.sharma@zscaler'},
                    'EMEA'=> new Set<String> {'gstaff@zscaler.com','mmukerji@zscaler.com'},
                        'WW Enterprise - AMS Enterprise' => new Set<String> {'bwheeler@zscaler.com','wdeardorff@zscaler.com','usharma@zscaler.com', 'acordeiro@zscaler.com'},
                            'WW Enterprise - APJ ENT' => new Set<String> {'sbhatia@zscaler.com'},
                                'WW Enterprise - EMEA ENT' => new Set<String> {'mmukerji@zscaler.com','gstaff@zscaler.com'},
                                    'WW Commercial - APJ' => new Set<String> {'sbhatia@zscaler.com'},
                                        'WW Commercial - AMS' => new Set<String> {'bwheeler@zscaler.com','wdeardorff@zscaler.com','usharma@zscaler.com', 'acordeiro@zscaler.com'},
                                            'WW Commercial - EMEA' => new Set<String> {'mmukerji@zscaler.com','gstaff@zscaler.com'},
                                                'Public Sector' => new Set<String> {'rhelbaoui@zscaler.com','jcavanaugh@zscaler.com'},
                                                    'all' => new Set<String> {'bwheeler@zscaler.com','wdeardorff@zscaler.com','usharma@zscaler.com', 'acordeiro@zscaler.com', 'robin.sharma@zscaler.com','gstaff@zscaler.com','mmukerji@zscaler.com', 'sbhatia@zscaler.com', 'rhelbaoui@zscaler.com','jcavanaugh@zscaler.com'},
                                                        'Americas sandbox' => new Set<String> {'bwheeler@zscaler.com.invalid','wdeardorff@zscaler.com.invalid','usharma@zscaler.com.invalid', 'acordeiro@zscaler.com.invalid'},
                                                            'Public Sector - SLED sandbox' => new Set<String> {'bwheeler@zscaler.com.invalid','wdeardorff@zscaler.com.invalid','usharma@zscaler.com.invalid', 'acordeiro@zscaler.com.invalid'},        
                                                                'APJ sandbox'=> new Set<String> {'sbhatia@zscaler.com.invalid','robin.sharma@zscaler.com.invalid'},
                                                                    'EMEA sandbox'=> new Set<String> {'gstaff@zscaler.com.invalid','mmukerji@zscaler.com.invalid'},
                                                                        'WW Enterprise - AMS Enterprise sandbox' => new Set<String> {'bwheeler@zscaler.com.invalid','wdeardorff@zscaler.com.invalid','usharma@zscaler.com.invalid', 'acordeiro@zscaler.com.invalid'},
                                                                            'WW Enterprise - APJ ENT sandbox' => new Set<String> {'sbhatia@zscaler.com.invalid'},
                                                                                'WW Enterprise - EMEA ENT sandbox' => new Set<String> {'mmukerji@zscaler.com.invalid','gstaff@zscaler.com.invalid'},
                                                                                    'WW Commercial - APJ sandbox' => new Set<String> {'sbhatia@zscaler.com.invalid'},
                                                                                        'WW Commercial - AMS sandbox' => new Set<String> {'bwheeler@zscaler.com.invalid','wdeardorff@zscaler.com.invalid','usharma@zscaler.com.invalid', 'acordeiro@zscaler.com.invalid'},
                                                                                            'WW Commercial - EMEA sandbox' => new Set<String> {'mmukerji@zscaler.com.invalid','gstaff@zscaler.com.invalid'},
                                                                                                'Public Sector sandbox' => new Set<String> {'rhelbaoui@zscaler.com.invalid','jcavanaugh@zscaler.com.invalid'},
                                                                                                    'all sandbox' => new Set<String> {'bwheeler@zscaler.com.invalid','wdeardorff@zscaler.com.invalid','usharma@zscaler.com.invalid', 'acordeiro@zscaler.com.invalid', 'robin.sharma@zscaler.com.invalid','gstaff@zscaler.com.invalid','mmukerji@zscaler.com.invalid', 'sbhatia@zscaler.com.invalid', 'rhelbaoui@zscaler.com.invalid','jcavanaugh@zscaler.com.invalid'}    
    };    
        
        
        public void handle() {
            retrieveRelatedProjects();
            queryEmailTemplates();
            retrieveUsers();
            sendEmail();        
        }
    
    private final Set<String> PS_EXT_EMAIL_TEMPLATESET = new Set<String> {
        'Services_Extension_Rejected',
            'Ext_Review_for_Project_after_IRS',
            'Project_Extension_Request_submission',
            'Services_Extension_Approved'
            };
                
                private Map<String, EmailTemplate> emailTemplateMap;
    
    private void queryEmailTemplates() {
        
        emailTemplateMap = new Map<String, EmailTemplate> ();
        
        for (EmailTemplate eTemp : [
            SELECT 
            Id,
            DeveloperName,
            HtmlValue,
            Body
            FROM
            EmailTemplate
            WHERE
            DeveloperName = :PS_EXT_EMAIL_TEMPLATESET
            LIMIT 4
        ]) {
            
            emailTemplateMap.put(eTemp.DeveloperName, eTemp);
        }
        
    }
    
    
    private void sendEmail() {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage> ();
        
        Set<String> userIdSet = new Set<String> ();
        
        Boolean isSandbox = isSandbox();
        
        for ( PS_Extension__c psExt : newPSExtMap.values()) {
            
            String geoKey = 'all';
            
            inspire1__Project__c inspireProject;
            Professional_Service_Project__c profSerProject;
            
            
            if ((psExt.Professional_Service_Project__c != NULL) && (proSerProjectMap.containsKey(psExt.Professional_Service_Project__c))) {
                
                profSerProject = proSerProjectMap.get(psExt.Professional_Service_Project__c);
                
                
                Boolean isBlankExtensionType = (profSerProject.Opportunity__c != NULL) && (String.isBlank(profSerProject.Extension_Type__c) && (profSerProject.Opportunity__r.Geo_Account__c != NULL));
                
                Boolean isAreaNotBlank = String.isNotBlank(profSerProject.Opportunity__r.Region_Account__c);
                Boolean isRegionNotBlank = String.isNotBlank(profSerProject.Opportunity__r.Area__c);
                
                
                if ( isBlankExtensionType && ( 
                    (profSerProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('Americas')) 
                    || 
                    (
                        (profSerProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('Public Sector')) 
                        && isAreaNotBlank 
                        && (
                            (profSerProject.Opportunity__r.Region_Account__c.equalsIgnoreCase('PS Commercial')) 
                            || 
                            (profSerProject.Opportunity__r.Region_Account__c.equalsIgnoreCase('SLED'))
                        )
                    )
                ) ) {
                    geoKey = 'Americas';
                } else if ( isBlankExtensionType && (profSerProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('APJ')) ) {
                    
                    geoKey = 'APJ';
                    
                } else if ( isBlankExtensionType && (profSerProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('EMEA')) ) {
                    
                    geoKey = 'EMEA';
                    
                } else if ( isBlankExtensionType && (profSerProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('WW Enterprise')) ) {
                    
                    
                    if (isAreaNotBlank && profSerProject.Opportunity__r.Region_Account__c.equalsIgnoreCase('APJ Enterprise')) {
                        geoKey = 'WW Enterprise - APJ ENT';          
                        
                    } else if (isAreaNotBlank && profSerProject.Opportunity__r.Region_Account__c.equalsIgnoreCase('AMS Enterprise')) {
                        geoKey = 'WW Enterprise - AMS Enterprise';
                        
                    } else if (isAreaNotBlank && profSerProject.Opportunity__r.Region_Account__c.equalsIgnoreCase('EMEA Enterprise')) {
                        geoKey = 'WW Enterprise - EMEA ENT';
                        
                    } 
                    
                }
                else if ( isBlankExtensionType && (profSerProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('WW Commercial')) ) {
                    if (isRegionNotBlank && profSerProject.Opportunity__r.Area__c.equalsIgnoreCase('AMS Commercial')) {
                        geoKey = 'WW Commercial - AMS';
                    } else if (isRegionNotBlank && profSerProject.Opportunity__r.Area__c.equalsIgnoreCase('APJ')) {
                        geoKey = 'WW Commercial - APJ';
                    } else if (isRegionNotBlank && profSerProject.Opportunity__r.Area__c.equalsIgnoreCase('EMEA')) {
                        
                        geoKey = 'WW Commercial - EMEA';
                    }
                } else if ( isBlankExtensionType && (profSerProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('Public Sector')) ) {
                    geoKey = 'Public Sector';
                } else {
                    geoKey = 'all';
                }
                
            } else if ((psExt.Project__c != NULL) && (inspireProjectMap.containsKey(psExt.Project__c))) {
                
                inspireProject = inspireProjectMap.get(psExt.Project__c);
                
                
                Boolean isBlankExtensionType = (inspireProject.Opportunity__c != NULL) && (String.isBlank(inspireProject.Extension_Type__c)) && (String.isNotBlank(inspireProject.Opportunity__r.Geo_Account__c));
                Boolean isAreaNotBlank = String.isNotBlank(inspireProject.Opportunity__r.Region_Account__c);
                Boolean isRegionNotBlank = String.isNotBlank(inspireProject.Opportunity__r.Area__c);
                
                if ( isBlankExtensionType && ( (inspireProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('Americas')) || ((inspireProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('Public Sector')) && isAreaNotBlank && ((inspireProject.Opportunity__r.Region_Account__c.equalsIgnoreCase('PS Commercial')) || (inspireProject.Opportunity__r.Region_Account__c.equalsIgnoreCase('SLED'))))) ) {
                    
                    geoKey = 'Americas';
                } else if ( isBlankExtensionType && (inspireProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('APJ')) ) {
                    
                    geoKey = 'APJ';
                    
                } else if ( isBlankExtensionType && (inspireProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('EMEA')) ) {
                    
                    geoKey = 'EMEA';
                    
                } else if ( isBlankExtensionType && (inspireProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('WW Enterprise')) ) {
                    
                    
                    if (isAreaNotBlank && inspireProject.Opportunity__r.Region_Account__c.equalsIgnoreCase('APJ Enterprise')) {
                        geoKey = 'WW Enterprise - APJ ENT';          
                    } else if (isAreaNotBlank && inspireProject.Opportunity__r.Region_Account__c.equalsIgnoreCase('AMS Enterprise')) {
                        geoKey = 'WW Enterprise - AMS Enterprise';
                        
                        
                    } else if (isAreaNotBlank && inspireProject.Opportunity__r.Region_Account__c.equalsIgnoreCase('EMEA Enterprise')) {
                        geoKey = 'WW Enterprise - EMEA ENT';
                        
                    } 
                    
                } else if ( isBlankExtensionType && (inspireProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('WW Commercial')) ) {
                    if (isRegionNotBlank && inspireProject.Opportunity__r.Area__c.equalsIgnoreCase('AMS Commercial')) {
                        geoKey = 'WW Commercial - AMS';
                    } else if (isRegionNotBlank && inspireProject.Opportunity__r.Area__c.equalsIgnoreCase('APJ')) {
                        geoKey = 'WW Commercial - APJ';
                    } else if (isRegionNotBlank && inspireProject.Opportunity__r.Area__c.equalsIgnoreCase('EMEA')) {
                        geoKey = 'WW Commercial - EMEA';
                    }
                } else if ( isBlankExtensionType && (inspireProject.Opportunity__r.Geo_Account__c.equalsIgnoreCase('Public Sector')) ) {
                    geoKey = 'Public Sector';
                    
                } else {
                    geoKey = 'all';
                }
                
            }
            
            geoKey = isSandbox ? geoKey + ' sandbox' : geoKey;
            
            for (String userEmail : geoUserEmailSetMap.get(geoKey)) {
                
                if (userEmailIdMap.containsKey(userEmail)) {
                    userIdSet.add(userEmailIdMap.get(userEmail));    
                }
                
            }
            
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            
            Id targetObjectId = psExt.Id;
            
            if (targetObjectId == NULL) {
                continue;
            }
            
            EmailTemplate emailTemp;
            
            
            if (emailTemplateMap.containsKey('Ext_Review_for_Project_after_IRS')) {
                emailTemp = emailTemplateMap.get('Ext_Review_for_Project_after_IRS');
            }
            
            if (emailTemp == NULL) {
                continue;
            }
            
            if (targetObjectId == NULL) {
                continue;
            }
            
            List<String> userList = new List<String> ();
            userList.addAll(userIdSet);
            
            //userList.add(System.UserInfo.getUserId());
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(String.valueOf(emailTemp.Id), String.valueOf(userList.get(0)), String.valueOf(targetObjectId));
            
            email.setSubject(email.getSubject());
            email.setPlainTextBody(email.getPlainTextBody());
            
            email.setSaveAsActivity(FALSE);
            email.setTreatTargetObjectAsRecipient(FALSE);
            
            email.setToAddresses(userList);
            
            //CC list: Project Manager (Primary),PS Consultant (Primary),Manager of Project Manager 
            List<String> ccAddressList = new List<String> ();
            
            if (psExt.Project_Manager_Primary__c != NULL) {
                ccAddressList.add(psExt.Project_Manager_Primary__c); 
            }
            if (psExt.Manager_of_Project_Manager__c != NULL) {
                ccAddressList.add(psExt.Manager_of_Project_Manager__c);
            }
            if (psExt.PS_Consultant_Primary__c != NULL) {
                ccAddressList.add(psExt.PS_Consultant_Primary__c);
            }
            
            if(!ccAddressList.isEmpty()) {
                email.setCcAddresses(ccAddressList);
            }
            
            emailList.add(email);
            
        }
        
        if(!emailList.isEmpty() && !Test.isRunningTest()){
            List<Messaging.SendEmailResult> emailResponseList = Messaging.sendEmail(emailList);
        }
        
        
    }
    
}