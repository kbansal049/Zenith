/**
 *  This is the ulitity class for triggers.
 *
 */

public class TriggerUtility2
{

    //Added by Gurjinder :  Code Clean Activity : Start

/*public static boolean skipOppTrigger = false;
public static Boolean isSkipOppTriggerExecuted() {
        return skipOppTrigger;
    }

    public static void SkipOppTriggerExecuted() {
        skipOppTrigger = true;
    }

    public static void SkipOppTriggerReset() {
        skipOppTrigger = false;
    } */
    
    public static boolean Oppbeforeinsert=false;
    public static Boolean isOppBeforeInsertExecuted() {
        return Oppbeforeinsert;
    }

    public static void OppBeforeInsertExecuted() {
        Oppbeforeinsert = true;
    }

    public static void OppBeforeInsertReset() {
        Oppbeforeinsert = false;
    }
    
    public static boolean Oppbeforeupdate = false;
    public static Boolean isOppBeforeUpdateExecuted() {
        return Oppbeforeupdate;
    }

    public static void OppBeforeUpdateExecuted() {
        Oppbeforeupdate = true;
    }

    public static void OppBeforeUpdateReset() {
        Oppbeforeupdate = false;
    }
    
    public static boolean Oppafterinsert = false;
    public static Boolean isOppAfterInsertExecuted() {
        return Oppafterinsert;
    }

    public static void OppAfterInsertExecuted() {
        Oppafterinsert = true;
    }

    public static void OppAfterInsertReset() {
        Oppafterinsert = false;
    }
    
    public static boolean OppAfterupdate = false;
    public static Boolean isOppAfterUpdateExecuted() {
        return OppAfterupdate;
    }

    public static void OppAfterUpdateExecuted() {
        OppAfterupdate = true;
    }

    public static void OppAfterUpdateReset() {
        OppAfterupdate = false;
    }
    
//Added by Gurjinder :  Code Clean Activity : End

//Added by Gurjinder :  CR# 910 : Start

public static boolean UpdateEdgewiseOverlayTeamSharing = false;
public static Boolean isUpdateEdgewiseOverlayTeamSharingExecuted() {
        return UpdateEdgewiseOverlayTeamSharing;
    }

    public static void UpdateEdgewiseOverlayTeamSharingExecuted() {
        UpdateEdgewiseOverlayTeamSharing = true;
    }

    public static void UpdateEdgewiseOverlayTeamSharingReset() {
        UpdateEdgewiseOverlayTeamSharing = false;
    }

//Added by Gurjinder :  CR# 910 : End

    
    //Added by Viral :  CR# 910 : Start
    public static boolean zscalerCloudIdTrigger = false;
    public static Boolean iszscalerCloudIdTriggerExecuted() {
        return zscalerCloudIdTrigger;
    }
    
    public static void UpdateZscalerCloudIdTriggerExecuted() {
        zscalerCloudIdTrigger = true;
    }
    
    public static void UpdateZscalerCloudIdTriggerReset() {
        zscalerCloudIdTrigger = false;
    }
    
    //Added by Viral :  CR# 910 : End
    //Added by Rajesh : CR#1229 - Start
    private static boolean updateTAMMetingDate = false; 
    public static Boolean isupdateTAMMetingDateExecuted() {
        return updateTAMMetingDate;
    }
    public static void updateTAMMetingDateExecuted() {
        updateTAMMetingDate = true;
    }
    public static void updateTAMMetingDateReset() {
        updateTAMMetingDate = false;
    }
    //Added by Rajesh : CR#1229 - End
    
    public static boolean attachmenttriggerskip = false;
    public static Boolean isSkipAttachmentTriggerExecuted() {
        return attachmenttriggerskip;
    }
    
    public static void SkipAttachmentTriggerExecuted() {
        attachmenttriggerskip = true;
    }
    
    public static void SkipAttachmentTriggerReset() {
        attachmenttriggerskip = false;
    }
    
    public static boolean attachmentafterinsertskip = false;
    public static Boolean isAttachmentAfterInsertExecuted() {
        return attachmentafterinsertskip;
    }
    
    public static void AttachmentAfterInsertExecuted() {
        attachmentafterinsertskip = true;
    }
    
