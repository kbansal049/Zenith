@isTest
public class ShowCartOperationsTest {
    
    public static String quoteNewBuiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId(); 
    public static String OppRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
    public static String oppAmendment = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Upsell_Opportunity_Open').getRecordTypeId();
    
    @TestSetup
    static void setupData(){
        //ShowCartItemsVFController
        Account acc = new Account();
        acc.Name = 'Test';
        acc.OwnerId = UserInfo.getUserId();
        insert acc;
        
        //ShowCartItemsVFController showCartItem = new ShowCartItemsVFController();
        
        Product2 prod = new Product2(Name = 'Laptop X200',
                                     Family = 'Hardware', ProductCode = 'ZCES-SUP-PREM');
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        //Create Quote
        Opportunity createOpp = new Opportunity();
        createOpp.Name='test opp';
        createOpp.StageName='6 - Closed Won';
        createOpp.Probability = 95;
        createOpp.CloseDate=system.today();
        insert createOpp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.ownerId = UserInfo.getUserId();
        quote.Proposal_Name__c = 'SingleTrad3Ramps - New Business';
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 3;
        quote.SBQQ__Opportunity2__c = createOpp.Id;
        quote.Price_List__c = 'FY21 Single Tier Price List';
        quote.SBQQ__Type__c = 'Quote';
        quote.RecordTypeId = quoteNewBuiness;
        quote.Partner_Program__c = 'Traditional';
        insert quote;
                
        SBQQ__QuoteLine__c quoteLineList = new SBQQ__QuoteLine__c();
        quoteLineList.SBQQ__Product__c = prod.Id;
        quoteLineList.SBQQ__Quote__c = quote.id;
        quoteLineList.SBQQ__Number__c = 5;
        quoteLineList.Line_Status__c = 'New';
        quoteLineList.SBQQ__Renewal__c = true;
        //quoteLineList.SBQQ__Existing__c = true;
        quoteLineList.SBQQ__PriorQuantity__c = 12;
        quoteLineList.SBQQ__NetPrice__c = 123;
        quoteLineList.Base_Extended_Price__c = 223;
        insert quoteLineList;
    }

    @isTest
    static void showCartDetailsTestUnit(){
        //ShowCartDetailsController
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        ShowCartDetailsController showCart = new ShowCartDetailsController();
        showCart.InstanceURL = 'https://zscaler--qa.lightning.force.com/lightning/page/home';
        showCart.ApproverId = acc.id;
        showCart.ApprovalRequestId = acc.id;
        showCart.IsAssignment = true;
        showCart.IsApproved = true;
        showCart.IsApproveOrReject = true;
        showCart.IsShowApprovalSection = true;
        showCart.IsEmailTemplateView = true;
        showCart.IsShowCartView = true;
    }
    @isTest
    static void showCartItemsVFTestUnit(){
                
        Account acc = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c qut = [SELECT Id, Proposal_Name__c FROM SBQQ__Quote__c];
        
        ApexPages.currentPage().getParameters().put('id',qut.Id);
        ShowCartItemsVFController showCartItem = new ShowCartItemsVFController();
        showCartItem.isPartnerSummit = true;
        showCartItem.isPartnerAdjustment = true;
        showCartItem.isTraditional = true;
        
        showCartItem.InstanceURL = 'https://zscaler--qa.lightning.force.com/lightning/page/home';
        showCartItem.ApproverId = acc.id;
        showCartItem.ApprovalRequestId = acc.id;
        showCartItem.IsAssignment = true;
        showCartItem.IsApproved = true;
        showCartItem.IsApproveOrReject = true;
        showCartItem.IsShowApprovalSection = true;
        showCartItem.IsEmailTemplateView = true;
        showCartItem.IsShowCartView = true;
        
        showCartItem.showDRSourced = true;
        showCartItem.showDRTeamResell = true;
        showCartItem.showDRTeamTech = true;
        showCartItem.isSummitDiscount = true;
        
        showCartItem.totalUnitRecommendedNet = 12.1;
        showCartItem.totalNetPUPY = 12.1;
        //showCartItem.OnlydiffOfRenewableAndProposal = 12.1;
        //showCartItem.totalNetPUPY = 12.1;
        showCartItem.oldppu = 12.1;
        showCartItem.newppu = 12.1;
        showCartItem.changeofPPU = 12.1;
        showCartItem.onCancel();
        showCartItem.GetChildRecords();
        showCartItem.showChild = true;
        showCartItem.quoteId = String.valueOf(qut.Id);        
    }

