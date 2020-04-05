@isTest
private class Test_Logger {
    private class TestException extends Exception {}

    @isTest
    private static void testInsertLogs() {
        Logger logger = new Logger();
        logger.setClass('Test_Logger');
        logger.setMethod('testInsertLogs');
        System.assertEquals('Test_Logger.testInsertLogs', logger.getScope(), 'Scope is not what is expected');
        Exception e = new TestException('Test exception');
        Log errorLog = logger.log(e);
        logger.insertLogs();
        List<Log__c> logs = [
            SELECT Id, Name, Details__c, Message__c,
                Type__c, ErrorType__c, Scope__c
            FROM Log__c
            ORDER BY CreatedDate
            DESC LIMIT 1
        ];
        System.assertEquals(1, logs.size());
        Log__c logRecord = logs[0];
        System.assertEquals(Log.TYPE_ERROR, logRecord.Type__c);
        System.assertEquals(e.getTypeName(), logRecord.ErrorType__c);
        System.assertEquals(e.getMessage(), logRecord.Message__c);
        System.assertEquals(e.getStackTraceString(), logRecord.Details__c);
        System.assertEquals(logger.getScope(), logRecord.Scope__c);
    }
}
