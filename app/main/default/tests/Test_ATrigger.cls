@isTest
public class Test_ATrigger {
    // TODO: "isFieldChanged" method returns true if field is changed on update operation

    private static final Account TEST_RECORD = new Account(Name = 'Test_ATrigger');

    private static final String INITIALIZE = 'initialize ';
    private static final String PREVALIDATE = 'preValidate ';
    private static final String CALCULATE = 'calculate ';
    private static final String VALIDATE = 'validate ';
    private static final String AFTER_INSERT = 'afterInsert ';
    private static final String AFTER_UPSERT = 'afterUpsert ';
    private static final String AFTER_UPDATE = 'afterUpdate ';
    private static final String VALIDATE_BEFORE_DELETE = 'validateBeforeDelete ';
    private static final String AFTER_DELETE = 'afterDelete ';
    private static final String AFTER_UNDELETE = 'afterUndelete ';

    public static String triggerLog = '';

    public class TestTriggerHandler extends ATrigger {
        protected override void initialize(List<sObject> records) {
            triggerLog += INITIALIZE;
        }

        protected override void calculate(List<sObject> records) {
            triggerLog += CALCULATE;
        }

        protected override void validate(List<sObject> records) {
            triggerLog += VALIDATE;
        }

        protected override void preValidate(List<sObject> records) {
            triggerLog += PREVALIDATE;
        }

        protected override void afterInsert(List<sObject> records) {
            triggerLog += AFTER_INSERT;
        }

        protected override void afterUpsert(List<sObject> records) {
            triggerLog += AFTER_UPSERT;
        }

        protected override void afterUpdate(List<sObject> records) {
            triggerLog += AFTER_UPDATE;
        }

        protected override void validateBeforeDelete(List<sObject> records) {
            triggerLog += VALIDATE_BEFORE_DELETE;
        }

        protected override void afterDelete(List<sObject> records) {
            triggerLog += AFTER_DELETE;
        }

        protected override void afterUndelete(List<sObject> records) {
            triggerLog += AFTER_UNDELETE;
        }
    }

    @isTest
    private static void testInsertSequenceInTrigger() {
        String logToTest = String.join(
            new List<String> {
                INITIALIZE,
                PREVALIDATE,
                CALCULATE,
                VALIDATE,
                AFTER_INSERT,
                AFTER_UPSERT
            },
            ''
        );
        insert TEST_RECORD;
        System.assertEquals(logToTest, triggerLog, 'Sequence is wrong for Insert trigger.');
    }

    @isTest
    private static void testUpdateSequenceInTrigger() {
        String logToTest = String.join(
            new List<String> {
                PREVALIDATE,
                CALCULATE,
                VALIDATE,
                AFTER_UPDATE,
                AFTER_UPSERT
            },
            ''
        );
        insert TEST_RECORD;
        triggerLog = '';
        update TEST_RECORD;
        System.assertEquals(logToTest, triggerLog, 'Sequence is wrong for Update trigger.');
    }

    @isTest
    private static void testDeleteSequenceInTrigger() {
        String logToTest = String.join(
            new List<String> {
                VALIDATE_BEFORE_DELETE,
                AFTER_DELETE
            },
            ''
        );
        insert TEST_RECORD;
        triggerLog = '';
        delete TEST_RECORD;
        System.assertEquals(logToTest, triggerLog, 'Sequence is wrong for Delete trigger.');
    }

    @isTest
    private static void testUndeleteSequenceInTrigger() {
        String logToTest = String.join(
            new List<String> {
                AFTER_UNDELETE
            },
            ''
        );
        insert TEST_RECORD;
        delete TEST_RECORD;
        triggerLog = '';
        undelete TEST_RECORD;
        System.assertEquals(logToTest, triggerLog, 'Sequence is wrong for Delete trigger.');
    }
}
