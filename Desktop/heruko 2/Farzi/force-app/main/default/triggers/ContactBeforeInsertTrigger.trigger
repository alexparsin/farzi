trigger ContactBeforeInsertTrigger on Contact (before insert, before update) {
    For( contact c: trigger.new){        
        if(c.Heroku_Sync_Status__c==true && trigger.isinsert){
            c.Expected_Date_to_Delete__c=date.today()+7;
        }
        if(trigger.isupdate && trigger.oldmap.get(c.id).Heroku_Sync_Status__c!=c.Heroku_Sync_Status__c){
             c.Expected_Date_to_Delete__c=date.today()+7;
        }
    }
}