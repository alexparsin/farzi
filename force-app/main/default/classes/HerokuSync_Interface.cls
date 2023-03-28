public interface HerokuSync_Interface {
    List<sObject> syncRecords(List<sObject> records);
    List<sObject> searchRecords(String searchTerm);
}