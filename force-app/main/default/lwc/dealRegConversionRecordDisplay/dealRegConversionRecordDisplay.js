/*
 * @description       : 
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0     -            -           Initial Version
 * 2.0  7/26/2022     Swathi        IBA - 1599
 */
import { LightningElement, api, track } from 'lwc';
import techPartner from '@salesforce/label/c.Partner_Type_Tech_Partner';
import { NavigationMixin } from 'lightning/navigation';
import reseller from '@salesforce/label/c.Partner_Type_Reseller';
import convertDRtoOpp from '@salesforce/apex/DealRegConversionLWCHelper.convertDRtoOpportunity';
//Changes of IBA - 1599 - Start
import uploadFiles from '@salesforce/apex/DealRegConversionLWCHelper.uploadFiles';
import oppStageSponsorship from '@salesforce/label/c.Stage_3_Value_Impact_Validation';
import oppStageImpactVal from '@salesforce/label/c.Stage_4_Economic_Buyer_Signoff';
import dealTypeSourced from '@salesforce/label/c.Deal_Reg_Type_Sourced';
import dealTypeTeaming from '@salesforce/label/c.Deal_Reg_Type_Teaming';
import RenewalOpportunity from '@salesforce/label/c.Renewal_Opportunity';
//Changes of IBA - 1599 - End

export default class DealRegConversionRecordDisplay_LWC extends NavigationMixin(LightningElement) {
    @api record;
    @api dealRegrecord;
    @api conditionSet;
    @track showModal = false;
    @track loading = false;
    showSourced;
    showTeaming;
    showTeamingReseller;
    showTeamingTech;
    @track showAVPAttachment = false;
    @track showModalPopUp;
    @track filesUploaded = [];
    @track avpApprovalcheckbox = false;
    renderedCallback() {
        if (this.isRenderedCallbackExecuted) {
            return;
        }
        this.showSourced = this.record.dealRegId ? true : false;
        this.showTeaming = this.record.teamingResellerdealRegId || this.record.teamingTechPartnerdealRegId;
        this.showTeamingReseller = this.record.teamingResellerdealRegId ? true : false;
        this.showTeamingTech = this.record.teamingTechPartnerdealRegId ? true : false;
        this.isRenderedCallbackExecuted = true;
        this.showAVPAttachment = (this.record.oppRecordType !== RenewalOpportunity && (!this.dealRegrecord.AVP_Approval__c && ((this.dealRegrecord.Deal_Reg_Type__c=== dealTypeSourced && (this.record.stageName=== oppStageSponsorship || this.record.stageName=== oppStageImpactVal ) )  || ( this.dealRegrecord.Deal_Reg_Type__c=== dealTypeTeaming && this.record.stageName=== oppStageImpactVal ) )) )? true : false;
    }
    checktheMatrix() {
        console.log(this.dealRegrecord.Deal_Reg_Type__c + (this.dealRegrecord.Partner_Type__c == techPartner ? techPartner : reseller) + this.record.dealRegType + this.record.dealRegPartnerType + this.record.teamingResellerdealRegType + this.record.teamingResellerdealRegPartnerType + this.record.teamingTechPartnerdealRegType + this.record.teamingTechPartnerdealRegPartnerType);
        console.log(this.record.stageName);
        let condToCheck = this.dealRegrecord.Deal_Reg_Type__c + (this.dealRegrecord.Partner_Type__c == techPartner ? techPartner : reseller) + this.record.dealRegType + this.record.dealRegPartnerType + this.record.teamingResellerdealRegType + this.record.teamingResellerdealRegPartnerType + this.record.teamingTechPartnerdealRegType + this.record.teamingTechPartnerdealRegPartnerType;
        if (this.record.oppId || this.record.isSelected) {
            if (!this.showAVPAttachment && ((this.conditionSet && condToCheck && this.conditionSet.indexOf(condToCheck) != -1) || this.record.isSelected)){
                this.loading = true;
                this.errmsg = '';
                convertDRtoOpp({ selectedOppId: this.record.oppId, drId: this.dealRegrecord.Id }).then(result => {
                    console.log(result);
                    if (!result.convertedOppId) {
                        this.errmsg = 'Error: Please reach out to Salesforce Support Team';
                        const filterChangeEvent = new CustomEvent('erroronsave', {
                            detail: this.errmsg
                        });
                        // Fire the custom event
                        this.dispatchEvent(filterChangeEvent);
                    } else if (result.convertedOppId) {
                        window.location.href = '/' + result.convertedOppId;
                        /*if (document.referrer.indexOf(".lightning.force.com") > 0) {
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: result.convertedOppId,
                                    actionName: 'view'
                                }
                            });
                        } else {
                            window.location.href = '/' + result.convertedOppId;
                        }*/
                    }
                    this.loading = false;
                }).catch(error => {
                    // Showing errors if any while inserting the files
                    if (error) {
                        console.log('inside error');
                        console.log(error);
                        let message = 'Error: ';
                        if (Array.isArray(error.body)) {
                            message = error.body.map(e => e.message).join(', ');
                        } else if (error.body && error.body.message && typeof error.body.message === 'string') {
                            message = error.body.message;
                        } else if (error.body.pageErrors  != 'undefined' && error.body.pageErrors[0] && error.body.pageErrors[0].message) {
                            message += error.body.pageErrors[0].message;
                        } else if (error.body && error.body.fieldErrors && error.body.fieldErrors[0] && error.body.fieldErrors[0].message) {
                            message += error.body.fieldErrors[0].message;
                        }
                        this.errmsg = message;
                        const filterChangeEvent = new CustomEvent('erroronsave', {
                            detail: this.errmsg
                        });
                        // Fire the custom event
                        this.dispatchEvent(filterChangeEvent);
                        this.loading = false;
                    }
                });
            } else {
                this.errmsg = '';
                const filterChangeEvent = new CustomEvent('erroronsave', {
                    detail: this.errmsg
                });
                // Fire the custom event
                this.dispatchEvent(filterChangeEvent);
                this.showModal = true;
                this.showModalPopUp = ((this.conditionSet && condToCheck && this.conditionSet.indexOf(condToCheck) != -1) || this.record.isSelected) ? true : false;
            }
        }
    }
    closeModal() {
        this.showModal = false;
        this.filesUploaded = [];
        this.avpApprovalcheckbox = false;
        this.errmsg = '';
    }

