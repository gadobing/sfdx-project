@isTest
private class CCI_Five9_AccountSearchTest {

    @TestSetup
    static void makeData(){
        Account provider = new Account();
        provider.FirstName = 'Test';
        provider.LastName = 'Provider';
        provider.RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Provider').getRecordTypeId();
        provider.NPI__c = '12345';

        Account member = new Account();
        member.FirstName = 'Test';
        member.LastName = 'Member';
        member.RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Member').getRecordTypeId();

        insert new List<Account>{provider, member};

        MemberPlan plan = new MemberPlan();
        plan.Name = 'Test Plan';
        plan.MemberId = member.Id;
        plan.MemberNumber = '11223344';
        insert plan;
    }

    @isTest
    private static void testSearchProviderByNPI(){

        PageReference pageRef = Page.CCIFive9ViewAccount;

        Test.setCurrentPage(pageRef);

        CCI_Five9_AccountSearch testController = new CCI_Five9_AccountSearch();

        ApexPages.currentPage().getParameters().put('npi', '12345');

        Test.startTest();
        testController.search();
        Test.stopTest();

        System.assertEquals(1, testController.acc.size());

    }

    @isTest
    private static void testSearchMemberByMemberId(){

        PageReference pageRef = Page.CCIFive9ViewAccount;

        Test.setCurrentPage(pageRef);

        CCI_Five9_AccountSearch testController = new CCI_Five9_AccountSearch();

        ApexPages.currentPage().getParameters().put('memberid', '11223344');

        Test.startTest();
        testController.search();
        Test.stopTest();

        System.assertEquals(1, testController.acc.size());

    }

    @isTest
    private static void testSearchSearchAndredirect(){

        PageReference pageRef = Page.CCIFive9ViewAccount;

        Test.setCurrentPage(pageRef);

        CCI_Five9_AccountSearch testController = new CCI_Five9_AccountSearch();

        ApexPages.currentPage().getParameters().put('memberid', '11223344');
        ApexPages.currentPage().getParameters().put('intent', 'Behavioral Health Clarifier');

        Test.startTest();
        testController.searchAndredirect();
        Test.stopTest();

        System.assertEquals(1, testController.acc.size());

    }
}