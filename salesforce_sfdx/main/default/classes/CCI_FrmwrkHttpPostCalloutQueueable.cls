/*********************************************************************** 
* @ClassName 				: CCI_FrmwrkHttpPostCalloutQueueable
  @testClass				: 
* @Description 				:  Class
* @Reason for Class Sharing :  Class
* @Author 					: SFDC
* @RevisionHistory 			: CH00
* @Version          Date              Changes made 
    CH00		     02/20/2022		        Initial Draft
************************************************************************/
global class CCI_FrmwrkHttpPostCalloutQueueable implements Queueable,Database.AllowsCallouts {
    global String contentDocumentId;
    global String documentId;
    global String payload;
    global String endpoint;
    global String authHeader;
    global String contentType;
    global Boolean isLoggingEnabled;
    global String messageId;
    global String serviceName;
    global String dynamicParams;
    global String additionalMethodArguments;
    global String retryRecordId;
    global String ipName;
    
    private static final String DUMMY_BODY = 'Dummy';
    private static final String ENDPOINT_PREFIX = 'callout:';
    
    /*************************************************************************************
    @Description : Parametrized Constructor
	@Author 	 : SFDC
	@Params 	 : String contentDocumentIdInput,String documentIdInput,String payloadInput,String endpointInput,
                   String authHeaderInput,String contentTypeInput, Boolean isLoggingEnabledInput, String messageIdInput,
                   String serviceNameInput, String dynamicParamsInput,String additionalMethodArgumentsInput, 
                   String retryRecordIdInput, String ipNameInput
	@Return 	 : None
    **************************************************************************************/
    public CCI_FrmwrkHttpPostCalloutQueueable(String contentDocumentIdInput,String documentIdInput,String payloadInput,String endpointInput,
                                              String authHeaderInput,String contentTypeInput, Boolean isLoggingEnabledInput, String messageIdInput,
                                              String serviceNameInput, String dynamicParamsInput,String additionalMethodArgumentsInput, 
                                              String retryRecordIdInput, String ipNameInput) 
    {
        contentDocumentId = contentDocumentIdInput;
        documentId = documentIdInput;
        payload = payloadInput;
        endpoint = endpointInput;
        authHeader = authHeaderInput;
        contentType = contentTypeInput;
        isLoggingEnabled = isLoggingEnabledInput;
        messageId = messageIdInput;
        serviceName = serviceNameInput;
        dynamicParams = dynamicParamsInput;
        additionalMethodArguments = additionalMethodArgumentsInput;
        retryRecordId = retryRecordIdInput;
        ipName = ipNameInput;
    }
    
    /*************************************************************************************
    @Description : Execute method of the Queueable
	@Author 	 : SFDC
	@Params 	 : QueueableContext qc
	@Return 	 : None
    **************************************************************************************/
    public void execute(QueueableContext qc){
        try{
            ContentVersion cv = [Select Id, VersionData from ContentVersion where ContentDocumentId=:contentDocumentId];
            CCI_P8PostRequestWrapper reqWrapper = (CCI_P8PostRequestWrapper)JSON.deserialize(payload, CCI_P8PostRequestWrapper.class);
            Map<String, String> searchStringMap = new Map<String, String>();
            for(CCI_P8PostRequestWrapper.cls_searchIndexes searchIndex : reqWrapper.searchIndexes){
                searchStringMap.put(searchIndex.name,searchIndex.value);
            }
            reqWrapper.searchIndexes.clear();
            for(String key : searchStringMap.keySet()){
                CCI_P8PostRequestWrapper.cls_searchIndexes searchIndex = new CCI_P8PostRequestWrapper.cls_searchIndexes();
                searchIndex.name = key;
                searchIndex.value = searchStringMap.get(key);
                reqWrapper.searchIndexes.add(searchIndex);
                searchIndex = null;
            }
            searchStringMap = null;
            reqWrapper.image.content = EncodingUtil.base64Encode(cv.VersionData);
            cv = null;
            payload=null;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ENDPOINT_PREFIX+endpoint);
            endpoint=null;
            request.setMethod(CCI_Constants.HTTP_METHOD_POST);
            request.setTimeout(120000);
            request.setHeader(CCI_Constants.HTTP_HEADER_AUTHORIZATION, authHeader);
            request.setHeader(CCI_Constants.HTTP_HEADER_CONTENT_TYPE, contentType);
            request.setBody(JSON.serialize(reqWrapper));
            reqWrapper = null;
			HttpResponse response = new HttpResponse();
            if(!Test.isRunningTest()){
                response = http.send(request);
            }
            else{
                response.setStatusCode(400);
                response.setBody(DUMMY_BODY);
            }
            if(isLoggingEnabled){
                CCI_FrmwrkHttpPostCallout.callLoggingIP(CCI_Constants.INTEGRATION_LOG_FRAMEWORK,documentId,messageId,
                                                        serviceName,request.getBody(),response,dynamicParams,
                                                        additionalMethodArguments,retryRecordId, ipName);
            }
            
            request = null;
            CCI_Document__c documentRecordToUpdate = [SELECT Id,Status__c,Document_Id_Ext__c,Retry_Count__c 
                                                      FROM CCI_Document__c WHERE Id =:documentId LIMIT 1];
            if(response.getStatusCode()==200 || response.getStatusCode()==201){
                documentRecordToUpdate.Status__c = CCI_Constants.STATUS_SUCCESS;
                documentRecordToUpdate.Document_Id_Ext__c = response.getBody();
                CCI_FrmwrkHttpPostCallout.deleteContentDocument(contentDocumentId);
            }
            else{
                CCI_Integration_System_Setting__mdt retryMasterData = CCI_Integration_System_Setting__mdt.getInstance(serviceName);
                if(documentRecordToUpdate.Retry_Count__c < (Integer)retryMasterData.Transport_Error_Max_Retry__c){  
                    documentRecordToUpdate.Status__c = CCI_Constants.STATUS_FAILURE_AWAITING_RETRY;
                    documentRecordToUpdate.Retry_Count__c = documentRecordToUpdate.Retry_Count__c+1;
                }
                else{
                    documentRecordToUpdate.Status__c = CCI_Constants.STATUS_FAILED;
                }
            }
            update documentRecordToUpdate;
            System.debug('Heap Size in future'+Limits.getHeapSize());
            System.debug('Heap Size in future'+Limits.getLimitHeapSize());
        }
        catch (Exception e) { // As part of retry mechanism, log record will be created
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception StackTrace: ' + e.getStackTraceString());
        }
    }
}