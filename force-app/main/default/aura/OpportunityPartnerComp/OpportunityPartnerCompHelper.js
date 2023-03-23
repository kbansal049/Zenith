({
    GetOppPartnersList: function (component, event, helper) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        var OpportunityId = component.get("v.OppId");
        if (OpportunityId != undefined) {
            var action = component.get("c.GetOppPartnersDetais");
            action.setParams({
                'OppId': OpportunityId
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                component.find("Id_spinner").set("v.class", 'slds-hide');
                if (state === "SUCCESS") {
                    var InnerRecord = response.getReturnValue();
                    component.set("v.OppPartnersList", InnerRecord.PartnersList);
                    component.set("v.IsResellerPresent", InnerRecord.IsResellerPresent);
                    component.set("v.IsTechPartnerPresent", InnerRecord.IsTechPartnerPresent);
                    component.set("v.IsEventTechPartnerPresent", InnerRecord.IsEventTechPartnerPresent);
                    component.set("v.IsIntegratorPresent", InnerRecord.IsIntegratorPresent);
                    component.set("v.IsFederalSysIntegratorPresent", InnerRecord.IsFederalSysIntegratorPresent);
                    component.set("v.IsDistributorPresent", InnerRecord.IsDistributorPresent);
                    component.set("v.isDealRegPresent", InnerRecord.isDealRegPresent);
                    component.set("v.isPOVPresent", InnerRecord.isPOVPresent);
                    component.set("v.isArchWorkshopPresent", InnerRecord.isArchPresent);
                    component.set("v.isAWPOVPresent", InnerRecord.isAWPOVPresent);//CR# 2556 - Added by Ritesh
                    component.set("v.showEditandDelete", InnerRecord.showEditandDelete);
                    component.set("v.isAdmin", InnerRecord.isAdmin);
                    component.set("v.PartnerProgramMap", InnerRecord.partnerProgramPickvals);
                    component.set("v.isFederal", InnerRecord.isFederal);
                    component.set("v.isFederalNew",InnerRecord.isFederalNew);
                    component.set("v.showAddNewDistibutor",InnerRecord.showAddNewDistibutor);
                    component.set("v.showAddNewFedSysIntegrator",InnerRecord.showAddNewFedSysIntegrator);
                    component.set("v.IsProfessionalServicePresent", InnerRecord.IsProfessionalServicePresent); //CR#3744
                    component.set("v.IsImpactPartnerPresent", InnerRecord.IsImpactPartnerPresent);
                    component.set("v.notShowAddNewImpactPartner", InnerRecord.notShowAddNewImpactPartner);
                    if(InnerRecord.isFederalNew || InnerRecord.showAddNewDistibutor){
                        component.set("v.isDistributorDisabled",false);
                    }
                    //component.set("v.isGoBackToOpportunity",InnerRecord.isPartnerProgramSelected);
					//console.log('v.isGoBackToOpportunity',component.get('v.isGoBackToOpportunity'));
                    for (let rec in InnerRecord.PartnersList) {
                        if (InnerRecord.PartnersList[rec].Partner_Type__c == 'Deal Reg') {
                            component.set("v.dealRegrec", InnerRecord.PartnersList[rec]);
                        }
                        if (InnerRecord.PartnersList[rec].Partner_Type__c == 'Architecture Workshop') {
                            component.set("v.archWorkshoprec", InnerRecord.PartnersList[rec]);
                        }
                        if (InnerRecord.PartnersList[rec].Partner_Type__c == 'POV') {
                            component.set("v.POVrec", InnerRecord.PartnersList[rec]);
                        }
                        //CR# 2556 - Added by Ritesh
                        if (InnerRecord.PartnersList[rec].Partner_Type__c == 'AW/POV') {
                            component.set("v.AWPOVrec", InnerRecord.PartnersList[rec]);
                        }
                    }
                }
                else if (state === "INCOMPLETE") {
                    alert('Response is Incompleted');
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
        }
    },
    
    checkDealPermission : function(component, event, helper){
        component.find("Id_spinner").set("v.class", 'slds-show');
        var action = component.get("c.checkAddDealPermission");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var addDealAccesss = response.getReturnValue();
                component.set("v.haveAddDealAccess",addDealAccesss);
                component.find("Id_spinner").set("v.class", 'slds-hide');
            }
            else{
                component.find("Id_spinner").set("v.class", 'slds-hide');
                console.log('Error occured while checking Add Deal Permission');
            }
            
        });
        $A.enqueueAction(action);
    },

    GetOppDetails: function (component, event, helper) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        var OpportunityId = component.get("v.OppId");
        if (OpportunityId != undefined) {
            var action = component.get("c.GetOpportunity");
            action.setParams({
                'OppId': OpportunityId
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                component.find("Id_spinner").set("v.class", 'slds-hide');
                if (state === "SUCCESS") {
                    var Opportunity = response.getReturnValue();
                    component.set("v.OppRecord", Opportunity);

                    if (Opportunity.Region_Account__c == 'Federal' || ( Opportunity.Account.Is_Federal_Account_Sync__c != null && Opportunity.Account.Is_Federal_Account_Sync__c == true)) {
                        component.set("v.opportunityArea", 'Federal Distributor');
                    }
                }
                else if (state === "INCOMPLETE") {
                    alert('Response is Incompleted');
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
        }
    },

    AddRowHelper: function (component, event, helper) {
        var RowItemList = component.get("v.WrapperList");
        RowItemList.push({
            'SelectedRecord': null,
            'PartnerRole': '',
			'PartnerProgram': '',
            'PartnerIncentiveId':'',
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
    },
    savePartnerProgramforPrimaryPartner: function (component, event, helper, PartnerId, PartProg, incentive) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        console.log('incentive',incentive,'PartProg',PartProg,'PartnerId',PartnerId);
        var action = component.get("c.updatePartnerProgram");
        action.setParams({
            'PartnerId': PartnerId,
            'Program': PartProg,
            'OppId': component.get("v.OppId"),
            'incentiveId' : incentive
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            component.find("Id_spinner").set("v.class", 'slds-hide');
            if (state === "SUCCESS") {
                var ResultMap = response.getReturnValue();
                if (ResultMap.State == 'Success') {
                    component.find("Custtoast").showToastModel(ResultMap.Message, 'success');
                    helper.GetOppPartnersList(component, event, helper);
                    component.set("v.partnerid", '');
                    component.set("v.editMode", false);
                }
                else if (ResultMap.State == 'Validation') {
                    component.set("v.showMainErrors", true);
                    component.set("v.errorMessage", ResultMap.Message);
                    helper.GetOppPartnersList(component, event, helper);
                }
                else {
                    component.find("Custtoast").showToastModel(ResultMap.Message, 'Error');
                }
            }
            else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
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
    },

    UpdatePartner: function (component, event, helper, PartnerId, Type) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        var OptyId = component.get("v.OppId");
        var action = component.get("c.UpdatePrimaryPartner");
        action.setParams({
            'PartnerId': PartnerId,
            'Type': Type,
            'OppId': OptyId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            component.find("Id_spinner").set("v.class", 'slds-hide');
            if (state === "SUCCESS") {
                var ResultMap = response.getReturnValue();
                if (ResultMap.State == 'Success') {
                    console.log(ResultMap.State);
                    component.find("Custtoast").showToastModel(ResultMap.Message, 'success');
                    helper.GetOppPartnersList(component, event, helper);
                }
                else if (ResultMap.State == 'Validation') {
                    console.log(ResultMap.State);
                    component.set("v.showMainErrors", true);
                    component.set("v.errorMessage", ResultMap.Message);
                    helper.GetOppPartnersList(component, event, helper);
                }
                else {
                    console.log(ResultMap.State);
                    component.find("Custtoast").showToastModel(ResultMap.Message, 'Error');
                }
            }
            else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
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
    },

    RemovePrimaryPartner: function (component, event, helper, PartnerId, Type) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        var OptyId = component.get("v.OppId");
        var action = component.get("c.UuncheckPrimaryPartner");
        action.setParams({
            'PartnerId': PartnerId,
            'Type': Type,
            'OppId': OptyId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            component.find("Id_spinner").set("v.class", 'slds-hide');
            if (state === "SUCCESS") {
                var ResultMap = response.getReturnValue();
                if (ResultMap.State == 'Success') {
                    component.find("Custtoast").showToastModel(ResultMap.Message, 'success');
                    helper.GetOppPartnersList(component, event, helper);
                }
                else if (ResultMap.State == 'Validation') {
                    component.set("v.showMainErrors", true);
                    component.set("v.errorMessage", ResultMap.Message);
                    helper.GetOppPartnersList(component, event, helper);
                }
                else {
                    component.find("Custtoast").showToastModel(ResultMap.Message, 'Error');
                }
            }
            else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
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
    },
    getPartnerInfo : function(component,event,helper,accId,keyIndex,changePartnerProgram) { 
        console.log('inside getPartnerInfo');
        var action = component.get('c.loadPartnerIncentiveData');
        action.setParams({ 
            accountId : accId,
            opportunityId : component.get('v.OppId'),
            showAllIncentives : component.get('v.isAdmin')
        });
        action.setCallback(this, function(actionResult) { 
            var state = action.getState();
            console.log("state", state);
            if(state === 'SUCCESS'){
                var response = actionResult.getReturnValue();
                console.log('response.length',response.length,response);
                component.set('v.partnerIncentiveData', actionResult.getReturnValue());
                console.log('map',component.get('v.partnerIncentiveData'),'changePartnerProgram',changePartnerProgram);
                if(response.length > 1 || changePartnerProgram == 'true'){
                    /*var element = component.find("notifyMessage");
                    $A.util.removeClass(element, "slds-show");
					$A.util.addClass(element, "slds-hide");*/
					
                    component.set('v.columnsToDisplay', [
                        {label: 'Partner Program', fieldName: 'Partner_Program__c', type: 'text',sortable:true},
                        {label: 'Program Type', fieldName: 'Partner_Role__c', type: 'text',sortable: true}
                    ]);
                    //component.set('v.selectedRows',response[0]);
                    //console.log('selectedrow',component.get('v.selectedRows'));
					if(changePartnerProgram == 'true'){
                        console.log('in here');
						component.set('v.isPartnerProgramSelect',false);
						component.set('v.isPartnerProgramChange',true);
					}else{
						component.set('v.isPartnerProgramChange',false);
						component.set('v.isPartnerProgramSelect',true);
						component.set('v.isDisabled',true);
						component.set('v.currentIndex',keyIndex);
                        //document.getElementById("partnerProgramErrorMsg").style.display = "flex";
					}
					//component.set('v.donotshownewRow',true);
					
                }else if(response.length == 1 && changePartnerProgram == 'false'){
					component.set('v.isPartnerProgramSelect',false);
					component.set('v.isPartnerProgramChange',false);
					var WrapperList = component.get("v.WrapperList");
					for (var indexVar = 0; indexVar < WrapperList.length; indexVar++) {
						if (indexVar == keyIndex) {
							//alert(WrapperList[indexVar].IsRadioChecked);
							WrapperList[indexVar].PartnerRole = response[0].Partner_Role__c;
							WrapperList[indexVar].PartnerProgram = response[0].Partner_Program__c;
                            WrapperList[indexVar].PartnerIncentiveId = response[0].Id;
							break;
						}
					}
					component.set('v.currentIndex',keyIndex);
					component.set("v.WrapperList", WrapperList);
					//component.set('v.donotshownewRow',false);
					component.set('v.isDisabled',false);
                    //component.find("Custtoast").showToastModel('Sorry! There are no Partner Incentives for this partner.', 'Error');
                    /*component.set('v.isPartnerProgramSelect',false);
                    component.set('v.promptHeaderMessage','ERROR');
					component.set('v.promptMessage','Sorry! There are no Partner Incentives for this partner.');
					var element = component.find("notifyMessage");
					$A.util.removeClass(element, "slds-hide");
					$A.util.addClass(element, "slds-show");
					var element = component.find("notifyClass");
					$A.util.addClass(element, "slds-theme_error");*/
                }
            }else{
                console.log("Errors", action.getError()[0].message);
                component.find("Custtoast").showToastModel(action.getError()[0].message, 'error');
            }
        });
        $A.enqueueAction(action); 
    },
    
    resetAllValues : function(component,event,helper){
        console.log('resetAllValues');
        component.set('v.partnerIncentiveData',null);
		component.set('v.columnsToDisplay','');
		component.set('v.defaultSortDirection','asc');
		component.set('v.sortDirection','asc');
		component.set('v.sortedBy','');
		component.set('v.isDisabled',false);
		component.set('v.isPartnerProgramSelect', false);
		component.set('v.isPartnerProgramChange', false);
		//component.set('v.donotshownewRow',false);
        component.set('v.selectedPartner','');
        component.set('v.selectedRows','');
        if(document.getElementById("partnerProgramErrorMsg") != null){
        	document.getElementById("partnerProgramErrorMsg").style.display = "none";
        }if(document.getElementById("partnerProgramErrorMsgs") != null){
        	document.getElementById("partnerProgramErrorMsgs").style.display = "none";
        }
        //component.set('v.selectedRowsCount', '0');
        //var gvIdList = [];
        //component.set('v.gvIds',gvIdList);
    },
    clearLookup : function(component,event,helper,keyIndex){
        var WrapperList = component.get("v.WrapperList");
        console.log('WrapperList',WrapperList);
        for (var indexVar = 0; indexVar < WrapperList.length; indexVar++) {
            console.log('in for loop');
            if (indexVar == keyIndex) {
                console.log('inside if');
                WrapperList[indexVar].SelectedRecord = null;
                WrapperList[indexVar].PartnerRole = '';
                WrapperList[indexVar].PartnerProgram = '';
                WrapperList[indexVar].PartnerIncentiveId = '';
                break;
            }
        }
        console.log('WrapperList after',WrapperList);
        component.set("v.WrapperList", WrapperList);
        component.set('v.isPartnerProgramSelect', false);
        //var childCmp = component.find("AccLookup");
        //console.log('childCmp',childCmp);
		//childCmp.clearLookupPill();
    },
    handleRerenderAvailableTeamingTechPartnerHelper : function(component, event, helper){
        var findChildComp = component.find('childLwcCompId');
        findChildComp.retrieveTeamingTechPartners();
    },
    handleRerenderAvailableImpactPartnerHelper : function(component, event, helper){
        var findChildComp = component.find('childLwcCompIdImpact');
        findChildComp.retrieveImpactTechPartners();
    }
})