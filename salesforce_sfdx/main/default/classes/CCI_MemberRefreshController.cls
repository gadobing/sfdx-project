/*********************************************************************************************
* @ClassName 				: CCI_MemberRefreshController
  @testClass				: CCI_MemberRefreshControllerTest
* @Description 				: LWC Controller Class (CCI_MemberRefresh)
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: NK
* @Version          Date              Changes made 
    NK		    03/06/2022		  Initial Draft
***********************************************************************************************/

public with sharing class CCI_MemberRefreshController {
     /*************************************************************************************
    @Description : refreshMember
	@Author 	 : SFDC
	@Params 	 : String recordId
	@Return 	 : account  
    **************************************************************************************/

    @AuraEnabled
    public static account refreshMember(string recordId){

        account member = [select Id,Last_Refresh_Date__c from account where id =:recordId];
        member.Last_Refresh_Date__c =System.now();
        update member;
        return member;

    }
}