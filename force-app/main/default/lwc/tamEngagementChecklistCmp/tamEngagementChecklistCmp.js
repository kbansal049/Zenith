import { LightningElement,api,track } from 'lwc';

import checkDocs from '@salesforce/apex/TAMEngagementChecklistCmpCtrl.checkDocs';
import checkAdoptionPercentage from '@salesforce/apex/TAMEngagementChecklistCmpCtrl.checkAdoptionPercentage';
import checkWeeklyMeetings from '@salesforce/apex/TAMEngagementChecklistCmpCtrl.checkWeeklyMeetings';
import checkTAMProjectStatus from '@salesforce/apex/TAMEngagementChecklistCmpCtrl.checkTAMProjectStatus';
import calculateReductionInCases from '@salesforce/apex/TAMEngagementChecklistCmpCtrl.calculateReductionInCases';
import getAdoptionRates from '@salesforce/apex/TAMEngagementChecklistCmpCtrl.getAdoptionRates';
import getCustomerSentiment from '@salesforce/apex/TAMEngagementChecklistCmpCtrl.getCustomerSentiment';
import getTAMMeetingDetails from '@salesforce/apex/TAMEngagementChecklistCmpCtrl.getTAMMeetingDetails';
import getOprContacts from '@salesforce/apex/OperationalContactsTableCtrl.getOperationalContacts';
//IBA - 3334 By Hitesh Sachdeva Starts
import TAMEngagementURL from '@salesforce/label/c.TamEngagementHelpURL';
//IBA - 3334 By Hitesh Sachdeva End

const stageChecklistMap = {
        'STAGE 1: Onboarding' : [       
                    'MARK_ATLEAST_ONE_OPERATIONAL_CONTACT'
                    ],
        'STAGE 2: Establish Alignment' : [
                    'BCP_DOCUMENT_REQUIRED'
                    ],
        'STAGE 3: Adoption Acceleration/Operation Excellence' : [
                    'DRIVE_50_Perc_ADOPTION',
                    'WEEKLY_MEETINGS_ARE_OCCURING'
                    ],
        'STAGE 4: Audit' : [
                    'HEALTH_CHECK_AUDIT_DOCUMENT_REQUIRED',
                    'CONFIG_AUDIT_TAM_PROJECTS_ARE_COMPLETED'
                    ],
        'STAGE 5: Continuous Adoption' : [
                    'DRIVE_75_Perc_ADOPTION',
                    'WEEKLY_MEETINGS_ARE_OCCURING',
                    'REDUCTION_IN_TICKETS_LOGGED'
                    ],
        'STAGE 6: Business Continuity' : []
};

const checklistMessageMap = {
    'BCP_DOCUMENT_REQUIRED' : 'You are required to upload a BCP Document.',
    'DRIVE_50_Perc_ADOPTION' : 'You are required to have above 50% adoption.',
    'WEEKLY_MEETINGS_ARE_OCCURING' : 'A weekly meeting must\'ve occured in the last 45 days.',
    'HEALTH_CHECK_AUDIT_DOCUMENT_REQUIRED' : 'You are required to upload a Config Audit Document.',
    'DRIVE_75_Perc_ADOPTION' : 'You are required to have above 75% adoption.',
    'CONFIG_AUDIT_TAM_PROJECTS_ARE_COMPLETED' : 'A TAM Project with sub-type : Configuration Audit must be in a Complete state.',
    'REDUCTION_IN_TICKETS_LOGGED' : 'Is there a 15% reduction in the tickets logged by Customers?',
    'MARK_ATLEAST_ONE_OPERATIONAL_CONTACT' : 'Mark atleast one operational contact.'
};

export default class TamEngagementChecklistCmp extends LightningElement {
    @api tamEngagementStage = '';
    @track resolvedItems = [];
    @track unresolvedItems = [];
    @api recordId = '';
    @track initialized = true;
    showSpinner = false;
    @track adoptionRates = [];
    @track caseReductionItems = [];
    @track customerSentiment = '';
    @track tamMeetingLink= '';
    @track tamMeetingName= '';
    @api parentId='';
    //IBA - 3334 By Hitesh Sachdeva Starts
    helplinkLabel = TAMEngagementURL;
    //IBA - 3334 By Hitesh Sachdeva End

