@isTest
public class ShowCartItemsVFControllerTest {

    public static String quoteNewBuiness = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId(); 
    public static String OppRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
    public static String oppAmendment = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Upsell_Opportunity_Open').getRecordTypeId();
    public static final String PROPOSALNAME = 'SingleTrad3Ramps - New Business';
    public static final String DRAFT = 'Draft';
    public static final String INSRANCEURL = 'https://zscaler--qa.lightning.force.com/lightning/page/home';
    public static final String CLOSEDWON = '6 - Closed Won';
    public static final String QUOTETYPE = 'Quote';
    public static final String NEWLINESTATUS = 'New';

    @TestSetup
    static void setupData(){
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Federal_Deal_Approved__c = true;
        acc.OwnerId = UserInfo.getUserId();
        insert acc;
        
        Product2 prod = getProduct();
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
        createOpp.StageName=CLOSEDWON;
        createOpp.Probability = 95;
        createOpp.CloseDate=system.today();
        insert createOpp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.ownerId = UserInfo.getUserId();
        quote.Proposal_Name__c = PROPOSALNAME;
        quote.SBQQ__Status__c = DRAFT;
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 3;
        quote.SBQQ__Opportunity2__c = createOpp.Id;
        quote.Price_List__c = 'FY21 Single Tier Price List';
        quote.SBQQ__Type__c = QUOTETYPE;
        quote.RecordTypeId = quoteNewBuiness;
        quote.Partner_Program__c = 'Traditional';
        insert quote;
                
        SBQQ__QuoteLine__c quoteLineList = new SBQQ__QuoteLine__c();
        quoteLineList.SBQQ__Product__c = prod.Id;
        quoteLineList.SBQQ__Quote__c = quote.id;
        quoteLineList.SBQQ__Number__c = 5;
        quoteLineList.Line_Status__c = NEWLINESTATUS;
        quoteLineList.SBQQ__Renewal__c = true;
        quoteLineList.SBQQ__PriorQuantity__c = 12;
        quoteLineList.SBQQ__NetPrice__c = 123;
        quoteLineList.Base_Extended_Price__c = 223;
        insert quoteLineList;
        Test.stopTest();
    }

    @isTest
    static void showCartItemsVFTestUnit(){
        Test.startTest();       
        Account acc = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c qut = [SELECT Id, Proposal_Name__c FROM SBQQ__Quote__c];
        
        ApexPages.currentPage().getParameters().put('id',qut.Id);
        ShowCartItemsVFController showCartItem = new ShowCartItemsVFController();
        showCartItem.isPartnerSummit = true;
        showCartItem.isPartnerAdjustment = true;
        showCartItem.isTraditional = true;
        
        showCartItem.InstanceURL = INSRANCEURL;
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
        showCartItem.oldppu = 12.1;
        showCartItem.newppu = 12.1;
        showCartItem.changeofPPU = 12.1;
        showCartItem.onCancel();
        showCartItem.GetChildRecords();
        showCartItem.showChild = true;
        showCartItem.quoteId = String.valueOf(qut.Id);        
        Test.stopTest();     
    }

    @isTest
    static void showCartItemsVFTestUnit1(){
        Test.startTest();             
        Account acc = [SELECT Id FROM Account LIMIT 1];
        SBQQ__Quote__c qut = [SELECT Id, Proposal_Name__c FROM SBQQ__Quote__c];
        ApexPages.currentPage().getParameters().put('id',qut.Id);
        ShowCartItemsVFController showCartItem = new ShowCartItemsVFController();
        showCartItem.isPartnerSummit = true;
        showCartItem.isPartnerAdjustment = true;
        showCartItem.isSummitDiscount = true;
        showCartItem.InstanceURL = INSRANCEURL;
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
        showCartItem.oldppu = 12.1;
        showCartItem.newppu = 12.1;
        showCartItem.changeofPPU = 12.1;
        showCartItem.onCancel();
        showCartItem.GetChildRecords();
        showCartItem.showChild = true;
        showCartItem.quoteId = String.valueOf(qut.Id);
        Test.stopTest();
    }

