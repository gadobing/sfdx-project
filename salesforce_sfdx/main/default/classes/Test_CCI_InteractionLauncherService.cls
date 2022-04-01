@isTest 
public class Test_CCI_InteractionLauncherService {
    @testSetup static void CreateTestRecords() {
        String RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get('Member').getRecordTypeId(); 
        Account member = new Account(RecordTypeId = RecordTypeId, FirstName = 'Salesforce', LastName = 'Tester', PersonEmail = 'testaccount@test.com', PersonBirthdate = Date.newInstance(2004, 03, 03),SSN__c = '1234567890', Medicare_HIC_MBI__c = 'M1234567890',Member_Id__c = 'K1234567890');
        Insert member;
        
        MemberPlan plan = new Memberplan();
        plan.Name = 'Health Plan';
        plan.MemberId = member.Id;
        Plan.Product_Line__c = 'Exchange ';
        Insert plan;
    }
    
    static testMethod void validateMemberSearch() {
        Map<String,Object> Input = new Map<String,Object>();
        Map<String,Object> Output = new Map<String,Object>();
        Map<String,Object> Options = new Map<String,Object>();
        Options.put('BusinessLine','Exchange');
        Options.put('MemberId','K1234567890');
        Options.put('FirstName','Salesforce');
        Options.put('LastName','Tester');
        Options.put('SSN','1234567890');
        Options.put('DOB','03/03/2004');
        Options.put('MedicareHIC','M1234567890');
        CCI_InteractionLauncherService CCIService = new CCI_InteractionLauncherService();
        Boolean result = CCIService.invokeMethod('searchMember',Input,Output,Options);
        system.assertEquals(true, result);
    }
    
    static testMethod void validateMemberSearchByPersonBirthDate() {
        Map<String,Object> Input = new Map<String,Object>();
        Map<String,Object> Output = new Map<String,Object>();
        Map<String,Object> Options = new Map<String,Object>();
        Options.put('BusinessLine','Exchange');
        Options.put('MemberId','K1234567890');
        Options.put('FirstName','Salesforce');
        Options.put('LastName','Tester');
        Options.put('SSN','1234567890');
        Options.put('DOB','03-03-2004');
        Options.put('MedicareHIC','M1234567890');
        CCI_InteractionLauncherService CCIService = new CCI_InteractionLauncherService();
        Boolean result = CCIService.invokeMethod('searchMember',Input,Output,Options);
        system.assertEquals(false, result);
    }
    
    
}