/*********************************************************************** 
* @ClassName 				: CCI_Constants
  @testClass				: None
* @Description 				: Constant Class
* @Reason for Class Sharing : Constant Class
* @Author 					: 
* @RevisionHistory 			: CH00
* @Version          Date              Changes made 
    CH00		    12/27/2020		  Initial Draft
************************************************************************/
public without sharing class CCI_Constants {
    
    
    /***********************************************************************
    @Description : Data type Constants values
	@Author 	 : SFDC
    ************************************************************************/
    public static final String AUTHTOKEN 	= 'Authtoken';
    public static final String USERNAME 	= 'Username';
    public static final String PASSWORD 	= 'Password';
    public static final String AUTH_HEADER 	= 'AuthHeader';
    public static final String AUTH_TYPE	= 'AuthType';
   	
    public static final String GET_BASE64STRING 	= 'getBase64String';
    public static final String CONTENT_DOCUMENT_ID 	= 'ContentDocumentId';
    public static final String BASE64STRING 		= 'Base64String';
    
    public static final String UTILITY_METHOD		= 'utilityMethod';
    public static final String P8_POST_UPLOAD		= 'P8PostUpload';
    
    
    public static map<String, String> GET_MIMETYPE_MAPPING = new map<String, String> 
    {
     'text/csv' => 'csv', 
     'application/csv' => 'csv1', 
     'application/json' => 'json',
     'text/plain' => 'txt', 
     'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xlsx', 
     'application/vnd.ms-excel.sheet.binary.macroEnabled.12' => 'xlsb',
     'application/vnd.ms-excel' => 'xls', 
     'application/vnd.ms-excel.sheet.macroEnabled.12' => 'xlsm', 
     'application/msword' => 'doc',
      'image/tiff' => 'tiff',
     'image/tif' => 'tif',
     'image/bmp' => 'bmp', 
     'image/gif' => 'gif', 
     'image/jpeg' => 'jpeg',
     'image/jpg' => 'jpg', 
     'image/png' => 'png', 
     'application/vnd.ms-word.document.macroEnabled.12' => 'docm',
     'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx', 
     'application/vnd.openxmlformats-officedocument.wordprocessingml.template' => 'dotx', 
     'application/vnd.ms-word.template.macroEnabled.12' => 'dotm',
     'text/html' => 'html', 
     'application/pdf' => 'pdf', 
     'application/vnd.ms-powerpoint.template.macroEnabled.12' => 'potm',
     'application/vnd.openxmlformats-officedocument.presentationml.template' => 'potx', 
     'application/vnd.ms-powerpoint.addin.macroEnabled.12' => 'ppam', 
     'application/vnd.openxmlformats-officedocument.presentationml.slideshow' => 'pps',
     'application/vnd.openxmlformats-officedocument.presentationml.slideshow' => 'ppsx', 
     'application/vnd.ms-powerpoint.slideshow.macroEnabled.12' => 'ppsm', 
     'application/vnd.ms-powerpoint' => 'ppt',
     'application/vnd.ms-powerpoint.presentation.macroEnabled.12' => 'pptm', 
     'application/vnd.openxmlformats-officedocument.presentationml.presentation' => 'pptx', 
     'application/rtf' => 'rtf',
     'text/rtf' => 'rtf2'
     
    };
}