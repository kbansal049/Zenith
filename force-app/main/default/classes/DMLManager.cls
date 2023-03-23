public class DMLManager {
    
    public static List<Database.SaveResult> dmlResults = new List<Database.SaveResult>();
    public static List<Database.UpsertResult> dmlUpsertResults = new List<Database.UpsertResult>();
    public static List<Database.DeleteResult> dmlDeleteResults = new List<Database.DeleteResult>();
    public static List<ErrorLogModel> errors = new List<ErrorLogModel>();
    public static String className = '';

    public static List<Id> recordIds {
        get {
            return recordIds == null ? (recordIds = new List<Id>()) : recordIds;
        }
        private set;
    }
    
    //static Methods for Inserting single records
    public static void insertAsSystem(sObject obj){ insertAsSystem(new List<SObject> {obj}); }
    public static void updateAsSystem(sObject obj){ updateAsSystem(new List<SObject> {obj}); }
    public static void updateAsSystem(sObject obj,String className){ updateAsSystem(new List<SObject> {obj}); }
    public static void upsertAsSystem(sObject obj){ upsertAsSystem(new List<SObject> {obj}); }
    public static void deleteAsSystem(sObject obj){ deleteAsSystem(new List<SObject> {obj}); }
    
    //static Methods for Inserting multiple records
    public static void insertAsSystem(List<SObject> objList){ dmlInsert(objList); }
    public static void updateAsSystem(List<SObject> objList){ dmlUpdate(objList); }
    public static void updateAsSystem(List<SObject> objList,String className){ dmlUpdate(objList); }
    public static void upsertAsSystem(List<SObject> objList){ dmlUpsert(objList); }
    public static void deleteAsSystem(List<SObject> objList){ dmlDelete(objList); }
    
    private static void dmlInsert(List<SObject> objList) {
        dmlResults = Database.insert(objList, false);
        dmlOperationResult();
    }
    
    @TestVisible
    private static void dmlUpdate(List<SObject> objList,String apexClassName) {
        dmlResults = Database.update(objList, false);
        className = apexClassName;
        dmlOperationResult();
    }

    private static void dmlUpdate(List<SObject> objList) {
        dmlResults = Database.update(objList, false);
        dmlOperationResult();
    }
    
    private static void dmlUpsert(List<SObject> objList) {
        dmlUpsertResults = Database.upsert(objList, false);
        dmlUpsertOperationResult();
    }
    
    private static void dmlDelete(List<SObject> objList) {
        dmlDeleteResults = Database.delete(objList, false);
        dmlDeleteOperationResult();
    }
    
    private static void dmlOperationResult() {
        for (Database.SaveResult dmlResult : dmlResults) {                
            if (dmlResult.isSuccess()) {
                recordIds.add(dmlResult.getId());
            }else {
                errors.addAll(getErrorLogModel(dmlResult.getErrors()));
                insertLogs();
            }
        }
    }
    
    private static void dmlUpsertOperationResult() {
        for (Database.UpsertResult dmlUpsertResult : dmlUpsertResults) {                
            if (dmlUpsertResult.isSuccess()) {
                recordIds.add(dmlUpsertResult.getId());
            }else {
                errors.addAll(getErrorLogModel(dmlUpsertResult.getErrors()));
                insertLogs();
            }
        }
    }
    
    private static void dmlDeleteOperationResult() {
        for (Database.DeleteResult dmlDeleteResult : dmlDeleteResults) {                
            if (dmlDeleteResult.isSuccess()) {
                recordIds.add(dmlDeleteResult.getId());
            }else {  
            	errors.addAll(getErrorLogModel(dmlDeleteResult.getErrors()));  
                insertLogs();
            }
        }
    }
    
    private static List<ErrorLogModel> getErrorLogModel(List<Database.Error> errors) {
        List<ErrorLogModel> errorLogs = new List<ErrorLogModel>();
        for(Database.Error err : errors) {
            errorLogs.add(new ErrorLogModel(String.valueOf(err.getStatusCode()),String.valueOf(err.getMessage()),err.getFields()));
        }
        return errorLogs;
    }
    
    private static void insertLogs() {
        
        ErrorLogModel error = errors.isEmpty() ? null :  errors.get(0);
        String exceptionMsg =  error != null ? error.statusCode +' '+ error.errorMessage + ' '+ error.errorFields : ' ' ;
        System.debug('Error occured in insertion '+ error.statusCode +' '+ error.errorMessage + ' '+ error.errorFields);
        
        if(System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled()) {
         	
        ZscalerErrorLogsUtility.insertLogsForAsync(className, 'error during DML',
                                                   'Apex', null,
                                                   'Sales Cloud',exceptionMsg , 
                                                   'DMLManager:', 'DML Operation failed');   
        }else {
            
        ZscalerErrorLogsUtility.insertLogs(className, 'error during DML',
                                                   'Apex', null,
                                                   'Sales Cloud',exceptionMsg , 
                                                   'DMLManager:', 'DML Operation failed');
        }
    }
    
    public Class ErrorLogModel {
        public String statusCode;
        public String errorMessage;
        public List<String> errorFields;
        
        public ErrorLogModel() {}
        
        public ErrorLogModel(String statusCode, String errorMessage, List<String> errorFields) {
            this.statusCode = statusCode;
            this.errorMessage = errorMessage;
            this.errorFields = errorFields;
        }
    }    
}