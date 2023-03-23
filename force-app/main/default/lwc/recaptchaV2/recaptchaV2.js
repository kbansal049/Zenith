import { LightningElement, track } from 'lwc';
import pageUrl from '@salesforce/resourceUrl/recaptchaV2';
import { fireEvent } from 'c/pubsub';

export default class RecaptchaV2 extends LightningElement {

    @track navigateTo;

    constructor() {
        try {
            super();
            this.navigateTo = pageUrl;
            //add event listener for message that we post in our recaptchaV2 static resource html file.
            window.addEventListener("message", this.listenForMessage);
        } catch (error) {
            console.error(error);
        }
    }

    captchaLoaded(event) {
        if (event.target.getAttribute('src') == pageUrl) {
            console.log('Google reCAPTCHA is loaded.');
        }
    }

    listenForMessage(message) {
        try {
            //message.data - The object passed from the other window.
            console.log('message data : ' + message.data);
            //message.origin - The origin of the window that sent the message at the time postMessage was called.
            console.log('message origin : ' + message.origin);
            //fireEvent(null, 'captchaeventmessage', message.data);

            if (message.data === 'captcha success') {
                fireEvent(null, 'captchasuccess', null);
            } else if (message.data === 'captcha failed') {
                fireEvent(null, 'captchafailed', null);
            } else {
                fireEvent(null, 'captchafailed', null);
            }

        } catch (error) {
            console.error(error);
            fireEvent(null, 'captchaeventmessage', null);
        }
    }

}