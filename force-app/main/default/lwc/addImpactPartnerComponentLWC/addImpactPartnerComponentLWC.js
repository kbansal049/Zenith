import { LightningElement, api, track } from 'lwc';
import createOpportunityPartners from "@salesforce/apex/ImpactTechPartnerComponentController.createOpportunityPartners";
import getPrimaryContacts from "@salesforce/apex/ImpactTechPartnerComponentController.getPrimaryContacts";
import ImpactPartnerErrorMessage from '@salesforce/label/c.Impact_Partner_Error_Message';
import findLoggedInUserProfile from "@salesforce/apex/ImpactTechPartnerComponentController.findLoggedInUserProfile";


export default class AddImpactPartnerComponentLWC extends LightningElement {

	@api recordId;
	@api modalHeader;
	isModalOpen;
	error;
    @track contactName;
	stopSubmittingRecord = false;
	customError = '';
	isValidUser = false;
	@track loading = false;
	@track impactTechPartnerList = [];

	connectedCallback(){
		this.findLoggedInUserProfile();
		this.addNewRow();
	}	

	handleRepNameChange(event) {
		console.log('-=- event.detail.value -=- '+event.detail.value);
		const indexOfImpactTechPartnerList = parseInt(event.target.dataset.id);
		this.impactTechPartnerList[indexOfImpactTechPartnerList].partnerRepName = event.detail.value;
	}

	handleRepEmailChange(event) {
        console.log('-=- event.detail.value -=- '+event.detail.value);
		const indexOfImpactTechPartnerList = parseInt(event.target.dataset.id);
		this.impactTechPartnerList[indexOfImpactTechPartnerList].partnerRepEmail = event.target.value;
	}

	handleSelectedRec(event) {
		const indexOfImpactTechPartnerList = parseInt(event.target.dataset.id);
		this.impactTechPartnerList[indexOfImpactTechPartnerList].impactPartnerAccount = event.detail.recordId;
		if(this.checkNotBlank(event.detail.recordId)){
			console.log('event.detail.recordId'+event.detail.recordId);
        	getPrimaryContacts({accountId: event.detail.recordId})
			.then(result => {
				if (result) {
                	console.log('result '+result.Tech_Partner_Primary_Contact__c);
                	this.impactTechPartnerList[indexOfImpactTechPartnerList].impactPartnerContact = result.Tech_Partner_Primary_Contact__c;
                	this.contactName = result.Tech_Partner_Primary_Contact__r.Name;
                	console.log('contactName '+contactName);
				}
			})
			.catch(error => {
				this.error = error;
			});
		}
		else{
			this.contactName = '';
		}
	}

	openModal() {
		this.resetValues();
		this.isModalOpen = true;
	}

	closeModal() {
		this.resetValues();
		this.isModalOpen = false;
	}

	resetValues() {
		this.error = undefined;
		this.customError = undefined;
		this.impactTechPartnerList = [];
		//this.loading = false;
		this.addNewRow();
	}

	submitDetails() {
		this.loading = true;
		console.log(this.impactTechPartnerList);
		this.stopSubmittingRecord = false; //TODO:make it to false
		this.customError = undefined;
		this.generateApprovalJSON();
		console.log(this.approvalJSON);
		this.validateInputdata();
		console.log('-=- this.stopSubmittingRecord -=- '+this.stopSubmittingRecord);
		if(this.stopSubmittingRecord) {
			return;
		}
		console.log('-=- this.impactTechPartnerList -=- ');
		console.log(JSON.stringify(this.impactTechPartnerList));
		createOpportunityPartners({oppPartnerWrapList: this.impactTechPartnerList})
		.then(result => {
			if (result) {
				this.reRenderImpactTechPartnerInAura();
			}
			this.loading = false;		
		})
		.catch(error => {
			this.loading = false;
			this.error = error;
		});
	}

	checkNotBlank(eachRecVal) {
		return ((eachRecVal !== null) && (eachRecVal !== '') && (eachRecVal !== undefined));
	}

