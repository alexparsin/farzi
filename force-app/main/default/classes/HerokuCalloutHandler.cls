public class HerokuCalloutHandler  implements HerokuSync_Interface{

    public static List<sObject> syncRecords(List<sObject> records){
        HTTPRequest req = new HTTPRequest();
        String endpoint = HerokuSyncUtils.getEndpoint(null);
        endpoint += HerokuSyncUtils.HEROKU_ENDPOINT_SYNC_RECORDS;
        req.setEndpoint(endpoint);
        req.setBody(HerokuSyncUtils.encryptData(records));
        HTTPResponse res = HerokuSyncUtils.sendRequestToHeroku(req);
        return getResultRecords(res);
    }
    
    public static List<sObject> searchRecords(String searchTerm){
        HTTPRequest req = new HTTPRequest();
        String endpoint = HerokuSyncUtils.getEndpoint(null);
        endpoint += HerokuSyncUtils.HEROKU_ENDPOINT_SEARCH_RECORDS;
        endpoint += '?searchTerm=' + searchTerm;
        req.setEndpoint(endpoint);
        HTTPResponse res = HerokuSyncUtils.sendRequestToHeroku(req);
        return getResultRecords(res);
    }

    public static List<sObject> getResultRecords(HTTPResponse res){
        HerokuSyncUtils.HerokuResponseWrapper wrap = (HerokuSyncUtils.HerokuResponseWrapper)JSON.deserialize(res.getBody(), HerokuSyncUtils.HerokuResponseWrapper.class);
        Heroku_Sync_Settings__c hss = HerokuSyncUtils.getSyncConfiguration();
        String decryptedString = Crypto.decrypt(
            HerokuSyncUtils.HEROKU_ENCRYPTION_ALGORITHM,
            EncodingUtil.base64Decode(hss.Encryption_Key_Heroku__c),
            EncodingUtil.base64Decode(hss.Init_Vector_Heroku__c),
            EncodingUtil.base64Decode(wrap.result)
        ).toString();
        return (List<sObject>)JSON.deserialize(decryptedString, List<sObject>.class);
    }
}