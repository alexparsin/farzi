trigger ConfigurationHerokuTrigger on Configuration_Heroku__c (before insert, before update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){}
        if(Trigger.isUpdate){}
        if(Trigger.isDelete){}
    }
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ConfigurationHerokuTriggerHandler.checkForExistingConfiguration(Trigger.new);
        }
        if(Trigger.isUpdate){
            ConfigurationHerokuTriggerHandler.checkForExistingConfiguration(Trigger.new);
        }
        if(Trigger.isDelete){}
    }
}