    @isTest
    static void showCartItemsVFTestUnit1(){
                        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c qut = [SELECT Id, Proposal_Name__c FROM SBQQ__Quote__c];
        //System.assertEquals(true, qut.Id != null);
        ApexPages.currentPage().getParameters().put('id',qut.Id);
        ShowCartItemsVFController showCartItem = new ShowCartItemsVFController();
        showCartItem.isPartnerSummit = true;
        showCartItem.isPartnerAdjustment = true;
        //showCartItem.isTraditional = true;
        showCartItem.isSummitDiscount = true;
        showCartItem.InstanceURL = 'https://zscaler--qa.lightning.force.com/lightning/page/home';
        showCartItem.ApproverId = acc.id;
        showCartItem.ApprovalRequestId = acc.id;
        showCartItem.IsAssignment = true;
        showCartItem.IsApproved = true;
        showCartItem.IsApproveOrReject = true;
        showCartItem.IsShowApprovalSection = true;
        showCartItem.IsEmailTemplateView = true;
        showCartItem.IsShowCartView = true;
        
        showCartItem.showDRSourced = true;
        showCartItem.showDRTeamResell = true;
        showCartItem.showDRTeamTech = true;
                
        showCartItem.totalUnitRecommendedNet = 12.1;
        showCartItem.totalNetPUPY = 12.1;
        //showCartItem.OnlydiffOfRenewableAndProposal = 12.1;
        //showCartItem.totalNetPUPY = 12.1;
        showCartItem.oldppu = 12.1;
        showCartItem.newppu = 12.1;
        showCartItem.changeofPPU = 12.1;
        showCartItem.onCancel();
        showCartItem.GetChildRecords();
        showCartItem.showChild = true;
        showCartItem.quoteId = String.valueOf(qut.Id);
        
    }
    @isTest
    static void showCartItemsVFTestUnit2(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity createOpp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.Proposal_Name__c = 'SingleTrad3Ramps - New Business';
            quote.SBQQ__Status__c = 'Draft';
            quote.SBQQ__Account__c = acc.Id;
            quote.SBQQ__StartDate__c = System.today();
            quote.SBQQ__EndDate__c = System.today() + 3;
            quote.SBQQ__Opportunity2__c = createOpp.Id;
            quote.Price_List__c = 'FY21 Federal Editions Price List';
            quote.SBQQ__Type__c = 'Quote';
            quote.SBQQ__Primary__c = true;
            insert quote;                
                    
            //SBQQ__Quote__c qut = [SELECT Id, Proposal_Name__c FROM SBQQ__Quote__c];
            //System.assertEquals(true, qut.Id != null);
            ApexPages.currentPage().getParameters().put('id',quote.Id);
            ShowCartItemsVFController showCartItem = new ShowCartItemsVFController();
            showCartItem.isPartnerSummit = true;
            showCartItem.isPartnerAdjustment = true;
            showCartItem.isTraditional = true;
            
            showCartItem.InstanceURL = 'https://zscaler--qa.lightning.force.com/lightning/page/home';
            showCartItem.ApproverId = acc.id;
            showCartItem.ApprovalRequestId = acc.id;
            showCartItem.IsAssignment = true;
            showCartItem.IsApproved = true;
            showCartItem.IsApproveOrReject = true;
            showCartItem.IsShowApprovalSection = true;
            showCartItem.IsEmailTemplateView = true;
            showCartItem.IsShowCartView = true;
            
            showCartItem.showDRSourced = true;
            showCartItem.showDRTeamResell = true;
            showCartItem.showDRTeamTech = true;
            showCartItem.isSummitDiscount = true;
            
            showCartItem.totalUnitRecommendedNet = 12.1;
            showCartItem.totalNetPUPY = 12.1;
            //showCartItem.OnlydiffOfRenewableAndProposal = 12.1;
            //showCartItem.totalNetPUPY = 12.1;
            showCartItem.oldppu = 12.1;
            showCartItem.newppu = 12.1;
            showCartItem.changeofPPU = 12.1;
            showCartItem.onCancel();
            showCartItem.GetChildRecords();
            showCartItem.showChild = true;
            showCartItem.quoteId = String.valueOf(quote.Id);
        Test.stopTest();
    }
    
