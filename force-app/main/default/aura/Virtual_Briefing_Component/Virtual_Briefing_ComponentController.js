({
    doInit: function (component, event, helper) {
        console.log('VBC doinit');
        
        if (component.get("v.recordId")) {
            
            console.log(component.get("v.recordId"));
            console.log(component.get("v.oppId"));
            console.log(component.get("v.accId"));
            component.set("v.isEdit", true);
            
            if (!component.get("v.oppId")) {
                component.set("v.proceedload", true);
            }
            if (component.get('v.accId')) {
                let contactfiltercriteria = 'Active__c = false and ';
                contactfiltercriteria += ' AccountId = \'' + component.get('v.accId') + '\'' ;
                component.set("v.contactfiltercriteria", contactfiltercriteria);
            }
            
        } else {
            component.set("v.isEdit", false);
            component.set("v.proceedload", true);
        }
        
        if (component.get('v.oppId') || component.get('v.accId')) {
            helper.populateOppdetails(component, event, helper, component.get('v.oppId'), false,component.get('v.accId'));
        }
        
        component.set("v.stepname", '1');
    },
    
    
    handleLoad: function (cmp, event, helper) {
        
        console.log('handleLoad called');
        
        cmp.set("v.showSpinner", false);
        
        if (!cmp.get("v.isEdit")) {
            helper.prepopulate(cmp, event, helper, false); 
        }
    },
    
    handleSubmit: function (component, event, helper) {  
        
        event.preventDefault();       // stop the form from submitting
        
        var fields = event.getParam('fields');
        var CurrentDate = new Date();
        var IsSuccess = true;
        
        var recordTypeId = component.get("v.recordTypeId");
        fields.RecordTypeId = recordTypeId;  
	        
        let oppRec = component.get("v.oppRec");
        //Commenting as per CR#1074
        /*if(oppRec.X3_Why__c == null || oppRec.X3_Why__c == ''){
            component.set("v.threeWhysError", true);
            IsSuccess=false;
        }else{
            component.set("v.threeWhysError", false);
        }*/
        
        //Days Difference should be minimum 14
        if(fields.Date_of_Meeting__c != null){
            var dom = $A.localizationService.formatDate(new Date(fields.Date_of_Meeting__c), "yyyy-MM-dd");
            var curDate =  $A.localizationService.formatDate(CurrentDate, "yyyy-MM-dd");
            
            const domDays = new Date(fields.Date_of_Meeting__c);
            const currDays = new Date();
            const diffTime = Math.abs(domDays - currDays);
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
            
            if(diffDays < 14){
                component.set("v.domValidationError",true);
                IsSuccess = false;
            }else{
                component.set("v.domValidationError",false);
            }
         }
        
        
       //Start time Validation
        if(component.get("v.StartTime") != null){
            var time = component.get("v.StartTime") + 'Z';
            fields.Start_Time__c = time;
            component.set("v.startTimeError",false);
        }else{
            
            component.set("v.startTimeError", true);
            IsSuccess=false;
            event.preventDefault();
        }
        
        //End time Validation
        if(component.get("v.EndTime") != null){
            var Endtime = component.get("v.EndTime") + 'Z';
            fields.End_Time__c = Endtime;
            component.set("v.endTimeError", false);
            
        }else{
            component.set("v.endTimeError", true);
            IsSuccess = false;
            event.preventDefault();
        }
        
        //Meeting time should not be less than 2 hrs
        if(component.get("v.StartTime") != null && component.get("v.EndTime") != null){
            var startTime = component.get("v.StartTime");
            var endTime = component.get("v.EndTime");
            var splittedStart = startTime.split(":");
            var splittedEnd = endTime.split(":");
            
            var startDateTime = new Date(null,null,null,splittedStart[0],splittedStart[1], null, null);
            var endDateTime = new Date(null,null,null,splittedEnd[0],splittedEnd[1], null, null);
            
            const startEndTimeDiff = Math.abs(endDateTime - startDateTime) / (1000 * 60 * 60);
            
            if(startEndTimeDiff < 2){
                component.set("v.timeDiffValidationError", true);
            	IsSuccess=false;    
            }else{
                component.set("v.timeDiffValidationError", false);
            }
           
            
        }
     	if(IsSuccess == true){
			//Submit the form
			component.find('execform').submit(fields);
		}
    },
    
    
    
    
    handleError: function (cmp, event, helper) {
        // errors are handled by lightning:inputField and lightning:nessages
        // so this just hides the spinnet
        cmp.set('v.showSpinner', false);
    },
    
    handleSuccess: function (cmp, event, helper) {
        var payload = event.getParams().response;
        console.log(payload.id);
        if (!cmp.get("v.recordId")) {
            cmp.set("v.recordId", payload.id);
            cmp.set("v.isEdit", true);
        }
        console.log(cmp.get("v.recordId"));
        cmp.set('v.showSpinner', false);
        cmp.set('v.stepname', '2');
    },
    pathstepchange: function (cmp, event, helper) {
        event.preventDefault();
        let prevstep = cmp.get('v.stepname');
        cmp.set('v.stepname', prevstep);
    },
    
    previous: function (cmp, event, helper) {
        let currstep = cmp.get('v.stepname');
        currstep = Number(currstep) - 1;
        cmp.set('v.errorMsg', '');
        cmp.set('v.stepname', String(currstep));
    },
    
    userchanged: function (cmp, event, helper) {
        let selItem = cmp.get("v.selItem");
        console.log('userchanged :: selItem::',cmp.get("v.selItem"));
        if(selItem){
            console.log(cmp.get("v.selItem")['rec']);
            let record = cmp.get("v.selItem")['rec'];
            if (record) {
                let userdetail = {
                    id: record['Id'],
                    name: record['Name'],
                    title: record['Title'],
                    email: record['Email']
                };
                console.log(userdetail);
                let userlst = [];
                userlst = cmp.get('v.userList'); 
                
                let found = false;
                if(userlst.some(user => user.email === userdetail.email)){
                    found = true;
                }            
                console.log('userchanged ::found ::',found);
                if(!found){      
                    userlst.push(userdetail);
                    console.log(userlst);
                }
                cmp.set("v.userList", userlst);
            }
        }
    },
    
    contactchanged: function (cmp, event, helper) {
        console.log(cmp.get("v.contactselecteditem")['rec']);
        let record = cmp.get("v.contactselecteditem")['rec'];
        if (record) {
            let contact = {
                id: record['Id'],
                name: record['Name'],
                title: record['Title'],
                email: record['Email']
            };
            console.log(contact);
            let headofitlst = cmp.get('v.headofitlst');
            let headofsecuritylst = cmp.get('v.headofsecuritylst');
            let headofnetworkinglst = cmp.get('v.headofnetworkinglst');
            let othercontactlst = cmp.get('v.othercontactlst');
            if (record['Head_of_IT__c']) {
                let donotadd = false;
                headofitlst.forEach(con => {
                    if (con.id == contact.id) {
                    donotadd = true;
                }
                                    });
                if (!donotadd) {
                    headofitlst.push(contact);
                }
                console.log(headofitlst);
            } else if (record['Head_of_Security__c']) {
                let donotadd = false;
                headofsecuritylst.forEach(con => {
                    if (con.id == contact.id) {
                    donotadd = true;
                }
                                          });
                if (!donotadd) {
                    headofsecuritylst.push(contact);
                }
                console.log(headofsecuritylst);
            } else if (record['Head_of_Networking__c']) {
                let donotadd = false;
                headofnetworkinglst.forEach(con => {
                    if (con.id == contact.id) {
                    donotadd = true;
                }
                                            });
                if (!donotadd) {
                    headofnetworkinglst.push(contact);
                }
                console.log(headofnetworkinglst);
            } else {
                let donotadd = false;
                othercontactlst.forEach(con => {
                    if (con.id == contact.id) {
                    donotadd = true;
                }
                                        });
                if (!donotadd) {
                    othercontactlst.push(contact);
                }
                console.log(othercontactlst);
            }
            cmp.set("v.headofitlst", headofitlst);
            cmp.set("v.headofsecuritylst", headofsecuritylst);
            cmp.set("v.headofnetworkinglst", headofnetworkinglst);
            cmp.set("v.othercontactlst", othercontactlst);
        }
    },
    
    saveinternalatt: function (cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        helper.saveinternalatt(cmp, event, helper);
    },
    
    saveexternalatt: function (cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        helper.saveexternalatt(cmp, event, helper);
    },
    
    cancel: function (cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        if (cmp.get('v.recordId')) {
            window.open('/' + cmp.get('v.recordId'), '_self');
        } else if (cmp.get('v.oppId')) {
            window.open('/' + cmp.get('v.oppId'), '_self');
        } else if (cmp.get('v.accId')) {
            window.open('/' + cmp.get('v.accId'), '_self');
        }
    },
    
    setMinEndTime :function(cmp, event, helper){
        cmp.set("v.startTimeError", false);
        let startTime =  event.getSource().get('v.value') + 'Z';
        cmp.set("v.minTime",  startTime);
    },
    
    setMaxStartTime :function(cmp, event, helper){
        cmp.set("v.endTimeError", false);
        let endTime =  event.getSource().get('v.value') + 'Z';
        cmp.set("v.maxTime",  endTime);
    },
    
    oppChanged: function(cmp, event, helper){
        cmp.set("v.oppId", event.getSource().get('v.value'));
        helper.populateOppdetails(cmp,event, helper, event.getSource().get('v.value'), true,cmp.get('v.accId'));
    },
    
    accountChanged: function(cmp, event, helper){
        console.log('AccountOnChange Called');
        cmp.set("v.accId", event.getSource().get('v.value'));
        helper.populateOppdetails(cmp,event, helper, cmp.get('v.oppId'), false,event.getSource().get('v.value'));
        helper.changecontactfilter(cmp,event, helper, event.getSource().get('v.value'));
    },
    
    
    
})