@isTest
public with sharing class CCI_ViewEOBTest {
    @isTest 
    public static void validateShowInvoiceController(){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Member').getRecordTypeId();
		Account acc= new Account(
        RecordTypeID=recordTypeId ,
        FirstName='Test FName',
        LastName='Test LName',
        PersonMailingStreet='test@salesforce.com',
        PersonMailingPostalCode='11224',
        PersonMailingCity='SFO',
        PersonEmail='test@salesforce.com',
        PersonHomePhone='(999) 999-9999',
        PersonMobilePhone='(999) 999-9999'
       
		);
		insert acc;
       	acc.Member_Id__c ='12972630W05';
        update acc;
        CCI_ShowInvoiceController invoice = new CCI_ShowInvoiceController();
        Map<String, Object> inputs =  new Map<String, Object>();
    	Map<String, Object> outputs = new Map<String, Object>();
    	Map<String, Object> options = new Map<String, Object>();
        inputs.put('memberId','1233455');
        inputs.put('claimId','1233455s');
        invoice.invokeMethod('getInvoiceDetails',inputs,outputs,options);
        //invoice.invokeMethod('getInvoiceDetails',null,null,null);
      
    }
}