    @track checklistStatusMap = {
        'BCP_DOCUMENT_REQUIRED' : false,
        'DRIVE_50_Perc_ADOPTION' : false,
        'WEEKLY_MEETINGS_ARE_OCCURING' : false,
        'HEALTH_CHECK_AUDIT_DOCUMENT_REQUIRED' : false,
        'DRIVE_75_Perc_ADOPTION' : false,
        'CONFIG_AUDIT_TAM_PROJECTS_ARE_COMPLETED' : false,
        'REDUCTION_IN_TICKETS_LOGGED' : false,
        'MARK_ATLEAST_ONE_OPERATIONAL_CONTACT' : false
    };

    get displayAdoptionRates() {
        if(this.tamEngagementStage == 'STAGE 3: Adoption Acceleration/Operation Excellence' ||
            this.tamEngagementStage == 'STAGE 5: Continuous Adoption') {
                return true;
        }
        else {
            return false;
        }
    }

    get displayCaseReductionSection() {
        if(this.tamEngagementStage == 'STAGE 5: Continuous Adoption') {
            return true;
        }
        else {
            return false;
        }
    }

    get displayCustomerSentiment() {
        if(this.tamEngagementStage == 'STAGE 4: Audit') {
            return true;
        }
        else {
            return false;
        }
    }

    get displayTAMMeeting() {
        if((this.tamEngagementStage == 'STAGE 3: Adoption Acceleration/Operation Excellence' || this.tamEngagementStage == 'STAGE 5: Continuous Adoption')
            && this.tamMeetingLink != '' && this.tamMeetingLink != undefined && this.tamMeetingName != undefined && this.tamMeetingName != '') {
            return true;
        }
        else {
            return false;
        }
    }

    get getResolvedItems() {
        let arr = [];
        let arrChecklist = stageChecklistMap[this.tamEngagementStage];
        for(let index in arrChecklist) {
            if(this.checklistStatusMap[arrChecklist[index]]) {
                arr.push(checklistMessageMap[arrChecklist[index]]);
            }
        }
        return arr;
    }

    get getUnresolvedItems() {
        let arr = [];
        let arrChecklist = stageChecklistMap[this.tamEngagementStage];
        for(let index in arrChecklist) {
            if(!this.checklistStatusMap[arrChecklist[index]]) {
                arr.push(checklistMessageMap[arrChecklist[index]]);
            }
        }
        return arr;
    }

    get hasResolved() {
        let arr = [];
        let arrChecklist = stageChecklistMap[this.tamEngagementStage];
        for(let index in arrChecklist) {
            if(this.checklistStatusMap[arrChecklist[index]]) {
                arr.push(checklistMessageMap[arrChecklist[index]]);
            }
        }
        if(arr.length > 0) {
            return true;
        }
        else {
            return false;
        }
    }

    get hasUnresolved() {
        let arr = [];
        let arrChecklist = stageChecklistMap[this.tamEngagementStage];
        for(let index in arrChecklist) {
            if(!this.checklistStatusMap[arrChecklist[index]]) {
                arr.push(checklistMessageMap[arrChecklist[index]]);
            }
        }
        if(arr.length > 0) {
            return true;
        }
        else {
            return false;
        }
    }

    get getSentimentIcon() {
        if(this.customerSentiment != undefined && this.customerSentiment != '') {
            let lowerCaseSentiment = this.customerSentiment.toLowerCase();
            if(lowerCaseSentiment.includes('positive')) {
                return "utility:smiley_and_people";
            }
            else if(lowerCaseSentiment.includes('negative')) {
                return "utility:sentiment_negative";
            } 
            else {
                return "utility:sentiment_neutral";
            }
        }
        else {
            return "utility:sentiment_neutral";
        }
    }

