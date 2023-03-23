/*
    @Author : Harish Gowda N
    @Requirement : PS Credit Process - IBA-3300
    @Created Date : 10/06/2022
    @Description : LWC Component for PS Credit Redemption Process.
    ***********************************************************************************************************
    MODIFICATION LOG
    * Version            Developer            Date            Jira Number          Description
    *---------------------------------------------------------------------------------------------------------
      1.0                Harish Gowda N       06/10/2022      IBA-3300     New PS Credits Offering for redemption (CR# 5222).
	  ***********************************************************************************************************
*/
import {
    api,
    LightningElement,
    track
} from 'lwc';

export default class GenericNotesComponent extends LightningElement {

    @api isNotesRequired = false;
    @api isParentModalOpen = false;
    @api recordId;
    @api recordName;
    @track notesVal;
    @api isNotesSuccess = false;

    addNotes(event) {
        this.isNotesRequired = true;
    }

    handleNotes(event) {
        this.notesVal = event.detail.value;
    }

    closeNotesModal() {
        this.isNotesRequired = false;
    }

    submitNotes(event) {
        //Create Event .
        const notesEvent = new CustomEvent("getnotesvalue", {
            detail: {
                data: {
                    currentRecordId: this.recordId,
                    notesValue: this.notesVal
                }
            }
        });

        if(this.notesVal){
            this.isNotesSuccess = true;
        }
        else{
            this.isNotesSuccess = false;
        }

        //Dispatch Event .
        this.dispatchEvent(notesEvent);
        this.isNotesRequired = false;
    }
    
}