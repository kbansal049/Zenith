import { LightningElement, wire, api, track} from 'lwc';
import strUserId from '@salesforce/user/Id';
import findContact from '@salesforce/apex/getContactListController.getContactList';

export default class getContactListController extends LightningElement {
    userId = strUserId;
    @track contacts;
    @track csm;
    customernametitle = 'Zscaler Team';
    @track showContacts = false;
    @track showCSM = false;
    @track showTitle = false;
   
    @wire(findContact)
    wiredContact({ error, data }) {
        if (data) {
            this.contacts = data.accteamlst;
            this.customernametitle += ' for ' + data.accname;
            this.showContacts = data.showaccteam;
            this.csm = data.csm;
            this.showCSM = data.showcsm;
            this.error = undefined;
            if(this.showContacts || this.showCSM){
                this.showTitle = true;
            }
            console.log(data);
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
            this.csm = undefined;
        }
    }
}