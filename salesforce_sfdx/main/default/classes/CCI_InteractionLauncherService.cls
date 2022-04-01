global class CCI_InteractionLauncherService implements omnistudio.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        Boolean result = true;
        try{
            if(methodName.equals('searchMember')){
                output.put('hasData', false);
                String BusinessLine = String.valueOf(options.get('BusinessLine'));
                String MemberId = String.valueOf(options.get('MemberId'));
                String FirstName = String.valueOf(options.get('FirstName'));
                String LastName = String.valueOf(options.get('LastName'));
                String SSN = String.valueOf(options.get('SSN'));
                String DOB = String.valueOf(options.get('DOB'));
                String MedicareHIC = String.valueOf(options.get('MedicareHIC'));
                List<Id> MemberIds = new List<Id>();
                if(!String.isEmpty(BusinessLine)){
                    List<Memberplan> memberPlans = [SELECT Id, MemberId From Memberplan Where Product_Line__c = :BusinessLine];
                    for(Memberplan plan : Memberplans){
                        MemberIds.add(plan.MemberId);
                    }
                }
                String QueryHeader = 'SELECT Id, FirstName, LastName, Medicare_HIC_MBI__c, Member_Id__c, SSN__c, PersonBirthdate, (Select street,state,city,Country,postalcode, parentId from Contactpointaddresses where isActiveNow__c = true and AddressType = \'Mailing Address\') From Account Where ';
                List<String> queryLines = new List<String>();
                
                String RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Member').getRecordTypeId();
                if(!String.isEmpty(RecordTypeId)){
                    String QueryLine =' RecordTypeId  = :RecordTypeId ';
                    queryLines.add(QueryLine);
                }
                if(!String.isEmpty(MemberId)){
                    String QueryLine =' Member_Id__c = :MemberId ';
                    queryLines.add(QueryLine);
                }
                if(!String.isEmpty(FirstName)){
                    String searchString ='\'' + FirstName  + '';
                    String QueryLine =' FirstName Like ' + searchString + '%\' ';
                    queryLines.add(QueryLine);
                }
                if(!String.isEmpty(LastName)){
                    String searchString ='\'' + LastName  + '';
                    String QueryLine =' LastName Like ' + searchString + '%\' ' ;
                    queryLines.add(QueryLine);
                }
                if(!String.isEmpty(SSN)){
                    String QueryLine =' SSN__c = :SSN ';
                    queryLines.add(QueryLine);
                }
                if(!String.isEmpty(DOB)){
                    Date birthDate = Date.parse(DOB);
                    String QueryLine =' PersonBirthdate = :birthDate ';
                    queryLines.add(QueryLine);
                }
                if(!String.isEmpty(MedicareHIC)){
                    String QueryLine =' Medicare_HIC_MBI__c = :MedicareHIC ';
                    queryLines.add(QueryLine);
                }
                if(!MemberIds.isEmpty()){
                    String QueryLine =' Id IN :MemberIds ';
                    queryLines.add(QueryLine);
                }
                String queryBody = String.join(queryLines,' AND ');
                String query = QueryHeader + queryBody;
                List<Account> sobjList = Database.query(query);
                output.put('Detail', sobjList);
                if(!sobjList.isEmpty()){
                    output.put('hasData', true);
                }
            } else if (methodName.equals('querySearch')) {
                querySearch(input, output, options);
            }
        } catch(Exception e){
            result = false;
        }
        return result;
    }


  private static Boolean querySearch(
    Map<String, Object> inputs,
    Map<String, Object> outputs,
    Map<String, Object> options
  ) {
    
    String RadioUserType = String.escapeSingleQuotes((String)inputs.get('RadioUserType')); 
    String ProviderFirstName = String.escapeSingleQuotes((String)inputs.get('ProviderFirstName'));
    String ProviderLastName = String.escapeSingleQuotes((String)inputs.get('ProviderLastName'));
    String ProviderID = String.escapeSingleQuotes((String)inputs.get('ProviderID')); 
    String ProviderNPI = String.escapeSingleQuotes((String)inputs.get('ProviderNPI')); 
    String FacilityName = String.escapeSingleQuotes((String)inputs.get('FacilityName')); 
    String FacilityNPI = String.escapeSingleQuotes((String)inputs.get('FacilityNPI')); 
    String LeadFirstName = String.escapeSingleQuotes((String)inputs.get('LeadFirstName')); 
    String LeadLastName = String.escapeSingleQuotes((String)inputs.get('LeadLastName')); 
    String LeadPhoneNumber = String.escapeSingleQuotes((String)inputs.get('LeadPhoneNumber')); 
    String MemberFirstName = String.escapeSingleQuotes((String)inputs.get('MemberFirstName'));
    String MemberLastName = String.escapeSingleQuotes((String)inputs.get('MemberLastName')); 
    String MemberPhoneNumber = String.escapeSingleQuotes((String)inputs.get('MemberPhoneNumber')); 
    String MemberDateOfBirth = String.escapeSingleQuotes((String)inputs.get('MemberDateOfBirth'));  
    String MemberID = String.escapeSingleQuotes((String)inputs.get('MemberID')); 
    String MemberLast4SocialSecurityNumber = String.escapeSingleQuotes((String)inputs.get('MemberLast4SocialSecurityNumber'));
    
    try {
        
        String query = 'SELECT personmobilephone, firstname, member_id__c, recordtypeid, parentid, lastname, ssn__c, ispersonaccount, personhomephone, work_phone__c, personbirthdate, name, id, personcontactid, abcbs_id__c, npi__c FROM Account';
                
        if (RadioUserType.equals('Provider')) {
            query+=' WHERE isPersonAccount = true AND recordTypeId IN (SELECT id FROM RecordType WHERE DeveloperName = \'Provider\' AND SobjectType = \'Account\')';

            if(!String.isEmpty(ProviderFirstName)) {
                ProviderFirstName = '%'+ProviderFirstName+'%'; 
                query+=' AND FirstName LIKE \''+ProviderFirstName+'\'';
            }

            if(!String.isEmpty(ProviderLastName)) {
                ProviderLastName = '%'+ProviderLastName+'%'; 
                query+=' AND LastName LIKE \''+ProviderLastName+'\'';
            }

            if(!String.isEmpty(ProviderID)) {
                query+=' AND ABCBS_ID__c = \''+ProviderID+'\'';
            }

            if(!String.isEmpty(ProviderNPI)) {
                query+=' AND NPI__c = \''+ProviderNPI+'\'';
            }
            
        } else if(RadioUserType.equals('Member')) {
            query+=' WHERE isPersonAccount = true and recordTypeId IN (SELECT id FROM RecordType WHERE DeveloperName = \'Member\' AND SobjectType = \'Account\')';

            if(!String.isEmpty(MemberFirstName)) {
                MemberFirstName = '%'+MemberFirstName+'%'; 
                query+=' AND FirstName LIKE \''+MemberFirstName+'\'';
            }

            if(!String.isEmpty(MemberLastName)) {
                MemberLastName = '%'+MemberLastName+'%';
                query+=' AND LastName LIKE \''+MemberLastName+'\'';
            }

            if(!String.isEmpty(MemberDateOfBirth)) {
                String year = MemberDateOfBirth.substring(0, 4);
                String month = MemberDateOfBirth.substring(5, 7);
                String day = MemberDateOfBirth.substring(8, 10);
                String stringDate = year + '-' + month+ '-' + day;

                query+=' AND PersonBirthdate = '+stringDate+'';
            }

            if(!String.isEmpty(MemberPhoneNumber)) {
                query+=' AND (PersonMobilePhone = \''+MemberPhoneNumber+'\' OR PersonHomePhone = \''+MemberPhoneNumber+'\' OR Work_Phone__c = \''+MemberPhoneNumber+'\')';
            }

            if(!String.isEmpty(MemberLast4SocialSecurityNumber)) {
                query+=' AND SSN__c = \''+MemberLast4SocialSecurityNumber+'\'';
            }

            if(!String.isEmpty(MemberID)) {
                query+=' AND Id IN (SELECT MemberId FROM MemberPlan WHERE MemberNumber = \''+MemberID+'\')';
            }

        } else if(RadioUserType.equals('Facility')) {
            query+=' WHERE isPersonAccount = false and recordTypeId IN (SELECT id FROM RecordType WHERE DeveloperName = \'InStateFacility\' AND SobjectType = \'Account\')'; 

            if(!String.isEmpty(FacilityName)) {
                FacilityName = '%'+FacilityName+'%';
                query+=' AND Name LIKE \''+FacilityName+'\'';
            }

            if(!String.isEmpty(FacilityNPI)) {
                query+=' AND NPI__c = \''+FacilityNPI+'\'';
            }

        } else if(RadioUserType.equals('Prospect')) {
            query = '';
            query+='SELECT name, firstname, phone, middlename, id, recordtypeid, lastname FROM lead';
            query+=' WHERE recordTypeId IN (SELECT id FROM RecordType WHERE DeveloperName = \'CCI_Prospective_Member\' AND SobjectType = \'Lead\')';  
            
            if(!String.isEmpty(LeadFirstName)) {
                LeadFirstName = '%'+LeadFirstName+'%';
                query+=' AND FirstName LIKE \''+LeadFirstName+'\'';
            }

            if(!String.isEmpty(LeadLastName)) {
                LeadLastName = '%'+LeadLastName+'%';
                query+=' AND LastName LIKE \''+LeadLastName+'\'';
            }

            if(!String.isEmpty(LeadPhoneNumber)) {
                query+=' AND Phone = \''+LeadPhoneNumber+'\'';
            }
        }

        query+=' ORDER BY FirstName LIMIT 10';

        List<Object> listDataBase = Database.query(query);

        if(!listDataBase.isEmpty()) {
            outputs.put('Detail', listDataBase);
            outputs.put('hasData', true);
        } else {
            outputs.put('Detail', null);
            outputs.put('hasData', false);
        }
       
    } catch (Exception e) {
        outputs.put('Error', e.getMessage());
        outputs.put('ErrorLine', e.getLineNumber());
        outputs.put('ErrorType', e.getTypeName());
    }

    return true;
  }
}