	validateInputdata() {

		console.log('-=- validate input data -=- ');
		this.impactTechPartnerList.forEach(eachRec => {
			//eachRec.impactPartnerContact = !this.checkNotBlank(eachRec.impactPartnerContact);
			if (!this.checkNotBlank(eachRec.impactPartnerAccount) || !this.checkNotBlank(eachRec.partnerRepEmail) || !this.checkNotBlank(eachRec.partnerRepName)) {
				this.stopSubmittingRecord = true;
				this.loading = false;
				this.customError = 'Complete the required field(s).';
				console.log('-=-=-this.error -=- ');
				console.log(this.customError);
				return;
			}
			if (this.checkNotBlank(eachRec.impactPartnerAccount) && !this.checkNotBlank(eachRec.impactPartnerContact)) {
				this.stopSubmittingRecord = true;
				this.loading = false;
				this.customError = ImpactPartnerErrorMessage;
				console.log('-=-=-this.error -=- ');
				console.log(this.customError);
				return;
			}
			
			this.stopSubmittingRecord = false;
		});
	}

	approvalJSON = {};
	generateApprovalJSON() {
		this.loading = true;
		this.approvalJSON.partnerRepEmail = '';
        this.approvalJSON.partnerRepName = '';
        this.approvalJSON.impactPartnerContact = '';
		this.approvalJSON.technologyPartnerAccount  = '';
		this.approvalJSON.recordId	   = this.recordId;
		this.impactTechPartnerList.forEach(eachRec => {
			eachRec.recordId	   = this.recordId;
		});
	}

	reRenderImpactTechPartnerInAura() {
		this.loading = true;
		const reAvailableImpactTechPartner = new CustomEvent("rerenderAvailableImpactPartner", {detail: {rerenderedValue:true}} );
		this.dispatchEvent(reAvailableImpactTechPartner);
		//Close the modal after firing the event to reRender the data 
		this.loading = false;
		this.closeModal();

	}

	
	addNewRow() {
		console.log('-=- Inside add row -=- ');
		let impactTechPartner = {};
		this.contactName = '';
        if(this.impactPartnerList){
		    impactTechPartner.impactPartnerAccount = '';
		    impactTechPartner.partnerRepEmail = '';
		    impactTechPartner.id = this.impactPartnerList.length;
		    impactTechPartner.partnerRepName = '';
            impactTechPartner.impactPartnerContact = '';
        }
        else{
            impactTechPartner.impactPartnerAccount = '';
		    impactTechPartner.partnerRepEmail = '';
		    impactTechPartner.id = 0;
		    impactTechPartner.partnerRepName = '';
            impactTechPartner.impactPartnerContact = '';
        }
		let impactTechPartnerArr = [];	
		this.impactTechPartnerList.forEach(eachRec => {
			impactTechPartnerArr.push(eachRec);
		});
		impactTechPartnerArr.push(impactTechPartner);
		this.impactTechPartnerList = impactTechPartnerArr;
        console.log('impactTechPartnerList' + this.impactTechPartnerList);	
	}

	handleRemoveRow(event) {
		console.log('-=- inside remove row -=- ');
		console.log('-=-=- this.impactTechPartnerList -=- ');
		console.log(this.impactTechPartnerList);
		const index = event.target.dataset.id;
		let impactTechPartnerArr = this.impactTechPartnerList;
		impactTechPartnerArr.splice(index, 1);
		this.impactTechPartnerList = [];
		impactTechPartnerArr.forEach(eachRec => {
			eachRec.id = eachRec.id > impactTechPartnerArr.length ? (eachRec.id - 1) : eachRec.id;
			this.impactTechPartnerList.push(eachRec);
		});
		console.log('-=-=- this.impactTechPartnerList -=- ');
		console.log(this.impactTechPartnerList);
	}

	findLoggedInUserProfile() {
		findLoggedInUserProfile({opportunityId: this.recordId})
		.then(result => {

			console.log('-=- result -=- '+result);
			this.isValidUser = result;
		})
		.catch(error => {

		});
	}

}