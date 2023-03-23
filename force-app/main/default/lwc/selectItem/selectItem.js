import { LightningElement, api } from 'lwc';

export default class SelectItem extends LightningElement {
	@api record;
	@api fieldName;
	@api iconName;

	handleSelect(event) {
		event.preventDefault();
		const selectedRecord = new CustomEvent("select", { detail : this.record.recordId});
		this.dispatchEvent(selectedRecord);
	}
}