    @isTest
    static void showCartItemsVFTestUnit2(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity createOpp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.Proposal_Name__c = PROPOSALNAME;
            quote.SBQQ__Status__c = DRAFT;
            quote.SBQQ__Account__c = acc.Id;
            quote.SBQQ__StartDate__c = System.today();
            quote.SBQQ__EndDate__c = System.today() + 3;
            quote.SBQQ__Opportunity2__c = createOpp.Id;
            quote.Price_List__c = 'FY21 Federal Editions Price List';
            quote.SBQQ__Type__c = QUOTETYPE;
            quote.SBQQ__Primary__c = true;
            insert quote;                

            ApexPages.currentPage().getParameters().put('id',quote.Id);
            ShowCartItemsVFController showCartItem = new ShowCartItemsVFController();
            showCartItem.isPartnerSummit = true;
            showCartItem.isPartnerAdjustment = true;
            showCartItem.isTraditional = true;
            
            showCartItem.InstanceURL = INSRANCEURL;
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
    static void showCartItemsEmailTestUnit(){
        //ShowCartItemsEmailController
        Account acc = new Account();
        acc.Name = 'TestAcc';
        insert acc;
        
        ShowCartItemsEmailController showCartItemEmail = new ShowCartItemsEmailController();
        showCartItemEmail.IsShowApprovalSection = true;
        showCartItemEmail.IsEmailTemplateView = true;
        showCartItemEmail.IsShowCartView = true;
        
        Product2 prod = getProduct();
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook 1', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        //Create Quote
        Opportunity createOpp = new Opportunity();
        createOpp.Name='test opp 1';
        createOpp.StageName=CLOSEDWON;
        createOpp.Probability = 95;
        createOpp.CloseDate=system.today();
        insert createOpp;
        
        Test.startTest();

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Proposal_Name__c = PROPOSALNAME;
        quote.SBQQ__Status__c = DRAFT;
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 3;
        quote.SBQQ__Opportunity2__c = createOpp.Id;
        quote.Price_List__c = 'FY21 Single Tier Price List';
        quote.SBQQ__Type__c = QUOTETYPE;
        quote.RecordTypeId = quoteNewBuiness;
        quote.Partner_Program__c = 'Summit - Discount';
        insert quote;
        
        SBQQ__QuoteLine__c quoteLineList = new SBQQ__QuoteLine__c();
        quoteLineList.SBQQ__Product__c = prod.Id;
        quoteLineList.SBQQ__Quote__c = quote.id;
        quoteLineList.SBQQ__Number__c = 5;
        quoteLineList.SBQQ__Renewal__c = true;
        quoteLineList.SBQQ__PriorQuantity__c = 12;
        quoteLineList.SBQQ__NetPrice__c = 123;
        quoteLineList.Base_Extended_Price__c = 223;
        quoteLineList.Line_Status__c = NEWLINESTATUS;
        insert quoteLineList;
                
        SBQQ__Quote__c qut = [SELECT Id, Proposal_Name__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :createOpp.Id];
        
        User adminUser =  SB_TestCPQDataUtility.createUsers(1, 'system', 'Administrator1' , 'System Administrator')[0];
        insert adminUser;
        
        Group indiaDealDesk = new Group(Name='indiaDealDesk1', DeveloperName='indiaDealDesk1',Type='Regular');
        insert indiaDealDesk;

        System.runAs(adminUser) {
            GroupMember gm = new GroupMember(GroupId = indiaDealDesk.Id, UserOrGroupId = adminUser.Id);
            insert gm;
        }
        
        // Create Approver
        sbaa__Approver__c objApprover = new sbaa__Approver__c();
        objApprover.sbaa__User__c = adminUser.Id;
        objApprover.Name = 'Test User SA'; 
        INSERT objApprover;
        
        sbaa__Approver__c objApproverGroup = new sbaa__Approver__c();
        objApproverGroup.sbaa__GroupId__c = indiaDealDesk.Id;
        objApproverGroup.Name = 'Test User IDD'; 
        INSERT objApproverGroup;
        
        showCartItemEmail.accountName = acc.Name;
        showCartItemEmail.quoteName = quote.Proposal_Name__c;
        showCartItemEmail.approvalReason = 'Testing Purpose';
        showCartItemEmail.accountId = acc.Id;
        showCartItemEmail.quoteId = String.valueOf(qut.Id);
        showCartItemEmail.quoteRecList = new List<SBQQ__Quote__c>();
        showCartItemEmail.InstanceURL = INSRANCEURL;
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
    static void showCartItemsEmailTestUnit111(){
        //ShowCartItemsEmailController
        Account acc = new Account();
        acc.Name = 'Testacc';
        insert acc;
        
        ShowCartItemsEmailController showCartItemEmail = new ShowCartItemsEmailController();
        showCartItemEmail.IsShowApprovalSection = true;
        showCartItemEmail.IsEmailTemplateView = true;
        showCartItemEmail.IsShowCartView = true;
        
        Product2 prod = getProduct();
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
        createOpp.Name='test opp 2';
        createOpp.StageName=CLOSEDWON;
        createOpp.Probability = 95;
        createOpp.CloseDate=system.today();
        insert createOpp;
        
        Test.startTest();

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Proposal_Name__c = PROPOSALNAME;
        quote.SBQQ__Status__c = DRAFT;
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 3;
        quote.SBQQ__Opportunity2__c = createOpp.Id;
        quote.Price_List__c = 'FY21 Volume Tier Price List';
        quote.SBQQ__Type__c = QUOTETYPE;
        quote.RecordTypeId = quoteNewBuiness;
        quote.Partner_Program__c = 'Traditional';
        insert quote;
        
        
        SBQQ__QuoteLine__c quoteLineList = new SBQQ__QuoteLine__c();
        quoteLineList.SBQQ__Product__c = prod.Id;
        quoteLineList.SBQQ__Quote__c = quote.id;
        quoteLineList.SBQQ__Number__c = 5;
        quoteLineList.SBQQ__Renewal__c = true;
        quoteLineList.SBQQ__PriorQuantity__c = 12;
        quoteLineList.SBQQ__NetPrice__c = 123;
        quoteLineList.Base_Extended_Price__c = 223;
        quoteLineList.Line_Status__c = NEWLINESTATUS;
        insert quoteLineList;
                
        SBQQ__Quote__c qut = [SELECT Id, Proposal_Name__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :createOpp.Id];
        
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
        showCartItemEmail.InstanceURL = INSRANCEURL;
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
        
        String targetObject = 'SBQQ__Quote__c';
        sbaa__ApprovalRule__c sbaaRule = new sbaa__ApprovalRule__c();
        sbaaRule.Name = 'Discount Rule';
        sbaaRule.sbaa__TargetObject__c = targetObject;
        sbaaRule.sbaa__ApprovalStep__c = 1;
        sbaaRule.Rule_Description__c = 'Please review net variance and manual adjustment on the quote';
        sbaaRule.sbaa__Approver__c = objApprover.Id;
        insert sbaaRule;
        
        sbaa__ApprovalRule__c sbaaRule2 = new sbaa__ApprovalRule__c();
        sbaaRule2.Name = 'Discount Rule2';
        sbaaRule2.sbaa__TargetObject__c = targetObject;
        sbaaRule2.sbaa__ApprovalStep__c = 2;
        sbaaRule2.Rule_Description__c = 'Please review net variance and manual adjustment on the quote';
        sbaaRule2.sbaa__Approver__c = objApprover.Id;
        insert sbaaRule2;
        
        sbaa__ApprovalRule__c sbaR = [SELECT Id, Name,Rule_Description__c FROM sbaa__ApprovalRule__c LIMIT 1];
        String recordField = 'Quote__c';
        String approvalStatus = 'Requested';
        sbaa__Approval__c sbaaApproval = new sbaa__Approval__c();
        sbaaApproval.sbaa__Rule__c = sbaR.Id;
        sbaaApproval.sbaa__ApprovalStep__c = 1;
        sbaaApproval.sbaa__RecordField__c = recordField;
        sbaaApproval.sbaa__Status__c = approvalStatus;
        sbaaApproval.sbaa__CommentsLong__c = 'Rejected ';
        sbaaApproval.sbaa__AssignedTo__c = adminUser.Id;
        sbaaApproval.Quote__c = quote.Id;
        insert sbaaApproval;
        
        sbaa__Approval__c sbaaApproval2 = new sbaa__Approval__c();
        sbaaApproval2.sbaa__Rule__c = sbaaRule2.Id;
        sbaaApproval2.sbaa__ApprovalStep__c = 2;
        sbaaApproval2.sbaa__RecordField__c = recordField;
        sbaaApproval2.sbaa__Status__c = approvalStatus;
        sbaaApproval2.sbaa__CommentsLong__c = 'Rejected the quote ';
        sbaaApproval2.sbaa__AssignedTo__c = adminUser.Id;
        sbaaApproval2.Quote__c = quote.Id;
        insert sbaaApproval2;

        sbaaApproval2.sbaa__Status__c ='Rejected';
        update sbaaApproval2;
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
    static void showCartItemsEmailTestGroupUnit(){
        //ShowCartItemsEmailController
        Account acc = new Account();
        acc.Name = 'Testacc1';
        insert acc;
        
        ShowCartItemsEmailController showCartItemEmail = new ShowCartItemsEmailController();
        showCartItemEmail.IsShowApprovalSection = true;
        showCartItemEmail.IsEmailTemplateView = true;
        showCartItemEmail.IsShowCartView = true;
        
        Product2 prod = getProduct();
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook 1', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        //Create Quote
        Opportunity createOpp = new Opportunity();
        createOpp.Name='test opp 2';
        createOpp.StageName=CLOSEDWON;
        createOpp.Probability = 95;
        createOpp.CloseDate=system.today();
        insert createOpp;
        
        Test.startTest();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Proposal_Name__c = PROPOSALNAME;
        quote.SBQQ__Status__c = DRAFT;
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__StartDate__c = System.today();
        quote.SBQQ__EndDate__c = System.today() + 3;
        quote.SBQQ__Opportunity2__c = createOpp.Id;
        quote.Price_List__c = 'FY21 Single Tier Price List';
        quote.SBQQ__Type__c = QUOTETYPE;
        quote.RecordTypeId = quoteNewBuiness;
        quote.Partner_Program__c = 'Summit - Discount';
        insert quote;
        
        SBQQ__QuoteLine__c quoteLineList = new SBQQ__QuoteLine__c();
        quoteLineList.SBQQ__Product__c = prod.Id;
        quoteLineList.SBQQ__Quote__c = quote.id;
        quoteLineList.SBQQ__Number__c = 5;
        quoteLineList.SBQQ__Renewal__c = true;
        quoteLineList.SBQQ__PriorQuantity__c = 12;
        quoteLineList.SBQQ__NetPrice__c = 123;
        quoteLineList.Base_Extended_Price__c = 223;
        quoteLineList.Line_Status__c = NEWLINESTATUS;
        insert quoteLineList;
                
        SBQQ__Quote__c qut = [SELECT Id, Proposal_Name__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :createOpp.Id];
        
        User adminUser =  SB_TestCPQDataUtility.createUsers(1, 'system', 'Administrator1' , 'System Administrator')[0];
        insert adminUser;

        Group indiaDealDesk = new Group(Name='indiaDealDesk', DeveloperName='indiaDealDesk',Type='Regular');
        insert indiaDealDesk;

        System.runAs(adminUser) {
            GroupMember gm = new GroupMember(GroupId = indiaDealDesk.Id, UserOrGroupId = adminUser.Id);
            insert gm;
        }
        
        // Create Approver
        sbaa__Approver__c objApprover = new sbaa__Approver__c();
        objApprover.sbaa__User__c = adminUser.Id;
        objApprover.Name = 'Test User SA'; 
        INSERT objApprover;
        
        sbaa__Approver__c objApproverGroup = new sbaa__Approver__c();
        objApproverGroup.sbaa__GroupId__c = indiaDealDesk.Id;
        objApproverGroup.Name = 'Test User IDD'; 
        INSERT objApproverGroup;

        showCartItemEmail.accountName = acc.Name;
        showCartItemEmail.quoteName = quote.Proposal_Name__c;
        showCartItemEmail.approvalReason = 'Testing Purpose';
        showCartItemEmail.accountId = acc.Id;
        showCartItemEmail.quoteId = String.valueOf(qut.Id);
        showCartItemEmail.quoteRecList = new List<SBQQ__Quote__c>();
        showCartItemEmail.InstanceURL = INSRANCEURL;
        showCartItemEmail.ApproverId = adminUser.Id;
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
        sbaaRule.sbaa__Approver__c = objApproverGroup.Id;
        insert sbaaRule;
        
        sbaa__ApprovalRule__c sbaR = [SELECT Id, Name,Rule_Description__c FROM sbaa__ApprovalRule__c LIMIT 1];
        
        sbaa__Approval__c sbaaApproval = new sbaa__Approval__c();
        sbaaApproval.sbaa__Rule__c = sbaR.Id;
        sbaaApproval.sbaa__ApprovalStep__c = 1;
        sbaaApproval.sbaa__RecordField__c = 'Quote__c';
        sbaaApproval.sbaa__Status__c = 'Requested';
        sbaaApproval.sbaa__CommentsLong__c = 'Rejected - ';
        sbaaApproval.sbaa__AssignedTo__c = adminUser.Id;
        sbaaApproval.sbaa__Approver__c = objApproverGroup.Id;
        sbaaApproval.Quote__c = quote.Id;
        insert sbaaApproval;
        
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

    private static Product2 getProduct(){
        Product2 newProduct = new Product2(Name = 'Laptop X200', Family = 'Hardware', ProductCode = 'ZCES-SUP-PREM');
        return newProduct;
    }
}