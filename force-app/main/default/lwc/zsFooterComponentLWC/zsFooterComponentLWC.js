import { api, LightningElement, wire } from 'lwc';
import social_icons from '@salesforce/resourceUrl/Social_Icons';
import fetchFooterLabels from '@salesforce/apex/Zenith_FooterClass.fetchFooterLabels';
export default class ZsFooterComponentLWC extends LightningElement {
    fbLogo = social_icons + '/Social_Icons/Facebook.png';
    linkedInLogo = social_icons + '/Social_Icons/Linkedin.png';
    twitterLogo = social_icons + '/Social_Icons/Twitter.png';
    ytLogo = social_icons + '/Social_Icons/Youtube.png';

    fetchFooter;
    @api facebook;
    @api linkedIn;
    @api twitter;
    @api youTube;
    @api privacyUrl;
    @api termsUrl;
    @api aboutUrl;
    @api faqUrl;
    
    connectedCallback(){
        console.log('Privacy Url ---> ', this.privacyUrl);
        if(this.privacyUrl == null || this.privacyUrl == undefined || this.privacyUrl == ''){
            this.privacyUrl = 'https://community.zscaler.com/privacy';
            console.log('If privacy ---> ', this.privacyUrl);
        }
        if(this.facebook == null || this.facebook == '' || this.facebook == undefined){
            this.facebook = 'https://www.facebook.com/Zscaler';
        }
        if(this.linkedIn == null || this.linkedIn == '' || this.linkedIn == undefined){
            this.linkedIn = 'https://www.linkedin.com/company/zscaler/';
        }
        if(this.twitter == null || this.twitter == '' || this.twitter == undefined){
            this.twitter = 'https://twitter.com/zscaler';
        }
        if(this.youTube == null || this.youTube == '' || this.youTube == undefined){
            this.youTube = 'https://www.youtube.com/user/ZscalerMarketing';
        }
        if(this.termsUrl == null || this.termsUrl == '' || this.termsUrl == undefined){
            this.termsUrl="https://community.zscaler.com/tos";
        }
        if(this.faqUrl == null || this.faqUrl == '' || this.faqUrl == undefined){
            this.faqUrl = 'https://community.zscaler.com/faq';
        }
        if(this.aboutUrl == null || this.aboutUrl == '' || this.aboutUrl == undefined){
            this.aboutUrl = 'https://community.zscaler.com/about';
        }
    }
    
    @wire(fetchFooterLabels)
    wiredFlows({ error, data }) {
        if (data) {
            this.fetchFooter = data.desktopLabels;
            console.log('check ----> ', this.fetchFooter);
        }
    }

    scrollToTop(event){
        console.log('Top clicked');
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    }


}