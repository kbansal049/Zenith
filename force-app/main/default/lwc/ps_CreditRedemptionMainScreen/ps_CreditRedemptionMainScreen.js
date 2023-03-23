/*
    @Author : Harish Gowda N, Sachin Tandon
    @Requirement : PS Credit Process - CR# 4743,CR# 4744,CR# 4745
    @Created Date : 17/05/2022
    @Description : LWC Component for PS Credit Redemption Process.
    ***********************************************************************************************************
    MODIFICATION LOG
    * Version            Developer            Date            Jira Number          Description
    *---------------------------------------------------------------------------------------------------------
      1.0                Sachin Tandon        17/05/2022      CR#4745      PS Credits Redemption Process && PS Credits Redemption Validation.
      2.0                Harish Gowda N       17/05/2022      CR#4744      PS Credits Redemption Process && PS Credits Redemption Validation.
      3.0                Harish Gowda N       29/07/2022      IBA-1098     Allow CSM's to redeem PS credits for Training. 
	  4.0                Harish Gowda N       21/09/2022      IBA-2878     New PS Credits Offering - Attack Surface Discovery Report (CR# 5203). 
	  5.0                Harish Gowda N       06/10/2022      IBA-3300     New PS Credits Offering for redemption (CR# 5222).
	  ***********************************************************************************************************
*/
import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import getPSCredits from '@salesforce/apex/PS_PSRedemptionScreenController.getPSCredits';
import getPSOfferings from '@salesforce/apex/PS_PSRedemptionScreenController.getPSOfferings';
import getDevelopmentProjectRecordTypeId from '@salesforce/apex/PS_PSRedemptionScreenController.getDevelopmentProjectRecordTypeId';
import createPSCreditRedemptionrecord from '@salesforce/apex/PS_PSRedemptionScreenController.createPSCreditRedemptionrecord';
import PS_CREDIT_REDEMPTION_OBJECT from '@salesforce/schema/PS_Credit_Redemption__c';
import hasEarlyEngagementCustomerCredit from '@salesforce/customPermission/Early_Engagement_Customer_Credit'; //IBA-5448

