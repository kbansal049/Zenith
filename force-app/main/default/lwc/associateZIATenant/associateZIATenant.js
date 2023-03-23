import { LightningElement,track ,wire} from 'lwc';

export default class AssociateZIATenant extends LightningElement {
    @track openModal=true;
    closeModal() {
        this.openModal = false;
    }
    
}