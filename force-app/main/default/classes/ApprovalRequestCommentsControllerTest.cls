@IsTest
private class ApprovalRequestCommentsControllerTest {

    @IsTest
    private static void test_get_comments() {
        ApprovalRequestCommentsController contr = new ApprovalRequestCommentsController();
        System.debug( contr.comments );

    }
    
}