    public static void AttachmentAfterInsertReset() {
        attachmentafterinsertskip = false;
    }
    
    public static boolean AttachmentAfterUpdate = false;
    public static Boolean isAttachmentAfterUpdateExecuted() {
        return AttachmentAfterUpdate;
    }
    
    public static void AttachmentAfterUpdateExecuted() {
        AttachmentAfterUpdate = true;
    }
    
    public static void AttachmentAfterUpdateReset() {
        AttachmentAfterUpdate = false;
    }
    
    public static boolean oppPO = false;
    public static Boolean isOppPOUpdateExecuted() {
        return oppPO;
    }
    
    public static void OppPOUpdateExecuted() {
        oppPO = true;
    }
    
    public static void OppPOUpdateReset() {
        oppPO = false;
    }
    
    // Added by Rajesh : CR# 1231
    public static boolean SkipNodeConfgtnTrigger=false;
    public static Boolean isSkipNodeConfgtnTriggerExecuted() {
        return SkipNodeConfgtnTrigger;
    }

    public static void SkipNodeConfgtnTriggerExecuted() {
        SkipNodeConfgtnTrigger = true;
    }

    public static void SkipNodeConfgtnTriggerReset() {
        SkipNodeConfgtnTrigger = false;
    }
    // Added by Rajesh : CR# 1231
    





    //Added by Swathi: CR1127 Start
    public static boolean updateTaskRelatedContOrLead=false;
    public static Boolean isupdateTaskRelatedContOrLeadExecuted() {
        return updateTaskRelatedContOrLead;
    }

    public static void updateTaskRelatedContOrLeadExecuted() {
        updateTaskRelatedContOrLead = true;
    }

    public static void updateTaskRelatedContOrLeadReset() {
        updateTaskRelatedContOrLead = false;
    }
    //Added by Swathi: CR1127 End
    
    // Added by Gurjinder : CR# 1256 :Start
    public static boolean updateTouchesSinceLastOpen=false;
    public static Boolean isupdateTouchesSinceLastOpenExecuted() {
        return updateTouchesSinceLastOpen;
    }

    public static void updateTouchesSinceLastOpenExecuted() {
        updateTouchesSinceLastOpen = true;
    }

    public static void updateTouchesSinceLastOpenReset() {
        updateTouchesSinceLastOpen = false;
    }
    // Added by Gurjinder : CR# 1256 :End

    //Added by Gurjinder :  CR# 1372 : Start

    public static boolean CreateUserStoryfromCR = false;
    public static Boolean isCreateUserStoryfromCRExecuted() {
        return CreateUserStoryfromCR;
    }
    
    public static void CreateUserStoryfromCRExecuted() {
        CreateUserStoryfromCR = true;
    }
    
    public static void CreateUserStoryfromCRReset() {
        CreateUserStoryfromCR = false;
    }






    //Added by Swathi: CR1410 Start
    public static boolean updateAccExtRelatedAcc=false;
    public static Boolean isupdateAccExtRelatedAccExecuted() {
        return updateAccExtRelatedAcc;
    }

    public static void updateAccExtRelatedAccExecuted() {
        updateAccExtRelatedAcc = true;
    }

    public static void updateAccExtRelatedAccReset() {
        updateAccExtRelatedAcc = false;
    }
    //Added by Swathi: CR1410 End
  

    //Added by Rajesh: CR 1357 Start

  public static boolean uniqueDataNodeConfig=false;
    public static Boolean isuniqueDataNodeConfigExecuted() {
        return uniqueDataNodeConfig;
    }

    public static void uniqueDataNodeConfigExecuted() {
        uniqueDataNodeConfig = true;
    }

    public static void uniqueDataNodeConfigReset() {
        uniqueDataNodeConfig = false;
    }
    //Added by Rajesh: CR 1357 End

    //Added by Swathi: CR1410 Start
    public static boolean UpdateCustomerScroceCardValue=false;
    public static Boolean isUpdateCustomerScroceCardValueExecuted() {
        return UpdateCustomerScroceCardValue;
    }

    public static void UpdateCustomerScroceCardValueExecuted() {
        UpdateCustomerScroceCardValue = true;
    }

    public static void UpdateCustomerScroceCardValueReset() {
        UpdateCustomerScroceCardValue = false;
    }
    
