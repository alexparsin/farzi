trigger AccountBeforeInsertTrigger on Account (before insert,before update) {
    For(account a: trigger.new){        
        if(a.Heroku_Sync_Status__c==true && trigger.isinsert){
            a.Expected_Date_to_Delete__c=date.today()+7;
        }
        if(trigger.isupdate && trigger.oldmap.get(a.id).Heroku_Sync_Status__c!=a.Heroku_Sync_Status__c){
             a.Expected_Date_to_Delete__c=date.today()+7;
        }
    }
}