    //Changes of IBA - 1599 - Start
    handleFileUploaded(event) {
        console.log('inside handleFileUploaded');
        if (event.target.files.length > 0) {
            console.log('file lenght'+event.target.files.length);
            let files = [];
            for(var i=0; i< event.target.files.length; i++){
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    let base64 = 'base64,';
                    let content = reader.result.indexOf(base64) + base64.length;
                    let fileContents = reader.result.substring(content);
                    this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
                };
                reader.readAsDataURL(file);
            }
        }
    }

    attachFiles(event){
        console.log('this.filesUploaded '+this.filesUploaded);
        this.loading = true;
        this.errmsg = '';
        uploadFiles({
            files: this.filesUploaded,
            dealReg: this.dealRegrecord,
            source: 'AVPApprovalonDR',
            avpApprovalcheck: this.avpApprovalcheckbox
        })
            .then(result => {
                if(result === 'success') {
                    console.log('result '+result);
                    this.showAVPAttachment = false;
                    console.log('this.showModalPopUp'+this.showModalPopUp);
                    if(this.showModalPopUp === true){
                        this.showModal = false;
                        this.loading = true;
                        let condToCheckagain = this.dealRegrecord.Deal_Reg_Type__c + (this.dealRegrecord.Partner_Type__c == techPartner ? techPartner : reseller) + this.record.dealRegType + this.record.dealRegPartnerType + this.record.teamingResellerdealRegType + this.record.teamingResellerdealRegPartnerType + this.record.teamingTechPartnerdealRegType + this.record.teamingTechPartnerdealRegPartnerType;
                        if (this.record.oppId || this.record.isSelected) {
                            if ((this.conditionSet && condToCheckagain && this.conditionSet.indexOf(condToCheckagain) != -1) || this.record.isSelected){
                                this.loading = true;
                                convertDRtoOpp({ selectedOppId: this.record.oppId, drId: this.dealRegrecord.Id }).then(result => {
                                console.log(result);
                                if (!result.convertedOppId) {
                                    this.errmsg = 'Error: Please reach out to Salesforce Support Team';
                                    const filterChangeEvent = new CustomEvent('erroronsave', {
                                    detail: this.errmsg
                                });
                                // Fire the custom event
                                this.dispatchEvent(filterChangeEvent);
                                this.loading = false;
                                } else if (result.convertedOppId) {
                                    window.location.href = '/' + result.convertedOppId;
                                    this.loading = false;
                                }
                                
                                }).catch(error => {
                                    // Showing errors if any while inserting the files
                                    if (error) {
                                        console.log('inside error');
                                        console.log(error);
                                        let message = 'Error: ';
                                        if (Array.isArray(error.body)) {
                                            message = error.body.map(e => e.message).join(', ');
                                        } else if (error.body && error.body.message && typeof error.body.message === 'string') {
                                            message = error.body.message;
                                        } else if (error.body.pageErrors  != 'undefined' && error.body.pageErrors[0] && error.body.pageErrors[0].message) {
                                            message += error.body.pageErrors[0].message;
                                        } else if (error.body && error.body.fieldErrors && error.body.fieldErrors[0] && error.body.fieldErrors[0].message) {
                                            message += error.body.fieldErrors[0].message;
                                        }
                                        this.errmsg = message;
                                        const filterChangeEvent = new CustomEvent('erroronsave', {
                                            detail: this.errmsg
                                        });
                                        // Fire the custom event
                                        this.dispatchEvent(filterChangeEvent);
                                        this.loading = false;
                                    }
                                });
                            } else {
                                    this.errmsg = '';
                                    const filterChangeEvent = new CustomEvent('erroronsave', {
                                        detail: this.errmsg
                                    });
                                    // Fire the custom event
                                    this.dispatchEvent(filterChangeEvent);
                                    this.showModal = true;
                                }
                        } 
                    }
                    console.log('this.showModal'+this.showModal);
                    if(this.showModal === false){
                        this.loading= true ;
                    }else{
                        this.loading= false ;
                    }
                    console.log('Success','Files uploaded', 'success');
                }else{
                    this.showAVPAttachment = false;
                    console.log('Error','Error uploading files', 'error');
                    this.errmsg = 'Error: Error uploading files, Please try again';
                    const filterChangeEvent = new CustomEvent('erroronsave', {
                        detail: this.errmsg
                    });
                    // Fire the custom event
                    this.dispatchEvent(filterChangeEvent);
                    this.loading = false;
                }
            })
            .catch(error => {
                console.log('Error','Error uploading files', 'error');
                if (error) {
                    console.log('inside error');
                    this.errmsg = 'Please upload a file of size lesser then 3MB';
                    const filterChangeEvent = new CustomEvent('erroronsave', {
                        message: this.errmsg
                    });
                    // Fire the custom event
                    this.dispatchEvent(filterChangeEvent);
                    this.loading = false;
                }
            });
    }

    get disableButton(){
        return !(this.filesUploaded.length >0 && this.avpApprovalcheckbox ? true : false);
    }

    handleAVPApprovalChange(event){
        this.avpApprovalcheckbox = event.target.checked;
    }

    handleRemove(event) {
        console.log('--remove-got--called---fileId--', event.currentTarget.dataset.id);
        let fileId;
        if (event.currentTarget && event.currentTarget.dataset && event.currentTarget.dataset.id) {
            fileId = event.currentTarget.dataset.id;
        }
        for (var i = 0; i < this.filesUploaded.length; i++) {
            if (this.filesUploaded[i].Title === fileId) {
                var sliced = this.filesUploaded.splice(i, 1);
                console.log("Remaining elements: " + this.filesUploaded + "sliced "+sliced);
            }
        }
    }
    //Changes of IBA - 1599 - End
    
}