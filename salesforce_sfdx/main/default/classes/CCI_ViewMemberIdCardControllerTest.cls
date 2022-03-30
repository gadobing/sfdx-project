/*********************************************************************** 
* @ClassName 				: CCI_ViewMemberIdCardControllerTest
  @testClass				: 
* @Description 				: CCI_ViewMemberIdCardControllerTest Class
* @Reason for Class Sharing : CCI_ViewMemberIdCardControllerTest Class
* @Author 					: SFDC
* @RevisionHistory 			: NK
* @Version          Date              Changes made 
    CH00		     02/07/2022	        Initial Draft
************************************************************************/
@isTest
public class CCI_ViewMemberIdCardControllerTest {
    @isTest 
    public static void validateGetMemberCardDetails(){
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
       
        CCI_ViewMemberIdCardController.MemberCardWrapper memCardwrap = new CCI_ViewMemberIdCardController.MemberCardWrapper('memberId','type','format','encoding','content',200,'OK');
    	CCI_ViewMemberIdCardController.MemberCardWrapper memCardwrapper = new CCI_ViewMemberIdCardController.MemberCardWrapper('memberId',404,'Error');
        memCardwrapper = CCI_ViewMemberIdCardController.getMemberCardDetails(acc.Id);
    	acc.Member_Id__c ='12972630W05';
        update acc;
        memCardwrapper = CCI_ViewMemberIdCardController.getMemberCardDetails(acc.Id);
    }
        

}