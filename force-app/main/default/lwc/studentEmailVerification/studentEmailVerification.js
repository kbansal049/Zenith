import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import StudentCreationFormCSS from '@salesforce/resourceUrl/StudentCreationFormCSS';
import updateIsEmailVerifiedField from '@salesforce/apex/StudentEmailVerificationController.updateIsEmailVerifiedField';
import EMAIL_VERIFICATION_SUCCESS_LABEL_LINE_1 from '@salesforce/label/c.ZS_Academy_Student_Email_Verification_Success_Line_1';
import EMAIL_VERIFICATION_SUCCESS_LABEL_LINE_2 from '@salesforce/label/c.ZS_Academy_Student_Email_Verification_Success_Line_2';
import EMAIL_VERIFICATION_FAILED__LABEL from '@salesforce/label/c.ZS_Academy_Student_Email_Verification_Failed';
import EMAIL_VERIFICATION_LINKEXPIRED__LABEL from '@salesforce/label/c.ZS_Academy_Student_Email_Verification_LinkExpired';
import EMAIL_RESEND_SUCCESS_LABEL from '@salesforce/label/c.ZS_Academy_EmailResendSuccess';
import resendVerificationEmail from '@salesforce/apex/StudentEmailVerificationController.resendVerificationEmail';

export default class StudentEmailVerification extends LightningElement {

    label = {
        EMAIL_VERIFICATION_SUCCESS_LABEL_LINE_1,
        EMAIL_VERIFICATION_SUCCESS_LABEL_LINE_2,
        EMAIL_VERIFICATION_FAILED__LABEL,
        EMAIL_VERIFICATION_LINKEXPIRED__LABEL,
        EMAIL_RESEND_SUCCESS_LABEL
    };

    showSpinner = false;
    _isEmailResendSuccess = false;

    _studentrecordid;
    @api
    get studentrecordid() {
        return this._studentrecordid;
    }
    set studentrecordid(value) {
        this._studentrecordid = value;
    }
    @track isEmailVerificationSuccess = false;
    @track isEmailVerificationFailed = false;
    @track isEmailVerificationLinkExpired = false;

    connectedCallback() {
        this.updateStudentRecord();
    }

    renderedCallback() {
        Promise.all([loadStyle(this, StudentCreationFormCSS)]);
    }

    async updateStudentRecord() {
        try {
            this.showSpinner = true;
            const updateStatusString = await updateIsEmailVerifiedField({ studentRecordId: decodeURIComponent(this._studentrecordid) });
            if (updateStatusString === 'UPDATE_SUCCESS') {
                this.isEmailVerificationSuccess = true;
            } else if (updateStatusString === 'UPDATE_FAIL') {
                this.isEmailVerificationFailed = true;
            } else if (updateStatusString === 'EMAIL_LINK_EXPIRED') {
                this.isEmailVerificationLinkExpired = true;
            } else {
                this.isEmailVerificationFailed = true;
            }
            this.showSpinner = false;

        } catch (error) {
            console.error(error);
            this.showSpinner = false;
        }
    }

    async triggerVerificationEmail() {
        try {
            this.showSpinner = true;
            const updateStatusString = await resendVerificationEmail({ studentRecordId: decodeURIComponent(this._studentrecordid) });
            if (updateStatusString === 'UPDATE_SUCCESS') {
                this._isEmailResendSuccess = true;
            } else if (updateStatusString === 'UPDATE_FAIL') {
                this._isEmailResendSuccess = false;
            }
            this.showSpinner = false;

        } catch (error) {
            console.error(error);
            this.showSpinner = false;
        }
    }
}