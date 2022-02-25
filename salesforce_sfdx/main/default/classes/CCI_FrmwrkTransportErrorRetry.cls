/*********************************************************************************************
* @ClassName 				: CCI_FrmwrkTransportErrorRetry
  @testClass				: FrmwrkTransportErrorRetryTest
* @Description 				: Test class of frmwrkTransportErrorRetry
* @Reason for Class Sharing : 
* @Author 					: SFDC
* @RevisionHistory 			: CH00
* @Version          Date              Changes made 
    CH00		    12/27/2021		  Initial Draft
***********************************************************************************************/
global with sharing class CCI_FrmwrkTransportErrorRetry implements %vlocity_namespace%.VlocityOpenInterface {
    
    // Instance variables in order of visibility
    global String recordId;
    global String retryRequestId;
    global Integer retryCount;
    global String messageID;
    global String path;
    global String payload;
    global String ipName;
    global String systemName;
    global String additionalMethodArguments;
    global List<CCI_Integration_System_Setting__mdt> mdtSettings;
    global CCI_Integration_Error_Retry__c fmwkBatchProcessLog;
    
    //private strings
    private static final String JOB_PREFIX = 'Retry Integration Framework - ';
    private static final String PARENT_RECORD_ID = 'ParentRecordId';
    private static final String SYSTEM_NAME = 'SystemName';
	private static final String ERROR_OBJECT_LOG_ID = 'ErrorObjectLogId';
    private static final String MAX_RETRY_LIMIT_MESSAGE_1 = '\nMax Retry Limit Reached! \nMax retry allowed: ';
	private static final String MAX_RETRY_LIMIT_MESSAGE_2 = '\nNumber of retries already attempted: ';


    /*************************************************************************************
    @Description : Called from the IP
	@Author 	 : SFDC
	@Params 	 : String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options
	@Return 	 : Boolean
    **************************************************************************************/
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean ret = true;
        try {
            if (methodName.equals(CCI_Constants.RETRY_REQUEST_METHOD)) {
                retryRequest(inputMap);
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
    @Description : Used for the retry mechanism
	@Author 	 : SFDC
	@Params 	 : Map<String, Object> inputMap
	@Return 	 : None
    **************************************************************************************/
    public void retryRequest(Map<String, Object> inputMap) {
        if (String.isNotBlank(String.valueOf(inputMap.get(PARENT_RECORD_ID)))) {
            this.systemName = String.valueOf(inputMap.get(SYSTEM_NAME));
            this.retryRequestId = (Id) String.valueOf(inputMap.get(ERROR_OBJECT_LOG_ID));
            this.fmwkBatchProcessLog = (CCI_Integration_Error_Retry__c) [SELECT Id,Retry_Count__c,Retry_Status__c,
                                                                         Error_Message__c
                                                                         FROM CCI_Integration_Error_Retry__c 
                                                                         WHERE Id = :this.retryRequestId LIMIT 1];
            setmdtSettings();
            if (this.mdtSettings.size() > 0) {
                Integer retrytimeInterval = (Integer) this.mdtSettings[0].Transport_Layer_Retry_Delay__c;
                Integer maxRetries = (Integer) this.mdtSettings[0].Transport_Error_Max_Retry__c;
                if (this.fmwkBatchProcessLog.Retry_Count__c < maxRetries) {
                    Integer batchSize = 1;
                    List<CronTrigger> cronTriggers = [SELECT Id, NextFireTime, CronJobDetail.Name FROM CronTrigger
                                                      WHERE CronJobDetail.Name LIKE :'%' + this.systemName + '%' AND NextFireTime != NULL];
                    if(cronTriggers.isEmpty()){
                        CCI_FrmwrkRetryCalloutBatch batchJob = new CCI_FrmwrkRetryCalloutBatch(this.systemName);
                        String jobDescription = JOB_PREFIX + this.systemName + ' - ' + System.now();
                        System.scheduleBatch(batchJob, jobDescription, retrytimeInterval, batchSize);//scheduling batch for resubmission of network failed orders. 
                    }
                    updateRQRBatch(CCI_Constants.STATUS_RESUBMISSION_IN_PROGRESS, (Integer) this.fmwkBatchProcessLog.Retry_Count__c+1, null);
                }
                else if(!(this.mdtSettings[0].Transport_Error_Max_Retry__c==0)) {
                    updateRQRBatch(CCI_Constants.STATUS_ERROR, null,this.fmwkBatchProcessLog.Error_Message__c + MAX_RETRY_LIMIT_MESSAGE_1
                            + this.mdtSettings[0].Transport_Error_Max_Retry__c + MAX_RETRY_LIMIT_MESSAGE_2 + (Integer) this.fmwkBatchProcessLog.Retry_Count__c);
                }
                else{
                    updateRQRBatch(CCI_Constants.STATUS_ERROR, 0, null);
                }
            }
            
            
        }
    }
    
    /*************************************************************************************
    @Description : Used to update the status of the error retry object
	@Author 	 : SFDC
	@Params 	 : String status,  Integer retryCount, String errorMessage
	@Return 	 : None
    **************************************************************************************/
    private void updateRQRBatch(String status, Integer retryCount, String errorMessage) {
        this.fmwkBatchProcessLog.Retry_Status__c = status;  
        if(errorMessage!=null){
            this.fmwkBatchProcessLog.Error_Message__c = errorMessage;
        }
        if(retryCount!=null){
            this.fmwkBatchProcessLog.Retry_Count__c = retryCount;
        }
        update this.fmwkBatchProcessLog;
    }

    /*************************************************************************************
    @Description : Returns the Metadata record
	@Author 	 : SFDC
	@Params 	 : None
	@Return 	 : None
    **************************************************************************************/
    private void setmdtSettings() {
        this.mdtSettings = [
                SELECT  Transport_Layer_Retry_Delay__c, Transport_Error_Max_Retry__c
                FROM   CCI_Integration_System_Setting__mdt
                WHERE System_Name__c = :this.systemName
                LIMIT 1
        ];
    
}
}