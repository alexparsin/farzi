public without sharing class HerokuSyncUtils {
    public virtual class HerokuSyncException extends Exception {}
    public class ConfigurationException extends HerokuSyncException {}

    public static final String HEROKU_ENDPOINT_SEARCH_RECORDS = 'searchRecords';
    public static final String HEROKU_ENDPOINT_SYNC_RECORDS = 'syncRecords';
    public static final String HEROKU_ENCRYPTION_ALGORITHM = 'AES256';

    public static HTTPRequest populateCredentials(){
        Heroku_Sync_Settings__c hss = getSyncConfiguration();
        if(String.isBlank(hss.Username__c) || String.isBlank(hss.Password__c)){
            ConfigurationException newError = new ConfigurationException('The credentials should be populated in custom settings');
            HerokuErrorLog_Utils.logError(newError, new List<Heroku_Sync_Settings__c>{hss});
            throw newError;
        }
        HTTPRequest req = new HTTPRequest();
        req.setHeader('username', hss.Username__c);
        req.setHeader('password', hss.Password__c);
        req.setEndpoint(hss.Endpoint__c);
        return req;
    }

    public static String getEndpoint(Heroku_Sync_Settings__c hss){
        if(hss == null){
            hss = getSyncConfiguration();
        }
        return hss.Endpoint__c;
    }

    public static String authenticate() {
        HTTPRequest req = HerokuSyncUtils.populateCredentials();
        Http http = new Http();
        HTTPResponse res = http.send(req);
        HerokuSyncUtils.HerokuResponseWrapper wrap = (HerokuSyncUtils.HerokuResponseWrapper)JSON.deserialize(res.getBody(), HerokuSyncUtils.HerokuResponseWrapper.class);
        HerokuSyncUtils.saveAccessToken(wrap.access_token);
        return wrap.access_token;
    }

    public static void saveAccessToken(String access_token){
        Cache.Session.put('herokuaccesstoken', access_token);
    }

    public static String getAccessToken(){
        return (String)Cache.Session.get('herokuaccesstoken');
    }

    public static Heroku_Sync_Settings__c getSyncConfiguration(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Heroku_Sync_Settings__c hss = Heroku_Sync_Settings__c.getInstance(adminProfile.Id);
        if(hss == null){
            // Log an error: credentials have not been configured in custom settings
            ConfigurationException newError = new ConfigurationException('Configuration not found in custom settings');
            HerokuErrorLog_Utils.logError(newError, null);
            throw newError;
        }
        if(String.isBlank(hss.Encryption_Key_Heroku__c) || String.isBlank(hss.Encryption_Key_SF__c)){
            // Log an error: Encryption Keys should be populated in Custom Setting
            ConfigurationException newError = new ConfigurationException('The Encryption Keys should be populated in custom settings');
            HerokuErrorLog_Utils.logError(newError, new List<Heroku_Sync_Settings__c>{hss});
            throw newError;
        }
        if(String.isBlank(hss.Init_Vector_Heroku__c) || String.isBlank(hss.Init_Vector_SF__c)){
            // Log an error: Encryption Keys should be populated in Custom Setting
            ConfigurationException newError = new ConfigurationException('The Init Vectors should be populated in custom settings');
            HerokuErrorLog_Utils.logError(newError, new List<Heroku_Sync_Settings__c>{hss});
            throw newError;
        }
        return hss;
    }

    public static HTTPResponse sendRequestToHeroku(HTTPRequest req){
        String accessToken = getAccessToken();
        if(accessToken == null){
            accessToken = authenticate();
        }
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        Http http = new Http();
        return http.send(req);
    }

    public static String encryptData(List<sObject> records){
        Heroku_Sync_Settings__c hss = getSyncConfiguration();
        Blob encryptedDate = Crypto.encrypt(
            HEROKU_ENCRYPTION_ALGORITHM,
            EncodingUtil.base64Decode(hss.Encryption_Key_SF__c),
            EncodingUtil.base64Decode(hss.Init_Vector_SF__c),
            Blob.valueOf(JSON.serialize(records))
        );
        return EncodingUtil.base64Encode(encryptedDate);
    }

    public static String encryptDataHeroku(List<sObject> records){
        Heroku_Sync_Settings__c hss = getSyncConfiguration();
        Blob encryptedDate = Crypto.encrypt(
            HEROKU_ENCRYPTION_ALGORITHM,
            EncodingUtil.base64Decode(hss.Encryption_Key_Heroku__c),
            EncodingUtil.base64Decode(hss.Init_Vector_Heroku__c),
            Blob.valueOf(JSON.serialize(records))
        );
        return EncodingUtil.base64Encode(encryptedDate);
    }

    public class HerokuResponseWrapper{
        public String result;
        public String access_token;
        public List<String> errors;
        public Map<String, List<sObject>> records;
    }
}