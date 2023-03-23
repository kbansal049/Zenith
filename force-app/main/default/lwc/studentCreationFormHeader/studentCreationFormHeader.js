import { LightningElement } from 'lwc';
import ZSA_StudentCreationPageFiles from '@salesforce/resourceUrl/ZSA_StudentCreationPageFiles';

export default class StudentCreationFormHeader extends LightningElement {

    get headerLogo() {
        return ZSA_StudentCreationPageFiles + '/ZSA_StudentCreationPageFiles/header-logo.1654010695.png';
    }    

}