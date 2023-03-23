import { LightningElement, api } from 'lwc';
import findRecords from "@salesforce/apex/CustomLookupController.findRecords";


export default class CustomTypeahead extends LightningElement {


	records;
	errors;
	selectedRecord;
	index;
	relationshipField;
	@api iconName;
	@api objectName;
	@api searchField;
	@api valuefield;
	@api partnerType;

	

	searchKey;
	//@api selectedAccounts;

	handleOnChange(event) {
		this.searchKey = event.detail.value;
		
		if (this.validateSearchKeyLen()) {
			console.log(this.searchKey.length);
			this.findRecordsFromObject();
		}

		
		

		
	}

	findRecordsFromObject() {
		let param = {
			searchKey : this.searchKey,
			objectName : this.objectName,
			searchField : this.searchField,
			valuefield : this.valuefield,
			partnerType : this.partnerType
			//existingRecords : this.selectedAccounts
		};

		console.log('this.valuefield'+this.valuefield);
		console.log('this.partnerType'+this.partnerType);
		findRecords({recordDetailsWrap:param})
		.then(result => {
			this.records = result;
			this.errors = undefined;
		})
		.catch(errors => {
			this.errors = errors;
			this.records = undefined;
		})
	}

	validateSearchKeyLen() {

		if (this.validateUndefined()) {
			return false;
		}

		console.log('-=-= this.searchKey -=- '+this.searchKey);
		if(this.searchKey){
		this.searchKey = this.searchKey.trim();

		console.log('-=- lenght > 2 -=- '+(this.searchKey.length >= 2));
		return (this.searchKey.length >= 2);
		}
	}

	validateUndefined() {
		console.log('undefined -- '+(this.searchKey === null));
		console.log('undefined -- '+(this.searchKey === ''));
		console.log('undefined -- '+(this.searchKey === undefined));
		console.log('is blank -- '+((this.searchKey === null) && (this.searchKey === '')));
		console.log('is blank -- '+((this.searchKey === null) && (this.searchKey === '')));

		return ((this.searchKey === null) && (this.searchKey === ''));
	}

	handleSelect(event) {
		const selectedRecordId = event.detail;

		console.log('-==- inside handle select -=-= '+selectedRecordId);

		this.selectedRecord = this.records.find(record => record.recordId === selectedRecordId);

		console.log(this.selectedRecord);

		//this.selectedAccounts.push(selectedRecordId);

		//console.log('-=- this.selectedAccounts -=- ');
		//console.log(this.selectedAccounts);

		const selectedRecordEvent = new CustomEvent("selectedrec",{ detail: {
			recordId: selectedRecordId,
			index: this.index,
			relationshipfield: this.relationshipfield
		}
		});

		this.dispatchEvent(selectedRecordEvent);
	}

	handleRemove(event) {
		event.preventDefault();
		this.selectedRecord = undefined;
		this.records = undefined;
		this.errors = undefined;

		const selectedRecordEvent = new CustomEvent("selectedrec", { detail: {
			recordId: undefined,
			index: this.index,
			relationshipfield: this.relationshipfield
		}
		});

		this.dispatchEvent(selectedRecordEvent);
	}


}