    @isTest
    static void showCartItemsVFTestUnit3(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        //Opportunity createOpp = [SELECT Id,RecordTypeId FROM Opportunity LIMIT 1];
        //update createOpp;
        
        Test.startTest();
            
            Opportunity createOpp = new Opportunity();
            createOpp.Name='test opp';
            createOpp.StageName='6 - Closed Won';
            createOpp.Probability = 95;
            createOpp.AccountId = acc.Id;
            //createOpp.AW_POV_Partner__c = acc.Id;
            createOpp.CloseDate=system.today();
            //createOpp.RecordTypeId = OppRenewal;
            createOpp.OwnerId = UserInfo.getUserId();
            insert createOpp;

            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.OwnerId = UserInfo.getUserId();
            quote.Proposal_Name__c = 'SingleTrad3Ramps - New Business';
            quote.SBQQ__Status__c = 'Draft';
            quote.SBQQ__Account__c = acc.Id;
            quote.SBQQ__StartDate__c = System.today();
            quote.SBQQ__EndDate__c = System.today() + 3;
            quote.SBQQ__Opportunity2__c = createOpp.Id;
            quote.Price_List__c = 'FY21 Volume Tier Price List';
            quote.SBQQ__Type__c = 'Renewal';
            quote.Partner_Program__c = 'Summit - Discount';
            //quote.SBQQ__Primary__c = true;
            insert quote;
                    
            Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
            SBQQ__QuoteLine__c quoteLineList = new SBQQ__QuoteLine__c();
            quoteLineList.SBQQ__Product__c = prod.Id;
            quoteLineList.SBQQ__Quote__c = quote.id;
            quoteLineList.SBQQ__Number__c = 5;
            quoteLineList.Line_Status__c = 'New';
            quoteLineList.SBQQ__Renewal__c = true;
            //quoteLineList.SBQQ__Existing__c = true;
            quoteLineList.SBQQ__PriorQuantity__c = 12;
            quoteLineList.SBQQ__NetPrice__c = 123;
            quoteLineList.Base_Extended_Price__c = 223;
            insert quoteLineList;        
            
            //SBQQ__Quote__c qut = [SELECT Id, Proposal_Name__c FROM SBQQ__Quote__c];
            //System.assertEquals(true, qut.Id != null);
            ApexPages.currentPage().getParameters().put('id',quote.Id);
            ShowCartItemsVFController showCartItem = new ShowCartItemsVFController();
            showCartItem.isPartnerSummit = true;
            showCartItem.isPartnerAdjustment = true;
            showCartItem.isTraditional = true;
            
            showCartItem.InstanceURL = 'https://zscaler--qa.lightning.force.com/lightning/page/home';
            showCartItem.ApproverId = acc.id;
            showCartItem.ApprovalRequestId = acc.id;
            showCartItem.IsAssignment = true;
            showCartItem.IsApproved = true;
            showCartItem.IsApproveOrReject = true;
            showCartItem.IsShowApprovalSection = true;
            showCartItem.IsEmailTemplateView = true;
            showCartItem.IsShowCartView = true;
            
            showCartItem.showDRSourced = true;
            showCartItem.showDRTeamResell = true;
            showCartItem.showDRTeamTech = true;
            showCartItem.isSummitDiscount = true;
            
            showCartItem.totalUnitRecommendedNet = 12.1;
            showCartItem.totalNetPUPY = 12.1;
            //showCartItem.OnlydiffOfRenewableAndProposal = 12.1;
            //showCartItem.totalNetPUPY = 12.1;
            showCartItem.oldppu = 12.1;
            showCartItem.newppu = 12.1;
            showCartItem.changeofPPU = 12.1;
            showCartItem.onCancel();
            showCartItem.GetChildRecords();
            showCartItem.showChild = true;
            showCartItem.quoteId = String.valueOf(quote.Id);        
            
            ShowCartItemsVFController.CoSellAtivity objWrapper = new ShowCartItemsVFController.CoSellAtivity('AW/POV','Traditional',0.0);
            objWrapper.Activity = 'AW/POV';
            objWrapper.PartnerName = 'Traditional';
            objWrapper.Margin = 0;      
        Test.stopTest();
    }
    