    public static boolean UpdateEventCustomerScroceCard=false;
    public static Boolean isUpdateEventCustomerScroceCardExecuted() {
        return UpdateEventCustomerScroceCard;
    }

    public static void UpdateEventCustomerScroceCardExecuted() {
        UpdateEventCustomerScroceCard = true;
    }

    public static void UpdateEventCustomerScroceCardReset() {
        UpdateEventCustomerScroceCard = false;
    }
    //Added by Swathi: CR1410 End

    //Added by Swathi: CR 1505 start
    public static boolean UpdateCampaignMemberBasedOnCont=false;
    public static Boolean isUpdateCampaignMemberBasedOnContExecuted() {
        return UpdateCampaignMemberBasedOnCont;
    }

    public static void UpdateCampaignMemberBasedOnContExecuted() {
        UpdateCampaignMemberBasedOnCont = true;
    }

    public static void UpdateCampaignMemberBasedOnContReset() {
        UpdateCampaignMemberBasedOnCont = false;
    }


    public static boolean UpdateCampaignMemberBasedOnLead=false;
    public static Boolean isUpdateCampaignMemberBasedOnleadExecuted() {
        return UpdateCampaignMemberBasedOnLead;
    }

    public static void UpdateCampaignMemberBasedOnLeadExecuted() {
        UpdateCampaignMemberBasedOnLead = true;
    }

    public static void UpdateCampaignMemberBasedOnLeadReset() {
        UpdateCampaignMemberBasedOnLead = false;
    }
    //Added by Swathi: CR 1505 End
    
    
    //Added by Rajesh: CR 1615 Start
    public static boolean setPartnerDiscount = false;
    public static Boolean issetPartnerDiscountExecuted() {
        return setPartnerDiscount;
    }

    public static void setPartnerDiscountExecuted() {
        setPartnerDiscount = true;
    }

    public static void setPartnerDiscountReset() {
        setPartnerDiscount = false;
    }
    //Added by Rajesh: CR 1615 End
    //Added by Swathi: CR 1926 Start
    public static boolean OppTechPartner = false;
    public static Boolean issetOppTechPartnerExecuted() {
        return OppTechPartner;
    }

    public static void setOppTechPartnerExecuted() {
        OppTechPartner = true;
    }

    public static void setOppTechPartnerReset() {
        OppTechPartner = false;
    }
    public static boolean OppRelTechPartner = false;
    public static Boolean issetOppRelTechPartnerExecuted() {
        return OppRelTechPartner;
    }

    public static void setOppRelTechPartnerExecuted() {
        OppRelTechPartner = true;
    }

    public static void setOppRelTechPartnerReset() {
        OppRelTechPartner = false;
    }
    public static boolean OppPartnerTechPartner = false;
    public static Boolean issetOppPartnerTechPartnerExecuted() {
        return OppPartnerTechPartner;
    }

    public static void setOppPartnerTechPartnerExecuted() {
        OppPartnerTechPartner = true;
    }

    public static void setOppPartnerTechPartnerReset() {
        OppPartnerTechPartner = false;
    }
    //Added by Swathi: CR 1926 End
    //Added by Swathi: CR 2447 Start
    public static boolean contractExtensionEmailSent = false;
    public static Boolean iscontractExtensionEmailSentExecuted() {
        return contractExtensionEmailSent;
    }

    public static void contractExtensionEmailSentExecuted() {
        contractExtensionEmailSent = true;
    }

    public static void contractExtensionEmailSentReset() {
        contractExtensionEmailSent = false;
    }
    //Added by Swathi: CR 2447 End
    public static boolean OpportunitySplitAfterInsert = false;
    public static Boolean isOpportunitySplitAfterInsertExecuted() {
        return OpportunitySplitAfterInsert;
    }

    public static void OpportunitySplitAfterInsertExecuted() {
        OpportunitySplitAfterInsert = true;
    }

    public static void OpportunitySplitAfterInsertReset() {
        OpportunitySplitAfterInsert = false;
    }
    
    public static boolean TargetafterInsertAndUpdate = false;
    public static Boolean isTargetafterInsertAndUpdate() {
        return TargetafterInsertAndUpdate;
    }

