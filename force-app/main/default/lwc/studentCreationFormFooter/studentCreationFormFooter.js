import { LightningElement } from 'lwc';
import ZSA_StudentCreationPageFiles from '@salesforce/resourceUrl/ZSA_StudentCreationPageFiles';

export default class StudentCreationFormFooter extends LightningElement {

    get poweredByLogo() {
        return ZSA_StudentCreationPageFiles + '/ZSA_StudentCreationPageFiles/powered-by-logo.864fb1f2d98e.png';
    }

    get footerLogo() {
        return ZSA_StudentCreationPageFiles + '/ZSA_StudentCreationPageFiles/logo-footer.svg';
    }

    get facebookLogo() {
        return ZSA_StudentCreationPageFiles + '/ZSA_StudentCreationPageFiles/facebook.svg';
    }

    get linkedinLogo() {
        return ZSA_StudentCreationPageFiles + '/ZSA_StudentCreationPageFiles/linkedin.svg';
    }

    get youtubeLogo() {
        return ZSA_StudentCreationPageFiles + '/ZSA_StudentCreationPageFiles/youtube.svg';
    }

    get twitterLogo() {
        return ZSA_StudentCreationPageFiles + '/ZSA_StudentCreationPageFiles/twitter.svg';
    }
}