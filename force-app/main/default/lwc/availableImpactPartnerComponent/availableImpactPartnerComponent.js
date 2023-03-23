import { LightningElement, api, track } from 'lwc';
import fetchImpactTechPartners from "@salesforce/apex/ImpactTechPartnerComponentController.fetchImpactTechPartners"; 
import updateStatus from "@salesforce/apex/ImpactTechPartnerComponentController.updateStatus";
//import describePicklistEntries from "@salesforce/apex/TeamingTechPartnerComponentController.describePicklistEntries";
import cosellWithdrawn from '@salesforce/label/c.Cosell_Withdrawn';


export default class AvailableImpactPartnerComponent extends LightningElement {
	@api opportunityId;
	impactTechPartners;
	error;
    @track showWithdraw;
    @track showComplete;
    @track isModalOpen = false;
    @track recordId;

	
	connectedCallback() {
		this.retrieveImpactTechPartners();
	}

	@api
	retrieveImpactTechPartners() {

		fetchImpactTechPartners({opportunityId: this.opportunityId})
		.then(result => {
			if (result) {
            	this.impactTechPartners = result.wrplst;
			}
			this.error = undefined;
		})
		.catch(error => {
			this.error 				 = error;
			this.impactTechPartners = undefined;
		});

	}

    settocomplete(event) {
        event.preventDefault();
		const selectedRecId = event.target.dataset.id;
        this.recordId = selectedRecId;
        console.log('event detail value--->'+this.recordId);
        this.isModalOpen = true;
    }

    settowithdraw(event){
        event.preventDefault();
		const selectedRecId = event.target.dataset.id;
        updateStatus({
            recordId: selectedRecId,
            Status: cosellWithdrawn
        })
		.then(result => {
            this.retrieveImpactTechPartners();

			this.reRenderImpactTechPartnerInAura();
		})
		.catch(error => {
			this.error = error;
		});
        location.reload();
    }

	closeModal() {
		this.isModalOpen = false;
	}
    
	reRenderImpactTechPartnerInAura() {

		const reAvailableImpactTechPartner = new CustomEvent("rerenderAvailableImpactPartner", {detail: {rerenderedValue:true}} );
		this.dispatchEvent(reAvailableImpactTechPartner);

		//Close the modal after firing the event to reRender the data 
		this.closeModal();

	}

}