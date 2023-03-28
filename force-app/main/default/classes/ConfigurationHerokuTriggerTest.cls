@isTest
public class ConfigurationHerokuTriggerTest {
    @TestSetup
    static void makeData(){
        Configuration_Heroku__c newConfig = new Configuration_Heroku__c();
        newConfig.Object_1_API_Name__c = 'Test Object';
        newConfig.Object_2_API_Name__c = 'Test Object';
        newConfig.Object_3_API_Name__c = 'Test Object';
        newConfig.Object_4_API_Name__c = 'Test Object';
        newConfig.Object_5_API_Name__c = 'Test Object';
        newConfig.Status__c = 'Active';
        insert newConfig;
    }

    @isTest public static void testMaxNumberOfSyncedObjects(){
        Configuration_Heroku__c newConfig = new Configuration_Heroku__c();
        newConfig.Object_1_API_Name__c = 'Test Object';
        newConfig.Status__c = 'Active';
        Test.startTest();
            Database.SaveResult tooManyObjectsSyncedResult = Database.insert(newConfig, false);
        Test.stopTest();
        System.assert(tooManyObjectsSyncedResult.isSuccess() == false, 'Result should not be successful');
        System.assert(tooManyObjectsSyncedResult.getErrors().size() == 1);
    }
}