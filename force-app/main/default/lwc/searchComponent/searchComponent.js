import { LightningElement } from 'lwc';

export default class SearchComponent extends LightningElement {
	searchKey;

	handleChange(event) {

		const searchKey = event.target.value;
		event.preventDefault();

		const searchEvent = new CustomEvent('change', {
			detail: searchKey
		});

		this.dispatchEvent(searchEvent);
	}
}