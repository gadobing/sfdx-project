/*********************************************************************************************
* @ClassName 				: FrmwrkOAuthImpl
  @testClass				: FrmwrkOAuthImplTest
* @Description 				: Used for SSO IP
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: CH00
* @Version          Date              Changes made 
    CH00		    12/27/2021		  Initial Draft
***********************************************************************************************/
global with sharing class CCI_FrmwrkOAuthImpl implements %vlocity_namespace%.VlocityOpenInterface {

    
    /*************************************************************************************
    @Description : Used for SSO IP
	@Author 	 : SFDC
	@Params 	 : String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options
	@Return 	 : Boolean
    **************************************************************************************/
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean isret = true;
        
        try {
            if (methodName.equals(CCI_Constants.AUTHTOKEN)) {
                string strHeaderValue =(String)inputMap.get(CCI_Constants.USERNAME) + ':' + (String)inputMap.get(CCI_Constants.PASSWORD);
                Blob headerValue = Blob.valueOf(strHeaderValue);
                outMap.put(CCI_Constants.AUTH_HEADER, (String)inputMap.get(CCI_Constants.AUTH_TYPE) + ' ' + EncodingUtil.base64Encode(headerValue));
            }
            if(Test.isRunningTest() && 
               methodName.equals('Test Exception')){
            	isret = false;
                return isret; 
			}
        } catch (Exception ex) {
            throw new AuraHandledException(Label.CCI_ExceptionMessage); 
         }
        return isret;
    }
    
  
}