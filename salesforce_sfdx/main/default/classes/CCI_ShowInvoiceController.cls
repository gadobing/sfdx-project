// /*********************************************************************************************
// * @ClassName 				: CCI_ShowInvoiceController
//   @testClass				: CCI_ShowInvoiceControllerTest
// * @Description 				: LWC Controller Class (CCI_ShowInvoice)
// * @Reason for Class Sharing : 
// * @Author 					: SFDC
// * @RevisionHistory 			: NK
// * @Version          Date              Changes made 
//     NK		    02/22/2022		  Initial Draft
// ***********************************************************************************************/

// public with sharing class CCI_ShowInvoiceController {
//     public CCI_ShowInvoiceController() {

//     }

//       /*************************************************************************************
//     @Description : getMemberCardDetails(API callout using IP)
// 	@Author 	 : SFDC
// 	@Params 	 : String memberId
// 	@Return 	 : MemberCardWrapper class 
//     **************************************************************************************/
//     @AuraEnabled
//     public static InvoiceWrapper getInvoiceDetails(string memberId, string invoiceId){
       
            
//  			try {
//                 Map<String, Object> ipOutput = new Map<String, Object> ();
//                 ipOutput = callIntegrationProcedure('CCI_RetrieveInvoice',memberId);
//                 if((integer)ipOutput.get('statusCode') !=200 ){
//                     InvoiceWrapper invoiceDetails = new InvoiceWrapper();
//                     invoiceDetails.memberId 	=   memberId;
//                     invoiceDetails.statusCode 	=   (integer)ipOutput.get('statusCode');
//                     invoiceDetails.status		=	(string)ipOutput.get('status');
//                     return invoiceDetails;
//                 }
//                 else{

//                   //  Map<String, Object> ipOutputFile = new Map<String, Object> ();
//                  //   ipOutputFile =(Map<String, Object>)ipOutput.get('file');
//                     InvoiceWrapper invoiceDetails = new InvoiceWrapper((string) memberId,(string) invoiceId, (string)ipOutput.get('format'),(string)ipOutput.get('encoding'), (string)ipOutput.get('content'),(integer)ipOutput.get('statusCode'),(string)ipOutput.get('status'));
//                     return invoiceDetails;
//                 }
        
//         } catch(Exception  e) {
//         System.debug('The following exception has occurred: ' + e.getMessage());
//             throw new AuraHandledException('The following exception has occurred: ' + e.getMessage()+' Line:' + String.valueOf(e.getLineNumber()));
//         }
//     }
//     public class InvoiceWrapper{
//         public InvoiceWrapper(){}
//         public InvoiceWrapper(string memberId,String invoice,string format, string encoding,string content, Integer statusCode, string status){
//             this.memberId		=	memberId;
//             this.invoiceId		=	invoice;
//             this.format		    =	format;
//             this.encoding		=	encoding;
//             this.content		=	content;
//             this.statusCode		=	statusCode;
//             this.status		    =	status;
//         }
//         public InvoiceWrapper(string memberId, Integer statusCode, string status){
//             this.memberId		=	memberId;
//             this.statusCode		=	statusCode;
//             this.status		    =	status;
//         }
//         @AuraEnabled 
//         Public string memberId;
//         @AuraEnabled
//         Public String invoiceId;
//         @AuraEnabled
//         Public string format;
//         @AuraEnabled
//         Public string encoding;
//         @AuraEnabled
//         Public string content;
//         @AuraEnabled
//         Public Integer statusCode;
//         @AuraEnabled
//         Public string status;
//     }

//    /*************************************************************************************
//     @Description : callIntegrationProcedure(API callout using IP)
// 	@Author 	 : SFDC
// 	@Params 	 : String IPName, String memberIdInput 
// 	@Return 	 : Map<String, Object>
//     **************************************************************************************/
//     public static Map<String, Object> callIntegrationProcedure(String IPName, String memberIdInput ) {
//         Map<String, Object> ipInput = new Map<String, Object> ();
//         Map<String, Object> ipOutput = new Map<String, Object> ();
//         Map<String, Object> ipOptions = new Map<String, Object> ();
//       //  ipInput.put('memberIdInput', memberIdInput);
//         ipOutput = (Map<String, Object>) %vlocity_namespace%.IntegrationProcedureService.runIntegrationService(IPName, ipInput, ipOptions);
//         return  ipOutput;
//     }
// }


global with sharing class CCI_ShowInvoiceController implements omnistudio.VlocityOpenInterface2{
    
    public Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputs,
    Map<String, Object> outputs,
    Map<String, Object> options
    ) {
        try {
        if (methodName == 'getInvoiceDetails') {
            return getInvoiceDetails(inputs, outputs, options);
        }
        } catch (Exception e) {
        outputs.put('Error', e.getMessage());
        outputs.put('ErrorLine', e.getLineNumber());
        outputs.put('ErrorType', e.getTypeName());
        outputs.put('MethodName', methodName);
        System.debug('ERROR: ------> ' + e);
        }

        return false;
    }

    private static Boolean getInvoiceDetails( Map<String, Object> inputs, Map<String, Object> outputs, Map<String, Object> options)
    {

        String memberId = (String)inputs.get('memberId');
        String invoiceId = (String)inputs.get('invoiceId'); 

            
        try {
            Map<String, Object> ipOutput = new Map<String, Object> ();
            ipOutput = callIntegrationProcedure('CCI_RetrieveInvoice',memberId);
            Integer statusCode = (integer)ipOutput.get('statusCode');
            if( statusCode !=200 ){
                outputs.put('memberId', memberId);
                outputs.put('statusCode', statusCode);
                outputs.put('status', (string)ipOutput.get('status'));
                return true;
            }
            else{
                outputs.put('memberId', memberId);
                outputs.put('invoiceId', invoiceId);
                outputs.put('format', (string)ipOutput.get('format'));
                outputs.put('encoding', (string)ipOutput.get('encoding'));
                outputs.put('content', (string)ipOutput.get('content'));
                outputs.put('statusCode', statusCode);
                outputs.put('status', (string)ipOutput.get('status'));
                return true;
            }
        } catch(Exception  e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
            throw new AuraHandledException('The following exception has occurred: ' + e.getMessage()+' Line:' + String.valueOf(e.getLineNumber()));
        }
    }

    private static Map<String, Object> callIntegrationProcedure(String IPName, String memberIdInput ) {
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        return (Map<String, Object>) omnistudio.IntegrationProcedureService.runIntegrationService(IPName, ipInput, ipOptions);
    }
}