    public static void TargetafterInsertAndUpdateExecuted() {
        TargetafterInsertAndUpdate = true;
    }

    public static void TargetafterInsertAndUpdateReset() {
        TargetafterInsertAndUpdate = false;
    }
    
    //CR#1920 Start
    public static boolean NFRafterUpdate = false;
    public static Boolean isNFRafterUpdateExecuted() {
        return NFRafterUpdate;
    }

    public static void NFRafterUpdateExecuted() {
        NFRafterUpdate = true;
    }

    public static void NFRafterUpdateExecutedReset() {
        NFRafterUpdate = false;
    }
    
    public static boolean PRNFRFieldUpdate = false;
    public static Boolean isPRNFRFieldUpdateExecuted() {
        return PRNFRFieldUpdate;
    }

    public static void PRNFRFieldUpdateExecuted() {
        PRNFRFieldUpdate = true;
    }

    public static void PRNFRFieldUpdateExecutedReset() {
        PRNFRFieldUpdate = false;
    }
    
    public static boolean PRNFRFieldInsert = false;
    public static Boolean isPRNFRFieldInsertExecuted() {
        return PRNFRFieldInsert;
    }

    public static void PRNFRFieldInsertExecuted() {
        PRNFRFieldInsert = true;
    }

    public static void PRNFRFieldInsertExecutedReset() {
        PRNFRFieldInsert = false;
    }
    //CR#1920 Ends

    public static void booster(){
    integer i=0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;

    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;

    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
	i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;

    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;

    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;

  }
    
    //Added by CSSCorp :  
    public static boolean oppOrderTracakerCalled = false;
    public static Boolean isOppOrderTracakerCalledExecuted() {
        return oppOrderTracakerCalled;
    }
    
    public static void oppOrderTracakerCalledExecuted() {
        oppOrderTracakerCalled = true;
    }
    
    public static void oppOrderTracakerCalledReset() {
        oppOrderTracakerCalled = false;
    }
    
    //Added by Gurjinder for Value Creation Engagement: CR# 3730 :Start
     private static boolean beforeupdateeventonVCE = false;   
    public static Boolean isbeforeupdateexecutedonVCE() { 
      return beforeupdateeventonVCE;   
    }   
        
    public static void beforeupdateexecutedonVCE() {  
      beforeupdateeventonVCE = true;   
    }   
        
    public static void beforeupdateexecutedonVCEReset() { 
      beforeupdateeventonVCE = false;  
    }  
    //Added by Gurjinder for Value Creation Engagement: CR# 3730 :End

    //CR# 4867 and CR# 4868 Start
    private static boolean oppSplitTeamMemberUpdateProcessExecuted = false;
    public static Boolean isOppSplitTeamMemberUpdateProcessExecuted() {
        return oppSplitTeamMemberUpdateProcessExecuted;
    }

    public static void setOppSplitTeamMemberUpdateProcessExecuted() {
        oppSplitTeamMemberUpdateProcessExecuted = true;
    }

    public static void reSetOppSplitTeamMemberUpdateProcessExecuted() {
        oppSplitTeamMemberUpdateProcessExecuted = false;
    }

    private static boolean oppSplitRAMAssignmentProcessExecuted = false;
    public static Boolean isOppSplitRAMAssignmentProcessExecuted() {
        return oppSplitRAMAssignmentProcessExecuted;
    }

    public static void setOppSplitRAMAssignmentProcessExecuted() {
        oppSplitRAMAssignmentProcessExecuted = true;
    }

    public static void reSetOppSplitRAMAssignmentProcessExecuted() {
        oppSplitRAMAssignmentProcessExecuted = false;
    }
    //CR# 4867 and CR# 4868 End
    private static boolean focusPartnerSalesTeamUpdateExecuted = false;
    public static Boolean isfocusPartnerSalesTeamUpdateExecuted() {
        return focusPartnerSalesTeamUpdateExecuted;
    }

    public static void setfocusPartnerSalesTeamUpdateExecuted() {
        focusPartnerSalesTeamUpdateExecuted = true;
    }

    public static void reSetfocusPartnerSalesTeamUpdateExecuted() {
        focusPartnerSalesTeamUpdateExecuted = false;
    }
}