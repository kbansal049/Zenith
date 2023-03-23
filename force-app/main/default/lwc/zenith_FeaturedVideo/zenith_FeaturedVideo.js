import { LightningElement ,api, track} from 'lwc';
import zsResources from '@salesforce/resourceUrl/zScalarResources';
export default class Zenith_FeaturedVideo extends LightningElement {

    iconright = zsResources + '/zScalarResources/images/leftArrow.png';
    iconleft = zsResources + '/zScalarResources/images/rightArrow.png';


    @api title11;
    @api subtitl1;
    @api redirecturl1;

    @api title12;
    @api subtitl2;
    @api redirecturl2;

    @api title13;
    @api subtitl3;
    @api redirecturl3;

   
    connectedCallback(){
        this.redirecturl1=this.redirecturl1+'/?enablejsapi=1';
        this.redirecturl2=this.redirecturl2+'/?enablejsapi=1';
        this.redirecturl3=this.redirecturl3+'/?enablejsapi=1';
    }

    // renderedCallback(){
    //     this.title11=this.title11+'/?enablejsapi=1';
    //     this.title12=this.title12+'/?enablejsapi=1';
    //     this.title13=this.title13+'/?enablejsapi=1';
    // }


    
   videoPause='';

    handledot(event) {
        try {
            var clickVal = event.target.dataset.value;

            this.videoPause=this.template.querySelectorAll('iframe')

            console.log('******* vide pause ',this.videoPause)
            console.log('******* vide pause ',this.videoPause.length)
            for(let i=0;i<this.videoPause.length;i++){
                this.videoPause[i].contentWindow.postMessage('{"event":"command", "func":"stopVideo", "args":""}','*')
            }

            var divTranslate = this.template.querySelector('[data-target-id="panel"]').style.transform;
            if ((clickVal == 'id1' && divTranslate == 'translateX(-100%)')) {
                this.template.querySelectorAll('[data-target-id="panel"]').forEach(element => {
                    element.style.transform = '';
                })
                var d1 = this.template.querySelector('[data-target-id="dot1"]');
                d1.classList.add('sf_filldot');
                var d2 = this.template.querySelector('[data-target-id="dot2"]');
                d2.classList.remove('sf_filldot');
                var d3 = this.template.querySelector('[data-target-id="dot3"]');
                d3.classList.remove('sf_filldot');

            } else if (clickVal == 'id1' && divTranslate == 'translateX(-200%)') {
                this.template.querySelectorAll('[data-target-id="panel"]').forEach(element => {
                    element.style.transform = 'translateX(-100%)';
                })


                var d1 = this.template.querySelector('[data-target-id="dot1"]');
                d1.classList.remove('sf_filldot');
                var d2 = this.template.querySelector('[data-target-id="dot2"]');
                d2.classList.add('sf_filldot');
                var d3 = this.template.querySelector('[data-target-id="dot3"]');
                d3.classList.remove('sf_filldot');



            } else if (clickVal == 'id2' && (divTranslate == 'translateX(0%)' || divTranslate == '')) {
                this.template.querySelectorAll('[data-target-id="panel"]').forEach(element => {
                    element.style.transform = 'translateX(-100%)';
                })

                var d1 = this.template.querySelector('[data-target-id="dot1"]');
                d1.classList.remove('sf_filldot');
                var d2 = this.template.querySelector('[data-target-id="dot2"]');
                d2.classList.add('sf_filldot');
                var d3 = this.template.querySelector('[data-target-id="dot3"]');
                d3.classList.remove('sf_filldot');



            } else if ((clickVal == 'id2' && divTranslate == 'translateX(-100%)')) {
                this.template.querySelectorAll('[data-target-id="panel"]').forEach(element => {
                    element.style.transform = 'translateX(-200%)';
                })

                var d1 = this.template.querySelector('[data-target-id="dot1"]');
                d1.classList.remove('sf_filldot');
                var d2 = this.template.querySelector('[data-target-id="dot2"]');
                d2.classList.remove('sf_filldot');
                var d3 = this.template.querySelector('[data-target-id="dot3"]');
                d3.classList.add('sf_filldot');



            } else if ((clickVal == 'id1' && (divTranslate == 'translateX(0%)' || divTranslate == 'translateX(-100%)') || divTranslate == '')) {
                this.template.querySelectorAll('[data-target-id="panel"]').forEach(element => {
                    element.style.transform = 'translateX(-200%)';
                })

                var d1 = this.template.querySelector('[data-target-id="dot1"]');
                d1.classList.remove('sf_filldot');
                var d2 = this.template.querySelector('[data-target-id="dot2"]');
                d2.classList.remove('sf_filldot');
                var d3 = this.template.querySelector('[data-target-id="dot3"]');
                d3.classList.add('sf_filldot');



            } else if ((clickVal == 'id2' && divTranslate == 'translateX(-200%)')) {
                this.template.querySelectorAll('[data-target-id="panel"]').forEach(element => {
                    element.style.transform = '';
                })

                var d1 = this.template.querySelector('[data-target-id="dot1"]');
                d1.classList.add('sf_filldot');
                var d2 = this.template.querySelector('[data-target-id="dot2"]');
                d2.classList.remove('sf_filldot');
                var d3 = this.template.querySelector('[data-target-id="dot3"]');
                d3.classList.remove('sf_filldot');


            }
            //  divTranslate = 'translateX(0%)';
        } catch (error) {
            console.log('Error:', error);
        }
    }



}