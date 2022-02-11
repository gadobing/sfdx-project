/*********************************************************************************************
* @ClassName 				: CCI_GenericUtility
  @testClass				: CCI_GenericUtilityTest
* @Description 				: Used for P8DocumentUploadBackendProcess IP
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: CH00
* @Version          Date              Changes made 
    CH00		    2/11/2022		  Initial Draft
***********************************************************************************************/
global class CCI_GenericUtility implements %vlocity_namespace%.VlocityOpenInterface{
    
    /*************************************************************************************
    @Description : Used for P8DocumentUploadBackendProcess IP
	@Author 	 : SFDC
	@Params 	 : String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options
	@Return 	 : Boolean
    **************************************************************************************/
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean ret = true;
        try {
            if (methodName.equals(CCI_Constants.GET_BASE64STRING)) {
                getBase64String(inputMap,outMap);
            }
        } catch (Exception e) {
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception StackTrace: ' + e.getStackTraceString());
            outMap.put('error', e.getMessage() + ' - ' + e.getStackTraceString());
            ret = false;
        }
        return ret;
    }
    
    /*************************************************************************************
    @Description : Used for getting Base64String
	@Author 	 : SFDC
	@Params 	 : Map<String, Object> inputMap,Map<String, Object> outMap
	@Return 	 : None
    **************************************************************************************/
    global static void getBase64String(Map<String, Object> inputMap,Map<String, Object> outMap){
        String contentDocumentId = String.valueOf(inputMap.get(CCI_Constants.CONTENT_DOCUMENT_ID));
        transient ContentVersion cv = [Select Id, VersionData from ContentVersion where ContentDocumentId=:contentDocumentId];
        System.debug('----->'+EncodingUtil.base64Encode(cv.VersionData));
        outMap.put(CCI_Constants.BASE64STRING, EncodingUtil.base64Encode(cv.VersionData));
    }
}