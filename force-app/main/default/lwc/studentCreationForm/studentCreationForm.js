import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import StudentCreationFormCSS from '@salesforce/resourceUrl/StudentCreationFormCSS';
import getFieldSetDetails from '@salesforce/apex/ZscalerLWCUtils.getFieldSetDetails';
import checkForDuplicates from '@salesforce/apex/StudentCreationFormCtrl.checkForDuplicates';
import updateExistingStudentRecord from '@salesforce/apex/StudentCreationFormCtrl.updateExistingStudentRecord';
import PREFIX_FOR_SKILLJAR_ID_LABEL from '@salesforce/label/c.ZS_Academy_Prefix_For_Skilljar_Id';
import STUDENT_CREATION_SUCCESS_MESSAGE_LABEL from '@salesforce/label/c.ZS_Academy_Student_Creation_Success_Message';
import DUPLICATE_STUDENT_EMAIL_VERIFIED_LABEL from '@salesforce/label/c.ZS_Academy_Duplicate_Student_Email_Verified';
import DUPLICATE_STUDENT_EMAIL_NOT_VERIFIED_LABEL from '@salesforce/label/c.ZS_Academy_Duplicate_Student_Email_Not_Verified';
import ZS_ACADEMY_STUDENTFORMHEADER from '@salesforce/label/c.ZS_Academy_StudentFormHeader';
import ZS_ACADEMY_EMAIL_FIELD_LABEL from '@salesforce/label/c.ZS_Academy_Email_Field_Label';
import ZS_ACADEMY_INVALID_EMAIL_DOMAINS_LABEL from '@salesforce/label/c.ZS_Academy_InvalidEmailDomains';
import ZS_ACADEMY_INVALID_EMAIL_DOMAINS_MESSAGE_LABEL from '@salesforce/label/c.ZS_Academy_InvalidEmailDomainsMessage';
import ZS_ACADEMY_ZSCALER_EMAIL_DOMAIN_MESSAGE_LABEL from '@salesforce/label/c.ZS_Academy_ZscalerEmailDomainMessage';
import ZS_ACADEMY_INVALID_STRING_ERROR from '@salesforce/label/c.ZS_ACADEMY_INVALID_STRING_ERROR';
import ZS_ACADEMY_STRING_VALIDATION_REGEX from '@salesforce/label/c.ZS_Academy_String_Validation_Regex';
import GetStudentRegistrationSuccessMsg from '@salesforce/apex/StudentCreationFormCtrl.StudentRegistrationSuccessMsg';

export default class StudentCreationForm extends NavigationMixin(LightningElement) {

    label = {
        PREFIX_FOR_SKILLJAR_ID_LABEL,
        STUDENT_CREATION_SUCCESS_MESSAGE_LABEL,
        DUPLICATE_STUDENT_EMAIL_VERIFIED_LABEL,
        DUPLICATE_STUDENT_EMAIL_NOT_VERIFIED_LABEL,
        ZS_ACADEMY_STUDENTFORMHEADER,
        ZS_ACADEMY_EMAIL_FIELD_LABEL,
        ZS_ACADEMY_INVALID_EMAIL_DOMAINS_LABEL,
        ZS_ACADEMY_INVALID_EMAIL_DOMAINS_MESSAGE_LABEL,
        ZS_ACADEMY_ZSCALER_EMAIL_DOMAIN_MESSAGE_LABEL,
        ZS_ACADEMY_INVALID_STRING_ERROR,
        ZS_ACADEMY_STRING_VALIDATION_REGEX
    };

    @track studentRecordId;
    @track studentFieldsJSON = {};
    @track showSpinner = false;
    @track errorMessage = false;
    @track recordCreated = false;
    @track recordEditFormFieldDetails;
    @track _isRecordDuplicate = false;
    @track _isDuplicateFound = false;
    @track _isDuplicateAndEmailVerified = false;
    @track _isDuplicateAndEmailNotVerified = false;
    @track _isEmailDomainValid = false;
    @track _invalidEmailDomainMessage = '';
    @track _invalidPhoneMessage = '';
    @track phoneFieldValue = '';
    @track titleComboBoxValue = '';
    @track StudentRegSuccessMsg = '';

