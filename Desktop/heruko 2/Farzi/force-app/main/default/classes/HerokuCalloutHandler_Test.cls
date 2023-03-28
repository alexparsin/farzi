@isTest
public class HerokuCalloutHandler_Test {
    @testSetup static void setup(){
        Account newAccount = new Account(Name = 'Test Account');
        insert newAccount;
        HerokuAdminUIController.generateSyncConfig();
        Heroku_Sync_Settings__c hss = HerokuAdminUIController.getSyncConfig();
        hss.Username__c = 'testUsername';
        hss.Password__c = 'testPassword';
        update hss;
    }

    @isTest static void syncRecords_Test(){
        Test.setMock(HttpCalloutMock.class, new HerokuAPIMock());
        List<Account> accountsList = [SELECT Id FROM Account];
        Test.startTest();
            HerokuCalloutHandler.syncRecords(accountsList);
        Test.stopTest();
    }

    @isTest static void searchRecords_Test(){
        Test.setMock(HttpCalloutMock.class, new HerokuAPIMock());
        List<Account> accountsList = [SELECT Id FROM Account];
        Test.startTest();
            HerokuCalloutHandler.searchRecords('test');
        Test.stopTest();
    }

    @isTest static void logError_Test(){
        HerokuErrorLog_Utils.logError(new HerokuSyncUtils.ConfigurationException('test exception'), new List<sObject>());
    }
}