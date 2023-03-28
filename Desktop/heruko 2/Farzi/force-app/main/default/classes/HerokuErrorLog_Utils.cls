public without sharing class HerokuErrorLog_Utils {
    public static void logError(HerokuSyncUtils.ConfigurationException e, List<sObject> relatedRecords){
        Heroku_Error_Log__c newLog = new Heroku_Error_Log__c();
        newLog.Description__c = e.getStackTraceString();
        newLog.Related_Records__c = JSON.serialize((new Map<Id,SObject>(relatedRecords)).keySet());
        newLog.Summary__c	 = e.getMessage();
        insert newLog;
    }
}