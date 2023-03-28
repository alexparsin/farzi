/**
* Author           : Alex Parsin (alexandru.parsin@eleks.com)
* Release          : To be confirmed
* Descrption       : A handler for the ConfigurationHerokuTrigger
* ClassName        : ConfigurationHerokuTriggerHandler.cls 
* Test Class       : ConfigurationHerokuTriggerTest.cls
-----------------------------------------------------------------------------------------------------------
Ver       Date            Author                      Modification                   MathodName
-----------------------------------------------------------------------------------------------------------
1.0    16/03/2023         Alex Parsin                       -                            -
*/
public without sharing class ConfigurationHerokuTriggerHandler {
    public static void checkForExistingConfiguration(List<Configuration_Heroku__c> scope){
        List<Configuration_Heroku__c> existingHerokuRecords = [
            SELECT
                Object_1_API_Name__c,
                Object_2_API_Name__c,
                Object_3_API_Name__c,
                Object_4_API_Name__c,
                Object_5_API_Name__c,
                Status__c
            FROM
                Configuration_Heroku__c
            WHERE
                Status__c = 'Active'
        ];
        Integer objectsSyncedCounter = 0;
        for(Configuration_Heroku__c currentConfiguration : existingHerokuRecords){
            objectsSyncedCounter += getNumberOfObjectsInConfigRecord(currentConfiguration);
        }
        for(Configuration_Heroku__c currentConfiguration : scope){
            Integer objectsToSyncCounter = getNumberOfObjectsInConfigRecord(currentConfiguration);
            // Value to be adjusted dynamically
            Integer maxObjectsAllowed = 5;
            if(objectsSyncedCounter + objectsToSyncCounter > maxObjectsAllowed){
                currentConfiguration.addError('Cannot sync more Objects. Max number of Objects to sync: ' + maxObjectsAllowed + '; Current number of Objects synced: ' + objectsSyncedCounter + ';');
            }
        }
    }

    public static Integer getNumberOfObjectsInConfigRecord(Configuration_Heroku__c configRecord){
        Integer syncedObjCounter = 0;
        if(configRecord.Status__c == 'Active'){
            if(String.isNotEmpty(configRecord.Object_1_API_Name__c)){
                syncedObjCounter++;
            }
            if(String.isNotEmpty(configRecord.Object_2_API_Name__c)){
                syncedObjCounter++;
            }
            if(String.isNotEmpty(configRecord.Object_3_API_Name__c)){
                syncedObjCounter++;
            }
            if(String.isNotEmpty(configRecord.Object_4_API_Name__c)){
                syncedObjCounter++;
            }
            if(String.isNotEmpty(configRecord.Object_5_API_Name__c)){
                syncedObjCounter++;
            }
        }
        return syncedObjCounter;
    }
}