    @isTest
    static void showCartItemsEmailTestUnit(){
        //ShowCartItemsEmailController
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        ShowCartItemsEmailController showCartItemEmail = new ShowCartItemsEmailController();
        showCartItemEmail.IsShowApprovalSection = true;
        showCartItemEmail.IsEmailTemplateView = true;
        showCartItemEmail.IsShowCartView = true;
        
        Product2 prod = new Product2(Name = 'Laptop X200',
                                     Family = 'Hardware', ProductCode = 'ZCES-SUP-PREM');
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        Test.startTest();
        
        //Create Quote
        Opportunity createOpp = new Opportunity();
        createOpp.Name='test opp';
        createOpp.StageName='6 - Closed Won';
        createOpp.Probability = 95;
        createOpp.CloseDate=system.today();
        insert createOpp;        

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Proposal_Name__c = 'SingleTrad3Ramps - New Business';
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 3;
        quote.SBQQ__Opportunity2__c = createOpp.Id;
        quote.Price_List__c = 'FY21 Single Tier Price List';
        quote.SBQQ__Type__c = 'Quote';
        quote.RecordTypeId = quoteNewBuiness;
        quote.Partner_Program__c = 'Summit - Discount';
        insert quote;
        
        SBQQ__QuoteLine__c quoteLineList = new SBQQ__QuoteLine__c();
        quoteLineList.SBQQ__Product__c = prod.Id;
        quoteLineList.SBQQ__Quote__c = quote.id;
        quoteLineList.SBQQ__Number__c = 5;
        quoteLineList.SBQQ__Renewal__c = true;
        //quoteLineList.SBQQ__Existing__c = true;
        quoteLineList.SBQQ__PriorQuantity__c = 12;
        quoteLineList.SBQQ__NetPrice__c = 123;
        quoteLineList.Base_Extended_Price__c = 223;
        quoteLineList.Line_Status__c = 'New';
        insert quoteLineList;
        
        Double BaseExtendedPrice = 1.0;
        
        SBQQ__Quote__c qut = [SELECT Id, Proposal_Name__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :createOpp.Id];
        //system.assert(false, qut.Id);
        
        User adminUser =  SB_TestCPQDataUtility.createUsers(1, 'system', 'Administrator1' , 'System Administrator')[0];
		insert adminUser;
        
        // Create Approver
        sbaa__Approver__c objApprover = new sbaa__Approver__c();
        objApprover.sbaa__User__c = adminUser.Id;
        objApprover.Name = 'Test User'; 
        INSERT objApprover;
        
        
        showCartItemEmail.accountName = acc.Name;
        showCartItemEmail.quoteName = quote.Proposal_Name__c;
        showCartItemEmail.approvalReason = 'Testing Purpose';
        showCartItemEmail.accountId = acc.Id;
        showCartItemEmail.quoteId = String.valueOf(qut.Id);
        //system.assert(false, showCartItemEmail.quoteId );
        showCartItemEmail.quoteRecList = new List<SBQQ__Quote__c>();
        showCartItemEmail.InstanceURL = 'https://zscaler--qa.lightning.force.com/lightning/page/home';
        showCartItemEmail.ApproverId = objApprover.Id;
        showCartItemEmail.ApprovalRequestId = quote.id;
        showCartItemEmail.IsAssignment = true;
        showCartItemEmail.IsApproved = true;
        showCartItemEmail.isPartnerSummit = true;
        showCartItemEmail.isPartnerAdjustment = true;
        showCartItemEmail.differnceOfRenewableAndProposal = 12.1;
        showCartItemEmail.OnlydiffOfRenewableAndProposal = 12.1;
        showCartItemEmail.isTraditional = true;
        showCartItemEmail.isSummitFederal = true;
        showCartItemEmail.isSummitDiscount = true;
        showCartItemEmail.IsShowApprovalSection = true;
        showCartItemEmail.IsEmailTemplateView = true;
        showCartItemEmail.IsShowCartView = true;
        
        
        sbaa__ApprovalRule__c sbaaRule = new sbaa__ApprovalRule__c();
        sbaaRule.Name = 'Discount Rule';
        sbaaRule.sbaa__TargetObject__c = 'SBQQ__Quote__c';
        sbaaRule.sbaa__ApprovalStep__c = 1;
        sbaaRule.Rule_Description__c = 'Please review net varinace and manual adjustment on the quote';
        sbaaRule.sbaa__Approver__c = objApprover.Id;
        insert sbaaRule;
        
        sbaa__ApprovalRule__c sbaR = [SELECT Id, Name,Rule_Description__c FROM sbaa__ApprovalRule__c LIMIT 1];
        
        sbaa__Approval__c sbaaApproval = new sbaa__Approval__c();
        sbaaApproval.sbaa__Rule__c = sbaR.Id;
        sbaaApproval.sbaa__ApprovalStep__c = 1;
        sbaaApproval.sbaa__RecordField__c = 'Quote__c';
        sbaaApproval.sbaa__Status__c = 'Requested';
        sbaaApproval.sbaa__CommentsLong__c = 'Rejected - ';
        sbaaApproval.sbaa__AssignedTo__c = adminUser.Id;
        sbaaApproval.Quote__c = quote.Id;
        insert sbaaApproval;
        
        sbaa__Approval__c spA = [SELECT Id, sbaa__Rule__r.Name, sbaa__Rule__c,Rule_Description__c, 
        sbaa__ApprovalStep__c, sbaa__RecordField__c FROM sbaa__Approval__c WHERE Id=: sbaaApproval.Id];
        showCartItemEmail.getQuoteList();
        //  showCartItemEmail.genrateExceptionLiteral(spA);
        showCartItemEmail.getListOfQuoteLineDetails();
        showCartItemEmail.getListOfRecurringLineItems();
        showCartItemEmail.getListOfRecurringRenewalLineItems();
        showCartItemEmail.getListOfOneTimeLineItems();
        showCartItemEmail.getSupportLineItem();
        showCartItemEmail.getApprovalExceptionsList();
        showCartItemEmail.getMyApprovalExceptionsList();
        showCartItemEmail.getOtherApprovalExceptionsList();
        showCartItemEmail.getRejectedBy();
        showCartItemEmail.getRejectionReason();
        
        Test.stopTest();
    }
    
    
    @isTest
    static void showCartItemsEmailTestUnit111(){
        //ShowCartItemsEmailController
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        ShowCartItemsEmailController showCartItemEmail = new ShowCartItemsEmailController();
        showCartItemEmail.IsShowApprovalSection = true;
        showCartItemEmail.IsEmailTemplateView = true;
        showCartItemEmail.IsShowCartView = true;
        
        Product2 prod = new Product2(Name = 'Laptop X200',
                                     Family = 'Hardware', ProductCode = 'ZCES-SUP-PREM');
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
                
        Test.startTest();

        //Create Quote
        Opportunity createOpp = new Opportunity();
        createOpp.Name='test opp';
        createOpp.StageName='6 - Closed Won';
        createOpp.Probability = 95;
        createOpp.CloseDate=system.today();
        insert createOpp;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Proposal_Name__c = 'SingleTrad3Ramps - New Business';
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 3;
        quote.SBQQ__Opportunity2__c = createOpp.Id;
        quote.Price_List__c = 'FY21 Volume Tier Price List';
        quote.SBQQ__Type__c = 'Quote';
        quote.RecordTypeId = quoteNewBuiness;
        quote.Partner_Program__c = 'Traditional';
        insert quote;
        
        
        SBQQ__QuoteLine__c quoteLineList = new SBQQ__QuoteLine__c();
        quoteLineList.SBQQ__Product__c = prod.Id;
        quoteLineList.SBQQ__Quote__c = quote.id;
        quoteLineList.SBQQ__Number__c = 5;
        quoteLineList.SBQQ__Renewal__c = true;
        //quoteLineList.SBQQ__Existing__c = true;
        quoteLineList.SBQQ__PriorQuantity__c = 12;
        quoteLineList.SBQQ__NetPrice__c = 123;
        quoteLineList.Base_Extended_Price__c = 223;
        quoteLineList.Line_Status__c = 'New';
        insert quoteLineList;
        
        Double BaseExtendedPrice = 1.0;
        
        SBQQ__Quote__c qut = [SELECT Id, Proposal_Name__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :createOpp.Id];
        //system.assert(false, qut.Id);
        
        User adminUser =  SB_TestCPQDataUtility.createUsers(1, 'system', 'Administrator1' , 'System Administrator')[0];
		insert adminUser;
        
        // Create Approver
        sbaa__Approver__c objApprover = new sbaa__Approver__c();
        objApprover.sbaa__User__c = adminUser.Id;
        objApprover.Name = 'Test User'; 
        INSERT objApprover;
        
        
        showCartItemEmail.accountName = acc.Name;
        showCartItemEmail.quoteName = quote.Proposal_Name__c;
        showCartItemEmail.approvalReason = 'Testing Purpose';
        showCartItemEmail.accountId = acc.Id;
        showCartItemEmail.quoteId = String.valueOf(qut.Id);
        showCartItemEmail.quoteRecList = new List<SBQQ__Quote__c>();
        showCartItemEmail.InstanceURL = 'https://zscaler--qa.lightning.force.com/lightning/page/home';
        showCartItemEmail.ApproverId = objApprover.Id;
        showCartItemEmail.ApprovalRequestId = quote.id;
        showCartItemEmail.IsAssignment = true;
        showCartItemEmail.IsApproved = true;
        showCartItemEmail.isPartnerSummit = true;
        showCartItemEmail.isPartnerAdjustment = true;
        showCartItemEmail.differnceOfRenewableAndProposal = 12.1;
        showCartItemEmail.OnlydiffOfRenewableAndProposal = 12.1;
        showCartItemEmail.isTraditional = true;
        showCartItemEmail.isSummitFederal = true;
        showCartItemEmail.isSummitDiscount = true;
        showCartItemEmail.IsShowApprovalSection = true;
        showCartItemEmail.IsEmailTemplateView = true;
        showCartItemEmail.IsShowCartView = true;
        
        
        sbaa__ApprovalRule__c sbaaRule = new sbaa__ApprovalRule__c();
        sbaaRule.Name = 'Discount Rule';
        sbaaRule.sbaa__TargetObject__c = 'SBQQ__Quote__c';
        sbaaRule.sbaa__ApprovalStep__c = 1;
        sbaaRule.Rule_Description__c = 'Please review net variance and manual adjustment on the quote';
        sbaaRule.sbaa__Approver__c = objApprover.Id;
        insert sbaaRule;
        
        sbaa__ApprovalRule__c sbaR = [SELECT Id, Name,Rule_Description__c FROM sbaa__ApprovalRule__c LIMIT 1];
        
        sbaa__Approval__c sbaaApproval = new sbaa__Approval__c();
        sbaaApproval.sbaa__Rule__c = sbaR.Id;
        sbaaApproval.sbaa__ApprovalStep__c = 1;
        sbaaApproval.sbaa__RecordField__c = 'Quote__c';
        sbaaApproval.sbaa__Status__c = 'Requested';
        sbaaApproval.sbaa__CommentsLong__c = 'Rejected - ';
        sbaaApproval.sbaa__AssignedTo__c = adminUser.Id;
        sbaaApproval.Quote__c = quote.Id;
        insert sbaaApproval;
        
        sbaa__Approval__c spA = [SELECT Id, sbaa__Rule__r.Name, sbaa__Rule__c,Rule_Description__c, 
        sbaa__ApprovalStep__c, sbaa__RecordField__c FROM sbaa__Approval__c WHERE Id=: sbaaApproval.Id];
        showCartItemEmail.getQuoteList();
        showCartItemEmail.getListOfQuoteLineDetails();
        showCartItemEmail.getListOfRecurringLineItems();
        showCartItemEmail.getListOfRecurringRenewalLineItems();
        showCartItemEmail.getListOfOneTimeLineItems();
        showCartItemEmail.getSupportLineItem();
        showCartItemEmail.getApprovalExceptionsList();
        showCartItemEmail.getMyApprovalExceptionsList();
        showCartItemEmail.getOtherApprovalExceptionsList();
        showCartItemEmail.getRejectedBy();
        showCartItemEmail.getRejectionReason();
        
        Test.stopTest();
    }
    
    
    @isTest
    static void showCartItemsEmailTestUnit1(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        ShowCartItemsEmailController showCartItemEmail = new ShowCartItemsEmailController();
        sbaa__ApprovalRule__c sbaaRule = new sbaa__ApprovalRule__c();
        sbaaRule.Name = 'NFR';
        sbaaRule.sbaa__TargetObject__c = 'SBQQ__Quote__c';
        sbaaRule.sbaa__ApprovalStep__c = 1;
        sbaaRule.Rule_Description__c = null;
        insert sbaaRule;
        
        sbaa__ApprovalRule__c sbaR = [SELECT Id, Name,Rule_Description__c FROM sbaa__ApprovalRule__c LIMIT 1];
        
        sbaa__Approval__c sbaaApproval = new sbaa__Approval__c();
        sbaaApproval.sbaa__Rule__c = sbaR.Id;
        sbaaApproval.sbaa__ApprovalStep__c = 1;
        sbaaApproval.sbaa__RecordField__c = 'Quote__c';
        sbaaApproval.Quote__c = quote.Id;
        insert sbaaApproval;
        
        sbaa__Approval__c spA = [SELECT Id, sbaa__Rule__r.Name, sbaa__Rule__c,Rule_Description__c, 
        sbaa__ApprovalStep__c, sbaa__RecordField__c FROM sbaa__Approval__c WHERE Id=: sbaaApproval.Id];
        
        Test.stopTest();
    }
    
