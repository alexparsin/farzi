/**
* Author           : Naveen
* Release          : To be confirmed
* Descrption       : This component will prepare the data to sync Heroku system*
* ClassName        : HerokuSyncBatchApexHelper.cls 
* Test Class       : HerokuSyncBatchApexHelperTest.cls
-----------------------------------------------------------------------------------------------------------
Ver       Date            Author                      Modification                   MathodName
-----------------------------------------------------------------------------------------------------------
1.0    16/01/2023       Naveen                         -                                   -
*/
public class HerokuSyncBatchApexHelper {
    Public static integer Obj1Count; 
    Public static integer Obj2Count;  
    Public static integer Obj3Count;  
    Public static integer Obj4Count;  
    Public static integer Obj5Count;
    Public Static List<string> listOfSobjectQuries;
    Public Static List<string> stringData=New List<string>();
    Public HerokuSyncBatchApexHelper(){
        //stringData=New List<String>();
    }
    Public Static void getHerokuObjData(List<Configuration_Heroku__c> listOfHerokus){
        System.debug('Watch the List of Herokus:::'+listOfHerokus);  
        listOfSobjectQuries=New List<String>();
        for(Configuration_Heroku__c a : listOfHerokus)
        {
            if(string.isNotEmpty(a.Object_1_API_Name__c)){              
               List<sobject> obj1Records= HerokuSyncBatchApexHelper.prepareSobjectSoql(a.Object_1_API_Name__c,a.Fields_1_APIs__c,a.Filter_Condition_1__c);
           a.Object_1_Count__c=obj1Records.size()>0?obj1Records.size():0;
            }
            if(string.isNotEmpty(a.Object_2_API_Name__c)){              
                List<sobject> obj2Records=HerokuSyncBatchApexHelper.prepareSobjectSoql(a.Object_2_API_Name__c,a.Fields_2_APIs__c,a.Filter_Condition_2__c);
            a.Object_2_Count__c=obj2Records.size()>0?obj2Records.size():0;
            }
            if(string.isNotEmpty(a.Object_3_API_Name__c)){              
                List<sobject> obj3Records=HerokuSyncBatchApexHelper.prepareSobjectSoql(a.Object_3_API_Name__c,a.Fields_3_APIs__c,a.Filter_Condition_3__c);
            a.Object_3_Count__c=obj3Records.size()>0?obj3Records.size():0;
            }
            if(string.isNotEmpty(a.Object_4_API_Name__c)){              
                List<sobject> obj4Records=HerokuSyncBatchApexHelper.prepareSobjectSoql(a.Object_4_API_Name__c,a.Fields_4_APIs__c,a.Filter_Condition_4__c);
            a.Object_4_Count__c=obj4Records.size()>0?obj4Records.size():0;
            }
            if(string.isNotEmpty(a.Object_5_API_Name__c)){              
                List<sobject> obj5Records=HerokuSyncBatchApexHelper.prepareSobjectSoql(a.Object_5_API_Name__c,a.Fields_5_APIs__c,a.Filter_Condition_5__c); 
            a.Object_5_Count__c=obj5Records.size()>0?obj5Records.size():0;
            }
        }
        database.update(listOfHerokus,false);
        System.debug('Watch Json Data::::'+HerokuSyncBatchApexHelper.stringData);
        
    }
    Public static List<Sobject> prepareSobjectSoql(string ObjAPI,String ObjFields,String ObjFilter){
        // if(string.isNotEmpty(a.Object_1_API_Name__c)){
        string q1;
        if(string.isNotEmpty(ObjFields)){
            q1='Select '+ObjFields+',Number_of_times_Job_run__c,Heroku_Sync_Status__c,Expected_Date_to_Delete__c From '+ObjAPI;
        }
        if(string.isNotEmpty(ObjFilter)){
         //   q1+=' Where '+ObjFilter+' AND Heroku_Sync_Status__c=false';
         q1+=' Where '+ObjFilter;
        }else{
         //   q1+=' Where Heroku_Sync_Status__c=false'; 
         //  q1+=' Where Heroku_Sync_Status__c=false'; 
        }
        listOfSobjectQuries.add(q1);
        List<Sobject> recList=HerokuSyncBatchApexHelper.updateObjData(q1);
        System.debug('Watch Query::'+listOfSobjectQuries);
        return recList.size()>0?recList:null;
        // }
    }
    Public static List<Sobject> updateObjData(String ObjQuery){
       // if(string.isNotEmpty(ObjQuery)){
            List<Sobject> listOfRecords=database.query(ObjQuery);
            System.debug('Watch the listOfRecords size:::'+listOfRecords.size());
            if(listOfRecords.size()>0){
                // Identify and delte the already heroku synced records
                List<Sobject> ListOfFinalRec=HerokuSyncBatchApexHelper.deleteSyncedRecs(listOfRecords);
                // Delete End
                List<Sobject> getUpdatedSobj=New List<Sobject>();
                string str=HerokuSyncBatchApexHelper.parseDataToString(ListOfFinalRec);
                HerokuSyncBatchApexHelper.stringData.add(str);
                //  List<contact> conlist=New List<contact>();
                for(Sobject obj: ListOfFinalRec){
                    System.debug('Sobject obj::'+obj);
                    sobject so=obj.id.getSobjectType().newSobject(obj.id);
                    integer syncCount=integer.valueOf(obj.get('Number_of_times_Job_run__c'));                  
                    so.put('Ready_to_migrate_to_Heroku__c',true);
                    if(syncCount!=null){
                        so.put('Number_of_times_Job_run__c',syncCount+1);
                    }else{
                        so.put('Number_of_times_Job_run__c',1);
                    }                   
                    System.debug('Sobject Type::'+so);
                    getUpdatedSobj.add(so);
                    /*    Object c=obj.get('Contact');
system.debug(''+Id.valueof(obj.id));
contact c=New contact();
c.Ready_to_migrate_to_Heroku__c=true;
c.Id=Id.valueof(obj.id);
conlist.add(c);    */             
                }
                update getUpdatedSobj;
            }
    //    }
        return listOfRecords.size()>0?listOfRecords:null;
    }
    Public static string parseDataToString(List<Sobject> sObjList){
        String jsonString = json.serialize(sObjList);
        return string.isNotEmpty(jsonString)?jsonString:null;
    }
    // By calling this method, it will delete the list of records which are already synced to Heroku
    Public Static List<Sobject> deleteSyncedRecs(List<Sobject> listOfRecords){
        System.debug('Watch List of Recors::'+listOfRecords.size());
        List<Sobject> finalRecords=New List<Sobject>();
        List<Sobject> deleteList=New List<Sobject>();
        Try{
            for(Sobject obj: listOfRecords){
                Boolean checkStatus=boolean.valueOf(obj.get('Heroku_Sync_Status__c'));
                if(checkStatus==true){
                    date TodayDate = date.today();
                    date recordDate = date.valueOf(obj.get('Expected_Date_to_Delete__c')); 
                    if(recordDate<=TodayDate){
                        deleteList.add(obj);
                    }
                }else{
                    finalRecords.add(obj);
                }                             
            }
            System.debug('Watch Deleted List:::'+deleteList);
            if(deleteList.size()>0){
                Database.delete(deleteList);
            }
            return finalRecords.size()>0?finalRecords:null;
        }catch(exception e){
            System.debug('Watch Catch block of deleteSyncedRecs::::'+e.getMessage()+'===LineNumber===='+e.getLineNumber());
            return null;
        }
    }
}