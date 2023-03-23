import { LightningElement, api, track } from 'lwc';
import describePicklistEntries from "@salesforce/apex/TeamingTechPartnerComponentController.describePicklistEntries";
import createOpportunityPartners from "@salesforce/apex/TeamingTechPartnerComponentController.createOpportunityPartners";

import teamingTechPartnerRequired from '@salesforce/label/c.Teaming_Tech_Partner_Required';

export default class AddTeamingTechPartnerComponent extends LightningElement {

	@api recordId;
	@api modalHeader;
	
	/*technologyPartnerAccount;
	activityDate;
	activityType;*/
	isModalOpen;

	picklistFieldEntries;
	error;
	@track loading = false;

	//selectedAccounts = [];
	@api picklistvalue ='';
	value = '';

	get options() {
        return [
            { label: 'Technology Partner', value: 'Technology Partner' },
            { label: 'System Integrator', value: 'Partner-Integrator' },
        ];
    }

    handleChangepicklist(event) {
        this.picklistvalue = event.detail.value;
		console.log('this.picklistvalue '+this.picklistvalue);
    }

	connectedCallback(){
		
		this.getPicklistValues();
		this.addNewRow();
	}


	getPicklistValues() {
		describePicklistEntries()
		.then(result => {

			console.log('-=-=-==--=- result -=-=- ');
			console.log(result);

			this.picklistFieldEntries = result;
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			this.picklistFieldEntries = undefined;
		});
	}

	

	handleChange(event) {

		console.log('-=- event.detail.value -=- '+event.detail.value);

		const indexOfTeamingTechPartnerList = parseInt(event.target.dataset.id);
		this.teamingTechPartnerList[indexOfTeamingTechPartnerList].activityType = event.detail.value;
	}

	handleActivityDateChange(event) {
		const indexOfTeamingTechPartnerList = parseInt(event.target.dataset.id);
		this.teamingTechPartnerList[indexOfTeamingTechPartnerList].activityDate = event.target.value;
	}

	handleSelectedRec(event) {
		const indexOfTeamingTechPartnerList = parseInt(event.target.dataset.id);
		this.teamingTechPartnerList[indexOfTeamingTechPartnerList].technologyPartnerAccount = event.detail.recordId;

	}

	handleDateChange(event) {
		const indexOfTeamingTechPartnerList = parseInt(event.target.dataset.id);
		this.teamingTechPartnerList[indexOfTeamingTechPartnerList].activityDate = event.detail.value; 
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
		this.teamingTechPartnerList = [];
		this.addNewRow();
	}

	submitDetails() {
		this.loading = true;
		console.log('-=- this.selectedPicklistValue -=- '+this.activityType);
		console.log('-=-=- this.activityDate -=- '+this.activityDate);
		console.log('-=- this.technologyPartnerAccount =- '+this.technologyPartnerAccount);

		console.log(this.teamingTechPartnerList);

		this.stopSubmittingRecord = false; //TODO:make it to false
		this.customError = undefined;
		
		
		this.generateApprovalJSON();

		console.log(this.approvalJSON);


		this.validateInputdata();

		console.log('-=- this.stopSubmittingRecord -=- '+this.stopSubmittingRecord);

		if(this.stopSubmittingRecord) {
			return;
		}

		console.log('-=- this.teamingTechPartnerList -=- ');
		console.log(this.teamingTechPartnerList);
		console.log(JSON.stringify(this.teamingTechPartnerList));


		createOpportunityPartners({oppPartnerWrapList: this.teamingTechPartnerList})
		.then(result => {

			if (result) {
				this.reRenderTeamingTechPartnerInAura();
			}
			this.loading = false;
			
		})
		.catch(error => {
			this.error = error;
			this.loading = false;
		});
		this.loading = false;



	}

	stopSubmittingRecord = false;
	customError = '';

