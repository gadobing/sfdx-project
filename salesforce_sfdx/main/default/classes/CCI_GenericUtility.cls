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
        System.debug('Heap Size--->'+Limits.getHeapSize());
        System.debug('Heap Size--->'+Limits.getLimitHeapSize());
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
        ContentVersion cv = [Select Id, VersionData from ContentVersion where ContentDocumentId=:contentDocumentId];
        
        outMap.put(CCI_Constants.BASE64STRING, EncodingUtil.base64Encode(cv.VersionData));
        System.debug('--->'+JSON.serialize(outMap));
        cv = null;
        System.debug('Heap Size'+Limits.getHeapSize());
        System.debug('Heap Size'+Limits.getLimitHeapSize());
    }
}