import { LightningElement, api } from "lwc";

export default class GenericRecordEditComponent extends LightningElement {
  // objectApiName is "Account" when this component is placed on an account record page
  @api objectApiName;
  @api recordId;
  @api showModal;
  @api showWithoutModal;

  @api fieldSetName;

  

  handleSuccess(event) {
    //fields.Name = 'My Custom  Name'; // modify a field
    this.dispatchEvent(new CustomEvent("standardeditsaveevt"));
    this.handleCancel();
  }
  handleCancel() {
    this.showModal = false;
    this.dispatchEvent(new CustomEvent("standardeditcancelevt"));
  }

  get checkTheFieldSetName() {
    console.log('--checkTheFieldSetName--',this.fieldSetName)
    let ret = false;
    if(this.fieldSetName){
      ret = true;
    }else{
      ret = false;
    }
    return ret;
  }

  get sectionExpand(){
    return true;
  }
}