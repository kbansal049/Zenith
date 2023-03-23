import { LightningElement, api, track } from 'lwc';
import fetchTeamingTechPartners from "@salesforce/apex/TeamingTechPartnerComponentController.fetchTeamingTechPartners"; 
import deleteTeamingTechPartners from "@salesforce/apex/TeamingTechPartnerComponentController.deleteTeamingTechPartners"; 
import findLoggedInUserProfile from "@salesforce/apex/TeamingTechPartnerComponentController.findLoggedInUserProfile";

export default class AvailableTeamingTechPartnerComponent extends LightningElement {
	@api opportunityId;
	teamingTechPartners;
	error;

	isSystemAdmin = false;	
	//partnerUrl = ''

	navigateToRecordPage(event) {
		event.preventDefault();
		const selectedRecId = event.target.dataset.id;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecId,
                objectApiName: 'Opportunity_Partner__c',
                actionName: 'view'
            }
        });
	}


	
	connectedCallback() {
		this.retrieveTeamingTechPartners();
		this.findLoggedInUserProfile();
	}

	@api
	retrieveTeamingTechPartners() {

		fetchTeamingTechPartners({opportunityId: this.opportunityId})
		.then(result => {
			this.teamingTechPartners = undefined;
			
			if (result.length > 0) {
				this.teamingTechPartners = result;
			}
			
			this.error 				 = undefined;
		})
		.catch(error => {
			this.error 				 = error;
			this.teamingTechPartners = undefined;
		}); 
	}

	handleDelete(event) {
		const selectedRecIdToDelete = event.target.dataset.id;

		var result = confirm("Want to delete?");

		if (result) {
			deleteTeamingTechPartners({recordId: selectedRecIdToDelete})
			.then(result => {
				this.retrieveTeamingTechPartners();

				this.reRenderTeamingTechPartnerInAura();
			})
			.catch(error => {

			});
		}

		
	}

	reRenderTeamingTechPartnerInAura() {

		const reAvailableTeamingTechPartner = new CustomEvent("rerenderAvailableTeamingTechPartner", {detail: {rerenderedValue:true}} );
		this.dispatchEvent(reAvailableTeamingTechPartner);

		//Close the modal after firing the event to reRender the data 
		this.closeModal();

	}

	findLoggedInUserProfile() {
		findLoggedInUserProfile()
		.then(result => {

			console.log('-=- result -=- '+result);
			this.isSystemAdmin = result;
		})
		.catch(error => {

		});
	}


}