    get getSentimentStyle() {
        if(this.customerSentiment != undefined && this.customerSentiment != '') {
            let lowerCaseSentiment = this.customerSentiment.toLowerCase();
            if(lowerCaseSentiment.includes('positive')) {
                return "color : green;";
            }
            else if(lowerCaseSentiment.includes('negative')) {
                return "color : red;";
            } 
            else {
                return "";
            }
        }
        else {
            return "";
        }
    }

    connectedCallback() {
        this.init();
    }

    @api
    init() {
        this.showSpinner = true;
        if(this.record != '' && this.recordId != undefined && this.tamEngagementStage != '' && this.tamEngagementStage != undefined) {
            this.evaluateChecklistItems();
        }
    }

    refreshCall() {
        this.init();
    }
    
    //IBA - 3334 By Hitesh Sachdeva Starts
    helpTab() {
        window.open(this.helplinkLabel, "_blank");       
    }
    //IBA - 3334 By Hitesh Sachdeva End

    evaluateChecklistItems() {
            if(this.tamEngagementStage == 'STAGE 2: Establish Alignment') {
                this.checkDocsHandler('BCP');
            }
            else if(this.tamEngagementStage == 'STAGE 3: Adoption Acceleration/Operation Excellence') {
                this.checkAdoptionPercentageHandler(50);
                this.checkWeeklyMeetingsHandler();
                this.getAdoptionRatesHandler();
                this.getTAMMeetingDetailsHandler();
            }
            else if(this.tamEngagementStage == 'STAGE 4: Audit') {
                this.checkDocsHandler('Config Audit Document');
                this.getCustomerSentimentHandler();
                this.checkTAMProjectStatusHandler();
            }
            else if(this.tamEngagementStage == 'STAGE 5: Continuous Adoption') {
                this.checkAdoptionPercentageHandler(75);
                this.checkWeeklyMeetingsHandler();
                this.getTAMMeetingDetailsHandler();
                this.calculateReductionInCasesHandler();
                this.getAdoptionRatesHandler();
            }
            else if(this.tamEngagementStage == 'STAGE 1: Onboarding') {
                this.getOperationalContactsHandler();
            }
        } 

    checkDocsHandler(docType) {
        this.showSpinner = true;
        checkDocs({ 
            recordId : this.recordId,
            docType : docType
        })
        .then(result => {
                if(docType == 'BCP') {
                    if(result) {
                        this.checklistStatusMap['BCP_DOCUMENT_REQUIRED'] = true;
                    }
                    else {
                        this.checklistStatusMap['BCP_DOCUMENT_REQUIRED'] = false;
                    }
                }
                else if(docType == 'Config Audit Document') {
                    if(result) {
                        this.checklistStatusMap['HEALTH_CHECK_AUDIT_DOCUMENT_REQUIRED'] = true;
                    }
                    else {
                        this.checklistStatusMap['HEALTH_CHECK_AUDIT_DOCUMENT_REQUIRED'] = false;
                    }
                }
                this.showSpinner = false;
                this.callParentCmp(); 
        })
        .catch(error => {
            console.log('Error received: code' + error.errorCode + ', ' +'message ' + error.body.message);
        });
    }
    
    checkAdoptionPercentageHandler(perc) {
        this.showSpinner = true;
        checkAdoptionPercentage({
            recordId : this.recordId,
            perc : perc
        })
        .then(result => {
            if(perc == 50) {
                if(result) {
                    this.checklistStatusMap['DRIVE_50_Perc_ADOPTION'] = true;
                }
                else {
                    this.checklistStatusMap['DRIVE_50_Perc_ADOPTION'] = false;
                }
            }
            else if(perc == 75) {
                if(result) {
                    this.checklistStatusMap['DRIVE_75_Perc_ADOPTION'] = true;
                }
                else {
                    this.checklistStatusMap['DRIVE_75_Perc_ADOPTION'] = false;
                }
            }
            this.showSpinner = false;
            this.callParentCmp();
        })
        .catch(error => {
            console.log('Error received: code' + error.errorCode + ', ' +'message ' + error.body.message);
        });
    }

