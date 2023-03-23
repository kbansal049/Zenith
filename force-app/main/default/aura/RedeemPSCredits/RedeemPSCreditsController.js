/*
    @Author : Harish Gowda N, Sachin Tandon
    @Requirement : PS Credit Process - CR# 4743,CR# 4744,CR# 4745
    @Created Date : 17/05/2022
    @Description : LWC Component for PS Credit Redemption Process.
    ***********************************************************************************************************
    MODIFICATION LOG
    * Version            Developer            Date            Jira Number          Description
    *---------------------------------------------------------------------------------------------------------
      1.0                Sachin Tandon        17/05/2022      CR#4745      PS Credits Redemption Process && PS Credits Redemption Validation.
      2.0                Harish Gowda N       17/05/2022      CR#4744      PS Credits Redemption Process && PS Credits Redemption Validation.
      ***********************************************************************************************************
*/

({
    onPageReferenceChange: function(component, event, helper) {
        var myPageRef = component.get('v.pageReference');
        var accountId = myPageRef.state.c__AccountId;
        component.set('v.accountId', accountId);
    }
})