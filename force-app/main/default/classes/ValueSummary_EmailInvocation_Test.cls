@istest
public class ValueSummary_EmailInvocation_Test{
    @isTest static void testgenerateValsum() {
        Account account = new Account(Name = 'Zscaler');
        insert account;
        ValueSummary_EmailInvocation.checkdomain(account.Id);
        ValueSummary_EmailInvocation_Lightning.checkdomain(account.Id);
        
    }
}