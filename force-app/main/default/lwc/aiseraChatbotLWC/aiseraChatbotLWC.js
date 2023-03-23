import { api, track, wire, LightningElement } from 'lwc';
import zacResource from '@salesforce/resourceUrl/Aisera_ZAC_Image';
import quoteOpen from '@salesforce/resourceUrl/Quote_Open';
import quoteClose from '@salesforce/resourceUrl/Quote_Close';
import checkAccess from '@salesforce/apex/AiseraChatbotController.accessChatbot';
import getUserDetails from '@salesforce/apex/AiseraChatbotController.getUserDetails';
import getUserTimezone from '@salesforce/apex/AiseraChatbotController.getUserTimezone';
import Username from '@salesforce/schema/User.Username';
import { NavigationMixin } from 'lightning/navigation';
import getSessionCustomSettings from '@salesforce/apex/AiseraChatbotController.getSessionCustomSettings';

export default class AiseraChatbotLWC extends LightningElement {
    zacImage = zacResource;
    quoteOpenIcon = quoteOpen;
    quoteCloseIcon = quoteClose;
    @api showOnlyChat;
    @api showMainHeader;
    @track showChat = false;
    @track userName;
    @track customSessionId
    userTimezone;
    //@track customSessionId;
    @api createCasePageOnly; //Added by Anup
    
    connectedCallback(){
        var sessionId = Math.random().toString(36).substr(2, 12);
        if(!this.showOnlyChat){
            sessionStorage.setItem('zacSessionId',sessionId);
            localStorage.setItem('zacSessionId',sessionId);
        }
        getUserTimezone()
        .then(result =>{
            this.userTimezone = result;
        })
        .catch(error => {
			console.log('Error fetching User Timezone');
		})
        getUserDetails()
		.then(result => {
			var userDetails = result;
            var orgId='';
            if(userDetails.portalDetails.zScalerORGId){
                orgId=userDetails.portalDetails.zScalerORGId;
            }
            this.userName = userDetails.fullName;
            window.webchat = {
                userEmail: userDetails.email,
                userFullName: userDetails.fullName,
                accountId: userDetails.accountId,
                contactId: userDetails.contactId,
                cloudId: orgId,
                userTime: this.userTimezone,
                sessionId: userDetails.customSessionId
            }
            /*var d=document,s=d.createElement('script');
            s.innerText=`loadChat();`
            d.getElementsByTagName('head')[0].appendChild(s);*/
            if(this.showOnlyChat){
                var sessionId2 = Math.random().toString(36).substr(2, 12);
                if(!localStorage.getItem('zacSessionId')){
                    localStorage.setItem('zacSessionId',sessionId2);
                    window.webchat = {
                        sessionId: userDetails.customSessionId,
                        userEmail: userDetails.email,
                        userFullName: userDetails.fullName,
                        accountId: userDetails.accountId,
                        contactId: userDetails.contactId,
                        cloudId: orgId,
                        userTime: this.userTimezone,    
                    }
                }
                //
                /*window.webchat = {
                    sessionId: sessionId2,
                    userEmail: userDetails.email,
                    userFullName: userDetails.fullName,
                    accountId: userDetails.accountId,
                    contactId: userDetails.contactId,
                    cloudId: orgId,
                    userTime: this.userTimezone,    
                }*/
            }
            if(this.createCasePageOnly == undefined || this.createCasePageOnly == false){
                var d=document,s=d.createElement('script');
                s.innerText=`loadChat();`
                d.getElementsByTagName('head')[0].appendChild(s);
            }
            
		})
		.catch(error => {
			console.log('Error fetching User Details');
		})
    }


    @wire(checkAccess)
    checkChatbotAccess({ error, data }) {
        if(data == 'true'){
            this.renderChatbot();
        }
        if(data == 'false'){
            if(this.showOnlyChat !=  true){
                this.renderHero();
            }
        }
        
    }
    
    
    renderChatbot(){
        try{
            var d=document,s=d.createElement('script');
            if(this.showOnlyChat !=  true){
                const style = d.createElement('style');
                style.innerText = `.forceCommunityThemeHeroBase {
                    display: none;
                }`;
                
                d.getElementsByTagName('head')[0].appendChild(style);
                
                this.showChat = true;
            }
            
            const style2 = d.createElement('style');
            style2.innerText = `#awc-webchat {
                display: block !important;
            }`;
            d.getElementsByTagName('head')[0].appendChild(style2);

            if(this.showOnlyChat == true){
                const styleHeader = d.createElement('style');
                styleHeader.innerText = `.forceCommunityThemeHeaderBase .themeBgImage{
                    background: linear-gradient(to right, #213f98 10%, #1ea1a1 100%) !important;
                    display: block !important;
                }`;
                d.getElementsByTagName('head')[0].appendChild(styleHeader);
            }else{
                const styleHomeHeader = d.createElement('style');
                styleHomeHeader.innerText = `.forceCommunityThemeHeaderBase .themeBgImage{
                    display: none !important;
                }`;
                d.getElementsByTagName('head')[0].appendChild(styleHomeHeader);
            }
    
        }catch(e){
            console.log('Exception-->'+e);
        }
        
    }


    renderHero(){
        var d = document;
        const style1 = d.createElement('style');
        style1.innerText = `.forceCommunityThemeHeroBase{
            display: block !important;
        }`;
        d.getElementsByTagName('head')[0].appendChild(style1);
        
        const style = d.createElement('style');
        style.innerText = `.forceCommunityThemeHeroBase .content{
            display: block !important;
        }`;
        d.getElementsByTagName('head')[0].appendChild(style);

        const style3 = d.createElement('style');
        /*style3.innerText = `.forceCommunityThemeHeroBase .bgImage{
            background: linear-gradient(to right, #213f98 10%, #1ea1a1 100%) !important;
        }`;*/
        /*style3.innerText = `.forceCommunityThemeHeroBase .bgImage{
            background: linear-gradient(to right, #0077a0 10%, #00b5af 100%) !important;
        }`;*/
        style3.innerText = `.forceCommunityThemeHeroBase .bgImage{
            background: linear-gradient(to right, #213f98 10%, #1ea1a1 100%) !important;
        }`;
        d.getElementsByTagName('head')[0].appendChild(style3);
        

    }


    showWebchatContent(){
       window.postMessage(JSON.stringify({type: 'aisera.webchat.open'}))
    }
    
}