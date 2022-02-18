/*********************************************************************** 
* @ClassName 				:  CCI_P8PostRequestWrapper
  @testClass				:  CCI_FrmwrkHttpPostCallout
* @Description 				:  Class
* @Reason for Class Sharing :  Class
* @Author 					: SFDC
* @RevisionHistory 			: 
* @Version          Date              Changes made 
    CH00		     02/16/2022		        Initial Draft
************************************************************************/
public class CCI_P8PostRequestWrapper {
    public Set<cls_searchIndexes> searchIndexes;
    public cls_image image;
    public String objectStore;	//MemAppOS
    public String documentClass;	//MEMAPP
    public String documentType;	//APPL
    public String lineOfBusiness;	//BCBS
    public class cls_searchIndexes {
        public String name;	//CaseID
        public String value;	//5007j00000A8DZeAAN
    }
    public class cls_image {
        public String format;	//application/jpeg
        public String content;	//base64string
    }
}