    @isTest
    static void showCartItemsEmailTestUnit2(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        ShowCartItemsEmailController showCartItemEmail = new ShowCartItemsEmailController();
        sbaa__ApprovalRule__c sbaaRule = new sbaa__ApprovalRule__c();
        sbaaRule.Name = 'DAS Seats Mismatch';
        sbaaRule.sbaa__TargetObject__c = 'SBQQ__Quote__c';
        sbaaRule.sbaa__ApprovalStep__c = 1;
        sbaaRule.Rule_Description__c = 'This Rule is for Deployment Services. Please review.';
        insert sbaaRule;
        
        sbaa__ApprovalRule__c sbaR = [SELECT Id, Name,Rule_Description__c FROM sbaa__ApprovalRule__c LIMIT 1];
        
        sbaa__Approval__c sbaaApproval = new sbaa__Approval__c();
        sbaaApproval.sbaa__Rule__c = sbaR.Id;
        sbaaApproval.sbaa__ApprovalStep__c = 1;
        sbaaApproval.sbaa__RecordField__c = 'Quote__c';
        sbaaApproval.Quote__c = quote.Id;
        insert sbaaApproval;
        
        sbaa__Approval__c spA = [SELECT Id, sbaa__Rule__r.Name, sbaa__Rule__c, 
        sbaa__ApprovalStep__c, sbaa__RecordField__c,Rule_Description__c FROM sbaa__Approval__c WHERE Id=: sbaaApproval.Id];
        
        Test.stopTest();
    }
    
