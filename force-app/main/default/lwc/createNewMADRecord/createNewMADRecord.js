import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import MAD_OBJECT from '@salesforce/schema/M_A_D_Details__c';
import { NavigationMixin } from 'lightning/navigation';
import fetchFieldCustomMetadata from '@salesforce/apex/createNewMADRecordController.fetchFieldCustomMetadata';
import fetchAccountRelatedToOpp from '@salesforce/apex/createNewMADRecordController.fetchAccountRelatedToOpp';

export default class CreateNewMADRecord extends NavigationMixin(LightningElement) {

    @api recordId;
    objectApiName = MAD_OBJECT;
    opportunityId;
    showSpinner = false;
    isModalOpen = false;
    accountData;
    error;
    showMAPartnersOther = false;

    @track fieldAPINameList = [];
    @track opportunityRecord;
    @track isSSOAccount = false;

    @wire(fetchFieldCustomMetadata)
    wiredRecs(value) {
        this.wiredRecords = value;
        const { data, error } = value;
        if (data) {
            this.fieldAPINameList = data;
            //console.log('fieldAPINameList - ' + JSON.stringify(this.fieldAPINameList));
            this.error = undefined;
        } else if (error) {
            console.error(error);
            this.error = error;
            this.fieldAPINameList = undefined;
        }
    }

    connectedCallback() {
        try {
            this.isModalOpen = true;
            const params = new Proxy(new URLSearchParams(window.location.search), {
                get: (searchParams, prop) => searchParams.get(prop)
            });
            let inContextOfRef = params.inContextOfRef;
            if (inContextOfRef.startsWith("1\.")) { inContextOfRef = inContextOfRef.substring(2); }
            var addressableContext = JSON.parse(window.atob(inContextOfRef));
            this.opportunityId = addressableContext.attributes.recordId;
            this.getAccountRecord();// Get the related Account Details from Opportunity record
        } catch (error) {
            console.error(error);
        }
    }

