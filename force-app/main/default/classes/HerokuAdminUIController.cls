global class HerokuAdminUIController {
    
    @AuraEnabled(cacheable=true)
    public static list<Configuration_Heroku__c> getSummaryHerokuRecs(){
        list<Configuration_Heroku__c> getRecords=New list<Configuration_Heroku__c>();
        Try{
            getRecords=[Select id,Name,Status__c,Createddate from Configuration_Heroku__c order by createddate desc];
            Return getRecords;
        }Catch(Exception e){
            System.debug('Watch catchBlock Error::'+e.getMessage()+'====LineNumber==='+e.getLineNumber());
            return getRecords;
        }
    }
    @AuraEnabled(cacheable=true)
    public static list<objectDetails> retrieveObjects(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        list<String> ObjectsName = new list<String>();
        list<objectDetails> objects = new list<objectDetails>();
        
        for(Schema.SObjectType obj : gd.values()){
            ObjectsName.add(String.valueOf(obj));
        }
        
        for(Schema.DescribeSObjectResult objResult: Schema.describeSObjects(ObjectsName)){
            if(!objResult.isCustomSetting()){
                objects.add(new objectDetails(objResult.getLabel(), objResult.isCustom() ? 'Custom Object' : 'Standard Object', objResult.getName()));
            }
        }
        
        system.debug('objects be: '+objects);
        return objects;
    }
    
    @AuraEnabled(cacheable=true)
    public static objectInfo getFields(String selectedObject){
        List<fieldDetails> reqFields = new List<fieldDetails>();
        map<string, string> allRecordTypes = new map<string, string>();        
        
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(selectedObject);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        
        for(Schema.RecordTypeInfo rtinfo: r.getRecordTypeInfos()){
            allRecordTypes.put(rtinfo.getName(),rtinfo.getDeveloperName());
        }
        
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        
        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();
            reqFields.add(new fieldDetails(F.getLabel(), string.valueOf(F.getType()), F.getName()));
        }
        system.debug('reqFields'+reqFields);
        system.debug('allRecordTypes'+allRecordTypes);
        return new objectInfo(reqFields, allRecordTypes);
        
    }
    
    @AuraEnabled(cacheable = true)
    public static boolean checkSyntax(String ObjectAPIName, String filter){
        try{
            String query = 'Select Id from '+ObjectAPIName+' where '+filter;
            system.debug('Query be: '+query);
            List<sObject> sobjList = Database.query(query);
            return true;    
        }
        catch(Exception e){
            system.debug('Exception be '+e.getMessage()+' at line number '+e.getLineNumber());
            return false;
        }
        
    }

    @AuraEnabled(cacheable = true)
    public static Heroku_Sync_Settings__c getSyncConfig(){
        try {
            return HerokuSyncUtils.getSyncConfiguration();
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static string generateSyncConfig(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Heroku_Sync_Settings__c hss = Heroku_Sync_Settings__c.getInstance(adminProfile.Id);
        if(hss == null){
            hss = new Heroku_Sync_Settings__c();
        }
        hss.SetupOwnerId = adminProfile.Id;
        hss.Encryption_Key_Heroku__c = EncodingUtil.base64Encode(Crypto.generateAesKey(256));
        hss.Encryption_Key_SF__c = EncodingUtil.base64Encode(Crypto.generateAesKey(256));
        hss.Endpoint__c = 'https://eleks.herokuapp.com/';
        hss.Init_Vector_Heroku__c = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
        hss.Init_Vector_SF__c = EncodingUtil.base64Encode(Crypto.generateAesKey(128));
        upsert hss;
        return 'success';
    }
    
    
    global class objectDetails{
        @AuraEnabled global String objectName;
        @AuraEnabled global String objectType;
        @AuraEnabled global String objectAPIName;
        public objectDetails (String objectName, String objectType, String objectAPIName) {
            this.objectName = objectName;
            this.objectType = objectType;
            this.objectAPIName = objectAPIName;
        }
    }
    
    global class fieldDetails{
        @AuraEnabled global String fieldName;
        @AuraEnabled global String fieldType;
        @AuraEnabled global String fieldAPIName;
        public fieldDetails (String fieldName, String fieldType, String fieldAPIName) {
            this.fieldName = fieldName;
            this.fieldType = fieldType;
            this.fieldAPIName = fieldAPIName;
        }
    }
    
    global class objectInfo{
        @AuraEnabled global List<fieldDetails> fieldDetails;
        @AuraEnabled global map<String, String> recordTypes;
        public objectInfo (List<fieldDetails> fieldDetails, map<String, String> recordTypes) {
            this.fieldDetails = fieldDetails;
            this.recordTypes = recordTypes;
        }
    }
    @AuraEnabled
    public static String saveMetadata(List<herokuWrapper> myWrap,String Scheduleby,String ScheduleTime,String ScheduleAt, String SelectedDate){
        String response;
        //try{
            System.debug('Watch MyWrapper:::'+myWrap.size());
            //System.debug('Watch MyWrapper:::'+Scheduleby+ScheduleTime+ScheduleAt);
            Configuration_Heroku__c createHeroku=New Configuration_Heroku__c();
            createHeroku.Runs_on__c=ScheduleAt;
            createHeroku.Schedule_By__c=Scheduleby;
            createHeroku.Date__c = Date.valueOf(SelectedDate);
            if(ScheduleTime != Null){
                String[] convertToTime= ScheduleTime.split(':');
                createHeroku.Starts_At__c = Time.newInstance(Integer.valueOf(convertToTime[0]),Integer.valueOf(convertToTime[1]),Integer.valueOf(convertToTime[2]),0);
            }
            createHeroku.Status__c='Active';
            for(integer i=0; i<myWrap.size(); i++){
                if(i==0){
                    createHeroku.Object_1_API_Name__c= myWrap[i].objectAPIName;
                    createHeroku.Filter_Condition_1__c= myWrap[i].ObjWhereCondition;
                    createHeroku.Fields_1_APIs__c= myWrap[i].selectedObjFieldsList;
                }
                if(i==1){
                    createHeroku.Object_2_API_Name__c= myWrap[i].objectAPIName;
                    createHeroku.Filter_Condition_2__c= myWrap[i].ObjWhereCondition;
                    createHeroku.Fields_2_APIs__c= myWrap[i].selectedObjFieldsList;
                }
                if(i==2){
                    createHeroku.Object_3_API_Name__c= myWrap[i].objectAPIName;
                    createHeroku.Filter_Condition_3__c= myWrap[i].ObjWhereCondition;
                    createHeroku.Fields_3_APIs__c= myWrap[i].selectedObjFieldsList;
                }
                if(i==3){
                    createHeroku.Object_4_API_Name__c= myWrap[i].objectAPIName;
                    createHeroku.Filter_Condition_4__c= myWrap[i].ObjWhereCondition;
                    createHeroku.Fields_4_APIs__c= myWrap[i].selectedObjFieldsList;
                }
                if(i==4){
                    createHeroku.Object_5_API_Name__c= myWrap[i].objectAPIName;
                    createHeroku.Filter_Condition_5__c= myWrap[i].ObjWhereCondition;
                    createHeroku.Fields_5_APIs__c= myWrap[i].selectedObjFieldsList;
                }
            }
            insert createHeroku;
            system.debug('createHeroku =====' + createHeroku);
            return createHeroku.id;
        /*}catch(exception e){
            system.debug('exception e=====' + e);
            return 'false'; 
        }*/
        
    }
    Public class herokuWrapper{
        @AuraEnabled
        Public string FilterCondition{ get; set; }
        @AuraEnabled
        Public string ObjectAPIName{ get; set; }
        @AuraEnabled
        Public string objectName{ get; set; }
        @AuraEnabled
        Public string objectType{ get; set; }
        @AuraEnabled 
        Public string ObjWhereCondition{ get; set; }
        @AuraEnabled 
        Public string selectedObjFieldsList{ get; set; }
        @AuraEnabled
        Public boolean IsObjWhereCondition{ get; set; }      
    }
   
}