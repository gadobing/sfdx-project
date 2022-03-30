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
    global List<CCI_Integration_System_Setting__mdt> mdtSettings;
    global CCI_Integration_Error_Retry__c fmwkBatchProcessLog;

    /*************************************************************************************
    @Description : Called from the IP
	@Author 	 : SFDC
	@Params 	 : String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options
	@Return 	 : Boolean
    **************************************************************************************/
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean ret = true;
        try {
            if (methodName.equals('retryRequest')) {
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
        System.debug('Here');
        if (String.isNotBlank(String.valueOf(inputMap.get('ParentRecordId')))) {
            this.recordId = String.valueOf(inputMap.get('ParentRecordId'));
            this.retryRequestId = (Id) String.valueOf(inputMap.get('ErrorObjectLogId'));
            this.systemName = String.valueOf(inputMap.get('SystemName'));
            this.path = String.valueOf(inputMap.get('Path'));
            this.messageID = String.valueOf(inputMap.get('MessageID'));
            this.payload = String.valueOf(inputMap.get('Payload'));
            this.ipName = String.valueOf(inputMap.get('IntegrationProcedureName'));
            
            this.fmwkBatchProcessLog = (CCI_Integration_Error_Retry__c) [SELECT Id FROM CCI_Integration_Error_Retry__c WHERE Id = :this.retryRequestId LIMIT 1];
            setRetryCount();
            setmdtSettings();
            if (this.mdtSettings.size() > 0) {
                if (this.retryCount <= this.mdtSettings[0].Transport_Error_Max_Retry__c) {
                    String sch = generateSchedule();
                    String jobName = 'Integration Framework - ID: ' + this.recordId + ' RETRY_COUNT: ' + String.valueOf(this.retryCount);
                    CCI_FrmwrkRQRErrorRetrySchedulable m = new CCI_FrmwrkRQRErrorRetrySchedulable(this.ipName, this.recordId, this.retryRequestId, this.systemName, this.messageID, this.path, this.payload);               
                    String jobID = System.schedule(jobName, sch, m);
                    System.debug('Scheduled Job'+jobId);
                } else if(this.mdtSettings[0].Transport_Error_Max_Retry__c!=0) {
                    updateRQRBatch('Error', 'Max Retry Limit Reached! \nMax retry allowed: '
                            + this.mdtSettings[0].Transport_Error_Max_Retry__c + '\nNumber of retries already attempted: ' + this.retryCount);
                }
                else{
                    updateRQRBatch('Error', null);
                }
            }

        }
    }

    /*************************************************************************************
    @Description : Used to schedule the apex class
	@Author 	 : SFDC
	@Params 	 : None
	@Return 	 : String
    **************************************************************************************/
    private String generateSchedule() {
        Integer RetryDelay = (Integer) this.mdtSettings[0].Transport_Layer_Retry_Delay__c;
        Datetime NewDatetime = Datetime.now();
        NewDatetime = NewDatetime.addMinutes(this.retryCount * RetryDelay);
        String Year = String.valueOf(NewDatetime).substring(0, 4);
        String Day = String.valueOf(NewDatetime).substring(8, 10);
        String Month = String.valueOf(NewDatetime).substring(5, 7);
        String Hour = String.valueOf(NewDatetime).substring(11, 13);
        String Minute = String.valueOf(NewDatetime).substring(14, 16);
        String sch = '0 ' + Minute + ' ' + Hour + ' ' + Day + ' ' + Month + ' ? ' + Year;
        return sch;
    }

    /*************************************************************************************
    @Description : Used to update the status of the error retry object
	@Author 	 : SFDC
	@Params 	 : String status, String errorMessage
	@Return 	 : None
    **************************************************************************************/
    private void updateRQRBatch(String status, String errorMessage) {
        this.fmwkBatchProcessLog.Status__c = status;
        if(errorMessage!=null){  
            this.fmwkBatchProcessLog.Error_Message__c = errorMessage;
        }
        update this.fmwkBatchProcessLog;
    }

    /*************************************************************************************
    @Description : Return the count of Error retry object
	@Author 	 : SFDC
	@Params 	 : None
	@Return 	 : None
    **************************************************************************************/
    private void setRetryCount() {
        this.retryCount = [
                SELECT COUNT()
                FROM CCI_Integration_Error_Retry__c
                WHERE Parent_Record_SFDC_ID__c = :this.recordId 
                AND System_Name__c = :this.systemName
        ];
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