    @isTest
    static void showCartItemsEmailTestUnit3(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        ShowCartItemsEmailController showCartItemEmail = new ShowCartItemsEmailController();
        sbaa__ApprovalRule__c sbaaRule = new sbaa__ApprovalRule__c();
        sbaaRule.Name = 'DAS Seats Mismatch';
        sbaaRule.sbaa__TargetObject__c = 'SBQQ__Quote__c';
        sbaaRule.sbaa__ApprovalStep__c = 1;
        insert sbaaRule;
        
        sbaa__ApprovalRule__c sbaR = [SELECT Id, Name,Rule_Description__c FROM sbaa__ApprovalRule__c LIMIT 1];
        
        sbaa__Approval__c sbaaApproval = new sbaa__Approval__c();
        sbaaApproval.sbaa__Rule__c = sbaR.Id;
        sbaaApproval.sbaa__ApprovalStep__c = 1;
        sbaaApproval.sbaa__RecordField__c = 'Quote__c';
        sbaaApproval.Quote__c = quote.Id;
        insert sbaaApproval;
        
        sbaa__Approval__c spA = [SELECT Id, sbaa__Rule__r.Name, sbaa__Rule__c,Rule_Description__c, 
        sbaa__ApprovalStep__c, sbaa__RecordField__c FROM sbaa__Approval__c WHERE Id=: sbaaApproval.Id];
        
        Test.stopTest();
    }
    