    _titleComboBoxValueOnChange;
    _isTitleComboBoxEmpty = true;
    _showTitleComboBoxRequiredError = false;
    _isPhoneNumberValid = true;
    _isEmailDomainValid = true;
    _studentRecordId;
    _skilljar__Obfuscated_Id;

    get titleComboBoxOptions() {
        return [
            { label: 'Security professional', value: 'Security professional' },
            { label: 'Networking professional', value: 'Networking professional' },
            { label: 'Manager', value: 'Manager' },
            { label: 'IT/support professional', value: 'IT/support professional' },
            { label: 'Other', value: 'Other' },
        ];
    }

    // IBA-1800 START
    _isFirstNameValid = false;
    _isLastNameValid = false;
    _isAccountNameValid = true;
    _ERROR_ELEMENT_SUFFIX = '_ErrorElement';
    // IBA-1800 END

    @wire(CurrentPageReference) pageRef

    // IBA-4398 START
    @wire(GetStudentRegistrationSuccessMsg)
    WiredStudentRegSuccessMsg({ error, data }) {
        if (data) {
            this.StudentRegSuccessMsg = data;
            console.log(JSON.stringify(data));
            //this.error = undefined;
        } else if (error) {
            //this.error = error;
            //this.StudentRegSuccessMsg = undefined;
        }
    }
    // IBA-4398 END
    
    connectedCallback() {
        try {
            this.getFieldDetails();
            // subscribe to event submitMyformProgramatically
            registerListener('captchasuccess', this.submitMyformProgramatically, this);
            //registerListener('captchafailed', this.submitMyformProgramatically, this);
        } catch (error) {
            console.error(error);
        }
    }

    renderedCallback() {
        Promise.all([loadStyle(this, StudentCreationFormCSS)]);
    }

    disconnectedCallback() {
        try {
            // unsubscribe from inputChangeEvent event
            unregisterAllListeners(this);
        } catch (error) {
            console.error(error);
        }
    }

    async getFieldDetails() {
        try {
            this.showSpinner = true;
            this.recordEditFormFieldDetails = await getFieldSetDetails({
                fieldSetName: 'StudentCreationFormLWC',
                objectAPIName: 'skilljar__Student__c'
            });
            for (let loopVar = 0; loopVar < this.recordEditFormFieldDetails.length; loopVar++) {
                if (this.recordEditFormFieldDetails[loopVar].fieldApiName === 'Account_Name__c') {// Label is Company Name
                    this.recordEditFormFieldDetails[loopVar].isFieldRequired = false;
                    // IBA-1800 START
                    this.recordEditFormFieldDetails[loopVar].stringValidationRequired = true;
                    this.recordEditFormFieldDetails[loopVar].errorMessageElement = this.recordEditFormFieldDetails[loopVar].fieldApiName + this._ERROR_ELEMENT_SUFFIX;
                    // IBA-1800 END
                } else if (this.recordEditFormFieldDetails[loopVar].fieldApiName === 'skilljar__Email__c') {
                    this.recordEditFormFieldDetails[loopVar].isEmailField = true;
                    this.recordEditFormFieldDetails[loopVar].isFieldRequired = true;
                } else if (this.recordEditFormFieldDetails[loopVar].fieldApiName === 'Phone__c') {
                    this.recordEditFormFieldDetails[loopVar].isPhoneField = true;
                    this.recordEditFormFieldDetails[loopVar].isFieldRequired = true;
                // IBA-1800 START
                } else if (this.recordEditFormFieldDetails[loopVar].fieldApiName === 'skilljar__First_Name__c' || 
                    this.recordEditFormFieldDetails[loopVar].fieldApiName === 'skilljar__Last_Name__c') {

                    this.recordEditFormFieldDetails[loopVar].isFieldRequired = true;
                    this.recordEditFormFieldDetails[loopVar].stringValidationRequired = true;
                    this.recordEditFormFieldDetails[loopVar].errorMessageElement = this.recordEditFormFieldDetails[loopVar].fieldApiName + this._ERROR_ELEMENT_SUFFIX;
                // IBA-1800 END
                } else if (this.recordEditFormFieldDetails[loopVar].fieldApiName === 'Title__c') {
                    this.recordEditFormFieldDetails[loopVar].isFieldRequired = true;
                    this.recordEditFormFieldDetails[loopVar].isTitleField = true;
                    this.recordEditFormFieldDetails[loopVar].fieldlabel = 'Tell us a little about yourself';
                } else {
                    this.recordEditFormFieldDetails[loopVar].isFieldRequired = true;
                    this.recordEditFormFieldDetails[loopVar].noCustomLogicOrValidation = true;
                }
            }
            this.showSpinner = false;
        } catch (error) {
            this.showSpinner = false;
            console.error(error);
        }
    }


