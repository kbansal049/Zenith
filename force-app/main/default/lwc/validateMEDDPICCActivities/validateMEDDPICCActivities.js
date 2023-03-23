import { LightningElement, api, track, wire } from 'lwc';
import OPPORTUNITY_PARTNER from '@salesforce/schema/Opportunity_Partner__c';
import updateOppotunityPartnerToImpact from '@salesforce/apex/ImpactTechPartnerComponentController.updateOppotunityPartnerToImpact';
import jointMeetingErrorMessage from '@salesforce/label/c.Impact_Partner_Joint_Meeting_Error_Message';//IBA-5620


export default class ValidateMEDDPICCActivities extends LightningElement {
   
    @api partnerid;
    @track recordtoSave = {};
    @track loading = true;
    @track saveRecord = false;
    @track existingpartners = [];
    @track errormsg = '';
    @track currentDate = '';//IBA-5620
    @track meetingDate = '';//IBA-5620
    selectedValues;
    isModalOpen;
    _selectedMEDDPICCActivities = new Array();
    isMEDDPICCUpdated = false;
    //meddpiccvalues = new Array();
    
    
    opportunityPartner = OPPORTUNITY_PARTNER;
    
    
    status = "Completed";
   

openmodal(){
    this.isModalOpen = true;
}


    handleFieldChange(e) {        
        return;

    }



    
    handleload(event) {
        if(!this.saveRecord){
            this.loading = false;
        }
    }

    handleSubmit(event) {
        this.loading = true;
        this.saveRecord = true;
        this.errormsg = '';
        this._selectedMEDDPICCActivities.length = 0;
       // this._selectedMEDDPICCActivities = event.detail.value;
        event.preventDefault();
        
        this.validateInput(event.detail.fields); // Modified as part of IBA-5620
    
        console.log('this.errormsg'+this.errormsg);
        if(this.isMEDDPICCUpdated == true){
            this.loading = false;
            this.opportunityPartner.Approval_Status__c = this.status;
            

                this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
           


            this.template.querySelector('lightning-record-edit-form').submit(this.opportunityPartner);
        }
            

    }

    //modified as part of IBA-5620: Start
    validateInput(fieldsValue){
        if(fieldsValue!== undefined){
            this.selectedValues = fieldsValue;
            this._selectedMEDDPICCActivities = (JSON.stringify(this.selectedValues.MEDDPICC_Activity_Type__c)).split(';');
            let d = new Date();
            let newD = new Date(d.getTime() + d.getTimezoneOffset()*60000);
            this.currentDate = newD.toISOString();
            let d1 = new Date(this.selectedValues.Meeting_Date__c);
            let newD2 = new Date(d1.getTime() + d1.getTimezoneOffset()*60000);
            this.meetingdate = newD2.toISOString();
            console.log('@currentDate--->'+this.currentDate);
            console.log('@meetingdate--->'+this.meetingdate);
            if(this.meetingdate > this.currentDate){
                this.loading = false;
                this.errormsg = jointMeetingErrorMessage+ "              ";
            }
            if(this._selectedMEDDPICCActivities.length < 2){
                this.loading = false;
                this.errormsg += "Minimum 2 Activities must be selected;";
            }
            if(this._selectedMEDDPICCActivities.length >= 2 && this.meetingdate <= this.currentDate){
            this.isMEDDPICCUpdated = true;
        }
    }
    //modified as part of IBA-5620: End
    
    }

    handleSuccess(event) {
        //alert("success");
        try{
            updateOppotunityPartnerToImpact({oppPartnerId : this.partnerid})
        } catch(error){
            alert(error);
        }
        if(this.isMEDDPICCUpdated == true){
         location.reload();
         this.isModalOpen = false;
         this.cancelCreation();
        }
    
    }
    handleError(event) {
        this.loading = false;
    }

    cancelCreation() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }

        const filterChangeEvent = new CustomEvent('closemodal');
        // Fire the custom event
        this.dispatchEvent(filterChangeEvent);
        this.isModalOpen = false;
    }

}