    async getAccountRecord() {
        try {
            if (this.opportunityId) {
                this.opportunityRecord = await fetchAccountRelatedToOpp({ opportunityId: this.opportunityId });
                //console.log('opportunityRecord - ' + JSON.stringify(this.opportunityRecord));
                if(this.opportunityRecord && this.opportunityRecord.Account &&
                    this.opportunityRecord.Account.Name &&
                    this.opportunityRecord.Account.Name.toUpperCase().includes('SSO') ){
                    this.isSSOAccount = true;
                }else {
                    this.isSSOAccount = false;
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleLoad(event) {
        //console.log('record - ' + JSON.stringify(event.detail.record));
        if (this.template.querySelector('[data-id="Name"]')) {
            this.template.querySelector('[data-id="Name"]').required = true;
        }
        if (this.opportunityId && this.template.querySelector('[data-id="Opportunity__c"]')) {
            this.template.querySelector('[data-id="Opportunity__c"]').value = this.opportunityId;
        }
        if (this.template.querySelector('[data-id="M_A_Partners_Involved_Others__c"]') &&
            !event.detail.record.fields.M_A_Partners_Involved__c.value) {
            this.template.querySelector('[data-id="M_A_Partners_Involved_Others__c"]').classList.add('slds-hide');
        }
        if (this.isSSOAccount &&
            this.template.querySelector('[data-id="Probability__c"]') &&
            !event.detail.record.fields.Confidential__c.value) {
            this.template.querySelector('[data-id="Probability__c"]').disabled = true;
        }
        //Default 'Confidence Level' to 'Lead' for non-sso accounts 
        if (!this.isSSOAccount && this.template.querySelector('[data-id="Probability__c"]')) {
            this.template.querySelector('[data-id="Probability__c"]').value = 'Lead';
        }
    }

    handleFieldChange(event) {
        try {
            if (event.target.fieldName === 'M_A_Partners_Involved__c' &&
                this.template.querySelector('[data-id="M_A_Partners_Involved_Others__c"]')) {
                if (event.target.value && event.target.value.includes('Others')) {
                    this.template.querySelector('[data-id="M_A_Partners_Involved_Others__c"]').classList.remove('slds-hide');
                } else if (event.target.value && !event.target.value.includes('Others')) {
                    this.template.querySelector('[data-id="M_A_Partners_Involved_Others__c"]').classList.add('slds-hide');
                } else {
                    this.template.querySelector('[data-id="M_A_Partners_Involved_Others__c"]').classList.add('slds-hide');
                }
            }

            if (event.target.fieldName === 'Probability__c' && event.target.value &&
                this.template.querySelector('[data-id="Stage__c"]')) {

                if ((event.target.value === 'Lead' || event.target.value === 'Target')) {
                    this.template.querySelector('[data-id="Stage__c"]').value = 'Lead level 0: No Action/ Interaction started';
                } else if ((event.target.value === 'Low' ||
                    event.target.value === 'High' ||
                    event.target.value === 'Closing' ||
                    event.target.value === 'Won' ||
                    event.target.value === 'Paused')) {
                    this.template.querySelector('[data-id="Stage__c"]').value = 'Level 1: M&A/D First Meeting Deck technical contact (RSM, SE)';
                } else if ((event.target.value === 'Lost' || event.target.value === 'Withdrawn')) {
                    this.template.querySelector('[data-id="Stage__c"]').value = 'Lead level 0: No Action/ Interaction started';
                }

            }

            if (event.target.fieldName === 'Confidential__c') {
                if(this.isSSOAccount){ // SSO Account
                    if (!event.target.value) {
                        this.template.querySelector('[data-id="Probability__c"]').disabled = true;
                    } else {
                        this.template.querySelector('[data-id="Probability__c"]').disabled = false;
                    }
                }
                if(!this.isSSOAccount){ // Non-SSO Account

                }
                
            }

            if (event.target.fieldName === 'Engaged_with_M_A_Partner__c' &&
                this.template.querySelector('[data-id="Partner_Engagement_Stage__c"]')) {
                if (event.target.value && event.target.value.includes('No')) {
                    this.template.querySelector('[data-id="Partner_Engagement_Stage__c"]').value = 'N/A';
                } else {
                    this.template.querySelector('[data-id="Partner_Engagement_Stage__c"]').value = '';
                }
            }

        } catch (error) {
            console.error(error);
        }
    }

    handleSubmit(event) {
        try {
            this.validateFields();
            this.showSpinner = true;
            event.preventDefault();       // stop the form from submitting
            const fields = event.detail.fields;
            fields.Account__c = this.opportunityRecord.AccountId;
            fields.Region__c = this.opportunityRecord.Account.Area__c;
            fields.Industry__c = this.opportunityRecord.Account.Industry;
            fields.Account_Type__c = this.opportunityRecord.Account.Type;
            fields.Market_Segment__c = this.opportunityRecord.Account.Market_Segment__c;
            fields.Account_Owner__c = this.opportunityRecord.Account.OwnerId;
            fields.Fortune_Global_500__c = this.opportunityRecord.Account.Fortune_500__c;
            fields.G2K_Rank__c = this.opportunityRecord.Account.Global_2000_Rank__c;
            //console.log('fields BEFORE SUBMIT - ' + JSON.stringify(fields));
            this.template.querySelector('lightning-record-edit-form').submit(fields); // Submits the form
        } catch (error) {
            console.error(error);
        }
    }

    closeModal(event) {
        this.isModalOpen = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.opportunityId,
                objectApiName: 'Opportunity',
                relationshipApiName: 'M_A_D_Details__r',
                actionName: 'view'
            },
        });
    }

    validateFields(event) {

        return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            return (validSoFar && field.reportValidity());
        }, true);
    }

    handleSuccess(event) {
        this.showSpinner = false;
        this.isModalOpen = false;
        this.error = undefined;
        //console.log('On Success' + JSON.stringify(event.detail));
        this.showToast('Success!!', 'success', 'New M, A&D Record Created Successfully!');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.detail.id,
                objectApiName: 'M_A_D_Details__c',
                actionName: 'view'
            },
        });
    }

    handleError(event) {
        this.showSpinner = false;
        console.error('On Error' + JSON.stringify(event.detail));
        this.template.querySelector('[data-id="message"]').setError(event.detail.detail);
        this.template.querySelector('.slds-modal__content').scrollTop = 0;
    }

    showToast(title, variant, msg) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: msg
        });
        this.dispatchEvent(event);
    }

}