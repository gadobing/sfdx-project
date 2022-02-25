/*********************************************************************** 
* @ClassName 				: CCI_FrmwrkHttpPostCallout
  @testClass				: 
* @Description 				:  Class
* @Reason for Class Sharing :  Class
* @Author 					: SFDC
* @RevisionHistory 			: CH00
* @Version          Date              Changes made 
    CH00		     02/16/2022		        Initial Draft
************************************************************************/
global with sharing class CCI_FrmwrkHttpPostCallout implements %vlocity_namespace%.VlocityOpenInterface {
    
    private static final String UTILITY_METHOD_NAME 			= 'utilityMethodName';
    private static final String ADDITIONAL_METHOD_ARGUEMENTS 	= 'additionalMethodArguments';
    private static final String CONTENT_DOCUMENT_ID 			= 'contentDocumentId';
    private static final String PAYLOAD 						= 'Payload';
    private static final String PAYLOAD_LOWER 					= 'payload';
    private static final String ENDPOINT 						= 'endpoint';
    private static final String AUTHORIZATION 					= 'authorization';
    private static final String CONTENT_TYPE 					= 'contentType';
    private static final String IS_LOGGING_ENABLED 				= 'isLoggingEnabled';
    private static final String MESSAGE_ID 						= 'Message_ID';
    private static final String SERVICE_NAME 					= 'Service_Name';
    private static final String DYNAMIC_PARAMS 					= 'DynamicParams';
    private static final String RETRY_RECORD_ID 				= 'retryRecordId';
    private static final String IP_NAME 						= 'ipName';
	private static final String PARENT_RECORD_SFDC_ID 			= 'Parent_Record_SFDC_ID';
	private static final String REQUEST_PAYLOAD 				= 'RequestPayload';
    private static final String STATUS_CODE 					= 'statusCode';
    private static final String PROCEDURE_NAME 					= 'procedureName';
    private static final String HEADERS 						= 'headers';
    private static final String SPLIT_AND 						= '&';
    private static final String SPLIT_EQUAL 					= '=';
    
    /*************************************************************************************
    @Description : Called from the IP
	@Author 	 : SFDC
	@Params 	 : String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options
	@Return 	 : Boolean
    **************************************************************************************/
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean ret = true;
        try {
            if (methodName.equals(CCI_Constants.UTILITY_METHOD)) {
                utilityMethod(inputMap,outMap);
                system.debug('invokeMethod: Heap size is ' + Limits.getHeapSize() + ' enforced is ' + Limits.getLimitHeapSize());
            }
        } catch (Exception e) { // As part of retry mechanism, log record will be created
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception StackTrace: ' + e.getStackTraceString());
            ret = false;
        }
        return ret;
    }
    
    /*************************************************************************************
    @Description : Used for the callout for P8 Upload document
	@Author 	 : SFDC
	@Params 	 : Map<String, Object> inputMap,Map<String, Object> outMap
	@Return 	 : None
    **************************************************************************************/
    global static void utilityMethod(Map<String, Object> inputMap,Map<String, Object> outMap){
        system.debug('UtilityMethod: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());

        if(String.valueOf(inputMap.get(UTILITY_METHOD_NAME))==CCI_Constants.P8_POST_UPLOAD){
            String additionalMethodArguments = String.valueOf(inputMap.get(ADDITIONAL_METHOD_ARGUEMENTS));
            String contentDocumentId, documentId;
            List<String> paramList = additionalMethodArguments.split(SPLIT_AND);
            for(String param : paramList){
                if(param.contains(CONTENT_DOCUMENT_ID)){
                    contentDocumentId = param.split(SPLIT_EQUAL)[1];
                }
                else{
                    documentId = param.split(SPLIT_EQUAL)[1];
                }
            }
            System.debug('Payload--->'+JSON.serialize(inputMap.get(PAYLOAD)));
            System.enqueueJob(new CCI_FrmwrkHttpPostCalloutQueueable(contentDocumentId,documentId, JSON.serialize(inputMap.get(PAYLOAD)),
                                                                     String.valueOf(inputMap.get(ENDPOINT)),String.valueOf(inputMap.get(AUTHORIZATION)),
                                                                     String.valueOf(inputMap.get(CONTENT_TYPE)),Boolean.valueOf(inputMap.get(IS_LOGGING_ENABLED)), 
                                                                     String.valueOf(inputMap.get(MESSAGE_ID)),String.valueOf(inputMap.get(SERVICE_NAME)),
                                                                     String.valueOf(inputMap.get(DYNAMIC_PARAMS)), String.valueOf(inputMap.get(ADDITIONAL_METHOD_ARGUEMENTS)),
                                                                     String.valueOf(inputMap.get(RETRY_RECORD_ID)),String.valueOf(inputMap.get(IP_NAME))));
        }
        System.debug('Heap Size'+Limits.getHeapSize());
        System.debug('Heap Size'+Limits.getLimitHeapSize());
    }
    
    
    /*************************************************************************************
    @Description : Call the IP
	@Author 	 : SFDC
	@Params 	 : String IPName, String iRQRId, String messageID, String SystemName, String payload, HttpResponse response,
                   String dynamicParams, String additionalMethodArguments,String retryRecordId, String ipNameToRetry
	@Return 	 : None
    **************************************************************************************/
    public static void callLoggingIP(String IPName, String iRQRId, String messageID, 
                                     String SystemName, String payload, HttpResponse response,
                                     String dynamicParams, String additionalMethodArguments,
                                     String retryRecordId, String ipNameToRetry) 
    {   

        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        ipInput.put(MESSAGE_ID, messageID);
        ipInput.put(PARENT_RECORD_SFDC_ID, iRQRId);
        ipInput.put(REQUEST_PAYLOAD, (payload.length()>1000? payload.substring(0, 1000) : payload));
        ipInput.put(SERVICE_NAME, SystemName);
        ipInput.put(STATUS_CODE, response.getStatusCode());
        ipInput.put(HEADERS, response);
        ipInput.put(PAYLOAD_LOWER, response.getBody());
        ipInput.put(PROCEDURE_NAME, ipNameToRetry);
        ipInput.put(DYNAMIC_PARAMS, dynamicParams);
        ipInput.put(ADDITIONAL_METHOD_ARGUEMENTS, additionalMethodArguments);
        ipInput.put(RETRY_RECORD_ID, retryRecordId);
        ipInput.put(IP_NAME, ipNameToRetry);
        payload = null;
        iRQRId = null;
        messageID = null;
        SystemName=null;
        response = null;
        dynamicParams = null;
        additionalMethodArguments = null;
        retryRecordId = null;  
        ipNameToRetry = null;
        ipOutput = (Map<String, Object>) %vlocity_namespace%.IntegrationProcedureService.runIntegrationService(
            IPName, ipInput, ipOptions);
       
    }
    
    /*************************************************************************************
    @Description : Delete the attached document when the callout is successful
	@Author 	 : SFDC
	@Params 	 : String contentDocumentId
	@Return 	 : None
    **************************************************************************************/
    public static void deleteContentDocument(String contentDocumentId){
        if(contentDocumentId!=null && contentDocumentId!=''){
            delete [Select id from ContentDocument where Id=:contentDocumentId LIMIT 1];
        }
        
    }
    
}