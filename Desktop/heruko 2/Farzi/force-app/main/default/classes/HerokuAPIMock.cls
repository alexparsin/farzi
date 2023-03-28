global class HerokuAPIMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        HerokuSyncUtils.HerokuResponseWrapper wrap = new HerokuSyncUtils.HerokuResponseWrapper();
        Account newAccount = new Account();
        wrap.result = HerokuSyncUtils.encryptDataHeroku(new List<Account>{newAccount});
        wrap.access_token = '1234567890';
        wrap.records = new Map<String, List<sObject>>();
        wrap.records.put('synced_records', new List<sObject>());
        wrap.records.put('error_records', new List<sObject>());
        wrap.errors = new List<String>();
        res.setBody(JSON.serialize(wrap));
        res.setStatusCode(200);
        return res;
    }
}