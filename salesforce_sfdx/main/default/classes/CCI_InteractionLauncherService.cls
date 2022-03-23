global class CCI_InteractionLauncherService implements omnistudio.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        Boolean result = true;
        try{
            if(methodName.equals('searchMember')){
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
                    String QueryLine =' LastName Like ' + searchString + '%\' ';
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
                if(!sobjList.isEmpty()){
                    output.put('Detail', sobjList);
                }
            }
        } catch(Exception e){
            result = false;
        }
        return result;
    }
}