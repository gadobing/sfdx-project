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
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean ret = true;
        try {
            if (methodName.equals('utilityMethod')) {
                utilityMethod(inputMap,outMap);
                system.debug('invikeMethod: Heap size is ' + Limits.getHeapSize() + ' enforced is ' + Limits.getLimitHeapSize());
            }
        } catch (Exception e) { // As part of retry mechanism, log record will be created
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception StackTrace: ' + e.getStackTraceString());
            //outMap.put('error', e.getMessage() + ' - ' + e.getStackTraceString());
            ret = false;
        }
        return ret;
    }
    
    global static void utilityMethod(Map<String, Object> inputMap,Map<String, Object> outMap){
        system.debug('UtilityMethod: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());

        if(String.valueOf(inputMap.get('utilityMethodName'))=='P8PostUpload'){
            String additionalMethodArguments = String.valueOf(inputMap.get('additionalMethodArguments'));
            String contentDocumentId, documentId;
            List<String> paramList = additionalMethodArguments.split('&');
            for(String param : paramList){
                if(param.contains('contentDocumentId')){
                    contentDocumentId = param.split('=')[1];
                }
                else{
                    documentId = param.split('=')[1];
                }
            }
            System.debug('Payload--->'+JSON.serialize(inputMap.get('Payload')));
            doFutureCallout(contentDocumentId,documentId, JSON.serialize(inputMap.get('Payload')),
                            String.valueOf(inputMap.get('endpoint')),String.valueOf(inputMap.get('authorization')),
                            String.valueOf(inputMap.get('contentType')),Boolean.valueOf(inputMap.get('isLoggingEnabled')), 
                            String.valueOf(inputMap.get('Message_ID')),String.valueOf(inputMap.get('Service_Name')),
                            String.valueOf(inputMap.get('DynamicParams')));
        }
        System.debug('Heap Size'+Limits.getHeapSize());
        System.debug('Heap Size'+Limits.getLimitHeapSize());
    }
    
    @future(callout=true)
    public static void doFutureCallout(String contentDocumentId,String documentId,String payload,String endpoint,
                                       String authHeader,String contentType, Boolean isLoggingEnabled, String messageId,
                                      String serviceName, String dynamicParams)
    {   
        try{
            ContentVersion cv = [Select Id, VersionData from ContentVersion where ContentDocumentId=:contentDocumentId];
            System.debug('--->'+payload);
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
            request.setEndpoint('callout:'+endpoint);
            endpoint=null;
            request.setMethod('POST');
            request.setTimeout(120000);
            request.setHeader('Authorization', authHeader);
            request.setHeader('Content-Type', contentType);
            request.setBody(JSON.serialize(reqWrapper));
            reqWrapper = null;
			HttpResponse response = new HttpResponse();
            if(!Test.isRunningTest()){
                response = http.send(request);
            }
            else{
                response.setStatusCode(200);
                response.setBody('Dummy');
            }
            if(isLoggingEnabled){
                callLoggingIP('CCI_IntregrationLogFramework',documentId,messageId,serviceName,request.getBody(),response,dynamicParams);
            }
            
            request = null;
            CCI_Document__c documnetRecordToUpdate = [SELECT Id,Status__c,Document_Id_Ext__c 
                                                      FROM CCI_Document__c WHERE Id =:documentId LIMIT 1];
            if(response.getStatusCode()==200 || response.getStatusCode()==201){
                documnetRecordToUpdate.Status__c = 'Success';
                documnetRecordToUpdate.Document_Id_Ext__c = response.getBody();
                deleteContentDocument(contentDocumentId);
            }
            else{
                documnetRecordToUpdate.Status__c = 'Failed - Awaiting Retry';
            }
            update documnetRecordToUpdate;
            System.debug('Heap Size in future'+Limits.getHeapSize());
            System.debug('Heap Size in future'+Limits.getLimitHeapSize());
        }
        catch (Exception e) { // As part of retry mechanism, log record will be created
            System.debug('Exception Message: ' + e.getMessage());
            System.debug('Exception StackTrace: ' + e.getStackTraceString());
        }
    }
    
    private static void callLoggingIP(String IPName, String iRQRId, String messageID, 
                                      String SystemName, String payload, HttpResponse response,
                                      String dynamicParams) 
    {   

        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        ipInput.put('Message_ID', messageID);
        ipInput.put('Parent_Record_SFDC_ID', iRQRId);
        ipInput.put('RequestPayload', (payload.length()>1000? payload.substring(0, 1000) : payload));
        ipInput.put('Service_Name', SystemName);
        ipInput.put('statusCode', response.getStatusCode());
        ipInput.put('headers', response);
        ipInput.put('payload', response.getBody());
        ipInput.put('procedureName', IPName);
        ipInput.put('DynamicParams', dynamicParams);
        payload = null;
        iRQRId = null;
        messageID = null;
        SystemName=null;
        response = null;
		dynamicParams = null;        
        ipOutput = (Map<String, Object>) %vlocity_namespace%.IntegrationProcedureService.runIntegrationService(
            IPName, ipInput, ipOptions);
       
    }
    
    private static void deleteContentDocument(String contentDocumentId){
        

        if(contentDocumentId!=null && contentDocumentId!=''){
            delete [Select id from ContentDocument where Id=:contentDocumentId LIMIT 1];
        }
        
    }
    
}