    handleLoad(event) {
    }

    handleFieldChange(event) {
        try {
            if (event.target.fieldName === 'skilljar__Email__c' && event.target.value) {
                let emailString = event.target.value.toLowerCase();
                this.checkEmailDomainValidity(emailString);
            }
            if (event.target.fieldName === 'Phone__c') {
                this.phoneFieldValue = event.target.value;
                event.target.reportValidity();
                this.checkPhoneValidity(event.target.value);
            }
            // IBA-1800 START
            let targetElement = event.target;
            if (targetElement.fieldName === 'skilljar__First_Name__c' || targetElement.fieldName === 'skilljar__Last_Name__c' ||
                targetElement.fieldName === 'Account_Name__c') {
                
                let isRequired = event.target.dataset.required === 'true';
                targetElement.reportValidity();
                this.checkStringValidity(targetElement, isRequired);
            }
            // IBA-1800 END
        } catch (error) {
            console.error(error);
        }
    }

    handleRegister(event) {
        this.showSpinner = true;
    }

    async handleSubmit(event) {
        try {
            if (!this._isFirstNameValid) {
                let targetElement = this.template.querySelector('[data-id="skilljar__First_Name__c"]');
                this.checkStringValidity(targetElement, true);
            } 
            if (!this._isLastNameValid) {
                let targetElement = this.template.querySelector('[data-id="skilljar__Last_Name__c"]');
                this.checkStringValidity(targetElement, true);
            }
            //this._showTitleComboBoxRequiredError = this._isTitleComboBoxEmpty == true;
            
            event.preventDefault();       // stop the form from submitting

            if (this._isPhoneNumberValid && 
                this._isEmailDomainValid && 
                this._isFirstNameValid && 
                this._isLastNameValid && 
                this._isAccountNameValid && 
                this.isRequiredFieldsCheckCompleted) {//Check for field validity before submitting form
                this.showSpinner = true;
                const fields = event.detail.fields;
                // IBA-1800 START
                fields.skilljar__First_Name__c = fields.skilljar__First_Name__c ? fields.skilljar__First_Name__c.trim() : '';
                fields.skilljar__Last_Name__c = fields.skilljar__Last_Name__c ? fields.skilljar__Last_Name__c.trim() : '';
                fields.Account_Name__c =  fields.Account_Name__c ? fields.Account_Name__c.trim() : '';
                    // IBA-1800 END
                const checkForDuplicateStudentWrapperList = await checkForDuplicates({ studentEmail: fields.skilljar__Email__c });
                if (checkForDuplicateStudentWrapperList.length > 0) {
                    for (let loopvar = 0; loopvar < checkForDuplicateStudentWrapperList.length; loopvar++) {
                        if (checkForDuplicateStudentWrapperList[loopvar].isDuplicate) {
                            if (checkForDuplicateStudentWrapperList[loopvar].isEmailVerified) {//isEmailVerified = TRUE
                                this._isDuplicateAndEmailVerified = true;
                            }
                            if (!checkForDuplicateStudentWrapperList[loopvar].isEmailVerified) {//isEmailVerified = FALSE
                                //IBA-1136 - Bikram 12th July 2022 Do not show any msg, merge the form data with existing record
                                this._isDuplicateAndEmailNotVerified = true;
                                this._studentRecordId = checkForDuplicateStudentWrapperList[loopvar].studentRecord.Id;
                                this._skilljar__Obfuscated_Id = checkForDuplicateStudentWrapperList[loopvar].studentRecord.skilljar__Obfuscated_Id__c;
                            }
                        }
                    }
                }
                if (!this._isDuplicateAndEmailVerified && !this._isDuplicateAndEmailNotVerified) {
                    fields.Name = fields.skilljar__First_Name__c + ' ' + fields.skilljar__Last_Name__c;
                    //Prefixed a Custom Label to identify SF record
                    let obfuscatedID = PREFIX_FOR_SKILLJAR_ID_LABEL + Math.random().toString(36).substring(2, 9);
                    fields.skilljar__Obfuscated_Id__c = obfuscatedID;
                    fields.Title__c = this._titleComboBoxValueOnChange;
                    fields.Phone__c = this.phoneFieldValue;
                    this.template.querySelector('lightning-record-edit-form').submit(fields); // Submits the form

                    //Community Guest user may see the Error ‘The Requested resource does not exist’ 
                    //while Creating Record from community using the lightning:recordEditForm
                    //https://trailblazer.salesforce.com/issues_view?id=a1p3A000001GN1gQAG&title=community-guest-user-may-see-the-error-the-requested-resource-does-not-exist-while-creating-record-from-community-using-the-lightning-recordeditform
                    //this.navigateToHomePage();
                } else if (this._isDuplicateAndEmailNotVerified) {
                    fields.Id = this._studentRecordId;
                    fields.Name = fields.skilljar__First_Name__c + ' ' + fields.skilljar__Last_Name__c;
                    fields.Title__c = this._titleComboBoxValueOnChange;
                    const checkForDuplicateStudentWrapperList = await updateExistingStudentRecord({ studentRecord: fields });
                    this._isDuplicateFound = true;
                    this.showSpinner = false;
                } else {
                    this.recordCreated = false;
                    this._isDuplicateFound = true;
                    this.showSpinner = false;
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleSuccess(event) {
        try {
            this.recordCreated = true;
            this.showSpinner = false;
            const payload = event.detail;
            const createdRecord = event.detail.id;
        } catch (error) {
            console.error(error);
        }
    }

    handleError(event) {
        try {
            if (event.detail.message === 'The requested resource does not exist') {
                this.recordCreated = true;
                this.showSpinner = false;
                this.errorMessage = '';
            } else {
                this.recordCreated = false;
                this.showSpinner = false;
                this.errorMessage = event.detail.message;
            }
        } catch (error) {
            console.error(error);
        }

    }

    handleCreateStudentButton(event) {
        this.recordCreated = false;
    }

    submitMyformProgramatically() {
        try {
            const btn = this.template.querySelector(".hiddenbtn");
            if (btn && this.isRequiredFieldsCheckCompleted) {
                btn.click();
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleTitleChange(event) {
        this._titleComboBoxValueOnChange = event.detail.value;
        if (this._titleComboBoxValueOnChange) {
            this._isTitleComboBoxEmpty = false;
            this._showTitleComboBoxRequiredError = false;
        } else {
            this._isTitleComboBoxEmpty = true;
            this._showTitleComboBoxRequiredError = true;
        }
    }

    get isRequiredFieldsCheckCompleted() {
        if (this._isTitleComboBoxEmpty) {
            this._showTitleComboBoxRequiredError = true;
        }
        return !this._isTitleComboBoxEmpty;
    }

    handleSignInButton(event) {
        window.open("https://customer.zscaler.com/page/zscaler-academy", "_parent");
    }

    checkPhoneValidity(phoneValue) {
        try {

            this._isPhoneNumberValid = true;

            let regexpForValidPhone = /[0-9]{10,}$/g;
            this._isPhoneNumberValid = phoneValue.match(regexpForValidPhone);
            // Added !phoneValue to avoid displaying two error messages for required field
            if (this._isPhoneNumberValid || !phoneValue) {
                this._invalidPhoneMessage = '';
            } else {
                this._invalidPhoneMessage = 'Please enter a valid phone number';
            }

        } catch (error) {
            console.error(error);
        }

    }

    checkEmailDomainValidity(emailString) {
        try {
            this._isEmailDomainValid = true;

            let regexpForDomainName = /(?<=@)[^.]+(?=\.)/g;
            let domainName = String(Array.from(emailString.matchAll(regexpForDomainName))[0]);
            let isEmailDomainInvalid = this.checkForInvalidEmailDomainNames(domainName);
            if (domainName === "zscaler") {
                this._invalidEmailDomainMessage = this.label.ZS_ACADEMY_ZSCALER_EMAIL_DOMAIN_MESSAGE_LABEL;
                this._isEmailDomainValid = false;
            } else if (isEmailDomainInvalid) {
                this._invalidEmailDomainMessage = this.label.ZS_ACADEMY_INVALID_EMAIL_DOMAINS_MESSAGE_LABEL;
                this._isEmailDomainValid = false;
            } else {
                this._invalidEmailDomainMessage = '';
                this._isEmailDomainValid = true;
            }

        } catch (error) {
            console.error(error);
        }
    }

    // IBA-1800 START
    checkStringValidity(targetElement, isRequired) {
        let booleanFlagName = this.getBooleanFlagName(targetElement.fieldName);
        let REGEX_STRING = this.label.ZS_ACADEMY_STRING_VALIDATION_REGEX;
        const REGEX_FOR_VALID_STRING = new RegExp(REGEX_STRING); // \w means word character a-z, A-Z, 0-9 and _(underscore)
        let isValid = true;
        let hideErrorMessage = true;
        if (isRequired) {
            isValid = targetElement.value && targetElement.value.trim() && REGEX_FOR_VALID_STRING.test(targetElement.value);
            hideErrorMessage = !targetElement.value || (targetElement.value.trim() && REGEX_FOR_VALID_STRING.test(targetElement.value));
        } else {
            isValid = !targetElement.value || (targetElement.value.trim() && REGEX_FOR_VALID_STRING.test(targetElement.value));
            hideErrorMessage = isValid;
        }
        this[booleanFlagName] = isValid;
        this.setErrorMessageOnUI(targetElement.dataset.errorMessageElementId, hideErrorMessage);
    }

    // This method is used to dynamically generate the name of boolean flag using the fieldName(API Name of field) for validity 
    // for e.g. _isFirstNameValid, _isLastNameValid, _isAccountNameValid
    getBooleanFlagName(fieldName) {
        const REGEX_FOR_END_STRING_MATCH = /__c$/i;
        const REGEX_FOR_START_STRING_MATCH = /^skilljar__/i;
        let booleanFlagName = fieldName.replace(REGEX_FOR_END_STRING_MATCH, '');
        booleanFlagName = booleanFlagName.replace(REGEX_FOR_START_STRING_MATCH, '');
        booleanFlagName = booleanFlagName.replaceAll('_', '');
        booleanFlagName = '_is' + booleanFlagName + 'Valid';
        return booleanFlagName;
    }

    setErrorMessageOnUI(errorMessageElementDataId, hideErrorMessage) {
        try {
            const QUERY_SELECTOR_INPUT = '[data-id="' + errorMessageElementDataId + '"]';
            let errorMessageElement = this.template.querySelector(QUERY_SELECTOR_INPUT);
            if (errorMessageElement) {
                errorMessageElement.innerHTML = hideErrorMessage ? '' : this.label.ZS_ACADEMY_INVALID_STRING_ERROR;
            } 
        } catch (error) {
            console.error(error);
        }
    }
    // IBA-1800 END

    checkForInvalidEmailDomainNames(domainName) {

        let _isEmailDomainInValid = false;
        const emailDomainArr = this.label.ZS_ACADEMY_INVALID_EMAIL_DOMAINS_LABEL.split(',');
        _isEmailDomainInValid = emailDomainArr.find(element => {
            return element.toLowerCase() === domainName.toLowerCase();
        });

        return _isEmailDomainInValid;
    }

}