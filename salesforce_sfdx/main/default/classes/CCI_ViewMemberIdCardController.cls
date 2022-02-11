/*********************************************************************************************
* @ClassName 				: CCI_ViewMemberIdCardController
  @testClass				: CCI_ViewMemberIdCardControllerTest
* @Description 				: LWC Controller Class (CCI_ViewMemberIdCardC)
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: NK
* @Version          Date              Changes made 
    NK		    02/03/2022		  Initial Draft
***********************************************************************************************/
public with sharing class CCI_ViewMemberIdCardController {
    /*************************************************************************************
    @Description : getMemberCardDetails(API callout using IP)
	@Author 	 : SFDC
	@Params 	 : String memberId
	@Return 	 : MemberCardWrapper class 
    **************************************************************************************/
    @AuraEnabled
    public static MemberCardWrapper getMemberCardDetails(string memberId){
       
           Account member = new account();
           member =[ SELECT Id,Member_Id__c FROM ACCOUNT WHERE Id =: memberId ];
           if(member.Member_Id__c == null){
           	if(! Test.isRunningTest()){throw new AuraHandledException('MemberId field is blank on this record. Please populate the MemberId field and try again!');}
            }
            
 			try {
                Map<String, Object> ipOutput = new Map<String, Object> ();
                ipOutput = callIntegrationProcedure('CCI_P8RetrieveMemberCard',member.Member_Id__c);
                if((integer)ipOutput.get('statusCode') !=200 ){
                    MemberCardWrapper memCardwrapper = new MemberCardWrapper();
                    memCardwrapper.memberId 	=   (string) member.Member_Id__c;
                    memCardwrapper.statusCode 	=   (integer)ipOutput.get('statusCode');
                    memCardwrapper.status		=	(string)ipOutput.get('status');
                    return memCardwrapper;
                }
                else{

                    Map<String, Object> ipOutputFile = new Map<String, Object> ();
                    ipOutputFile =(Map<String, Object>)ipOutput.get('file');
                    MemberCardWrapper memCardwrapper = new MemberCardWrapper((string) member.Member_Id__c,(string) ipOutput.get('type'), (string)ipOutputFile.get('format'),(string)ipOutputFile.get('encoding'), (string)ipOutputFile.get('content'),(integer)ipOutput.get('statusCode'),(string)ipOutput.get('status'));
                    return memCardwrapper;
                }
        
        } catch(Exception  e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
            throw new AuraHandledException('The following exception has occurred: ' + e.getMessage()+' Line:' + String.valueOf(e.getLineNumber()));
        }
    }
    public class MemberCardWrapper{
        public MemberCardWrapper(){}
        public MemberCardWrapper(string memberId,String type,string format, string encoding,string content, Integer statusCode, string status){
            this.memberId		=	memberId;
            this.type			=	type;
            this.format		    =	format;
            this.encoding		=	encoding;
            this.content		=	content;
            this.statusCode		=	statusCode;
            this.status		    =	status;
        }
        public MemberCardWrapper(string memberId, Integer statusCode, string status){
            this.memberId		=	memberId;
            this.statusCode		=	statusCode;
            this.status		    =	status;
        }
        @AuraEnabled 
        Public string memberId;
        @AuraEnabled
        Public String type;
        @AuraEnabled
        Public string format;
        @AuraEnabled
        Public string encoding;
        @AuraEnabled
        Public string content;
        @AuraEnabled
        Public Integer statusCode;
        @AuraEnabled
        Public string status;
    }

   /*************************************************************************************
    @Description : callIntegrationProcedure(API callout using IP)
	@Author 	 : SFDC
	@Params 	 : String IPName, String memberIdInput 
	@Return 	 : Map<String, Object>
    **************************************************************************************/
    public static Map<String, Object> callIntegrationProcedure(String IPName, String memberIdInput ) {
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        ipInput.put('memberIdInput', memberIdInput);
        ipOutput = (Map<String, Object>) %vlocity_namespace%.IntegrationProcedureService.runIntegrationService(IPName, ipInput, ipOptions);
        return  ipOutput;
    }

}