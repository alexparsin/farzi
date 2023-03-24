/**
* Author           : Naveen
* Release          : To be confirmed
* Descrption       : This component will prepare the data to sync Heroku system*
* ClassName        : HerokuSyncBatchApex.cls 
* Test Class       : HerokuSyncBatchApexTest.cls
-----------------------------------------------------------------------------------------------------------
Ver       Date            Author                      Modification                   MathodName
-----------------------------------------------------------------------------------------------------------
1.0    16/01/2023       Naveen                         -                                   -
*/

global class HerokuSyncBatchApex implements Database.Batchable<sObject>
{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Date__c,Fields_1_APIs__c,Fields_2_APIs__c,Fields_3_APIs__c,Fields_4_APIs__c,Fields_5_APIs__c,Filter_Condition_1__c,Filter_Condition_2__c,Filter_Condition_3__c,Filter_Condition_4__c,Filter_Condition_5__c,Object_1_API_Name__c,Object_2_API_Name__c,Object_3_API_Name__c,Object_4_API_Name__c,Object_5_API_Name__c,Runs_on__c,Schedule_By__c,Starts_At__c,Status__c FROM Configuration_Heroku__c where Status__c=\'Active\'';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Configuration_Heroku__c> scope)
    {
        system.debug('Watch the scope size:::'+scope.size());
        for(Configuration_Heroku__c a : scope)
        {
            // HerokuSyncBatchApexHelper.getHerokuObjData();
        }
        HerokuSyncBatchApexHelper.getHerokuObjData(scope);
        // update scope;
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}