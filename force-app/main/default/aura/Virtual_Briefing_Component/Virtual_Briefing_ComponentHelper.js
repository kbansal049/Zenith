({
    processexistingintattendee: function (cmp, intatt) {
        if (intatt) {
            let usrlst = [];
            intatt.forEach(record => {
                let userdetail = {
                    id: record['User__c'],
                    name: record['User__r']['Name'],
                    title: record['User__r']['Title'],
                    email: record['User__r']['Email']
                };
                usrlst.push(userdetail);
            });
            cmp.set("v.userList", usrlst);
        }
    },
 
    processexistingextattendee: function (cmp, extatt) {
        if (extatt) {
            let headofitlst = [];
            let headofsecuritylst = [];
            let headofnetworkinglst = [];
            let othercontactlst = [];
            extatt.forEach(record => {
                let contact = {
                    id: record['Attendee__c'],
                    name: record['Attendee__r']['Name'],
                    title: record['Attendee__r']['Title'],
                    email: record['Attendee__r']['Email']
                };
                
                if (record['Attendee__r']['Head_of_IT__c']) {
                    headofitlst.push(contact);
                
                } else if (record['Attendee__r']['Head_of_Security__c']) {
                    headofsecuritylst.push(contact);
                
                } else if (record['Attendee__r']['Head_of_Networking__c']) {
                    headofnetworkinglst.push(contact);
                
                } else {
                    othercontactlst.push(contact);
                
                }
            });
            cmp.set("v.headofitlst", headofitlst);
            cmp.set("v.headofsecuritylst", headofsecuritylst);
            cmp.set("v.headofnetworkinglst", headofnetworkinglst);
            cmp.set("v.othercontactlst", othercontactlst);
        }
    },
    saveinternalatt: function (cmp, event, helper) {
        let userlst = cmp.get("v.userList");
        let action = cmp.get("c.saveintattendees");
        //console.log(userlst);
        if (userlst.length < 1) {
            cmp.set("v.errorMsg", 'Please add at least one Internal Attendee');
            cmp.set('v.showSpinner', false);
            return;
        } else {
            cmp.set('v.errorMsg', '');
        }
        action.setParams({
            userList: JSON.stringify(userlst),
            ebId: cmp.get('v.recordId')
        });
        action.setCallback(this, function (res) {
            if (res.getState() === 'SUCCESS') {
                cmp.set('v.stepname', '3');
                cmp.set('v.showSpinner', false);
            } else if (res.getState() === 'ERROR') {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
        
        
    saveexternalatt: function (cmp, event, helper) {
        let headofitlst = cmp.get('v.headofitlst');
        let headofsecuritylst = cmp.get('v.headofsecuritylst');
        let headofnetworkinglst = cmp.get('v.headofnetworkinglst');
        let othercontactlst = cmp.get('v.othercontactlst');
        let finalarr = [];
        finalarr = headofitlst.concat(headofsecuritylst, headofnetworkinglst, othercontactlst);
        console.log('finalarr :'+finalarr);
        if (finalarr.length < 1) {
            cmp.set("v.errorMsg", 'Please add at least one External Attendee');
            cmp.set('v.showSpinner', false);
            return;
        } else {
            cmp.set('v.errorMsg', '');
        }
        let action = cmp.get("c.saveextattendeesVBC");
        action.setParams({
            conlst: JSON.stringify(finalarr),
            ebId: cmp.get('v.recordId')
        });
        action.setCallback(this, function (res) {
            if (res.getState() === 'SUCCESS') {
                console.log('Entered Success');	
                window.open('/' + cmp.get('v.recordId'), '_self');
                cmp.set('v.errorMsg', '');
            } else if (res.getState() === 'ERROR') {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
        
        
    populateOppdetails: function (component, event, helper, oppId, oppchanged, AccId) {
        console.log('populateOppDetails Called :'+AccId+'  ----  '+oppId);
        
        let action = component.get("c.getVBCData");
        action.setParams({
            oppId: oppId,
            ebId: component.get('v.recordId'),
            AccountId : AccId
        });
        action.setCallback(this, function (res) {
            if (res.getState() === 'SUCCESS') {
                var retObj = res.getReturnValue();
                console.log('populateOppdetails ::',retObj);
                if (retObj) {
                    if (retObj.opp) {
                        component.set('v.oppRec', retObj.opp);
                    }
                    
                    if(retObj.AccountRec){
                        
                        component.set('v.AccountRec', retObj.AccountRec);
                        
                        let contactfiltercriteria = 'Active__c = false and ';
                        contactfiltercriteria += ' AccountId = \'' + retObj.AccountRec.Id + '\'' ;
                        console.log('contactfiltercriteria :'+contactfiltercriteria);
                        component.set("v.contactfiltercriteria", contactfiltercriteria);
                        
                        
                    }
    
                    if(retObj.EventBriefingReq != undefined){
                        if(retObj.EventBriefingReq.Start_Time__c != undefined){
                        	component.set("v.StartTime",new Date(retObj.EventBriefingReq.Start_Time__c).toISOString().substr(11, 8)+'.000Z');
                        }
                        
                        if(retObj.EventBriefingReq.End_Time__c != undefined){
                        	component.set('v.EndTime',new Date(retObj.EventBriefingReq.End_Time__c).toISOString().substr(11, 8)+'.000Z');
                        }
                    }
    
                    
                    this.processexistingintattendee(component, retObj.intAttlst);
                    this.processexistingextattendee(component, retObj.extAttlst);
                    if(oppchanged){
                        this.prepopulate(component, event, helper, oppchanged);
                    }
                }
            } else if (res.getState() === 'ERROR') {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
            component.set("v.proceedload", true);
        });
        $A.enqueueAction(action);
    },
        
    prepopulate: function (cmp, event, helper, oppchanged) {
        console.log('inside new rec pre pop');
        
        if (cmp.get('v.accId')) {
            cmp.find('accountval').set("v.value", cmp.get('v.accId'));
        }
        
        if (cmp.get('v.oppId')) {
            
            if (!cmp.find('accountval').get("v.value")) {
                if (cmp.get('v.accId')) {
                    cmp.find('accountval').set("v.value", cmp.get('v.accId'));
    
                } else if (cmp.get('v.oppRec') && cmp.get('v.oppRec')['AccountId']) {
                    cmp.find('accountval').set("v.value", cmp.get('v.oppRec')['AccountId']);
                    cmp.set('v.accId', cmp.get('v.oppRec')['AccountId']);
                }
                let contactfiltercriteria = 'Active__c = false and ';
                contactfiltercriteria += ' AccountId = \'' + cmp.get('v.accId') + '\'';
                cmp.set("v.contactfiltercriteria", contactfiltercriteria);
            }
        
            if (!cmp.find('oppIdval').get("v.value")) {
                cmp.find('oppIdval').set("v.value", cmp.get('v.oppId'));
            }
           
        }

        
    },
    changecontactfilter: function (cmp, event, helper, accId) {
        let contactfiltercriteria = 'Active__c = false and ';
        contactfiltercriteria += ' AccountId = \'' + accId + '\'';
        cmp.set("v.contactfiltercriteria", contactfiltercriteria);
    },
    
    
})