    @isTest
    static void showCartItemsEmailTestUnit4(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        ShowCartItemsEmailController showCartItemEmail = new ShowCartItemsEmailController();
        sbaa__ApprovalRule__c sbaaRule = new sbaa__ApprovalRule__c();
        sbaaRule.Name = 'One Time Credit Approval';
        sbaaRule.sbaa__TargetObject__c = 'SBQQ__Quote__c';
        sbaaRule.sbaa__ApprovalStep__c = 1;
        sbaaRule.Rule_Description__c = 'This Rule is for One time Credit products. Please review.';
        insert sbaaRule;
        
        sbaa__ApprovalRule__c sbaR = [SELECT Id, Name,Rule_Description__c FROM sbaa__ApprovalRule__c LIMIT 1];
        
        sbaa__Approval__c sbaaApproval = new sbaa__Approval__c();
        sbaaApproval.sbaa__Rule__c = sbaR.Id;
        sbaaApproval.sbaa__ApprovalStep__c = 1;
        sbaaApproval.sbaa__RecordField__c = 'Quote__c';
        sbaaApproval.Quote__c = quote.Id;
        insert sbaaApproval;
        
        sbaa__Approval__c spA = [SELECT Id, sbaa__Rule__r.Name, sbaa__Rule__c,Rule_Description__c, 
        sbaa__ApprovalStep__c, sbaa__RecordField__c FROM sbaa__Approval__c WHERE Id=: sbaaApproval.Id];
        
        Test.stopTest();
    }
}