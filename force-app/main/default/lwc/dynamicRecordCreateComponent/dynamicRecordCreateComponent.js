import { LightningElement, api, track } from "lwc";

export default class DynamicRecordCreateComponent extends LightningElement {
  // objectApiName is "Account" when this component is placed on an account record page
  @api objectApiName;
  @api rtId;
  @api showModal;
  @api relApiName;
  @api relValue;
  @api showWithoutModal;
  @api defaultvals;

  @api fieldSetName;

  @track loading = false;

  handleSubmit(event) {
    //fields.Name = 'My Custom  Name'; // modify a field
    this.loading = true;
    event.preventDefault(); // stop the form from submitting
    const fields = event.detail.fields;
    console.log(this.defaultvals);
    console.log(this.relApiName);
    console.log(this.relValue);
    if (this.relApiName && this.relValue) {
      console.log("inside set def");
      fields[this.relApiName] = this.relValue;
    }
    if (this.defaultvals) {
      this.defaultvals.forEach((el) => {
        if (el && el.name && el.value) {
          fields[el.name] = el.value;
        }
      });
    }
    this.template.querySelector("lightning-record-form").submit(fields);
  }
  handleError(event) {
    console.log("inside err");
    this.loading = false;
  }
  handleSuccess(event) {
    this.dispatchEvent(new CustomEvent("standardcreatesaveevt"));
    this.handleCancel();
  }
  handleCancel() {
    this.dispatchEvent(new CustomEvent("standardcreatecancelevt"));
    this.loading = false;
  }

  get checkTheFieldSetName() {
    console.log("--checkTheFieldSetName--", this.fieldSetName);
    let ret = false;
    if (this.fieldSetName) {
      ret = true;
    } else {
      ret = false;
    }
    return ret;
  }
  get sectionExpand() {
    return true;
  }
}