import {
    getPicklistValuesByRecordType,
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
const DELAY = 300;
import {
    NavigationMixin
} from 'lightning/navigation';
import {
    refreshApex
} from '@salesforce/apex';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent'

export default class Ps_CreditRedemptionMainScreen extends NavigationMixin(LightningElement) {

    //Columns for the Avaliable Professional Services Credits Table.
    @track columns = [{
            label: 'Name',
            fieldName: 'PSCreditName'
        },
        {
            label: 'Opportunity',
            fieldName: 'opportunityName',

        },
        {
            label: 'Credits Expiration Date',
            fieldName: 'Credits_Expiration_Date__c',
            type: 'date',
            cellAttributes: {
                alignment: 'left'
            },
        },
        {
            label: 'Credits Purchased',
            fieldName: 'Credits_Purchased__c',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            }
        },
        {
            label: 'Credits Redeemed',
            fieldName: 'Credits_Redeemed__c',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            },
        },
        {
            label: 'Credits Remaining',
            fieldName: 'Credits_Remaining__c',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            },
        }
    ];

    //Columns for the Professional Services Offerings Table.
    @track psOfferingColumns = [{
            label: 'Offering',
            fieldName: 'Name',
            type: 'text'
        },
        {
            label: 'Details',
            fieldName: 'Offering_Details__c',
            type: 'text',
            wrapText: true
        },
        {
            label: 'Credits Required',
            fieldName: 'Credits__c',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            }
        },
        {
            label: 'Units Required',
            fieldName: 'Units',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            },
            typeAttributes: {
                step: '1',
                maximumFractionDigits: '0',
                minimumFractionDigits: '0',
                min: 0
            },
            editable: true
        },
        {
            label: 'Suggested Max',
            fieldName: 'Suggested_Max__c',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            }
        },
        {
            label: 'Credits Redeemed',
            fieldName: 'CreditsRequired',
            type: 'number',
            cellAttributes: {
                alignment: 'left'
            }
        }
    ];

    @api recId;
    @track error;
    @track psOfferingsList = [];
    @track trainingOfferingsList = [];
    draftValues = [];
    offeringByOfferingId = new Map();
    trainingOfferingByOfferingId = new Map();
    offeringByOfferingIdModal = new Map();
    trainingOfferingByOfferingIdModal = new Map();
    attackSurfaceOfferingByOfferingIdModal = new Map();
    offeringUnitByOfferingId = new Map();
    trainingOfferingUnitByOfferingId = new Map();
    @track psOfferingsListOriginalCopy = [];
    @track attackSurfaceOfferingsListOriginalCopy = [];
    @track trainingOfferingsListOriginalCopy = [];
    accountName;
    @track totalCreditsRedeemed = 0;
    offeringByOfferingIdCopy = new Map();
    trainingOfferingByOfferingIdCopy = new Map();
    @track psCreditsList = [];
    @track totalAvailableCredits = 0;
    
    //IBA-6609 Start
    totalAvailablePSCredits = 0;
    totalAvailableEECredits = 0;
    @track userPreferredCreditType = 'PSCredit';
    shouldDisplayPSCreditTable = true;
    shouldDisplayEEComponent = false;
    //IBA-6609 END
    
    isLoading = false;
    @api isModalOpen = false;
    psCreditRedemptionList = [];
    devProjectRecordTypeId;
    @track requestedTimeZones;
    showPSCreditTable = false;
    showModalPSofferingtable = false;
    showModalTrainingofferingtable = false;
    @track modalValuesByofferingId = new Map();
    showAttackSurfaceDiscoveryReport = false;

    @track earlyEngagementCustomerCredits = [];
    //To constrol visibility of Customer Credits
    hasEEPermision = false;
    shouldDisplayEECreditsTable = false;
    displayCreditPicklistModal = false;

    //Start : Generic Search Component variables
    delayTimeout;
    objName = 'Contact';
    fields = ['Name'];
    displayFields = 'Name,FirstName,LastName';
    iconName = 'standard:contact';
    isLoading = false;
    ICON_URL = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';
    //END Generic Search Component variables

    PS_REDEMPTION_SCREEN_LBL = 'PS Redemption Screen';
    NO_PS_CREDITS_FOUND_MSG = 'No Active Professional Services Credits found for the Account';
    NO_EE_CREDITS_FOUND_MSG = 'No Active Early Engagement Credits found for the Account';
    TOTAL_AVAILABLE_CREDITS_LBL = 'Total Available Credits =';
    TOTAL_CREDITS_REDEEMED_LBL = 'Total Credits Redeemed =';

    connectedCallback() {
        this.loadRecords();
        this.shouldDisplayCreditPicklistModal();
    }

    @wire(getDevelopmentProjectRecordTypeId)
    developmentProjectRecordTypeId({
        error,
        data
    }) {
        if (data) {
            this.devProjectRecordTypeId = JSON.parse(JSON.stringify(data));

        } else if (error) {
            ;
            var result = JSON.parse(JSON.stringify(error));
        }
    };

    @wire(getPicklistValuesByRecordType, {
        objectApiName: PS_CREDIT_REDEMPTION_OBJECT,
        recordTypeId: '$devProjectRecordTypeId'
    })
    timeZonePicklistValues({
        data,
        error
    }) {
        if (data) {
            this.requestedTimeZones = data.picklistFieldValues.Project_Requester_Time_Zone__c.values;
        } else if (error) {
            var result = JSON.parse(JSON.stringify(error));
        }
    };

    // Uitility method for Toast Message.
    showToastMessage(title, messageBody, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: messageBody,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    loadRecords() {
        this.totalCreditsRedeemed = 0;
        this.isLoading = true;
        this.hasEEPermision = this.isEligibleForEarlyEngagement() === undefined ? false : true;

        getPSCredits({
                accountId: this.recId
            }).then(result => {
                if (result !== null && result !== undefined) {
                    this.psCreditsList = [];
                    this.totalAvailableCredits = 0;
                    this.totalAvailablePSCredits = 0;
                    this.totalAvailableEECredits = 0;
                    this.earlyEngagementCustomerCredits = [];

                    result.forEach((row) => {
                        let rowData = {};
                        rowData.Id = row.psCreditId;
                        rowData.PSCreditName = row.psCreditName;
                        rowData.opportunityName = row.opportunityName;
                        rowData.Credits_Purchased__c = row.creditsPurchased;
                        rowData.Credits_Expiration_Date__c = row.creditsExpirationDate;
                        rowData.Credits_Redeemed__c = row.creditsRedeemed;
                        rowData.Credits_Remaining__c = row.creditsRemaining;

                        if(row.isEarlyEngagementCredit) {
                            this.earlyEngagementCustomerCredits.push(rowData);
                            this.totalAvailableEECredits = this.totalAvailableEECredits + row.creditsRemaining;
                        }else {
                            this.psCreditsList.push(rowData);
                            this.totalAvailablePSCredits = this.totalAvailablePSCredits + row.creditsRemaining;
                        }
                        this.totalAvailableCredits = this.totalAvailableCredits + row.creditsRemaining;
                        this.accountName = row.accountName;
                    });

                    if (this.psCreditsList.length > 0) {
                        this.psCreditsList = [...this.psCreditsList];
                        this.showPSCreditTable = true;
                    }

                    if (this.earlyEngagementCustomerCredits.length > 0) {
                        this.shouldDisplayEECreditsTable = true;
                        this.earlyEngagementCustomerCredits = [...this.earlyEngagementCustomerCredits];
                    }
                    
                    this.updateTotalAvailableCredits();
                    this.isLoading = false;

                } else if (result === null || result === undefined) {
                    this.psCreditsList = [];
                    this.totalAvailableCredits = 0;
                    this.earlyEngagementCustomerCredits = [];
                    this.isLoading = false;
                    this.showPSCreditTable = false;
                    this.shouldDisplayEECreditsTable = false;
                }
            })
            .catch(error => {
                this.showToastMessage('Error While Loading PS Credit Records', JSON.stringify(error.body.message), 'error');
                //this.psCreditsList = null;
                this.earlyEngagementCustomerCredits = null;
                this.isLoading = false;
            });

        getPSOfferings({}).then(result => {
                if (result !== null && result !== undefined) {
                    this.psOfferingsList = [];
                    this.trainingOfferingsList = [];

                    result.forEach((row) => {

                        let offeringRowData = {};
                        let trainingOfferingRowData = {};

                        if (row.RecordType.Name === 'Professional Service Offerings') {
                            offeringRowData.Id = row.Id;
                            offeringRowData.Name = row.Name;
                            offeringRowData.Offering_Details__c = row.Offering_Details__c;
                            offeringRowData.Credits__c = row.Credits__c;
                            offeringRowData.Suggested_Max__c = row.Suggested_Max__c;
                            offeringRowData.Units = 0;
                            offeringRowData.RecordTypeId = row.RecordTypeId;
                            offeringRowData.recordTypeName = row.RecordType.Name;
                            offeringRowData.CreditsRequired = 0;

                            this.psOfferingsList.push(offeringRowData);
                            this.offeringByOfferingId.set(offeringRowData.Id, offeringRowData);
                            this.offeringByOfferingIdCopy.set(offeringRowData.Id, offeringRowData);
                        } else if (row.RecordType.Name === 'Training Offerings') {
                            trainingOfferingRowData.Id = row.Id;
                            trainingOfferingRowData.Name = row.Name;
                            trainingOfferingRowData.Offering_Details__c = row.Offering_Details__c;
                            trainingOfferingRowData.Credits__c = row.Credits__c;
                            trainingOfferingRowData.Suggested_Max__c = row.Suggested_Max__c;
                            trainingOfferingRowData.Units = 0;
                            trainingOfferingRowData.CreditsRequired = 0;
                            trainingOfferingRowData.RecordTypeId = row.RecordTypeId;
                            trainingOfferingRowData.recordTypeName = row.RecordType.Name;

                            this.trainingOfferingsList.push(trainingOfferingRowData);
                            this.trainingOfferingByOfferingId.set(trainingOfferingRowData.Id, trainingOfferingRowData);
                            this.trainingOfferingByOfferingIdCopy.set(trainingOfferingRowData.Id, trainingOfferingRowData);
                        }
                    });

                    if (this.psOfferingsList.length > 0) {
                        this.psOfferingsList = [...this.psOfferingsList];
                    }

                    if (this.trainingOfferingsList.length > 0) {
                        this.trainingOfferingsList = [...this.trainingOfferingsList];
                    }

                }
                this.isLoading = false;
            })
            .catch(error => {
                this.showToastMessage('Error While Loading PS Offering Records', JSON.stringify(error.body.message), 'error');
                this.isLoading = false;
            });
    }

    goBackToAccount() {
        if(this.hasEEPermision) {
            this.displayCreditPicklistModal = true;
        }
        this.isLoading = true;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
        this.resetOfferingTableToOriginalData();
        this.isLoading = false;
    }

    handleSave(event) {
        this.isLoading = true;
        if (this.totalCreditsRedeemed == 0) {
            this.showToastMessage('Error', 'Credit Units must be entered to proceed', 'error');
            this.isLoading = false;
        } else if (this.totalCreditsRedeemed > this.totalAvailableCredits) {
            this.showToastMessage('Error', 'Insufficient Credits. Please review available credits and revise your redemption.', 'error');
            this.isLoading = false;
        } else {
            this.isModalOpen = true;
        }
    }

    submitDetails() {
        if (this.validateData()) {
            let userSelectedoption = this.userPreferredCreditType;
            this.createPsCreditredemptionRecords();
            this.isModalOpen = false;
            this.userPreferredCreditType = userSelectedoption;
            this.submitCreditType();
        }
    }

    //IBA-6609 : Start
    updateTotalAvailableCredits() {
        if(this.hasEEPermision) {
            if(this.userPreferredCreditType == 'EECredit') {
                this.totalAvailableCredits = this.totalAvailableEECredits;
            }else if(this.userPreferredCreditType == 'PSCredit') {
                this.totalAvailableCredits = this.totalAvailablePSCredits;
            }
        }
    }

    shouldDisplayCreditPicklistModal() {
        if(this.hasEEPermision) {
            this.displayCreditPicklistModal = true; 
        }
    }

    handlePicklistChange(event) {
        const selectedOption = event.detail.value;
        this.userPreferredCreditType = selectedOption;
    }

    submitCreditType() {
        if(this.userPreferredCreditType == 'EECredit') {
            this.shouldDisplayEEComponent = true;
            this.shouldDisplayPSCreditTable = false;
            this.totalAvailableCredits = this.totalAvailableEECredits;
        }else {
            this.shouldDisplayPSCreditTable = true;
            this.totalAvailableCredits = this.totalAvailablePSCredits;
            this.shouldDisplayEEComponent = false;
        }
        this.closeCustomerCreditPicklistModal();       
    }

    displayCustomerCreditModal() {
        this.resetOfferingTableToOriginalData();
        this.displayCreditPicklistModal = true;
    }

    closeCustomerCreditPicklistModal(){
        this.displayCreditPicklistModal = false;
    }

    get customerCreditOptions() {
        return [
            { label: 'Early Engagement Credits('+this.totalAvailableEECredits+')', value: 'EECredit' },
            { label: 'Professional Service Credits('+this.totalAvailablePSCredits+')', value: 'PSCredit' },
        ];
    }

    //IBA-6609 : END

    createPsCreditredemptionRecords() {
        this.isLoading = true;
        var mapToSend = {};
        let modalValues = {};

        for (var key of this.offeringUnitByOfferingId.keys()) {
            mapToSend[key] = this.offeringUnitByOfferingId.get(key);
        }
        // To add Training Offering unit values to the Offering and Units Map.
        for (var key of this.trainingOfferingUnitByOfferingId.keys()) {
            mapToSend[key] = this.trainingOfferingUnitByOfferingId.get(key);
        }

        for (var key of this.offeringByOfferingIdModal.keys()) {
            modalValues[key] = this.offeringByOfferingIdModal.get(key);
        }

        for (var key of this.trainingOfferingByOfferingIdModal.keys()) {
            modalValues[key] = this.trainingOfferingByOfferingIdModal.get(key);
        }

        for (var key of this.attackSurfaceOfferingByOfferingIdModal.keys()) {
            modalValues[key] = this.attackSurfaceOfferingByOfferingIdModal.get(key);
        }

        createPSCreditRedemptionrecord({
                accountId: this.recId,
                accountName: this.accountName,
                totalCreditsRequired: this.totalCreditsRedeemed,
                psOfferingIdUnitsmap: mapToSend,
                psOfferingByOfferingId: modalValues,
                shouldRedeemEECredit : this.shouldDisplayEEComponent
            }).then(result => {
                if (result !== null && result !== undefined) {
                    this.psCreditRedemptionList = result;

                    if (this.psCreditRedemptionList[0] === 'Success') {
                        this.showToastMessage('Success', 'You have successfully redeemed credits.', 'success');
                        refreshApex(this.psCreditsList);
                        refreshApex(this.psOfferingsList);
                        refreshApex(this.earlyEngagementCustomerCredits);
                        this.resetOfferingTableToOriginalData();
                        this.isLoading = false;
                    }
                }
            })
            .catch(error => {
                this.showToastMessage('Error During PS Credit Redemption Process', JSON.stringify(error.body.message), 'error');
                this.psCreditsList = null;
                this.earlyEngagementCustomerCredits = null;
                this.isLoading = false;
            });
    }

    /**
     * 
     * offeringByOfferingId - This map is used to display values in PS Offering Table.
     * It is updated when the component is loaded with all the Ps Offerings
     * When the user updates the units required the map is updated to display user changes on PS Offering Table. 
     * 
     * offeringUnitByOfferingId - Is used retain the map of Offering Vs Units redeemed. It is used in Modal further
     * and later send to Controller.
     */
    hanldeCellChange(event) {
        let updatedOffering = event.detail.draftValues;
        updatedOffering.forEach((newOffering) => {
            let offering = this.offeringByOfferingId.get(newOffering.Id);
            offering.Id = newOffering.Id;
            offering.name = newOffering.name;
            let units = newOffering.Units !== "" ? newOffering.Units : 0;
            offering.Units = Math.round(Math.abs(units));
            newOffering.Units = offering.Units;
            offering.CreditsRequired = offering.Credits__c * offering.Units;
            offering.filterClause = 'where Account.Id = \'' + this.recId + '\'';
            offering.RequesterTimeZone = null;
            offering.DeploymentStartDate = null;
            offering.contact = null;
            offering.notes = null;
            offering.RecordTypeId = offering.RecordTypeId;
            newOffering.recordTypeName = offering.recordTypeName;
            newOffering.Name = offering.Name;
            this.offeringByOfferingId.set(newOffering.Id, offering);
            this.offeringUnitByOfferingId.set(newOffering.Id, offering.Units);

            //Add offering to Modal Table To load the modal only when the units are not equal to 0
            if (newOffering.Units !== "" && newOffering.Units !== 0 && newOffering.recordTypeName === 'Professional Service Offerings' && newOffering.Name !== 'Attack Surface Discovery Report') {
                this.offeringByOfferingIdModal.set(newOffering.Id, offering);
            } else {
                this.offeringByOfferingIdModal.delete(newOffering.Id);
            }
            //IBA - 2878 Changes - to add the new attack service offering and show that without project values.
            if (newOffering.Units !== "" && newOffering.Units !== 0 && newOffering.recordTypeName === 'Professional Service Offerings' && newOffering.Name === 'Attack Surface Discovery Report') {
                this.attackSurfaceOfferingByOfferingIdModal.set(newOffering.Id, offering);
            } else {
                this.attackSurfaceOfferingByOfferingIdModal.delete(newOffering.Id);
            }

            if (newOffering.Units === "" && newOffering.Units === 0) {
                this.offeringUnitByOfferingId.delete(newOffering.Id);
            }

        });

        //Updating Offering List with Updated Value to be shown to user on PS Credit Redemption Screen-PS Offering Table
        this.psOfferingsList = [...this.offeringByOfferingId.values()];

        //Updating Offering List with Updated Value to be shown to user on PS Credit Redemption Screen-PS Offering Table
        if (this.offeringByOfferingIdModal.size > 0) {
            this.psOfferingsListOriginalCopy = [...this.offeringByOfferingIdModal.values()];
            this.showModalPSofferingtable = true;
        } else {
            this.showModalPSofferingtable = false;
        }

        //IBA - 2878 Changes - to add the new attack service offering and show that without project values.
        if (this.attackSurfaceOfferingByOfferingIdModal.size > 0) {
            this.attackSurfaceOfferingsListOriginalCopy = [...this.attackSurfaceOfferingByOfferingIdModal.values()];
            this.showAttackSurfaceDiscoveryReport = true;
            this.showModalPSofferingtable = true;
        } else {
            this.showAttackSurfaceDiscoveryReport = false;
        }

        //Update draft values:
        this.updateOfferingTableDraftValues();
        this.calculateTotalCreditsRedemmed();
    }

    hanldeTrainingCellChange(event) {
        let trainingUpdatedOffering = event.detail.draftValues;
        trainingUpdatedOffering.forEach((trainingNewOffering) => {
            let trainingOffering = this.trainingOfferingByOfferingId.get(trainingNewOffering.Id);
            trainingOffering.Id = trainingNewOffering.Id;
            trainingOffering.name = trainingNewOffering.name;
            let units = trainingNewOffering.Units !== "" ? trainingNewOffering.Units : 0;
            trainingOffering.Units = Math.round(Math.abs(units));
            trainingNewOffering.Units = trainingOffering.Units;
            trainingOffering.CreditsRequired = trainingOffering.Credits__c * trainingOffering.Units;
            trainingOffering.filterClause = 'where Account.Id = \'' + this.recId + '\'';
            trainingOffering.RequesterTimeZone = null;
            trainingOffering.DeploymentStartDate = null;
            trainingOffering.notes = null;
            trainingOffering.contact = null;
            trainingOffering.RecordTypeId = trainingOffering.RecordTypeId;
            trainingNewOffering.recordTypeName = trainingOffering.recordTypeName;
            this.trainingOfferingByOfferingId.set(trainingNewOffering.Id, trainingOffering);
            this.trainingOfferingUnitByOfferingId.set(trainingNewOffering.Id, trainingOffering.Units);

            //Add Training offering to Modal Table To load the modal only when the units are not equal to 0
            if (trainingNewOffering.Units !== "" && trainingNewOffering.Units !== 0 && trainingNewOffering.recordTypeName === 'Training Offerings') {
                this.trainingOfferingByOfferingIdModal.set(trainingNewOffering.Id, trainingOffering);
            } else {
                this.trainingOfferingUnitByOfferingId.delete(trainingNewOffering.Id);
                this.trainingOfferingByOfferingIdModal.delete(trainingNewOffering.Id);
            }
        });

        //Updating Offering List with Updated Value to be shown to user on PS Credit Redemption Screen-PS Offering Table
        this.trainingOfferingsList = [...this.trainingOfferingByOfferingId.values()];

        //Updating Offering List with Updated Value to be shown to user on PS Credit Redemption Screen-PS Offering Table
        if (this.trainingOfferingByOfferingIdModal.size > 0) {
            this.trainingOfferingsListOriginalCopy = [...this.trainingOfferingByOfferingIdModal.values()];
            this.showModalTrainingofferingtable = true;
        } else {
            this.showModalTrainingofferingtable = false;
        }

        //Update draft values:
        this.updateTrainingOfferingTableDraftValues();
        this.calculateTotalCreditsRedemmed();
    }


    calculateTotalCreditsRedemmed() {
        let creditsRedeemed = 0;
        this.offeringByOfferingId.forEach(function(key, val) {
            let offering = key;
            creditsRedeemed = creditsRedeemed + offering.CreditsRequired;
        });

        this.trainingOfferingByOfferingId.forEach(function(key, val) {
            let trainingOffering = key;
            creditsRedeemed = creditsRedeemed + trainingOffering.CreditsRequired;
        });

        this.totalCreditsRedeemed = creditsRedeemed;
    }

    /**
     * This function rounds off any decimal value and removes negative number and takes positive integers.
     */
    updateOfferingTableDraftValues() {

        let psOfferingDraftValues = this.template.querySelector('[data-id="psOfferingTable"]').draftValues;
        Object.keys(psOfferingDraftValues).forEach(key => {
            let rows = psOfferingDraftValues[key];
            let rowNumber = key;
            Object.keys(rows).forEach(key => {
                if (key === 'Units' || key === 'units') {
                    psOfferingDraftValues[rowNumber]['Units'] = Math.round(Math.abs(rows[key]));
                }
            });
        });
        this.template.querySelector('[data-id="psOfferingTable"]').draftValues = psOfferingDraftValues;
    }

    /**
     * This function rounds off any decimal value and removes negative number and takes positive integers.
     */
    updateTrainingOfferingTableDraftValues() {

        let trainingOfferingDraftValues = this.template.querySelector('[data-id="trainingOfferingTable"]').draftValues;
        Object.keys(trainingOfferingDraftValues).forEach(key => {
            let rows = trainingOfferingDraftValues[key];
            let rowNumber = key;
            Object.keys(rows).forEach(key => {
                if (key === 'Units' || key === 'units') {
                    trainingOfferingDraftValues[rowNumber]['Units'] = Math.round(Math.abs(rows[key]));
                }
            });
        });
        this.template.querySelector('[data-id="trainingOfferingTable"]').draftValues = trainingOfferingDraftValues;
    }

    handleCancel(event) {
        try {
            this.isLoading = false;
            let userSelectedoption = this.userPreferredCreditType;
            this.resetOfferingTableToOriginalData();
            this.userPreferredCreditType = userSelectedoption;
            this.submitCreditType();
        } catch (error) {
            this.showToastMessage('Error during cancel process', JSON.stringify(error.body.message), 'error');
        }
    }

    resetOfferingTableToOriginalData() {
        this.totalCreditsRedeemed = 0;
        this.psOfferingsList = [...this.offeringByOfferingIdCopy.values()];
        this.trainingOfferingsList = [...this.trainingOfferingByOfferingIdCopy.values()];
        this.offeringByOfferingId = new Map(this.offeringByOfferingIdCopy);
        this.trainingOfferingByOfferingId = new Map(this.trainingOfferingByOfferingIdCopy);
        this.offeringUnitByOfferingId = new Map();
        this.trainingOfferingUnitByOfferingId = new Map();
        this.offeringByOfferingIdModal = new Map();
        this.trainingOfferingByOfferingIdModal = new Map();
        this.attackSurfaceOfferingByOfferingIdModal = new Map();
        this.offeringByOfferingIdModal.clear();
        this.trainingOfferingByOfferingIdModal.clear();
        this.attackSurfaceOfferingByOfferingIdModal.clear();
        this.template.querySelector('[data-id="psOfferingTable"]').draftValues = [];
        this.template.querySelector('[data-id="trainingOfferingTable"]').draftValues = [];
        //Updating Offering List with Updated Value to be shown to user on PS Credit Redemption Screen-PS Offering Table
        this.psOfferingsListOriginalCopy = [...this.offeringByOfferingIdModal.values()];
        this.showModalPSofferingtable = false;
        this.attackSurfaceOfferingsListOriginalCopy = [...this.attackSurfaceOfferingByOfferingIdModal.values()];
        this.showAttackSurfaceDiscoveryReport = false;
        this.trainingOfferingsListOriginalCopy = [...this.trainingOfferingByOfferingIdModal.values()];
        this.showModalTrainingofferingtable = false;
        this.loadRecords();
    }

    closeModal() {
        this.isModalOpen = false;
        this.isLoading = false;
        //Reset all the values that are inserted in 
        this.resetModalValues();

    }

    handleLookup(event) {
        if (event.detail.data && event.detail.data.sourceId != undefined) {
            if (this.offeringByOfferingIdModal !== null && this.offeringByOfferingIdModal.size > 0 && this.offeringByOfferingIdModal.has(event.detail.data.sourceId)) {
                let existingOffering = this.offeringByOfferingIdModal.get(event.detail.data.sourceId);
                if (event.detail.data.recordId) {
                    existingOffering.contact = event.detail.data.recordId;
                    this.offeringByOfferingIdModal.set(existingOffering.Id, existingOffering);
                } else {
                    existingOffering.contact = null;
                    this.offeringByOfferingIdModal.set(existingOffering.Id, existingOffering);
                }
            }
        }
    }

    handleDate(event) {
        if (this.offeringByOfferingIdModal !== null && this.offeringByOfferingIdModal.size > 0 && this.offeringByOfferingIdModal.has(event.target.dataset.id)) {
            let existingOffering = this.offeringByOfferingIdModal.get(event.target.dataset.id);
            if (event.detail.value !== null) {
                existingOffering.DeploymentStartDate = event.detail.value;
                this.offeringByOfferingIdModal.set(existingOffering.Id, existingOffering);
            } else {
                existingOffering.DeploymentStartDate = null;
                this.offeringByOfferingIdModal.set(existingOffering.Id, existingOffering);
            }
        }
    }

    handleTimeZoneChange(event) {
        if (this.offeringByOfferingIdModal !== null && this.offeringByOfferingIdModal.size > 0 && this.offeringByOfferingIdModal.has(event.target.dataset.id)) {
            let existingOffering = this.offeringByOfferingIdModal.get(event.target.dataset.id);
            if (event.detail.value !== null) {
                existingOffering.RequesterTimeZone = event.detail.value;
                this.offeringByOfferingIdModal.set(existingOffering.Id, existingOffering);
            }
        }
    }

    handleNotes(event) {
        if (event.detail.data && event.detail.data.currentRecordId != undefined) {
            if (this.offeringByOfferingIdModal !== null && this.offeringByOfferingIdModal.size > 0 && this.offeringByOfferingIdModal.has(event.detail.data.currentRecordId)) {
                let existingOffering = this.offeringByOfferingIdModal.get(event.detail.data.currentRecordId);
                if (event.detail.data.notesValue) {
                    existingOffering.notes = event.detail.data.notesValue;
                    this.offeringByOfferingIdModal.set(existingOffering.Id, existingOffering);
					this.showToastMessage('Success', 'Notes has been successfully added', 'success');
                } else {
                    existingOffering.notes = null;
                    this.offeringByOfferingIdModal.set(existingOffering.Id, existingOffering);
                }
            }
        }
    }

    resetModalValues() {
        for (const key of this.offeringByOfferingIdModal.keys()) {
            let resetOffering = this.offeringByOfferingIdModal.get(key);
            resetOffering.RequesterTimeZone = null;
            resetOffering.DeploymentStartDate = null;
            resetOffering.contact = null;
            resetOffering.notes = null;
            this.offeringByOfferingIdModal.set(resetOffering.Id, resetOffering);
        }
    }

    validateData() {
        let isError = false;
        let erorMsg = 'Please input values in fields: ';
        for (const key of this.offeringByOfferingIdModal.keys()) {
            let offering = this.offeringByOfferingIdModal.get(key);

            if (!(offering.hasOwnProperty('RequesterTimeZone')) || offering.RequesterTimeZone === null) {
                erorMsg = erorMsg + offering.Name + ' Requester Time Zone ';
                isError = true;
            }

            if (!(offering.hasOwnProperty('DeploymentStartDate')) || offering.DeploymentStartDate === null) {
                erorMsg = erorMsg + offering.Name + ' Deployment Start Date ';
                isError = true;
            }

            if (!(offering.hasOwnProperty('contact')) || offering.contact === null) {
                erorMsg = erorMsg + offering.Name + ' Cutomer Contact ';
                isError = true;
            }
        }

        if (isError) {
            this.showToastMessage('Error While Saving the record', erorMsg, 'error');
            this.isLoading = false;
        }

        return !isError;
    }

    disconnectedCallback() {
        this.recId = '';
    }

    isEligibleForEarlyEngagement() {
        return hasEarlyEngagementCustomerCredit;
    }

}