    checkWeeklyMeetingsHandler() {
        this.showSpinner = true;
        checkWeeklyMeetings({
            recordId : this.recordId,
        })
        .then(result => {
            if(result) {
                this.checklistStatusMap['WEEKLY_MEETINGS_ARE_OCCURING'] = true;
            }
            else {
                this.checklistStatusMap['WEEKLY_MEETINGS_ARE_OCCURING'] = false;
            }
            this.showSpinner = false;
            this.callParentCmp();
        })
        .catch(error => {
            console.log('Error received: code' + error.errorCode + ', ' +'message ' + error.body.message);
        });
    }

    checkTAMProjectStatusHandler() {
        this.showSpinner = true;
        checkTAMProjectStatus({
            recordId : this.recordId,
        })
        .then(result => {
            if(result) {
                this.checklistStatusMap['CONFIG_AUDIT_TAM_PROJECTS_ARE_COMPLETED'] = true;
            }
            else {
                this.checklistStatusMap['CONFIG_AUDIT_TAM_PROJECTS_ARE_COMPLETED'] = false;
            }
            this.showSpinner = false;
            this.callParentCmp();
        })
        .catch(error => {
            console.log('Error received: code' + error.errorCode + ', ' +'message ' + error.body.message);
        });
    }

    calculateReductionInCasesHandler() {
        this.showSpinner = true;
        calculateReductionInCases({
            recordId : this.recordId,
        })
        .then(result => {
            if(result) {
                this.caseReductionItems = result.details;
                this.checklistStatusMap['REDUCTION_IN_TICKETS_LOGGED'] = result.flag;
            }
            this.showSpinner = false;
            this.callParentCmp();
        })
        .catch(error => {
            console.log('Error received: code' + error.errorCode + ', ' +'message ' + error.body.message);
        });
    }

    getAdoptionRatesHandler() {
        this.adoptionRates = [];
        this.showSpinner = true;
        getAdoptionRates({ 
            recordId : this.recordId
        })
        .then(result => {
            if(result){
                this.adoptionRates = result;
            }
            this.showSpinner = false;
        })
        .catch(error => {
            console.log('Error received: code' + error.errorCode + ', ' +'message ' + error.body.message);
        });
    }

    getCustomerSentimentHandler() {
        this.customerSentiment = '';
        this.showSpinner = true;
        getCustomerSentiment({ 
            recordId : this.recordId
        })
        .then(result => {
            if(result){
                this.customerSentiment = result;
            }
            this.showSpinner = false;
        })
        .catch(error => {
            console.log('Error received: code' + error.errorCode + ', ' +'message ' + error.body.message);
        });
    }

    getTAMMeetingDetailsHandler() {
        this.tamMeetingName = '';
        this.tamMeetingURL = '';
        this.showSpinner = true;
        getTAMMeetingDetails({ 
            recordId : this.recordId
        })
        .then(result => {
            if(result){
                this.tamMeetingName = result.name;
                this.tamMeetingLink = '/'+result.id;
            }
            this.showSpinner = false;
        })
        .catch(error => {
            console.log('Error received: code' + error.errorCode + ', ' +'message ' + error.body.message);
        });
    }
    getOperationalContactsHandler() {
        this.showSpinner = true;
        getOprContacts({
            recordId : this.parentId,
        })
        .then(result => {
            if(result && result.length>0) {
                this.checklistStatusMap['MARK_ATLEAST_ONE_OPERATIONAL_CONTACT'] = true;
            }
            else {
                this.checklistStatusMap['MARK_ATLEAST_ONE_OPERATIONAL_CONTACT'] = false;
            }
            this.showSpinner = false;
            this.callParentCmp();
        })
        .catch(error => {
            console.log('Error received: code' + error.errorCode + ', ' +'message ' + error.body.message);
        });
    }
    callParentCmp() {
        let paramData = {
            checklistStatusMap : this.checklistStatusMap,
            stageChecklist : stageChecklistMap[this.tamEngagementStage]
        };
        let ev = new CustomEvent('childchecklist', {
            detail : paramData
        });
        this.dispatchEvent(ev); 
    }
}