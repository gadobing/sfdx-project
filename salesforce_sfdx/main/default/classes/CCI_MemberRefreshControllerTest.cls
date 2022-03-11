/*********************************************************************************************
* @ClassName 				: CCI_MemberRefreshControllerTest
  @testClass				: Test Class for CCI_MemberRefreshController
* @Description 				: Test Class
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: NK
* @Version          Date              Changes made 
    NK		    03/07/2022		  Initial Draft
***********************************************************************************************/
@isTest
public class CCI_MemberRefreshControllerTest {
	 @isTest 
    public static void validateMemberRefresh(){
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
  		//CCI_MemberRefreshController refresh  =  new CCI_MemberRefreshController();
        CCI_MemberRefreshController.refreshMember(string.valueOf(acc.Id));
        
      
    }
}