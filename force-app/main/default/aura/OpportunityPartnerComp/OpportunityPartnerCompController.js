({
    doInit: function (component, event, helper) {
        component.set("v.isDealReg", false);
        component.set("v.isReseller", false);
        helper.checkDealPermission(component, event, helper);
        helper.GetOppPartnersList(component, event, helper);
        helper.GetOppDetails(component, event, helper);
        helper.AddRowHelper(component, event, helper);
    },

    AddRow: function (component, event, helper) {
        helper.AddRowHelper(component, event, helper);
    },

    reloadcomp: function (component, event, helper) {
        helper.GetOppPartnersList(component, event, helper);
    },

    AddNewReseller: function (component, event, helper) {
         component.set("v.isDealReg", false);
		 component.set("v.isReseller", true);
        
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
			'PartnerRole': '',
			'PartnerProgram': '',
            'PartnerIncentiveId' : '',
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again   
        component.set("v.IsAddNewPartner", true); 
        component.set("v.IsTechPartner", false);	
        var Type = 'Reseller';	
        var isFederal = component.get("v.isFederal");	
        if(isFederal){	
            Type = 'FederalReseller';
        }
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.PartnerType", Type);
    },

    AddNewTechPartner: function (component, event, helper) {
         component.set("v.isDealReg", false);
		 component.set("v.isReseller", false);
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
			'PartnerRole': '',
			'PartnerProgram': '',
            'PartnerIncentiveId':'',
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        component.set("v.IsTechPartner", true);
        var Type = 'Tech Partner';
        component.set("v.PartnerType", Type);
    },

    AddNewIntegrator: function (component, event, helper) {
         component.set("v.isDealReg", false);
		 component.set("v.isReseller", false);
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
			'PartnerRole': '',
			'PartnerProgram': '',
            'PartnerIncentiveId':'',
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        component.set("v.IsTechPartner", false);
        var Type = 'System Integrator';
        component.set("v.PartnerType", Type);
    },
	//IBA-4762 -Start
    AddNewFederalSysIntegrator: function (component, event, helper) {
        component.set("v.isDealReg", false);
        component.set("v.isReseller", false);
       var RowItemList = [];
       RowItemList.push({
           'SelectedRecord': null,
           'PartnerRole': '',
           'PartnerProgram': '',
           'PartnerIncentiveId':'',
           'IsRadioChecked': false
       });
       // set the updated list to attribute (contactList) again    
       component.set("v.WrapperList", RowItemList);
       component.set("v.showErrors", false);
       component.set("v.showMainErrors", false);
       component.set("v.errorMessage", '');
       component.set("v.IsAddNewPartner", true);
       component.set("v.IsTechPartner", false);
       var Type = 'Federal System Integrator';
       component.set("v.PartnerType", Type);
   },
   //IBA-4762 -End
    AddNewDistributor: function (component, event, helper) {
         component.set("v.isDealReg", false);
		 component.set("v.isReseller", false);
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
			'PartnerRole': '',
			'PartnerProgram': '',
            'PartnerIncentiveId':'',
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        component.set("v.IsTechPartner", false);
        var Type = 'Distributor';
        component.set("v.PartnerType", Type);
    },

   

    AddNewArch: function (component, event, helper) {
         component.set("v.isDealReg", false);
		 component.set("v.isReseller", false);
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
			'PartnerRole': '',
			'PartnerProgram': '',
            'PartnerIncentiveId':'',
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        component.set("v.donotshownewRow", true);
        component.set("v.IsTechPartner", false);
        var Type = 'Architecture Workshop';
        component.set("v.PartnerType", Type);
    },

    AddNewPOV: function (component, event, helper) {
         component.set("v.isDealReg", false);
		 component.set("v.isReseller", false);
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
			'PartnerRole': '',
			'PartnerProgram': '',
            'PartnerIncentiveId':'',
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        component.set("v.IsTechPartner", false);
        component.set("v.donotshownewRow", true);
        var Type = 'POV';
        component.set("v.PartnerType", Type);
    },
	//CR#3744 Start
	AddNewProfessionalServices: function (component, event, helper) {
         component.set("v.isDealReg", false);
		 component.set("v.isReseller", false);
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
			'PartnerRole': '',
			'PartnerProgram': '',
            'PartnerIncentiveId':'',
            'IsRadioChecked': false
        });    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        component.set("v.IsTechPartner", false);
        var Type = 'Professional Services';
        component.set("v.PartnerType", Type);
    },
	//CR#3744 ENd

    closeModel: function (component, event, helper) {
        component.set("v.IsPrimary", false);
        component.set("v.SelectedRecord", null);
        component.set("v.IsAddNewPartner", false);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.donotshownewRow", false);
		component.set('v.isPartnerProgramSelect',false);
		component.set('v.isPartnerProgramChange',false);
		component.set('v.isDisabled',false);
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
			'PartnerRole': '',
			'PartnerProgram': '',
            'PartnerIncentiveId':'',
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        console.log(component.get("v.WrapperList"));
    },

    DeleteRecord: function (component, event, helper) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        var result = confirm("Want to delete?");
        if (result) {
            var OptyId = component.get("v.OppId");
            var selectedItem = event.currentTarget;
            var OppPartnerId = selectedItem.dataset.variablename;
            //alert('--Partner Id--'+OppPartnerId);
            var action = component.get("c.DeletePartnerRec");
            action.setParams({
                'PartnerId': OppPartnerId
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                component.find("Id_spinner").set("v.class", 'slds-hide');
                if (state === "SUCCESS") {
                    var ResultMap = response.getReturnValue();
                    if (ResultMap.State == 'Success') {
                        component.find("Custtoast").showToastModel(ResultMap.Message, 'success');
                        //location.reload();
                        component.set("v.IsAddNewPartner", false);
                        helper.GetOppPartnersList(component, event, helper);
                        //window.open('/'+OptyId, '_parent');
                    } else {
                        component.find("Custtoast").showToastModel(ResultMap.Message, 'error');
                    }
                }
                else if (state === "INCOMPLETE") {
                    //alert('Response is Incompleted');
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " +
                                errors[0].message);
                        }
                    }
                    else {
                        alert("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            component.find("Id_spinner").set("v.class", 'slds-hide');
        }

    },

    SaveDetails: function (component, event, helper) {
       // alert("Deal Reg?"+component.get("v.isDealReg"));
        //alert(JSON.stringify(component.get("v.WrapperListDeal")));
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.find("Id_spinner").set("v.class", 'slds-show');
        var PartnerType = component.get("v.PartnerType");
        var OptyId = component.get("v.OppId");
        var IsSave = true;
        var WrapperList;
		if(component.get('v.isPartnerProgramSelect') == true){
			var element = component.find("partnerData");
			document.getElementById("partnerProgramErrorMsg").style.display = "flex";
			///$A.util.addClass(element, 'slds-scope slds-has-error');
			component.set('v.isDisabled',true);
			component.find("Id_spinner").set("v.class", 'slds-hide');
		}
        WrapperList = component.get("v.WrapperList");
        if(component.get("v.isDealReg")){
            WrapperList = component.get("v.WrapperListDeal");
        }
        
        if (WrapperList.length > 0) {
            for (var indexVar = 0; indexVar < WrapperList.length; indexVar++) {
                if (!component.get("v.isDealReg") && WrapperList[indexVar].SelectedRecord == null) {
                    IsSave = false;
                }
                else if(component.get("v.isDealReg") && WrapperList[indexVar].SelectedDealRec == null){
                    IsSave = false;
                }
            }
            /*//Added by Priyanka - start
            if(component.get("v.isDealReg")){
                var count = 0;
                for (var indexVar = 0; indexVar < component.get("v.WrapperListDeal").length; indexVar++) {
                    if (component.get("v.WrapperListDeal")[indexVar].SelectedDealRec != null) {
                        count++;
                    }
                }
                //alert('count::'+count);
                if(count == 0)
                    IsSave = false;
                else
                    IsSave = true;
            }
            //alert('IsSave::'+IsSave);
            //Added by Priyanka - End*/
            //alert('wrpr::'+JSON.stringify(component.get("v.WrapperListDeal")));
            if(IsSave == true){
                if(component.get("v.isDealReg")){
                    // Save Deal Reg
                    var action = component.get("c.SaveDealRec");
                    action.setParams({
                        'OppId': OptyId,
                        'dealRecId': component.get("v.WrapperListDeal")[0].SelectedDealRec.Id
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    component.find("Id_spinner").set("v.class", 'slds-hide');
                    if (state === "SUCCESS") {
                        var ResultMap = response.getReturnValue();
                        //alert("ResultMap"+JSON.stringify(ResultMap));
                        if (ResultMap.State == 'Success') {
                            component.find("Custtoast").showToastModel(ResultMap.Message, 'success');
                            //location.reload();
                            component.set("v.IsAddNewPartner", false);
                            component.set("v.donotshownewRow", false);
                            //helper.GetOppDealList(component, event, helper);
                            helper.GetOppPartnersList(component, event, helper);
                            //window.open('/'+OptyId, '_parent');
                        } else if (ResultMap.State == 'Validation') {
                            component.set("v.showErrors", true);
                            component.set("v.errorMessage", ResultMap.Message);
                        }
                        else {
                            component.find("Custtoast").showToastModel(ResultMap.Message, 'Error');
                        }
                    }
                    else if (state === "INCOMPLETE") {
                        component.set("v.showErrors", true);
                        component.set("v.errorMessage", 'Response is Incompleted');
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            let message = '';
                            if (errors[0] && errors[0].message) {
                                message = errors[0].message;

                            } else if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0] && errors[0].pageErrors[0].message) {
                                message = errors[0].pageErrors[0].message;
                            }
                            component.set("v.showErrors", true);
                            component.set("v.errorMessage", message);

                        }
                        else {
                            alert("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
                } else{                    
                var action = component.get("c.SavePartnerRec");
                action.setParams({
                    'OppId': OptyId,
                    'PartnerRecords': JSON.stringify(component.get("v.WrapperList")),
                    'PartnerType': PartnerType
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    component.find("Id_spinner").set("v.class", 'slds-hide');
                    if (state === "SUCCESS") {
                        var ResultMap = response.getReturnValue();
                        if (ResultMap.State == 'Success') {
                            component.find("Custtoast").showToastModel(ResultMap.Message, 'success');
                            //location.reload();
                            component.set("v.IsAddNewPartner", false);
                            component.set("v.donotshownewRow", false);
                            helper.GetOppPartnersList(component, event, helper);
                            //window.open('/'+OptyId, '_parent');
                        } else if (ResultMap.State == 'Validation') {
                            component.set("v.showErrors", true);
                            component.set("v.errorMessage", ResultMap.Message);
                        }
                        else {
                            component.find("Custtoast").showToastModel(ResultMap.Message, 'error');
                        }
                    }
                    else if (state === "INCOMPLETE") {
                        component.set("v.showErrors", true);
                        component.set("v.errorMessage", 'Response is Incompleted');
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            let message = '';
                            if (errors[0] && errors[0].message) {
                                message = errors[0].message;

                            } else if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0] && errors[0].pageErrors[0].message) {
                                message = errors[0].pageErrors[0].message;
                            }
                            component.set("v.showErrors", true);
                            component.set("v.errorMessage", message);

                        }
                        else {
                            alert("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
                }
            } else {
                component.find("Id_spinner").set("v.class", 'slds-hide');
                component.set("v.showErrors", true);
                if(component.get("v.isDealReg")){
                component.set("v.errorMessage", 'Please Select Deal Registration');
                }else{
                  component.set("v.errorMessage", 'Please Select account');  
                }
            }
        } else {
            component.find("Id_spinner").set("v.class", 'slds-hide');
            component.set("v.showErrors", true);
            component.set("v.errorMessage", 'Please Select atleast one record');
        }
    },

    ChangeSelected: function (component, event, helper) {
        //alert('--changed--'+event.getSource().get("v.text"));
        var index = event.getSource().get("v.text");
        var WrapperList = component.get("v.WrapperList");
        for (var indexVar = 0; indexVar < WrapperList.length; indexVar++) {
            if (indexVar == index) {
                //alert(WrapperList[indexVar].IsRadioChecked);
                if (!WrapperList[indexVar].IsRadioChecked) {
                    WrapperList[indexVar].IsRadioChecked = true;
                } else {
                    WrapperList[indexVar].IsRadioChecked = false;
                }
            } else {
                WrapperList[indexVar].IsRadioChecked = false;
            }
        }
        component.set("v.WrapperList", WrapperList);
        //alert('--list--'+JSON.stringify(WrapperList));
    },

    removeRow: function (component, event, helper) {
        var Index = event.target.dataset.id;
        //alert('--index--'+Index);
        var WrapperList = component.get("v.WrapperList");
        WrapperList.splice(Index, 1);
        component.set("v.WrapperList", WrapperList);
        helper.resetAllValues(component,event,helper);
    },

    ChangeResellerPrimary: function (component, event, helper) {
        var PartnerId = event.getSource().get("v.text");
        //alert('---PartnerId--'+PartnerId);
        helper.UpdatePartner(component, event, helper, PartnerId, 'Reseller');
    },
    editPartner: function (component, event, helper) {
        let partId = event.getSource().get("v.title");
        component.set("v.partnerid", partId);
        component.set("v.editMode", true);
    },
    /*savePartnerProgram: function (component, event, helper) {
        let partId = event.getSource().get("v.title");
        let selectedVal = event.getSource().get("v.value");
        helper.savePartnerProgramforPrimaryPartner(component, event, helper, partId, selectedVal);

    },*/

    ChangeTechPrimary: function (component, event, helper) {
        var PartnerId = event.getSource().get("v.text");
	    /*var selected = !event.getSource().get("v.value");
	    //alert('---PartnerId--'+PartnerId);
	    if(selected){ */
        helper.UpdatePartner(component, event, helper, PartnerId, 'Tech Partner');
	    /*}else{
	        helper.RemovePrimaryPartner(component, event, helper, PartnerId, 'Tech Partner');
	    }*/
    },

    ChangeSysIntegratorPrimary: function (component, event, helper) {
        var PartnerId = event.getSource().get("v.text");
        var selected = !event.getSource().get("v.value");
        //alert('---PartnerId--'+PartnerId);
        if (selected) {
            helper.UpdatePartner(component, event, helper, PartnerId, 'System Integrator');
        } else {
            helper.RemovePrimaryPartner(component, event, helper, PartnerId, 'System Integrator');
        }
    },
    //IBA-4762 -START
    ChangeFederalSysIntegratorPrimary: function (component, event, helper) {
        var PartnerId = event.getSource().get("v.text");
        var selected = !event.getSource().get("v.value");
        //alert('---PartnerId--'+PartnerId);
        if (selected) {
            helper.UpdatePartner(component, event, helper, PartnerId, 'Federal System Integrator');
        } else {
            helper.RemovePrimaryPartner(component, event, helper, PartnerId, 'Federal System Integrator');
        }
    },
    //IBA-4762 -End
    ChangeDistributorPrimary: function (component, event, helper) {

        var PartnerId = event.getSource().get("v.text");
        var selected = !event.getSource().get("v.value");
        //alert('selected' + selected+'----PartnerId----'+PartnerId);

        //alert('---PartnerId--'+PartnerId);
        if (selected) {
            helper.UpdatePartner(component, event, helper, PartnerId, 'Distributor');
        } else {
            helper.RemovePrimaryPartner(component, event, helper, PartnerId, 'Distributor');
        }
    },
    
    //CR# 3744 Start
    ChangeProfessionalservicePrimary: function (component, event, helper) {
        /*var PartnerId = event.getSource().get("v.text");
        var selected = !event.getSource().get("v.value");
        //alert('---PartnerId--'+PartnerId);
        if (selected) {
            helper.UpdatePartner(component, event, helper, PartnerId, 'Professional Services');
        } else {
            helper.RemovePrimaryPartner(component, event, helper, PartnerId, 'Professional Services');
        }*/
        var PartnerId = event.getSource().get("v.text");
        //alert('---PartnerId--'+PartnerId);
        helper.UpdatePartner(component, event, helper, PartnerId, 'Professional Services');
    },
    //CR# 3744 End
    /* Priyanka - AddNewDealReg*/ 
     addDealReg: function (component, event, helper) {
         component.set("v.isDealReg", true);
		 component.set("v.isReseller", false);
         //alert(component.get("v.isDealReg"));
        var RowItemList = [];
        RowItemList.push({
            'SelectedDealRec': null,
            'PartnerRole': '',
			'PartnerProgram': '',
            'PartnerIncentiveId':'',
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperListDeal", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        component.set("v.donotshownewRow", true);
        var Type = 'Deal Reg';
        component.set("v.PartnerType", '');
    },
    
    /* Chandan Panigrahy for CR# 2153 START */
    handleRerenderAvailableTeamingTechPartner: function(component, event, helper) {
        console.log('-=-- Inside aura controller -=- ');
        helper.handleRerenderAvailableTeamingTechPartnerHelper(component, event, helper);
        helper.GetOppPartnersList(component, event, helper);
        
    },
  	/* Chandan Panigrahy for CR# 2153 END */
    
    /* Swathi for IBA - 1600 START */
    handleRerenderAvailableImpactPartner: function(component, event, helper) {
        console.log('-=-- Inside aura controller -=- ');
        helper.handleRerenderAvailableImpactPartnerHelper(component, event, helper);
        helper.GetOppPartnersList(component, event, helper);
        
    },
  	/* Swathi for IBA - 1600 END */  
    
    onSelectPartnerProgram: function (component, event, helper) {
        console.log('inside onSelectPartnerProgram',event.currentTarget.getAttribute('data-accountId'));
        var accId = event.currentTarget.getAttribute('data-accountId');
        var oppPartId = event.currentTarget.getAttribute('data-recordId');
        component.set('v.selectedPartner',oppPartId);
        var optyId = component.get("v.OppId");
        console.log('accId',accId,'optyId',optyId);
		var keyIndex;
		var changePartnerProgram = 'true';
        helper.getPartnerInfo(component,event,helper,accId,keyIndex,changePartnerProgram);
    },
    
    cancel : function(component, event, helper) {
		component.set('v.isPartnerProgramSelect',false);
		component.set('v.isPartnerProgramChange',false);
		var keyIndex = component.get("v.currentIndex");
        console.log('in cancel',keyIndex);
        helper.resetAllValues(component,event,helper);
        helper.clearLookup(component,event,helper,keyIndex);        
    },
    
    getSelectedName:function(component, event, helper) {
        var selRow = event.getParam("selectedRows");
        console.log('selectedrows',selRow);
        component.set('v.selectedRows',selRow);
        console.log('document.getElementById("partnerProgramErrorMsg")',document.getElementById("partnerProgramErrorMsg"));
        if(document.getElementById("partnerProgramErrorMsg") != null){
        	document.getElementById("partnerProgramErrorMsg").style.display = "none";
        }if(document.getElementById("partnerProgramErrorMsgs") != null){
        	document.getElementById("partnerProgramErrorMsgs").style.display = "none";
        }
        
        if(component.get('v.isPartnerProgramSelect') == true){
            console.log('name',selRow[0].Partner_Program__c);
            var WrapperList = component.get("v.WrapperList");
            var keyIndex = component.get("v.currentIndex");
            for (var indexVar = 0; indexVar < WrapperList.length; indexVar++) {
                if (indexVar == keyIndex) {
                    console.log('in 548');
                    WrapperList[indexVar].PartnerRole = selRow[0].Partner_Role__c;
                    WrapperList[indexVar].PartnerProgram = selRow[0].Partner_Program__c;
                    WrapperList[indexVar].PartnerIncentiveId = selRow[0].Id;
                    break;
                }
            }
            component.set("v.WrapperList", WrapperList);
            component.set('v.isPartnerProgramSelect',false);
            component.set('v.isDisabled',false);
            //component.set('v.donotshownewRow',false);
            helper.resetAllValues(component,event,helper);
        }
    },
  
	savePartnerChange: function (component, event, helper) {
        var selRow = [];
        selRow = component.get('v.selectedRows');
        if(selRow == '' || selRow == 'undefined' || selRow == null){
            console.log('document.getElementById("partnerProgramErrorMsgs")',document.getElementById("partnerProgramErrorMsgs"));
            document.getElementById("partnerProgramErrorMsgs").style.display = "flex";
        }else{
            document.getElementById("partnerProgramErrorMsgs").style.display = "none";
            console.log('name',selRow[0].Partner_Program__c);
            component.set('v.selectedIncentive',selRow[0].Id);
            var partId = component.get('v.selectedPartner');
            var selectedVal = selRow[0].Partner_Program__c;
            var incentive = component.get('v.selectedIncentive');
            helper.savePartnerProgramforPrimaryPartner(component, event, helper, partId, selectedVal, incentive);
            component.set('v.isPartnerProgramChange',false);
            helper.resetAllValues(component,event,helper);
        }
    },
    
	handleLookupIdUpdate: function (component, event, helper) {
		console.log(event.getParam("instanceId"));
        console.log(event.getParam("sObjectId"));
		var accId = event.getParam("sObjectId");
		var keyIndex = event.getParam("index");
        console.log('keyIndex',keyIndex);
		var changePartnerProgram = 'false';
		if(event.getParam("instanceId") == 'resellerLookup' && accId.startsWith("001")){
			helper.getPartnerInfo(component,event,helper,accId,keyIndex,changePartnerProgram);			
		}
	},
    
	handleLookupIdClear: function (component, event, helper) {
		console.log(event.getParam("instanceId"));
        var keyIndex = event.getParam("index");
        var keyInstance = event.getParam("instanceId");
        if(keyInstance == 'resellerLookup'){
        	helper.clearLookup(component, event, helper,keyIndex);
        }
	},
})