	validateInputdata() {

		console.log('-=- validate input data -=- ');
		this.teamingTechPartnerList.forEach(eachRec => {
			eachRec.activityTypeBlank = !this.checkNotBlank(eachRec.activityType);
			eachRec.partnerBlank = !this.checkNotBlank(eachRec.technologyPartnerAccount);

			console.log((eachRec.activityTypeBlank || eachRec.partnerBlank));
			console.log(eachRec.activityType);
			console.log(eachRec.technologyPartnerAccount);
			console.log(eachRec.activityTypeBlank);
			console.log(eachRec.partnerBlank);

			if (eachRec.activityTypeBlank || eachRec.partnerBlank || !this.checkNotBlank(this.picklistvalue)) {
				this.stopSubmittingRecord = true;
				//this.customError= 'Both Technology Partner Account and Activity Type are required.';
				//this.customError = 'Complete the required field(s).'
				this.loading = false;
				this.customError = teamingTechPartnerRequired;
				console.log('-=-=-this.error -=- ');
				console.log(this.customError);
				return;
			}

			this.stopSubmittingRecord = false;

		});

		console.log('-=-=-- here I am -=- ');
		console.log(this.teamingTechPartnerList);
		

	}

	checkNotBlank(eachRecVal) {
		return ((eachRecVal !== null) && (eachRecVal !== ''));
	}


	approvalJSON = {};

	generateApprovalJSON() {
		this.loading = true;
		this.approvalJSON.activityType = '';
		this.approvalJSON.technologyPartnerAccount  = '';
		this.approvalJSON.recordId	   = this.recordId;

		this.teamingTechPartnerList.forEach(eachRec => {
			eachRec.recordId	   = this.recordId;
		});


	}

	reRenderTeamingTechPartnerInAura() {
		this.loading = true;
		const reAvailableTeamingTechPartner = new CustomEvent("rerenderAvailableTeamingTechPartner", {detail: {rerenderedValue:true}} );
		this.dispatchEvent(reAvailableTeamingTechPartner);

		//Close the modal after firing the event to reRender the data 
		this.loading = false;
		this.closeModal();

	}





	@track teamingTechPartnerList = [];


	addNewRow() {
		console.log('-=- Inside add row -=- ');

		//this.teamingTechPartnerList = [];

		var today = new Date();

		let numberOfRecs = this.teamingTechPartnerList.length;
		numberOfRecs = numberOfRecs > 0 ? numberOfRecs : 0;

		let teamingTechPartner = {};
		teamingTechPartner.technologyPartnerAccount = '';
		teamingTechPartner.activityType = '';
		teamingTechPartner.id = numberOfRecs;
		teamingTechPartner.activityDate = undefined;

		let teamingTechPartnerArr = [];
		
		this.teamingTechPartnerList.forEach(eachRec => {
			teamingTechPartnerArr.push(eachRec);

			//this.selectedAccounts.push(eachRec.technologyPartnerAccount);
		});



		teamingTechPartnerArr.push(teamingTechPartner);

		this.teamingTechPartnerList = teamingTechPartnerArr;

		//this.teamingTechPartnerList.push(teamingTechPartner);

		
	}

	handleRemoveRow(event) {
		console.log('-=- inside remove row -=- ');
		console.log('-=-=- this.teamingTechPartnerList -=- ');
		console.log(this.teamingTechPartnerList);

		const index = event.target.dataset.id;

		let teamingTechPartnerArr = this.teamingTechPartnerList;
		teamingTechPartnerArr.splice(index, 1);

		this.teamingTechPartnerList = [];

		teamingTechPartnerArr.forEach(eachRec => {
			eachRec.id = eachRec.id > teamingTechPartnerArr.length ? (eachRec.id - 1) : eachRec.id;
			this.teamingTechPartnerList.push(eachRec);
		});

		

		console.log('-=-=- this.teamingTechPartnerList -=- ');
		console.log(this.teamingTechPartnerList);
	}

}